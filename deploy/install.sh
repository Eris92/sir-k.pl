#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/sir-k.pl}"
REPO_URL="${REPO_URL:-https://github.com/Eris92/sir-k.pl.git}"
SITE_DOMAIN="${SITE_DOMAIN:-sir-k.pl}"

if [[ ${EUID} -ne 0 ]]; then
  echo "Uruchom jako root: sudo bash deploy/install.sh" >&2
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git docker.io docker-compose-plugin
systemctl enable --now docker

if [[ -d "$APP_DIR/.git" ]]; then
  git -C "$APP_DIR" fetch --prune origin
  git -C "$APP_DIR" reset --hard origin/main
else
  rm -rf "$APP_DIR"
  git clone "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"
if [[ ! -f .env ]]; then
  read -r -p "Adres e-mail dla Let's Encrypt: " ACME_EMAIL
  umask 077
  cat > .env <<EOF
SITE_DOMAIN=$SITE_DOMAIN
ACME_EMAIL=$ACME_EMAIL
EOF
fi

chmod 600 .env
docker compose pull
docker compose up -d --force-recreate

echo
echo "Strona uruchomiona. Ustaw rekordy DNS A/AAAA dla $SITE_DOMAIN i www.$SITE_DOMAIN na ten VPS."
docker compose ps
