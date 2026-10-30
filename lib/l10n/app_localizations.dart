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

  /// No description provided for @typeToSearch.
  ///
  /// In sv, this message translates to:
  /// **'{total, plural, =1{Skriv i sökrutan för att visa träffar (1 totalt).} other{Skriv i sökrutan för att visa träffar ({total} totalt).}}'**
  String typeToSearch(int total);

  /// No description provided for @noSearchMatches.
  ///
  /// In sv, this message translates to:
  /// **'Inga träffar.'**
  String get noSearchMatches;

  /// No description provided for @searchMatches.
  ///
  /// In sv, this message translates to:
  /// **'{count, plural, =1{1 träff} other{{count} träffar}}'**
  String searchMatches(int count);

  /// No description provided for @searchOfficesLabel.
  ///
  /// In sv, this message translates to:
  /// **'Sök på land, stad eller valuta'**
  String get searchOfficesLabel;

  /// No description provided for @searchManagersLabel.
  ///
  /// In sv, this message translates to:
  /// **'Sök på namn, e-post, telefon eller kontor'**
  String get searchManagersLabel;

  /// No description provided for @searchTransactionsLabel.
  ///
  /// In sv, this message translates to:
  /// **'Nr, klient-ID, namn, telefon, kontor, valuta eller status'**
  String get searchTransactionsLabel;

  /// No description provided for @searchTransactionsHint.
  ///
  /// In sv, this message translates to:
  /// **'t.ex. T-00012, 00, Ali, Grozny, RUB'**
  String get searchTransactionsHint;

  /// No description provided for @searchOrChooseDatesHint.
  ///
  /// In sv, this message translates to:
  /// **'Skriv i sökrutan eller välj ett datumintervall för att visa transaktioner.'**
  String get searchOrChooseDatesHint;

  /// No description provided for @editManagerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Ändra manager'**
  String get editManagerTitle;

  /// No description provided for @managerUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Manager uppdaterad.'**
  String get managerUpdated;

  /// No description provided for @deleteManagerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Radera manager?'**
  String get deleteManagerTitle;

  /// No description provided for @deleteManagerConfirm.
  ///
  /// In sv, this message translates to:
  /// **'{name} kommer inte längre åt appen. Inloggningskontot finns kvar och kan tas bort under Authentication i Firebase-konsolen.'**
  String deleteManagerConfirm(Object name);

  /// No description provided for @managerDeleted.
  ///
  /// In sv, this message translates to:
  /// **'Manager raderad.'**
  String get managerDeleted;

  /// No description provided for @editTransactionTitle.
  ///
  /// In sv, this message translates to:
  /// **'Ändra transaktion'**
  String get editTransactionTitle;

  /// No description provided for @statusChangeNoBalance.
  ///
  /// In sv, this message translates to:
  /// **'Att ändra status påverkar inte kontorets saldo.'**
  String get statusChangeNoBalance;

  /// No description provided for @transactionUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Transaktion uppdaterad.'**
  String get transactionUpdated;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In sv, this message translates to:
  /// **'Radera transaktion?'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In sv, this message translates to:
  /// **'Transaktionen tas bort permanent. Kontorets saldo ändras inte.'**
  String get deleteTransactionConfirm;

  /// No description provided for @customerPanel.
  ///
  /// In sv, this message translates to:
  /// **'Vad vill du göra?'**
  String get customerPanel;

  /// No description provided for @sendMoney.
  ///
  /// In sv, this message translates to:
  /// **'Skicka pengar'**
  String get sendMoney;

  /// No description provided for @sendMoneySubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Välj valuta och kontor och skicka en förfrågan.'**
  String get sendMoneySubtitle;

  /// No description provided for @myTransactionsSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Följ dina transaktioner och svara på förslag.'**
  String get myTransactionsSubtitle;

  /// No description provided for @offersWaiting.
  ///
  /// In sv, this message translates to:
  /// **'{count, plural, =1{1 förslag väntar på ditt svar.} other{{count} förslag väntar på ditt svar.}}'**
  String offersWaiting(int count);

  /// No description provided for @soonBadge.
  ///
  /// In sv, this message translates to:
  /// **'Snart'**
  String get soonBadge;

  /// No description provided for @statusCountered.
  ///
  /// In sv, this message translates to:
  /// **'Motförslag från kund'**
  String get statusCountered;

  /// No description provided for @customerStatusCountered.
  ///
  /// In sv, this message translates to:
  /// **'Motförslag skickat – väntar på manager'**
  String get customerStatusCountered;

  /// No description provided for @managerStatusCountered.
  ///
  /// In sv, this message translates to:
  /// **'Kunden har skickat ett motförslag'**
  String get managerStatusCountered;

  /// No description provided for @counterOffer.
  ///
  /// In sv, this message translates to:
  /// **'Motförslag'**
  String get counterOffer;

  /// No description provided for @counterOfferAlreadyUsed.
  ///
  /// In sv, this message translates to:
  /// **'Du har redan använt ditt motförslag för den här transaktionen.'**
  String get counterOfferAlreadyUsed;

  /// No description provided for @yourCounterOffer.
  ///
  /// In sv, this message translates to:
  /// **'Ditt motförslag: {fee}% avgift'**
  String yourCounterOffer(Object fee);

  /// No description provided for @waitingForManagerAnswer.
  ///
  /// In sv, this message translates to:
  /// **'Väntar på managerns svar.'**
  String get waitingForManagerAnswer;

  /// No description provided for @counterOfferIntro.
  ///
  /// In sv, this message translates to:
  /// **'Managern föreslår {fee}% i avgift. Vilken avgift föreslår du?'**
  String counterOfferIntro(Object fee);

  /// No description provided for @counterFeeLabel.
  ///
  /// In sv, this message translates to:
  /// **'Din avgift (%)'**
  String get counterFeeLabel;

  /// No description provided for @youWouldReceive.
  ///
  /// In sv, this message translates to:
  /// **'Du skulle få ut: {amount} {currency}'**
  String youWouldReceive(Object amount, Object currency);

  /// No description provided for @messageOptional.
  ///
  /// In sv, this message translates to:
  /// **'Meddelande (valfritt)'**
  String get messageOptional;

  /// No description provided for @counterOfferOnce.
  ///
  /// In sv, this message translates to:
  /// **'Du kan bara skicka ett motförslag per transaktion.'**
  String get counterOfferOnce;

  /// No description provided for @counterFeeMustBeLower.
  ///
  /// In sv, this message translates to:
  /// **'Ange en avgift från 0 och lägre än {fee}%.'**
  String counterFeeMustBeLower(Object fee);

  /// No description provided for @sendCounterOffer.
  ///
  /// In sv, this message translates to:
  /// **'Skicka motförslag'**
  String get sendCounterOffer;

  /// No description provided for @counterOfferSent.
  ///
  /// In sv, this message translates to:
  /// **'Motförslaget är skickat.'**
  String get counterOfferSent;

  /// No description provided for @customerCounterOffer.
  ///
  /// In sv, this message translates to:
  /// **'Kunden föreslår {counter}% i avgift i stället för {fee}%.'**
  String customerCounterOffer(Object counter, Object fee);

  /// No description provided for @counterOfferManagerHint.
  ///
  /// In sv, this message translates to:
  /// **'Acceptera kundens avgift, eller skicka ett nytt förslag. Kunden kan inte lägga fler motförslag.'**
  String get counterOfferManagerHint;

  /// No description provided for @acceptCounterOffer.
  ///
  /// In sv, this message translates to:
  /// **'Acceptera {fee}%'**
  String acceptCounterOffer(Object fee);

  /// No description provided for @sendNewProposal.
  ///
  /// In sv, this message translates to:
  /// **'Skicka nytt förslag'**
  String get sendNewProposal;

  /// No description provided for @counterOfferAccepted.
  ///
  /// In sv, this message translates to:
  /// **'Motförslaget är accepterat.'**
  String get counterOfferAccepted;

  /// No description provided for @transactionNoValue.
  ///
  /// In sv, this message translates to:
  /// **'Transaktion {no}'**
  String transactionNoValue(Object no);

  /// No description provided for @exportNo.
  ///
  /// In sv, this message translates to:
  /// **'Nr'**
  String get exportNo;

  /// No description provided for @statusPaid.
  ///
  /// In sv, this message translates to:
  /// **'Betald av kund'**
  String get statusPaid;

  /// No description provided for @statusPaymentConfirmed.
  ///
  /// In sv, this message translates to:
  /// **'Betalning bekräftad'**
  String get statusPaymentConfirmed;

  /// No description provided for @customerStatusPaid.
  ///
  /// In sv, this message translates to:
  /// **'Betalning skickad – managern kontrollerar'**
  String get customerStatusPaid;

  /// No description provided for @customerStatusPaymentConfirmed.
  ///
  /// In sv, this message translates to:
  /// **'Klar att hämta ut – se din kod'**
  String get customerStatusPaymentConfirmed;

  /// No description provided for @managerStatusPaid.
  ///
  /// In sv, this message translates to:
  /// **'Kunden har betalat – kontrollera betalningen'**
  String get managerStatusPaid;

  /// No description provided for @managerStatusPaymentConfirmed.
  ///
  /// In sv, this message translates to:
  /// **'Betalning bekräftad – väntar på uthämtning'**
  String get managerStatusPaymentConfirmed;

  /// No description provided for @readyForPickup.
  ///
  /// In sv, this message translates to:
  /// **'{count, plural, =1{1 transaktion är klar att hämta ut.} other{{count} transaktioner är klara att hämta ut.}}'**
  String readyForPickup(int count);

  /// No description provided for @iHavePaid.
  ///
  /// In sv, this message translates to:
  /// **'Jag har betalat'**
  String get iHavePaid;

  /// No description provided for @markPaidIntro.
  ///
  /// In sv, this message translates to:
  /// **'Bifoga gärna kvittot (bild eller PDF) så går det fortare för managern att kontrollera betalningen.'**
  String get markPaidIntro;

  /// No description provided for @attachReceipt.
  ///
  /// In sv, this message translates to:
  /// **'Bifoga kvitto'**
  String get attachReceipt;

  /// No description provided for @changeReceipt.
  ///
  /// In sv, this message translates to:
  /// **'Byt kvitto'**
  String get changeReceipt;

  /// No description provided for @receiptTooLarge.
  ///
  /// In sv, this message translates to:
  /// **'Filen är för stor (högst 10 MB).'**
  String get receiptTooLarge;

  /// No description provided for @confirmPaid.
  ///
  /// In sv, this message translates to:
  /// **'Skicka'**
  String get confirmPaid;

  /// No description provided for @markedAsPaidSent.
  ///
  /// In sv, this message translates to:
  /// **'Tack! Managern kontrollerar betalningen.'**
  String get markedAsPaidSent;

  /// No description provided for @markedAsPaid.
  ///
  /// In sv, this message translates to:
  /// **'Du har markerat som betalt'**
  String get markedAsPaid;

  /// No description provided for @managerCheckingPayment.
  ///
  /// In sv, this message translates to:
  /// **'Managern kontrollerar betalningen och bekräftar så snart den har kommit.'**
  String get managerCheckingPayment;

  /// No description provided for @showReceipt.
  ///
  /// In sv, this message translates to:
  /// **'Visa kvitto'**
  String get showReceipt;

  /// No description provided for @paymentMissingTitle.
  ///
  /// In sv, this message translates to:
  /// **'Betalningen har inte kommit'**
  String get paymentMissingTitle;

  /// No description provided for @paymentConfirmedTitle.
  ///
  /// In sv, this message translates to:
  /// **'Betalningen är bekräftad'**
  String get paymentConfirmedTitle;

  /// No description provided for @yourPickupCode.
  ///
  /// In sv, this message translates to:
  /// **'Din uthämtningskod'**
  String get yourPickupCode;

  /// No description provided for @pickupCodeInstructions.
  ///
  /// In sv, this message translates to:
  /// **'Visa koden på kontoret för att hämta ut {amount} {currency}. Dela den bara med den som ska hämta ut pengarna.'**
  String pickupCodeInstructions(Object amount, Object currency);

  /// No description provided for @paidOutTitle.
  ///
  /// In sv, this message translates to:
  /// **'Utbetald'**
  String get paidOutTitle;

  /// No description provided for @paidOutBody.
  ///
  /// In sv, this message translates to:
  /// **'Pengarna är uthämtade. Tack!'**
  String get paidOutBody;

  /// No description provided for @wrongPickupCode.
  ///
  /// In sv, this message translates to:
  /// **'Fel kod. Kontrollera koden som kunden visar.'**
  String get wrongPickupCode;

  /// No description provided for @paymentConfirmedSent.
  ///
  /// In sv, this message translates to:
  /// **'Betalningen är bekräftad och kunden har fått sin kod.'**
  String get paymentConfirmedSent;

  /// No description provided for @paymentMissing.
  ///
  /// In sv, this message translates to:
  /// **'Betalning saknas'**
  String get paymentMissing;

  /// No description provided for @paymentMissingDefault.
  ///
  /// In sv, this message translates to:
  /// **'Vi har inte fått din betalning ännu. Kontrollera betalningen och försök igen.'**
  String get paymentMissingDefault;

  /// No description provided for @messageToCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Meddelande till kunden'**
  String get messageToCustomer;

  /// No description provided for @confirmPayment.
  ///
  /// In sv, this message translates to:
  /// **'Bekräfta betalning'**
  String get confirmPayment;

  /// No description provided for @customerMarkedPaid.
  ///
  /// In sv, this message translates to:
  /// **'Kunden har markerat som betalt'**
  String get customerMarkedPaid;

  /// No description provided for @showReceiptNamed.
  ///
  /// In sv, this message translates to:
  /// **'Visa kvitto {name}'**
  String showReceiptNamed(Object name);

  /// No description provided for @noReceiptAttached.
  ///
  /// In sv, this message translates to:
  /// **'Inget kvitto bifogat.'**
  String get noReceiptAttached;

  /// No description provided for @paymentConfirmedManager.
  ///
  /// In sv, this message translates to:
  /// **'Betalningen är bekräftad'**
  String get paymentConfirmedManager;

  /// No description provided for @payoutInstructions.
  ///
  /// In sv, this message translates to:
  /// **'Betala ut {amount} {currency} när kunden visar sin uthämtningskod.'**
  String payoutInstructions(Object amount, Object currency);

  /// No description provided for @giveCodeToWalkIn.
  ///
  /// In sv, this message translates to:
  /// **'Kunden har inget konto. Ge kunden koden: {code}'**
  String giveCodeToWalkIn(Object code);

  /// No description provided for @customerPickupCode.
  ///
  /// In sv, this message translates to:
  /// **'Kundens uthämtningskod'**
  String get customerPickupCode;

  /// No description provided for @payOutAndComplete.
  ///
  /// In sv, this message translates to:
  /// **'Betala ut och markera som genomförd'**
  String get payOutAndComplete;

  /// No description provided for @showQrAtOffice.
  ///
  /// In sv, this message translates to:
  /// **'Visa QR-koden på kontoret'**
  String get showQrAtOffice;

  /// No description provided for @orUseCode.
  ///
  /// In sv, this message translates to:
  /// **'Eller uppge koden'**
  String get orUseCode;

  /// No description provided for @scanCustomerQr.
  ///
  /// In sv, this message translates to:
  /// **'Skanna kundens QR-kod'**
  String get scanCustomerQr;

  /// No description provided for @enterCodeInstead.
  ///
  /// In sv, this message translates to:
  /// **'Skriv in koden i stället'**
  String get enterCodeInstead;

  /// No description provided for @payOutWithCode.
  ///
  /// In sv, this message translates to:
  /// **'Betala ut med kod'**
  String get payOutWithCode;

  /// No description provided for @qrDoesNotMatch.
  ///
  /// In sv, this message translates to:
  /// **'QR-koden stämmer inte för den här transaktionen.'**
  String get qrDoesNotMatch;

  /// No description provided for @qrVerified.
  ///
  /// In sv, this message translates to:
  /// **'QR-koden stämmer'**
  String get qrVerified;

  /// No description provided for @payOutAmount.
  ///
  /// In sv, this message translates to:
  /// **'Betala ut {amount} {currency}'**
  String payOutAmount(Object amount, Object currency);

  /// No description provided for @checkIdHint.
  ///
  /// In sv, this message translates to:
  /// **'Kontrollera kundens legitimation innan du betalar ut.'**
  String get checkIdHint;

  /// No description provided for @qrOtherTransaction.
  ///
  /// In sv, this message translates to:
  /// **'QR-koden hör till en annan transaktion.'**
  String get qrOtherTransaction;

  /// No description provided for @scanPickupQr.
  ///
  /// In sv, this message translates to:
  /// **'Skanna uthämtning'**
  String get scanPickupQr;

  /// No description provided for @notAPickupQr.
  ///
  /// In sv, this message translates to:
  /// **'Det här är inte en uthämtningskod från appen.'**
  String get notAPickupQr;

  /// No description provided for @cameraError.
  ///
  /// In sv, this message translates to:
  /// **'Kameran kunde inte startas ({error}). Tillåt kameran i webbläsaren, eller skriv in koden i stället.'**
  String cameraError(Object error);

  /// No description provided for @pointCameraAtQr.
  ///
  /// In sv, this message translates to:
  /// **'Rikta kameran mot QR-koden på kundens telefon.'**
  String get pointCameraAtQr;

  /// No description provided for @scanPickup.
  ///
  /// In sv, this message translates to:
  /// **'Skanna uthämtning'**
  String get scanPickup;

  /// No description provided for @scanPickupSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skanna kundens QR-kod för att betala ut en bekräftad transaktion.'**
  String get scanPickupSubtitle;

  /// No description provided for @qrNotReadyForPayout.
  ///
  /// In sv, this message translates to:
  /// **'Transaktionen finns inte eller är inte klar för utbetalning.'**
  String get qrNotReadyForPayout;

  /// No description provided for @qrOtherOffice.
  ///
  /// In sv, this message translates to:
  /// **'QR-koden hör till ett annat kontor.'**
  String get qrOtherOffice;

  /// No description provided for @transferPending.
  ///
  /// In sv, this message translates to:
  /// **'Väntar på mottagaren'**
  String get transferPending;

  /// No description provided for @transferAccepted.
  ///
  /// In sv, this message translates to:
  /// **'Mottagen'**
  String get transferAccepted;

  /// No description provided for @transferRejected.
  ///
  /// In sv, this message translates to:
  /// **'Nekad'**
  String get transferRejected;

  /// No description provided for @transferCancelled.
  ///
  /// In sv, this message translates to:
  /// **'Avbruten'**
  String get transferCancelled;

  /// No description provided for @noIncomingTransfers.
  ///
  /// In sv, this message translates to:
  /// **'Inga inkommande överföringar väntar.'**
  String get noIncomingTransfers;

  /// No description provided for @noTransfersYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga överföringar ännu.'**
  String get noTransfersYet;

  /// No description provided for @transferFrom.
  ///
  /// In sv, this message translates to:
  /// **'Från {name}'**
  String transferFrom(Object name);

  /// No description provided for @transferTo.
  ///
  /// In sv, this message translates to:
  /// **'Till {name}'**
  String transferTo(Object name);

  /// No description provided for @transferAcceptedDone.
  ///
  /// In sv, this message translates to:
  /// **'Mottaget. Beloppet är lagt till ditt saldo.'**
  String get transferAcceptedDone;

  /// No description provided for @receivedButton.
  ///
  /// In sv, this message translates to:
  /// **'Mottaget'**
  String get receivedButton;

  /// No description provided for @rejectTransferTitle.
  ///
  /// In sv, this message translates to:
  /// **'Neka överföringen?'**
  String get rejectTransferTitle;

  /// No description provided for @rejectTransferConfirm.
  ///
  /// In sv, this message translates to:
  /// **'{amount} {currency} går tillbaka till {name}.'**
  String rejectTransferConfirm(Object amount, Object currency, Object name);

  /// No description provided for @transferRejectedDone.
  ///
  /// In sv, this message translates to:
  /// **'Överföringen är nekad och pengarna har gått tillbaka.'**
  String get transferRejectedDone;

  /// No description provided for @cancelTransferTitle.
  ///
  /// In sv, this message translates to:
  /// **'Avbryta överföringen?'**
  String get cancelTransferTitle;

  /// No description provided for @cancelTransferConfirm.
  ///
  /// In sv, this message translates to:
  /// **'{amount} {currency} till {name} avbryts och läggs tillbaka på ditt saldo.'**
  String cancelTransferConfirm(Object amount, Object currency, Object name);

  /// No description provided for @transferCancelledDone.
  ///
  /// In sv, this message translates to:
  /// **'Överföringen är avbruten och pengarna är tillbaka på ditt saldo.'**
  String get transferCancelledDone;

  /// No description provided for @cancelTransfer.
  ///
  /// In sv, this message translates to:
  /// **'Avbryt överföring'**
  String get cancelTransfer;

  /// No description provided for @cashBalance.
  ///
  /// In sv, this message translates to:
  /// **'Kassa'**
  String get cashBalance;

  /// No description provided for @noBalanceYet.
  ///
  /// In sv, this message translates to:
  /// **'Inget saldo ännu. Admin fyller på saldot.'**
  String get noBalanceYet;

  /// No description provided for @cashierAppBarTitle.
  ///
  /// In sv, this message translates to:
  /// **'CRM – Kassör'**
  String get cashierAppBarTitle;

  /// No description provided for @cashierNotSetUp.
  ///
  /// In sv, this message translates to:
  /// **'Ditt kassörskonto är inte klart. Kontakta admin.'**
  String get cashierNotSetUp;

  /// No description provided for @cashierSendSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skicka pengar till en annan kassör.'**
  String get cashierSendSubtitle;

  /// No description provided for @incomingTransfers.
  ///
  /// In sv, this message translates to:
  /// **'Inkommande'**
  String get incomingTransfers;

  /// No description provided for @incomingWaiting.
  ///
  /// In sv, this message translates to:
  /// **'{count, plural, =1{1 överföring väntar på att du tar emot den.} other{{count} överföringar väntar på att du tar emot dem.}}'**
  String incomingWaiting(int count);

  /// No description provided for @incomingSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Överföringar som skickats till dig.'**
  String get incomingSubtitle;

  /// No description provided for @myTransfers.
  ///
  /// In sv, this message translates to:
  /// **'Mina överföringar'**
  String get myTransfers;

  /// No description provided for @myTransfersSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Alla skickade och mottagna överföringar.'**
  String get myTransfersSubtitle;

  /// No description provided for @notEnoughBalance.
  ///
  /// In sv, this message translates to:
  /// **'Du har bara {available} {currency}.'**
  String notEnoughBalance(Object available, Object currency);

  /// No description provided for @confirmTransferTitle.
  ///
  /// In sv, this message translates to:
  /// **'Skicka pengar?'**
  String get confirmTransferTitle;

  /// No description provided for @confirmTransferBody.
  ///
  /// In sv, this message translates to:
  /// **'{amount} {currency} till {name}. Beloppet reserveras från ditt saldo tills mottagaren tar emot.'**
  String confirmTransferBody(Object amount, Object currency, Object name);

  /// No description provided for @transferSent.
  ///
  /// In sv, this message translates to:
  /// **'Skickat till {name}. Väntar på att mottagaren tar emot.'**
  String transferSent(Object name);

  /// No description provided for @noBalanceToSend.
  ///
  /// In sv, this message translates to:
  /// **'Du har inget saldo att skicka.'**
  String get noBalanceToSend;

  /// No description provided for @noOtherCashiers.
  ///
  /// In sv, this message translates to:
  /// **'Det finns inga andra kassörer att skicka till.'**
  String get noOtherCashiers;

  /// No description provided for @recipientCashier.
  ///
  /// In sv, this message translates to:
  /// **'Mottagare (kassör)'**
  String get recipientCashier;

  /// No description provided for @availableBalance.
  ///
  /// In sv, this message translates to:
  /// **'Tillgängligt: {amount} {currency}'**
  String availableBalance(Object amount, Object currency);

  /// No description provided for @transferReservedHint.
  ///
  /// In sv, this message translates to:
  /// **'Beloppet dras från ditt saldo direkt och läggs till mottagarens när hen tar emot. Nekar hen, eller avbryter du, går pengarna tillbaka.'**
  String get transferReservedHint;

  /// No description provided for @transfersTitle.
  ///
  /// In sv, this message translates to:
  /// **'Överföringar'**
  String get transfersTitle;

  /// No description provided for @editCashierTitle.
  ///
  /// In sv, this message translates to:
  /// **'Ändra kassör'**
  String get editCashierTitle;

  /// No description provided for @cashierUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Kassören är uppdaterad.'**
  String get cashierUpdated;

  /// No description provided for @adjustBalance.
  ///
  /// In sv, this message translates to:
  /// **'Justera saldo'**
  String get adjustBalance;

  /// No description provided for @adjustBalanceHint.
  ///
  /// In sv, this message translates to:
  /// **'Positivt belopp fyller på, negativt drar av.'**
  String get adjustBalanceHint;

  /// No description provided for @balanceWouldBeNegative.
  ///
  /// In sv, this message translates to:
  /// **'Saldot kan inte bli negativt.'**
  String get balanceWouldBeNegative;

  /// No description provided for @balanceUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Saldot är uppdaterat.'**
  String get balanceUpdated;

  /// No description provided for @deleteCashierTitle.
  ///
  /// In sv, this message translates to:
  /// **'Radera kassör?'**
  String get deleteCashierTitle;

  /// No description provided for @deleteCashierConfirm.
  ///
  /// In sv, this message translates to:
  /// **'{name} kommer inte längre åt appen och saldot tas bort. Inloggningskontot finns kvar och kan tas bort under Authentication i Firebase-konsolen.'**
  String deleteCashierConfirm(Object name);

  /// No description provided for @cashierDeleted.
  ///
  /// In sv, this message translates to:
  /// **'Kassören är raderad.'**
  String get cashierDeleted;

  /// No description provided for @cashiers.
  ///
  /// In sv, this message translates to:
  /// **'Kassörer'**
  String get cashiers;

  /// No description provided for @existingCashiers.
  ///
  /// In sv, this message translates to:
  /// **'Befintliga kassörer'**
  String get existingCashiers;

  /// No description provided for @searchCashiersLabel.
  ///
  /// In sv, this message translates to:
  /// **'Sök på namn, kontor eller manager'**
  String get searchCashiersLabel;

  /// No description provided for @officeOptional.
  ///
  /// In sv, this message translates to:
  /// **'Kontor (valfritt)'**
  String get officeOptional;

  /// No description provided for @managerOptional.
  ///
  /// In sv, this message translates to:
  /// **'Manager (valfritt)'**
  String get managerOptional;

  /// No description provided for @noManagerAssigned.
  ///
  /// In sv, this message translates to:
  /// **'Ingen manager'**
  String get noManagerAssigned;

  /// No description provided for @cashierCreated.
  ///
  /// In sv, this message translates to:
  /// **'Kassören är skapad.'**
  String get cashierCreated;

  /// No description provided for @couldNotCreateCashier.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte skapa kassör: {error}'**
  String couldNotCreateCashier(Object error);

  /// No description provided for @requiredField.
  ///
  /// In sv, this message translates to:
  /// **'Obligatoriskt'**
  String get requiredField;

  /// No description provided for @createNewCashier.
  ///
  /// In sv, this message translates to:
  /// **'Skapa ny kassör'**
  String get createNewCashier;

  /// No description provided for @createCashier.
  ///
  /// In sv, this message translates to:
  /// **'Skapa kassör'**
  String get createCashier;

  /// No description provided for @cashiersCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skapa kassörer, koppla dem till kontor och manager och fyll på saldon.'**
  String get cashiersCardSubtitle;

  /// No description provided for @myCashiers.
  ///
  /// In sv, this message translates to:
  /// **'Mina kassörer'**
  String get myCashiers;

  /// No description provided for @myCashiersSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Kassörer kopplade till dig eller ditt kontor, med saldon och överföringar.'**
  String get myCashiersSubtitle;

  /// No description provided for @noCashiersLinked.
  ///
  /// In sv, this message translates to:
  /// **'Inga kassörer är kopplade till dig eller ditt kontor.'**
  String get noCashiersLinked;

  /// No description provided for @archivedBadge.
  ///
  /// In sv, this message translates to:
  /// **'Arkiverad'**
  String get archivedBadge;

  /// No description provided for @restoreAction.
  ///
  /// In sv, this message translates to:
  /// **'Återställ'**
  String get restoreAction;

  /// No description provided for @archiveAction.
  ///
  /// In sv, this message translates to:
  /// **'Arkivera'**
  String get archiveAction;

  /// No description provided for @showArchived.
  ///
  /// In sv, this message translates to:
  /// **'Visa arkiverade ({count})'**
  String showArchived(Object count);

  /// No description provided for @archiveTransactionTitle.
  ///
  /// In sv, this message translates to:
  /// **'Arkivera transaktionen?'**
  String get archiveTransactionTitle;

  /// No description provided for @archiveTransactionConfirm.
  ///
  /// In sv, this message translates to:
  /// **'Transaktionen är genomförd och kan inte raderas. Den döljs i listan men räknas fortfarande i vinsten och exporten. Du kan visa och återställa den med \"Visa arkiverade\".'**
  String get archiveTransactionConfirm;

  /// No description provided for @transactionArchived.
  ///
  /// In sv, this message translates to:
  /// **'Transaktionen är arkiverad.'**
  String get transactionArchived;

  /// No description provided for @transactionRestored.
  ///
  /// In sv, this message translates to:
  /// **'Transaktionen är återställd.'**
  String get transactionRestored;

  /// No description provided for @tierSilver.
  ///
  /// In sv, this message translates to:
  /// **'Silver'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In sv, this message translates to:
  /// **'Guld'**
  String get tierGold;

  /// No description provided for @tierDiamond.
  ///
  /// In sv, this message translates to:
  /// **'Diamant'**
  String get tierDiamond;

  /// No description provided for @tierNone.
  ///
  /// In sv, this message translates to:
  /// **'Ingen nivå'**
  String get tierNone;

  /// No description provided for @tierLabel.
  ///
  /// In sv, this message translates to:
  /// **'Kundnivå'**
  String get tierLabel;

  /// No description provided for @customerTiers.
  ///
  /// In sv, this message translates to:
  /// **'Kundnivåer'**
  String get customerTiers;

  /// No description provided for @customerTiersCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Silver, Guld och Diamant med rabatt på avgiften'**
  String get customerTiersCardSubtitle;

  /// No description provided for @customerTiersIntro.
  ///
  /// In sv, this message translates to:
  /// **'Rabatten är procentenheter som dras från avgiften managern skriver. Exempel: managern skriver 5 % och kunden är Guld med 1 % rabatt, då betalar kunden 4 %. Du ger kunder en nivå under Kunder.'**
  String get customerTiersIntro;

  /// No description provided for @tierDiscountLabel.
  ///
  /// In sv, this message translates to:
  /// **'Rabatt för {tier}'**
  String tierDiscountLabel(Object tier);

  /// No description provided for @tierInvalidValues.
  ///
  /// In sv, this message translates to:
  /// **'Ange ett tal från 0 till 100.'**
  String get tierInvalidValues;

  /// No description provided for @tierSettingsSaved.
  ///
  /// In sv, this message translates to:
  /// **'Kundnivåerna är sparade.'**
  String get tierSettingsSaved;

  /// No description provided for @customerTierTitle.
  ///
  /// In sv, this message translates to:
  /// **'Kundnivå för {name}'**
  String customerTierTitle(Object name);

  /// No description provided for @customDiscountLabel.
  ///
  /// In sv, this message translates to:
  /// **'Egen rabatt (valfritt)'**
  String get customDiscountLabel;

  /// No description provided for @customDiscountHelper.
  ///
  /// In sv, this message translates to:
  /// **'Lämna tomt för att använda nivåns rabatt.'**
  String get customDiscountHelper;

  /// No description provided for @tierFeeSummary.
  ///
  /// In sv, this message translates to:
  /// **'Rabatt {discount} procentenheter. Exempel: avgift 5 % → kunden betalar {fee} %.'**
  String tierFeeSummary(Object discount, Object fee);

  /// No description provided for @tierNoAccountNote.
  ///
  /// In sv, this message translates to:
  /// **'Kunden har inget konto i appen. Nivån gäller först när kunden skickar förfrågningar i appen.'**
  String get tierNoAccountNote;

  /// No description provided for @customerTierSaved.
  ///
  /// In sv, this message translates to:
  /// **'Kundnivån är sparad.'**
  String get customerTierSaved;

  /// No description provided for @tierDiscountShort.
  ///
  /// In sv, this message translates to:
  /// **'{discount} % rabatt'**
  String tierDiscountShort(Object discount);

  /// No description provided for @customerTierManagerLine.
  ///
  /// In sv, this message translates to:
  /// **'{tier}: {discount} % rabatt dras från avgiften du skriver'**
  String customerTierManagerLine(Object tier, Object discount);

  /// No description provided for @customerTierBadge.
  ///
  /// In sv, this message translates to:
  /// **'{tier} – {discount} % rabatt på avgiften'**
  String customerTierBadge(Object tier, Object discount);

  /// No description provided for @tierFeeExample.
  ///
  /// In sv, this message translates to:
  /// **'Exempel: avgift 5 % → kunden betalar {fee} %'**
  String tierFeeExample(Object fee);

  /// No description provided for @feeAfterTierLine.
  ///
  /// In sv, this message translates to:
  /// **'{base} % − rabatt {discount} % = kunden betalar {fee} %'**
  String feeAfterTierLine(Object base, Object discount, Object fee);

  /// No description provided for @buyCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Köp valuta kontant på kontoret eller till din bank.'**
  String get buyCardSubtitle;

  /// No description provided for @currencyToBuy.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du vill köpa'**
  String get currencyToBuy;

  /// No description provided for @currencyToPayWith.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du betalar med'**
  String get currencyToPayWith;

  /// No description provided for @howToReceive.
  ///
  /// In sv, this message translates to:
  /// **'Hur vill du få pengarna?'**
  String get howToReceive;

  /// No description provided for @deliveryCash.
  ///
  /// In sv, this message translates to:
  /// **'Kontant'**
  String get deliveryCash;

  /// No description provided for @deliveryBank.
  ///
  /// In sv, this message translates to:
  /// **'Till min bank'**
  String get deliveryBank;

  /// No description provided for @deliveryCashHint.
  ///
  /// In sv, this message translates to:
  /// **'Du hämtar pengarna på kontoret med en kod eller QR-kod.'**
  String get deliveryCashHint;

  /// No description provided for @deliveryBankHint.
  ///
  /// In sv, this message translates to:
  /// **'När kontoret har fått din betalning fyller du i dina bankuppgifter, och kontoret skickar pengarna dit.'**
  String get deliveryBankHint;

  /// No description provided for @chooseCurrenciesFirst.
  ///
  /// In sv, this message translates to:
  /// **'Välj valutorna först'**
  String get chooseCurrenciesFirst;

  /// No description provided for @officeForPickup.
  ///
  /// In sv, this message translates to:
  /// **'Kontor där du hämtar pengarna'**
  String get officeForPickup;

  /// No description provided for @officeForBankPayout.
  ///
  /// In sv, this message translates to:
  /// **'Kontor som tar emot din betalning'**
  String get officeForBankPayout;

  /// No description provided for @amountToBuy.
  ///
  /// In sv, this message translates to:
  /// **'Hur mycket vill du köpa?'**
  String get amountToBuy;

  /// No description provided for @sendBuyRequest.
  ///
  /// In sv, this message translates to:
  /// **'Skicka köpförfrågan'**
  String get sendBuyRequest;

  /// No description provided for @buyRequestSent.
  ///
  /// In sv, this message translates to:
  /// **'Köpförfrågan är skickad till kontoret.'**
  String get buyRequestSent;

  /// No description provided for @buySummary.
  ///
  /// In sv, this message translates to:
  /// **'Köp {amount} {to} med {from}'**
  String buySummary(Object amount, Object to, Object from);

  /// No description provided for @youPay.
  ///
  /// In sv, this message translates to:
  /// **'Du betalar: {amount} {currency}'**
  String youPay(Object amount, Object currency);

  /// No description provided for @customerPays.
  ///
  /// In sv, this message translates to:
  /// **'Kunden betalar: {amount} {currency}'**
  String customerPays(Object amount, Object currency);

  /// No description provided for @buyPriceComing.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret räknar ut vad det kostar och skickar ett förslag.'**
  String get buyPriceComing;

  /// No description provided for @paidOutToBankBody.
  ///
  /// In sv, this message translates to:
  /// **'Pengarna är skickade till din bank.'**
  String get paidOutToBankBody;

  /// No description provided for @enterBankDetailsIntro.
  ///
  /// In sv, this message translates to:
  /// **'Fyll i vart pengarna ska skickas.'**
  String get enterBankDetailsIntro;

  /// No description provided for @bankNameLabel.
  ///
  /// In sv, this message translates to:
  /// **'Bankens namn'**
  String get bankNameLabel;

  /// No description provided for @bankPhoneLabel.
  ///
  /// In sv, this message translates to:
  /// **'Telefonnummer'**
  String get bankPhoneLabel;

  /// No description provided for @bankAccountHolderLabel.
  ///
  /// In sv, this message translates to:
  /// **'Kontoinnehavarens namn och efternamn'**
  String get bankAccountHolderLabel;

  /// No description provided for @sendBankDetails.
  ///
  /// In sv, this message translates to:
  /// **'Skicka bankuppgifter'**
  String get sendBankDetails;

  /// No description provided for @fillAllBankFields.
  ///
  /// In sv, this message translates to:
  /// **'Fyll i alla fälten (högst 100 tecken).'**
  String get fillAllBankFields;

  /// No description provided for @bankDetailsWaiting.
  ///
  /// In sv, this message translates to:
  /// **'Tack! Kontoret skickar pengarna till din bank.'**
  String get bankDetailsWaiting;

  /// No description provided for @bankNameValue.
  ///
  /// In sv, this message translates to:
  /// **'Bank: {value}'**
  String bankNameValue(Object value);

  /// No description provided for @bankPhoneValue.
  ///
  /// In sv, this message translates to:
  /// **'Telefon: {value}'**
  String bankPhoneValue(Object value);

  /// No description provided for @bankAccountHolderValue.
  ///
  /// In sv, this message translates to:
  /// **'Kontoinnehavare: {value}'**
  String bankAccountHolderValue(Object value);

  /// No description provided for @changeBankDetails.
  ///
  /// In sv, this message translates to:
  /// **'Ändra bankuppgifter'**
  String get changeBankDetails;

  /// No description provided for @waitingForBankDetails.
  ///
  /// In sv, this message translates to:
  /// **'Väntar på att kunden fyller i sina bankuppgifter.'**
  String get waitingForBankDetails;

  /// No description provided for @sendToBankInstructions.
  ///
  /// In sv, this message translates to:
  /// **'Skicka {amount} {currency} till kundens bank:'**
  String sendToBankInstructions(Object amount, Object currency);

  /// No description provided for @markSentToBank.
  ///
  /// In sv, this message translates to:
  /// **'Pengarna är skickade till banken'**
  String get markSentToBank;

  /// No description provided for @confirmSentToBank.
  ///
  /// In sv, this message translates to:
  /// **'Har du skickat {amount} {currency} till kundens bank? Transaktionen blir genomförd och kontorets saldo uppdateras.'**
  String confirmSentToBank(Object amount, Object currency);

  /// No description provided for @confirm.
  ///
  /// In sv, this message translates to:
  /// **'Bekräfta'**
  String get confirm;

  /// No description provided for @rateFieldLabel.
  ///
  /// In sv, this message translates to:
  /// **'Växelkurs: 1 {from} = ? {to}'**
  String rateFieldLabel(Object from, Object to);

  /// No description provided for @invalidRate.
  ///
  /// In sv, this message translates to:
  /// **'Ange en växelkurs större än 0.'**
  String get invalidRate;

  /// No description provided for @rateChangedFromMarket.
  ///
  /// In sv, this message translates to:
  /// **'Egen kurs. Marknadskurs: {rate}'**
  String rateChangedFromMarket(Object rate);

  /// No description provided for @marketRateUsed.
  ///
  /// In sv, this message translates to:
  /// **'Marknadskurs. Du kan ändra den.'**
  String get marketRateUsed;

  /// No description provided for @useMarketRate.
  ///
  /// In sv, this message translates to:
  /// **'Använd marknadskursen'**
  String get useMarketRate;

  /// No description provided for @pickupCodeDigitsHint.
  ///
  /// In sv, this message translates to:
  /// **'Skriv bara siffrorna, bindestrecken kommer automatiskt.'**
  String get pickupCodeDigitsHint;

  /// No description provided for @balancesTitle.
  ///
  /// In sv, this message translates to:
  /// **'Saldo'**
  String get balancesTitle;

  /// No description provided for @officeBalanceTitle.
  ///
  /// In sv, this message translates to:
  /// **'Kontorets saldo'**
  String get officeBalanceTitle;

  /// No description provided for @cashierBalancesTitle.
  ///
  /// In sv, this message translates to:
  /// **'Kassörernas saldo'**
  String get cashierBalancesTitle;

  /// No description provided for @balancesCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Kontorets och kassörernas saldo, totalt och var för sig.'**
  String get balancesCardSubtitle;

  /// No description provided for @noBalance.
  ///
  /// In sv, this message translates to:
  /// **'Inget saldo.'**
  String get noBalance;

  /// No description provided for @sellCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Sälj valuta och få pengarna kontant eller till din bank.'**
  String get sellCardSubtitle;

  /// No description provided for @currencyToSell.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du vill sälja'**
  String get currencyToSell;

  /// No description provided for @currencyToReceive.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du vill få'**
  String get currencyToReceive;

  /// No description provided for @amountToSell.
  ///
  /// In sv, this message translates to:
  /// **'Hur mycket vill du sälja?'**
  String get amountToSell;

  /// No description provided for @sendSellRequest.
  ///
  /// In sv, this message translates to:
  /// **'Skicka säljförfrågan'**
  String get sendSellRequest;

  /// No description provided for @sellRequestSent.
  ///
  /// In sv, this message translates to:
  /// **'Säljförfrågan är skickad till kontoret.'**
  String get sellRequestSent;

  /// No description provided for @sellSummary.
  ///
  /// In sv, this message translates to:
  /// **'Sälj {amount} {from} för {to}'**
  String sellSummary(Object amount, Object from, Object to);

  /// No description provided for @partners.
  ///
  /// In sv, this message translates to:
  /// **'Partner'**
  String get partners;

  /// No description provided for @partnersCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Växla valuta med dina partner.'**
  String get partnersCardSubtitle;

  /// No description provided for @partnersAdminCardSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Skapa partner och koppla dem till kontor eller manager.'**
  String get partnersAdminCardSubtitle;

  /// No description provided for @editPartnerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Ändra partner'**
  String get editPartnerTitle;

  /// No description provided for @partnerUpdated.
  ///
  /// In sv, this message translates to:
  /// **'Partnern är uppdaterad.'**
  String get partnerUpdated;

  /// No description provided for @deletePartnerTitle.
  ///
  /// In sv, this message translates to:
  /// **'Ta bort partnern?'**
  String get deletePartnerTitle;

  /// No description provided for @deletePartnerConfirm.
  ///
  /// In sv, this message translates to:
  /// **'{name} kommer inte längre åt appen och saldot tas bort. Inloggningskontot finns kvar och kan tas bort under Authentication i Firebase-konsolen.'**
  String deletePartnerConfirm(Object name);

  /// No description provided for @partnerDeleted.
  ///
  /// In sv, this message translates to:
  /// **'Partnern är borttagen.'**
  String get partnerDeleted;

  /// No description provided for @existingPartners.
  ///
  /// In sv, this message translates to:
  /// **'Partner'**
  String get existingPartners;

  /// No description provided for @searchPartnersLabel.
  ///
  /// In sv, this message translates to:
  /// **'Sök partner (namn, kontor, manager)'**
  String get searchPartnersLabel;

  /// No description provided for @createNewPartner.
  ///
  /// In sv, this message translates to:
  /// **'Skapa ny partner'**
  String get createNewPartner;

  /// No description provided for @createPartner.
  ///
  /// In sv, this message translates to:
  /// **'Skapa partner'**
  String get createPartner;

  /// No description provided for @partnerCreated.
  ///
  /// In sv, this message translates to:
  /// **'Partnern är skapad.'**
  String get partnerCreated;

  /// No description provided for @couldNotCreatePartner.
  ///
  /// In sv, this message translates to:
  /// **'Kunde inte skapa partner: {error}'**
  String couldNotCreatePartner(Object error);

  /// No description provided for @partnerAppBarTitle.
  ///
  /// In sv, this message translates to:
  /// **'CRM – Partner'**
  String get partnerAppBarTitle;

  /// No description provided for @partnerNotSetUp.
  ///
  /// In sv, this message translates to:
  /// **'Ditt partnerkonto är inte kopplat till något kontor än. Kontakta admin.'**
  String get partnerNotSetUp;

  /// No description provided for @newExchange.
  ///
  /// In sv, this message translates to:
  /// **'Nytt växlingsförslag'**
  String get newExchange;

  /// No description provided for @exchangesTitle.
  ///
  /// In sv, this message translates to:
  /// **'Växlingar'**
  String get exchangesTitle;

  /// No description provided for @partnerBalancesTitle.
  ///
  /// In sv, this message translates to:
  /// **'Partnernas saldo'**
  String get partnerBalancesTitle;

  /// No description provided for @noPartnersLinked.
  ///
  /// In sv, this message translates to:
  /// **'Inga partner är kopplade till dig eller ditt kontor.'**
  String get noPartnersLinked;

  /// No description provided for @exchangeProposed.
  ///
  /// In sv, this message translates to:
  /// **'Förslag'**
  String get exchangeProposed;

  /// No description provided for @exchangeAccepted.
  ///
  /// In sv, this message translates to:
  /// **'Accepterad'**
  String get exchangeAccepted;

  /// No description provided for @exchangeRejected.
  ///
  /// In sv, this message translates to:
  /// **'Avböjd'**
  String get exchangeRejected;

  /// No description provided for @exchangeCancelled.
  ///
  /// In sv, this message translates to:
  /// **'Avbruten'**
  String get exchangeCancelled;

  /// No description provided for @exchangeCompleted.
  ///
  /// In sv, this message translates to:
  /// **'Genomförd'**
  String get exchangeCompleted;

  /// No description provided for @noExchangesYet.
  ///
  /// In sv, this message translates to:
  /// **'Inga växlingar än.'**
  String get noExchangesYet;

  /// No description provided for @exchangeOfficeGives.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret ger: {amount}'**
  String exchangeOfficeGives(Object amount);

  /// No description provided for @exchangePartnerGives.
  ///
  /// In sv, this message translates to:
  /// **'Partnern ger: {amount}'**
  String exchangePartnerGives(Object amount);

  /// No description provided for @exchangeYouGive.
  ///
  /// In sv, this message translates to:
  /// **'Du ger: {amount}'**
  String exchangeYouGive(Object amount);

  /// No description provided for @exchangeYouGet.
  ///
  /// In sv, this message translates to:
  /// **'Du får: {amount}'**
  String exchangeYouGet(Object amount);

  /// No description provided for @exchangeRateLine.
  ///
  /// In sv, this message translates to:
  /// **'Kurs: 1 {from} = {rate} {to}'**
  String exchangeRateLine(Object from, Object rate, Object to);

  /// No description provided for @exchangeOfficeSentDone.
  ///
  /// In sv, this message translates to:
  /// **'✓ Kontoret har skickat'**
  String get exchangeOfficeSentDone;

  /// No description provided for @exchangeOfficeSentWaiting.
  ///
  /// In sv, this message translates to:
  /// **'… Kontoret har inte skickat än'**
  String get exchangeOfficeSentWaiting;

  /// No description provided for @exchangePartnerSentDone.
  ///
  /// In sv, this message translates to:
  /// **'✓ Partnern har skickat'**
  String get exchangePartnerSentDone;

  /// No description provided for @exchangePartnerSentWaiting.
  ///
  /// In sv, this message translates to:
  /// **'… Partnern har inte skickat än'**
  String get exchangePartnerSentWaiting;

  /// No description provided for @counterProposal.
  ///
  /// In sv, this message translates to:
  /// **'Motförslag'**
  String get counterProposal;

  /// No description provided for @waitingForAnswer.
  ///
  /// In sv, this message translates to:
  /// **'Väntar på svar'**
  String get waitingForAnswer;

  /// No description provided for @markExchangeSent.
  ///
  /// In sv, this message translates to:
  /// **'Jag har skickat {amount}'**
  String markExchangeSent(Object amount);

  /// No description provided for @confirmExchangeSent.
  ///
  /// In sv, this message translates to:
  /// **'Bekräfta att du har skickat pengarna. Den andra sidan ser det och kan bekräfta när de har kommit.'**
  String get confirmExchangeSent;

  /// No description provided for @markExchangeReceived.
  ///
  /// In sv, this message translates to:
  /// **'Jag har tagit emot {amount}'**
  String markExchangeReceived(Object amount);

  /// No description provided for @confirmExchangeReceived.
  ///
  /// In sv, this message translates to:
  /// **'Bekräfta att pengarna har kommit. När båda har bekräftat blir växlingen genomförd och saldona uppdateras.'**
  String get confirmExchangeReceived;

  /// No description provided for @waitingForOtherReceived.
  ///
  /// In sv, this message translates to:
  /// **'Väntar på att den andra sidan bekräftar att pengarna har kommit.'**
  String get waitingForOtherReceived;

  /// No description provided for @youGiveLabel.
  ///
  /// In sv, this message translates to:
  /// **'Belopp du ger'**
  String get youGiveLabel;

  /// No description provided for @youGetLabel.
  ///
  /// In sv, this message translates to:
  /// **'Belopp du får'**
  String get youGetLabel;

  /// No description provided for @currencyYouGive.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du ger'**
  String get currencyYouGive;

  /// No description provided for @currencyYouGet.
  ///
  /// In sv, this message translates to:
  /// **'Valuta du får'**
  String get currencyYouGet;

  /// No description provided for @exchangeProposalSent.
  ///
  /// In sv, this message translates to:
  /// **'Förslaget är skickat.'**
  String get exchangeProposalSent;

  /// No description provided for @choosePartner.
  ///
  /// In sv, this message translates to:
  /// **'Partner'**
  String get choosePartner;

  /// No description provided for @sendProposal.
  ///
  /// In sv, this message translates to:
  /// **'Skicka förslag'**
  String get sendProposal;

  /// No description provided for @searchExistingCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Sök befintlig kund'**
  String get searchExistingCustomer;

  /// No description provided for @noCustomerFoundNew.
  ///
  /// In sv, this message translates to:
  /// **'Ingen kund hittades. Skriv in en ny kund nedan.'**
  String get noCustomerFoundNew;

  /// No description provided for @orNewCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Eller ny kund:'**
  String get orNewCustomer;

  /// No description provided for @hasAppAccount.
  ///
  /// In sv, this message translates to:
  /// **'Har konto i appen'**
  String get hasAppAccount;

  /// No description provided for @noAppAccount.
  ///
  /// In sv, this message translates to:
  /// **'Inget konto i appen'**
  String get noAppAccount;

  /// No description provided for @changeCustomer.
  ///
  /// In sv, this message translates to:
  /// **'Byt'**
  String get changeCustomer;

  /// No description provided for @inviteCustomerQuestion.
  ///
  /// In sv, this message translates to:
  /// **'Vill kunden bli kund hos oss?'**
  String get inviteCustomerQuestion;

  /// No description provided for @inviteCustomerHint.
  ///
  /// In sv, this message translates to:
  /// **'Kunden sparas i kundregistret och får en länk via SMS för att skapa konto i appen.'**
  String get inviteCustomerHint;

  /// No description provided for @invitePhoneRequired.
  ///
  /// In sv, this message translates to:
  /// **'Skriv kundens telefonnummer för att kunna skicka länken.'**
  String get invitePhoneRequired;

  /// No description provided for @inviteSmsText.
  ///
  /// In sv, this message translates to:
  /// **'Hej {name}! Välkommen som kund hos oss. Skapa ditt konto här: {link}'**
  String inviteSmsText(Object name, Object link);

  /// No description provided for @inviteWelcome.
  ///
  /// In sv, this message translates to:
  /// **'Välkommen! Du är redan kund hos oss med klient-ID {clientId}. Skapa ditt konto nedan, så ser du dina transaktioner i appen.'**
  String inviteWelcome(Object clientId);

  /// No description provided for @inviteInvalid.
  ///
  /// In sv, this message translates to:
  /// **'Länken fungerar inte längre. Du kan ändå skapa ett konto nedan.'**
  String get inviteInvalid;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In sv, this message translates to:
  /// **'Har du redan ett konto? Logga in'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @attachReceiptOptional.
  ///
  /// In sv, this message translates to:
  /// **'Bifoga kvitto (valfritt)'**
  String get attachReceiptOptional;

  /// No description provided for @officeReceipt.
  ///
  /// In sv, this message translates to:
  /// **'Kontorets kvitto'**
  String get officeReceipt;

  /// No description provided for @partnerReceipt.
  ///
  /// In sv, this message translates to:
  /// **'Partnerns kvitto'**
  String get partnerReceipt;

  /// No description provided for @totalBalanceTitle.
  ///
  /// In sv, this message translates to:
  /// **'Totalt saldo'**
  String get totalBalanceTitle;

  /// No description provided for @totalBalanceSubtitle.
  ///
  /// In sv, this message translates to:
  /// **'Kontoret + kassörer (utan partner)'**
  String get totalBalanceSubtitle;
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
