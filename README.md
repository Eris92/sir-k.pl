# sir-k.pl

Publiczna strona wizytówkowa **Sir-K / Krzysztof Lechmyc**.

Strona prezentuje zakres usług IT, doświadczenie, praktyki bezpieczeństwa, dane kontaktowe oraz odsyła do rozwijanego produktu **SIRK Portal** pod `https://sirkportal.com`.

## Cel projektu

To nie jest panel administracyjny ani aplikacja SaaS. Strona ma pełnić rolę lekkiej, profesjonalnej wizytówki B2B dla firm i instytucji publicznych.

Aktualny kierunek:

- prosty i nowoczesny styl konsultingowy,
- krótkie, czytelne nagłówki,
- nacisk na Microsoft Infrastructure, Identity, Security i automatyzację,
- widoczny kontakt i LinkedIn,
- osobna sekcja produktu SIRK Portal,
- brak trackerów, reklam i zewnętrznych fontów,
- brak niepotwierdzonych certyfikatów, referencji i nazw klientów,
- wersja PL/EN bez przeładowania strony.

## Publiczne adresy

| Adres | Rola |
|---|---|
| `https://sir-k.pl` | domena kanoniczna strony |
| `https://www.sir-k.pl` | przekierowanie do `sir-k.pl` |
| `https://sirkportal.com` | publiczna strona produktu SIRK Portal |
| `https://www.linkedin.com/in/krzysztof-lechmyc` | profil LinkedIn |

## Architektura wdrożenia

Projekt nie uruchamia osobnego Caddy na produkcyjnym VPS.

Pliki znajdują się w:

```text
/opt/sir-k.pl
```

i są montowane tylko do odczytu do kontenera Caddy należącego do projektu `SIRK-Central`:

```yaml
${SIRK_BUSINESS_SITE_PATH:-/opt/sir-k.pl}:/srv/sir-k:ro
```

Ten sam Caddy obsługuje:

```text
sirkportal.com
central.sirkportal.com
auth.sirkportal.com
sir-k.pl
www.sir-k.pl
```

Dzięki temu certyfikaty, przekierowania i nagłówki bezpieczeństwa są zarządzane w jednym miejscu.

## DNS

Rekordy powinny wskazywać na ten sam VPS co SIRK Central:

```text
sir-k.pl      A/AAAA -> VPS
www.sir-k.pl  A/AAAA -> VPS
```

Nie dodawaj `AAAA`, jeżeli IPv6 nie jest skonfigurowany na tym samym VPS. Błędny rekord IPv6 może kierować użytkowników i walidację Let's Encrypt do starego hostingu.

Weryfikacja:

```bash
dig @1.1.1.1 +short A sir-k.pl
dig @1.1.1.1 +short AAAA sir-k.pl
dig @1.1.1.1 +short A www.sir-k.pl
dig @1.1.1.1 +short AAAA www.sir-k.pl
```

## Instalacja repozytorium na VPS

```bash
sudo apt-get update
sudo apt-get install -y git
sudo git clone https://github.com/Eris92/sir-k.pl.git /opt/sir-k.pl
```

Następnie upewnij się, że projekt SIRK Central ma ustawione:

```text
SIRK_BUSINESS_DOMAIN=sir-k.pl
SIRK_BUSINESS_SITE_PATH=/opt/sir-k.pl
```

i odtwórz Caddy:

```bash
cd /opt/sirk-central
docker compose --profile auth up -d --force-recreate caddy
```

Nie uruchamiaj na produkcji osobnego `docker compose` z tego repozytorium, jeśli domenę obsługuje wspólny Caddy SIRK Central.

## Aktualizacja strony

```bash
cd /opt/sir-k.pl
git fetch --prune origin
git reset --hard origin/main
```

Pliki są montowane bezpośrednio do Caddy, więc zwykle wystarczy odświeżenie przeglądarki z pominięciem cache:

```text
Ctrl + F5
```

Gdy Caddy nie widzi zmian lub zmieniono jego konfigurację:

```bash
cd /opt/sirk-central
docker compose --profile auth restart caddy
```

## Struktura projektu

- `index.html` — strona główna i sekcje wizytówki,
- `security.html` — publiczny opis praktyk bezpieczeństwa i odpowiedzialnego użycia narzędzi,
- `privacy.html` — polityka prywatności,
- `styles.css` — wspólny wygląd strony,
- `app.js` — obsługa PL/EN,
- `assets/` — favicon i lokalne zasoby,
- `Caddyfile` i `docker-compose.yml` — wariant samodzielny/testowy; produkcyjnie używany jest Caddy z SIRK Central.

## Główne sekcje strony

- hero: `Bezpieczeństwo bez przestojów.`,
- specjalizacje: `W czym pomagam`,
- profil: `Doświadczenie w praktyce`,
- produkt: `SIRK Portal`,
- bezpieczeństwo: `Bezpieczeństwo przede wszystkim`,
- kontakt: `Porozmawiajmy`.

Treści będą dalej dopracowywane, ale powinny pozostać krótkie, konkretne i możliwe do potwierdzenia.

## Zasady treści publicznej

Nie publikuj:

- nazw klientów bez ich wyraźnej zgody,
- identyfikatorów tenantów, hostów i domen wewnętrznych,
- zrzutów ekranów zawierających dane organizacji,
- niepotwierdzonych certyfikatów lub partnerstw,
- danych logowania, sekretów, adresów administracyjnych i szczegółów break-glass.

Można publikować:

- ogólny zakres technologii i usług,
- faktycznie stosowane praktyki bezpieczeństwa,
- publiczne dane kontaktowe,
- odsyłacz do SIRK Portal i LinkedIn,
- informacje o współpracy B2B oraz sektorach klientów bez podawania ich nazw.

## Przed publikacją zmian

Sprawdź:

1. działanie przełącznika PL/EN,
2. poprawność linków do `sirkportal.com` i LinkedIn,
3. działanie `kontakt@sir-k.pl` i `security@sir-k.pl`,
4. zgodność nazwy prawnej i NIP w polityce prywatności,
5. responsywność na komputerze i telefonie,
6. brak danych klientów w kodzie i metadanych,
7. odpowiedzi HTTP przez Caddy.

## Weryfikacja produkcji

```bash
curl -I https://sir-k.pl
curl -I https://www.sir-k.pl
curl -I https://sir-k.pl/security.html
curl -I https://sir-k.pl/privacy.html
```

Oczekiwane zachowanie:

- `sir-k.pl` zwraca `200`,
- `www.sir-k.pl` przekierowuje do domeny kanonicznej,
- odpowiedź pochodzi z Caddy, a nie ze starego hostingu Apache,
- certyfikat obejmuje `sir-k.pl` i `www.sir-k.pl`,
- wszystkie podstrony działają po HTTPS.