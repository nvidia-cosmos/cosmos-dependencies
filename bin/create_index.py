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

_TORCH_BASE_URL = "https://download.pytorch.org"
_TORCH_PACKAGES = [
    "torch",
    "torchvision",
    "triton",
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
        line_stripped = line.strip()
        if not line_stripped or line_stripped.startswith("<!--"):
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

    # Group wheels by cuda/torch version and package name
    all_wheels: dict[str, dict[str, set[_IndexLine]]] = collections.defaultdict(lambda: collections.defaultdict(set))

    # Get wheels from release assets
    version_pattern = parse.compile("{version}+cu{cuda_version:d}.torch{torch_version:d}", case_sensitive=True)
    for asset in assets:
        filename: str = asset["name"]
        if not filename.endswith(".whl"):
            continue

        url: str = asset["url"]
        hash_name, hash_value = asset["digest"].split(":")
        url += f"#{hash_name}={hash_value}"
        pwf = parse_wheel_filename(filename)
        package_name = pwf.project.replace("_", "-")

        # Parse cuda/torch version
        match = version_pattern.parse(pwf.version)
        if match is None:
            warnings.warn(f"Skipping invalid wheel filename: {filename}")
            continue
        index_name = f"cu{match['cuda_version']}_torch{match['torch_version']}"

        all_wheels[index_name][package_name].add(_IndexLine(filename, url))

    # Parse wheel URL files
    urls_files = args.input_dir.glob("*.txt")
    assert urls_files
    for urls_file in urls_files:
        index_name = urls_file.stem
        urls = urls_file.read_text().splitlines()
        for url in urls:
            url = url.strip()
            if not url or url.startswith("#"):
                # Skip comments and empty lines
                continue
            url_parts = urllib.parse.urlparse(url)
            filename = urllib.parse.unquote(url_parts.path.rsplit("/", 1)[-1])
            pwf = parse_wheel_filename(filename)
            package_name = pwf.project.replace("_", "-")
            all_wheels[index_name][package_name].add(_IndexLine(filename, url))

    all_lines: dict[str, set[_IndexLine]] = collections.defaultdict(set)

    # Create cuda/torch specific indices
    for index_name, index_wheels in all_wheels.items():
        index_dir = args.output_dir / index_name / "simple"
        cuda_name, _torch_name = index_name.split("_")
        index_lines = set()

        # Create package indices
        for package_name, package_wheels in index_wheels.items():
            index_lines.add(_IndexLine(package_name))
            all_lines[package_name].update(package_wheels)
            _write_html(
                index_dir / package_name / "index.html",
                package_wheels,
            )

        for package_name in _TORCH_PACKAGES:
            index_lines.add(_IndexLine(package_name))
            _download_html(
                f"{_TORCH_BASE_URL}/whl/{cuda_name}/{package_name}/",
                index_dir / package_name / "index.html",
                base_url=_TORCH_BASE_URL,
            )
        _write_html(
            index_dir / "index.html",
            index_lines,
        )

    # Create global index
    index_dir = args.output_dir / "simple"
    index_lines = set(_IndexLine(package_name) for package_name in all_lines)
    for package_name in _TORCH_PACKAGES:
        index_lines.add(_IndexLine(package_name))
        _download_html(
            f"{_TORCH_BASE_URL}/whl/{package_name}/", index_dir / package_name / "index.html", base_url=_TORCH_BASE_URL
        )
    _write_html(index_dir / "index.html", index_lines)
    for package_name, package_lines in all_lines.items():
        _write_html(
            index_dir / package_name / "index.html",
            package_lines,
        )


if __name__ == "__main__":
    args = tyro.cli(Args, description=__doc__)
    main(args)
