import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In sv, this message translates to:
  /// **'CRM App'**
  String get appTitle;

  /// No description provided for @languageTooltip.
  ///
  /// In sv, this message translates to:
  /// **'Språk'**
  String get languageTooltip;

  /// No description provided for @languageSystem.
  ///
  /// In sv, this message translates to:
  /// **'Enhetens språk'**
  String get languageSystem;

  /// No description provided for @errorWithDetails.
  ///
  /// In sv, this message translates to:
  /// **'Fel: {error}'**
  String errorWithDetails(Object error);

  /// No description provided for @noRoleFound.
  ///
  /// In sv, this message translates to:
  /// **'Ingen roll hittades för användaren'**
  String get noRoleFound;

  /// No description provided for @logout.
  ///
  /// In sv, this message translates to:
  /// **'Logga ut'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In sv, this message translates to:
  /// **'Avbryt'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In sv, this message translates to:
  /// **'Ta bort'**
  String get delete;

  /// No description provided for @phoneValue.
  ///
  /// In sv, this message translates to:
  /// **'Telefon: {phone}'**
  String phoneValue(Object phone);

  /// No description provided for @emailValue.
  ///
  /// In sv, this message translates to:
  /// **'E-post: {email}'**
  String emailValue(Object email);

  /// No description provided for @clientIdValue.
  ///
  /// In sv, this message translates to:
  /// **'Klient-ID: {clientId}'**
  String clientIdValue(Object clientId);

  /// No description provided for @statusRequested.
  ///
  /// In sv, this message translates to:
  /// **'Ny förfrågan'**
  String get statusRequested;

  /// No description provided for @statusProposed.
  ///
  /// In sv, this message translates to:
  /// **'Förslag skickat'**
  String get statusProposed;

  /// No description provided for @statusAccepted.
  ///
  /// In sv, this message translates to:
  /// **'Accepterad av kund'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In sv, this message translates to:
  /// **'Avböjd av kund'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In sv, this message translates to:
  /// **'Genomförd'**
  String get statusCompleted;

  /// No description provided for @customerStatusRequested.
  ///
  /// In sv, this message translates to:
  /// **'Skickad – väntar på manager'**
  String get customerStatusRequested;

  /// No description provided for @customerStatusProposed.
  ///
  /// In sv, this message translates to:
  /// **'Förslag från manager – klicka för detaljer'**
  String get customerStatusProposed;

  /// No description provided for @customerStatusAccepted.
  ///
  /// In sv, this message translates to:
  /// **'Accepterad – betalningsuppgifter kommer'**
  String get customerStatusAccepted;

  /// No description provided for @customerStatusRejected.
  ///
  /// In sv, this message translates to:
  /// **'Avböjd'**
  String get customerStatusRejected;

  /// No description provided for @reportTotalOrders.
  ///
  /// In sv, this message translates to:
  /// **'Totalt antal ordrar: {total} (genomförda: {completed})'**
  String reportTotalOrders(Object total, Object completed);

  /// No description provided for @reportTotalProfit.
  ///
  /// In sv, this message translates to:
  /// **'Total företagets vinst (genomförda): {profit}'**
  String reportTotalProfit(Object profit);

  /// No description provided for @reportProfitPerDay.
  ///
  /// In sv, this message translates to:
  /// **'Vinst per dag:'**
  String get reportProfitPerDay;

  /// No description provided for @noOrdersYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga ordrar ännu.'**
  String get noOrdersYet;

  /// No description provided for @orderStatusLine.
  ///
  /// In sv, this message translates to:
  /// **'Status: {status}'**
  String orderStatusLine(Object status);

  /// No description provided for @orderDetails.
  ///
  /// In sv, this message translates to:
  /// **'Valuta: {currency}, Belopp: {amount}, Avgift: {fee}'**
  String orderDetails(Object currency, Object amount, Object fee);

  /// No description provided for @dateValue.
  ///
  /// In sv, this message translates to:
  /// **'Datum: {date}'**
  String dateValue(Object date);

  /// No description provided for @noCustomersYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga kunder ännu.'**
  String get noCustomersYet;

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Ta bort kund'**
  String get deleteCustomerTitle;

  /// No description provided for @deleteCustomerConfirm.
  ///
  /// In sv, this message translates to:
  /// **'Vill du verkligen ta bort #{clientId} {name}?'**
  String deleteCustomerConfirm(Object clientId, Object name);

  /// No description provided for @customerAppBarTitle.
  ///
  /// In sv, this message translates to:
  /// **'CRM – Kund'**
  String get customerAppBarTitle;

  /// No description provided for @myTransactions.
  ///
  /// In sv, this message translates to:
  /// **'Mina transaktioner'**
  String get myTransactions;

  /// No description provided for @welcomeName.
  ///
  /// In sv, this message translates to:
  /// **'Välkommen, {name}'**
  String welcomeName(Object name);

  /// No description provided for @tabSend.
  ///
  /// In sv, this message translates to:
  /// **'Skicka'**
  String get tabSend;

  /// No description provided for @tabBuy.
  ///
  /// In sv, this message translates to:
  /// **'Köpa'**
  String get tabBuy;

  /// No description provided for @tabSell.
  ///
  /// In sv, this message translates to:
  /// **'Sälja'**
  String get tabSell;

  /// No description provided for @tabExchange.
  ///
  /// In sv, this message translates to:
  /// **'Växla'**
  String get tabExchange;

  /// No description provided for @comingSoon.
  ///
  /// In sv, this message translates to:
  /// **'{section} – innehåll kommer senare'**
  String comingSoon(Object section);

  /// No description provided for @noTransactionsYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga transaktioner ännu'**
  String get noTransactionsYet;

  /// No description provided for @transaction.
  ///
  /// In sv, this message translates to:
  /// **'Transaktion'**
  String get transaction;

  /// No description provided for @transactions.
  ///
  /// In sv, this message translates to:
  /// **'Transaktioner'**
  String get transactions;

  /// No description provided for @youSend.
  ///
  /// In sv, this message translates to:
  /// **'Du skickar: {amount} {currency}'**
  String youSend(Object amount, Object currency);

  /// No description provided for @exchangeRateValue.
  ///
  /// In sv, this message translates to:
  /// **'Växelkurs: 1 {from} = {rate} {to}'**
  String exchangeRateValue(Object from, Object rate, Object to);

  /// No description provided for @grossReceived.
  ///
  /// In sv, this message translates to:
  /// **'Brutto mottaget: {amount} {currency}'**
  String grossReceived(Object amount, Object currency);

  /// No description provided for @feeValue.
  ///
  /// In sv, this message translates to:
  /// **'Avgift: {percent}% ({feeFrom} {from} ≈ {feeTo} {to})'**
  String feeValue(
    Object percent,
    Object feeFrom,
    Object from,
    Object feeTo,
    Object to,
  );

  /// No description provided for @youReceive.
  ///
  /// In sv, this message translates to:
  /// **'Du får ut: {amount} {currency}'**
  String youReceive(Object amount, Object currency);

  /// No description provided for @paymentTo.
  ///
  /// In sv, this message translates to:
  /// **'Betalning till: {label}'**
  String paymentTo(Object label);

  /// No description provided for @payAmountTo.
  ///
  /// In sv, this message translates to:
  /// **'Betala {amount} {currency} till:'**
  String payAmountTo(Object amount, Object currency);

  /// No description provided for @acceptedWaitingPayment.
  ///
  /// In sv, this message translates to:
  /// **'Du har accepterat. Managern skickar betalningsuppgifter inom kort.'**
  String get acceptedWaitingPayment;

  /// No description provided for @accept.
  ///
  /// In sv, this message translates to:
  /// **'Acceptera'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In sv, this message translates to:
  /// **'Avböj'**
  String get reject;

  /// No description provided for @waitingForProposal.
  ///
  /// In sv, this message translates to:
  /// **'Väntar på att managern ska skicka ett förslag.'**
  String get waitingForProposal;

  /// No description provided for @noSignedInUser.
  ///
  /// In sv, this message translates to:
  /// **'Ingen inloggad användare.'**
  String get noSignedInUser;

  /// No description provided for @couldNotLoadCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte ladda kund: {error}'**
  String couldNotLoadCustomer(Object error);

  /// No description provided for @managerStatusRequested.
  ///
  /// In sv, this message translates to:
  /// **'Ny förfrågan från kund'**
  String get managerStatusRequested;

  /// No description provided for @managerStatusProposed.
  ///
  /// In sv, this message translates to:
  /// **'Förslag skickat – väntar på kund'**
  String get managerStatusProposed;

  /// No description provided for @managerStatusAccepted.
  ///
  /// In sv, this message translates to:
  /// **'Kund har accepterat förslaget'**
  String get managerStatusAccepted;

  /// No description provided for @managerStatusRejected.
  ///
  /// In sv, this message translates to:
  /// **'Kund avbröt transaktionen'**
  String get managerStatusRejected;

  /// No description provided for @unknownClient.
  ///
  /// In sv, this message translates to:
  /// **'Okänd klient'**
  String get unknownClient;

  /// No description provided for @authWrongCredentials.
  ///
  /// In sv, this message translates to:
  /// **'Fel e-post eller lösenord.'**
  String get authWrongCredentials;

  /// No description provided for @authInvalidEmail.
  ///
  /// In sv, this message translates to:
  /// **'Ogiltig e-postadress.'**
  String get authInvalidEmail;

  /// No description provided for @authEmailInUse.
  ///
  /// In sv, this message translates to:
  /// **'Det finns redan ett konto med den här e-postadressen.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In sv, this message translates to:
  /// **'Lösenordet är för svagt.'**
  String get authWeakPassword;

  /// No description provided for @authMissingEmail.
  ///
  /// In sv, this message translates to:
  /// **'Ange din e-postadress först.'**
  String get authMissingEmail;

  /// No description provided for @authTooManyRequests.
  ///
  /// In sv, this message translates to:
  /// **'För många försök. Vänta en stund och försök igen.'**
  String get authTooManyRequests;

  /// No description provided for @authNetworkError.
  ///
  /// In sv, this message translates to:
  /// **'Ingen anslutning. Kontrollera internet och försök igen.'**
  String get authNetworkError;

  /// No description provided for @authUserDisabled.
  ///
  /// In sv, this message translates to:
  /// **'Kontot är avstängt.'**
  String get authUserDisabled;

  /// No description provided for @loginTagline.
  ///
  /// In sv, this message translates to:
  /// **'VALUTAVÄXLING'**
  String get loginTagline;

  /// No description provided for @login.
  ///
  /// In sv, this message translates to:
  /// **'Logga in'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Ange dina uppgifter för att fortsätta'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In sv, this message translates to:
  /// **'E-post'**
  String get email;

  /// No description provided for @password.
  ///
  /// In sv, this message translates to:
  /// **'Lösenord'**
  String get password;

  /// No description provided for @resetLinkSent.
  ///
  /// In sv, this message translates to:
  /// **'Återställningslänk har skickats till din e-post.'**
  String get resetLinkSent;

  /// No description provided for @forgotPassword.
  ///
  /// In sv, this message translates to:
  /// **'Glömt lösenord?'**
  String get forgotPassword;

  /// No description provided for @registerAccount.
  ///
  /// In sv, this message translates to:
  /// **'Registrera konto'**
  String get registerAccount;

  /// No description provided for @registerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Registrera dig som kund'**
  String get registerTitle;

  /// No description provided for @firstName.
  ///
  /// In sv, this message translates to:
  /// **'Förnamn'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In sv, this message translates to:
  /// **'Efternamn'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In sv, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @enterFirstName.
  ///
  /// In sv, this message translates to:
  /// **'Ange förnamn'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In sv, this message translates to:
  /// **'Ange efternamn'**
  String get enterLastName;

  /// No description provided for @enterValidEmail.
  ///
  /// In sv, this message translates to:
  /// **'Ange giltig e-post'**
  String get enterValidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In sv, this message translates to:
  /// **'Minst 6 tecken'**
  String get passwordMinLength;

  /// No description provided for @register.
  ///
  /// In sv, this message translates to:
  /// **'Registrera'**
  String get register;

  /// No description provided for @couldNotCreateCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte skapa kund: {error}'**
  String couldNotCreateCustomer(Object error);

  /// No description provided for @clientIdMustBeInteger.
  ///
  /// In sv, this message translates to:
  /// **'Klient-ID måste vara ett heltal'**
  String get clientIdMustBeInteger;

  /// No description provided for @customerSaved.
  ///
  /// In sv, this message translates to:
  /// **'Kund sparad!'**
  String get customerSaved;

  /// No description provided for @createUpdateCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Skapa / uppdatera kund'**
  String get createUpdateCustomer;

  /// No description provided for @clientIdOptional.
  ///
  /// In sv, this message translates to:
  /// **'Klient-ID (valfritt)'**
  String get clientIdOptional;

  /// No description provided for @clientIdHint.
  ///
  /// In sv, this message translates to:
  /// **'t.ex. 007'**
  String get clientIdHint;

  /// No description provided for @saveCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Spara kund'**
  String get saveCustomer;

  /// No description provided for @office.
  ///
  /// In sv, this message translates to:
  /// **'Kontor'**
  String get office;

  /// No description provided for @couldNotLoadOffices.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte ladda kontor: {error}'**
  String couldNotLoadOffices(Object error);

  /// No description provided for @fillAllFieldsValidAmount.
  ///
  /// In sv, this message translates to:
  /// **'Fyll i alla fält med ett giltigt belopp'**
  String get fillAllFieldsValidAmount;

  /// No description provided for @noCustomerProfile.
  ///
  /// In sv, this message translates to:
  /// **'Hittar ingen kundprofil för den här användaren'**
  String get noCustomerProfile;

  /// No description provided for @requestSentToOffice.
  ///
  /// In sv, this message translates to:
  /// **'Begäran skickad till kontoret'**
  String get requestSentToOffice;

  /// No description provided for @couldNotCreateTransaction.
  ///
  /// In sv, this message translates to:
  /// **'Fel vid skapande av transaktion: {error}'**
  String couldNotCreateTransaction(Object error);

  /// No description provided for @noOfficesAvailable.
  ///
  /// In sv, this message translates to:
  /// **'Det finns inga kontor att skicka via just nu.'**
  String get noOfficesAvailable;

  /// No description provided for @currencyYouSend.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du skickar'**
  String get currencyYouSend;

  /// No description provided for @chooseOfficeFirstCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Välj kontor (välj valuta först)'**
  String get chooseOfficeFirstCurrency;

  /// No description provided for @officesHandlingCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Kontor som hanterar {currency}'**
  String officesHandlingCurrency(Object currency);

  /// No description provided for @currencyRecipientGets.
  ///
  /// In sv, this message translates to:
  /// **'Valuta mottagaren tar emot'**
  String get currencyRecipientGets;

  /// No description provided for @amountToSend.
  ///
  /// In sv, this message translates to:
  /// **'Belopp att skicka'**
  String get amountToSend;

  /// No description provided for @send.
  ///
  /// In sv, this message translates to:
  /// **'Skicka'**
  String get send;

  /// No description provided for @managerCreated.
  ///
  /// In sv, this message translates to:
  /// **'Manager skapad.'**
  String get managerCreated;

  /// No description provided for @couldNotCreateManager.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte skapa manager: {error}'**
  String couldNotCreateManager(Object error);

  /// No description provided for @unexpectedError.
  ///
  /// In sv, this message translates to:
  /// **'Oväntat fel: {error}'**
  String unexpectedError(Object error);

  /// No description provided for @createOfficeBeforeManager.
  ///
  /// In sv, this message translates to:
  /// **'Skapa minst ett kontor innan du lägger till manager.'**
  String get createOfficeBeforeManager;

  /// No description provided for @createNewManager.
  ///
  /// In sv, this message translates to:
  /// **'Skapa ny manager'**
  String get createNewManager;

  /// No description provided for @enterEmail.
  ///
  /// In sv, this message translates to:
  /// **'Ange e-post'**
  String get enterEmail;

  /// No description provided for @createManager.
  ///
  /// In sv, this message translates to:
  /// **'Skapa manager'**
  String get createManager;

  /// No description provided for @couldNotLoadOfficeCurrencies.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte läsa kontorets valutor: {error}'**
  String couldNotLoadOfficeCurrencies(Object error);

  /// No description provided for @enterCustomerName.
  ///
  /// In sv, this message translates to:
  /// **'Ange kundens namn.'**
  String get enterCustomerName;

  /// No description provided for @chooseTwoDifferentCurrencies.
  ///
  /// In sv, this message translates to:
  /// **'Välj två olika valutor.'**
  String get chooseTwoDifferentCurrencies;

  /// No description provided for @enterAmountAboveZero.
  ///
  /// In sv, this message translates to:
  /// **'Ange ett belopp större än 0.'**
  String get enterAmountAboveZero;

  /// No description provided for @enterFeeRange.
  ///
  /// In sv, this message translates to:
  /// **'Ange en avgift mellan 0 och 100 %.'**
  String get enterFeeRange;

  /// No description provided for @createNewTransaction.
  ///
  /// In sv, this message translates to:
  /// **'Skapa ny transaktion'**
  String get createNewTransaction;

  /// No description provided for @customerName.
  ///
  /// In sv, this message translates to:
  /// **'Kundens namn'**
  String get customerName;

  /// No description provided for @phoneOptional.
  ///
  /// In sv, this message translates to:
  /// **'Telefon (valfritt)'**
  String get phoneOptional;

  /// No description provided for @customerGivesCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Kunden lämnar (valuta)'**
  String get customerGivesCurrency;

  /// No description provided for @customerGetsCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Kunden får (valuta)'**
  String get customerGetsCurrency;

  /// No description provided for @amountCustomerGives.
  ///
  /// In sv, this message translates to:
  /// **'Belopp som kunden lämnar'**
  String get amountCustomerGives;

  /// No description provided for @feePercentLabel.
  ///
  /// In sv, this message translates to:
  /// **'Avgift (%)'**
  String get feePercentLabel;

  /// No description provided for @creating.
  ///
  /// In sv, this message translates to:
  /// **'Skapar …'**
  String get creating;

  /// No description provided for @createTransaction.
  ///
  /// In sv, this message translates to:
  /// **'Skapa transaktion'**
  String get createTransaction;

  /// No description provided for @chooseAtLeastOneCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Välj minst en valuta'**
  String get chooseAtLeastOneCurrency;

  /// No description provided for @country.
  ///
  /// In sv, this message translates to:
  /// **'Land'**
  String get country;

  /// No description provided for @city.
  ///
  /// In sv, this message translates to:
  /// **'Stad'**
  String get city;

  /// No description provided for @enterCountry.
  ///
  /// In sv, this message translates to:
  /// **'Ange land'**
  String get enterCountry;

  /// No description provided for @enterCity.
  ///
  /// In sv, this message translates to:
  /// **'Ange stad'**
  String get enterCity;

  /// No description provided for @currencies.
  ///
  /// In sv, this message translates to:
  /// **'Valutor'**
  String get currencies;

  /// No description provided for @paymentMethods.
  ///
  /// In sv, this message translates to:
  /// **'Betalningsmetoder'**
  String get paymentMethods;

  /// No description provided for @add.
  ///
  /// In sv, this message translates to:
  /// **'Lägg till'**
  String get add;

  /// No description provided for @noPaymentMethodsYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga betalningsmetoder ännu. Tryck \"Lägg till\" för att lägga till.'**
  String get noPaymentMethodsYet;

  /// No description provided for @createOffice.
  ///
  /// In sv, this message translates to:
  /// **'Skapa kontor'**
  String get createOffice;

  /// No description provided for @methodNumber.
  ///
  /// In sv, this message translates to:
  /// **'Metod {number}'**
  String methodNumber(Object number);

  /// No description provided for @removeMethod.
  ///
  /// In sv, this message translates to:
  /// **'Ta bort metod'**
  String get removeMethod;

  /// No description provided for @methodName.
  ///
  /// In sv, this message translates to:
  /// **'Namn på metod'**
  String get methodName;

  /// No description provided for @methodNameHint.
  ///
  /// In sv, this message translates to:
  /// **'t.ex. SEB SEK-konto, USDT TRC20'**
  String get methodNameHint;

  /// No description provided for @methodDetails.
  ///
  /// In sv, this message translates to:
  /// **'Detaljer (kontonummer, IBAN, wallet-adress etc.)'**
  String get methodDetails;

  /// No description provided for @methodDetailsHint.
  ///
  /// In sv, this message translates to:
  /// **'t.ex. IBAN: SE12 3456...'**
  String get methodDetailsHint;

  /// No description provided for @supportsCurrencies.
  ///
  /// In sv, this message translates to:
  /// **'Stödjer valutor'**
  String get supportsCurrencies;

  /// No description provided for @managerAppBarTitle.
  ///
  /// In sv, this message translates to:
  /// **'CRM – Manager'**
  String get managerAppBarTitle;

  /// No description provided for @managerAppBarTitleWithOffice.
  ///
  /// In sv, this message translates to:
  /// **'CRM – Manager ({office})'**
  String managerAppBarTitleWithOffice(Object office);

  /// No description provided for @managerPanel.
  ///
  /// In sv, this message translates to:
  /// **'Manager-panel'**
  String get managerPanel;

  /// No description provided for @managerPanelIntro.
  ///
  /// In sv, this message translates to:
  /// **'Välj vad du vill arbeta med. Här ser du snabbt nya, pågående och färdiga transaktioner.'**
  String get managerPanelIntro;

  /// No description provided for @createTransactionCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Registrera en kund som kommer in på kontoret och saknar konto.'**
  String get createTransactionCardSubtitle;

  /// No description provided for @newCustomerTransactions.
  ///
  /// In sv, this message translates to:
  /// **'Nya kundtransaktioner'**
  String get newCustomerTransactions;

  /// No description provided for @newCustomerTransactionsSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Se nya beställningar från kunder som ännu inte har påbörjats.'**
  String get newCustomerTransactionsSubtitle;

  /// No description provided for @ongoingTransactions.
  ///
  /// In sv, this message translates to:
  /// **'Pågående transaktioner'**
  String get ongoingTransactions;

  /// No description provided for @ongoingTransactionsSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Förslag som väntar på kund samt accepterade ärenden som ska betalas och genomföras.'**
  String get ongoingTransactionsSubtitle;

  /// No description provided for @finishedTransactions.
  ///
  /// In sv, this message translates to:
  /// **'Färdiga transaktioner'**
  String get finishedTransactions;

  /// No description provided for @finishedTransactionsSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Genomförda och avböjda transaktioner.'**
  String get finishedTransactionsSubtitle;

  /// No description provided for @calculationError.
  ///
  /// In sv, this message translates to:
  /// **'Fel vid beräkning: {error}'**
  String calculationError(Object error);

  /// No description provided for @paymentDetailsSent.
  ///
  /// In sv, this message translates to:
  /// **'Betalningsuppgifter skickade till kunden.'**
  String get paymentDetailsSent;

  /// No description provided for @insufficientBalance.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret har för lågt saldo i {currency} ({available} finns, {needed} behövs). Be admin fylla på saldo.'**
  String insufficientBalance(Object currency, Object available, Object needed);

  /// No description provided for @transactionManager.
  ///
  /// In sv, this message translates to:
  /// **'Transaktion (manager)'**
  String get transactionManager;

  /// No description provided for @customerSends.
  ///
  /// In sv, this message translates to:
  /// **'Kund skickar: {amount} {currency}'**
  String customerSends(Object amount, Object currency);

  /// No description provided for @toCurrencyValue.
  ///
  /// In sv, this message translates to:
  /// **'Till valuta: {currency}'**
  String toCurrencyValue(Object currency);

  /// No description provided for @customerReceives.
  ///
  /// In sv, this message translates to:
  /// **'Kunden får ut: {amount} {currency}'**
  String customerReceives(Object amount, Object currency);

  /// No description provided for @calculating.
  ///
  /// In sv, this message translates to:
  /// **'Beräknar...'**
  String get calculating;

  /// No description provided for @paymentMethodValue.
  ///
  /// In sv, this message translates to:
  /// **'Betalningsmetod: {label}'**
  String paymentMethodValue(Object label);

  /// No description provided for @officeNotFound.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret hittades inte.'**
  String get officeNotFound;

  /// No description provided for @noPaymentMethodsForCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Inga betalningsmetoder för den här valutan.'**
  String get noPaymentMethodsForCurrency;

  /// No description provided for @choosePaymentMethodForCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Välj betalningsmetod att skicka till kund:'**
  String get choosePaymentMethodForCustomer;

  /// No description provided for @proposeTerms.
  ///
  /// In sv, this message translates to:
  /// **'Föreslå villkor'**
  String get proposeTerms;

  /// No description provided for @sentToCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Skickat till kund: {label}'**
  String sentToCustomer(Object label);

  /// No description provided for @resendPaymentDetails.
  ///
  /// In sv, this message translates to:
  /// **'Skicka om betalningsuppgifter'**
  String get resendPaymentDetails;

  /// No description provided for @sendPaymentDetailsToCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Skicka betalningsuppgifter till kund'**
  String get sendPaymentDetailsToCustomer;

  /// No description provided for @markAsCompleted.
  ///
  /// In sv, this message translates to:
  /// **'Markera som genomförd'**
  String get markAsCompleted;

  /// No description provided for @noOfficesYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga kontor skapade ännu.'**
  String get noOfficesYet;

  /// No description provided for @searchCountryOrCity.
  ///
  /// In sv, this message translates to:
  /// **'Sök på land eller stad...'**
  String get searchCountryOrCity;

  /// No description provided for @officesFound.
  ///
  /// In sv, this message translates to:
  /// **'{count, plural, =1{1 kontor hittat} other{{count} kontor hittade}}'**
  String officesFound(int count);

  /// No description provided for @noOfficesMatch.
  ///
  /// In sv, this message translates to:
  /// **'Inga kontor matchar sökningen.'**
  String get noOfficesMatch;

  /// No description provided for @balanceValue.
  ///
  /// In sv, this message translates to:
  /// **'Saldo: {balances}'**
  String balanceValue(Object balances);

  /// No description provided for @managerLoading.
  ///
  /// In sv, this message translates to:
  /// **'Manager: laddar …'**
  String get managerLoading;

  /// No description provided for @managerNone.
  ///
  /// In sv, this message translates to:
  /// **'Manager: –'**
  String get managerNone;

  /// No description provided for @managerValue.
  ///
  /// In sv, this message translates to:
  /// **'Manager: {name}'**
  String managerValue(Object name);

  /// No description provided for @managerUnknown.
  ///
  /// In sv, this message translates to:
  /// **'Manager: (okänd)'**
  String get managerUnknown;

  /// No description provided for @editOffice.
  ///
  /// In sv, this message translates to:
  /// **'Ändra kontor'**
  String get editOffice;

  /// No description provided for @topUpBalance.
  ///
  /// In sv, this message translates to:
  /// **'Fyll på saldo'**
  String get topUpBalance;

  /// No description provided for @deleteOffice.
  ///
  /// In sv, this message translates to:
  /// **'Radera kontor'**
  String get deleteOffice;

  /// No description provided for @noCustomerWithClientId.
  ///
  /// In sv, this message translates to:
  /// **'Ingen kund hittades med klient-ID {clientId}'**
  String noCustomerWithClientId(Object clientId);

  /// No description provided for @editCustomerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Redigera kund #{clientId}'**
  String editCustomerTitle(Object clientId);

  /// No description provided for @customerUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Kund uppdaterad!'**
  String get customerUpdated;

  /// No description provided for @save.
  ///
  /// In sv, this message translates to:
  /// **'Spara'**
  String get save;

  /// No description provided for @customerDeleted.
  ///
  /// In sv, this message translates to:
  /// **'Kund borttagen.'**
  String get customerDeleted;

  /// No description provided for @searchClientId.
  ///
  /// In sv, this message translates to:
  /// **'Sök klient-ID'**
  String get searchClientId;

  /// No description provided for @search.
  ///
  /// In sv, this message translates to:
  /// **'Sök'**
  String get search;

  /// No description provided for @customerNumber.
  ///
  /// In sv, this message translates to:
  /// **'Kund #{clientId}'**
  String customerNumber(Object clientId);

  /// No description provided for @edit.
  ///
  /// In sv, this message translates to:
  /// **'Redigera'**
  String get edit;

  /// No description provided for @nameValue.
  ///
  /// In sv, this message translates to:
  /// **'Namn: {name}'**
  String nameValue(Object name);

  /// No description provided for @officeUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Kontor uppdaterat!'**
  String get officeUpdated;

  /// No description provided for @editOfficeTitle.
  ///
  /// In sv, this message translates to:
  /// **'Redigera kontor'**
  String get editOfficeTitle;

  /// No description provided for @methodIdLabel.
  ///
  /// In sv, this message translates to:
  /// **'ID (t.ex. usdt-trc20)'**
  String get methodIdLabel;

  /// No description provided for @name.
  ///
  /// In sv, this message translates to:
  /// **'Namn'**
  String get name;

  /// No description provided for @methodDetailsShort.
  ///
  /// In sv, this message translates to:
  /// **'Detaljer (IBAN, wallet etc.)'**
  String get methodDetailsShort;

  /// No description provided for @supportedFromCurrency.
  ///
  /// In sv, this message translates to:
  /// **'Stöds för valuta (fromCurrency)'**
  String get supportedFromCurrency;

  /// No description provided for @saveChanges.
  ///
  /// In sv, this message translates to:
  /// **'Spara ändringar'**
  String get saveChanges;

  /// No description provided for @officeCreated.
  ///
  /// In sv, this message translates to:
  /// **'Kontor skapat!'**
  String get officeCreated;

  /// No description provided for @deleteOfficeQuestion.
  ///
  /// In sv, this message translates to:
  /// **'Radera kontor?'**
  String get deleteOfficeQuestion;

  /// No description provided for @deleteOfficeConfirm.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret tas bort permanent. Är du säker?'**
  String get deleteOfficeConfirm;

  /// No description provided for @deleteAction.
  ///
  /// In sv, this message translates to:
  /// **'Radera'**
  String get deleteAction;

  /// No description provided for @officeDeleted.
  ///
  /// In sv, this message translates to:
  /// **'Kontor raderat'**
  String get officeDeleted;

  /// No description provided for @deleteError.
  ///
  /// In sv, this message translates to:
  /// **'Fel vid radering: {error}'**
  String deleteError(Object error);

  /// No description provided for @startBalance.
  ///
  /// In sv, this message translates to:
  /// **'Startsaldo {currency}'**
  String startBalance(Object currency);

  /// No description provided for @assignManager.
  ///
  /// In sv, this message translates to:
  /// **'Tilldela manager'**
  String get assignManager;

  /// No description provided for @noManagersYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga managers registrerade ännu.'**
  String get noManagersYet;

  /// No description provided for @manager.
  ///
  /// In sv, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @noPaymentMethodsAdded.
  ///
  /// In sv, this message translates to:
  /// **'Inga betalningsmetoder tillagda ännu.'**
  String get noPaymentMethodsAdded;

  /// No description provided for @searchManageOffices.
  ///
  /// In sv, this message translates to:
  /// **'Sök & hantera kontor'**
  String get searchManageOffices;

  /// No description provided for @noOfficesFound.
  ///
  /// In sv, this message translates to:
  /// **'Inga kontor hittades.'**
  String get noOfficesFound;

  /// No description provided for @officeSummary.
  ///
  /// In sv, this message translates to:
  /// **'Valutor: {currencies}\n{count, plural, =1{1 betalningsmetod} other{{count} betalningsmetoder}}'**
  String officeSummary(Object currencies, int count);

  /// No description provided for @exportDate.
  ///
  /// In sv, this message translates to:
  /// **'Datum'**
  String get exportDate;

  /// No description provided for @exportStatus.
  ///
  /// In sv, this message translates to:
  /// **'Status'**
  String get exportStatus;

  /// No description provided for @exportClientId.
  ///
  /// In sv, this message translates to:
  /// **'Klient-ID'**
  String get exportClientId;

  /// No description provided for @exportOffice.
  ///
  /// In sv, this message translates to:
  /// **'Kontor'**
  String get exportOffice;

  /// No description provided for @exportFrom.
  ///
  /// In sv, this message translates to:
  /// **'Från'**
  String get exportFrom;

  /// No description provided for @exportTo.
  ///
  /// In sv, this message translates to:
  /// **'Till'**
  String get exportTo;

  /// No description provided for @exportAmount.
  ///
  /// In sv, this message translates to:
  /// **'Belopp'**
  String get exportAmount;

  /// No description provided for @exportFee.
  ///
  /// In sv, this message translates to:
  /// **'Avgift'**
  String get exportFee;

  /// No description provided for @exportPayout.
  ///
  /// In sv, this message translates to:
  /// **'Utbetalas'**
  String get exportPayout;

  /// No description provided for @noTransactionsToExport.
  ///
  /// In sv, this message translates to:
  /// **'Inga transaktioner att exportera'**
  String get noTransactionsToExport;

  /// No description provided for @orderReport.
  ///
  /// In sv, this message translates to:
  /// **'Orderrapport'**
  String get orderReport;

  /// No description provided for @adminAppBarTitle.
  ///
  /// In sv, this message translates to:
  /// **'CRM – Admin'**
  String get adminAppBarTitle;

  /// No description provided for @adminHeadline.
  ///
  /// In sv, this message translates to:
  /// **'Adminvy: Full kontroll'**
  String get adminHeadline;

  /// No description provided for @manageOffices.
  ///
  /// In sv, this message translates to:
  /// **'Hantera kontor'**
  String get manageOffices;

  /// No description provided for @officeHasNoCurrencies.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret har inga valutor. Lägg till en valuta via Ändra kontor först.'**
  String get officeHasNoCurrencies;

  /// No description provided for @currency.
  ///
  /// In sv, this message translates to:
  /// **'Valuta'**
  String get currency;

  /// No description provided for @amount.
  ///
  /// In sv, this message translates to:
  /// **'Belopp'**
  String get amount;

  /// No description provided for @ok.
  ///
  /// In sv, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @orderHistory.
  ///
  /// In sv, this message translates to:
  /// **'Orderhistorik'**
  String get orderHistory;

  /// No description provided for @filterByOffice.
  ///
  /// In sv, this message translates to:
  /// **'Filtrera på kontor (valfritt)'**
  String get filterByOffice;

  /// No description provided for @allOffices.
  ///
  /// In sv, this message translates to:
  /// **'Alla kontor'**
  String get allOffices;

  /// No description provided for @chooseDateRange.
  ///
  /// In sv, this message translates to:
  /// **'Välj datumintervall'**
  String get chooseDateRange;

  /// No description provided for @clearDates.
  ///
  /// In sv, this message translates to:
  /// **'Rensa datum'**
  String get clearDates;

  /// No description provided for @exportCsv.
  ///
  /// In sv, this message translates to:
  /// **'Exportera CSV'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In sv, this message translates to:
  /// **'Exportera PDF'**
  String get exportPdf;

  /// No description provided for @chooseDateRangeHint.
  ///
  /// In sv, this message translates to:
  /// **'Välj ett datumintervall för att visa transaktioner.'**
  String get chooseDateRangeHint;

  /// No description provided for @clientShort.
  ///
  /// In sv, this message translates to:
  /// **'Klient {clientId}'**
  String clientShort(Object clientId);

  /// No description provided for @rateMissingApiKey.
  ///
  /// In sv, this message translates to:
  /// **'API-nyckel för valutakurser saknas. Bygg appen med --dart-define-from-file=fx_key.json.'**
  String get rateMissingApiKey;

  /// No description provided for @rateHttpError.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte hämta växelkurs (HTTP {code}).'**
  String rateHttpError(Object code);

  /// No description provided for @rateNotFound.
  ///
  /// In sv, this message translates to:
  /// **'Ingen kurs hittades för {from} → {to}.'**
  String rateNotFound(Object from, Object to);

  /// No description provided for @customers.
  ///
  /// In sv, this message translates to:
  /// **'Kunder'**
  String get customers;

  /// No description provided for @offices.
  ///
  /// In sv, this message translates to:
  /// **'Kontor'**
  String get offices;

  /// No description provided for @managers.
  ///
  /// In sv, this message translates to:
  /// **'Managers'**
  String get managers;

  /// No description provided for @adminPanel.
  ///
  /// In sv, this message translates to:
  /// **'Admin-panel'**
  String get adminPanel;

  /// No description provided for @adminPanelIntro.
  ///
  /// In sv, this message translates to:
  /// **'Välj vad du vill hantera. Siffran på varje kort visar hur många det finns.'**
  String get adminPanelIntro;

  /// No description provided for @customersCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skapa, sök, ändra och ta bort kunder.'**
  String get customersCardSubtitle;

  /// No description provided for @officesCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skapa kontor, ändra valutor och betalningsmetoder och fyll på saldon.'**
  String get officesCardSubtitle;

  /// No description provided for @managersCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skapa managers och se vilket kontor de arbetar på.'**
  String get managersCardSubtitle;

  /// No description provided for @ordersCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Alla transaktioner med filter, vinstrapport och export till CSV/PDF.'**
  String get ordersCardSubtitle;

  /// No description provided for @existingManagers.
  ///
  /// In sv, this message translates to:
  /// **'Befintliga managers'**
  String get existingManagers;

  /// No description provided for @noOfficeAssigned.
  ///
  /// In sv, this message translates to:
  /// **'Inget kontor'**
  String get noOfficeAssigned;

  /// No description provided for @officeValue.
  ///
  /// In sv, this message translates to:
  /// **'Kontor: {office}'**
  String officeValue(Object office);

  /// No description provided for @searchCustomers.
  ///
  /// In sv, this message translates to:
  /// **'Sök kund'**
  String get searchCustomers;

  /// No description provided for @searchCustomersLabel.
  ///
  /// In sv, this message translates to:
  /// **'Klient-ID, namn, telefon, land eller stad'**
  String get searchCustomersLabel;

  /// No description provided for @searchCustomersHint.
  ///
  /// In sv, this message translates to:
  /// **'t.ex. 00, Ali, 0731, Grozny'**
  String get searchCustomersHint;

  /// No description provided for @clearSearch.
  ///
  /// In sv, this message translates to:
  /// **'Rensa sökning'**
  String get clearSearch;

  /// No description provided for @customersShown.
  ///
  /// In sv, this message translates to:
  /// **'Visar {shown} av {total} kunder'**
  String customersShown(int shown, int total);

  /// No description provided for @noCustomersMatch.
  ///
  /// In sv, this message translates to:
  /// **'Inga kunder matchar sökningen.'**
  String get noCustomersMatch;

  /// No description provided for @placesValue.
  ///
  /// In sv, this message translates to:
  /// **'Kontor: {places}'**
  String placesValue(Object places);

  /// No description provided for @typeToSearchCustomers.
  ///
  /// In sv, this message translates to:
  /// **'{total, plural, =1{Skriv i sökrutan för att visa kunder (1 kund totalt).} other{Skriv i sökrutan för att visa kunder ({total} kunder totalt).}}'**
  String typeToSearchCustomers(int total);

  /// No description provided for @customersShownLimited.
  ///
  /// In sv, this message translates to:
  /// **'Visar de första {shown} av {count} träffar. Skriv mer för att begränsa.'**
  String customersShownLimited(int shown, int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'sv', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
