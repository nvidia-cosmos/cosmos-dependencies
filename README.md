# Cosmos Dependencies

Repository for building and publishing Cosmos dependencies.

Index URLs:

* [all](https://nvidia-cosmos.github.io/cosmos-dependencies/v1.2.0/simple)
* [cu128_torch27](https://nvidia-cosmos.github.io/cosmos-dependencies/v1.2.0/cu128_torch27/simple)

## Setup

Install system dependencies:

[uv](https://docs.astral.sh/uv/getting-started/installation/)

```shell
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
```

[just](https://github.com/casey/just?tab=readme-ov-file#installation)

```shell
uv tool install -U rust-just
```

[gh](https://github.com/cli/cli?tab=readme-ov-file#installation):

```shell
curl -L 'https://github.com/cli/cli/releases/download/v2.82.1/gh_2.82.1_linux_amd64.tar.gz' | tar xz -C "$HOME/.local"
gh auth login
```

## Build Wheels

Run the docker container:

```shell
just docker-<cuda_version>

# Example
just docker-cu128
```

Build a single package:

```shell
just build <package_name> <package_version> <python_version> <torch_version> <cuda_version>

# Example
just build natten 0.21.0 3.12 2.7 12.8
```

## Upload Wheels

1. Upload wheels

```shell
just upload
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

## Contributing

We thrive on community collaboration! [NVIDIA-Cosmos](https://github.com/nvidia-cosmos/) wouldn't be where it is without contributions from developers like you. Check out our [Contributing Guide](CONTRIBUTING.md) to get started, and share your feedback through issues.

Big thanks 🙏 to everyone helping us push the boundaries of open-source physical AI!

## License

This repository is licensed under the [Apache License 2.0](LICENSE).
