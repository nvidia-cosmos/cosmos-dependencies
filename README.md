> [!IMPORTANT]
> ## 🚀 [Cosmos 3 Has Arrived](https://github.com/nvidia/cosmos)
>
> Cosmos 3 is NVIDIA's next-generation foundation model platform for Physical AI. Compared with Cosmos Dependencies, Cosmos 3 provides the latest home for models, technical reports, tutorials, benchmarks, and ecosystem updates.
>
> Rather than relying on separate models for reasoning, prediction, transfer, and policy learning, a single Cosmos 3 model can understand the world, reason about physical interactions, predict future outcomes, transform observations across domains, and generate actions for embodied agents. This unified architecture enables stronger performance across a broad range of Physical AI applications, including robotics, autonomous vehicles, and smart spaces.
>
> This repository is no longer under active development and will receive only limited maintenance updates. Future model releases, features, documentation, and community support will be focused on Cosmos 3.
>
> 👉 Visit the new Cosmos home: https://github.com/nvidia/cosmos
>
> There you will find the latest Cosmos 3 models, technical reports, tutorials, benchmarks, and ecosystem updates.
>
> Thank you for your support of Cosmos Dependencies. We encourage all users to migrate to Cosmos 3 for the latest state-of-the-art Physical AI capabilities.

# Cosmos Dependencies

Repository for building and publishing Cosmos dependencies.

[Index](https://nvidia-cosmos.github.io/cosmos-dependencies/v1.5.0)

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
just build-dummy
```

Build a single package:

```shell
just build <package_name> <package_version> <python_version> <torch_version>
```

Example:

```shell
just docker-cu128
just build-dummy
just build natten 0.21.1 3.12 2.9
```

On the host, fix file permissions:

```shell
just fix-permissions
```

## Upload Wheels

1. Upload wheels

```shell
just upload "build/**/*.whl"
```

1. Create and locally host the package index

```shell
just index-serve
```

1. Open a PR and merge to [cosmos-dependencies](https://github.com/nvidia-cosmos/cosmos-dependencies).

## Bump Version

```shell
uv version --bump=minor
gh release create --repo nvidia-cosmos/cosmos-dependencies v$(uv version --short)
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
