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

# https://github.com/Dao-AILab/flash-attention?tab=readme-ov-file#installation-and-features
export MAX_JOBS=${MAX_JOBS:-$(($(nproc) / 4))}

# https://github.com/Dao-AILab/flash-attention/blob/main/setup.py
export FLASH_ATTENTION_FORCE_BUILD=TRUE
export FLASH_ATTN_CUDA_ARCHS="${TORCH_CUDA_ARCH_LIST}"

pip wheel \
	-v \
	--no-deps \
	--no-build-isolation \
	--check-build-dependencies \
	--wheel-dir="${OUTPUT_DIR}" \
	"git+https://github.com/Dao-AILab/flash-attention.git@v${PACKAGE_VERSION}" \
	"$@"
