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

ARG CUDA_VERSION="12.8.1"
ARG BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu22.04"
FROM ${BASE_IMAGE}

# Set the DEBIAN_FRONTEND environment variable to avoid interactive prompts during apt operations.
ENV DEBIAN_FRONTEND=noninteractive

# Update apt and install essential build dependencies in a single layer.
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        ccache \
        curl \
        software-properties-common \
        git-lfs \
        tree \
        wget

# Install ffmpeg 6
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    add-apt-repository ppa:ubuntuhandbook1/ffmpeg6 && \
    apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg

ENV PATH="/usr/lib/ccache:/usr/local/bin:$PATH"

# Install uv: https://docs.astral.sh/uv/getting-started/installation/
# https://github.com/astral-sh/uv-docker-example/blob/main/Dockerfile
COPY --from=ghcr.io/astral-sh/uv:0.9.28 /uv /uvx /usr/local/bin/

# Install just: https://just.systems/man/en/pre-built-binaries.html
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin --tag 1.46.0

# Set the working directory for the application.
WORKDIR /app

ENTRYPOINT ["/app/docker/entrypoint.sh"]
CMD ["/bin/bash"]
