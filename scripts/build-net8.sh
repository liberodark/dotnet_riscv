#!/usr/bin/env bash
set -euo pipefail
cd /dotnet
./prep.sh
BV="$(ls -d /dotnet/.dotnet/sdk/*/Microsoft.NETCoreSdk.BundledVersions.props | head -1)"
sed -i 's|linux-x64;|linux-x64;linux-riscv64;linux-musl-riscv64;|g; s|linux-x64"|linux-x64;linux-riscv64;linux-musl-riscv64"|g' "$BV"
grep -q "linux-riscv64" "$BV"
export DISABLE_CROSSGEN=true
export CrossBuild=true
export TargetArchitecture=riscv64
export TargetRid=${TARGET_NAME}-riscv64
sed -i "s|<TargetRid Condition=\"'\$(TargetRid)' == ''\">\$(__DistroRid)</TargetRid>|<TargetRid Condition=\"'\$(TargetRid)' == ''\">${TARGET_NAME}-riscv64</TargetRid>|" \
  Directory.Build.props
grep -q "riscv64</TargetRid>" Directory.Build.props
sed -i "s|<PublishReadyToRun Condition=\"'\$(NativeAotSupported)' != 'true'\">true</PublishReadyToRun>|<PublishReadyToRun Condition=\"'\$(NativeAotSupported)' != 'true' and '\$(TargetArchitecture)' != 'riscv64'\">true</PublishReadyToRun>|" \
  src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
grep -q "riscv64" src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
sed -i "s|<PublishReadyToRun Condition=\"'\$(TargetOS)' == 'freebsd' and '\$(CrossBuild)' == 'true'\">false</PublishReadyToRun>|&\n    <PublishReadyToRun Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</PublishReadyToRun>\n    <PublishSingleFile Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</PublishSingleFile>|" \
  src/runtime/src/coreclr/tools/aot/crossgen2/crossgen2_publish.csproj
grep -q "TargetArchitecture)' == 'riscv64'" src/runtime/src/coreclr/tools/aot/crossgen2/crossgen2_publish.csproj
sed -i "s|<PublishSingleFile Condition=\"'\$(NativeAotSupported)' != 'true'\">true</PublishSingleFile>|&\n    <PublishSingleFile Condition=\"'\$(TargetArchitecture)' == 'riscv64'\">false</PublishSingleFile>|" \
  src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
grep -q "PublishSingleFile Condition=\"'\$(TargetArchitecture)' == 'riscv64'" src/runtime/src/coreclr/tools/aot/ILCompiler/ILCompiler.csproj
sed -i "s|linux-bionic-x86\"|linux-bionic-x86;linux-riscv64;linux-musl-riscv64\"|" \
  src/runtime/eng/targetingpacks.targets
grep -q "linux-riscv64" src/runtime/eng/targetingpacks.targets
sed -i "s|<CrossgenOutput Condition=\" '\$(CrossgenOutput)' == '' AND '\$(Configuration)' != 'Debug' \">true</CrossgenOutput>|<CrossgenOutput Condition=\" '\$(CrossgenOutput)' == '' AND '\$(Configuration)' != 'Debug' \">false</CrossgenOutput>|" \
  src/aspnetcore/src/Framework/App.Runtime/src/Microsoft.AspNetCore.App.Runtime.csproj
grep -q ">false</CrossgenOutput>" src/aspnetcore/src/Framework/App.Runtime/src/Microsoft.AspNetCore.App.Runtime.csproj
sed -i "s|Condition=\"\$(HostRid.StartsWith('mariner.2.0'))\">|Condition=\"\$(CoreSetupRid.StartsWith('mariner.2.0'))\">|; s|Condition=\"\$(HostRid.StartsWith('azurelinux.3.0'))\">|Condition=\"\$(CoreSetupRid.StartsWith('azurelinux.3.0'))\">|" \
  src/installer/src/redist/targets/GenerateLayout.targets
grep -q "CoreSetupRid.StartsWith('azurelinux" src/installer/src/redist/targets/GenerateLayout.targets
sed -i "s|AND '\$(TargetRid)' != '\$(PortableRid)'\">|AND '\$(TargetRid)' != '\$(PortableRid)' AND '\$(TargetRid)' != 'linux-riscv64' AND '\$(TargetRid)' != 'linux-musl-riscv64'\">|" \
  src/sdk/src/Layout/redist/targets/GenerateLayout.targets
grep -q "linux-riscv64" src/sdk/src/Layout/redist/targets/GenerateLayout.targets
./build.sh --clean-while-building -- \
  /p:TargetRid=${TARGET_NAME}-riscv64 /p:TargetOS=linux /p:TargetArchitecture=riscv64 /p:CrossBuild=true
