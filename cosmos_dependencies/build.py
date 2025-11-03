import torch

def _parse_torch_cuda_arch(name: str) -> tuple[int, int]:
    """Parse CUDA architecture from a string of the form sm_<major><minor>."""
    name = name.removeprefix('sm_')
    major = int(name[:-1])
    minor = int(name[-1])
    return major, minor

def _get_torch_cuda_arch_list() -> list[tuple[int, int]]:
    """Get the list of CUDA architectures supported by PyTorch."""
    arch_list = torch.cuda.get_arch_list()
    return [_parse_torch_cuda_arch(x) for x in arch_list if x.startswith('sm_')]

def build_env() -> None:
    """Print the build environment variables."""
    _GLIBCXX_USE_CXX11_ABI = 1 if torch.compiled_with_cxx11_abi() else 0
    print(f"export _GLIBCXX_USE_CXX11_ABI={_GLIBCXX_USE_CXX11_ABI}")
    TORCH_CUDA_ARCH_LIST = ';'.join([f'{major}.{minor}' for major, minor in _get_torch_cuda_arch_list()])
    print(f"export TORCH_CUDA_ARCH_LIST='{TORCH_CUDA_ARCH_LIST}'")
