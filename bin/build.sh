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

# CUDA 12.8 requires gcc<=14: `/usr/local/cuda-12.8/targets/x86_64-linux/include/crt/host_config.h`

# Build a package.

if [[ $# -lt 5 ]]; then
	echo "Usage: $0 <package_name> <package_version> <python_version> <torch_version> <cuda_version>" >&2
	exit 1
fi
export PACKAGE_NAME="${1}"
shift
export PACKAGE_VERSION="${1}"
shift
export PYTHON_VERSION="${1}"
shift
export TORCH_VERSION="${1}"
shift
export CUDA_VERSION="${1}"
shift
BUILD_DIR="$(abspath "${1}")"
export BUILD_DIR="${BUILD_DIR}"
shift

if [[ ! "${PYTHON_VERSION}" =~ ^[0-9]+\.[0-9]+$ ]]; then
	echo "Error: Python version must be '<major>.<minor>'." >&2
	exit 1
fi
if [[ ! "${TORCH_VERSION}" =~ ^[0-9]+\.[0-9]+$ ]]; then
	echo "Error: Torch version must be '<major>.<minor>'" >&2
	exit 1
fi
if [[ ! "${CUDA_VERSION}" =~ ^[0-9]+\.[0-9]+$ ]]; then
	echo "Error: CUDA version must be '<major>.<minor>'" >&2
	exit 1
fi

name="${PACKAGE_NAME//-/_}-${PACKAGE_VERSION}-py${PYTHON_VERSION}-cu${CUDA_VERSION}-torch${TORCH_VERSION}"
export OUTPUT_DIR="${BUILD_DIR}/${name}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
log_file="${OUTPUT_DIR}/build.log"
echo "Logging to ${log_file}"

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
env -i \
	PACKAGE_NAME="${PACKAGE_NAME}" \
	PACKAGE_VERSION="${PACKAGE_VERSION}" \
	PYTHON_VERSION="${PYTHON_VERSION}" \
	TORCH_VERSION="${TORCH_VERSION}" \
	CUDA_VERSION="${CUDA_VERSION}" \
	OUTPUT_DIR="${OUTPUT_DIR}" \
	PATH="${PATH:-}" \
	HOME="${HOME:-}" \
	USER="${USER:-}" \
	XDG_CACHE_HOME="${XDG_CACHE_HOME}" \
	UV_CACHE_DIR="${UV_CACHE_DIR:-$XDG_CACHE_HOME/uv}" \
	PIP_CACHE_DIR="${PIP_CACHE_DIR:-$XDG_CACHE_HOME/pip}" \
	bash -euxo pipefail "bin/_build.sh" "$@" |& tee "${log_file}"
