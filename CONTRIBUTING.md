# Contributing

## Code

Run linting/formatting:

```shell
just lint
```

Run testing:

```shell
just test
```

Check licenses:

```shell
just license
```

## Wheels

Unfortunately, we cannot accept externally built wheels. You are welcome to fork the repository and host your own package index if desired.

To copy over existing wheels:

```shell
gh release download --repo nvidia-cosmos/cosmos-dependencies v$(uv version --short) -D tmp/assets --pattern '*'
gh release upload --repo <username>/cosmos-dependencies v$(uv version --short) tmp/assets/*
```
