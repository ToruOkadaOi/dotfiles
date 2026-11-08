#!/usr/bin/env python3
"""Select a release asset and its GitHub-published SHA-256 digest."""
import json
import re
import sys

path, tool, target = sys.argv[1:]
with open(path, encoding="utf-8") as source:
    release = json.load(source)
version = release["tag_name"]
if version.startswith("v"):
    version = version[1:]
if not re.fullmatch(r"\d+\.\d+\.\d+", version):
    raise SystemExit("Unsupported release version")
if tool == "delta":
    filename = f"delta-{version}-{target}.tar.gz"
elif tool == "lazygit":
    filename = f"lazygit_{version}_linux_{target}.tar.gz"
else:
    raise SystemExit("Unsupported tool")
assets = [asset for asset in release["assets"] if asset["name"] == filename]
if len(assets) != 1:
    raise SystemExit(f"Release asset missing or ambiguous: {filename}")
digest = assets[0].get("digest") or ""
if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
    raise SystemExit(f"No SHA-256 digest for {filename}")
print(version, digest[len("sha256:"):])
