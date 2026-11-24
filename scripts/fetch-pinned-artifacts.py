#!/usr/bin/env python3
"""Download the pinned cache's archives and check each one against the pinned list.

Written for this repository. The pins and the check of the list come from
scripts/restore-cache.py. The download is done by scripts/rh-buildq/fetch-artifacts.py, an
unchanged copy of upstream's downloader. It checks each archive's SHA-256 before the archive
enters the cache. It also checks the archives already there and downloads a bad one again, so
a rerun repairs a cache that dropped connections left incomplete.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import urllib.request

SCRIPTS = Path(__file__).resolve().parent
FETCH_ARTIFACTS = SCRIPTS / "rh-buildq" / "fetch-artifacts.py"
ARTIFACTS = "https://rh-cache.taucetiproject.org/artifacts/leanprover-community/riemann-hypothesis/"
USER_AGENT = "RiemannHypothesisCache/1.0"
MAP_SCHEMA = "2026-03-17"  # The first line of a Lake map. The downloader skips it.

_PINS = importlib.util.spec_from_file_location("rh_pinned_cache", SCRIPTS / "restore-cache.py")
pins = importlib.util.module_from_spec(_PINS)
_PINS.loader.exec_module(pins)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache-dir", type=Path, help="defaults to LAKE_CACHE_DIR or .lake/cache")
    args = parser.parse_args()
    cache = (args.cache_dir or Path(os.environ.get("LAKE_CACHE_DIR", ".lake/cache"))).resolve()
    request = urllib.request.Request(pins.URL, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        rows = pins.manifest_rows(response.read())
    cache.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="fetch-pinned-", dir=cache) as temporary:
        mapping, digests = Path(temporary) / "outputs.jsonl", Path(temporary) / "sha256.json"
        mapping.write_text(json.dumps(MAP_SCHEMA) + "\n" + "".join(
            json.dumps([dep_hash, artifact]) + "\n" for _, dep_hash, artifact, _ in rows))
        digests.write_text(json.dumps({artifact: digest for _, _, artifact, digest in rows}))
        code = subprocess.run([sys.executable, "-I", str(FETCH_ARTIFACTS), str(mapping), str(cache),
                               "--sha256", str(digests), "--verify-existing",
                               "--base-url", ARTIFACTS, "--user-agent", USER_AGENT]).returncode
    if code:
        raise ValueError("some archives could not be downloaded and checked; its output above says why. "
                         "If this was a network problem, rerun lake exe cache get")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as error:
        sys.exit(f"Download stopped: {error}")
