// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CRM App';

  @override
  String get languageTooltip => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String errorWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get noRoleFound => 'No role found for this user';

  @override
  String get logout => 'Log out';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String phoneValue(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String emailValue(Object email) {
    return 'Email: $email';
  }

  @override
  String clientIdValue(Object clientId) {
    return 'Client ID: $clientId';
  }

  @override
  String get statusRequested => 'New request';

  @override
  String get statusProposed => 'Offer sent';

  @override
  String get statusAccepted => 'Accepted by customer';

  @override
  String get statusRejected => 'Declined by customer';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get customerStatusRequested => 'Sent – waiting for manager';

  @override
  String get customerStatusProposed => 'Offer from manager – tap for details';

  @override
  String get customerStatusAccepted => 'Accepted – payment details coming';

  @override
  String get customerStatusRejected => 'Declined';

  @override
  String reportTotalOrders(Object total, Object completed) {
    return 'Total orders: $total (completed: $completed)';
  }

  @override
  String reportTotalProfit(Object profit) {
    return 'Total company profit (completed): $profit';
  }

  @override
  String get reportProfitPerDay => 'Profit per day:';

  @override
  String get noOrdersYet => 'No orders yet.';

  @override
  String orderStatusLine(Object status) {
    return 'Status: $status';
  }

  @override
  String orderDetails(Object currency, Object amount, Object fee) {
    return 'Currency: $currency, Amount: $amount, Fee: $fee';
  }

  @override
  String dateValue(Object date) {
    return 'Date: $date';
  }

  @override
  String get noCustomersYet => 'No customers yet.';

  @override
  String get deleteCustomerTitle => 'Delete customer';

  @override
  String deleteCustomerConfirm(Object clientId, Object name) {
    return 'Do you really want to delete #$clientId $name?';
  }

  @override
  String get customerAppBarTitle => 'CRM – Customer';

  @override
  String get myTransactions => 'My transactions';

  @override
  String welcomeName(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get tabSend => 'Send';

  @override
  String get tabBuy => 'Buy';

  @override
  String get tabSell => 'Sell';

  @override
  String get tabExchange => 'Exchange';

  @override
  String comingSoon(Object section) {
    return '$section – coming soon';
  }

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get transaction => 'Transaction';

  @override
  String get transactions => 'Transactions';

  @override
  String youSend(Object amount, Object currency) {
    return 'You send: $amount $currency';
  }

  @override
  String exchangeRateValue(Object from, Object rate, Object to) {
    return 'Exchange rate: 1 $from = $rate $to';
  }

  @override
  String grossReceived(Object amount, Object currency) {
    return 'Gross received: $amount $currency';
  }

  @override
  String feeValue(
    Object percent,
    Object feeFrom,
    Object from,
    Object feeTo,
    Object to,
  ) {
    return 'Fee: $percent% ($feeFrom $from ≈ $feeTo $to)';
  }

  @override
  String youReceive(Object amount, Object currency) {
    return 'You receive: $amount $currency';
  }

  @override
  String paymentTo(Object label) {
    return 'Payment to: $label';
  }

  @override
  String payAmountTo(Object amount, Object currency) {
    return 'Pay $amount $currency to:';
  }

  @override
  String get acceptedWaitingPayment =>
      'You have accepted. The manager will send payment details shortly.';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Decline';

  @override
  String get waitingForProposal => 'Waiting for the manager to send an offer.';

  @override
  String get noSignedInUser => 'No user is signed in.';

  @override
  String couldNotLoadCustomer(Object error) {
    return 'Could not load customer: $error';
  }

  @override
  String get managerStatusRequested => 'New request from customer';

  @override
  String get managerStatusProposed => 'Offer sent – waiting for customer';

  @override
  String get managerStatusAccepted => 'Customer accepted the offer';

  @override
  String get managerStatusRejected => 'Customer cancelled the transaction';

  @override
  String get unknownClient => 'Unknown client';

  @override
  String get authWrongCredentials => 'Wrong email or password.';

  @override
  String get authInvalidEmail => 'Invalid email address.';

  @override
  String get authEmailInUse =>
      'An account with this email address already exists.';

  @override
  String get authWeakPassword => 'The password is too weak.';

  @override
  String get authMissingEmail => 'Enter your email address first.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authNetworkError =>
      'No connection. Check your internet and try again.';

  @override
  String get authUserDisabled => 'This account has been disabled.';

  @override
  String get loginTagline => 'CURRENCY EXCHANGE';

  @override
  String get login => 'Log in';

  @override
  String get loginSubtitle => 'Enter your details to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get resetLinkSent => 'A reset link has been sent to your email.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get registerAccount => 'Create account';

  @override
  String get registerTitle => 'Register as a customer';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get phone => 'Phone';

  @override
  String get enterFirstName => 'Enter first name';

  @override
  String get enterLastName => 'Enter last name';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordMinLength => 'At least 6 characters';

  @override
  String get register => 'Register';

  @override
  String couldNotCreateCustomer(Object error) {
    return 'Could not create customer: $error';
  }

  @override
  String get clientIdMustBeInteger => 'Client ID must be a whole number';

  @override
  String get customerSaved => 'Customer saved!';

  @override
  String get createUpdateCustomer => 'Create / update customer';

  @override
  String get clientIdOptional => 'Client ID (optional)';

  @override
  String get clientIdHint => 'e.g. 007';

  @override
  String get saveCustomer => 'Save customer';

  @override
  String get office => 'Office';

  @override
  String couldNotLoadOffices(Object error) {
    return 'Could not load offices: $error';
  }

  @override
  String get fillAllFieldsValidAmount =>
      'Fill in all fields with a valid amount';

  @override
  String get noCustomerProfile => 'No customer profile found for this user';

  @override
  String get requestSentToOffice => 'Request sent to the office';

  @override
  String couldNotCreateTransaction(Object error) {
    return 'Error creating transaction: $error';
  }

  @override
  String get noOfficesAvailable =>
      'There are no offices to send through right now.';

  @override
  String get currencyYouSend => 'Currency you send';

  @override
  String get chooseOfficeFirstCurrency =>
      'Choose office (choose currency first)';

  @override
  String officesHandlingCurrency(Object currency) {
    return 'Offices that handle $currency';
  }

  @override
  String get currencyRecipientGets => 'Currency the recipient receives';

  @override
  String get amountToSend => 'Amount to send';

  @override
  String get send => 'Send';

  @override
  String get managerCreated => 'Manager created.';

  @override
  String couldNotCreateManager(Object error) {
    return 'Could not create manager: $error';
  }

  @override
  String unexpectedError(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String get createOfficeBeforeManager =>
      'Create at least one office before adding a manager.';

  @override
  String get createNewManager => 'Create new manager';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get createManager => 'Create manager';

  @override
  String couldNotLoadOfficeCurrencies(Object error) {
    return 'Could not load the office\'s currencies: $error';
  }

  @override
  String get enterCustomerName => 'Enter the customer\'s name.';

  @override
  String get chooseTwoDifferentCurrencies => 'Choose two different currencies.';

  @override
  String get enterAmountAboveZero => 'Enter an amount greater than 0.';

  @override
  String get enterFeeRange => 'Enter a fee between 0 and 100 %.';

  @override
  String get createNewTransaction => 'Create new transaction';

  @override
  String get customerName => 'Customer\'s name';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get customerGivesCurrency => 'Customer gives (currency)';

  @override
  String get customerGetsCurrency => 'Customer gets (currency)';

  @override
  String get amountCustomerGives => 'Amount the customer gives';

  @override
  String get feePercentLabel => 'Fee (%)';

  @override
  String get creating => 'Creating …';

  @override
  String get createTransaction => 'Create transaction';

  @override
  String get chooseAtLeastOneCurrency => 'Choose at least one currency';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get enterCountry => 'Enter country';

  @override
  String get enterCity => 'Enter city';

  @override
  String get currencies => 'Currencies';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get add => 'Add';

  @override
  String get noPaymentMethodsYet =>
      'No payment methods yet. Tap \"Add\" to add one.';

  @override
  String get createOffice => 'Create office';

  @override
  String methodNumber(Object number) {
    return 'Method $number';
  }

  @override
  String get removeMethod => 'Remove method';

  @override
  String get methodName => 'Method name';

  @override
  String get methodNameHint => 'e.g. SEB SEK account, USDT TRC20';

  @override
  String get methodDetails =>
      'Details (account number, IBAN, wallet address etc.)';

  @override
  String get methodDetailsHint => 'e.g. IBAN: SE12 3456...';

  @override
  String get supportsCurrencies => 'Supported currencies';

  @override
  String get managerAppBarTitle => 'CRM – Manager';

  @override
  String managerAppBarTitleWithOffice(Object office) {
    return 'CRM – Manager ($office)';
  }

  @override
  String get managerPanel => 'Manager panel';

  @override
  String get managerPanelIntro =>
      'Choose what to work on. Here you can quickly see new, ongoing and finished transactions.';

  @override
  String get createTransactionCardSubtitle =>
      'Register a customer who comes into the office and has no account.';

  @override
  String get newCustomerTransactions => 'New customer transactions';

  @override
  String get newCustomerTransactionsSubtitle =>
      'See new orders from customers that have not been started yet.';

  @override
  String get ongoingTransactions => 'Ongoing transactions';

  @override
  String get ongoingTransactionsSubtitle =>
      'Offers waiting for the customer and accepted orders to be paid and completed.';

  @override
  String get finishedTransactions => 'Finished transactions';

  @override
  String get finishedTransactionsSubtitle =>
      'Completed and declined transactions.';

  @override
  String calculationError(Object error) {
    return 'Calculation error: $error';
  }

  @override
  String get paymentDetailsSent => 'Payment details sent to the customer.';

  @override
  String insufficientBalance(Object currency, Object available, Object needed) {
    return 'The office balance in $currency is too low ($available available, $needed needed). Ask an admin to top up the balance.';
  }

  @override
  String get transactionManager => 'Transaction (manager)';

  @override
  String customerSends(Object amount, Object currency) {
    return 'Customer sends: $amount $currency';
  }

  @override
  String toCurrencyValue(Object currency) {
    return 'To currency: $currency';
  }

  @override
  String customerReceives(Object amount, Object currency) {
    return 'Customer receives: $amount $currency';
  }

  @override
  String get calculating => 'Calculating...';

  @override
  String paymentMethodValue(Object label) {
    return 'Payment method: $label';
  }

  @override
  String get officeNotFound => 'Office not found.';

  @override
  String get noPaymentMethodsForCurrency =>
      'No payment methods for this currency.';

  @override
  String get choosePaymentMethodForCustomer =>
      'Choose a payment method to send to the customer:';

  @override
  String get proposeTerms => 'Propose terms';

  @override
  String sentToCustomer(Object label) {
    return 'Sent to customer: $label';
  }

  @override
  String get resendPaymentDetails => 'Resend payment details';

  @override
  String get sendPaymentDetailsToCustomer => 'Send payment details to customer';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get noOfficesYet => 'No offices created yet.';

  @override
  String get searchCountryOrCity => 'Search by country or city...';

  @override
  String officesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offices found',
      one: '1 office found',
    );
    return '$_temp0';
  }

  @override
  String get noOfficesMatch => 'No offices match the search.';

  @override
  String balanceValue(Object balances) {
    return 'Balance: $balances';
  }

  @override
  String get managerLoading => 'Manager: loading …';

  @override
  String get managerNone => 'Manager: –';

  @override
  String managerValue(Object name) {
    return 'Manager: $name';
  }

  @override
  String get managerUnknown => 'Manager: (unknown)';

  @override
  String get editOffice => 'Edit office';

  @override
  String get topUpBalance => 'Top up balance';

  @override
  String get deleteOffice => 'Delete office';

  @override
  String noCustomerWithClientId(Object clientId) {
    return 'No customer found with client ID $clientId';
  }

  @override
  String editCustomerTitle(Object clientId) {
    return 'Edit customer #$clientId';
  }

  @override
  String get customerUpdated => 'Customer updated!';

  @override
  String get save => 'Save';

  @override
  String get customerDeleted => 'Customer deleted.';

  @override
  String get searchClientId => 'Search client ID';

  @override
  String get search => 'Search';

  @override
  String customerNumber(Object clientId) {
    return 'Customer #$clientId';
  }

  @override
  String get edit => 'Edit';

  @override
  String nameValue(Object name) {
    return 'Name: $name';
  }

  @override
  String get officeUpdated => 'Office updated!';

  @override
  String get editOfficeTitle => 'Edit office';

  @override
  String get methodIdLabel => 'ID (e.g. usdt-trc20)';

  @override
  String get name => 'Name';

  @override
  String get methodDetailsShort => 'Details (IBAN, wallet etc.)';

  @override
  String get supportedFromCurrency => 'Supported for currency (fromCurrency)';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get officeCreated => 'Office created!';

  @override
  String get deleteOfficeQuestion => 'Delete office?';

  @override
  String get deleteOfficeConfirm =>
      'The office will be permanently deleted. Are you sure?';

  @override
  String get deleteAction => 'Delete';

  @override
  String get officeDeleted => 'Office deleted';

  @override
  String deleteError(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String startBalance(Object currency) {
    return 'Starting balance $currency';
  }

  @override
  String get assignManager => 'Assign manager';

  @override
  String get noManagersYet => 'No managers registered yet.';

  @override
  String get manager => 'Manager';

  @override
  String get noPaymentMethodsAdded => 'No payment methods added yet.';

  @override
  String get searchManageOffices => 'Search & manage offices';

  @override
  String get noOfficesFound => 'No offices found.';

  @override
  String officeSummary(Object currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payment methods',
      one: '1 payment method',
    );
    return 'Currencies: $currencies\n$_temp0';
  }

  @override
  String get exportDate => 'Date';

  @override
  String get exportStatus => 'Status';

  @override
  String get exportClientId => 'Client ID';

  @override
  String get exportOffice => 'Office';

  @override
  String get exportFrom => 'From';

  @override
  String get exportTo => 'To';

  @override
  String get exportAmount => 'Amount';

  @override
  String get exportFee => 'Fee';

  @override
  String get exportPayout => 'Payout';

  @override
  String get noTransactionsToExport => 'No transactions to export';

  @override
  String get orderReport => 'Order report';

  @override
  String get adminAppBarTitle => 'CRM – Admin';

  @override
  String get adminHeadline => 'Admin view: Full control';

  @override
  String get manageOffices => 'Manage offices';

  @override
  String get officeHasNoCurrencies =>
      'The office has no currencies. Add a currency via Edit office first.';

  @override
  String get currency => 'Currency';

  @override
  String get amount => 'Amount';

  @override
  String get ok => 'OK';

  @override
  String get orderHistory => 'Order history';

  @override
  String get filterByOffice => 'Filter by office (optional)';

  @override
  String get allOffices => 'All offices';

  @override
  String get chooseDateRange => 'Choose date range';

  @override
  String get clearDates => 'Clear dates';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get chooseDateRangeHint => 'Choose a date range to show transactions.';

  @override
  String clientShort(Object clientId) {
    return 'Client $clientId';
  }

  @override
  String get rateMissingApiKey =>
      'The exchange-rate API key is missing. Build the app with --dart-define-from-file=fx_key.json.';

  @override
  String rateHttpError(Object code) {
    return 'Could not fetch the exchange rate (HTTP $code).';
  }

  @override
  String rateNotFound(Object from, Object to) {
    return 'No rate found for $from → $to.';
  }
}
