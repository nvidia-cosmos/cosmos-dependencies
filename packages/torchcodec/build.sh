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

PACKAGE_REVISION="v${PACKAGE_VERSION}"

# Install system dependencies
apt-get update && apt-get install -y --no-install-recommends \
	libavdevice-dev \
	libavfilter-dev \
	libavformat-dev \
	libavcodec-dev \
	libavutil-dev \
	libswresample-dev \
	libswscale-dev \
	pkg-config \
	python3-dev

# Set pybind11 cmake directory (required - CMake can't find it otherwise)
pybind11_DIR=$(python -c "import pybind11; print(pybind11.get_cmake_dir())")
export pybind11_DIR
export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1
export ENABLE_CUDA=1

pip wheel \
	-v \
	--no-deps \
	--no-build-isolation \
	--check-build-dependencies \
	--wheel-dir="${OUTPUT_DIR}" \
	"git+https://github.com/meta-pytorch/torchcodec.git@${PACKAGE_REVISION}" \
	"$@"
