#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="${SITE_DIR:-/opt/sir-k.pl}"
CENTRAL_DIR="${CENTRAL_DIR:-/opt/sirk-central}"
REPO_URL="${REPO_URL:-https://github.com/Eris92/sir-k.pl.git}"

if [[ ${EUID} -ne 0 ]]; then
  echo "Uruchom jako root: sudo bash deploy/install-on-sirk-central.sh" >&2
  exit 1
fi

if [[ ! -d "$CENTRAL_DIR/.git" ]]; then
  echo "Nie znaleziono SIRK Central w $CENTRAL_DIR" >&2
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates git

if [[ -d "$SITE_DIR/.git" ]]; then
  git -C "$SITE_DIR" fetch --prune origin
  git -C "$SITE_DIR" reset --hard origin/main
else
  rm -rf "$SITE_DIR"
  git clone "$REPO_URL" "$SITE_DIR"
fi

chmod -R a+rX "$SITE_DIR"

cd "$CENTRAL_DIR"
git fetch --prune origin
git reset --hard origin/main

docker compose --profile auth up -d --build --force-recreate central auth caddy

printf '\nSIR-K uruchomione przez wspólny Caddy SIRK Central.\n'
printf 'Ustaw DNS A/AAAA dla sir-k.pl oraz www.sir-k.pl na ten VPS.\n'
docker compose --profile auth ps
