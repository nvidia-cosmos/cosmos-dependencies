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

root_dir="$(pwd)"
package_dir="${root_dir}/packages/${PACKAGE_NAME}"

CUDA_NAME="${CUDA_VERSION//./}"
TORCH_NAME="${TORCH_VERSION//./}"

echo "Building ${PACKAGE_NAME}=${PACKAGE_VERSION} python=${PYTHON_VERSION} torch=${TORCH_VERSION} cuda=${CUDA_VERSION}" "$@"

# Print system information.
date
uname -a
cat /etc/os-release
ldd --version
gcc --version
printenv

# Set CUDA environment variables
export CUDA_HOME="/usr/local/cuda-${CUDA_VERSION}"
# Check if CUDA_HOME is valid.
if [ ! -d "${CUDA_HOME}/bin" ]; then
	echo "CUDA ${CUDA_VERSION} is not installed."
	exit 1
fi
export PATH="${CUDA_HOME}/bin:${PATH:-}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH:-}"
nvcc --version

# Install build dependencies
pushd "${package_dir}"
venv_dir="$(uv cache dir)/cosmos-dependencies/${OUTPUT_NAME}"
uv venv --python "${PYTHON_VERSION}" "${venv_dir}"
# shellcheck source=/dev/null
source "${venv_dir}/bin/activate"
uv sync --active
uv pip install "torch==${TORCH_VERSION}.*" --index-url "https://download.pytorch.org/whl/cu${CUDA_NAME}"

# Set build environment variables
eval "$(python -c "
from cosmos_dependencies.build import build_env
build_env()
")"

# Configure ccache
ccache --zero-stats
export CCACHE_NOHASHDIR="true"

# Build the package.
# shellcheck source=/dev/null
source "${package_dir}/build.sh" "$@"
deactivate
rm -rf "${venv_dir}"
popd || exit 1

ccache --show-stats

# Fix wheel filenames.
uv run bin/fix_wheel.py -i "${OUTPUT_DIR}"/*.whl --version="${PACKAGE_VERSION}" --local-version="cu${CUDA_NAME}.torch${TORCH_NAME}"
