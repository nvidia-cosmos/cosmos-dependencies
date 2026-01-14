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

# https://github.com/NVIDIA/TransformerEngine?tab=readme-ov-file#pip-installation
export NVTE_FRAMEWORK=pytorch
NVTE_CUDA_ARCHS=$(tr -d . <<<"${TORCH_CUDA_ARCH_LIST:-90}")
export NVTE_CUDA_ARCHS

apt-get update && apt-get install -y --no-install-recommends python3-dev

# Create missing PyTorch header file for CUDA extension builds
TORCH_INCLUDE=$(python -c "import torch; print(torch.__path__[0])")/include
if [[ ! -f "${TORCH_INCLUDE}/c10/cuda/impl/cuda_cmake_macros.h" ]]; then
	mkdir -p "${TORCH_INCLUDE}/c10/cuda/impl"
	cat >"${TORCH_INCLUDE}/c10/cuda/impl/cuda_cmake_macros.h" <<'HEADER'
#pragma once
#define C10_CUDA_BUILD_SHARED_LIBS
HEADER
fi

pip wheel \
	-v \
	--no-deps \
	--no-build-isolation \
	--check-build-dependencies \
	--wheel-dir="${OUTPUT_DIR}" \
	"git+https://github.com/NVIDIA/TransformerEngine.git@v${PACKAGE_VERSION}" \
	"$@"
