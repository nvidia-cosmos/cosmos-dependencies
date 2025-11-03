from cosmos_dependencies.build import _parse_torch_cuda_arch, build_env

def test_parse_torch_cuda_arch():
    assert _parse_torch_cuda_arch('sm_80') == (8, 0)
    assert _parse_torch_cuda_arch('sm_86') == (8, 6)
    assert _parse_torch_cuda_arch('sm_120') == (12, 0)

def test_print_build_env():
    build_env()
