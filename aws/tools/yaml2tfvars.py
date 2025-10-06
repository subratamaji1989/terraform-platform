#!/usr/bin/env python3
"""
yaml2tfvars.py
Merge all YAML files under vars/ into a single all.tfvars.json compatible with tf vars.
Usage: python yaml2tfvars.py <vars-dir> <output-json>
"""
import sys
import os
import yaml
import json

def merge_yaml_files(dirpath):
    result = {}
    if not os.path.isdir(dirpath):
        print(f"Error: vars directory not found at '{dirpath}'", file=sys.stderr)
        sys.exit(1)
    for fname in sorted(os.listdir(dirpath)):
        if not (fname.endswith('.yaml') or fname.endswith('.yml')):
            continue
        with open(os.path.join(dirpath, fname)) as fh:
            data = yaml.safe_load(fh) or {}
            for k, v in data.items():
                if k in result and isinstance(result[k], dict) and isinstance(v, dict):
                    result[k].update(v)
                else:
                    result[k] = v
    return result

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: yaml2tfvars.py <vars-dir> <output.json>")
        sys.exit(1)
    varsdir = sys.argv[1]
    out = sys.argv[2]
    merged = merge_yaml_files(varsdir)
    with open(out, 'w') as fh:
        json.dump(merged, fh, indent=2)
    print("Wrote", out)