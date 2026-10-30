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

  @override
  String get customers => 'Customers';

  @override
  String get offices => 'Offices';

  @override
  String get managers => 'Managers';

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get adminPanelIntro =>
      'Choose what to manage. The number on each card shows how many there are.';

  @override
  String get customersCardSubtitle =>
      'Create, search, edit and delete customers.';

  @override
  String get officesCardSubtitle =>
      'Create offices, edit currencies and payment methods, and top up balances.';

  @override
  String get managersCardSubtitle =>
      'Create managers and see which office they work at.';

  @override
  String get ordersCardSubtitle =>
      'All transactions with filters, profit report and CSV/PDF export.';

  @override
  String get existingManagers => 'Existing managers';

  @override
  String get noOfficeAssigned => 'No office';

  @override
  String officeValue(Object office) {
    return 'Office: $office';
  }

  @override
  String get searchCustomers => 'Search customers';

  @override
  String get searchCustomersLabel => 'Client ID, name, phone, country or city';

  @override
  String get searchCustomersHint => 'e.g. 00, Ali, 0731, Grozny';

  @override
  String get clearSearch => 'Clear search';

  @override
  String customersShown(int shown, int total) {
    return 'Showing $shown of $total customers';
  }

  @override
  String get noCustomersMatch => 'No customers match the search.';

  @override
  String placesValue(Object places) {
    return 'Offices: $places';
  }

  @override
  String typeToSearchCustomers(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other:
          'Type in the search box to show customers ($total customers in total).',
      one: 'Type in the search box to show customers (1 customer in total).',
    );
    return '$_temp0';
  }

  @override
  String customersShownLimited(int shown, int count) {
    return 'Showing the first $shown of $count matches. Type more to narrow it down.';
  }

  @override
  String typeToSearch(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Type in the search box to show matches ($total in total).',
      one: 'Type in the search box to show matches (1 in total).',
    );
    return '$_temp0';
  }

  @override
  String get noSearchMatches => 'No matches.';

  @override
  String searchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get searchOfficesLabel => 'Search by country, city or currency';

  @override
  String get searchManagersLabel => 'Search by name, email, phone or office';

  @override
  String get searchTransactionsLabel =>
      'No., client ID, name, phone, office, currency or status';

  @override
  String get searchTransactionsHint => 'e.g. T-00012, 00, Ali, Grozny, RUB';

  @override
  String get searchOrChooseDatesHint =>
      'Type in the search box or choose a date range to show transactions.';

  @override
  String get editManagerTitle => 'Edit manager';

  @override
  String get managerUpdated => 'Manager updated.';

  @override
  String get deleteManagerTitle => 'Delete manager?';

  @override
  String deleteManagerConfirm(Object name) {
    return '$name will no longer have access to the app. The login account remains and can be removed under Authentication in the Firebase console.';
  }

  @override
  String get managerDeleted => 'Manager deleted.';

  @override
  String get editTransactionTitle => 'Edit transaction';

  @override
  String get statusChangeNoBalance =>
      'Changing the status does not change the office balance.';

  @override
  String get transactionUpdated => 'Transaction updated.';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String get deleteTransactionConfirm =>
      'The transaction will be permanently deleted. The office balance is not changed.';

  @override
  String get customerPanel => 'What would you like to do?';

  @override
  String get sendMoney => 'Send money';

  @override
  String get sendMoneySubtitle =>
      'Choose currency and office and send a request.';

  @override
  String get myTransactionsSubtitle =>
      'Follow your transactions and reply to offers.';

  @override
  String offersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers are waiting for your reply.',
      one: '1 offer is waiting for your reply.',
    );
    return '$_temp0';
  }

  @override
  String get soonBadge => 'Soon';

  @override
  String get statusCountered => 'Counter-offer from customer';

  @override
  String get customerStatusCountered =>
      'Counter-offer sent – waiting for manager';

  @override
  String get managerStatusCountered => 'The customer sent a counter-offer';

  @override
  String get counterOffer => 'Counter-offer';

  @override
  String get counterOfferAlreadyUsed =>
      'You have already used your counter-offer for this transaction.';

  @override
  String yourCounterOffer(Object fee) {
    return 'Your counter-offer: $fee% fee';
  }

  @override
  String get waitingForManagerAnswer => 'Waiting for the manager\'s answer.';

  @override
  String counterOfferIntro(Object fee) {
    return 'The manager proposes a $fee% fee. What fee do you propose?';
  }

  @override
  String get counterFeeLabel => 'Your fee (%)';

  @override
  String youWouldReceive(Object amount, Object currency) {
    return 'You would receive: $amount $currency';
  }

  @override
  String get messageOptional => 'Message (optional)';

  @override
  String get counterOfferOnce =>
      'You can only send one counter-offer per transaction.';

  @override
  String counterFeeMustBeLower(Object fee) {
    return 'Enter a fee from 0 and lower than $fee%.';
  }

  @override
  String get sendCounterOffer => 'Send counter-offer';

  @override
  String get counterOfferSent => 'Your counter-offer has been sent.';

  @override
  String customerCounterOffer(Object counter, Object fee) {
    return 'The customer proposes a $counter% fee instead of $fee%.';
  }

  @override
  String get counterOfferManagerHint =>
      'Accept the customer\'s fee or send a new proposal. The customer cannot counter again.';

  @override
  String acceptCounterOffer(Object fee) {
    return 'Accept $fee%';
  }

  @override
  String get sendNewProposal => 'Send new proposal';

  @override
  String get counterOfferAccepted => 'The counter-offer was accepted.';

  @override
  String transactionNoValue(Object no) {
    return 'Transaction $no';
  }

  @override
  String get exportNo => 'No.';

  @override
  String get statusPaid => 'Paid by customer';

  @override
  String get statusPaymentConfirmed => 'Payment confirmed';

  @override
  String get customerStatusPaid => 'Payment sent – the manager is checking';

  @override
  String get customerStatusPaymentConfirmed =>
      'Ready for pickup – see your code';

  @override
  String get managerStatusPaid => 'The customer has paid – check the payment';

  @override
  String get managerStatusPaymentConfirmed =>
      'Payment confirmed – waiting for pickup';

  @override
  String readyForPickup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions are ready for pickup.',
      one: '1 transaction is ready for pickup.',
    );
    return '$_temp0';
  }

  @override
  String get iHavePaid => 'I have paid';

  @override
  String get markPaidIntro =>
      'Attach the receipt (image or PDF) so the manager can check the payment faster.';

  @override
  String get attachReceipt => 'Attach receipt';

  @override
  String get changeReceipt => 'Change receipt';

  @override
  String get receiptTooLarge => 'The file is too large (max 10 MB).';

  @override
  String get confirmPaid => 'Send';

  @override
  String get markedAsPaidSent =>
      'Thank you! The manager is checking the payment.';

  @override
  String get markedAsPaid => 'You marked this as paid';

  @override
  String get managerCheckingPayment =>
      'The manager is checking the payment and will confirm as soon as it has arrived.';

  @override
  String get showReceipt => 'Show receipt';

  @override
  String get paymentMissingTitle => 'The payment has not arrived';

  @override
  String get paymentConfirmedTitle => 'The payment is confirmed';

  @override
  String get yourPickupCode => 'Your pickup code';

  @override
  String pickupCodeInstructions(Object amount, Object currency) {
    return 'Show the code at the office to collect $amount $currency. Only share it with the person collecting the money.';
  }

  @override
  String get paidOutTitle => 'Paid out';

  @override
  String get paidOutBody => 'The money has been collected. Thank you!';

  @override
  String get wrongPickupCode =>
      'Wrong code. Check the code the customer shows.';

  @override
  String get paymentConfirmedSent =>
      'The payment is confirmed and the customer has received a code.';

  @override
  String get paymentMissing => 'Payment missing';

  @override
  String get paymentMissingDefault =>
      'We have not received your payment yet. Please check the payment and try again.';

  @override
  String get messageToCustomer => 'Message to the customer';

  @override
  String get confirmPayment => 'Confirm payment';

  @override
  String get customerMarkedPaid => 'The customer has marked this as paid';

  @override
  String showReceiptNamed(Object name) {
    return 'Show receipt $name';
  }

  @override
  String get noReceiptAttached => 'No receipt attached.';

  @override
  String get paymentConfirmedManager => 'The payment is confirmed';

  @override
  String payoutInstructions(Object amount, Object currency) {
    return 'Pay out $amount $currency when the customer shows the pickup code.';
  }

  @override
  String giveCodeToWalkIn(Object code) {
    return 'The customer has no account. Give the customer this code: $code';
  }

  @override
  String get customerPickupCode => 'Customer\'s pickup code';

  @override
  String get payOutAndComplete => 'Pay out and mark as completed';

  @override
  String get showQrAtOffice => 'Show the QR code at the office';

  @override
  String get orUseCode => 'Or give the code';

  @override
  String get scanCustomerQr => 'Scan the customer\'s QR code';

  @override
  String get enterCodeInstead => 'Enter the code instead';

  @override
  String get payOutWithCode => 'Pay out with code';

  @override
  String get qrDoesNotMatch => 'The QR code does not match this transaction.';

  @override
  String get qrVerified => 'QR code verified';

  @override
  String payOutAmount(Object amount, Object currency) {
    return 'Pay out $amount $currency';
  }

  @override
  String get checkIdHint => 'Check the customer\'s ID before paying out.';

  @override
  String get qrOtherTransaction =>
      'The QR code belongs to another transaction.';

  @override
  String get scanPickupQr => 'Scan pickup';

  @override
  String get notAPickupQr => 'This is not a pickup code from the app.';

  @override
  String cameraError(Object error) {
    return 'The camera could not start ($error). Allow the camera in the browser, or enter the code instead.';
  }

  @override
  String get pointCameraAtQr =>
      'Point the camera at the QR code on the customer\'s phone.';

  @override
  String get scanPickup => 'Scan pickup';

  @override
  String get scanPickupSubtitle =>
      'Scan the customer\'s QR code to pay out a confirmed transaction.';

  @override
  String get qrNotReadyForPayout =>
      'The transaction does not exist or is not ready for payout.';

  @override
  String get qrOtherOffice => 'The QR code belongs to another office.';

  @override
  String get transferPending => 'Waiting for recipient';

  @override
  String get transferAccepted => 'Received';

  @override
  String get transferRejected => 'Declined';

  @override
  String get transferCancelled => 'Cancelled';

  @override
  String get noIncomingTransfers => 'No incoming transfers are waiting.';

  @override
  String get noTransfersYet => 'No transfers yet.';

  @override
  String transferFrom(Object name) {
    return 'From $name';
  }

  @override
  String transferTo(Object name) {
    return 'To $name';
  }

  @override
  String get transferAcceptedDone =>
      'Received. The amount has been added to your balance.';

  @override
  String get receivedButton => 'Received';

  @override
  String get rejectTransferTitle => 'Decline the transfer?';

  @override
  String rejectTransferConfirm(Object amount, Object currency, Object name) {
    return '$amount $currency will go back to $name.';
  }

  @override
  String get transferRejectedDone =>
      'The transfer was declined and the money has gone back.';

  @override
  String get cancelTransferTitle => 'Cancel the transfer?';

  @override
  String cancelTransferConfirm(Object amount, Object currency, Object name) {
    return '$amount $currency to $name will be cancelled and added back to your balance.';
  }

  @override
  String get transferCancelledDone =>
      'The transfer was cancelled and the money is back in your balance.';

  @override
  String get cancelTransfer => 'Cancel transfer';

  @override
  String get cashBalance => 'Cash';

  @override
  String get noBalanceYet => 'No balance yet. An admin tops up the balance.';

  @override
  String get cashierAppBarTitle => 'CRM – Cashier';

  @override
  String get cashierNotSetUp =>
      'Your cashier account is not set up. Contact an admin.';

  @override
  String get cashierSendSubtitle => 'Send money to another cashier.';

  @override
  String get incomingTransfers => 'Incoming';

  @override
  String incomingWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfers are waiting for you to receive them.',
      one: '1 transfer is waiting for you to receive it.',
    );
    return '$_temp0';
  }

  @override
  String get incomingSubtitle => 'Transfers sent to you.';

  @override
  String get myTransfers => 'My transfers';

  @override
  String get myTransfersSubtitle => 'All sent and received transfers.';

  @override
  String notEnoughBalance(Object available, Object currency) {
    return 'You only have $available $currency.';
  }

  @override
  String get confirmTransferTitle => 'Send money?';

  @override
  String confirmTransferBody(Object amount, Object currency, Object name) {
    return '$amount $currency to $name. The amount is reserved from your balance until the recipient receives it.';
  }

  @override
  String transferSent(Object name) {
    return 'Sent to $name. Waiting for the recipient to receive it.';
  }

  @override
  String get noBalanceToSend => 'You have no balance to send.';

  @override
  String get noOtherCashiers => 'There are no other cashiers to send to.';

  @override
  String get recipientCashier => 'Recipient (cashier)';

  @override
  String availableBalance(Object amount, Object currency) {
    return 'Available: $amount $currency';
  }

  @override
  String get transferReservedHint =>
      'The amount leaves your balance immediately and is added to the recipient\'s when they receive it. If they decline, or you cancel, the money comes back.';

  @override
  String get transfersTitle => 'Transfers';

  @override
  String get editCashierTitle => 'Edit cashier';

  @override
  String get cashierUpdated => 'The cashier was updated.';

  @override
  String get adjustBalance => 'Adjust balance';

  @override
  String get adjustBalanceHint =>
      'A positive amount tops up, a negative one deducts.';

  @override
  String get balanceWouldBeNegative => 'The balance cannot go below zero.';

  @override
  String get balanceUpdated => 'The balance was updated.';

  @override
  String get deleteCashierTitle => 'Delete cashier?';

  @override
  String deleteCashierConfirm(Object name) {
    return '$name will lose access to the app and the balance is removed. The login account remains and can be removed under Authentication in the Firebase console.';
  }

  @override
  String get cashierDeleted => 'The cashier was deleted.';

  @override
  String get cashiers => 'Cashiers';

  @override
  String get existingCashiers => 'Existing cashiers';

  @override
  String get searchCashiersLabel => 'Search by name, office or manager';

  @override
  String get officeOptional => 'Office (optional)';

  @override
  String get managerOptional => 'Manager (optional)';

  @override
  String get noManagerAssigned => 'No manager';

  @override
  String get cashierCreated => 'The cashier was created.';

  @override
  String couldNotCreateCashier(Object error) {
    return 'Could not create cashier: $error';
  }

  @override
  String get requiredField => 'Required';

  @override
  String get createNewCashier => 'Create new cashier';

  @override
  String get createCashier => 'Create cashier';

  @override
  String get cashiersCardSubtitle =>
      'Create cashiers, link them to offices and managers, and top up balances.';

  @override
  String get myCashiers => 'My cashiers';

  @override
  String get myCashiersSubtitle =>
      'Cashiers linked to you or your office, with balances and transfers.';

  @override
  String get noCashiersLinked =>
      'No cashiers are linked to you or your office.';

  @override
  String get archivedBadge => 'Archived';

  @override
  String get restoreAction => 'Restore';

  @override
  String get archiveAction => 'Archive';

  @override
  String showArchived(Object count) {
    return 'Show archived ($count)';
  }

  @override
  String get archiveTransactionTitle => 'Archive the transaction?';

  @override
  String get archiveTransactionConfirm =>
      'The transaction is completed and cannot be deleted. It is hidden from the list but still counts in profit and export. You can show and restore it with \"Show archived\".';

  @override
  String get transactionArchived => 'The transaction was archived.';

  @override
  String get transactionRestored => 'The transaction was restored.';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierDiamond => 'Diamond';

  @override
  String get tierNone => 'No tier';

  @override
  String get tierLabel => 'Customer tier';

  @override
  String get customerTiers => 'Customer tiers';

  @override
  String get customerTiersCardSubtitle =>
      'Silver, Gold and Diamond with a fee discount';

  @override
  String get customerTiersIntro =>
      'The discount is percentage points taken off the fee the manager enters. Example: the manager enters 5% and the customer is Gold with a 1% discount, so the customer pays 4%. You give customers a tier under Customers.';

  @override
  String tierDiscountLabel(Object tier) {
    return 'Discount for $tier';
  }

  @override
  String get tierInvalidValues => 'Enter a number from 0 to 100.';

  @override
  String get tierSettingsSaved => 'Customer tiers saved.';

  @override
  String customerTierTitle(Object name) {
    return 'Customer tier for $name';
  }

  @override
  String get customDiscountLabel => 'Own discount (optional)';

  @override
  String get customDiscountHelper => 'Leave empty to use the tier\'s discount.';

  @override
  String tierFeeSummary(Object discount, Object fee) {
    return 'Discount $discount percentage points. Example: fee 5% → the customer pays $fee%.';
  }

  @override
  String get tierNoAccountNote =>
      'The customer has no app account. The tier applies once the customer sends requests in the app.';

  @override
  String get customerTierSaved => 'Customer tier saved.';

  @override
  String tierDiscountShort(Object discount) {
    return '$discount% discount';
  }

  @override
  String customerTierManagerLine(Object tier, Object discount) {
    return '$tier: a $discount% discount is taken off the fee you enter';
  }

  @override
  String customerTierBadge(Object tier, Object discount) {
    return '$tier – $discount% discount on the fee';
  }

  @override
  String tierFeeExample(Object fee) {
    return 'Example: fee 5% → the customer pays $fee%';
  }

  @override
  String feeAfterTierLine(Object base, Object discount, Object fee) {
    return '$base% − discount $discount% = the customer pays $fee%';
  }

  @override
  String get buyCardSubtitle =>
      'Buy currency in cash at the office or to your bank.';

  @override
  String get currencyToBuy => 'Currency you want to buy';

  @override
  String get currencyToPayWith => 'Currency you pay with';

  @override
  String get howToReceive => 'How do you want to receive the money?';

  @override
  String get deliveryCash => 'Cash';

  @override
  String get deliveryBank => 'To my bank';

  @override
  String get deliveryCashHint =>
      'You pick up the money at the office with a code or QR code.';

  @override
  String get deliveryBankHint =>
      'Once the office has received your payment, you enter your bank details and the office sends the money there.';

  @override
  String get chooseCurrenciesFirst => 'Choose the currencies first';

  @override
  String get officeForPickup => 'Office where you pick up the money';

  @override
  String get officeForBankPayout => 'Office that receives your payment';

  @override
  String get amountToBuy => 'How much do you want to buy?';

  @override
  String get sendBuyRequest => 'Send purchase request';

  @override
  String get buyRequestSent => 'The purchase request was sent to the office.';

  @override
  String buySummary(Object amount, Object to, Object from) {
    return 'Buy $amount $to with $from';
  }

  @override
  String youPay(Object amount, Object currency) {
    return 'You pay: $amount $currency';
  }

  @override
  String customerPays(Object amount, Object currency) {
    return 'The customer pays: $amount $currency';
  }

  @override
  String get buyPriceComing =>
      'The office works out the price and sends a proposal.';

  @override
  String get paidOutToBankBody => 'The money has been sent to your bank.';

  @override
  String get enterBankDetailsIntro => 'Enter where the money should be sent.';

  @override
  String get bankNameLabel => 'Bank name';

  @override
  String get bankPhoneLabel => 'Phone number';

  @override
  String get bankAccountHolderLabel => 'Account holder\'s first and last name';

  @override
  String get sendBankDetails => 'Send bank details';

  @override
  String get fillAllBankFields =>
      'Fill in all fields (at most 100 characters).';

  @override
  String get bankDetailsWaiting =>
      'Thank you! The office will send the money to your bank.';

  @override
  String bankNameValue(Object value) {
    return 'Bank: $value';
  }

  @override
  String bankPhoneValue(Object value) {
    return 'Phone: $value';
  }

  @override
  String bankAccountHolderValue(Object value) {
    return 'Account holder: $value';
  }

  @override
  String get changeBankDetails => 'Change bank details';

  @override
  String get waitingForBankDetails =>
      'Waiting for the customer to enter their bank details.';

  @override
  String sendToBankInstructions(Object amount, Object currency) {
    return 'Send $amount $currency to the customer\'s bank:';
  }

  @override
  String get markSentToBank => 'Money sent to the bank';

  @override
  String confirmSentToBank(Object amount, Object currency) {
    return 'Have you sent $amount $currency to the customer\'s bank? The transaction will be completed and the office balance updated.';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String rateFieldLabel(Object from, Object to) {
    return 'Exchange rate: 1 $from = ? $to';
  }

  @override
  String get invalidRate => 'Enter an exchange rate above 0.';

  @override
  String rateChangedFromMarket(Object rate) {
    return 'Own rate. Market rate: $rate';
  }

  @override
  String get marketRateUsed => 'Market rate. You can change it.';

  @override
  String get useMarketRate => 'Use the market rate';

  @override
  String get pickupCodeDigitsHint =>
      'Type only the digits; the dashes are added automatically.';

  @override
  String get balancesTitle => 'Balance';

  @override
  String get officeBalanceTitle => 'Office balance';

  @override
  String get cashierBalancesTitle => 'Cashier balances';

  @override
  String get balancesCardSubtitle =>
      'The office\'s and the cashiers\' balances, in total and separately.';

  @override
  String get noBalance => 'No balance.';

  @override
  String get sellCardSubtitle =>
      'Sell currency and get the money in cash or to your bank.';

  @override
  String get currencyToSell => 'Currency you want to sell';

  @override
  String get currencyToReceive => 'Currency you want to receive';

  @override
  String get amountToSell => 'How much do you want to sell?';

  @override
  String get sendSellRequest => 'Send sell request';

  @override
  String get sellRequestSent => 'The sell request was sent to the office.';

  @override
  String sellSummary(Object amount, Object from, Object to) {
    return 'Sell $amount $from for $to';
  }

  @override
  String get partners => 'Partners';

  @override
  String get partnersCardSubtitle => 'Exchange currency with your partners.';

  @override
  String get partnersAdminCardSubtitle =>
      'Create partners and link them to an office or manager.';

  @override
  String get editPartnerTitle => 'Edit partner';

  @override
  String get partnerUpdated => 'The partner was updated.';

  @override
  String get deletePartnerTitle => 'Delete the partner?';

  @override
  String deletePartnerConfirm(Object name) {
    return '$name will no longer have access to the app and the balance is removed. The login account remains and can be deleted under Authentication in the Firebase console.';
  }

  @override
  String get partnerDeleted => 'The partner was deleted.';

  @override
  String get existingPartners => 'Partners';

  @override
  String get searchPartnersLabel => 'Search partner (name, office, manager)';

  @override
  String get createNewPartner => 'Create new partner';

  @override
  String get createPartner => 'Create partner';

  @override
  String get partnerCreated => 'The partner was created.';

  @override
  String couldNotCreatePartner(Object error) {
    return 'Could not create partner: $error';
  }

  @override
  String get partnerAppBarTitle => 'CRM – Partner';

  @override
  String get partnerNotSetUp =>
      'Your partner account is not linked to an office yet. Contact the admin.';

  @override
  String get newExchange => 'New exchange proposal';

  @override
  String get exchangesTitle => 'Exchanges';

  @override
  String get partnerBalancesTitle => 'Partner balances';

  @override
  String get noPartnersLinked =>
      'No partners are linked to you or your office.';

  @override
  String get exchangeProposed => 'Proposal';

  @override
  String get exchangeAccepted => 'Accepted';

  @override
  String get exchangeRejected => 'Rejected';

  @override
  String get exchangeCancelled => 'Cancelled';

  @override
  String get exchangeCompleted => 'Completed';

  @override
  String get noExchangesYet => 'No exchanges yet.';

  @override
  String exchangeOfficeGives(Object amount) {
    return 'The office gives: $amount';
  }

  @override
  String exchangePartnerGives(Object amount) {
    return 'The partner gives: $amount';
  }

  @override
  String exchangeYouGive(Object amount) {
    return 'You give: $amount';
  }

  @override
  String exchangeYouGet(Object amount) {
    return 'You get: $amount';
  }

  @override
  String exchangeRateLine(Object from, Object rate, Object to) {
    return 'Rate: 1 $from = $rate $to';
  }

  @override
  String get exchangeOfficeSentDone => '✓ The office has sent';

  @override
  String get exchangeOfficeSentWaiting => '… The office has not sent yet';

  @override
  String get exchangePartnerSentDone => '✓ The partner has sent';

  @override
  String get exchangePartnerSentWaiting => '… The partner has not sent yet';

  @override
  String get counterProposal => 'Counter-proposal';

  @override
  String get waitingForAnswer => 'Waiting for an answer';

  @override
  String markExchangeSent(Object amount) {
    return 'I have sent $amount';
  }

  @override
  String get confirmExchangeSent =>
      'Confirm that you have sent the money. The other side sees it and can confirm when it has arrived.';

  @override
  String markExchangeReceived(Object amount) {
    return 'I have received $amount';
  }

  @override
  String get confirmExchangeReceived =>
      'Confirm that the money has arrived. When both have confirmed, the exchange is completed and the balances are updated.';

  @override
  String get waitingForOtherReceived =>
      'Waiting for the other side to confirm that the money has arrived.';

  @override
  String get youGiveLabel => 'Amount you give';

  @override
  String get youGetLabel => 'Amount you get';

  @override
  String get currencyYouGive => 'Currency you give';

  @override
  String get currencyYouGet => 'Currency you get';

  @override
  String get exchangeProposalSent => 'The proposal was sent.';

  @override
  String get choosePartner => 'Partner';

  @override
  String get sendProposal => 'Send proposal';

  @override
  String get searchExistingCustomer => 'Search existing customer';

  @override
  String get noCustomerFoundNew =>
      'No customer found. Enter a new customer below.';

  @override
  String get orNewCustomer => 'Or a new customer:';

  @override
  String get hasAppAccount => 'Has an app account';

  @override
  String get noAppAccount => 'No app account';

  @override
  String get changeCustomer => 'Change';

  @override
  String get inviteCustomerQuestion =>
      'Does the customer want to become our customer?';

  @override
  String get inviteCustomerHint =>
      'The customer is saved in the customer register and gets a link by SMS to create an app account.';

  @override
  String get invitePhoneRequired =>
      'Enter the customer\'s phone number to send the link.';

  @override
  String inviteSmsText(Object name, Object link) {
    return 'Hi $name! Welcome as our customer. Create your account here: $link';
  }

  @override
  String inviteWelcome(Object clientId) {
    return 'Welcome! You are already our customer with client ID $clientId. Create your account below to see your transactions in the app.';
  }

  @override
  String get inviteInvalid =>
      'The link no longer works. You can still create an account below.';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Log in';

  @override
  String get attachReceiptOptional => 'Attach receipt (optional)';

  @override
  String get officeReceipt => 'Office receipt';

  @override
  String get partnerReceipt => 'Partner receipt';

  @override
  String get totalBalanceTitle => 'Total balance';

  @override
  String get totalBalanceSubtitle => 'Office + cashiers (excluding partners)';

  @override
  String get officeAddressLabel => 'Address (for customers paying cash)';

  @override
  String get officeMapUrlLabel => 'Map link';

  @override
  String get officeMapUrlHelper =>
      'Open the office in Google Maps, tap Share and paste the link here.';

  @override
  String get howDoYouPay => 'How do you pay?';

  @override
  String get howDoesCustomerPay => 'How does the customer pay?';

  @override
  String get payCashAtOffice => 'Cash at the office';

  @override
  String get payViaBank => 'Via bank';

  @override
  String get payCashHint =>
      'You get the office address with a map link and hand in the money there. The office confirms the payment.';

  @override
  String get payBankHint => 'The office sends you payment details, as before.';

  @override
  String get walkInCashHint =>
      'The customer pays here at the office. The payment is confirmed right away and the customer gets a pickup code.';

  @override
  String get walkInBankHint =>
      'You send payment details to the customer and confirm when the money has arrived, as before.';

  @override
  String get officeAddressMissing =>
      'The office has no address yet. Ask the office.';

  @override
  String get openMap => 'Open map';

  @override
  String payCashAtOfficeAmount(Object amount, Object currency) {
    return 'Pay $amount $currency in cash at the office';
  }

  @override
  String get payCashConfirmHint =>
      'The office confirms when you have handed in the money. You then get your pickup code.';

  @override
  String get customerPaysCashAtOffice =>
      '💵 The customer pays cash at the office';

  @override
  String get cashPaymentReceived => 'Payment received (cash)';

  @override
  String get cashPaymentsTitle => 'Cash payments';

  @override
  String get cashPaymentsSubtitle =>
      'Customers who will pay cash at the office.';

  @override
  String get noCashPaymentsWaiting => 'No cash payments are waiting right now.';

  @override
  String confirmCashReceived(Object amount, Object name) {
    return 'Have you received $amount in cash from $name? The customer then gets their pickup code.';
  }

  @override
  String customerPaysCashAmount(Object amount, Object currency) {
    return 'The customer pays $amount $currency';
  }

  @override
  String get pickUpAtOfficeTitle => 'Office address';

  @override
  String get youPayCashAtOffice => 'You pay cash at the office';

  @override
  String lowBalanceTitle(Object currency) {
    return 'Not enough $currency';
  }

  @override
  String get lowBalanceHas => 'The office has:';

  @override
  String get lowBalanceToPay => 'To pay out:';

  @override
  String get lowBalanceMissing => 'Missing:';

  @override
  String lowBalancePartnerHint(Object currency) {
    return 'Check with a partner whether you can exchange for $currency.';
  }
}
