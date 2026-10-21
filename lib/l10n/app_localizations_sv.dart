// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'CRM App';

  @override
  String get languageTooltip => 'Språk';

  @override
  String get languageSystem => 'Enhetens språk';

  @override
  String errorWithDetails(Object error) {
    return 'Fel: $error';
  }

  @override
  String get noRoleFound => 'Ingen roll hittades för användaren';

  @override
  String get logout => 'Logga ut';

  @override
  String get cancel => 'Avbryt';

  @override
  String get delete => 'Ta bort';

  @override
  String phoneValue(Object phone) {
    return 'Telefon: $phone';
  }

  @override
  String emailValue(Object email) {
    return 'E-post: $email';
  }

  @override
  String clientIdValue(Object clientId) {
    return 'Klient-ID: $clientId';
  }

  @override
  String get statusRequested => 'Ny förfrågan';

  @override
  String get statusProposed => 'Förslag skickat';

  @override
  String get statusAccepted => 'Accepterad av kund';

  @override
  String get statusRejected => 'Avböjd av kund';

  @override
  String get statusCompleted => 'Genomförd';

  @override
  String get customerStatusRequested => 'Skickad – väntar på manager';

  @override
  String get customerStatusProposed =>
      'Förslag från manager – klicka för detaljer';

  @override
  String get customerStatusAccepted =>
      'Accepterad – betalningsuppgifter kommer';

  @override
  String get customerStatusRejected => 'Avböjd';

  @override
  String reportTotalOrders(Object total, Object completed) {
    return 'Totalt antal ordrar: $total (genomförda: $completed)';
  }

  @override
  String reportTotalProfit(Object profit) {
    return 'Total företagets vinst (genomförda): $profit';
  }

  @override
  String get reportProfitPerDay => 'Vinst per dag:';

  @override
  String get noOrdersYet => 'Inga ordrar ännu.';

  @override
  String orderStatusLine(Object status) {
    return 'Status: $status';
  }

  @override
  String orderDetails(Object currency, Object amount, Object fee) {
    return 'Valuta: $currency, Belopp: $amount, Avgift: $fee';
  }

  @override
  String dateValue(Object date) {
    return 'Datum: $date';
  }

  @override
  String get noCustomersYet => 'Inga kunder ännu.';

  @override
  String get deleteCustomerTitle => 'Ta bort kund';

  @override
  String deleteCustomerConfirm(Object clientId, Object name) {
    return 'Vill du verkligen ta bort #$clientId $name?';
  }

  @override
  String get customerAppBarTitle => 'CRM – Kund';

  @override
  String get myTransactions => 'Mina transaktioner';

  @override
  String welcomeName(Object name) {
    return 'Välkommen, $name';
  }

  @override
  String get tabSend => 'Skicka';

  @override
  String get tabBuy => 'Köpa';

  @override
  String get tabSell => 'Sälja';

  @override
  String get tabExchange => 'Växla';

  @override
  String comingSoon(Object section) {
    return '$section – innehåll kommer senare';
  }

  @override
  String get noTransactionsYet => 'Inga transaktioner ännu';

  @override
  String get transaction => 'Transaktion';

  @override
  String get transactions => 'Transaktioner';

  @override
  String youSend(Object amount, Object currency) {
    return 'Du skickar: $amount $currency';
  }

  @override
  String exchangeRateValue(Object from, Object rate, Object to) {
    return 'Växelkurs: 1 $from = $rate $to';
  }

  @override
  String grossReceived(Object amount, Object currency) {
    return 'Brutto mottaget: $amount $currency';
  }

  @override
  String feeValue(
    Object percent,
    Object feeFrom,
    Object from,
    Object feeTo,
    Object to,
  ) {
    return 'Avgift: $percent% ($feeFrom $from ≈ $feeTo $to)';
  }

  @override
  String youReceive(Object amount, Object currency) {
    return 'Du får ut: $amount $currency';
  }

  @override
  String paymentTo(Object label) {
    return 'Betalning till: $label';
  }

  @override
  String payAmountTo(Object amount, Object currency) {
    return 'Betala $amount $currency till:';
  }

  @override
  String get acceptedWaitingPayment =>
      'Du har accepterat. Managern skickar betalningsuppgifter inom kort.';

  @override
  String get accept => 'Acceptera';

  @override
  String get reject => 'Avböj';

  @override
  String get waitingForProposal =>
      'Väntar på att managern ska skicka ett förslag.';

  @override
  String get noSignedInUser => 'Ingen inloggad användare.';

  @override
  String couldNotLoadCustomer(Object error) {
    return 'Kunde inte ladda kund: $error';
  }

  @override
  String get managerStatusRequested => 'Ny förfrågan från kund';

  @override
  String get managerStatusProposed => 'Förslag skickat – väntar på kund';

  @override
  String get managerStatusAccepted => 'Kund har accepterat förslaget';

  @override
  String get managerStatusRejected => 'Kund avbröt transaktionen';

  @override
  String get unknownClient => 'Okänd klient';

  @override
  String get authWrongCredentials => 'Fel e-post eller lösenord.';

  @override
  String get authInvalidEmail => 'Ogiltig e-postadress.';

  @override
  String get authEmailInUse =>
      'Det finns redan ett konto med den här e-postadressen.';

  @override
  String get authWeakPassword => 'Lösenordet är för svagt.';

  @override
  String get authMissingEmail => 'Ange din e-postadress först.';

  @override
  String get authTooManyRequests =>
      'För många försök. Vänta en stund och försök igen.';

  @override
  String get authNetworkError =>
      'Ingen anslutning. Kontrollera internet och försök igen.';

  @override
  String get authUserDisabled => 'Kontot är avstängt.';

  @override
  String get loginTagline => 'VALUTAVÄXLING';

  @override
  String get login => 'Logga in';

  @override
  String get loginSubtitle => 'Ange dina uppgifter för att fortsätta';

  @override
  String get email => 'E-post';

  @override
  String get password => 'Lösenord';

  @override
  String get resetLinkSent =>
      'Återställningslänk har skickats till din e-post.';

  @override
  String get forgotPassword => 'Glömt lösenord?';

  @override
  String get registerAccount => 'Registrera konto';

  @override
  String get registerTitle => 'Registrera dig som kund';

  @override
  String get firstName => 'Förnamn';

  @override
  String get lastName => 'Efternamn';

  @override
  String get phone => 'Telefon';

  @override
  String get enterFirstName => 'Ange förnamn';

  @override
  String get enterLastName => 'Ange efternamn';

  @override
  String get enterValidEmail => 'Ange giltig e-post';

  @override
  String get passwordMinLength => 'Minst 6 tecken';

  @override
  String get register => 'Registrera';

  @override
  String couldNotCreateCustomer(Object error) {
    return 'Kunde inte skapa kund: $error';
  }

  @override
  String get clientIdMustBeInteger => 'Klient-ID måste vara ett heltal';

  @override
  String get customerSaved => 'Kund sparad!';

  @override
  String get createUpdateCustomer => 'Skapa / uppdatera kund';

  @override
  String get clientIdOptional => 'Klient-ID (valfritt)';

  @override
  String get clientIdHint => 't.ex. 007';

  @override
  String get saveCustomer => 'Spara kund';

  @override
  String get office => 'Kontor';

  @override
  String couldNotLoadOffices(Object error) {
    return 'Kunde inte ladda kontor: $error';
  }

  @override
  String get fillAllFieldsValidAmount =>
      'Fyll i alla fält med ett giltigt belopp';

  @override
  String get noCustomerProfile =>
      'Hittar ingen kundprofil för den här användaren';

  @override
  String get requestSentToOffice => 'Begäran skickad till kontoret';

  @override
  String couldNotCreateTransaction(Object error) {
    return 'Fel vid skapande av transaktion: $error';
  }

  @override
  String get noOfficesAvailable =>
      'Det finns inga kontor att skicka via just nu.';

  @override
  String get currencyYouSend => 'Valuta du skickar';

  @override
  String get chooseOfficeFirstCurrency => 'Välj kontor (välj valuta först)';

  @override
  String officesHandlingCurrency(Object currency) {
    return 'Kontor som hanterar $currency';
  }

  @override
  String get currencyRecipientGets => 'Valuta mottagaren tar emot';

  @override
  String get amountToSend => 'Belopp att skicka';

  @override
  String get send => 'Skicka';

  @override
  String get managerCreated => 'Manager skapad.';

  @override
  String couldNotCreateManager(Object error) {
    return 'Kunde inte skapa manager: $error';
  }

  @override
  String unexpectedError(Object error) {
    return 'Oväntat fel: $error';
  }

  @override
  String get createOfficeBeforeManager =>
      'Skapa minst ett kontor innan du lägger till manager.';

  @override
  String get createNewManager => 'Skapa ny manager';

  @override
  String get enterEmail => 'Ange e-post';

  @override
  String get createManager => 'Skapa manager';

  @override
  String couldNotLoadOfficeCurrencies(Object error) {
    return 'Kunde inte läsa kontorets valutor: $error';
  }

  @override
  String get enterCustomerName => 'Ange kundens namn.';

  @override
  String get chooseTwoDifferentCurrencies => 'Välj två olika valutor.';

  @override
  String get enterAmountAboveZero => 'Ange ett belopp större än 0.';

  @override
  String get enterFeeRange => 'Ange en avgift mellan 0 och 100 %.';

  @override
  String get createNewTransaction => 'Skapa ny transaktion';

  @override
  String get customerName => 'Kundens namn';

  @override
  String get phoneOptional => 'Telefon (valfritt)';

  @override
  String get customerGivesCurrency => 'Kunden lämnar (valuta)';

  @override
  String get customerGetsCurrency => 'Kunden får (valuta)';

  @override
  String get amountCustomerGives => 'Belopp som kunden lämnar';

  @override
  String get feePercentLabel => 'Avgift (%)';

  @override
  String get creating => 'Skapar …';

  @override
  String get createTransaction => 'Skapa transaktion';

  @override
  String get chooseAtLeastOneCurrency => 'Välj minst en valuta';

  @override
  String get country => 'Land';

  @override
  String get city => 'Stad';

  @override
  String get enterCountry => 'Ange land';

  @override
  String get enterCity => 'Ange stad';

  @override
  String get currencies => 'Valutor';

  @override
  String get paymentMethods => 'Betalningsmetoder';

  @override
  String get add => 'Lägg till';

  @override
  String get noPaymentMethodsYet =>
      'Inga betalningsmetoder ännu. Tryck \"Lägg till\" för att lägga till.';

  @override
  String get createOffice => 'Skapa kontor';

  @override
  String methodNumber(Object number) {
    return 'Metod $number';
  }

  @override
  String get removeMethod => 'Ta bort metod';

  @override
  String get methodName => 'Namn på metod';

  @override
  String get methodNameHint => 't.ex. SEB SEK-konto, USDT TRC20';

  @override
  String get methodDetails =>
      'Detaljer (kontonummer, IBAN, wallet-adress etc.)';

  @override
  String get methodDetailsHint => 't.ex. IBAN: SE12 3456...';

  @override
  String get supportsCurrencies => 'Stödjer valutor';

  @override
  String get managerAppBarTitle => 'CRM – Manager';

  @override
  String managerAppBarTitleWithOffice(Object office) {
    return 'CRM – Manager ($office)';
  }

  @override
  String get managerPanel => 'Manager-panel';

  @override
  String get managerPanelIntro =>
      'Välj vad du vill arbeta med. Här ser du snabbt nya, pågående och färdiga transaktioner.';

  @override
  String get createTransactionCardSubtitle =>
      'Registrera en kund som kommer in på kontoret och saknar konto.';

  @override
  String get newCustomerTransactions => 'Nya kundtransaktioner';

  @override
  String get newCustomerTransactionsSubtitle =>
      'Se nya beställningar från kunder som ännu inte har påbörjats.';

  @override
  String get ongoingTransactions => 'Pågående transaktioner';

  @override
  String get ongoingTransactionsSubtitle =>
      'Förslag som väntar på kund samt accepterade ärenden som ska betalas och genomföras.';

  @override
  String get finishedTransactions => 'Färdiga transaktioner';

  @override
  String get finishedTransactionsSubtitle =>
      'Genomförda och avböjda transaktioner.';

  @override
  String calculationError(Object error) {
    return 'Fel vid beräkning: $error';
  }

  @override
  String get paymentDetailsSent => 'Betalningsuppgifter skickade till kunden.';

  @override
  String insufficientBalance(Object currency, Object available, Object needed) {
    return 'Kontoret har för lågt saldo i $currency ($available finns, $needed behövs). Be admin fylla på saldo.';
  }

  @override
  String get transactionManager => 'Transaktion (manager)';

  @override
  String customerSends(Object amount, Object currency) {
    return 'Kund skickar: $amount $currency';
  }

  @override
  String toCurrencyValue(Object currency) {
    return 'Till valuta: $currency';
  }

  @override
  String customerReceives(Object amount, Object currency) {
    return 'Kunden får ut: $amount $currency';
  }

  @override
  String get calculating => 'Beräknar...';

  @override
  String paymentMethodValue(Object label) {
    return 'Betalningsmetod: $label';
  }

  @override
  String get officeNotFound => 'Kontoret hittades inte.';

  @override
  String get noPaymentMethodsForCurrency =>
      'Inga betalningsmetoder för den här valutan.';

  @override
  String get choosePaymentMethodForCustomer =>
      'Välj betalningsmetod att skicka till kund:';

  @override
  String get proposeTerms => 'Föreslå villkor';

  @override
  String sentToCustomer(Object label) {
    return 'Skickat till kund: $label';
  }

  @override
  String get resendPaymentDetails => 'Skicka om betalningsuppgifter';

  @override
  String get sendPaymentDetailsToCustomer =>
      'Skicka betalningsuppgifter till kund';

  @override
  String get markAsCompleted => 'Markera som genomförd';

  @override
  String get noOfficesYet => 'Inga kontor skapade ännu.';

  @override
  String get searchCountryOrCity => 'Sök på land eller stad...';

  @override
  String officesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kontor hittade',
      one: '1 kontor hittat',
    );
    return '$_temp0';
  }

  @override
  String get noOfficesMatch => 'Inga kontor matchar sökningen.';

  @override
  String balanceValue(Object balances) {
    return 'Saldo: $balances';
  }

  @override
  String get managerLoading => 'Manager: laddar …';

  @override
  String get managerNone => 'Manager: –';

  @override
  String managerValue(Object name) {
    return 'Manager: $name';
  }

  @override
  String get managerUnknown => 'Manager: (okänd)';

  @override
  String get editOffice => 'Ändra kontor';

  @override
  String get topUpBalance => 'Fyll på saldo';

  @override
  String get deleteOffice => 'Radera kontor';

  @override
  String noCustomerWithClientId(Object clientId) {
    return 'Ingen kund hittades med klient-ID $clientId';
  }

  @override
  String editCustomerTitle(Object clientId) {
    return 'Redigera kund #$clientId';
  }

  @override
  String get customerUpdated => 'Kund uppdaterad!';

  @override
  String get save => 'Spara';

  @override
  String get customerDeleted => 'Kund borttagen.';

  @override
  String get searchClientId => 'Sök klient-ID';

  @override
  String get search => 'Sök';

  @override
  String customerNumber(Object clientId) {
    return 'Kund #$clientId';
  }

  @override
  String get edit => 'Redigera';

  @override
  String nameValue(Object name) {
    return 'Namn: $name';
  }

  @override
  String get officeUpdated => 'Kontor uppdaterat!';

  @override
  String get editOfficeTitle => 'Redigera kontor';

  @override
  String get methodIdLabel => 'ID (t.ex. usdt-trc20)';

  @override
  String get name => 'Namn';

  @override
  String get methodDetailsShort => 'Detaljer (IBAN, wallet etc.)';

  @override
  String get supportedFromCurrency => 'Stöds för valuta (fromCurrency)';

  @override
  String get saveChanges => 'Spara ändringar';

  @override
  String get officeCreated => 'Kontor skapat!';

  @override
  String get deleteOfficeQuestion => 'Radera kontor?';

  @override
  String get deleteOfficeConfirm => 'Kontoret tas bort permanent. Är du säker?';

  @override
  String get deleteAction => 'Radera';

  @override
  String get officeDeleted => 'Kontor raderat';

  @override
  String deleteError(Object error) {
    return 'Fel vid radering: $error';
  }

  @override
  String startBalance(Object currency) {
    return 'Startsaldo $currency';
  }

  @override
  String get assignManager => 'Tilldela manager';

  @override
  String get noManagersYet => 'Inga managers registrerade ännu.';

  @override
  String get manager => 'Manager';

  @override
  String get noPaymentMethodsAdded => 'Inga betalningsmetoder tillagda ännu.';

  @override
  String get searchManageOffices => 'Sök & hantera kontor';

  @override
  String get noOfficesFound => 'Inga kontor hittades.';

  @override
  String officeSummary(Object currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count betalningsmetoder',
      one: '1 betalningsmetod',
    );
    return 'Valutor: $currencies\n$_temp0';
  }

  @override
  String get exportDate => 'Datum';

  @override
  String get exportStatus => 'Status';

  @override
  String get exportClientId => 'Klient-ID';

  @override
  String get exportOffice => 'Kontor';

  @override
  String get exportFrom => 'Från';

  @override
  String get exportTo => 'Till';

  @override
  String get exportAmount => 'Belopp';

  @override
  String get exportFee => 'Avgift';

  @override
  String get exportPayout => 'Utbetalas';

  @override
  String get noTransactionsToExport => 'Inga transaktioner att exportera';

  @override
  String get orderReport => 'Orderrapport';

  @override
  String get adminAppBarTitle => 'CRM – Admin';

  @override
  String get adminHeadline => 'Adminvy: Full kontroll';

  @override
  String get manageOffices => 'Hantera kontor';

  @override
  String get officeHasNoCurrencies =>
      'Kontoret har inga valutor. Lägg till en valuta via Ändra kontor först.';

  @override
  String get currency => 'Valuta';

  @override
  String get amount => 'Belopp';

  @override
  String get ok => 'OK';

  @override
  String get orderHistory => 'Orderhistorik';

  @override
  String get filterByOffice => 'Filtrera på kontor (valfritt)';

  @override
  String get allOffices => 'Alla kontor';

  @override
  String get chooseDateRange => 'Välj datumintervall';

  @override
  String get clearDates => 'Rensa datum';

  @override
  String get exportCsv => 'Exportera CSV';

  @override
  String get exportPdf => 'Exportera PDF';

  @override
  String get chooseDateRangeHint =>
      'Välj ett datumintervall för att visa transaktioner.';

  @override
  String clientShort(Object clientId) {
    return 'Klient $clientId';
  }

  @override
  String get rateMissingApiKey =>
      'API-nyckel för valutakurser saknas. Bygg appen med --dart-define-from-file=fx_key.json.';

  @override
  String rateHttpError(Object code) {
    return 'Kunde inte hämta växelkurs (HTTP $code).';
  }

  @override
  String rateNotFound(Object from, Object to) {
    return 'Ingen kurs hittades för $from → $to.';
  }

  @override
  String get customers => 'Kunder';

  @override
  String get offices => 'Kontor';

  @override
  String get managers => 'Managers';

  @override
  String get adminPanel => 'Admin-panel';

  @override
  String get adminPanelIntro =>
      'Välj vad du vill hantera. Siffran på varje kort visar hur många det finns.';

  @override
  String get customersCardSubtitle => 'Skapa, sök, ändra och ta bort kunder.';

  @override
  String get officesCardSubtitle =>
      'Skapa kontor, ändra valutor och betalningsmetoder och fyll på saldon.';

  @override
  String get managersCardSubtitle =>
      'Skapa managers och se vilket kontor de arbetar på.';

  @override
  String get ordersCardSubtitle =>
      'Alla transaktioner med filter, vinstrapport och export till CSV/PDF.';

  @override
  String get existingManagers => 'Befintliga managers';

  @override
  String get noOfficeAssigned => 'Inget kontor';

  @override
  String officeValue(Object office) {
    return 'Kontor: $office';
  }

  @override
  String get searchCustomers => 'Sök kund';

  @override
  String get searchCustomersLabel =>
      'Klient-ID, namn, telefon, land eller stad';

  @override
  String get searchCustomersHint => 't.ex. 00, Ali, 0731, Grozny';

  @override
  String get clearSearch => 'Rensa sökning';

  @override
  String customersShown(int shown, int total) {
    return 'Visar $shown av $total kunder';
  }

  @override
  String get noCustomersMatch => 'Inga kunder matchar sökningen.';

  @override
  String placesValue(Object places) {
    return 'Kontor: $places';
  }

  @override
  String typeToSearchCustomers(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Skriv i sökrutan för att visa kunder ($total kunder totalt).',
      one: 'Skriv i sökrutan för att visa kunder (1 kund totalt).',
    );
    return '$_temp0';
  }

  @override
  String customersShownLimited(int shown, int count) {
    return 'Visar de första $shown av $count träffar. Skriv mer för att begränsa.';
  }

  @override
  String typeToSearch(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Skriv i sökrutan för att visa träffar ($total totalt).',
      one: 'Skriv i sökrutan för att visa träffar (1 totalt).',
    );
    return '$_temp0';
  }

  @override
  String get noSearchMatches => 'Inga träffar.';

  @override
  String searchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count träffar',
      one: '1 träff',
    );
    return '$_temp0';
  }

  @override
  String get searchOfficesLabel => 'Sök på land, stad eller valuta';

  @override
  String get searchManagersLabel => 'Sök på namn, e-post, telefon eller kontor';

  @override
  String get searchTransactionsLabel =>
      'Klient-ID, namn, telefon, kontor, valuta eller status';

  @override
  String get searchTransactionsHint => 't.ex. 00, Ali, Grozny, RUB, genomförd';

  @override
  String get searchOrChooseDatesHint =>
      'Skriv i sökrutan eller välj ett datumintervall för att visa transaktioner.';
}
