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

"""Fix wheel filename."""

from dataclasses import dataclass
from pathlib import Path
from typing import Annotated

import tyro
from change_wheel_version import change_wheel_version
from wheel_filename import parse_wheel_filename


@dataclass
class Args:
    input_paths: Annotated[list[Path], tyro.conf.arg(aliases=("-i",))]
    """Input wheel path."""

    cuda: int
    """CUDA version (e.g. 128)."""
    torch: int
    """Torch version (e.g. 27)."""


def main(args: Args):
    for input_path in args.input_paths:
        pwf = parse_wheel_filename(input_path.name)
        version = pwf.version.split("+")[0]
        output_path = change_wheel_version(
            wheel=input_path,
            version=version,
            local_version=f"cu{args.cuda}.torch{args.torch}",
            allow_same_version=True,
        )
        if output_path == input_path:
            print(f"Wheel filename is already correct: '{input_path}'")
            continue
        input_path.unlink()
        print(f"Renamed wheel: '{input_path}' -> '{output_path}'")


if __name__ == "__main__":
    args = tyro.cli(Args, description=__doc__)
    main(args)
