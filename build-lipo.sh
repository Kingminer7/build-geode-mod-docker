#!/usr/bin/env bash
set -euo pipefail

# Builds statically linked LLVM lipo from source, for use in the merge workflow

cat > /tmp/build-lipo.sh<< EOF

apt-get update
apt-get install -y git build-essential cmake llvm ninja-build

git clone --depth 1 --branch llvmorg-23.1.6 https://github.com/llvm/llvm-project.git
cd llvm-project/llvm

cmake -B build -G Ninja \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_TARGETS_TO_BUILD="" \
    -DLLVM_ENABLE_PROJECTS="" \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_EXE_LINKER_FLAGS="-static"

cmake --build build --target llvm-lipo
cp build/bin/llvm-lipo /tmp/llvm-lipo

EOF

docker run --rm -v /tmp:/tmp ubuntu:latest /bin/bash /tmp/build-lipo.sh

rm /tmp/build-lipo.sh
echo "LLVM lipo built and copied to /tmp/llvm-lipo"
