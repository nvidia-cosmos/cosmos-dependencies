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

cd ../python
# python3 setup.py install

pip wheel \
	-v \
	--no-deps \
	--no-build-isolation \
	--check-build-dependencies \
	--wheel-dir="${OUTPUT_DIR}" \
	"." \
	"$@"
