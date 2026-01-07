#!/usr/bin/env -S bash -euxo pipefail
# SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# https://github.com/dmlc/decord?tab=readme-ov-file#installation
apt-get update
apt-get install -y --no-install-recommends \
	build-essential \
	make \
	cmake \
	ffmpeg \
	libavcodec-dev \
	libavfilter-dev \
	libavformat-dev \
	libavutil-dev

cp "Video_Codec_SDK_13.0.19/Lib/linux/stubs/$(uname -m)/"* /usr/local/cuda/lib64/
cp Video_Codec_SDK_13.0.19/Interface/* /usr/local/cuda/include

temp_dir="$(mktemp -d)"
cd "${temp_dir}"
git clone --depth 1 --branch "v${PACKAGE_VERSION}" --recursive https://github.com/dmlc/decord
cd decord

# Fix to work with ffmpeg 6.0
find . -type f -exec sed -i "s/AVInputFormat \*/const AVInputFormat \*/g" {} \;
sed -i "s/[[:space:]]AVCodec \*dec/const AVCodec \*dec/" src/video/video_reader.cc
sed -i "s/avcodec\.h>/avcodec\.h>\n#include <libavcodec\/bsf\.h>/" src/video/ffmpeg/ffmpeg_common.h

mkdir build
cd build
cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release
make -j "$(nproc)"
make install
