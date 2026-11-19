// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دايرة';

  @override
  String get retry => 'حاول مجددًا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get ok => 'حسنًا';

  @override
  String get continueAction => 'متابعة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signInTitle => 'أهلًا بعودتك';

  @override
  String get signInBody => 'سجّل الدخول لمتابعة جمعياتك.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get requiredField => 'أكمل هذا الحقل.';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get errorOffline => 'لا يوجد اتصال. تحقّق من الإنترنت وحاول مجددًا.';

  @override
  String get errorUnavailable => 'دايرة لا تستجيب الآن. حاول بعد قليل.';

  @override
  String get errorCredentials =>
      'راجع البريد وكلمة المرور. الحساب الجديد يحتاج تأكيد البريد أولًا.';

  @override
  String get errorSuspended => 'هذا الحساب موقوف. تواصل مع دعم دايرة.';

  @override
  String get errorSessionEnded => 'انتهت جلستك. سجّل الدخول مجددًا.';

  @override
  String get errorConflict =>
      'تغيّرت البيانات في الأثناء. حدّثناها — راجعها وحاول مجددًا.';

  @override
  String get errorForbidden => 'لا يمكنك تنفيذ هذا الإجراء في هذه الجمعية.';

  @override
  String get errorRateLimited => 'محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.';

  @override
  String get errorInvalidInput => 'راجع البيانات المحددة.';

  @override
  String get errorNotFound => 'هذا العنصر لم يعد متاحًا.';

  @override
  String get errorCircleSuspended => 'هذه الجمعية موقوفة من دعم دايرة.';

  @override
  String get errorGeneric => 'حدث خطأ. حاول مجددًا.';

  @override
  String get maintenanceTitle => 'دايرة تحت الصيانة';

  @override
  String get maintenanceBody =>
      'نحسّن الخدمة الآن. بياناتك في أمان — عُد بعد قليل.';

  @override
  String maintenanceUntil(String until) {
    return 'العودة المتوقعة: $until';
  }

  @override
  String get updateRequiredTitle => 'حدّث دايرة للمتابعة';

  @override
  String get updateRequiredBody =>
      'هذا الإصدار لم يعد مدعومًا. حدّث التطبيق من المتجر لتواصل استخدام دايرة.';

  @override
  String get updateAvailableTitle => 'يتوفر إصدار جديد';

  @override
  String updateAvailableBody(String version) {
    return 'الإصدار $version متاح الآن في المتجر.';
  }

  @override
  String updateRequiredFrom(String date) {
    return 'سيصبح إلزاميًا من $date';
  }

  @override
  String get updateNow => 'تحديث';

  @override
  String get whatsNew => 'الجديد';

  @override
  String get offlineTitle => 'لا يوجد اتصال';

  @override
  String get offlineBody => 'دايرة تحتاج الإنترنت لتبقى جمعياتك محدّثة.';

  @override
  String get unavailableTitle => 'تعذّر الوصول إلى دايرة';

  @override
  String get unavailableBody => 'لم تستجب الخدمة. حاول مجددًا بعد لحظات.';

  @override
  String get obligationPending => 'لم يُدفع';

  @override
  String get obligationReported => 'بانتظار التأكيد';

  @override
  String get obligationApproved => 'تم الدفع';

  @override
  String get obligationOverdue => 'متأخر';

  @override
  String get actionPaid => 'دفعت القسط';

  @override
  String get actionReceived => 'وصلني';

  @override
  String get actionNotReceived => 'لم يصلني';

  @override
  String get actionPayout => 'سلّمت المبلغ';

  @override
  String get actionReceipt => 'استلمت';

  @override
  String get circleDraft => 'مسودة';

  @override
  String get circleActive => 'نشطة';

  @override
  String get circleSuspended => 'موقوفة';

  @override
  String get circleCompleted => 'مكتملة';

  @override
  String get circleCancelled => 'ملغاة';

  @override
  String get roundCollecting => 'جارٍ التحصيل';

  @override
  String get roundReady => 'جاهزة للتسليم';

  @override
  String get roundPayoutReported => 'بانتظار الاستلام';

  @override
  String get roundCompleted => 'مكتملة';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'حسب الجهاز';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get emptyCirclesTitle => 'لا توجد جمعيات بعد';

  @override
  String get emptyCirclesBody =>
      'أنشئ جمعية لمجموعتك، أو انضم لجمعية برمز دعوة.';

  @override
  String get createCircle => 'إنشاء جمعية';

  @override
  String get joinWithCode => 'الانضمام برمز';

  @override
  String roundOf(int number, int total) {
    return 'الدور $number من $total';
  }

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabCircles => 'جمعياتي';

  @override
  String get tabNotifications => 'الإشعارات';

  @override
  String get tabAccount => 'حسابي';

  @override
  String get welcomeTitle => 'جمعياتك بوضوح';

  @override
  String get welcomeBody =>
      'تابع كل قسط وكل دور مع مجموعتك. الأموال تتحرك خارج دايرة.';

  @override
  String get welcomePoint1 => 'كل مواعيد الأقساط في مكان واحد';

  @override
  String get welcomePoint2 => 'المنظّم يؤكد استلام كل قسط';

  @override
  String get welcomePoint3 => 'كل عضو يعرف موعد دوره';

  @override
  String get welcomeTermsPrefix => 'بالمتابعة أنت توافق على ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get terms => 'شروط الاستخدام';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get help => 'المساعدة';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpBody => 'سنرسل لك رمزًا لتأكيد بريدك الإلكتروني.';

  @override
  String get fullName => 'الاسم بالكامل';

  @override
  String passwordHint(int min) {
    return 'على الأقل $min أحرف.';
  }

  @override
  String get signUpTerms => 'بإنشاء الحساب أنت توافق على شروط الاستخدام.';

  @override
  String get haveAccountSignIn => 'لديّ حساب بالفعل';

  @override
  String get noAccountCreate => 'جديد؟ أنشئ حسابًا';

  @override
  String get confirmEmailLink => 'لديّ رمز تأكيد';

  @override
  String errorWeakPassword(int min) {
    return 'استخدم كلمة مرور من $min أحرف على الأقل.';
  }

  @override
  String get errorSignupDisabled => 'إنشاء الحسابات متوقف مؤقتًا. حاول لاحقًا.';

  @override
  String get errorVerificationCode =>
      'الرمز غير صحيح أو انتهت صلاحيته. راجع آخر رسالة أو اطلب رمزًا جديدًا.';

  @override
  String get verifyTitle => 'أكّد بريدك الإلكتروني';

  @override
  String get verifyBody =>
      'اكتب الرمز المكوّن من 8 أرقام من الرسالة التي وصلتك، أو اضغط الرابط في نفس الرسالة.';

  @override
  String get verificationCode => 'رمز التأكيد';

  @override
  String get verificationCodeHint => 'اكتب الأرقام الثمانية.';

  @override
  String get confirmEmail => 'تأكيد';

  @override
  String get resendCode => 'إرسال رمز جديد';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال بعد $seconds ث';
  }

  @override
  String get confirmationResent =>
      'إذا كان البريد يحتاج تأكيدًا، سيصلك رمز جديد.';

  @override
  String get emailConfirmed => 'تم تأكيد البريد. سجّل الدخول للمتابعة.';

  @override
  String get backToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get forgotTitle => 'استعادة كلمة المرور';

  @override
  String get forgotBody =>
      'اكتب بريدك وسنرسل لك رابطًا لاختيار كلمة مرور جديدة.';

  @override
  String get sendResetLink => 'إرسال الرابط';

  @override
  String get checkEmailTitle => 'تحقّق من بريدك';

  @override
  String get resetSentBody =>
      'إذا كان هناك حساب بهذا البريد، سيصلك رابط الاستعادة. اختر كلمة المرور الجديدة من الرابط ثم سجّل الدخول هنا.';

  @override
  String get useAnotherEmail => 'استخدام بريد آخر';

  @override
  String hello(String name) {
    return 'أهلًا $name';
  }

  @override
  String get needsYou => 'مطلوب منك';

  @override
  String get nothingNeeded => 'كل شيء تمام، لا شيء مطلوب منك الآن.';

  @override
  String get upcomingPayments => 'القادم';

  @override
  String roundNumber(int number) {
    return 'الدور $number';
  }

  @override
  String get yourTurn => 'دورك';

  @override
  String get turnIsNow => 'الدور الحالي دورك';

  @override
  String turnInRounds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count دور',
      many: 'بعد $count دورًا',
      few: 'بعد $count أدوار',
      two: 'بعد دورين',
      one: 'بعد دور واحد',
    );
    return '$_temp0';
  }

  @override
  String get actionPayTitle => 'ادفع قسطك';

  @override
  String get actionReceiptTitle => 'أكّد استلام المبلغ';

  @override
  String actionConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قسط بانتظار تأكيدك',
      many: '$count قسطًا بانتظار تأكيدك',
      few: '$count أقساط بانتظار تأكيدك',
      two: 'قسطان بانتظار تأكيدك',
      one: 'قسط واحد بانتظار تأكيدك',
    );
    return '$_temp0';
  }

  @override
  String actionPayoutTitle(String name) {
    return 'سلّم المبلغ لـ $name';
  }

  @override
  String get review => 'مراجعة';

  @override
  String notReceivedReason(String reason) {
    return 'لم يصل: $reason';
  }

  @override
  String get dueToday => 'يستحق اليوم';

  @override
  String dueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يستحق بعد $count يوم',
      many: 'يستحق بعد $count يومًا',
      few: 'يستحق بعد $count أيام',
      two: 'يستحق بعد يومين',
      one: 'يستحق غدًا',
    );
    return '$_temp0';
  }

  @override
  String daysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متأخر $count يوم',
      many: 'متأخر $count يومًا',
      few: 'متأخر $count أيام',
      two: 'متأخر يومين',
      one: 'متأخر يومًا',
    );
    return '$_temp0';
  }

  @override
  String everyDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count يوم',
      many: 'كل $count يومًا',
      few: 'كل $count أيام',
      two: 'كل يومين',
      one: 'يوميًا',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count أسبوع',
      many: 'كل $count أسبوعًا',
      few: 'كل $count أسابيع',
      two: 'كل أسبوعين',
      one: 'أسبوعيًا',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count شهر',
      many: 'كل $count شهرًا',
      few: 'كل $count شهور',
      two: 'كل شهرين',
      one: 'شهريًا',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
    );
    return '$_temp0';
  }

  @override
  String get filterActive => 'النشطة';

  @override
  String get filterDrafts => 'المسودات';

  @override
  String get filterCompleted => 'المنتهية';

  @override
  String get noDrafts => 'لا توجد مسودات';

  @override
  String get noCompleted => 'لا توجد جمعيات منتهية بعد';

  @override
  String get organizer => 'المنظّم';

  @override
  String myTurnRound(int round) {
    return 'دورك: الدور $round';
  }

  @override
  String get draftHint => 'مسودة — أكملها وابدأ الجمعية.';

  @override
  String get activityLog => 'سجل النشاط';

  @override
  String get confirmPaidTitle => 'هل دفعت القسط؟';

  @override
  String get confirmPaidBody =>
      'دايرة لا تحوّل الأموال. هذا يُبلغ المنظّم أنك دفعت ليؤكد الاستلام.';

  @override
  String get paidDone => 'أُرسل للمنظّم للتأكيد.';

  @override
  String approvedDone(String member) {
    return 'تم تأكيد قسط $member.';
  }

  @override
  String get rejectedDone => 'سيظهر السبب للعضو.';

  @override
  String get confirmPayoutTitle => 'هل سلّمت المبلغ؟';

  @override
  String confirmPayoutBody(String recipient) {
    return 'سيُطلب من $recipient تأكيد الاستلام.';
  }

  @override
  String get payoutDone => 'بانتظار تأكيد المستلم.';

  @override
  String get confirmReceiptTitle => 'هل استلمت المبلغ؟';

  @override
  String get confirmReceiptBody => 'التأكيد يُغلق هذا الدور للجميع.';

  @override
  String get receiptDone => 'تم إغلاق الدور. شكرًا!';

  @override
  String get circleSuspendedTitle => 'هذه الجمعية موقوفة مؤقتًا';

  @override
  String get circleSuspendedBody =>
      'أوقفها دعم دايرة. تعود الأقساط عند استئنافها.';

  @override
  String get circleCancelledTitle => 'تم إلغاء هذه الجمعية';

  @override
  String get circleCompletedTitle =>
      'اكتملت الجمعية — كل الأعضاء استلموا أدوارهم';

  @override
  String get yourPayment => 'قسطك';

  @override
  String get yourPayout => 'مبلغك';

  @override
  String payoutSentToYou(String amount) {
    return 'المنظّم سجّل أنه سلّمك $amount.';
  }

  @override
  String get handOver => 'التسليم';

  @override
  String readyForPayoutBody(String recipient) {
    return 'الكل دفع. سلّم المبلغ لـ $recipient.';
  }

  @override
  String waitingRecipient(String name) {
    return 'بانتظار تأكيد $name للاستلام.';
  }

  @override
  String get paymentsThisRound => 'أقساط هذا الدور';

  @override
  String toReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count للمراجعة',
      many: '$count للمراجعة',
      few: '$count للمراجعة',
      two: 'اثنان للمراجعة',
      one: 'واحد للمراجعة',
    );
    return '$_temp0';
  }

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get turnOrder => 'ترتيب الأدوار';

  @override
  String perShare(String amount) {
    return '$amount للسهم';
  }

  @override
  String get youOrganize => 'أنت المنظّم';

  @override
  String get yourTurnNow => 'هذا الدور دورك';

  @override
  String recipientIs(String name) {
    return '$name يستلم هذا الدور';
  }

  @override
  String collectedOf(String collected, String total) {
    return 'تأكد $collected من $total';
  }

  @override
  String get notReceivedHint =>
      'ادفع أو تواصل مع المنظّم، ثم اضغط «دفعت القسط».';

  @override
  String get payHint => 'ادفع للمنظّم بالطريقة المتفق عليها، ثم أبلغه من هنا.';

  @override
  String get waitingOrganizer => 'بانتظار تأكيد المنظّم.';

  @override
  String get paymentConfirmed => 'أكّده المنظّم.';

  @override
  String youName(String name) {
    return '$name (أنت)';
  }

  @override
  String reportedAt(String time) {
    return 'دفع $time';
  }

  @override
  String rejectTitle(String member) {
    return 'قسط $member لم يصلك؟';
  }

  @override
  String get rejectBody => 'اكتب السبب. سيظهر للعضو ويمكنه الدفع مرة أخرى.';

  @override
  String get reason => 'السبب';

  @override
  String get reasonHint => 'مثال: لم يصل أي تحويل حتى الآن';

  @override
  String sharesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سهم',
      many: '$count سهمًا',
      few: '$count أسهم',
      two: 'سهمان',
      one: 'سهم واحد',
    );
    return '$_temp0';
  }

  @override
  String get memberJoined => 'انضم';

  @override
  String get memberNotJoined => 'لم ينضم بعد';

  @override
  String get invite => 'دعوة';

  @override
  String get importedRound => 'قبل دايرة';

  @override
  String get startCircleTitle => 'بدء الجمعية؟';

  @override
  String get startCircleBody =>
      'بعد البدء لا يمكن تغيير الأعضاء أو المبالغ أو الأدوار.';

  @override
  String get startCircle => 'ابدأ الجمعية';

  @override
  String get circleStarted => 'بدأت الجمعية.';

  @override
  String get draftTitle => 'مسودة';

  @override
  String get draftBody => 'لا يراها غيرك. عدّلها أو ابدأها عندما تكون جاهزة.';

  @override
  String get editDraft => 'تعديل المسودة';

  @override
  String inviteTitle(String name) {
    return 'دعوة $name';
  }

  @override
  String inviteBody(int hours) {
    return 'شارك رمزًا يُستخدم مرة واحدة، صالح لمدة $hours ساعة، ويربط هذا العضو بحسابه.';
  }

  @override
  String get createInvite => 'إنشاء رمز دعوة';

  @override
  String get inviteActive => 'توجد دعوة سارية بالفعل';

  @override
  String inviteActiveBody(String date) {
    return 'صالحة حتى $date. للأمان يظهر الرمز مرة واحدة فقط — ألغِها لإنشاء رمز جديد.';
  }

  @override
  String get revokeAndNew => 'إلغاء وإنشاء رمز جديد';

  @override
  String get revoke => 'إلغاء الدعوة';

  @override
  String get revokeTitle => 'إلغاء هذه الدعوة؟';

  @override
  String get revokeBody => 'سيتوقف الرمز عن العمل فورًا.';

  @override
  String expiresOn(String date) {
    return 'ينتهي $date';
  }

  @override
  String get share => 'مشاركة';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get copied => 'تم النسخ';

  @override
  String inviteMessage(String member, String circle, String code, String link) {
    return 'أهلًا $member! انضم لجمعية «$circle» على دايرة بهذا الرمز: $code\nأو افتح: $link';
  }

  @override
  String get joinTitle => 'اكتب رمز الدعوة';

  @override
  String get joinBody => 'المنظّم يشاركك رمزًا من 12 حرفًا.';

  @override
  String get inviteCode => 'رمز الدعوة';

  @override
  String get inviteCodeHint => 'اكتب أحرف الرمز الـ 12.';

  @override
  String get inviteInvalid => 'الرمز غير صالح. اطلب رمزًا جديدًا من المنظّم.';

  @override
  String get inviteExpired =>
      'انتهت صلاحية الرمز. اطلب رمزًا جديدًا من المنظّم.';

  @override
  String get inviteAlreadyMember =>
      'أنت عضو بالفعل في الجمعية، أو هذا المكان مرتبط بحساب آخر.';

  @override
  String get featureDisabled => 'هذا الخيار متوقف حاليًا.';

  @override
  String get joinPreviewTitle => 'الانضمام لهذه الجمعية؟';

  @override
  String organizedBy(String name) {
    return 'ينظّمها $name';
  }

  @override
  String get joinAs => 'تنضم باسم';

  @override
  String yourTurnRound(int round) {
    return 'دورك: الدور $round';
  }

  @override
  String get joinNote => 'تُبلغ عن أقساطك من هنا، ويؤكد المنظّم استلامها.';

  @override
  String get joinCircle => 'انضم للجمعية';

  @override
  String joinedCircle(String circle) {
    return 'انضممت إلى $circle.';
  }

  @override
  String get noActivity => 'لا يوجد نشاط بعد';

  @override
  String get byDairaSupport => 'دعم دايرة';

  @override
  String get evCircleSaved => 'حُفظت بيانات الجمعية';

  @override
  String evReport(String member, int round) {
    return '$member دفع قسط الدور $round';
  }

  @override
  String evApprove(String member, int round) {
    return 'تأكيد قسط $member للدور $round';
  }

  @override
  String evReject(String member, int round) {
    return 'قسط $member للدور $round لم يصل';
  }

  @override
  String evCollectionCompleted(int round) {
    return 'اكتمل تحصيل الدور $round';
  }

  @override
  String evPayout(int round) {
    return 'تسليم مبلغ الدور $round';
  }

  @override
  String evReceipt(int round) {
    return 'استلام الدور $round وإغلاقه';
  }

  @override
  String get evCircleCompleted => 'اكتملت الجمعية';

  @override
  String get evInvitationCreated => 'إنشاء دعوة';

  @override
  String get evInvitationRevoked => 'إلغاء دعوة';

  @override
  String get evInvitationAccepted => 'انضمام عضو';

  @override
  String get evCircleSuspended => 'إيقاف الجمعية من الدعم';

  @override
  String get evCircleResumed => 'استئناف الجمعية';

  @override
  String get evCircleCancelled => 'إلغاء الجمعية';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get noNotificationsBody => 'ستظهر هنا الأقساط والتأكيدات والأدوار.';

  @override
  String get needsAction => 'يحتاج إجراء منك';

  @override
  String ntPaymentReported(String actor, int round) {
    return '$actor دفع قسط الدور $round — أكّد الاستلام';
  }

  @override
  String ntPaymentConfirmed(String actor, int round) {
    return '$actor أكّد استلام قسطك للدور $round';
  }

  @override
  String ntPaymentNotReceived(int round, String reason) {
    return 'قسطك للدور $round لم يصل: $reason';
  }

  @override
  String ntReadyForPayout(int round, String member) {
    return 'اكتمل تحصيل الدور $round — سلّم المبلغ لـ $member';
  }

  @override
  String ntPayoutSent(String actor, String amount) {
    return '$actor سلّمك $amount — أكّد الاستلام';
  }

  @override
  String ntPayoutReceived(String actor, int round) {
    return '$actor أكّد استلام الدور $round';
  }

  @override
  String ntMemberJoined(String actor) {
    return '$actor انضم للجمعية';
  }

  @override
  String ntDueSoon(int round, String amount) {
    return 'قسط الدور $round يستحق قريبًا ($amount)';
  }

  @override
  String ntOverdue(int round, String amount) {
    return 'قسط الدور $round متأخر ($amount)';
  }

  @override
  String get ntCircleCompleted => 'اكتملت الجمعية';

  @override
  String get ntCircleSuspended => 'أوقف الدعم الجمعية مؤقتًا';

  @override
  String get ntCircleResumed => 'عادت الجمعية للعمل';

  @override
  String get ntCircleCancelled => 'تم إلغاء الجمعية';

  @override
  String get ntGeneric => 'تحديث جديد';

  @override
  String get security => 'الأمان';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get signedInDevices => 'الأجهزة المتصلة';

  @override
  String get helpAndAbout => 'المساعدة وعن دايرة';

  @override
  String get signOutTitle => 'تسجيل الخروج؟';

  @override
  String get signOutBody => 'يمكنك تسجيل الدخول في أي وقت.';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteBody =>
      'سيُغلق حسابك ويُحذف اسمك من الجمعيات المنتهية. لا يمكن التراجع.';

  @override
  String get deleteBlocked => 'أنت عضو في جمعية نشطة. أكملها قبل حذف حسابك.';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get deleteForever => 'احذف حسابي';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get editName => 'اسمك';

  @override
  String get editNameBody => 'يظهر لأعضاء جمعياتك.';

  @override
  String get save => 'حفظ';

  @override
  String get changePasswordBody =>
      'سيتم تسجيل الخروج من الأجهزة الأخرى، ويبقى هذا الجهاز متصلًا.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور.';

  @override
  String get devicesBody => 'أنهِ أي جلسة لا تعرفها.';

  @override
  String get thisDevice => 'هذا الجهاز';

  @override
  String get endSession => 'إنهاء الجلسة';

  @override
  String get endSessionTitle => 'تسجيل خروج هذا الجهاز؟';

  @override
  String get endOthersTitle => 'تسجيل الخروج من كل الأجهزة الأخرى؟';

  @override
  String get endSessionBody => 'سيحتاج لتسجيل الدخول مرة أخرى.';

  @override
  String get endOthers => 'تسجيل الخروج من الأجهزة الأخرى';

  @override
  String get contentEmpty => 'لا يوجد محتوى بعد.';

  @override
  String lastUpdated(String date) {
    return 'آخر تحديث $date';
  }

  @override
  String get newCircle => 'جمعية جديدة';

  @override
  String stepOf(int step, int total, String title) {
    return 'الخطوة $step من $total · $title';
  }

  @override
  String get stepBasics => 'الأساسيات';

  @override
  String get stepMembers => 'الأعضاء';

  @override
  String get stepOrder => 'الأدوار';

  @override
  String get stepReview => 'المراجعة';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get saveDraft => 'حفظ كمسودة';

  @override
  String get draftSaved => 'تم حفظ المسودة.';

  @override
  String get discardTitle => 'تجاهل هذه الجمعية؟';

  @override
  String get discardBody => 'ستفقد ما أدخلته.';

  @override
  String get discard => 'تجاهل';

  @override
  String get startDatePast =>
      'تاريخ أول قسط في الماضي. اختر اليوم أو بعده، أو حدّد الأدوار المكتملة قبل دايرة.';

  @override
  String get draftChanged =>
      'تغيّرت المسودة من جهاز آخر. افتحها من جديد وحاول مرة أخرى.';

  @override
  String get circleName => 'اسم الجمعية';

  @override
  String get circleNameHint => 'مثال: جمعية العيلة 2026';

  @override
  String get installmentPerShare => 'القسط لكل سهم';

  @override
  String get amountInvalid => 'اكتب مبلغًا صحيحًا.';

  @override
  String get currency => 'العملة';

  @override
  String get cadence => 'موعد الأقساط';

  @override
  String get cadenceDays => 'أيام';

  @override
  String get cadenceWeeks => 'أسابيع';

  @override
  String get cadenceMonths => 'شهور';

  @override
  String get firstDueDate => 'تاريخ أول قسط';

  @override
  String get lastDueDate => 'تاريخ آخر قسط';

  @override
  String get firstDueDateHint => 'كل دور يتبع الموعد بدءًا من هذا التاريخ.';

  @override
  String get change => 'تغيير';

  @override
  String get membersStepBody =>
      'أضف باقي الأعضاء بالاسم. يمكنهم الانضمام بدعوة لاحقًا.';

  @override
  String memberNumber(int number) {
    return 'العضو $number';
  }

  @override
  String get removeMember => 'حذف العضو';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get increase => 'زيادة';

  @override
  String get decrease => 'تقليل';

  @override
  String totalShares(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سهم إجمالًا = $count دور',
      many: '$count سهمًا إجمالًا = $count دورًا',
      few: '$count أسهم إجمالًا = $count أدوار',
      two: 'سهمان إجمالًا = دوران',
      one: 'سهم واحد إجمالًا',
    );
    return '$_temp0';
  }

  @override
  String payoutPerRound(String amount) {
    return 'كل دور يجمع $amount.';
  }

  @override
  String sharesLimit(int max) {
    return 'الجمعية تحتاج من 2 إلى $max سهم إجمالًا.';
  }

  @override
  String get orderBody => 'اسحب لترتيب من يستلم كل دور. لكل سهم دور.';

  @override
  String get orderFixedBody =>
      'الأدوار حسب ترتيب إضافة الأعضاء، وأنت تستلم أخيرًا.';

  @override
  String get resetOrder => 'إعادة الترتيب الافتراضي';

  @override
  String get noImportedRounds => 'جمعية جديدة (لا أدوار قبل دايرة)';

  @override
  String importedRounds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دور مكتمل قبل دايرة',
      many: '$count دورًا مكتملًا قبل دايرة',
      few: '$count أدوار مكتملة قبل دايرة',
      two: 'دوران مكتملان قبل دايرة',
      one: 'دور واحد مكتمل قبل دايرة',
    );
    return '$_temp0';
  }

  @override
  String get importedHint =>
      'لجمعية بدأت بالفعل: تُسجَّل الأدوار الأولى كمكتملة.';

  @override
  String get dragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String get membersLabel => 'الأعضاء';

  @override
  String get roundsLabel => 'الأدوار';

  @override
  String get importedLabel => 'مكتمل قبل دايرة';

  @override
  String get eachRoundCollects => 'كل دور يجمع';

  @override
  String get reviewNoteTitle => 'الأموال تتحرك خارج دايرة';

  @override
  String get reviewNoteBody =>
      'دايرة تسجّل من دفع ومن استلم، ليرى الجميع نفس الحقيقة.';

  @override
  String get name => 'الاسم';

  @override
  String paidOf(int paid, int total) {
    return 'دفع $paid من $total';
  }

  @override
  String get unpaidGroup => 'لم يدفعوا بعد';

  @override
  String paidGroup(int count) {
    return 'دفعوا ($count)';
  }

  @override
  String get recordPayment => 'تسجيل الدفع';

  @override
  String get recordSeveral => 'تسجيل أكثر من دفعة';

  @override
  String recordSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تسجيل $count دفعة',
      few: 'تسجيل $count دفعات',
      two: 'تسجيل دفعتين',
      one: 'تسجيل دفعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get selectWhoPaid => 'اختر من دفع';

  @override
  String recordTitle(String member) {
    return 'تسجيل دفع $member';
  }

  @override
  String get recordBody => 'استخدمه عندما يصلك القسط نقدًا أو بأي طريقة أخرى.';

  @override
  String get paymentMethodOptional => 'طريقة الدفع (اختياري)';

  @override
  String get methodCash => 'نقدًا';

  @override
  String get methodTransfer => 'تحويل';

  @override
  String get methodWallet => 'محفظة';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get recordedDone => 'تم تسجيل الدفع';

  @override
  String get recordedByOrganizer => 'سجّله المنظّم';

  @override
  String get reportedAndConfirmed => 'أبلغ العضو وأكّد المنظّم';

  @override
  String get paymentDetails => 'تفاصيل الدفعة';

  @override
  String confirmedAt(String time) {
    return 'تأكّد $time';
  }

  @override
  String get undoPayment => 'إلغاء التسجيل';

  @override
  String undoPaymentTitle(String member) {
    return 'إلغاء تسجيل دفع $member؟';
  }

  @override
  String get undoPaymentBody =>
      'يعود القسط إلى «لم يدفع»، ويبقى ذلك في سجل النشاط.';

  @override
  String get undoneDone => 'تم إلغاء التسجيل';

  @override
  String get remindUnpaid => 'تذكير من لم يدفع';

  @override
  String get remindTitle => 'إرسال تذكير؟';

  @override
  String remindBody(int left) {
    return 'يصل إشعار للأعضاء المسجّلين الذين لم يدفعوا. المتبقي في هذا الدور: $left.';
  }

  @override
  String get remindAction => 'إرسال التذكير';

  @override
  String get remindDone => 'تم إرسال التذكير';

  @override
  String remindNextAt(String time) {
    return 'التذكير التالي $time';
  }

  @override
  String get remindLimitReached => 'انتهت تذكيرات هذا الدور';

  @override
  String get markReceived => 'تسجيل الاستلام';

  @override
  String markReceivedTitle(String member) {
    return 'هل استلم $member المبلغ؟';
  }

  @override
  String markReceivedBody(String member) {
    return 'يُغلق الدور ويصل $member إشعار، ويستطيع أن يبلغ إذا لم يصله المبلغ.';
  }

  @override
  String get receivedDone => 'تم إغلاق الدور';

  @override
  String get undoPayout => 'إلغاء التسليم';

  @override
  String get undoPayoutTitle => 'إلغاء تسجيل التسليم؟';

  @override
  String get undoPayoutBody => 'يعود الدور إلى «جاهز للتسليم».';

  @override
  String get undoPayoutDone => 'تم إلغاء التسليم';

  @override
  String reopenRound(int number) {
    return 'إعادة فتح الدور $number';
  }

  @override
  String get reopenBody =>
      'استخدمه إذا سُجّل الاستلام بالخطأ. الدور الحالي ينتظر حتى يُغلق هذا الدور مرة أخرى.';

  @override
  String get reopenedDone => 'أُعيد فتح الدور';

  @override
  String receiptRecordedForYou(int number) {
    return 'سجّل المنظّم أنك استلمت مبلغ الدور $number.';
  }

  @override
  String get notReceivedMine => 'لم أستلم';

  @override
  String get disputeTitle => 'لم يصلك المبلغ؟';

  @override
  String get disputeBody => 'يُعاد فتح الدور ويصل المنظّم إشعار.';

  @override
  String get disputeDone => 'تم إبلاغ المنظّم';

  @override
  String get receivedLabel => 'استلم';

  @override
  String receivedRound(int number) {
    return 'استلم الدور $number';
  }

  @override
  String get turnNowLabel => 'دوره الآن';

  @override
  String accountNameLabel(String name) {
    return 'اسم الحساب: $name';
  }

  @override
  String get moreActions => 'المزيد';

  @override
  String get installmentsTable => 'جدول الأقساط';

  @override
  String get editTurnOrder => 'تعديل ترتيب الأدوار';

  @override
  String get reminderSettings => 'التذكيرات';

  @override
  String get muteReminders => 'إيقاف التذكيرات';

  @override
  String get unmuteReminders => 'تشغيل التذكيرات';

  @override
  String get mutedDone => 'أُوقفت التذكيرات لهذه الجمعية';

  @override
  String get unmutedDone => 'تم تشغيل التذكيرات';

  @override
  String get reminderSettingsBody =>
      'تصل التذكيرات التلقائية للأعضاء المسجّلين الذين لم يدفعوا.';

  @override
  String get remindBefore => 'قبل الموعد';

  @override
  String get remindOff => 'متوقف';

  @override
  String remindDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String get remindOnDue => 'يوم الموعد';

  @override
  String get remindOverdue => 'عند التأخير';

  @override
  String get reminderSaved => 'تم تحديث التذكيرات';

  @override
  String get tableLegend => 'اضغط على أي خانة لعرض التفاصيل.';

  @override
  String roundColumn(int number) {
    return 'الدور $number';
  }

  @override
  String get reorderBody =>
      'يمكن تغيير أي دور لم يُسلَّم بعد، والمبالغ لا تتغير.';

  @override
  String get lockedTurns => 'تم تسليمها';

  @override
  String get dragHint => 'اضغط مطولًا على الاسم واسحبه لأعلى أو لأسفل';

  @override
  String get reviewChanges => 'مراجعة التغييرات';

  @override
  String get reorderConfirmTitle => 'حفظ الترتيب الجديد؟';

  @override
  String reorderChange(String member, int from, int to) {
    return '$member: الدور $from ← $to';
  }

  @override
  String get reorderNotice => 'يصل إشعار لكل عضو تغيّر دوره.';

  @override
  String get reorderDone => 'تم حفظ الترتيب';

  @override
  String get noChanges => 'لا توجد تغييرات';

  @override
  String get moveToRound => 'نقل إلى الدور…';

  @override
  String get errorReminderLimit => 'لا يوجد تذكير متاح الآن.';

  @override
  String get errorNobodyToRemind => 'كل الأعضاء المسجّلين دفعوا.';

  @override
  String get errorRoundHandedOver =>
      'تم تسليم مبلغ هذا الدور. ألغِ التسليم أولًا.';

  @override
  String ntPaymentDueToday(int round, String amount) {
    return 'قسط الدور $round مستحق اليوم ($amount)';
  }

  @override
  String ntReminder(String actor, int round) {
    return '$actor يذكّرك بقسط الدور $round';
  }

  @override
  String ntPaymentRecorded(String actor, int round) {
    return 'سجّل $actor دفع قسطك للدور $round';
  }

  @override
  String ntPaymentUndone(String actor, int round) {
    return 'ألغى $actor تسجيل قسطك للدور $round';
  }

  @override
  String ntReceiptRecorded(String actor, int round) {
    return 'سجّل $actor أنك استلمت مبلغ الدور $round';
  }

  @override
  String ntReceiptDisputed(String member, int round) {
    return '$member أبلغ أن مبلغ الدور $round لم يصله';
  }

  @override
  String ntPayoutUndone(int round) {
    return 'أُلغي تسجيل تسليم الدور $round';
  }

  @override
  String ntReceiptUndone(int round) {
    return 'أُعيد فتح الدور $round';
  }

  @override
  String ntTurnChanged(int round) {
    return 'دورك أصبح في الدور $round';
  }

  @override
  String ntLinkRequest(String actor, String member) {
    return '$actor يطلب ربط حسابك باسم $member';
  }

  @override
  String ntJoinRequest(String actor, String member) {
    return '$actor استخدم دعوة $member. هل هو الشخص الصحيح؟';
  }

  @override
  String ntCircleInvitation(String actor) {
    return '$actor يدعوك إلى جمعية';
  }

  @override
  String ntLinkAccepted(String member) {
    return 'تم ربط $member بالحساب';
  }

  @override
  String ntAddedToCircle(String actor) {
    return 'أضافك $actor إلى هذه الجمعية';
  }

  @override
  String evRecordPayment(String member, int round) {
    return 'سجّل المنظّم دفع $member للدور $round';
  }

  @override
  String evUndoPayment(String member, int round) {
    return 'أُلغي تسجيل دفع $member للدور $round';
  }

  @override
  String evUndoPayout(int round) {
    return 'أُلغي تسليم الدور $round';
  }

  @override
  String evReceiptRecorded(int round) {
    return 'سجّل المنظّم استلام الدور $round';
  }

  @override
  String evUndoReceipt(int round) {
    return 'أُعيد فتح الدور $round';
  }

  @override
  String evReceiptDisputed(int round) {
    return 'أبلغ صاحب الدور $round أن المبلغ لم يصله';
  }

  @override
  String get evOrderChanged => 'تم تعديل ترتيب الأدوار';

  @override
  String evRemind(int round) {
    return 'أُرسل تذكير بقسط الدور $round';
  }

  @override
  String get evReminderSettings => 'تم تعديل إعدادات التذكير';

  @override
  String evMemberLinked(String member) {
    return 'انضم $member بحسابه';
  }

  @override
  String evMemberUnlinked(String member) {
    return 'لم يعد $member مرتبطًا بحساب';
  }

  @override
  String get startedQuestion => 'الجمعية بدأت بالفعل';

  @override
  String get startedHint => 'بعض الأعضاء استلموا قبل استخدام دايرة.';

  @override
  String get nextDueDate => 'موعد القسط القادم';

  @override
  String get nextDueHint => 'يحسب التطبيق تواريخ الأدوار السابقة تلقائيًا.';

  @override
  String get markLastReceivedHint =>
      'رتّب الأعضاء حسب من استلم أولًا، ثم اضغط على آخر من استلم.';

  @override
  String get shuffleOrder => 'ترتيب عشوائي';

  @override
  String get evCircleSavedRandom => 'حُفظت الجمعية بترتيب عشوائي للأدوار';

  @override
  String get installmentDue => 'موعد القسط';

  @override
  String get tabPayments => 'الأقساط';

  @override
  String get tabTurns => 'الأدوار';

  @override
  String selectedSummary(int count, String amount) {
    return 'المحدَّد $count · $amount';
  }

  @override
  String roundPaymentsTitle(int number) {
    return 'أقساط الدور $number';
  }

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get clearSelection => 'إلغاء التحديد';

  @override
  String get selectToRecordHint =>
      'اضغط على من دفع لتحديده، ثم سجّل الدفع مرة واحدة.';

  @override
  String roundsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دور',
      many: '$count دورًا',
      few: '$count أدوار',
      two: 'دوران',
      one: 'دور واحد',
    );
    return '$_temp0';
  }

  @override
  String get randomOrderChip => 'رُتّبت بالقرعة';

  @override
  String get yourTurnTag => 'دورك';

  @override
  String get tableMember => 'العضو';

  @override
  String get tablePaid => 'دفعوا';

  @override
  String get tableRecipient => 'يستلم هذا الدور';

  @override
  String paidRatio(int paid, int total) {
    return 'دفع $paid من $total';
  }

  @override
  String moveMemberTo(String name) {
    return 'نقل $name إلى…';
  }

  @override
  String get resetChanges => 'تراجع';

  @override
  String get reorderHowTo =>
      'اسحب البطاقة من ⇅، أو اضغط عليها لاختيار دورها الجديد.';

  @override
  String get movableTurns => 'الأدوار القابلة للتغيير';

  @override
  String wasRound(int number) {
    return 'كان الدور $number';
  }

  @override
  String get currentRoundTag => 'الدور الحالي';

  @override
  String get noChangesYet => 'لا توجد تغييرات بعد';

  @override
  String reviewChangesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مراجعة $count تغيير',
      many: 'مراجعة $count تغييرًا',
      few: 'مراجعة $count تغييرات',
      two: 'مراجعة تغييرين',
      one: 'مراجعة تغيير واحد',
    );
    return '$_temp0';
  }

  @override
  String reorderReviewBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتغيّر دور $count عضو، والمبالغ كما هي.',
      many: 'سيتغيّر دور $count عضوًا، والمبالغ كما هي.',
      few: 'سيتغيّر دور $count أعضاء، والمبالغ كما هي.',
      two: 'سيتغيّر دور عضوين، والمبالغ كما هي.',
      one: 'سيتغيّر دور عضو واحد، والمبالغ كما هي.',
    );
    return '$_temp0';
  }

  @override
  String get saveOrder => 'حفظ الترتيب';

  @override
  String get orderStepHint =>
      'رتّب الأدوار بالقرعة، أو اسحب البطاقة من ⇅ لترتيبها بنفسك.';

  @override
  String get shufflingNow => 'جارٍ الترتيب…';

  @override
  String get receivedBeforeTitle => 'استلموا قبل دايرة';

  @override
  String get receivedBeforeHint => 'أول الأدوار في القائمة أدناه.';

  @override
  String get dateToday => 'اليوم';

  @override
  String get dateNextWeek => 'بعد أسبوع';

  @override
  String get dateNextMonthStart => 'أول الشهر القادم';

  @override
  String get dateOther => 'تاريخ آخر';

  @override
  String get orderRandom => 'بالقرعة';

  @override
  String get orderArranged => 'حسب الترتيب المحدد';

  @override
  String get dayYesterday => 'أمس';

  @override
  String get circleKindTitle => 'هل الجمعية جديدة؟';

  @override
  String get kindNew => 'جمعية جديدة';

  @override
  String get kindNewHint => 'تبدأ من الدور الأول.';

  @override
  String get kindRunning => 'جمعية قائمة';

  @override
  String get kindRunningHint => 'بدأت قبل دايرة، وتكمّلها هنا.';

  @override
  String get currentDueDate => 'موعد قسط الدور الحالي';

  @override
  String get currentRoundQuestion => 'الدور الحالي';

  @override
  String get currentRoundFirst => 'لم يستلم أحد بعد.';

  @override
  String currentRoundHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الـ$count دور قبله تُعتبر مستلَمة.',
      many: 'الـ$count دورًا قبله تُعتبر مستلَمة.',
      few: 'الأدوار الـ$count قبله تُعتبر مستلَمة.',
      two: 'الدوران قبله يُعتبران مستلَمين.',
      one: 'الدور الذي قبله يُعتبر مستلَمًا.',
    );
    return '$_temp0';
  }

  @override
  String get orderStepHintRunning =>
      'رتّب الأعضاء حسب ترتيب الاستلام (من استلم أولًا)، ثم حدّد الدور الحالي.';

  @override
  String get myPaymentDue => 'لم تدفع بعد';

  @override
  String get myPaymentLate => 'متأخر';

  @override
  String get myPaymentDone => 'دفعت قسطك';

  @override
  String collectedInstallments(int paid, int total) {
    return 'تم تحصيل $paid من $total أقساط';
  }

  @override
  String get nextPayoutLabel => 'دورك القادم في الاستلام';

  @override
  String get myTurnNow => 'دورك الآن';

  @override
  String showEarlierRounds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count دور سابق',
      many: 'عرض $count دورًا سابقًا',
      few: 'عرض $count أدوار سابقة',
      two: 'عرض دورين سابقين',
      one: 'عرض دور سابق',
    );
    return '$_temp0';
  }

  @override
  String showAllRounds(int count) {
    return 'عرض كل الأدوار ($count)';
  }

  @override
  String get showFewerRounds => 'عرض أقل';
}
