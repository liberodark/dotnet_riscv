#!/usr/bin/env bash
set -euo pipefail
cd /dotnet
./prep-source-build.sh
export DISABLE_CROSSGEN=true
for f in src/sdk/src/Installer/redist-installer/redist-installer.csproj src/sdk/src/Layout/redist/redist.csproj; do
  if [ -f "$f" ] && grep -q "BundleNativeAotCompiler" "$f"; then
    sed -i "s|'\$(DotNetBuildOrchestrator)' == 'true'\">true</BundleNativeAotCompiler>|'\$(DotNetBuildOrchestrator)' == 'true' and '\$(Architecture)' != 'riscv64'\">true</BundleNativeAotCompiler>|" "$f"
    grep -q "riscv64" "$f"
  fi
done
./build.sh --clean-while-building -sb --rid ${TARGET_NAME}-riscv64 \
  /p:TargetOS=linux /p:TargetArchitecture=riscv64 /p:CrossBuild=true
