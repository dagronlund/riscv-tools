riscv-tools [![Build Status](https://travis-ci.org/ucb-bar/riscv-tools.svg?branch=master)](https://travis-ci.org/ucb-bar/riscv-tools) 
===========================================================================

##The RISC-V GCC/Newlib Toolchain Installation Manual

This document was authored by [Quan Nguyen](http://ocf.berkeley.edu/~qmn) and is a mirrored version (with slight modifications) of the one found at [Quan's OCF
website](http://ocf.berkeley.edu/~qmn/linux/install-newlib.html). Recent updates were made by Sagar Karandikar.

Last updated August 6, 2014

## Introduction

The purpose of this page is to document a procedure through
which an interested user can build the RISC-V GCC/Newlib toolchain.

A project with a duration such as this requires adequate
documentation to support future development and maintenance. This document is
created with the hope of being useful; however, its accuracy is not
guaranteed.

This work was completed at Andrew and Yunsup's request.

## Table of Contents

1.  Introduction
2.  Table of Contents
3.  [Meta-installation Notes](#meta-installation-notes)
4.  [Installing the Toolchain](#installing-toolchain)
5.  [Testing Your Toolchain](#testing-toolchain)
6.  ["Help! It doesn't work!"](#help-it-doesnt-work)

## <a name="meta-installation-notes"></a>Meta-installation Notes

You may notice this document strikes you as similar to its 
bigger sibling, the <a href="install-linux.html">
Linux/RISC-V Installation Manual</a>. That's because the instructions are rather
similar. That said...

### Running Shell Commands

Instructive text will appear as this paragraph does. Any
instruction to execute in your terminal will look like this:

	$ echo "execute this"

_Optional_ shell commands that may be required for
your particular system will have their prompt preceeded with an O:

	O$ echo "call this, maybe"

If you will need to replace a bit of code that applies
specifically to your situation, it will be surrounded by [square brackets].

### The Standard Build Unit

To instruct how long it will take someone to build the
various components of the packages on this page, I have provided build times in
terms of the Standard Build Unit (SBU), as coined by Gerard Beekmans in his
immensely useful [Linux From Scratch](http://www.linuxfromscratch.org)
website.

On an Intel Xeon Dual Quad-core server with 48 GiB RAM, I
achieved the following build time for `binutils`: 38.64 seconds.
Thus, **38.64 seconds = 1 SBU**. (EECS members at the University
 of California, Berkeley: I used the `s141.millennium` server.)

As a point of reference, my 2007 MacBook with an Intel Core 2
Duo and 1 GiB RAM has 100.1 seconds to each SBU. Building
`riscv-linux-gcc`, unsurprisingly, took about an hour.

Items marked as "optional" are not measured.

### Having Superuser Permissions

You will need root privileges to install
the tools to directories like `/usr/bin`, but you may optionally
specify a different installation directory. Otherwise, superuser privileges are
not necessary.

### GCC Version

Note: Building `riscv-tools` requires GCC >= 4.8 for C++11 support (including thread_local). To use a compiler different than the default (for example on OS X), you'll need to do the following when the guide requires you to run `build.sh`:

	$ CC=gcc-4.8 CXX=g++-4.8 ./build.sh


## <a name="installing-toolchain"></a>Installing the Toolchain

Let's start with the directory in which we will install our
tools. Find a nice, big expanse of hard drive space, and let's call that
`$TOP`. Change to the directory you want to install in, and then set 
the `$TOP` environment variable accordingly:

	$ export TOP=$(pwd)

For the sake of example, my `$TOP` directory is on
`s141.millennium`, at `/scratch/quannguyen/noob`, named so
because I believe even a newbie at the command prompt should be able to complete 
this tutorial. Here's to you, n00bs!

### Tour of the Sources

If we are starting from a relatively fresh install of
GNU/Linux, it will be necessary to install the RISC-V toolchain. The toolchain
consists of the following components:

*   `riscv-gcc`, a RISC-V cross-compiler
*   `riscv-fesvr`, a "front-end" server that
services calls between the host and target processors on the Host-Target
InterFace (HTIF) (it also provides a virtualized console and disk device)
*   `riscv-isa-sim`, the ISA simulator and
"golden standard" of execution
*   `riscv-opcodes`, the enumeration of all
RISC-V opcodes executable by the simulator
*   `riscv-pk`, a proxy kernel that services
system calls generated by code built and linked with the RISC-V Newlib port
(this does not apply to Linux, as _it_ handles the system calls)
*   `riscv-tests`, a set of assembly tests
and benchmarks

In the installation guide for Linux builds, we built only the
simulator and the front-end server. Binaries built against Newlib with
`riscv-gcc` will not have the luxury of being run on a full-blown
operating system, but they will still demand to have access to some crucial
system calls.

### What's Newlib?

[Newlib](http://www.sourceware.org/newlib/) is a
"C library intended for use on embedded systems." It has the advantage of not
having so much cruft as Glibc at the obvious cost of incomplete support (and
idiosyncratic behavior) in the fringes. The porting process is much less complex
than that of Glibc because you only have to fill in a few stubs of glue
code.

These stubs of code include the system calls that are
supposed to call into the operating system you're running on. Because there's no
operating system proper, the simulator runs, on top of it, a proxy kernel
(`riscv-pk`) to handle many system calls, like `open`,
`close`, and `printf`.

### Obtaining and Compiling the Sources (7.87 SBU)

First, clone the tools from the `riscv-tools` GitHub
repository:

	$ git clone https://github.com/ucb-bar/riscv-tools.git

This command will bring in only references to the
repositories that we will need. We rely on Git's submodule system to take care
of resolving the references. Enter the newly-created riscv-tools directory and
instruct Git to update its submodules. 

	$ cd $TOP/riscv-tools
	$ git submodule update --init --recursive

To build GCC, we will need several other packages, including
flex, bison, autotools, libmpc, libmpfr, and libgmp. Ubuntu distribution
installations will require this command to be run. If you have not installed
these things yet, then run this:

	O$ sudo apt-get install autoconf automake autotools-dev libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf

Before we start installation, we need to set the
`$RISCV` environment variable. The variable is used throughout the
build script process to identify where to install the new tools. (This value is
used as the argument to the `--prefix` configuration switch.)

	$ export RISCV=$TOP/riscv

If your `$PATH` variable does not contain the
directory specified by `$RISCV`, add it to the `$PATH`
environment variable now:

	$ export PATH=$PATH:$RISCV/bin

One more thing: If your machine doesn't have the capacity to
handle 16 make jobs (or conversely, it can handle more), edit
`build.common` to change the number specified by
`JOBS`.

	O$ sed -i 's/JOBS=16/JOBS=[number]/' build.common

With everything else set up, run the build script. Recall that if you're using a new-version of gcc that isn't the default on your system, you'll need to precede the `./build.sh` with `CC=gcc-4.8 CXX=g++-4.8`:

	$ ./build.sh


## <a name="testing-toolchain"></a> Testing Your Toolchain

Now that you have a toolchain, it'd be a good idea to test it
on the quintessential "Hello world!" program. Exit the `riscv-tools`
directory and write your "Hello world!" program. I'll use a long-winded
`echo` command.

	$ cd $TOP
	$ echo -e '#include <stdio.h>\n int main(void) { printf("Hello world!\\n"); return 0; }' > hello.c

Then, build your program with `riscv-gcc`.

	$ riscv-gcc -o hello hello.c

When you're done, you may think to do `./hello`,
but not so fast. We can't even run `spike hello`, because our "Hello
world!" program involves a system call, which couldn't be handled by our host
x86 system. We'll have to run the program within the
proxy kernel, which itself is run by `spike`, the RISC-V
architectural simulator. Run this command to run your "Hello world!"
program:

	$ spike pk hello

The RISC-V architectural simulator, `spike`, takes
as its argument the path of the binary to run. This binary is `pk`,
and is located at `$RISCV/riscv-elf/bin/pk`.
`spike` finds this automatically.
Then, `riscv-pk` receives as _its_
argument the name of the program you want to run.

Hopefully, if all's gone well, you'll have your program
saying, "Hello world!". If not...


## <a name="help-it-doesnt-work"></a>"Help! It doesn't work!"

I know, I've been there too. Good luck!