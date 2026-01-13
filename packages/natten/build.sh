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

case "$PACKAGE_VERSION" in
0.21.5.dev9)
	PACKAGE_REVISION="51e7bc1b0209e78ab482d79aea940dbc1940b003"
	;;
*)
	PACKAGE_REVISION="v${PACKAGE_VERSION}"
	;;
esac

# https://natten.org/install/#build-natten-libnatten
export NATTEN_N_WORKERS=${NATTEN_N_WORKERS:-$(($(nproc) / 2))}
export NATTEN_VERBOSE=1
export NATTEN_CUDA_ARCH="${TORCH_CUDA_ARCH_LIST}"

pip wheel \
	-v \
	--no-deps \
	--no-build-isolation \
	--check-build-dependencies \
	--wheel-dir="${OUTPUT_DIR}" \
	"git+https://github.com/SHI-Labs/NATTEN.git@${PACKAGE_REVISION}" \
	"$@"
