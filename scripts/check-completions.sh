#!/usr/bin/env bash
set -euo pipefail

prefix="$(brew --prefix "$1")"
for completion in \
  etc/bash_completion.d/katlctl \
  share/fish/vendor_completions.d/katlctl.fish \
  share/zsh/site-functions/_katlctl; do
  if [[ ! -s "$prefix/$completion" ]]; then
    echo "Missing or empty completion: $prefix/$completion" >&2
    exit 1
  fi
done
