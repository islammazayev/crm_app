// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CRM App';

  @override
  String get languageTooltip => 'Dil';

  @override
  String get languageSystem => 'Cihaz dili';

  @override
  String errorWithDetails(Object error) {
    return 'Hata: $error';
  }

  @override
  String get noRoleFound => 'Kullanıcı için rol bulunamadı';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String phoneValue(Object phone) {
    return 'Telefon: $phone';
  }

  @override
  String emailValue(Object email) {
    return 'E-posta: $email';
  }

  @override
  String clientIdValue(Object clientId) {
    return 'Müşteri No: $clientId';
  }

  @override
  String get statusRequested => 'Yeni talep';

  @override
  String get statusProposed => 'Teklif gönderildi';

  @override
  String get statusAccepted => 'Müşteri kabul etti';

  @override
  String get statusRejected => 'Müşteri reddetti';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get customerStatusRequested => 'Gönderildi – yönetici bekleniyor';

  @override
  String get customerStatusProposed =>
      'Yöneticiden teklif – ayrıntılar için dokunun';

  @override
  String get customerStatusAccepted => 'Kabul edildi – ödeme bilgileri gelecek';

  @override
  String get customerStatusRejected => 'Reddedildi';

  @override
  String reportTotalOrders(Object total, Object completed) {
    return 'Toplam sipariş: $total (tamamlanan: $completed)';
  }

  @override
  String reportTotalProfit(Object profit) {
    return 'Şirketin toplam kârı (tamamlanan): $profit';
  }

  @override
  String get reportProfitPerDay => 'Günlük kâr:';

  @override
  String get noOrdersYet => 'Henüz sipariş yok.';

  @override
  String orderStatusLine(Object status) {
    return 'Durum: $status';
  }

  @override
  String orderDetails(Object currency, Object amount, Object fee) {
    return 'Döviz: $currency, Tutar: $amount, Ücret: $fee';
  }

  @override
  String dateValue(Object date) {
    return 'Tarih: $date';
  }

  @override
  String get noCustomersYet => 'Henüz müşteri yok.';

  @override
  String get deleteCustomerTitle => 'Müşteriyi sil';

  @override
  String deleteCustomerConfirm(Object clientId, Object name) {
    return '#$clientId $name müşterisini gerçekten silmek istiyor musunuz?';
  }

  @override
  String get customerAppBarTitle => 'CRM – Müşteri';

  @override
  String get myTransactions => 'İşlemlerim';

  @override
  String welcomeName(Object name) {
    return 'Hoş geldiniz, $name';
  }

  @override
  String get tabSend => 'Gönder';

  @override
  String get tabBuy => 'Al';

  @override
  String get tabSell => 'Sat';

  @override
  String get tabExchange => 'Döviz bozdur';

  @override
  String comingSoon(Object section) {
    return '$section – yakında';
  }

  @override
  String get noTransactionsYet => 'Henüz işlem yok';

  @override
  String get transaction => 'İşlem';

  @override
  String get transactions => 'İşlemler';

  @override
  String youSend(Object amount, Object currency) {
    return 'Gönderdiğiniz: $amount $currency';
  }

  @override
  String exchangeRateValue(Object from, Object rate, Object to) {
    return 'Kur: 1 $from = $rate $to';
  }

  @override
  String grossReceived(Object amount, Object currency) {
    return 'Brüt alınan: $amount $currency';
  }

  @override
  String feeValue(
    Object percent,
    Object feeFrom,
    Object from,
    Object feeTo,
    Object to,
  ) {
    return 'Ücret: %$percent ($feeFrom $from ≈ $feeTo $to)';
  }

  @override
  String youReceive(Object amount, Object currency) {
    return 'Alacağınız: $amount $currency';
  }

  @override
  String paymentTo(Object label) {
    return 'Ödeme yapılacak hesap: $label';
  }

  @override
  String payAmountTo(Object amount, Object currency) {
    return '$amount $currency tutarını şuraya ödeyin:';
  }

  @override
  String get acceptedWaitingPayment =>
      'Teklifi kabul ettiniz. Yönetici kısa süre içinde ödeme bilgilerini gönderecek.';

  @override
  String get accept => 'Kabul et';

  @override
  String get reject => 'Reddet';

  @override
  String get waitingForProposal => 'Yöneticinin teklif göndermesi bekleniyor.';

  @override
  String get noSignedInUser => 'Giriş yapmış kullanıcı yok.';

  @override
  String couldNotLoadCustomer(Object error) {
    return 'Müşteri yüklenemedi: $error';
  }

  @override
  String get managerStatusRequested => 'Müşteriden yeni talep';

  @override
  String get managerStatusProposed => 'Teklif gönderildi – müşteri bekleniyor';

  @override
  String get managerStatusAccepted => 'Müşteri teklifi kabul etti';

  @override
  String get managerStatusRejected => 'Müşteri işlemi iptal etti';

  @override
  String get unknownClient => 'Bilinmeyen müşteri';

  @override
  String get authWrongCredentials => 'E-posta veya şifre yanlış.';

  @override
  String get authInvalidEmail => 'Geçersiz e-posta adresi.';

  @override
  String get authEmailInUse => 'Bu e-posta adresiyle bir hesap zaten var.';

  @override
  String get authWeakPassword => 'Şifre çok zayıf.';

  @override
  String get authMissingEmail => 'Önce e-posta adresinizi girin.';

  @override
  String get authTooManyRequests =>
      'Çok fazla deneme. Biraz bekleyip tekrar deneyin.';

  @override
  String get authNetworkError =>
      'Bağlantı yok. İnternetinizi kontrol edip tekrar deneyin.';

  @override
  String get authUserDisabled => 'Hesap devre dışı bırakılmış.';

  @override
  String get loginTagline => 'DÖVİZ BÜROSU';

  @override
  String get login => 'Giriş yap';

  @override
  String get loginSubtitle => 'Devam etmek için bilgilerinizi girin';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get resetLinkSent =>
      'Şifre sıfırlama bağlantısı e-postanıza gönderildi.';

  @override
  String get forgotPassword => 'Şifrenizi mi unuttunuz?';

  @override
  String get registerAccount => 'Hesap oluştur';

  @override
  String get registerTitle => 'Müşteri olarak kaydolun';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get phone => 'Telefon';

  @override
  String get enterFirstName => 'Adınızı girin';

  @override
  String get enterLastName => 'Soyadınızı girin';

  @override
  String get enterValidEmail => 'Geçerli bir e-posta girin';

  @override
  String get passwordMinLength => 'En az 6 karakter';

  @override
  String get register => 'Kaydol';

  @override
  String couldNotCreateCustomer(Object error) {
    return 'Müşteri oluşturulamadı: $error';
  }

  @override
  String get clientIdMustBeInteger => 'Müşteri No tam sayı olmalıdır';

  @override
  String get customerSaved => 'Müşteri kaydedildi!';

  @override
  String get createUpdateCustomer => 'Müşteri oluştur / güncelle';

  @override
  String get clientIdOptional => 'Müşteri No (isteğe bağlı)';

  @override
  String get clientIdHint => 'örn. 007';

  @override
  String get saveCustomer => 'Müşteriyi kaydet';

  @override
  String get office => 'Şube';

  @override
  String couldNotLoadOffices(Object error) {
    return 'Şubeler yüklenemedi: $error';
  }

  @override
  String get fillAllFieldsValidAmount =>
      'Tüm alanları geçerli bir tutarla doldurun';

  @override
  String get noCustomerProfile =>
      'Bu kullanıcı için müşteri profili bulunamadı';

  @override
  String get requestSentToOffice => 'Talep şubeye gönderildi';

  @override
  String couldNotCreateTransaction(Object error) {
    return 'İşlem oluşturulurken hata: $error';
  }

  @override
  String get noOfficesAvailable => 'Şu anda gönderim yapılabilecek şube yok.';

  @override
  String get currencyYouSend => 'Gönderdiğiniz döviz';

  @override
  String get chooseOfficeFirstCurrency => 'Şube seçin (önce dövizi seçin)';

  @override
  String officesHandlingCurrency(Object currency) {
    return '$currency ile çalışan şubeler';
  }

  @override
  String get currencyRecipientGets => 'Alıcının alacağı döviz';

  @override
  String get amountToSend => 'Gönderilecek tutar';

  @override
  String get send => 'Gönder';

  @override
  String get managerCreated => 'Yönetici oluşturuldu.';

  @override
  String couldNotCreateManager(Object error) {
    return 'Yönetici oluşturulamadı: $error';
  }

  @override
  String unexpectedError(Object error) {
    return 'Beklenmeyen hata: $error';
  }

  @override
  String get createOfficeBeforeManager =>
      'Yönetici eklemeden önce en az bir şube oluşturun.';

  @override
  String get createNewManager => 'Yeni yönetici oluştur';

  @override
  String get enterEmail => 'E-posta girin';

  @override
  String get createManager => 'Yönetici oluştur';

  @override
  String couldNotLoadOfficeCurrencies(Object error) {
    return 'Şubenin dövizleri okunamadı: $error';
  }

  @override
  String get enterCustomerName => 'Müşterinin adını girin.';

  @override
  String get chooseTwoDifferentCurrencies => 'İki farklı döviz seçin.';

  @override
  String get enterAmountAboveZero => '0\'dan büyük bir tutar girin.';

  @override
  String get enterFeeRange => '0 ile 100 arasında bir ücret (%) girin.';

  @override
  String get createNewTransaction => 'Yeni işlem oluştur';

  @override
  String get customerName => 'Müşterinin adı';

  @override
  String get phoneOptional => 'Telefon (isteğe bağlı)';

  @override
  String get customerGivesCurrency => 'Müşterinin verdiği döviz';

  @override
  String get customerGetsCurrency => 'Müşterinin alacağı döviz';

  @override
  String get amountCustomerGives => 'Müşterinin verdiği tutar';

  @override
  String get feePercentLabel => 'Ücret (%)';

  @override
  String get creating => 'Oluşturuluyor …';

  @override
  String get createTransaction => 'İşlem oluştur';

  @override
  String get chooseAtLeastOneCurrency => 'En az bir döviz seçin';

  @override
  String get country => 'Ülke';

  @override
  String get city => 'Şehir';

  @override
  String get enterCountry => 'Ülke girin';

  @override
  String get enterCity => 'Şehir girin';

  @override
  String get currencies => 'Dövizler';

  @override
  String get paymentMethods => 'Ödeme yöntemleri';

  @override
  String get add => 'Ekle';

  @override
  String get noPaymentMethodsYet =>
      'Henüz ödeme yöntemi yok. Eklemek için \"Ekle\"ye dokunun.';

  @override
  String get createOffice => 'Şube oluştur';

  @override
  String methodNumber(Object number) {
    return 'Yöntem $number';
  }

  @override
  String get removeMethod => 'Yöntemi kaldır';

  @override
  String get methodName => 'Yöntem adı';

  @override
  String get methodNameHint => 'örn. SEB SEK hesabı, USDT TRC20';

  @override
  String get methodDetails => 'Ayrıntılar (hesap no, IBAN, cüzdan adresi vb.)';

  @override
  String get methodDetailsHint => 'örn. IBAN: SE12 3456...';

  @override
  String get supportsCurrencies => 'Desteklenen dövizler';

  @override
  String get managerAppBarTitle => 'CRM – Yönetici';

  @override
  String managerAppBarTitleWithOffice(Object office) {
    return 'CRM – Yönetici ($office)';
  }

  @override
  String get managerPanel => 'Yönetici paneli';

  @override
  String get managerPanelIntro =>
      'Ne üzerinde çalışmak istediğinizi seçin. Yeni, devam eden ve biten işlemleri burada hızlıca görürsünüz.';

  @override
  String get createTransactionCardSubtitle =>
      'Şubeye gelen ve hesabı olmayan bir müşteriyi kaydedin.';

  @override
  String get newCustomerTransactions => 'Yeni müşteri işlemleri';

  @override
  String get newCustomerTransactionsSubtitle =>
      'Müşterilerden gelen ve henüz başlanmamış yeni siparişler.';

  @override
  String get ongoingTransactions => 'Devam eden işlemler';

  @override
  String get ongoingTransactionsSubtitle =>
      'Müşteriyi bekleyen teklifler ile ödenip tamamlanacak kabul edilmiş işlemler.';

  @override
  String get finishedTransactions => 'Biten işlemler';

  @override
  String get finishedTransactionsSubtitle =>
      'Tamamlanan ve reddedilen işlemler.';

  @override
  String calculationError(Object error) {
    return 'Hesaplama hatası: $error';
  }

  @override
  String get paymentDetailsSent => 'Ödeme bilgileri müşteriye gönderildi.';

  @override
  String insufficientBalance(Object currency, Object available, Object needed) {
    return 'Şubenin $currency bakiyesi yetersiz ($available mevcut, $needed gerekli). Yöneticiden bakiye yüklemesini isteyin.';
  }

  @override
  String get transactionManager => 'İşlem (yönetici)';

  @override
  String customerSends(Object amount, Object currency) {
    return 'Müşterinin gönderdiği: $amount $currency';
  }

  @override
  String toCurrencyValue(Object currency) {
    return 'Hedef döviz: $currency';
  }

  @override
  String customerReceives(Object amount, Object currency) {
    return 'Müşterinin alacağı: $amount $currency';
  }

  @override
  String get calculating => 'Hesaplanıyor...';

  @override
  String paymentMethodValue(Object label) {
    return 'Ödeme yöntemi: $label';
  }

  @override
  String get officeNotFound => 'Şube bulunamadı.';

  @override
  String get noPaymentMethodsForCurrency => 'Bu döviz için ödeme yöntemi yok.';

  @override
  String get choosePaymentMethodForCustomer =>
      'Müşteriye gönderilecek ödeme yöntemini seçin:';

  @override
  String get proposeTerms => 'Teklif gönder';

  @override
  String sentToCustomer(Object label) {
    return 'Müşteriye gönderildi: $label';
  }

  @override
  String get resendPaymentDetails => 'Ödeme bilgilerini yeniden gönder';

  @override
  String get sendPaymentDetailsToCustomer =>
      'Ödeme bilgilerini müşteriye gönder';

  @override
  String get markAsCompleted => 'Tamamlandı olarak işaretle';

  @override
  String get noOfficesYet => 'Henüz şube oluşturulmadı.';

  @override
  String get searchCountryOrCity => 'Ülke veya şehre göre ara...';

  @override
  String officesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count şube bulundu',
      one: '1 şube bulundu',
    );
    return '$_temp0';
  }

  @override
  String get noOfficesMatch => 'Aramayla eşleşen şube yok.';

  @override
  String balanceValue(Object balances) {
    return 'Bakiye: $balances';
  }

  @override
  String get managerLoading => 'Yönetici: yükleniyor …';

  @override
  String get managerNone => 'Yönetici: –';

  @override
  String managerValue(Object name) {
    return 'Yönetici: $name';
  }

  @override
  String get managerUnknown => 'Yönetici: (bilinmiyor)';

  @override
  String get editOffice => 'Şubeyi düzenle';

  @override
  String get topUpBalance => 'Bakiye yükle';

  @override
  String get deleteOffice => 'Şubeyi sil';

  @override
  String noCustomerWithClientId(Object clientId) {
    return '$clientId numaralı müşteri bulunamadı';
  }

  @override
  String editCustomerTitle(Object clientId) {
    return 'Müşteriyi düzenle #$clientId';
  }

  @override
  String get customerUpdated => 'Müşteri güncellendi!';

  @override
  String get save => 'Kaydet';

  @override
  String get customerDeleted => 'Müşteri silindi.';

  @override
  String get searchClientId => 'Müşteri No ara';

  @override
  String get search => 'Ara';

  @override
  String customerNumber(Object clientId) {
    return 'Müşteri #$clientId';
  }

  @override
  String get edit => 'Düzenle';

  @override
  String nameValue(Object name) {
    return 'Ad: $name';
  }

  @override
  String get officeUpdated => 'Şube güncellendi!';

  @override
  String get editOfficeTitle => 'Şubeyi düzenle';

  @override
  String get methodIdLabel => 'ID (örn. usdt-trc20)';

  @override
  String get name => 'Ad';

  @override
  String get methodDetailsShort => 'Ayrıntılar (IBAN, cüzdan vb.)';

  @override
  String get supportedFromCurrency => 'Desteklenen döviz (fromCurrency)';

  @override
  String get saveChanges => 'Değişiklikleri kaydet';

  @override
  String get officeCreated => 'Şube oluşturuldu!';

  @override
  String get deleteOfficeQuestion => 'Şube silinsin mi?';

  @override
  String get deleteOfficeConfirm =>
      'Şube kalıcı olarak silinecek. Emin misiniz?';

  @override
  String get deleteAction => 'Sil';

  @override
  String get officeDeleted => 'Şube silindi';

  @override
  String deleteError(Object error) {
    return 'Silme hatası: $error';
  }

  @override
  String startBalance(Object currency) {
    return 'Başlangıç bakiyesi $currency';
  }

  @override
  String get assignManager => 'Yönetici ata';

  @override
  String get noManagersYet => 'Henüz kayıtlı yönetici yok.';

  @override
  String get manager => 'Yönetici';

  @override
  String get noPaymentMethodsAdded => 'Henüz ödeme yöntemi eklenmedi.';

  @override
  String get searchManageOffices => 'Şube ara ve yönet';

  @override
  String get noOfficesFound => 'Şube bulunamadı.';

  @override
  String officeSummary(Object currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ödeme yöntemi',
      one: '1 ödeme yöntemi',
    );
    return 'Dövizler: $currencies\n$_temp0';
  }

  @override
  String get exportDate => 'Tarih';

  @override
  String get exportStatus => 'Durum';

  @override
  String get exportClientId => 'Müşteri No';

  @override
  String get exportOffice => 'Şube';

  @override
  String get exportFrom => 'Kaynak';

  @override
  String get exportTo => 'Hedef';

  @override
  String get exportAmount => 'Tutar';

  @override
  String get exportFee => 'Ücret';

  @override
  String get exportPayout => 'Ödenecek';

  @override
  String get noTransactionsToExport => 'Dışa aktarılacak işlem yok';

  @override
  String get orderReport => 'Sipariş raporu';

  @override
  String get adminAppBarTitle => 'CRM – Yönetim';

  @override
  String get adminHeadline => 'Yönetim paneli: Tam kontrol';

  @override
  String get manageOffices => 'Şubeleri yönet';

  @override
  String get officeHasNoCurrencies =>
      'Şubenin dövizi yok. Önce \"Şubeyi düzenle\" ile bir döviz ekleyin.';

  @override
  String get currency => 'Döviz';

  @override
  String get amount => 'Tutar';

  @override
  String get ok => 'Tamam';

  @override
  String get orderHistory => 'Sipariş geçmişi';

  @override
  String get filterByOffice => 'Şubeye göre filtrele (isteğe bağlı)';

  @override
  String get allOffices => 'Tüm şubeler';

  @override
  String get chooseDateRange => 'Tarih aralığı seç';

  @override
  String get clearDates => 'Tarihleri temizle';

  @override
  String get exportCsv => 'CSV dışa aktar';

  @override
  String get exportPdf => 'PDF dışa aktar';

  @override
  String get chooseDateRangeHint =>
      'İşlemleri görmek için bir tarih aralığı seçin.';

  @override
  String clientShort(Object clientId) {
    return 'Müşteri $clientId';
  }

  @override
  String get rateMissingApiKey =>
      'Döviz kuru API anahtarı eksik. Uygulamayı --dart-define-from-file=fx_key.json ile derleyin.';

  @override
  String rateHttpError(Object code) {
    return 'Döviz kuru alınamadı (HTTP $code).';
  }

  @override
  String rateNotFound(Object from, Object to) {
    return '$from → $to için kur bulunamadı.';
  }

  @override
  String get customers => 'Müşteriler';

  @override
  String get offices => 'Şubeler';

  @override
  String get managers => 'Yöneticiler';

  @override
  String get adminPanel => 'Yönetim paneli';

  @override
  String get adminPanelIntro =>
      'Neyi yöneteceğinizi seçin. Her karttaki sayı kaç tane olduğunu gösterir.';

  @override
  String get customersCardSubtitle =>
      'Müşteri oluşturun, arayın, düzenleyin ve silin.';

  @override
  String get officesCardSubtitle =>
      'Şube oluşturun, döviz ve ödeme yöntemlerini düzenleyin, bakiye yükleyin.';

  @override
  String get managersCardSubtitle =>
      'Yönetici oluşturun ve hangi şubede çalıştıklarını görün.';

  @override
  String get ordersCardSubtitle =>
      'Filtreler, kâr raporu ve CSV/PDF dışa aktarma ile tüm işlemler.';

  @override
  String get existingManagers => 'Mevcut yöneticiler';

  @override
  String get noOfficeAssigned => 'Şube yok';

  @override
  String officeValue(Object office) {
    return 'Şube: $office';
  }

  @override
  String get searchCustomers => 'Müşteri ara';

  @override
  String get searchCustomersLabel => 'Müşteri No, ad, telefon, ülke veya şehir';

  @override
  String get searchCustomersHint => 'örn. 00, Ali, 0731, Grozni';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String customersShown(int shown, int total) {
    return '$total müşteriden $shown gösteriliyor';
  }

  @override
  String get noCustomersMatch => 'Aramayla eşleşen müşteri yok.';

  @override
  String placesValue(Object places) {
    return 'Şubeler: $places';
  }

  @override
  String typeToSearchCustomers(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other:
          'Müşterileri görmek için arama kutusuna yazın (toplam $total müşteri).',
      one: 'Müşterileri görmek için arama kutusuna yazın (toplam 1 müşteri).',
    );
    return '$_temp0';
  }

  @override
  String customersShownLimited(int shown, int count) {
    return '$count eşleşmenin ilk $shown tanesi gösteriliyor. Daraltmak için daha fazla yazın.';
  }

  @override
  String typeToSearch(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Sonuçları görmek için arama kutusuna yazın (toplam $total).',
      one: 'Sonuçları görmek için arama kutusuna yazın (toplam 1).',
    );
    return '$_temp0';
  }

  @override
  String get noSearchMatches => 'Sonuç yok.';

  @override
  String searchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sonuç',
      one: '1 sonuç',
    );
    return '$_temp0';
  }

  @override
  String get searchOfficesLabel => 'Ülke, şehir veya dövize göre ara';

  @override
  String get searchManagersLabel => 'Ad, e-posta, telefon veya şubeye göre ara';

  @override
  String get searchTransactionsLabel =>
      'No, müşteri No, ad, telefon, şube, döviz veya durum';

  @override
  String get searchTransactionsHint => 'örn. T-00012, 00, Ali, Grozni, RUB';

  @override
  String get searchOrChooseDatesHint =>
      'İşlemleri görmek için arama kutusuna yazın veya bir tarih aralığı seçin.';

  @override
  String get editManagerTitle => 'Yöneticiyi düzenle';

  @override
  String get managerUpdated => 'Yönetici güncellendi.';

  @override
  String get deleteManagerTitle => 'Yönetici silinsin mi?';

  @override
  String deleteManagerConfirm(Object name) {
    return '$name artık uygulamaya erişemeyecek. Giriş hesabı kalır; Firebase konsolunda Authentication bölümünden silinebilir.';
  }

  @override
  String get managerDeleted => 'Yönetici silindi.';

  @override
  String get editTransactionTitle => 'İşlemi düzenle';

  @override
  String get statusChangeNoBalance =>
      'Durumu değiştirmek şube bakiyesini değiştirmez.';

  @override
  String get transactionUpdated => 'İşlem güncellendi.';

  @override
  String get deleteTransactionTitle => 'İşlem silinsin mi?';

  @override
  String get deleteTransactionConfirm =>
      'İşlem kalıcı olarak silinecek. Şube bakiyesi değişmez.';

  @override
  String get customerPanel => 'Ne yapmak istersiniz?';

  @override
  String get sendMoney => 'Para gönder';

  @override
  String get sendMoneySubtitle => 'Döviz ve şube seçip talep gönderin.';

  @override
  String get myTransactionsSubtitle =>
      'İşlemlerinizi takip edin ve tekliflere yanıt verin.';

  @override
  String offersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teklif yanıtınızı bekliyor.',
      one: '1 teklif yanıtınızı bekliyor.',
    );
    return '$_temp0';
  }

  @override
  String get soonBadge => 'Yakında';

  @override
  String get statusCountered => 'Müşteriden karşı teklif';

  @override
  String get customerStatusCountered =>
      'Karşı teklif gönderildi – yönetici bekleniyor';

  @override
  String get managerStatusCountered => 'Müşteri karşı teklif gönderdi';

  @override
  String get counterOffer => 'Karşı teklif';

  @override
  String get counterOfferAlreadyUsed =>
      'Bu işlem için karşı teklif hakkınızı zaten kullandınız.';

  @override
  String yourCounterOffer(Object fee) {
    return 'Karşı teklifiniz: %$fee ücret';
  }

  @override
  String get waitingForManagerAnswer => 'Yöneticinin yanıtı bekleniyor.';

  @override
  String counterOfferIntro(Object fee) {
    return 'Yönetici %$fee ücret öneriyor. Siz hangi ücreti öneriyorsunuz?';
  }

  @override
  String get counterFeeLabel => 'Önerdiğiniz ücret (%)';

  @override
  String youWouldReceive(Object amount, Object currency) {
    return 'Alacağınız: $amount $currency';
  }

  @override
  String get messageOptional => 'Mesaj (isteğe bağlı)';

  @override
  String get counterOfferOnce =>
      'Her işlem için yalnızca bir karşı teklif gönderebilirsiniz.';

  @override
  String counterFeeMustBeLower(Object fee) {
    return '0 veya daha yüksek ve %$fee değerinden düşük bir ücret girin.';
  }

  @override
  String get sendCounterOffer => 'Karşı teklif gönder';

  @override
  String get counterOfferSent => 'Karşı teklifiniz gönderildi.';

  @override
  String customerCounterOffer(Object counter, Object fee) {
    return 'Müşteri %$fee yerine %$counter ücret öneriyor.';
  }

  @override
  String get counterOfferManagerHint =>
      'Müşterinin ücretini kabul edin veya yeni bir teklif gönderin. Müşteri tekrar karşı teklif veremez.';

  @override
  String acceptCounterOffer(Object fee) {
    return '%$fee kabul et';
  }

  @override
  String get sendNewProposal => 'Yeni teklif gönder';

  @override
  String get counterOfferAccepted => 'Karşı teklif kabul edildi.';

  @override
  String transactionNoValue(Object no) {
    return 'İşlem $no';
  }

  @override
  String get exportNo => 'No';

  @override
  String get statusPaid => 'Müşteri ödedi';

  @override
  String get statusPaymentConfirmed => 'Ödeme onaylandı';

  @override
  String get customerStatusPaid => 'Ödeme gönderildi – yönetici kontrol ediyor';

  @override
  String get customerStatusPaymentConfirmed =>
      'Teslim alınmaya hazır – kodunuza bakın';

  @override
  String get managerStatusPaid => 'Müşteri ödedi – ödemeyi kontrol edin';

  @override
  String get managerStatusPaymentConfirmed =>
      'Ödeme onaylandı – teslim bekleniyor';

  @override
  String readyForPickup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count işlem teslim alınmaya hazır.',
      one: '1 işlem teslim alınmaya hazır.',
    );
    return '$_temp0';
  }

  @override
  String get iHavePaid => 'Ödedim';

  @override
  String get markPaidIntro =>
      'Yöneticinin ödemeyi daha hızlı kontrol edebilmesi için dekontu (fotoğraf veya PDF) ekleyin.';

  @override
  String get attachReceipt => 'Dekont ekle';

  @override
  String get changeReceipt => 'Dekontu değiştir';

  @override
  String get receiptTooLarge => 'Dosya çok büyük (en fazla 10 MB).';

  @override
  String get confirmPaid => 'Gönder';

  @override
  String get markedAsPaidSent =>
      'Teşekkürler! Yönetici ödemeyi kontrol ediyor.';

  @override
  String get markedAsPaid => 'Ödendi olarak işaretlediniz';

  @override
  String get managerCheckingPayment =>
      'Yönetici ödemeyi kontrol ediyor ve ulaşır ulaşmaz onaylayacak.';

  @override
  String get showReceipt => 'Dekontu göster';

  @override
  String get paymentMissingTitle => 'Ödeme ulaşmadı';

  @override
  String get paymentConfirmedTitle => 'Ödeme onaylandı';

  @override
  String get yourPickupCode => 'Teslim alma kodunuz';

  @override
  String pickupCodeInstructions(Object amount, Object currency) {
    return '$amount $currency teslim almak için kodu şubede gösterin. Kodu yalnızca parayı alacak kişiyle paylaşın.';
  }

  @override
  String get paidOutTitle => 'Ödendi';

  @override
  String get paidOutBody => 'Para teslim alındı. Teşekkürler!';

  @override
  String get wrongPickupCode =>
      'Yanlış kod. Müşterinin gösterdiği kodu kontrol edin.';

  @override
  String get paymentConfirmedSent => 'Ödeme onaylandı ve müşteri kodunu aldı.';

  @override
  String get paymentMissing => 'Ödeme yok';

  @override
  String get paymentMissingDefault =>
      'Ödemenizi henüz almadık. Lütfen ödemeyi kontrol edip tekrar deneyin.';

  @override
  String get messageToCustomer => 'Müşteriye mesaj';

  @override
  String get confirmPayment => 'Ödemeyi onayla';

  @override
  String get customerMarkedPaid => 'Müşteri ödendi olarak işaretledi';

  @override
  String showReceiptNamed(Object name) {
    return 'Dekontu göster $name';
  }

  @override
  String get noReceiptAttached => 'Dekont eklenmedi.';

  @override
  String get paymentConfirmedManager => 'Ödeme onaylandı';

  @override
  String payoutInstructions(Object amount, Object currency) {
    return 'Müşteri teslim alma kodunu gösterdiğinde $amount $currency ödeyin.';
  }

  @override
  String giveCodeToWalkIn(Object code) {
    return 'Müşterinin hesabı yok. Müşteriye bu kodu verin: $code';
  }

  @override
  String get customerPickupCode => 'Müşterinin teslim alma kodu';

  @override
  String get payOutAndComplete => 'Öde ve tamamlandı olarak işaretle';

  @override
  String get showQrAtOffice => 'QR kodunu şubede gösterin';

  @override
  String get orUseCode => 'Veya kodu söyleyin';

  @override
  String get scanCustomerQr => 'Müşterinin QR kodunu tara';

  @override
  String get enterCodeInstead => 'Kodu elle gir';

  @override
  String get payOutWithCode => 'Kodla öde';

  @override
  String get qrDoesNotMatch => 'QR kodu bu işlemle eşleşmiyor.';

  @override
  String get qrVerified => 'QR kodu doğrulandı';

  @override
  String payOutAmount(Object amount, Object currency) {
    return '$amount $currency öde';
  }

  @override
  String get checkIdHint => 'Ödemeden önce müşterinin kimliğini kontrol edin.';

  @override
  String get qrOtherTransaction => 'QR kodu başka bir işleme ait.';

  @override
  String get scanPickupQr => 'Teslimat tara';

  @override
  String get notAPickupQr => 'Bu, uygulamadan bir teslim alma kodu değil.';

  @override
  String cameraError(Object error) {
    return 'Kamera başlatılamadı ($error). Tarayıcıda kameraya izin verin veya kodu elle girin.';
  }

  @override
  String get pointCameraAtQr =>
      'Kamerayı müşterinin telefonundaki QR koduna tutun.';

  @override
  String get scanPickup => 'Teslimat tara';

  @override
  String get scanPickupSubtitle =>
      'Onaylanmış bir işlemi ödemek için müşterinin QR kodunu tarayın.';

  @override
  String get qrNotReadyForPayout =>
      'İşlem bulunamadı veya ödemeye hazır değil.';

  @override
  String get qrOtherOffice => 'QR kodu başka bir şubeye ait.';

  @override
  String get transferPending => 'Alıcı bekleniyor';

  @override
  String get transferAccepted => 'Alındı';

  @override
  String get transferRejected => 'Reddedildi';

  @override
  String get transferCancelled => 'İptal edildi';

  @override
  String get noIncomingTransfers => 'Bekleyen gelen transfer yok.';

  @override
  String get noTransfersYet => 'Henüz transfer yok.';

  @override
  String transferFrom(Object name) {
    return 'Gönderen: $name';
  }

  @override
  String transferTo(Object name) {
    return 'Alıcı: $name';
  }

  @override
  String get transferAcceptedDone => 'Alındı. Tutar bakiyenize eklendi.';

  @override
  String get receivedButton => 'Alındı';

  @override
  String get rejectTransferTitle => 'Transfer reddedilsin mi?';

  @override
  String rejectTransferConfirm(Object amount, Object currency, Object name) {
    return '$amount $currency $name kişisine geri gönderilecek.';
  }

  @override
  String get transferRejectedDone =>
      'Transfer reddedildi ve para geri gönderildi.';

  @override
  String get cancelTransferTitle => 'Transfer iptal edilsin mi?';

  @override
  String cancelTransferConfirm(Object amount, Object currency, Object name) {
    return '$name kişisine $amount $currency iptal edilecek ve bakiyenize geri eklenecek.';
  }

  @override
  String get transferCancelledDone =>
      'Transfer iptal edildi, para bakiyenize geri döndü.';

  @override
  String get cancelTransfer => 'Transferi iptal et';

  @override
  String get cashBalance => 'Kasa';

  @override
  String get noBalanceYet => 'Henüz bakiye yok. Bakiyeyi yönetici yükler.';

  @override
  String get cashierAppBarTitle => 'CRM – Kasiyer';

  @override
  String get cashierNotSetUp =>
      'Kasiyer hesabınız hazır değil. Yöneticiyle iletişime geçin.';

  @override
  String get cashierSendSubtitle => 'Başka bir kasiyere para gönderin.';

  @override
  String get incomingTransfers => 'Gelenler';

  @override
  String incomingWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfer almanızı bekliyor.',
      one: '1 transfer almanızı bekliyor.',
    );
    return '$_temp0';
  }

  @override
  String get incomingSubtitle => 'Size gönderilen transferler.';

  @override
  String get myTransfers => 'Transferlerim';

  @override
  String get myTransfersSubtitle => 'Gönderilen ve alınan tüm transferler.';

  @override
  String notEnoughBalance(Object available, Object currency) {
    return 'Yalnızca $available $currency bakiyeniz var.';
  }

  @override
  String get confirmTransferTitle => 'Para gönderilsin mi?';

  @override
  String confirmTransferBody(Object amount, Object currency, Object name) {
    return '$name kişisine $amount $currency. Tutar, alıcı kabul edene kadar bakiyenizden ayrılır.';
  }

  @override
  String transferSent(Object name) {
    return '$name kişisine gönderildi. Alıcının kabul etmesi bekleniyor.';
  }

  @override
  String get noBalanceToSend => 'Gönderecek bakiyeniz yok.';

  @override
  String get noOtherCashiers => 'Gönderilecek başka kasiyer yok.';

  @override
  String get recipientCashier => 'Alıcı (kasiyer)';

  @override
  String availableBalance(Object amount, Object currency) {
    return 'Kullanılabilir: $amount $currency';
  }

  @override
  String get transferReservedHint =>
      'Tutar hemen bakiyenizden düşülür ve alıcı kabul ettiğinde onun bakiyesine eklenir. Reddederse veya siz iptal ederseniz para geri döner.';

  @override
  String get transfersTitle => 'Transferler';

  @override
  String get editCashierTitle => 'Kasiyeri düzenle';

  @override
  String get cashierUpdated => 'Kasiyer güncellendi.';

  @override
  String get adjustBalance => 'Bakiyeyi düzenle';

  @override
  String get adjustBalanceHint => 'Pozitif tutar ekler, negatif tutar düşer.';

  @override
  String get balanceWouldBeNegative => 'Bakiye sıfırın altına düşemez.';

  @override
  String get balanceUpdated => 'Bakiye güncellendi.';

  @override
  String get deleteCashierTitle => 'Kasiyer silinsin mi?';

  @override
  String deleteCashierConfirm(Object name) {
    return '$name uygulamaya erişemeyecek ve bakiye silinecek. Giriş hesabı kalır; Firebase konsolunda Authentication bölümünden silinebilir.';
  }

  @override
  String get cashierDeleted => 'Kasiyer silindi.';

  @override
  String get cashiers => 'Kasiyerler';

  @override
  String get existingCashiers => 'Mevcut kasiyerler';

  @override
  String get searchCashiersLabel => 'Ad, şube veya yöneticiye göre ara';

  @override
  String get officeOptional => 'Şube (isteğe bağlı)';

  @override
  String get managerOptional => 'Yönetici (isteğe bağlı)';

  @override
  String get noManagerAssigned => 'Yönetici yok';

  @override
  String get cashierCreated => 'Kasiyer oluşturuldu.';

  @override
  String couldNotCreateCashier(Object error) {
    return 'Kasiyer oluşturulamadı: $error';
  }

  @override
  String get requiredField => 'Zorunlu';

  @override
  String get createNewCashier => 'Yeni kasiyer oluştur';

  @override
  String get createCashier => 'Kasiyer oluştur';

  @override
  String get cashiersCardSubtitle =>
      'Kasiyer oluşturun, şubelere ve yöneticilere bağlayın, bakiye yükleyin.';

  @override
  String get myCashiers => 'Kasiyerlerim';

  @override
  String get myCashiersSubtitle =>
      'Size veya şubenize bağlı kasiyerler, bakiyeleri ve transferleriyle.';

  @override
  String get noCashiersLinked => 'Size veya şubenize bağlı kasiyer yok.';

  @override
  String get archivedBadge => 'Arşivlendi';

  @override
  String get restoreAction => 'Geri yükle';

  @override
  String get archiveAction => 'Arşivle';

  @override
  String showArchived(Object count) {
    return 'Arşivlenenleri göster ($count)';
  }

  @override
  String get archiveTransactionTitle => 'İşlem arşivlensin mi?';

  @override
  String get archiveTransactionConfirm =>
      'İşlem tamamlandı ve silinemez. Listeden gizlenir ancak kâr ve dışa aktarmada sayılmaya devam eder. \"Arşivlenenleri göster\" ile görüp geri yükleyebilirsiniz.';

  @override
  String get transactionArchived => 'İşlem arşivlendi.';

  @override
  String get transactionRestored => 'İşlem geri yüklendi.';

  @override
  String get tierSilver => 'Gümüş';

  @override
  String get tierGold => 'Altın';

  @override
  String get tierDiamond => 'Elmas';

  @override
  String get tierNone => 'Seviye yok';

  @override
  String get tierLabel => 'Müşteri seviyesi';

  @override
  String get customerTiers => 'Müşteri seviyeleri';

  @override
  String get customerTiersCardSubtitle =>
      'Ücret indirimli Gümüş, Altın ve Elmas';

  @override
  String get customerTiersIntro =>
      'İndirim, yöneticinin girdiği ücretten düşülen yüzde puandır. Örnek: yönetici %5 girer ve müşteri %1 indirimli Altın seviyesindeyse müşteri %4 öder. Müşterilere seviyeyi Müşteriler bölümünden verirsiniz.';

  @override
  String tierDiscountLabel(Object tier) {
    return '$tier için indirim';
  }

  @override
  String get tierInvalidValues => '0 ile 100 arasında bir sayı girin.';

  @override
  String get tierSettingsSaved => 'Müşteri seviyeleri kaydedildi.';

  @override
  String customerTierTitle(Object name) {
    return '$name için müşteri seviyesi';
  }

  @override
  String get customDiscountLabel => 'Özel indirim (isteğe bağlı)';

  @override
  String get customDiscountHelper =>
      'Seviyenin indirimini kullanmak için boş bırakın.';

  @override
  String tierFeeSummary(Object discount, Object fee) {
    return 'İndirim $discount yüzde puan. Örnek: ücret %5 → müşteri %$fee öder.';
  }

  @override
  String get tierNoAccountNote =>
      'Müşterinin uygulamada hesabı yok. Seviye, müşteri uygulamadan talep gönderdiğinde geçerli olur.';

  @override
  String get customerTierSaved => 'Müşteri seviyesi kaydedildi.';

  @override
  String tierDiscountShort(Object discount) {
    return '%$discount indirim';
  }

  @override
  String customerTierManagerLine(Object tier, Object discount) {
    return '$tier: girdiğiniz ücretten %$discount indirim düşülür';
  }

  @override
  String customerTierBadge(Object tier, Object discount) {
    return '$tier – ücrette %$discount indirim';
  }

  @override
  String tierFeeExample(Object fee) {
    return 'Örnek: ücret %5 → müşteri %$fee öder';
  }

  @override
  String feeAfterTierLine(Object base, Object discount, Object fee) {
    return '%$base − indirim %$discount = müşteri %$fee öder';
  }

  @override
  String get buyCardSubtitle => 'Ofisten nakit veya bankanıza döviz alın.';

  @override
  String get currencyToBuy => 'Almak istediğiniz döviz';

  @override
  String get currencyToPayWith => 'Ödeme yapacağınız döviz';

  @override
  String get howToReceive => 'Parayı nasıl almak istiyorsunuz?';

  @override
  String get deliveryCash => 'Nakit';

  @override
  String get deliveryBank => 'Bankama';

  @override
  String get deliveryCashHint =>
      'Parayı ofisten bir kod veya QR kod ile alırsınız.';

  @override
  String get deliveryBankHint =>
      'Ofis ödemenizi aldıktan sonra banka bilgilerinizi girersiniz ve ofis parayı oraya gönderir.';

  @override
  String get chooseCurrenciesFirst => 'Önce dövizleri seçin';

  @override
  String get officeForPickup => 'Parayı alacağınız ofis';

  @override
  String get officeForBankPayout => 'Ödemenizi alacak ofis';

  @override
  String get amountToBuy => 'Ne kadar almak istiyorsunuz?';

  @override
  String get sendBuyRequest => 'Alım talebi gönder';

  @override
  String get buyRequestSent => 'Alım talebi ofise gönderildi.';

  @override
  String buySummary(Object amount, Object to, Object from) {
    return '$from ile $amount $to alım';
  }

  @override
  String youPay(Object amount, Object currency) {
    return 'Ödeyeceğiniz: $amount $currency';
  }

  @override
  String customerPays(Object amount, Object currency) {
    return 'Müşterinin ödeyeceği: $amount $currency';
  }

  @override
  String get buyPriceComing => 'Ofis tutarı hesaplayıp bir teklif gönderecek.';

  @override
  String get paidOutToBankBody => 'Para bankanıza gönderildi.';

  @override
  String get enterBankDetailsIntro => 'Paranın nereye gönderileceğini girin.';

  @override
  String get bankNameLabel => 'Banka adı';

  @override
  String get bankPhoneLabel => 'Telefon numarası';

  @override
  String get bankAccountHolderLabel => 'Hesap sahibinin adı ve soyadı';

  @override
  String get sendBankDetails => 'Banka bilgilerini gönder';

  @override
  String get fillAllBankFields =>
      'Tüm alanları doldurun (en fazla 100 karakter).';

  @override
  String get bankDetailsWaiting =>
      'Teşekkürler! Ofis parayı bankanıza gönderecek.';

  @override
  String bankNameValue(Object value) {
    return 'Banka: $value';
  }

  @override
  String bankPhoneValue(Object value) {
    return 'Telefon: $value';
  }

  @override
  String bankAccountHolderValue(Object value) {
    return 'Hesap sahibi: $value';
  }

  @override
  String get changeBankDetails => 'Banka bilgilerini değiştir';

  @override
  String get waitingForBankDetails =>
      'Müşterinin banka bilgilerini girmesi bekleniyor.';

  @override
  String sendToBankInstructions(Object amount, Object currency) {
    return 'Müşterinin bankasına $amount $currency gönderin:';
  }

  @override
  String get markSentToBank => 'Para bankaya gönderildi';

  @override
  String confirmSentToBank(Object amount, Object currency) {
    return 'Müşterinin bankasına $amount $currency gönderdiniz mi? İşlem tamamlanacak ve ofis bakiyesi güncellenecek.';
  }

  @override
  String get confirm => 'Onayla';

  @override
  String rateFieldLabel(Object from, Object to) {
    return 'Kur: 1 $from = ? $to';
  }

  @override
  String get invalidRate => '0\'dan büyük bir kur girin.';

  @override
  String rateChangedFromMarket(Object rate) {
    return 'Özel kur. Piyasa kuru: $rate';
  }

  @override
  String get marketRateUsed => 'Piyasa kuru. Değiştirebilirsiniz.';

  @override
  String get useMarketRate => 'Piyasa kurunu kullan';

  @override
  String get pickupCodeDigitsHint =>
      'Yalnızca rakamları yazın, tireler otomatik eklenir.';

  @override
  String get balancesTitle => 'Bakiye';

  @override
  String get officeBalanceTitle => 'Ofis bakiyesi';

  @override
  String get cashierBalancesTitle => 'Kasiyer bakiyeleri';

  @override
  String get balancesCardSubtitle =>
      'Ofisin ve kasiyerlerin bakiyeleri, toplam ve ayrı ayrı.';

  @override
  String get noBalance => 'Bakiye yok.';

  @override
  String get sellCardSubtitle =>
      'Döviz satın, parayı nakit veya bankanıza alın.';

  @override
  String get currencyToSell => 'Satmak istediğiniz döviz';

  @override
  String get currencyToReceive => 'Almak istediğiniz döviz';

  @override
  String get amountToSell => 'Ne kadar satmak istiyorsunuz?';

  @override
  String get sendSellRequest => 'Satış talebi gönder';

  @override
  String get sellRequestSent => 'Satış talebi ofise gönderildi.';

  @override
  String sellSummary(Object amount, Object from, Object to) {
    return '$to karşılığında $amount $from satış';
  }

  @override
  String get partners => 'Ortaklar';

  @override
  String get partnersCardSubtitle => 'Ortaklarınızla döviz bozdurun.';

  @override
  String get partnersAdminCardSubtitle =>
      'Ortak oluşturun ve bir ofise veya yöneticiye bağlayın.';

  @override
  String get editPartnerTitle => 'Ortağı düzenle';

  @override
  String get partnerUpdated => 'Ortak güncellendi.';

  @override
  String get deletePartnerTitle => 'Ortak silinsin mi?';

  @override
  String deletePartnerConfirm(Object name) {
    return '$name artık uygulamaya erişemeyecek ve bakiye silinecek. Giriş hesabı kalır ve Firebase konsolunda Authentication altından silinebilir.';
  }

  @override
  String get partnerDeleted => 'Ortak silindi.';

  @override
  String get existingPartners => 'Ortaklar';

  @override
  String get searchPartnersLabel => 'Ortak ara (ad, ofis, yönetici)';

  @override
  String get createNewPartner => 'Yeni ortak oluştur';

  @override
  String get createPartner => 'Ortak oluştur';

  @override
  String get partnerCreated => 'Ortak oluşturuldu.';

  @override
  String couldNotCreatePartner(Object error) {
    return 'Ortak oluşturulamadı: $error';
  }

  @override
  String get partnerAppBarTitle => 'CRM – Ortak';

  @override
  String get partnerNotSetUp =>
      'Ortak hesabınız henüz bir ofise bağlı değil. Yöneticiyle iletişime geçin.';

  @override
  String get newExchange => 'Yeni bozdurma teklifi';

  @override
  String get exchangesTitle => 'Bozdurmalar';

  @override
  String get partnerBalancesTitle => 'Ortak bakiyeleri';

  @override
  String get noPartnersLinked => 'Size veya ofisinize bağlı ortak yok.';

  @override
  String get exchangeProposed => 'Teklif';

  @override
  String get exchangeAccepted => 'Kabul edildi';

  @override
  String get exchangeRejected => 'Reddedildi';

  @override
  String get exchangeCancelled => 'İptal edildi';

  @override
  String get exchangeCompleted => 'Tamamlandı';

  @override
  String get noExchangesYet => 'Henüz bozdurma yok.';

  @override
  String exchangeOfficeGives(Object amount) {
    return 'Ofis verir: $amount';
  }

  @override
  String exchangePartnerGives(Object amount) {
    return 'Ortak verir: $amount';
  }

  @override
  String exchangeYouGive(Object amount) {
    return 'Verdiğiniz: $amount';
  }

  @override
  String exchangeYouGet(Object amount) {
    return 'Aldığınız: $amount';
  }

  @override
  String exchangeRateLine(Object from, Object rate, Object to) {
    return 'Kur: 1 $from = $rate $to';
  }

  @override
  String get exchangeOfficeSentDone => '✓ Ofis gönderdi';

  @override
  String get exchangeOfficeSentWaiting => '… Ofis henüz göndermedi';

  @override
  String get exchangePartnerSentDone => '✓ Ortak gönderdi';

  @override
  String get exchangePartnerSentWaiting => '… Ortak henüz göndermedi';

  @override
  String get counterProposal => 'Karşı teklif';

  @override
  String get waitingForAnswer => 'Yanıt bekleniyor';

  @override
  String markExchangeSent(Object amount) {
    return '$amount gönderdim';
  }

  @override
  String get confirmExchangeSent =>
      'Parayı gönderdiğinizi onaylayın. Diğer taraf bunu görür ve geldiğinde onaylayabilir.';

  @override
  String markExchangeReceived(Object amount) {
    return '$amount aldım';
  }

  @override
  String get confirmExchangeReceived =>
      'Paranın geldiğini onaylayın. İki taraf da onayladığında bozdurma tamamlanır ve bakiyeler güncellenir.';

  @override
  String get waitingForOtherReceived =>
      'Diğer tarafın paranın geldiğini onaylaması bekleniyor.';

  @override
  String get youGiveLabel => 'Verdiğiniz tutar';

  @override
  String get youGetLabel => 'Aldığınız tutar';

  @override
  String get currencyYouGive => 'Verdiğiniz döviz';

  @override
  String get currencyYouGet => 'Aldığınız döviz';

  @override
  String get exchangeProposalSent => 'Teklif gönderildi.';

  @override
  String get choosePartner => 'Ortak';

  @override
  String get sendProposal => 'Teklif gönder';

  @override
  String get searchExistingCustomer => 'Mevcut müşteri ara';

  @override
  String get noCustomerFoundNew =>
      'Müşteri bulunamadı. Aşağıya yeni müşteri girin.';

  @override
  String get orNewCustomer => 'Veya yeni müşteri:';

  @override
  String get hasAppAccount => 'Uygulamada hesabı var';

  @override
  String get noAppAccount => 'Uygulamada hesabı yok';

  @override
  String get changeCustomer => 'Değiştir';

  @override
  String get inviteCustomerQuestion =>
      'Müşteri bizim müşterimiz olmak istiyor mu?';

  @override
  String get inviteCustomerHint =>
      'Müşteri müşteri kaydına eklenir ve uygulamada hesap oluşturmak için SMS ile bir bağlantı alır.';

  @override
  String get invitePhoneRequired =>
      'Bağlantıyı göndermek için müşterinin telefon numarasını girin.';

  @override
  String inviteSmsText(Object name, Object link) {
    return 'Merhaba $name! Müşterimiz olarak hoş geldiniz. Hesabınızı buradan oluşturun: $link';
  }

  @override
  String inviteWelcome(Object clientId) {
    return 'Hoş geldiniz! $clientId müşteri numarasıyla zaten müşterimizsiniz. İşlemlerinizi uygulamada görmek için aşağıdan hesabınızı oluşturun.';
  }

  @override
  String get inviteInvalid =>
      'Bağlantı artık geçerli değil. Yine de aşağıdan hesap oluşturabilirsiniz.';

  @override
  String get alreadyHaveAccountLogin => 'Zaten hesabınız var mı? Giriş yapın';

  @override
  String get attachReceiptOptional => 'Makbuz ekle (isteğe bağlı)';

  @override
  String get officeReceipt => 'Ofis makbuzu';

  @override
  String get partnerReceipt => 'Ortak makbuzu';

  @override
  String get totalBalanceTitle => 'Toplam bakiye';

  @override
  String get totalBalanceSubtitle => 'Ofis + kasiyerler (ortaklar hariç)';

  @override
  String get officeAddressLabel => 'Adres (nakit ödeyen müşteriler için)';

  @override
  String get officeMapUrlLabel => 'Harita bağlantısı';

  @override
  String get officeMapUrlHelper =>
      'Ofisi Google Haritalar\'da açın, Paylaş\'a dokunun ve bağlantıyı buraya yapıştırın.';

  @override
  String get howDoYouPay => 'Nasıl ödüyorsunuz?';

  @override
  String get howDoesCustomerPay => 'Müşteri nasıl ödüyor?';

  @override
  String get payCashAtOffice => 'Ofiste nakit';

  @override
  String get payViaBank => 'Banka ile';

  @override
  String get payCashHint =>
      'Harita bağlantısıyla ofis adresini alırsınız ve parayı orada teslim edersiniz. Ofis ödemeyi onaylar.';

  @override
  String get payBankHint =>
      'Ofis size ödeme bilgilerini gönderir, eskisi gibi.';

  @override
  String get walkInCashHint =>
      'Müşteri burada, ofiste öder. Ödeme hemen onaylanır ve müşteri teslim kodunu alır.';

  @override
  String get walkInBankHint =>
      'Müşteriye ödeme bilgilerini gönderir ve para geldiğinde onaylarsınız, eskisi gibi.';

  @override
  String get officeAddressMissing => 'Ofisin henüz adresi yok. Ofise sorun.';

  @override
  String get openMap => 'Haritayı aç';

  @override
  String payCashAtOfficeAmount(Object amount, Object currency) {
    return 'Ofiste $amount $currency nakit ödeyin';
  }

  @override
  String get payCashConfirmHint =>
      'Parayı teslim ettiğinizde ofis onaylar. Ardından teslim kodunuzu alırsınız.';

  @override
  String get customerPaysCashAtOffice => '💵 Müşteri ofiste nakit ödüyor';

  @override
  String get cashPaymentReceived => 'Ödeme alındı (nakit)';

  @override
  String get cashPaymentsTitle => 'Nakit ödemeler';

  @override
  String get cashPaymentsSubtitle => 'Ofiste nakit ödeyecek müşteriler.';

  @override
  String get noCashPaymentsWaiting => 'Şu anda bekleyen nakit ödeme yok.';

  @override
  String confirmCashReceived(Object amount, Object name) {
    return '$name kişisinden $amount nakit aldınız mı? Müşteri ardından teslim kodunu alır.';
  }

  @override
  String customerPaysCashAmount(Object amount, Object currency) {
    return 'Müşteri $amount $currency öder';
  }

  @override
  String get pickUpAtOfficeTitle => 'Ofis adresi';

  @override
  String get youPayCashAtOffice => 'Ofiste nakit ödüyorsunuz';
}
