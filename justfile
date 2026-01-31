default:
  just --list

# Install pre-commit
_pre-commit-install *args:
  uv tool install "pre-commit>=4.3.0"
  pre-commit install -c .pre-commit-config-base.yaml {{args}}

# Setup the repository
setup: _pre-commit-install

# Run pre-commit
_pre-commit *args: setup
  pre-commit run -a {{args}} || pre-commit run -a {{args}}

# Run linting and formatting
lint: _pre-commit

# Build a package.
build package_name package_version python_version torch_version build_dir='build' *args:
  ./bin/build.sh {{package_name}} {{package_version}} {{python_version}} {{torch_version}} {{build_dir}} {{args}}

# Build a dummy package.
build-dummy: (build 'cosmos-dummy' '0.1.0' '3.12' '2.9' 'tmp/build')

# Run the docker container.
_docker cuda_version build_args='' run_args='':
  #!/usr/bin/env bash
  set -euxo pipefail
  build_args="--build-arg=CUDA_VERSION={{cuda_version}} {{build_args}}"
  docker build $build_args .
  image_tag=$(docker build $build_args -q .)
  # Mount cache directories to avoid re-downloading dependencies.
  # Some packages use `torch.cuda.is_available()` which requires a GPU.
  docker run \
    -it \
    --rm \
    --gpus 1 \
    -v .:/app \
    -v /app/.venv \
    -v /root/.cache:/root/.cache \
    -v /root/.ccache:/root/.ccache \
    {{run_args}} $image_tag

# Run the CUDA 12.6 docker container.
docker-cu126 *args: (_docker '12.6.3' args)

# Run the CUDA 12.8 docker container.
docker-cu128 *args: (_docker '12.8.1' args)

# Run the CUDA 12.9 docker container.
docker-cu129 *args: (_docker '12.9.1' args)

# Run the CUDA 13.0 docker container.
docker-cu130 *args: (_docker '13.0.2' args)

# Fix file permissions.
fix-permissions:
  sudo chown -R $(id -u):$(id -g) .

upload pattern *args:
  #!/usr/bin/env bash
  set -euxo pipefail
  for file in {{pattern}}; do
    gh release upload --repo nvidia-cosmos/cosmos-dependencies v$(uv version --short) $file {{args}}
    rm -rfv $file
  done

version := `uv version --short`
tag := 'v' + version
index_dir := 'docs/' + tag

# Create the package index
_index-create *args:
  uv run bin/create_index.py -i assets -o {{index_dir}} --tag={{tag}} {{args}}

# Create the package index
index-create *args: license (_index-create args)

# Serve the package index
_index-serve *args:
  uv run -m http.server -d {{index_dir}} {{args}}

# Locally serve the package index
index-serve *args: index-create _index-serve

# Test the package index
_index-test: (index-create '-o' 'tmp/' + index_dir)

_pytest *args:
  uv run pytest {{args}}

# Run tests
test: lint _pytest _index-test

# https://spdx.org/licenses/
allow_licenses := "MIT BSD-2-CLAUSE BSD-3-CLAUSE APACHE-2.0 ISC"
ignore_package_licenses := "nvidia-*"

# Run licensecheck
_licensecheck *args:
  uv run --all-groups licensecheck --show-only-failing --only-licenses {{allow_licenses}} --ignore-packages {{ignore_package_licenses}} --zero {{args}}

# Run pip-licenses
_pip-licenses *args:
  uv run --all-groups pip-licenses --python .venv/bin/python --format=plain-vertical --with-license-file --no-license-path --no-version --with-urls --output-file ATTRIBUTIONS.md {{args}}
  pre-commit run --files ATTRIBUTIONS.md || true

# Check licenses
license: _licensecheck _pip-licenses
