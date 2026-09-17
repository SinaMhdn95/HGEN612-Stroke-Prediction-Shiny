#!/usr/bin/env bash
set -euo pipefail

tracked_files=$(git ls-files)

if printf '%s\n' "$tracked_files" | grep -Eiq '(^|/)(\.Renviron($|\.)|github-recovery-codes|credentials?|secrets?|id_rsa|id_ed25519)(\.|/|$)'; then
  echo "Blocked: a credential-like file is tracked." >&2
  exit 1
fi

if git grep -IEn 'sk-[A-Za-z0-9_-]{20,}|OPENAI_API_KEY|GITHUB_TOKEN|AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY)|-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----' -- . ':(exclude)scripts/privacy_check.sh'; then
  echo "Blocked: a probable secret is present in tracked text." >&2
  exit 1
fi

if git grep -IEn '/Users/[^/]+/|[A-Za-z]:\\\\Users\\\\' -- . ':(exclude)scripts/privacy_check.sh'; then
  echo "Blocked: an absolute user path is present in tracked text." >&2
  exit 1
fi

echo "Privacy check passed."
