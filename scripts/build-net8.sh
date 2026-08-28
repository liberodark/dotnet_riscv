#!/usr/bin/env bash
set -euo pipefail
cd /dotnet
./prep.sh
export DISABLE_CROSSGEN=true
export PublishReadyToRun=false
export CrossBuild=true
sed -i "s|<PublishReadyToRun Condition=\"'\$(NativeAotSupported)' != 'true'\">true</PublishReadyToRun>|<PublishReadyToRun Condition=\"'\$(NativeAotSupported)' != 'true' and '\$(TargetArchitecture)' != 'riscv64'\">true</PublishReadyToRun>|" \
  src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
grep -q "riscv64" src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
sed -i "s|<PublishReadyToRun Condition=\"'\$(TargetOS)' == 'freebsd' and '\$(CrossBuild)' == 'true'\">false</PublishReadyToRun>|&\n    <PublishReadyToRun Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</PublishReadyToRun>\n    <PublishSingleFile Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</PublishSingleFile>\n    <UseAppHost Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</UseAppHost>|" \
  src/runtime/src/coreclr/tools/aot/crossgen2/crossgen2_publish.csproj
grep -q "TargetArchitecture)' == 'riscv64'" src/runtime/src/coreclr/tools/aot/crossgen2/crossgen2_publish.csproj
sed -i "s|<PublishSingleFile Condition=\"'\$(NativeAotSupported)' != 'true'\">true</PublishSingleFile>|&\n    <PublishSingleFile Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</PublishSingleFile>\n    <UseAppHost Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</UseAppHost>|" \
  src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
grep -q "PublishSingleFile Condition=\"'\$(TargetArchitecture)' == 'riscv64'" src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
./build.sh --clean-while-building -- \
  /p:TargetRid=${TARGET_NAME}-riscv64 /p:TargetOS=linux /p:TargetArchitecture=riscv64 /p:CrossBuild=true
