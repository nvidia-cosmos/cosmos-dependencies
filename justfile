default:
  just --list

# Setup the repository
setup:
  uv tool install -U pre-commit
  pre-commit install -c .pre-commit-config-base.yaml

# Run linting and formatting
lint: setup
  pre-commit run --all-files || pre-commit run --all-files

# Build a package.
build package_name package_version python_version torch_version cuda_version *args:
  ./bin/build.sh {{package_name}} {{package_version}} {{python_version}} {{torch_version}} {{cuda_version}} {{args}}

# Build a dummy package.
build-dummy:
  ./bin/build.sh cosmos-dummy 0.1.0 3.10 2.7 12.8

# Run the docker container.
_docker base_image build_args='' run_args='':
  #!/usr/bin/env bash
  set -euxo pipefail
  docker build --build-arg BASE_IMAGE={{base_image}} {{build_args}} .
  image_tag=$(docker build --build-arg BASE_IMAGE={{base_image}} {{build_args}} . -q)
  docker run --rm -v .:/app -v /app/.venv -v /root/.cache/uv:/root/.cache/uv -it {{run_args}} $image_tag

# Run the CUDA 12.6 docker container.
docker-cu126:
  just -f "{{source_file()}}" _docker nvidia/cuda:12.6.3-cudnn-devel-ubuntu20.04

# Run the CUDA 12.8 docker container.
docker-cu128:
  just -f "{{source_file()}}" _docker nvidia/cuda:12.8.1-cudnn-devel-ubuntu20.04

# Run the CUDA 13.0 docker container.
docker-cu130:
  just -f "{{source_file()}}" _docker nvidia/cuda:13.0.1-cudnn-devel-ubuntu22.04

version := `uv version --short`
tag := 'v' + version
index_dir := 'docs/' + tag

# Create the package index
index-create:
  uv run bin/create_index.py -o {{index_dir}} --tag={{tag}}

# Locally serve the package index
index-serve: index-create
  uv run -m http.server -d {{index_dir}}

test: lint
  uv run bin/create_index.py -o tmp/{{index_dir}} --tag={{tag}}

# https://spdx.org/licenses/
allow_licenses := "MIT BSD-2-CLAUSE BSD-3-CLAUSE APACHE-2.0 ISC"
ignore_package_licenses := "nvidia-*"

# Check licenses
license:
  uv run --all-groups licensecheck --show-only-failing --only-licenses {{allow_licenses}} --ignore-packages {{ignore_package_licenses}} --zero
  uv run --all-groups pip-licenses --python .venv/bin/python --format=plain-vertical --with-license-file --no-license-path --no-version --with-urls --output-file ATTRIBUTIONS.md
  pre-commit run --files ATTRIBUTIONS.md || true
