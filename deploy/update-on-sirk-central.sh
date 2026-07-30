#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="${SITE_DIR:-/opt/sir-k.pl}"
CENTRAL_DIR="${CENTRAL_DIR:-/opt/sirk-central}"

if [[ ${EUID} -ne 0 ]]; then
  echo "Uruchom jako root: sudo bash deploy/update-on-sirk-central.sh" >&2
  exit 1
fi

if [[ ! -d "$SITE_DIR/.git" ]]; then
  echo "Nie znaleziono strony w $SITE_DIR" >&2
  exit 1
fi

if [[ ! -d "$CENTRAL_DIR/.git" ]]; then
  echo "Nie znaleziono SIRK Central w $CENTRAL_DIR" >&2
  exit 1
fi

git -C "$SITE_DIR" fetch --prune origin
git -C "$SITE_DIR" reset --hard origin/main
chmod -R a+rX "$SITE_DIR"

cd "$CENTRAL_DIR"
docker compose --profile auth up -d --force-recreate caddy

echo "sir-k.pl zaktualizowane."
