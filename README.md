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

# 2. Starta appen. Valutakursernas API-nyckel ligger inte i koden:
flutter run --dart-define=FX_API_KEY=din_nyckel
```

Gör samma `--dart-define` när du bygger (`flutter build web --dart-define=FX_API_KEY=...`).

### Första gången efter uppdateringen

1. Deploya reglerna (ovan).
2. Logga in som admin och öppna appen en gång. Då skapas `officeListings` för befintliga kontor och
   `meta/customers.lastClientId` sätts till minst det högsta befintliga klient-ID:t.
3. Släpp därefter appen till kunder och managers.

### Skapa en admin

Första admin-kontot skapas manuellt: skapa användaren under Authentication i Firebase-konsolen och lägg
ett dokument `users/{uid}` med `role: "admin"` i Firestore. Kunder skapas via registreringen i appen
och managers skapas av en admin i adminvyn.
