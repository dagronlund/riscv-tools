#! /bin/bash
#
# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain.
# Tools will be installed to $RISCV.

. build.common

echo "Starting RISC-V Toolchain build process"

build_project riscv-fesvr --prefix=$RISCV
build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV --with-isa=RV32IM
build_project riscv-gnu-toolchain --prefix=$RISCV --with-arch=RV32IMA

echo -e "\\nRISC-V Toolchain installation completed!"