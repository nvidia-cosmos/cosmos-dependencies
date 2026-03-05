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
from dataclasses import dataclass
from pathlib import Path
from typing import Annotated

import tyro
from wheel_filename import WheelFilename

_TORCH_BASE_URL = "https://download.pytorch.org"
_TORCH_PACKAGES = [
    "torch",
    "torchvision",
    "triton",
    "xformers",
]

_HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<body>
{body}
</body>
</html>
"""


@dataclass(frozen=True, order=True)
class _IndexLine:
    """Index line."""

    name: str
    url: str | None = None

    def __str__(self) -> str:
        if self.url is not None:
            url = self.url
        else:
            url = f"{self.name}/"
        return f"<a href='{url}'>{self.name}</a><br>"


def _download_html(url: str, html_path: Path, *, base_url: str) -> None:
    """Download index HTML file."""
    html_path.parent.mkdir(exist_ok=True, parents=True)
    cmd = [
        "wget",
        "--quiet",
        "--convert-links",
        f"--base={base_url}",
        url,
        "-O",
        html_path,
    ]
    subprocess.check_call(cmd)

    # Strip comments and empty lines
    lines: list[str] = []
    for line in html_path.read_text().splitlines():
        line = line.rstrip()
        if not line or line.lstrip().startswith("<!--"):
            continue
        lines.append(line)
    html_path.write_text("\n".join(lines) + "\n")


def _write_html(html_path: Path, lines: set[_IndexLine]) -> None:
    """Write index HTML file."""
    index_html = _HTML_TEMPLATE.format(body="\n".join(map(str, sorted(lines))))
    html_path.parent.mkdir(exist_ok=True, parents=True)
    html_path.write_text(index_html)


@dataclass(kw_only=True, frozen=True)
class Args:
    output_dir: Annotated[Path, tyro.conf.arg(aliases=("-o",))]
    """Output directory."""
    repo: str = "nvidia-cosmos/cosmos-dependencies"
    """GitHub repository."""
    tag: str
    """Release tag."""
    wheels_file: Path | None = None
    """Wheels file."""


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

    # Group wheels by package name
    all_wheels: dict[str, set[_IndexLine]] = collections.defaultdict(set)

    # Get wheels from release assets
    for asset in assets:
        filename: str = asset["name"]
        if not filename.endswith(".whl"):
            continue

        url: str = asset["url"]
        hash_name, hash_value = asset["digest"].split(":")
        url += f"#{hash_name}={hash_value}"
        pwf = WheelFilename.parse(filename)
        package_name = pwf.project.replace("_", "-")

        all_wheels[package_name].add(_IndexLine(filename, url))

    # Parse wheel URL files
    if args.wheels_file is not None:
        index_name = args.wheels_file.stem
        urls = args.wheels_file.read_text().splitlines()
        for url in urls:
            url = url.strip()
            if not url or url.startswith("#"):
                # Skip comments and empty lines
                continue
            url_parts = urllib.parse.urlparse(url)
            filename = urllib.parse.unquote(url_parts.path.rsplit("/", 1)[-1])
            pwf = WheelFilename.parse(filename)
            package_name = pwf.project.replace("_", "-")
            all_wheels[index_name][package_name].add(_IndexLine(filename, url))

    all_lines: dict[str, set[_IndexLine]] = collections.defaultdict(set)
    for package_name, package_wheels in all_wheels.items():
        all_lines[package_name].update(package_wheels)

    # Create global index
    index_dir = args.output_dir
    index_lines = set(_IndexLine(package_name) for package_name in all_lines)
    _write_html(index_dir / "index.html", index_lines)
    for package_name, package_lines in all_lines.items():
        _write_html(
            index_dir / package_name / "index.html",
            package_lines,
        )


if __name__ == "__main__":
    args = tyro.cli(Args, description=__doc__)
    main(args)
