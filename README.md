# sir-k.pl

Nowa statyczna strona marki Sir-K, przygotowana do uruchomienia na VPS.

## Założenia

- spójny styl z `sirkportal.com`,
- pełna wersja PL/EN bez przeładowania,
- brak trackerów, reklam i zewnętrznych fontów,
- publiczny opis praktyk bezpieczeństwa i odpowiedzialnego użycia AI,
- brak niepotwierdzonych certyfikatów i nazw klientów,
- Caddy z automatycznym TLS i nagłówkami bezpieczeństwa,
- proste wdrożenie Docker Compose.

## Przed publikacją

Sprawdź i potwierdź:

1. Czy adresy `kontakt@sir-k.pl` i `security@sir-k.pl` istnieją.
2. Czy nazwa prawna w polityce prywatności odpowiada wpisowi działalności.
3. Czy NIP `6040150128` jest poprawny.
4. Czy opis stosowanych kontroli odpowiada faktycznemu sposobowi pracy.

## Instalacja na świeżym Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y git
sudo git clone https://github.com/Eris92/sir-k.pl.git /opt/sir-k.pl
cd /opt/sir-k.pl
sudo bash deploy/install.sh
```

Ustaw DNS:

```text
sir-k.pl      A/AAAA → VPS
www.sir-k.pl  A/AAAA → VPS
```

## Aktualizacja

```bash
cd /opt/sir-k.pl
git fetch --prune origin
git reset --hard origin/main
docker compose up -d --force-recreate
```

## Pliki

- `index.html` — strona główna,
- `security.html` — praktyki bezpieczeństwa i odpowiedzialnego użycia,
- `privacy.html` — polityka prywatności,
- `styles.css` — wspólny wygląd,
- `app.js` — PL/EN,
- `Caddyfile` — TLS i nagłówki bezpieczeństwa,
- `docker-compose.yml` — uruchomienie na VPS.
