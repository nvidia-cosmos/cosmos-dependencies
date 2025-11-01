# Cosmos Dependencies

Repository for building and publishing Cosmos dependencies.

Index URLs:

* [all](https://nvidia-cosmos.github.io/cosmos-dependencies/latest/simple)
* [cu126_torch29](https://nvidia-cosmos.github.io/cosmos-dependencies/latest/cu126_torch29/simple)
* [cu130_torch29](https://nvidia-cosmos.github.io/cosmos-dependencies/latest/cu126_torch29/simple)

## Setup

Install system dependencies:

[uv](https://docs.astral.sh/uv/getting-started/installation/)

```shell
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
curl -LsSf https://astral.sh/uv/install.sh | sh
source $XDG_BIN_HOME/env
```

[just](https://github.com/casey/just?tab=readme-ov-file#installation)

```shell
pushd "$XDG_BIN_HOME" && curl https://zyedidia.github.io/eget.sh | sh && popd
eget casey/just --to="$XDG_BIN_HOME"
```

If uploading wheels, [gh](https://github.com/cli/cli?tab=readme-ov-file#installation):

```shell
eget cli/cli --asset=.tar.gz --to="$XDG_BIN_HOME"
gh auth login
```

## Build Wheels

Run the docker container:

```shell
just docker-<cuda_version>
```

Optionally, test the environment:

```shell
just build-dummy <cuda_version>
```

Build a single package:

```shell
just build <package_name> <package_version> <python_version> <torch_version> <cuda_version>
```

Example:

```shell
just docker-cu128
just build-dummy 12.8
just build natten 0.21.0 3.12 2.7 12.8
```

## Upload Wheels

1. Upload wheels

```shell
just upload <wheel_path>
```

1. Create and locally host the package index

```shell
just index-serve
```

1. Open a PR and merge to [cosmos-dependencies](https://github.com/nvidia-cosmos/cosmos-dependencies).

## Bump Version

```shell
gh release download --repo nvidia-cosmos/cosmos-dependencies v$(uv version --short) -D tmp/assets --pattern '*'
uv version --bump minor
gh release upload --repo nvidia-cosmos/cosmos-dependencies v$(uv version --short) tmp/assets/*
```

## Version Constraints

* cuda
  * [torch](https://pytorch.org/get-started/previous-versions/)
* gcc
  * [cuda](/usr/local/cuda/targets/x86_64-linux/include/crt/host_config.h)
* flash-attn
  * [transformer-engine `FlashAttentionUtils.max_version`](https://github.com/NVIDIA/TransformerEngine/blob/main/transformer_engine/pytorch/attention/dot_product_attention/utils.py)

## Contributing

We thrive on community collaboration! [NVIDIA-Cosmos](https://github.com/nvidia-cosmos/) wouldn't be where it is without contributions from developers like you. Check out our [Contributing Guide](CONTRIBUTING.md) to get started, and share your feedback through issues.

Big thanks 🙏 to everyone helping us push the boundaries of open-source physical AI!

## License

This repository is licensed under the [Apache License 2.0](LICENSE).
