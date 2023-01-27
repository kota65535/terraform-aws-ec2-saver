#!/usr/bin/env bash
set -euo pipefail

# Install pre-commit hook
if [[ $0 != ".git/hooks/pre-commit" ]]; then
  cp "$0" .git/hooks/pre-commit
fi

# Update requirements.txt
cd lambda
poetry export -o requirements.txt
git add requirements.txt
