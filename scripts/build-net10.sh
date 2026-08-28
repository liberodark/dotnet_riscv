#!/usr/bin/env bash
set -euo pipefail
cd /dotnet
./build.sh --clean-while-building --prep -sb --os ${TARGET_NAME} --rid ${TARGET_NAME}-riscv64 --arch riscv64
