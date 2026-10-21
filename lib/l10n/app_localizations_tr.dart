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
}
