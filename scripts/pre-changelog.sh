#!/usr/bin/env bash
# pre-changelog.sh — Validate inputs before the changelog agent runs.
#
# Runs on the host via the harness pre_script mechanism. Validates that
# the issue URL and issue number are well-formed before starting the sandbox.
#
# Required env vars:
#   GITHUB_ISSUE_URL — HTML URL of the issue
#   GH_TOKEN         — GitHub token with issues read scope

set -euo pipefail

echo "::notice::📋 Changelog target: ${GITHUB_ISSUE_URL:-}"

errors=0

if [[ ! "${GITHUB_ISSUE_URL:-}" =~ ^https://github\.com/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+/issues/[0-9]+$ ]]; then
  echo "::error::GITHUB_ISSUE_URL does not match expected pattern: '${GITHUB_ISSUE_URL:-}'"
  errors=$((errors + 1))
fi

# Extract and validate issue number from the URL.
if [[ -n "${GITHUB_ISSUE_URL:-}" ]]; then
  URL_ISSUE_NUMBER=$(basename "${GITHUB_ISSUE_URL}")
  if [[ ! "${URL_ISSUE_NUMBER}" =~ ^[1-9][0-9]*$ ]]; then
    echo "::error::Issue number extracted from URL is not a positive integer: '${URL_ISSUE_NUMBER}'"
    errors=$((errors + 1))
  fi
fi

if [[ "${errors}" -gt 0 ]]; then
  echo "::error::Input validation failed with ${errors} error(s). Aborting."
  exit 1
fi

echo "Input validation passed."
