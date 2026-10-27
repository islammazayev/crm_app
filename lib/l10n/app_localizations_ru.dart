// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CRM App';

  @override
  String get languageTooltip => 'Язык';

  @override
  String get languageSystem => 'Язык устройства';

  @override
  String errorWithDetails(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get noRoleFound => 'Для пользователя не найдена роль';

  @override
  String get logout => 'Выйти';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String phoneValue(Object phone) {
    return 'Телефон: $phone';
  }

  @override
  String emailValue(Object email) {
    return 'Эл. почта: $email';
  }

  @override
  String clientIdValue(Object clientId) {
    return 'ID клиента: $clientId';
  }

  @override
  String get statusRequested => 'Новый запрос';

  @override
  String get statusProposed => 'Предложение отправлено';

  @override
  String get statusAccepted => 'Принято клиентом';

  @override
  String get statusRejected => 'Отклонено клиентом';

  @override
  String get statusCompleted => 'Выполнено';

  @override
  String get customerStatusRequested => 'Отправлено – ждём менеджера';

  @override
  String get customerStatusProposed =>
      'Предложение от менеджера – нажмите для подробностей';

  @override
  String get customerStatusAccepted =>
      'Принято – реквизиты для оплаты скоро придут';

  @override
  String get customerStatusRejected => 'Отклонено';

  @override
  String reportTotalOrders(Object total, Object completed) {
    return 'Всего заказов: $total (выполнено: $completed)';
  }

  @override
  String reportTotalProfit(Object profit) {
    return 'Общая прибыль компании (выполненные): $profit';
  }

  @override
  String get reportProfitPerDay => 'Прибыль по дням:';

  @override
  String get noOrdersYet => 'Заказов пока нет.';

  @override
  String orderStatusLine(Object status) {
    return 'Статус: $status';
  }

  @override
  String orderDetails(Object currency, Object amount, Object fee) {
    return 'Валюта: $currency, Сумма: $amount, Комиссия: $fee';
  }

  @override
  String dateValue(Object date) {
    return 'Дата: $date';
  }

  @override
  String get noCustomersYet => 'Клиентов пока нет.';

  @override
  String get deleteCustomerTitle => 'Удалить клиента';

  @override
  String deleteCustomerConfirm(Object clientId, Object name) {
    return 'Вы действительно хотите удалить #$clientId $name?';
  }

  @override
  String get customerAppBarTitle => 'CRM – Клиент';

  @override
  String get myTransactions => 'Мои переводы';

  @override
  String welcomeName(Object name) {
    return 'Добро пожаловать, $name';
  }

  @override
  String get tabSend => 'Отправить';

  @override
  String get tabBuy => 'Купить';

  @override
  String get tabSell => 'Продать';

  @override
  String get tabExchange => 'Обменять';

  @override
  String comingSoon(Object section) {
    return '$section – скоро';
  }

  @override
  String get noTransactionsYet => 'Переводов пока нет';

  @override
  String get transaction => 'Перевод';

  @override
  String get transactions => 'Переводы';

  @override
  String youSend(Object amount, Object currency) {
    return 'Вы отправляете: $amount $currency';
  }

  @override
  String exchangeRateValue(Object from, Object rate, Object to) {
    return 'Курс: 1 $from = $rate $to';
  }

  @override
  String grossReceived(Object amount, Object currency) {
    return 'Сумма до комиссии: $amount $currency';
  }

  @override
  String feeValue(
    Object percent,
    Object feeFrom,
    Object from,
    Object feeTo,
    Object to,
  ) {
    return 'Комиссия: $percent% ($feeFrom $from ≈ $feeTo $to)';
  }

  @override
  String youReceive(Object amount, Object currency) {
    return 'Вы получите: $amount $currency';
  }

  @override
  String paymentTo(Object label) {
    return 'Оплата на: $label';
  }

  @override
  String payAmountTo(Object amount, Object currency) {
    return 'Оплатите $amount $currency на:';
  }

  @override
  String get acceptedWaitingPayment =>
      'Вы приняли предложение. Менеджер скоро пришлёт реквизиты для оплаты.';

  @override
  String get accept => 'Принять';

  @override
  String get reject => 'Отклонить';

  @override
  String get waitingForProposal => 'Ждём, пока менеджер пришлёт предложение.';

  @override
  String get noSignedInUser => 'Пользователь не вошёл в систему.';

  @override
  String couldNotLoadCustomer(Object error) {
    return 'Не удалось загрузить клиента: $error';
  }

  @override
  String get managerStatusRequested => 'Новый запрос от клиента';

  @override
  String get managerStatusProposed => 'Предложение отправлено – ждём клиента';

  @override
  String get managerStatusAccepted => 'Клиент принял предложение';

  @override
  String get managerStatusRejected => 'Клиент отменил перевод';

  @override
  String get unknownClient => 'Неизвестный клиент';

  @override
  String get authWrongCredentials => 'Неверная эл. почта или пароль.';

  @override
  String get authInvalidEmail => 'Неверный адрес эл. почты.';

  @override
  String get authEmailInUse =>
      'Аккаунт с этим адресом эл. почты уже существует.';

  @override
  String get authWeakPassword => 'Слишком простой пароль.';

  @override
  String get authMissingEmail => 'Сначала введите адрес эл. почты.';

  @override
  String get authTooManyRequests =>
      'Слишком много попыток. Подождите немного и попробуйте снова.';

  @override
  String get authNetworkError =>
      'Нет соединения. Проверьте интернет и попробуйте снова.';

  @override
  String get authUserDisabled => 'Аккаунт заблокирован.';

  @override
  String get loginTagline => 'ОБМЕН ВАЛЮТ';

  @override
  String get login => 'Войти';

  @override
  String get loginSubtitle => 'Введите свои данные, чтобы продолжить';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get resetLinkSent =>
      'Ссылка для сброса пароля отправлена на вашу почту.';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get registerAccount => 'Создать аккаунт';

  @override
  String get registerTitle => 'Регистрация клиента';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get phone => 'Телефон';

  @override
  String get enterFirstName => 'Введите имя';

  @override
  String get enterLastName => 'Введите фамилию';

  @override
  String get enterValidEmail => 'Введите корректный адрес эл. почты';

  @override
  String get passwordMinLength => 'Минимум 6 символов';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String couldNotCreateCustomer(Object error) {
    return 'Не удалось создать клиента: $error';
  }

  @override
  String get clientIdMustBeInteger => 'ID клиента должен быть целым числом';

  @override
  String get customerSaved => 'Клиент сохранён!';

  @override
  String get createUpdateCustomer => 'Создать / обновить клиента';

  @override
  String get clientIdOptional => 'ID клиента (необязательно)';

  @override
  String get clientIdHint => 'напр. 007';

  @override
  String get saveCustomer => 'Сохранить клиента';

  @override
  String get office => 'Офис';

  @override
  String couldNotLoadOffices(Object error) {
    return 'Не удалось загрузить офисы: $error';
  }

  @override
  String get fillAllFieldsValidAmount =>
      'Заполните все поля и укажите корректную сумму';

  @override
  String get noCustomerProfile =>
      'Профиль клиента для этого пользователя не найден';

  @override
  String get requestSentToOffice => 'Запрос отправлен в офис';

  @override
  String couldNotCreateTransaction(Object error) {
    return 'Ошибка при создании перевода: $error';
  }

  @override
  String get noOfficesAvailable => 'Сейчас нет офисов для отправки.';

  @override
  String get currencyYouSend => 'Валюта, которую вы отправляете';

  @override
  String get chooseOfficeFirstCurrency =>
      'Выберите офис (сначала выберите валюту)';

  @override
  String officesHandlingCurrency(Object currency) {
    return 'Офисы, работающие с $currency';
  }

  @override
  String get currencyRecipientGets => 'Валюта, которую получит получатель';

  @override
  String get amountToSend => 'Сумма к отправке';

  @override
  String get send => 'Отправить';

  @override
  String get managerCreated => 'Менеджер создан.';

  @override
  String couldNotCreateManager(Object error) {
    return 'Не удалось создать менеджера: $error';
  }

  @override
  String unexpectedError(Object error) {
    return 'Непредвиденная ошибка: $error';
  }

  @override
  String get createOfficeBeforeManager =>
      'Создайте хотя бы один офис, прежде чем добавлять менеджера.';

  @override
  String get createNewManager => 'Новый менеджер';

  @override
  String get enterEmail => 'Введите эл. почту';

  @override
  String get createManager => 'Создать менеджера';

  @override
  String couldNotLoadOfficeCurrencies(Object error) {
    return 'Не удалось загрузить валюты офиса: $error';
  }

  @override
  String get enterCustomerName => 'Введите имя клиента.';

  @override
  String get chooseTwoDifferentCurrencies => 'Выберите две разные валюты.';

  @override
  String get enterAmountAboveZero => 'Введите сумму больше 0.';

  @override
  String get enterFeeRange => 'Введите комиссию от 0 до 100 %.';

  @override
  String get createNewTransaction => 'Новый перевод';

  @override
  String get customerName => 'Имя клиента';

  @override
  String get phoneOptional => 'Телефон (необязательно)';

  @override
  String get customerGivesCurrency => 'Клиент сдаёт (валюта)';

  @override
  String get customerGetsCurrency => 'Клиент получает (валюта)';

  @override
  String get amountCustomerGives => 'Сумма, которую сдаёт клиент';

  @override
  String get feePercentLabel => 'Комиссия (%)';

  @override
  String get creating => 'Создаём …';

  @override
  String get createTransaction => 'Создать перевод';

  @override
  String get chooseAtLeastOneCurrency => 'Выберите хотя бы одну валюту';

  @override
  String get country => 'Страна';

  @override
  String get city => 'Город';

  @override
  String get enterCountry => 'Введите страну';

  @override
  String get enterCity => 'Введите город';

  @override
  String get currencies => 'Валюты';

  @override
  String get paymentMethods => 'Способы оплаты';

  @override
  String get add => 'Добавить';

  @override
  String get noPaymentMethodsYet =>
      'Способов оплаты пока нет. Нажмите «Добавить», чтобы добавить.';

  @override
  String get createOffice => 'Создать офис';

  @override
  String methodNumber(Object number) {
    return 'Способ $number';
  }

  @override
  String get removeMethod => 'Удалить способ';

  @override
  String get methodName => 'Название способа';

  @override
  String get methodNameHint => 'напр. счёт SEB SEK, USDT TRC20';

  @override
  String get methodDetails =>
      'Реквизиты (номер счёта, IBAN, адрес кошелька и т. д.)';

  @override
  String get methodDetailsHint => 'напр. IBAN: SE12 3456...';

  @override
  String get supportsCurrencies => 'Поддерживаемые валюты';

  @override
  String get managerAppBarTitle => 'CRM – Менеджер';

  @override
  String managerAppBarTitleWithOffice(Object office) {
    return 'CRM – Менеджер ($office)';
  }

  @override
  String get managerPanel => 'Панель менеджера';

  @override
  String get managerPanelIntro =>
      'Выберите, с чем работать. Здесь видно новые, текущие и завершённые переводы.';

  @override
  String get createTransactionCardSubtitle =>
      'Оформите клиента, который пришёл в офис и не имеет аккаунта.';

  @override
  String get newCustomerTransactions => 'Новые запросы клиентов';

  @override
  String get newCustomerTransactionsSubtitle =>
      'Новые заказы клиентов, которые ещё не взяты в работу.';

  @override
  String get ongoingTransactions => 'Текущие переводы';

  @override
  String get ongoingTransactionsSubtitle =>
      'Предложения, ожидающие клиента, и принятые заказы, которые нужно оплатить и завершить.';

  @override
  String get finishedTransactions => 'Завершённые переводы';

  @override
  String get finishedTransactionsSubtitle =>
      'Выполненные и отклонённые переводы.';

  @override
  String calculationError(Object error) {
    return 'Ошибка расчёта: $error';
  }

  @override
  String get paymentDetailsSent => 'Реквизиты отправлены клиенту.';

  @override
  String insufficientBalance(Object currency, Object available, Object needed) {
    return 'В офисе недостаточно средств в $currency (есть $available, нужно $needed). Попросите администратора пополнить баланс.';
  }

  @override
  String get transactionManager => 'Перевод (менеджер)';

  @override
  String customerSends(Object amount, Object currency) {
    return 'Клиент отправляет: $amount $currency';
  }

  @override
  String toCurrencyValue(Object currency) {
    return 'В валюту: $currency';
  }

  @override
  String customerReceives(Object amount, Object currency) {
    return 'Клиент получит: $amount $currency';
  }

  @override
  String get calculating => 'Считаем...';

  @override
  String paymentMethodValue(Object label) {
    return 'Способ оплаты: $label';
  }

  @override
  String get officeNotFound => 'Офис не найден.';

  @override
  String get noPaymentMethodsForCurrency =>
      'Нет способов оплаты для этой валюты.';

  @override
  String get choosePaymentMethodForCustomer =>
      'Выберите способ оплаты для клиента:';

  @override
  String get proposeTerms => 'Предложить условия';

  @override
  String sentToCustomer(Object label) {
    return 'Отправлено клиенту: $label';
  }

  @override
  String get resendPaymentDetails => 'Отправить реквизиты повторно';

  @override
  String get sendPaymentDetailsToCustomer => 'Отправить реквизиты клиенту';

  @override
  String get markAsCompleted => 'Отметить как выполненный';

  @override
  String get noOfficesYet => 'Офисов пока нет.';

  @override
  String get searchCountryOrCity => 'Поиск по стране или городу...';

  @override
  String officesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count офиса',
      many: 'Найдено $count офисов',
      few: 'Найдено $count офиса',
      one: 'Найден $count офис',
    );
    return '$_temp0';
  }

  @override
  String get noOfficesMatch => 'Нет офисов по этому запросу.';

  @override
  String balanceValue(Object balances) {
    return 'Баланс: $balances';
  }

  @override
  String get managerLoading => 'Менеджер: загрузка …';

  @override
  String get managerNone => 'Менеджер: –';

  @override
  String managerValue(Object name) {
    return 'Менеджер: $name';
  }

  @override
  String get managerUnknown => 'Менеджер: (неизвестен)';

  @override
  String get editOffice => 'Изменить офис';

  @override
  String get topUpBalance => 'Пополнить баланс';

  @override
  String get deleteOffice => 'Удалить офис';

  @override
  String noCustomerWithClientId(Object clientId) {
    return 'Клиент с ID $clientId не найден';
  }

  @override
  String editCustomerTitle(Object clientId) {
    return 'Изменить клиента #$clientId';
  }

  @override
  String get customerUpdated => 'Клиент обновлён!';

  @override
  String get save => 'Сохранить';

  @override
  String get customerDeleted => 'Клиент удалён.';

  @override
  String get searchClientId => 'Поиск по ID клиента';

  @override
  String get search => 'Найти';

  @override
  String customerNumber(Object clientId) {
    return 'Клиент #$clientId';
  }

  @override
  String get edit => 'Изменить';

  @override
  String nameValue(Object name) {
    return 'Имя: $name';
  }

  @override
  String get officeUpdated => 'Офис обновлён!';

  @override
  String get editOfficeTitle => 'Изменить офис';

  @override
  String get methodIdLabel => 'ID (напр. usdt-trc20)';

  @override
  String get name => 'Название';

  @override
  String get methodDetailsShort => 'Реквизиты (IBAN, кошелёк и т. д.)';

  @override
  String get supportedFromCurrency => 'Для валюты (fromCurrency)';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get officeCreated => 'Офис создан!';

  @override
  String get deleteOfficeQuestion => 'Удалить офис?';

  @override
  String get deleteOfficeConfirm => 'Офис будет удалён навсегда. Вы уверены?';

  @override
  String get deleteAction => 'Удалить';

  @override
  String get officeDeleted => 'Офис удалён';

  @override
  String deleteError(Object error) {
    return 'Ошибка при удалении: $error';
  }

  @override
  String startBalance(Object currency) {
    return 'Начальный баланс $currency';
  }

  @override
  String get assignManager => 'Назначить менеджера';

  @override
  String get noManagersYet => 'Менеджеров пока нет.';

  @override
  String get manager => 'Менеджер';

  @override
  String get noPaymentMethodsAdded => 'Способы оплаты ещё не добавлены.';

  @override
  String get searchManageOffices => 'Поиск и управление офисами';

  @override
  String get noOfficesFound => 'Офисы не найдены.';

  @override
  String officeSummary(Object currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count способа оплаты',
      many: '$count способов оплаты',
      few: '$count способа оплаты',
      one: '$count способ оплаты',
    );
    return 'Валюты: $currencies\n$_temp0';
  }

  @override
  String get exportDate => 'Дата';

  @override
  String get exportStatus => 'Статус';

  @override
  String get exportClientId => 'ID клиента';

  @override
  String get exportOffice => 'Офис';

  @override
  String get exportFrom => 'Из';

  @override
  String get exportTo => 'В';

  @override
  String get exportAmount => 'Сумма';

  @override
  String get exportFee => 'Комиссия';

  @override
  String get exportPayout => 'К выплате';

  @override
  String get noTransactionsToExport => 'Нет переводов для экспорта';

  @override
  String get orderReport => 'Отчёт по заказам';

  @override
  String get adminAppBarTitle => 'CRM – Администратор';

  @override
  String get adminHeadline => 'Панель администратора';

  @override
  String get manageOffices => 'Управление офисами';

  @override
  String get officeHasNoCurrencies =>
      'У офиса нет валют. Сначала добавьте валюту через «Изменить офис».';

  @override
  String get currency => 'Валюта';

  @override
  String get amount => 'Сумма';

  @override
  String get ok => 'OK';

  @override
  String get orderHistory => 'История заказов';

  @override
  String get filterByOffice => 'Фильтр по офису (необязательно)';

  @override
  String get allOffices => 'Все офисы';

  @override
  String get chooseDateRange => 'Выбрать период';

  @override
  String get clearDates => 'Сбросить даты';

  @override
  String get exportCsv => 'Экспорт CSV';

  @override
  String get exportPdf => 'Экспорт PDF';

  @override
  String get chooseDateRangeHint => 'Выберите период, чтобы увидеть переводы.';

  @override
  String clientShort(Object clientId) {
    return 'Клиент $clientId';
  }

  @override
  String get rateMissingApiKey =>
      'Нет API-ключа для курсов валют. Соберите приложение с --dart-define-from-file=fx_key.json.';

  @override
  String rateHttpError(Object code) {
    return 'Не удалось получить курс (HTTP $code).';
  }

  @override
  String rateNotFound(Object from, Object to) {
    return 'Курс для $from → $to не найден.';
  }

  @override
  String get customers => 'Клиенты';

  @override
  String get offices => 'Офисы';

  @override
  String get managers => 'Менеджеры';

  @override
  String get adminPanel => 'Панель администратора';

  @override
  String get adminPanelIntro =>
      'Выберите, чем управлять. Число на карточке показывает количество.';

  @override
  String get customersCardSubtitle =>
      'Создание, поиск, изменение и удаление клиентов.';

  @override
  String get officesCardSubtitle =>
      'Создание офисов, валюты и способы оплаты, пополнение баланса.';

  @override
  String get managersCardSubtitle => 'Создание менеджеров и их офисы.';

  @override
  String get ordersCardSubtitle =>
      'Все переводы с фильтрами, отчётом о прибыли и экспортом в CSV/PDF.';

  @override
  String get existingManagers => 'Текущие менеджеры';

  @override
  String get noOfficeAssigned => 'Нет офиса';

  @override
  String officeValue(Object office) {
    return 'Офис: $office';
  }

  @override
  String get searchCustomers => 'Поиск клиента';

  @override
  String get searchCustomersLabel =>
      'ID клиента, имя, телефон, страна или город';

  @override
  String get searchCustomersHint => 'напр. 00, Али, 0731, Грозный';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String customersShown(int shown, int total) {
    return 'Показано $shown из $total';
  }

  @override
  String get noCustomersMatch => 'Нет клиентов по этому запросу.';

  @override
  String placesValue(Object places) {
    return 'Офисы: $places';
  }

  @override
  String typeToSearchCustomers(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Начните вводить, чтобы увидеть клиентов (всего $total клиента).',
      many: 'Начните вводить, чтобы увидеть клиентов (всего $total клиентов).',
      few: 'Начните вводить, чтобы увидеть клиентов (всего $total клиента).',
      one: 'Начните вводить, чтобы увидеть клиентов (всего $total клиент).',
    );
    return '$_temp0';
  }

  @override
  String customersShownLimited(int shown, int count) {
    return 'Показаны первые $shown из $count совпадений. Уточните запрос.';
  }

  @override
  String typeToSearch(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Начните вводить, чтобы увидеть результаты (всего $total).',
      many: 'Начните вводить, чтобы увидеть результаты (всего $total).',
      few: 'Начните вводить, чтобы увидеть результаты (всего $total).',
      one: 'Начните вводить, чтобы увидеть результаты (всего $total).',
    );
    return '$_temp0';
  }

  @override
  String get noSearchMatches => 'Ничего не найдено.';

  @override
  String searchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count совпадения',
      many: '$count совпадений',
      few: '$count совпадения',
      one: '$count совпадение',
    );
    return '$_temp0';
  }

  @override
  String get searchOfficesLabel => 'Поиск по стране, городу или валюте';

  @override
  String get searchManagersLabel => 'Поиск по имени, почте, телефону или офису';

  @override
  String get searchTransactionsLabel =>
      '№, ID клиента, имя, телефон, офис, валюта или статус';

  @override
  String get searchTransactionsHint => 'напр. T-00012, 00, Али, Грозный, RUB';

  @override
  String get searchOrChooseDatesHint =>
      'Введите запрос или выберите период, чтобы увидеть переводы.';

  @override
  String get editManagerTitle => 'Изменить менеджера';

  @override
  String get managerUpdated => 'Менеджер обновлён.';

  @override
  String get deleteManagerTitle => 'Удалить менеджера?';

  @override
  String deleteManagerConfirm(Object name) {
    return '$name больше не будет иметь доступа к приложению. Учётная запись для входа останется, её можно удалить в разделе Authentication в консоли Firebase.';
  }

  @override
  String get managerDeleted => 'Менеджер удалён.';

  @override
  String get editTransactionTitle => 'Изменить перевод';

  @override
  String get statusChangeNoBalance =>
      'Изменение статуса не меняет баланс офиса.';

  @override
  String get transactionUpdated => 'Перевод обновлён.';

  @override
  String get deleteTransactionTitle => 'Удалить перевод?';

  @override
  String get deleteTransactionConfirm =>
      'Перевод будет удалён навсегда. Баланс офиса не изменится.';

  @override
  String get customerPanel => 'Что вы хотите сделать?';

  @override
  String get sendMoney => 'Отправить деньги';

  @override
  String get sendMoneySubtitle => 'Выберите валюту и офис и отправьте запрос.';

  @override
  String get myTransactionsSubtitle =>
      'Следите за переводами и отвечайте на предложения.';

  @override
  String offersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предложения ждут вашего ответа.',
      many: '$count предложений ждут вашего ответа.',
      few: '$count предложения ждут вашего ответа.',
      one: '$count предложение ждёт вашего ответа.',
    );
    return '$_temp0';
  }

  @override
  String get soonBadge => 'Скоро';

  @override
  String get statusCountered => 'Встречное предложение клиента';

  @override
  String get customerStatusCountered =>
      'Встречное предложение отправлено – ждём менеджера';

  @override
  String get managerStatusCountered => 'Клиент отправил встречное предложение';

  @override
  String get counterOffer => 'Встречное предложение';

  @override
  String get counterOfferAlreadyUsed =>
      'Вы уже использовали встречное предложение для этого перевода.';

  @override
  String yourCounterOffer(Object fee) {
    return 'Ваше предложение: комиссия $fee%';
  }

  @override
  String get waitingForManagerAnswer => 'Ждём ответа менеджера.';

  @override
  String counterOfferIntro(Object fee) {
    return 'Менеджер предлагает комиссию $fee%. Какую комиссию предлагаете вы?';
  }

  @override
  String get counterFeeLabel => 'Ваша комиссия (%)';

  @override
  String youWouldReceive(Object amount, Object currency) {
    return 'Вы получите: $amount $currency';
  }

  @override
  String get messageOptional => 'Сообщение (необязательно)';

  @override
  String get counterOfferOnce =>
      'Встречное предложение можно отправить только один раз.';

  @override
  String counterFeeMustBeLower(Object fee) {
    return 'Введите комиссию от 0 и меньше $fee%.';
  }

  @override
  String get sendCounterOffer => 'Отправить предложение';

  @override
  String get counterOfferSent => 'Встречное предложение отправлено.';

  @override
  String customerCounterOffer(Object counter, Object fee) {
    return 'Клиент предлагает комиссию $counter% вместо $fee%.';
  }

  @override
  String get counterOfferManagerHint =>
      'Примите комиссию клиента или отправьте новое предложение. Клиент больше не может предлагать.';

  @override
  String acceptCounterOffer(Object fee) {
    return 'Принять $fee%';
  }

  @override
  String get sendNewProposal => 'Отправить новое предложение';

  @override
  String get counterOfferAccepted => 'Встречное предложение принято.';

  @override
  String transactionNoValue(Object no) {
    return 'Перевод $no';
  }

  @override
  String get exportNo => '№';

  @override
  String get statusPaid => 'Оплачено клиентом';

  @override
  String get statusPaymentConfirmed => 'Оплата подтверждена';

  @override
  String get customerStatusPaid => 'Оплата отправлена – менеджер проверяет';

  @override
  String get customerStatusPaymentConfirmed => 'Можно получить – см. код';

  @override
  String get managerStatusPaid => 'Клиент оплатил – проверьте оплату';

  @override
  String get managerStatusPaymentConfirmed =>
      'Оплата подтверждена – ждём получения';

  @override
  String readyForPickup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count перевода можно получить.',
      many: '$count переводов можно получить.',
      few: '$count перевода можно получить.',
      one: '$count перевод можно получить.',
    );
    return '$_temp0';
  }

  @override
  String get iHavePaid => 'Я оплатил';

  @override
  String get markPaidIntro =>
      'Прикрепите чек (фото или PDF), чтобы менеджер быстрее проверил оплату.';

  @override
  String get attachReceipt => 'Прикрепить чек';

  @override
  String get changeReceipt => 'Заменить чек';

  @override
  String get receiptTooLarge => 'Файл слишком большой (максимум 10 МБ).';

  @override
  String get confirmPaid => 'Отправить';

  @override
  String get markedAsPaidSent => 'Спасибо! Менеджер проверяет оплату.';

  @override
  String get markedAsPaid => 'Вы отметили оплату';

  @override
  String get managerCheckingPayment =>
      'Менеджер проверяет оплату и подтвердит, как только она поступит.';

  @override
  String get showReceipt => 'Показать чек';

  @override
  String get paymentMissingTitle => 'Оплата не поступила';

  @override
  String get paymentConfirmedTitle => 'Оплата подтверждена';

  @override
  String get yourPickupCode => 'Ваш код для получения';

  @override
  String pickupCodeInstructions(Object amount, Object currency) {
    return 'Покажите код в офисе, чтобы получить $amount $currency. Сообщайте его только тому, кто будет получать деньги.';
  }

  @override
  String get paidOutTitle => 'Выплачено';

  @override
  String get paidOutBody => 'Деньги получены. Спасибо!';

  @override
  String get wrongPickupCode =>
      'Неверный код. Проверьте код, который показывает клиент.';

  @override
  String get paymentConfirmedSent => 'Оплата подтверждена, клиент получил код.';

  @override
  String get paymentMissing => 'Оплата не поступила';

  @override
  String get paymentMissingDefault =>
      'Мы ещё не получили вашу оплату. Проверьте платёж и попробуйте снова.';

  @override
  String get messageToCustomer => 'Сообщение клиенту';

  @override
  String get confirmPayment => 'Подтвердить оплату';

  @override
  String get customerMarkedPaid => 'Клиент отметил оплату';

  @override
  String showReceiptNamed(Object name) {
    return 'Показать чек $name';
  }

  @override
  String get noReceiptAttached => 'Чек не прикреплён.';

  @override
  String get paymentConfirmedManager => 'Оплата подтверждена';

  @override
  String payoutInstructions(Object amount, Object currency) {
    return 'Выплатите $amount $currency, когда клиент покажет код.';
  }

  @override
  String giveCodeToWalkIn(Object code) {
    return 'У клиента нет аккаунта. Передайте клиенту код: $code';
  }

  @override
  String get customerPickupCode => 'Код клиента для получения';

  @override
  String get payOutAndComplete => 'Выплатить и отметить как выполненный';

  @override
  String get showQrAtOffice => 'Покажите QR-код в офисе';

  @override
  String get orUseCode => 'Или назовите код';

  @override
  String get scanCustomerQr => 'Сканировать QR-код клиента';

  @override
  String get enterCodeInstead => 'Ввести код вручную';

  @override
  String get payOutWithCode => 'Выплатить по коду';

  @override
  String get qrDoesNotMatch => 'QR-код не подходит к этому переводу.';

  @override
  String get qrVerified => 'QR-код подтверждён';

  @override
  String payOutAmount(Object amount, Object currency) {
    return 'Выплатить $amount $currency';
  }

  @override
  String get checkIdHint => 'Проверьте документ клиента перед выплатой.';

  @override
  String get qrOtherTransaction => 'QR-код относится к другому переводу.';

  @override
  String get scanPickupQr => 'Сканировать получение';

  @override
  String get notAPickupQr => 'Это не код получения из приложения.';

  @override
  String cameraError(Object error) {
    return 'Не удалось запустить камеру ($error). Разрешите камеру в браузере или введите код вручную.';
  }

  @override
  String get pointCameraAtQr =>
      'Наведите камеру на QR-код на телефоне клиента.';

  @override
  String get scanPickup => 'Сканировать получение';

  @override
  String get scanPickupSubtitle =>
      'Отсканируйте QR-код клиента, чтобы выплатить подтверждённый перевод.';

  @override
  String get qrNotReadyForPayout =>
      'Перевод не найден или ещё не готов к выплате.';

  @override
  String get qrOtherOffice => 'QR-код относится к другому офису.';

  @override
  String get transferPending => 'Ждёт получателя';

  @override
  String get transferAccepted => 'Получено';

  @override
  String get transferRejected => 'Отклонено';

  @override
  String get transferCancelled => 'Отменено';

  @override
  String get noIncomingTransfers => 'Нет входящих переводов.';

  @override
  String get noTransfersYet => 'Переводов пока нет.';

  @override
  String transferFrom(Object name) {
    return 'От $name';
  }

  @override
  String transferTo(Object name) {
    return 'Кому: $name';
  }

  @override
  String get transferAcceptedDone =>
      'Получено. Сумма добавлена к вашему балансу.';

  @override
  String get receivedButton => 'Получено';

  @override
  String get rejectTransferTitle => 'Отклонить перевод?';

  @override
  String rejectTransferConfirm(Object amount, Object currency, Object name) {
    return '$amount $currency вернутся к $name.';
  }

  @override
  String get transferRejectedDone => 'Перевод отклонён, деньги возвращены.';

  @override
  String get cancelTransferTitle => 'Отменить перевод?';

  @override
  String cancelTransferConfirm(Object amount, Object currency, Object name) {
    return '$amount $currency для $name будут отменены и вернутся на ваш баланс.';
  }

  @override
  String get transferCancelledDone =>
      'Перевод отменён, деньги вернулись на ваш баланс.';

  @override
  String get cancelTransfer => 'Отменить перевод';

  @override
  String get cashBalance => 'Касса';

  @override
  String get noBalanceYet => 'Баланса пока нет. Его пополняет администратор.';

  @override
  String get cashierAppBarTitle => 'CRM – Кассир';

  @override
  String get cashierNotSetUp =>
      'Ваш аккаунт кассира не настроен. Обратитесь к администратору.';

  @override
  String get cashierSendSubtitle => 'Отправить деньги другому кассиру.';

  @override
  String get incomingTransfers => 'Входящие';

  @override
  String incomingWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count перевода ждут получения.',
      many: '$count переводов ждут получения.',
      few: '$count перевода ждут получения.',
      one: '$count перевод ждёт получения.',
    );
    return '$_temp0';
  }

  @override
  String get incomingSubtitle => 'Переводы, отправленные вам.';

  @override
  String get myTransfers => 'Мои переводы';

  @override
  String get myTransfersSubtitle => 'Все отправленные и полученные переводы.';

  @override
  String notEnoughBalance(Object available, Object currency) {
    return 'У вас только $available $currency.';
  }

  @override
  String get confirmTransferTitle => 'Отправить деньги?';

  @override
  String confirmTransferBody(Object amount, Object currency, Object name) {
    return '$amount $currency для $name. Сумма резервируется с вашего баланса, пока получатель её не примет.';
  }

  @override
  String transferSent(Object name) {
    return 'Отправлено $name. Ждём, пока получатель примет.';
  }

  @override
  String get noBalanceToSend => 'У вас нет баланса для отправки.';

  @override
  String get noOtherCashiers => 'Нет других кассиров для отправки.';

  @override
  String get recipientCashier => 'Получатель (кассир)';

  @override
  String availableBalance(Object amount, Object currency) {
    return 'Доступно: $amount $currency';
  }

  @override
  String get transferReservedHint =>
      'Сумма сразу списывается с вашего баланса и добавляется получателю, когда он её примет. Если он отклонит или вы отмените, деньги вернутся.';

  @override
  String get transfersTitle => 'Переводы';

  @override
  String get editCashierTitle => 'Изменить кассира';

  @override
  String get cashierUpdated => 'Кассир обновлён.';

  @override
  String get adjustBalance => 'Изменить баланс';

  @override
  String get adjustBalanceHint =>
      'Положительная сумма пополняет, отрицательная списывает.';

  @override
  String get balanceWouldBeNegative => 'Баланс не может быть отрицательным.';

  @override
  String get balanceUpdated => 'Баланс обновлён.';

  @override
  String get deleteCashierTitle => 'Удалить кассира?';

  @override
  String deleteCashierConfirm(Object name) {
    return '$name потеряет доступ к приложению, баланс будет удалён. Учётная запись для входа останется, её можно удалить в разделе Authentication в консоли Firebase.';
  }

  @override
  String get cashierDeleted => 'Кассир удалён.';

  @override
  String get cashiers => 'Кассиры';

  @override
  String get existingCashiers => 'Текущие кассиры';

  @override
  String get searchCashiersLabel => 'Поиск по имени, офису или менеджеру';

  @override
  String get officeOptional => 'Офис (необязательно)';

  @override
  String get managerOptional => 'Менеджер (необязательно)';

  @override
  String get noManagerAssigned => 'Без менеджера';

  @override
  String get cashierCreated => 'Кассир создан.';

  @override
  String couldNotCreateCashier(Object error) {
    return 'Не удалось создать кассира: $error';
  }

  @override
  String get requiredField => 'Обязательно';

  @override
  String get createNewCashier => 'Новый кассир';

  @override
  String get createCashier => 'Создать кассира';

  @override
  String get cashiersCardSubtitle =>
      'Создавайте кассиров, привязывайте их к офисам и менеджерам, пополняйте балансы.';

  @override
  String get myCashiers => 'Мои кассиры';

  @override
  String get myCashiersSubtitle =>
      'Кассиры, привязанные к вам или вашему офису, с балансами и переводами.';

  @override
  String get noCashiersLinked => 'К вам или вашему офису не привязаны кассиры.';

  @override
  String get archivedBadge => 'В архиве';

  @override
  String get restoreAction => 'Восстановить';

  @override
  String get archiveAction => 'В архив';

  @override
  String showArchived(Object count) {
    return 'Показать архив ($count)';
  }

  @override
  String get archiveTransactionTitle => 'Отправить перевод в архив?';

  @override
  String get archiveTransactionConfirm =>
      'Перевод выполнен и не может быть удалён. Он скрывается из списка, но по-прежнему учитывается в прибыли и экспорте. Его можно показать и восстановить через «Показать архив».';

  @override
  String get transactionArchived => 'Перевод отправлен в архив.';

  @override
  String get transactionRestored => 'Перевод восстановлен.';

  @override
  String get tierSilver => 'Серебро';

  @override
  String get tierGold => 'Золото';

  @override
  String get tierDiamond => 'Бриллиант';

  @override
  String get tierNone => 'Без уровня';

  @override
  String get tierLabel => 'Уровень клиента';

  @override
  String get customerTiers => 'Уровни клиентов';

  @override
  String get customerTiersCardSubtitle =>
      'Серебро, Золото и Бриллиант со скидкой на комиссию';

  @override
  String get customerTiersIntro =>
      'Скидка — это процентные пункты, которые вычитаются из комиссии, введённой менеджером. Пример: менеджер вводит 5 %, клиент уровня Золото со скидкой 1 % платит 4 %. Уровень клиенту назначается в разделе «Клиенты».';

  @override
  String tierDiscountLabel(Object tier) {
    return 'Скидка для уровня $tier';
  }

  @override
  String get tierInvalidValues => 'Введите число от 0 до 100.';

  @override
  String get tierSettingsSaved => 'Уровни клиентов сохранены.';

  @override
  String customerTierTitle(Object name) {
    return 'Уровень клиента $name';
  }

  @override
  String get customDiscountLabel => 'Своя скидка (необязательно)';

  @override
  String get customDiscountHelper =>
      'Оставьте пустым, чтобы использовать скидку уровня.';

  @override
  String tierFeeSummary(Object discount, Object fee) {
    return 'Скидка $discount п.п. Пример: комиссия 5 % → клиент платит $fee %.';
  }

  @override
  String get tierNoAccountNote =>
      'У клиента нет аккаунта в приложении. Уровень начнёт действовать, когда клиент будет отправлять заявки в приложении.';

  @override
  String get customerTierSaved => 'Уровень клиента сохранён.';

  @override
  String tierDiscountShort(Object discount) {
    return 'скидка $discount %';
  }

  @override
  String customerTierManagerLine(Object tier, Object discount) {
    return '$tier: скидка $discount % вычитается из введённой вами комиссии';
  }

  @override
  String customerTierBadge(Object tier, Object discount) {
    return '$tier – скидка $discount % на комиссию';
  }

  @override
  String tierFeeExample(Object fee) {
    return 'Пример: комиссия 5 % → клиент платит $fee %';
  }

  @override
  String feeAfterTierLine(Object base, Object discount, Object fee) {
    return '$base % − скидка $discount % = клиент платит $fee %';
  }

  @override
  String get buyCardSubtitle =>
      'Покупка валюты наличными в офисе или на ваш банк.';

  @override
  String get currencyToBuy => 'Валюта, которую вы покупаете';

  @override
  String get currencyToPayWith => 'Валюта, которой вы платите';

  @override
  String get howToReceive => 'Как вы хотите получить деньги?';

  @override
  String get deliveryCash => 'Наличными';

  @override
  String get deliveryBank => 'На мой банк';

  @override
  String get deliveryCashHint =>
      'Вы получаете деньги в офисе по коду или QR-коду.';

  @override
  String get deliveryBankHint =>
      'Когда офис получит вашу оплату, вы вводите банковские данные, и офис отправляет деньги туда.';

  @override
  String get chooseCurrenciesFirst => 'Сначала выберите валюты';

  @override
  String get officeForPickup => 'Офис, где вы получите деньги';

  @override
  String get officeForBankPayout => 'Офис, который принимает вашу оплату';

  @override
  String get amountToBuy => 'Сколько вы хотите купить?';

  @override
  String get sendBuyRequest => 'Отправить заявку на покупку';

  @override
  String get buyRequestSent => 'Заявка на покупку отправлена в офис.';

  @override
  String buySummary(Object amount, Object to, Object from) {
    return 'Покупка $amount $to за $from';
  }

  @override
  String youPay(Object amount, Object currency) {
    return 'Вы платите: $amount $currency';
  }

  @override
  String customerPays(Object amount, Object currency) {
    return 'Клиент платит: $amount $currency';
  }

  @override
  String get buyPriceComing =>
      'Офис рассчитает стоимость и отправит предложение.';

  @override
  String get paidOutToBankBody => 'Деньги отправлены на ваш банк.';

  @override
  String get enterBankDetailsIntro => 'Укажите, куда отправить деньги.';

  @override
  String get bankNameLabel => 'Название банка';

  @override
  String get bankPhoneLabel => 'Номер телефона';

  @override
  String get bankAccountHolderLabel => 'Имя и фамилия владельца счёта';

  @override
  String get sendBankDetails => 'Отправить банковские данные';

  @override
  String get fillAllBankFields => 'Заполните все поля (не более 100 символов).';

  @override
  String get bankDetailsWaiting => 'Спасибо! Офис отправит деньги на ваш банк.';

  @override
  String bankNameValue(Object value) {
    return 'Банк: $value';
  }

  @override
  String bankPhoneValue(Object value) {
    return 'Телефон: $value';
  }

  @override
  String bankAccountHolderValue(Object value) {
    return 'Владелец счёта: $value';
  }

  @override
  String get changeBankDetails => 'Изменить банковские данные';

  @override
  String get waitingForBankDetails =>
      'Ожидаем, пока клиент введёт банковские данные.';

  @override
  String sendToBankInstructions(Object amount, Object currency) {
    return 'Отправьте $amount $currency на банк клиента:';
  }

  @override
  String get markSentToBank => 'Деньги отправлены в банк';

  @override
  String confirmSentToBank(Object amount, Object currency) {
    return 'Вы отправили $amount $currency на банк клиента? Перевод будет выполнен, а баланс офиса обновлён.';
  }

  @override
  String get confirm => 'Подтвердить';

  @override
  String rateFieldLabel(Object from, Object to) {
    return 'Курс: 1 $from = ? $to';
  }

  @override
  String get invalidRate => 'Введите курс больше 0.';

  @override
  String rateChangedFromMarket(Object rate) {
    return 'Свой курс. Рыночный курс: $rate';
  }

  @override
  String get marketRateUsed => 'Рыночный курс. Вы можете его изменить.';

  @override
  String get useMarketRate => 'Использовать рыночный курс';

  @override
  String get pickupCodeDigitsHint =>
      'Вводите только цифры, дефисы добавятся автоматически.';

  @override
  String get balancesTitle => 'Баланс';

  @override
  String get officeBalanceTitle => 'Баланс офиса';

  @override
  String get cashierBalancesTitle => 'Балансы кассиров';

  @override
  String get balancesCardSubtitle => 'Баланс офиса и кассиров, отдельно.';

  @override
  String get noBalance => 'Нет баланса.';

  @override
  String get sellCardSubtitle =>
      'Продайте валюту и получите деньги наличными или на банк.';

  @override
  String get currencyToSell => 'Валюта, которую вы продаёте';

  @override
  String get currencyToReceive => 'Валюта, которую вы хотите получить';

  @override
  String get amountToSell => 'Сколько вы хотите продать?';

  @override
  String get sendSellRequest => 'Отправить заявку на продажу';

  @override
  String get sellRequestSent => 'Заявка на продажу отправлена в офис.';

  @override
  String sellSummary(Object amount, Object from, Object to) {
    return 'Продажа $amount $from за $to';
  }

  @override
  String get partners => 'Партнёры';

  @override
  String get partnersCardSubtitle => 'Обмен валюты с вашими партнёрами.';

  @override
  String get partnersAdminCardSubtitle =>
      'Создавайте партнёров и привязывайте их к офису или менеджеру.';

  @override
  String get editPartnerTitle => 'Изменить партнёра';

  @override
  String get partnerUpdated => 'Партнёр обновлён.';

  @override
  String get deletePartnerTitle => 'Удалить партнёра?';

  @override
  String deletePartnerConfirm(Object name) {
    return '$name больше не сможет войти в приложение, а баланс будет удалён. Учётная запись для входа останется, её можно удалить в разделе Authentication в консоли Firebase.';
  }

  @override
  String get partnerDeleted => 'Партнёр удалён.';

  @override
  String get existingPartners => 'Партнёры';

  @override
  String get searchPartnersLabel => 'Поиск партнёра (имя, офис, менеджер)';

  @override
  String get createNewPartner => 'Создать партнёра';

  @override
  String get createPartner => 'Создать партнёра';

  @override
  String get partnerCreated => 'Партнёр создан.';

  @override
  String couldNotCreatePartner(Object error) {
    return 'Не удалось создать партнёра: $error';
  }

  @override
  String get partnerAppBarTitle => 'CRM – Партнёр';

  @override
  String get partnerNotSetUp =>
      'Ваш аккаунт партнёра ещё не привязан к офису. Обратитесь к администратору.';

  @override
  String get newExchange => 'Новое предложение обмена';

  @override
  String get exchangesTitle => 'Обмены';

  @override
  String get partnerBalancesTitle => 'Балансы партнёров';

  @override
  String get noPartnersLinked =>
      'К вам или вашему офису не привязаны партнёры.';

  @override
  String get exchangeProposed => 'Предложение';

  @override
  String get exchangeAccepted => 'Принято';

  @override
  String get exchangeRejected => 'Отклонено';

  @override
  String get exchangeCancelled => 'Отменено';

  @override
  String get exchangeCompleted => 'Выполнено';

  @override
  String get noExchangesYet => 'Обменов пока нет.';

  @override
  String exchangeOfficeGives(Object amount) {
    return 'Офис отдаёт: $amount';
  }

  @override
  String exchangePartnerGives(Object amount) {
    return 'Партнёр отдаёт: $amount';
  }

  @override
  String exchangeYouGive(Object amount) {
    return 'Вы отдаёте: $amount';
  }

  @override
  String exchangeYouGet(Object amount) {
    return 'Вы получаете: $amount';
  }

  @override
  String exchangeRateLine(Object from, Object rate, Object to) {
    return 'Курс: 1 $from = $rate $to';
  }

  @override
  String get exchangeOfficeSentDone => '✓ Офис отправил';

  @override
  String get exchangeOfficeSentWaiting => '… Офис ещё не отправил';

  @override
  String get exchangePartnerSentDone => '✓ Партнёр отправил';

  @override
  String get exchangePartnerSentWaiting => '… Партнёр ещё не отправил';

  @override
  String get counterProposal => 'Встречное предложение';

  @override
  String get waitingForAnswer => 'Ожидает ответа';

  @override
  String markExchangeSent(Object amount) {
    return 'Я отправил $amount';
  }

  @override
  String get confirmExchangeSent =>
      'Подтвердите, что вы отправили деньги. Другая сторона увидит это и подтвердит получение.';

  @override
  String markExchangeReceived(Object amount) {
    return 'Я получил $amount';
  }

  @override
  String get confirmExchangeReceived =>
      'Подтвердите, что деньги пришли. Когда обе стороны подтвердят, обмен будет выполнен, а балансы обновлены.';

  @override
  String get waitingForOtherReceived =>
      'Ожидаем, пока другая сторона подтвердит получение денег.';

  @override
  String get youGiveLabel => 'Сумма, которую вы отдаёте';

  @override
  String get youGetLabel => 'Сумма, которую вы получаете';

  @override
  String get currencyYouGive => 'Валюта, которую вы отдаёте';

  @override
  String get currencyYouGet => 'Валюта, которую вы получаете';

  @override
  String get exchangeProposalSent => 'Предложение отправлено.';

  @override
  String get choosePartner => 'Партнёр';

  @override
  String get sendProposal => 'Отправить предложение';

  @override
  String get searchExistingCustomer => 'Найти существующего клиента';

  @override
  String get noCustomerFoundNew =>
      'Клиент не найден. Введите нового клиента ниже.';

  @override
  String get orNewCustomer => 'Или новый клиент:';

  @override
  String get hasAppAccount => 'Есть аккаунт в приложении';

  @override
  String get noAppAccount => 'Нет аккаунта в приложении';

  @override
  String get changeCustomer => 'Сменить';

  @override
  String get inviteCustomerQuestion => 'Клиент хочет стать нашим клиентом?';

  @override
  String get inviteCustomerHint =>
      'Клиент будет сохранён в базе клиентов и получит ссылку по SMS для создания аккаунта в приложении.';

  @override
  String get invitePhoneRequired =>
      'Введите номер телефона клиента, чтобы отправить ссылку.';

  @override
  String inviteSmsText(Object name, Object link) {
    return 'Здравствуйте, $name! Добро пожаловать к нам. Создайте аккаунт здесь: $link';
  }

  @override
  String inviteWelcome(Object clientId) {
    return 'Добро пожаловать! Вы уже наш клиент с ID $clientId. Создайте аккаунт ниже, чтобы видеть свои переводы в приложении.';
  }

  @override
  String get inviteInvalid =>
      'Ссылка больше не действует. Вы всё равно можете создать аккаунт ниже.';

  @override
  String get alreadyHaveAccountLogin => 'Уже есть аккаунт? Войти';

  @override
  String get attachReceiptOptional => 'Прикрепить квитанцию (необязательно)';

  @override
  String get officeReceipt => 'Квитанция офиса';

  @override
  String get partnerReceipt => 'Квитанция партнёра';
}
