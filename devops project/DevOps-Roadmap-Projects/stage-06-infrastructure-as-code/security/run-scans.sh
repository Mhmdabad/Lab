#!/usr/bin/env bash
# run-scans.sh — DevSecOps step 06 (IaC Security) for this stage.
#
# Runs every scanner you have installed against the Terraform + Ansible code.
# Each tool is optional: if it isn't installed we print a hint and continue,
# so the script is useful whether you have all of them or none.
#
# Usage:  ./run-scans.sh
set -uo pipefail

TF_DIR="$(cd "$(dirname "$0")/../terraform" && pwd)"
ANS_DIR="$(cd "$(dirname "$0")/../ansible" && pwd)"
FAILED=0

section() { printf '\n\033[1;34m==== %s ====\033[0m\n' "$1"; }
have()    { command -v "$1" >/dev/null 2>&1; }
skip()    { printf '  \033[33m[skip] %s not installed — %s\033[0m\n' "$1" "$2"; }

# 1) Secret scanning — no AWS keys / passwords committed anywhere.
section "1/5  Gitleaks (secret scanning)"
if have gitleaks; then
  gitleaks detect --source .. --no-banner --verbose || FAILED=1
else
  skip gitleaks "https://github.com/gitleaks/gitleaks"
fi

# 2) Checkov — Terraform misconfiguration.
section "2/5  Checkov (Terraform)"
if have checkov; then
  checkov -d "$TF_DIR" --compact --quiet || FAILED=1
else
  skip checkov "pip install checkov"
fi

# 3) tfsec — second-opinion Terraform scanner.
section "3/5  tfsec (Terraform)"
if have tfsec; then
  tfsec "$TF_DIR" || FAILED=1
else
  skip tfsec "https://github.com/aquasecurity/tfsec"
fi

# 4) Trivy config — Trivy's built-in IaC scanner (covers Terraform).
section "4/5  Trivy config (Terraform)"
if have trivy; then
  trivy config "$TF_DIR" || FAILED=1
else
  skip trivy "https://aquasecurity.github.io/trivy"
fi

# 5) Trivy config on Ansible.
section "5/5  Trivy config (Ansible)"
if have trivy; then
  trivy config "$ANS_DIR" || FAILED=1
else
  skip trivy "https://aquasecurity.github.io/trivy"
fi

echo
if [ "$FAILED" -eq 0 ]; then
  printf '\033[1;32mAll available scanners passed (or found nothing critical).\033[0m\n'
else
  printf '\033[1;31mOne or more scanners reported findings. Read the output above.\033[0m\n'
  printf 'Tip: this is expected if you uncommented the INSECURE-ON-PURPOSE block.\n'
fi
exit "$FAILED"
