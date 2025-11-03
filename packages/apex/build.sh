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

# Apex is not versioned, so we are pinning a specific commit.
if [ "$PACKAGE_VERSION" == "0.1.0" ]; then
	tag="26bba57d62553d268319b4a20cc3d8aa990249ec"
else
	tag="${PACKAGE_VERSION}"
fi

# https://github.com/NVIDIA/apex?tab=readme-ov-file#from-source
export APEX_CPP_EXT=1
export APEX_CUDA_EXT=1
export APEX_PARALLEL_BUILD=8
export NVCC_APPEND_FLAGS="--threads 4"

pip wheel \
	-v \
	--no-deps \
	--no-build-isolation \
	--check-build-dependencies \
	--wheel-dir="${OUTPUT_DIR}" \
	"git+https://github.com/NVIDIA/apex.git@${tag}" \
	"$@"
