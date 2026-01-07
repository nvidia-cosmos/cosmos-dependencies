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

import torch


def _parse_torch_cuda_arch(name: str) -> tuple[int, int]:
    """Parse CUDA architecture from a string of the form sm_<major><minor>."""
    name = name.removeprefix("sm_")
    major = int(name[:-1])
    minor = int(name[-1])
    return major, minor


def _get_torch_cuda_arch_list() -> list[tuple[int, int]]:
    """Get the list of CUDA architectures supported by PyTorch."""
    arch_list = []
    for arch in torch.cuda.get_arch_list():
        if not arch.startswith("sm_"):
            continue
        major, minor = _parse_torch_cuda_arch(arch)
        if major < 8:
            # Only support Ampere and later.
            continue
        arch_list.append((major, minor))
    return arch_list


def build_env() -> None:
    """Print the build environment variables."""
    _GLIBCXX_USE_CXX11_ABI = 1 if torch.compiled_with_cxx11_abi() else 0
    print(f"export _GLIBCXX_USE_CXX11_ABI={_GLIBCXX_USE_CXX11_ABI}")
    TORCH_CUDA_ARCH_LIST = ";".join([f"{major}.{minor}" for major, minor in _get_torch_cuda_arch_list()])
    print(f"export TORCH_CUDA_ARCH_LIST='{TORCH_CUDA_ARCH_LIST}'")
