# crm_app

Flutter-app (Firebase Auth + Cloud Firestore) för kontor som hanterar valutaöverföringar.
Tre roller, styrda av `users/{uid}.role`: `admin`, `manager` och `customer`.

## Flödet

1. Kunden väljer **valutan hen skickar**, sedan ett av de **kontor som hanterar den valutan**,
   sedan **valutan mottagaren får** och belopp. Det skapar en `transactions`-post med status `customer_requested`.
2. Kontorets manager hämtar kurs, sätter avgift och **föreslår villkor** (`manager_proposed`).
3. Kunden **accepterar** (`customer_accepted`) eller **avböjer** (`customer_rejected`).
4. Managern väljer betalningsmetod och markerar transaktionen **genomförd** (`completed`).

## Firestore

| Samlingen | Innehåll | Vem läser |
|---|---|---|
| `users/{uid}` | roll, `officeId` (managers), kontaktuppgifter | egen post, admin |
| `customers/{uid}` | klient-ID (heltal), namn, telefon, `userId` | egen post, admin |
| `meta/customers` | `lastClientId`, räknare för klient-ID | alla inloggade (skriv: admin, och kund vid registrering, +1) |
| `offices/{id}` | **privat**: saldon, betalningsuppgifter | admin, kontorets manager |
| `officeListings/{id}` | **publik**: land, stad, valutor (kopia av kontoret) | alla inloggade (skriv: admin) |
| `transactions/{id}` | förfrågningar och deras status | admin, kontorets manager, kunden själv |

`officeListings` skrivs av admin-appen när ett kontor skapas, ändras eller raderas, och
rättas av `OfficeListingService.syncAll()` varje gång admin öppnar appen.
Kunder läser bara den, så de ser aldrig saldon eller betalningsuppgifter.

Reglerna ligger i `firestore.rules` och indexen i `firestore.indexes.json`.

## Sätta upp

```bash
# 1. Deploya regler och index
firebase deploy --only firestore

# 2. Lägg API-nyckeln för valutakurser (freecurrencyapi.com) i en lokal fil.
#    fx_key.json ignoreras av git, så nyckeln hamnar aldrig i repot.
cp fx_key.example.json fx_key.json   # klistra sedan in nyckeln i filen

# 3. Starta eller bygg appen
flutter run --dart-define-from-file=fx_key.json
flutter build web --dart-define-from-file=fx_key.json
```

Obs: i webbygget hamnar nyckeln i den publicerade JavaScript-koden och kan läsas av den som letar.

### Publicera webbappen

Webbappen ligger på Firebase Hosting: **https://crm-app-1e5fe.web.app**

```bash
scripts/deploy_web.sh            # bygger och publicerar live
scripts/deploy_web.sh preview    # tillfällig förhandsadress (7 dagar) att testa på först
```

Skriptet bygger med `fx_key.json` och kör `firebase deploy --only hosting`. Reglerna
deployas inte här, utan med `firebase deploy --only firestore`.

### Första gången efter uppdateringen

1. Deploya reglerna (ovan).
2. Logga in som admin och öppna appen en gång. Då skapas `officeListings` för befintliga kontor och
   `meta/customers.lastClientId` sätts till minst det högsta befintliga klient-ID:t.
3. Släpp därefter appen till kunder och managers.

### Skapa en admin

Första admin-kontot skapas manuellt: skapa användaren under Authentication i Firebase-konsolen och lägg
ett dokument `users/{uid}` med `role: "admin"` i Firestore. Kunder skapas via registreringen i appen
och managers skapas av en admin i adminvyn.

## Betalningsuppgifter, saldon och valutakoder

- När kunden har accepterat väljer managern en betalningsmetod och trycker
  "Skicka betalningsuppgifter till kund". Namn och uppgifter kopieras in i
  transaktionen (`paymentMethodLabel`, `paymentMethodDetails`) och kunden ser
  dem direkt i sin transaktion. Först därefter kan den markeras som genomförd.
- "Markera som genomförd" bokför kontorets saldo i samma batch: kontoret får
  `+amountFrom` i `fromCurrency` och `-amountToNet` i `toCurrency`. Saldot får
  inte bli negativt. Reglerna kontrollerar att ändringen matchar transaktionen.
- Valutakoder är alltid ISO-liknande (`RUB`, `EUR`, ...) enligt
  `lib/utils/currencies.dart`. Gamla `RUBLE`/`EURO` rättas automatiskt när en
  admin öppnar appen (`CurrencyMigrationService`).
- Managern kan skapa en transaktion för en kund utan konto ("Skapa ny
  transaktion"). Den startar som `customer_accepted`.

## Språk

Appen finns på ryska, engelska, svenska och turkiska.

- Första gången öppnas appen på enhetens språk. Finns det språket inte i appen visas **ryska**.
- Språket byts med 🌐 uppe till höger (inloggning, registrering och alla tre rollernas startsidor).
  Valet sparas på enheten. "Enhetens språk" går tillbaka till automatiskt val.
- Texterna ligger i `lib/l10n/app_<språk>.arb`. `app_sv.arb` är mallen: lägg nya texter där
  först, översätt dem i de andra filerna och kör `flutter gen-l10n` (görs också automatiskt vid bygge).
- I koden hämtas texter med `context.l10n.nyckel` (se `lib/l10n/locale_controller.dart`).
- Nytt språk: lägg till `app_<kod>.arb` och koden i `LocaleController.languages`.
