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
}
