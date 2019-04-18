#! /bin/bash
#
# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain.
# Tools will be installed to $RISCV.

. build.common

echo "Starting RISC-V Toolchain build process"

build_project riscv-fesvr --prefix=$RISCV
# build_project riscv-gnu-toolchain --prefix=$RISCV --with-arch=rv32ifv --disable-multilib
build_project riscv-gnu-toolchain --prefix=$RISCV \
    --with-arch=rv32ifv --with-abi=ilp32f \
    --target=riscv32-basilisk \
    --disable-multilib \
    --disable-gdb \
    --disable-sim \
    --disable-libdecnumber \
    --disable-libreadline

# CC= CXX= build_project riscv-pk --prefix=$RISCV --host=riscv32-unknown-elf
# build_project riscv-openocd --prefix=$RISCV --enable-remote-bitbang --disable-werror

echo -e "\\nRISC-V Toolchain installation completed!"
