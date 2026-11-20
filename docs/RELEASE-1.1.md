# رفع دايرة 1.1 — مرجع خطوة بخطوة

| | |
|---|---|
| التطبيق | `com.daira.circles` — الإصدار `1.1.0+2` — فرع `main`، tag `v1.1.0` |
| الباك اند | الموديول `daira_backend` — الإصدار `19.0.4.0.0` — فرع `main`، tag `v1.1.0` |
| السيرفر | https://daira.rs-sa.com |

> الترتيب مهم: **الباك اند أولًا، ثم التطبيق**. نسخة 1.0 من التطبيق تعمل مع باك اند 1.1.

---

## 1. قبل الرفع (على جهاز التطوير)

```powershell
# التطبيق
cd D:\flutter-apps\daira_odoo
git checkout main
flutter pub get
flutter gen-l10n
flutter analyze
flutter test

# الباك اند: الاختبارات (اختياري، على داتابيز تجريبية)
# odoo-bin -c <conf> -d <test_db> -u daira_backend --test-enable --test-tags /daira_backend --stop-after-init
```

اختبار يدوي سريع على موبايلين (حسابين) ضد السيرفر المحلي:

- [ ] إنشاء جمعية جديدة (أعضاء من جهات الاتصال، أسهم، قرعة، تاريخ من التقويم) وبدؤها.
- [ ] مسودة: فتحها، تعديلها، بدؤها، وحذف مسودة أخرى.
- [ ] دورة كاملة: «دفعت القسط» ← تأكيد المنظّم ← تسجيل الدفع لعضو غير مسجَّل ← التسليم ← الاستلام.
- [ ] الربط برقم الحساب (كتابة ومسح QR)، الموافقة، «سحب الطلب»، «ليس أنا».
- [ ] الإشعارات (والتطبيق مفتوح يظهر الكارت أعلى الشاشة).

## 2. رفع الكود إلى GitHub

```powershell
cd D:\odoo19\custom\mine\daira-backend
git push origin main release/1.1 --tags

cd D:\flutter-apps\daira_odoo
git push origin main release/1.1 --tags
```

## 3. الباك اند على السيرفر

1. **نسخة احتياطية** من الداتابيز والـ filestore (من مدير قواعد البيانات في Odoo أو `pg_dump`).
2. حدّث كود الموديول على السيرفر (حسب طريقتك):
   ```bash
   # لو السيرفر يسحب من git:
   cd <addons>/daira-backend && git fetch && git checkout main && git pull
   # أو انسخ مجلد daira_backend/ فقط (بدون __pycache__) فوق القديم
   ```
3. أعد تشغيل Odoo مع تحديث الموديول:
   ```bash
   odoo-bin -c <conf> -d <prod_db> -u daira_backend --stop-after-init
   # ثم شغّل الخدمة كالمعتاد (systemctl restart odoo مثلًا)
   ```
   التحديث يعمل تلقائيًا: أرقام الحسابات (DA-XXXXXX) لكل الحسابات، وجهات اتصال لأعضاء الجمعيات الحالية.
4. تحقق:
   - `https://daira.rs-sa.com/daira/health` يرد `{"service": "daira", ...}`
   - `https://daira.rs-sa.com/daira/join?invite=ABCDEFGH2345` تظهر صفحة الدعوة.

### إعدادات دايرة (Odoo ← دايرة ← الإعدادات)

| الإعداد | القيمة |
|---|---|
| Google Play link | `https://play.google.com/store/apps/details?id=com.daira.circles` |
| Android package name | `com.daira.circles` |
| Android signing certificate (SHA-256) | من Play Console ← سلامة التطبيق ← شهادة مفتاح توقيع التطبيق ← SHA-256 (لتفتح روابط الدعوة التطبيق مباشرة) |
| Push notifications (FCM) | مفعّل + ملف الـ service account |
| Organizer approves who joins | مفعّل (الافتراضي). مستخدمو 1.0 قليلون ومعروفون: اطلب منهم التحديث |
| Organizer reminders per round / Hours between | 3 / 24 (الافتراضي) |

بعد حفظ بصمة SHA-256 تحقق من: `https://daira.rs-sa.com/.well-known/assetlinks.json` (يظهر `com.daira.circles`).

## 4. التطبيق على Google Play

```powershell
cd D:\flutter-apps\daira_odoo
git checkout main
.\tool\release.ps1
# الناتج: build\app\outputs\bundle\prodRelease\app-prod-release.aab
# احتفظ بمجلد build\symbols لهذا الإصدار
```

1. Play Console ← **Internal testing** ← إصدار جديد ← ارفع `app-prod-release.aab` ← ملاحظات الإصدار (أدناه).
2. ثبّته من رابط الاختبار الداخلي وجرّب على البروداكشن: الدخول، فتح جمعية، رقم الحساب، طلب ربط.
3. انقل الإصدار إلى **Production** (Promote release).
4. **Data safety**: التطبيق يستخدم الكاميرا لمسح رمز الحساب فقط، ولا يحفظ أو يرسل صورًا — لا يلزم تغيير.
5. بعد النشر: Odoo ← دايرة ← App Releases ← أضف البناء `2` (اختياري أو إجباري).

### ملاحظات الإصدار

**عربي**
```
• تسجيل دفعات الأعضاء بضغطة، وتصحيحها عند الحاجة
• جهات الاتصال: اربط كل عضو بحسابه برقم الحساب أو رمز QR
• ترتيب الأدوار بالقرعة أو يدويًا، وإضافة جمعية قائمة بالفعل
• جدول الأقساط وسجل النشاط بتصميم أوضح
• تذكيرات تلقائية لكل جمعية، وتذكير يدوي للمنظّم
• صفحة رئيسية أبسط تُظهر ما ينتظرك أولًا
```

**English**
```
• Record members' payments in one tap, and correct them when needed
• Contacts: link each member to their account by account ID or QR code
• Random or manual turn order, and add a circle that already started
• Clearer installments table and activity log
• Automatic reminders per circle, and manual reminders for organizers
• A simpler home screen that shows what is waiting for you first
```

## 5. بعد النشر

- راقب أول يومين: Odoo ← دايرة (لوحة المتابعة) وسجل السيرفر.
- اطلب من المستخدمين الحاليين التحديث من المتجر.
- لو حصلت مشكلة في الباك اند: ارجع للنسخة الاحتياطية + `git checkout v1.0.0` للموديول. التطبيق 1.0 يستمر في العمل.

## 6. التالي (1.2)

1. قفل التطبيق بالبصمة (اختياري للمستخدم).
2. ملخص واتساب لحالة الجمعية، و«جمعية مشابهة».
3. التسجيل برقم الموبايل والتأكيد عبر واتساب (برقم تجريبي ثم الرقم الرسمي).

العمل على 1.2 يبدأ من `main` في فرع جديد:
```powershell
git checkout main && git checkout -b release/1.2
```
