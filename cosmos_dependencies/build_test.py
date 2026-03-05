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

from cosmos_dependencies.build import _format_build_env, _get_torch_cuda_arch_list, _parse_torch_cuda_arch


def test_parse_torch_cuda_arch():
    assert _parse_torch_cuda_arch("sm_80") == (8, 0)
    assert _parse_torch_cuda_arch("sm_86") == (8, 6)
    assert _parse_torch_cuda_arch("sm_120") == (12, 0)


def test_build_env():
    assert torch.__version__ == "2.10.0+cu128"
    assert _get_torch_cuda_arch_list() == [(8, 0), (8, 6), (9, 0), (10, 0), (12, 0)]
    assert _format_build_env() == [
        "export _GLIBCXX_USE_CXX11_ABI=1",
        "export TORCH_CUDA_ARCH_LIST='8.0;8.6;9.0;10.0;12.0'",
    ]
