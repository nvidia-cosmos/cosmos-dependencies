#!/usr/bin/env -S bash -euxo pipefail

# https://github.com/dmlc/decord?tab=readme-ov-file#installation
apt-get update
apt-get install -y \
	build-essential \
	python3-dev \
	python3-setuptools \
	make \
	cmake \
	ffmpeg \
	libavcodec-dev \
	libavfilter-dev \
	libavformat-dev \
	libavutil-dev

git clone --depth 1 --branch "v${PACKAGE_VERSION}" --recursive https://github.com/dmlc/decord
cd decord

mkdir build
cd build
unzip ../../Video_Codec_SDK_13.0.19.zip -d .
cp Video_Codec_SDK_13.0.19/Lib/linux/stubs/aarch64/* /usr/local/cuda/lib64/
cp Video_Codec_SDK_13.0.19/Interface/* /usr/local/cuda/include
cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release
make -j "$(nproc)"
cp libdecord.so /usr/local/cuda/lib64/
