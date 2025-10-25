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

"""Generate PEP 503 compliant index.

Reference: https://peps.python.org/pep-0503/
"""

import collections
import json
import shutil
import subprocess
import urllib.parse
import warnings
from dataclasses import dataclass
from pathlib import Path
from typing import Annotated

import parse
import tyro
from wheel_filename import parse_wheel_filename

_HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<body>
{body}
</body>
</html>
"""


@dataclass
class _WheelInfo:
    filename: str
    url: str


def _get_index_line(package_name: str) -> str:
    return f"<a href='{package_name}/'>{package_name}</a><br>"


def _write_html(html_path: Path, lines: list[str]) -> None:
    index_html = _HTML_TEMPLATE.format(body="\n".join(lines))
    html_path.parent.mkdir(exist_ok=True, parents=True)
    html_path.write_text(index_html)


@dataclass
class Args:
    input_dir: Annotated[Path, tyro.conf.arg(aliases=("-i",))]
    """Input directory."""
    output_dir: Annotated[Path, tyro.conf.arg(aliases=("-o",))]
    """Output directory."""
    tag: str
    """Release tag."""

    repo: str = "nvidia-cosmos/cosmos-dependencies"
    """GitHub repository."""


def main(args: Args):
    shutil.rmtree(args.output_dir, ignore_errors=True)

    # Get the assets from the release
    cmd = [
        "gh",
        "release",
        "view",
        "--repo",
        args.repo,
        f"{args.tag}",
        "--json",
        "assets",
    ]
    assets = json.loads(subprocess.check_output(cmd, text=True))["assets"]

    # Group wheels by cuda/torch version and package
    all_wheels: dict[str, dict[str, list[_WheelInfo]]] = collections.defaultdict(lambda: collections.defaultdict(list))
    
    # Get wheels from release assets
    version_pattern = parse.compile("{version}+cu{cuda_version:d}.torch{torch_version:d}", case_sensitive=True)
    for asset in assets:
        filename: str = asset["name"]
        if not filename.endswith(".whl"):
            continue

        url: str = asset["url"]
        pwf = parse_wheel_filename(filename)
        package_name = pwf.project.replace("_", "-")

        # Parse cuda/torch version
        match = version_pattern.parse(pwf.version)
        if match is None:
            warnings.warn(f"Skipping invalid wheel filename: {filename}")
            continue
        index_name = f"cu{match['cuda_version']}_torch{match['torch_version']}"

        all_wheels[index_name][package_name].append(_WheelInfo(filename=filename, url=url))

    # Parse urls.txt files
    urls_files = args.input_dir.glob("*/urls.txt")
    assert urls_files
    for urls_file in urls_files:
        index_name = urls_file.parent.name
        urls = urls_file.read_text().splitlines()
        assert urls
        for url in urls:
            url = url.strip()
            if not url or url.startswith("#"):
                # Skip comments and empty lines
                continue
            url_parts = urllib.parse.urlparse(url)
            filename = urllib.parse.unquote(url_parts.path.rsplit("/", 1)[-1])
            pwf = parse_wheel_filename(filename)
            package_name = pwf.project.replace("_", "-")
            all_wheels[index_name][package_name].append(_WheelInfo(filename=filename, url=url))

    all_lines: dict[str, list[str]] = collections.defaultdict(list)

    # Create cuda/torch specific indices
    for index_name, index_wheels in all_wheels.items():
        index_lines = []

        # Create package indices
        for package_name, package_wheels in index_wheels.items():
            if package_name == "cosmos-dummy":
                continue
            index_lines.append(_get_index_line(package_name))

            package_lines = []
            for whl_info in package_wheels:
                package_lines.append(f"<a href='{whl_info.url}'>{whl_info.filename}</a><br>")
            all_lines[package_name].extend(package_lines)
            _write_html(
                args.output_dir / index_name / "simple" / package_name / "index.html",
                package_lines,
            )

        _write_html(
            args.output_dir / index_name / "simple/index.html",
            index_lines,
        )

    # Create global index
    _write_html(
        args.output_dir / "simple/index.html",
        [_get_index_line(package_name) for package_name in all_lines],
    )
    for package_name, package_lines in all_lines.items():
        _write_html(
            args.output_dir / "simple" / package_name / "index.html",
            package_lines,
        )


if __name__ == "__main__":
    args = tyro.cli(Args, description=__doc__)
    main(args)
