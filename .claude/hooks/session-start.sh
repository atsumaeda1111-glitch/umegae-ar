#!/bin/bash
# Installs markitdown (document -> Markdown conversion) for Claude Code on the web
# sessions. Only runs remotely; local machines keep their own Python setup.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Fast path: the container image is cached after this hook completes, so on
# resume/clear/compact the packages are usually already present.
if python3 -c 'import markitdown' 2>/dev/null; then
  echo "markitdown already installed"
  exit 0
fi

PIP_ARGS=(--quiet --root-user-action=ignore)

# cffi must come first. The base image ships Debian's cryptography without it,
# so pdfminer (pulled in by markitdown[all]) dies on `import cryptography`
# with "No module named '_cffi_backend'".
python3 -m pip install "${PIP_ARGS[@]}" cffi
python3 -m pip install "${PIP_ARGS[@]}" 'markitdown[all]'

python3 -c 'import markitdown' 2>/dev/null
echo "markitdown installed"
