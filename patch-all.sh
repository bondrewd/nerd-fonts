#!/bin/bash

for f in $1/*; do
    ./custom-patcher.sh --out-name "Fira Code Custom" "$f"
done
