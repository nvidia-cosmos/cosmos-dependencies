#!/usr/bin/env -S bash -euxo pipefail

# https://github.com/dmlc/decord?tab=readme-ov-file#installation
apt-get update
apt-get install -y \
	build-essential \
	make \
	cmake \
	ffmpeg \
	libavcodec-dev \
	libavfilter-dev \
	libavformat-dev \
	libavutil-dev

cp packages/decord/Video_Codec_SDK_13.0.19/Lib/linux/stubs/aarch64/* /usr/local/cuda/lib64/
cp packages/decord/Video_Codec_SDK_13.0.19/Interface/* /usr/local/cuda/include

temp_dir="$(mktemp -d)"
cd "${temp_dir}"
git clone --depth 1 --branch "v${PACKAGE_VERSION}" --recursive https://github.com/dmlc/decord
cd decord
mkdir build
cd build
cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release
make -j "$(nproc)"
cp libdecord.so /usr/local/cuda/lib64/
