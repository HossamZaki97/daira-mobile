# دايرة على المتاجر — ملف التجهيز

كل اللي هتحتاجه وانت بتملأ Google Play Console، بالترتيب. النصوص جاهزة للنسخ واللصق.
(متطلبات المتجر بتتغير؛ لو شاشة في الكونسول اختلفت عن المكتوب هنا، الكونسول هو المرجع.)

## 0. قبل ما تبدأ

- [ ] الباك اند على السيرفر، بدومين عليه HTTPS، ومتحدّث على آخر نسخة (`-u daira_backend`).
- [ ] الصفحات العامة شغالة على الدومين:
  - `https://daira.rs-sa.com/daira/privacy` ← سياسة الخصوصية
  - `https://daira.rs-sa.com/daira/terms` ← شروط الاستخدام
  - `https://daira.rs-sa.com/daira/delete-account` ← حذف الحساب (Play بيطلبها)
- [ ] من إعدادات دايرة على السيرفر: Firebase، والبريد (SMTP)، و`public_url` = الدومين.
- [ ] بريد تواصل للتطبيق (مثلًا support@<الدومين>)، لأن الشروط والخصوصية وصفحة الحذف بتحيل له.
- [ ] الدومين في `config/prod.json` (`ODOO_URL`).
- [ ] رقم الإصدار في `pubspec.yaml` (`version: 1.0.0+1`، وكل رفعة جديدة لازم الرقم اللي بعد `+` يزيد).
- [ ] `tool\release.ps1` يطلع `build\app\outputs\bundle\prodRelease\app-prod-release.aab`.
- [ ] حساب مراجعة لجوجل على السيرفر (شوف البند 6) — كلمة السر تتكتب في الكونسول بس، مش هنا ولا في git.

## 1. إنشاء التطبيق

| الحقل | القيمة |
|---|---|
| App name | Daira (أو «دايرة» لو اللغة الافتراضية عربي) |
| Default language | Arabic – ar |
| App or game | App |
| Free or paid | Free (نهائي، مينفعش يتغير بعدين) |
| Package name | `com.daira.circles` (بيتحدد تلقائيًا مع أول AAB) |

## 2. Main store listing

### العربية (ar)

**اسم التطبيق** (حد أقصى 30 حرف)
```
دايرة - نظّم جمعيتك
```

**الوصف القصير** (حد أقصى 80 حرف)
```
نظّم الجمعية مع أهلك وأصحابك: الأقساط والأدوار والتأكيدات في مكان واحد
```

**الوصف الكامل** (حد أقصى 4000 حرف)
```
دايرة بتساعدك تدير الجمعية بوضوح: مين دفع، مين أكّد، ومين عليه الدور يقبض.

بدل الورقة ورسائل الواتساب، كل حاجة متسجلة في مكان واحد، وكل عضو يشوف اللي يخصه.

للمنظّم
• اعمل الجمعية في دقيقة: المبلغ، والمواعيد (يومي، أسبوعي، شهري)، والأعضاء.
• رتّب الأدوار زي ما اتفقتوا، واحفظها كمسودة لحد ما تكونوا جاهزين.
• ادعُ الأعضاء برمز دعوة يُستخدم مرة واحدة.
• أكّد وصول كل قسط بضغطة، أو ارفضه مع كتابة السبب.
• سجّل تسليم المبلغ لصاحب الدور.

للعضو
• شوف دورك الجاي، والمبلغ اللي هتقبضه، وفاضل كام دور.
• بلّغ إنك دفعت القسط، واستنى تأكيد المنظّم.
• أكّد استلام المبلغ لما ييجي دورك.

للكل
• تذكير قبل ميعاد القسط، وإشعار عند كل تأكيد أو تسليم.
• سجل واضح لكل حركة في الجمعية بالوقت والاسم.
• عربي وإنجليزي، ووضع ليلي.
• عضو واحد ممكن ياخد أكتر من سهم.
• تقدر تضيف جمعية بدأت قبل كده وتكمّلها على دايرة.

مهم تعرفه
دايرة أداة تسجيل ومتابعة. التطبيق لا يحتفظ بأي أموال ولا يحوّلها؛ الدفع بيتم بينكم مباشرة بالطريقة اللي تتفقوا عليها، ودايرة بتسجّل اللي حصل.

خصوصيتك
مش بنطلب موقعك ولا جهات الاتصال ولا الصور، ومفيش إعلانات. تقدر تحذف حسابك من التطبيق في أي وقت.
```

### English (en-US)

**App name**
```
Daira - Savings Circles
```

**Short description**
```
Run your savings circle with family and friends: payments, turns and approvals
```

**Full description**
```
Daira keeps your savings circle (gam'eya) clear: who paid, who confirmed, and whose turn it is to receive.

Instead of paper notes and chat messages, everything is recorded in one place, and every member sees what concerns them.

For organizers
• Create a circle in a minute: amount, schedule (daily, weekly, monthly) and members.
• Set the turn order you agreed on, and keep it as a draft until you are ready.
• Invite members with a single-use code.
• Confirm each payment in one tap, or decline it with a reason.
• Record the payout to the member whose turn it is.

For members
• See your next turn, the amount you will receive, and how many rounds are left.
• Report that you paid and wait for the organizer to confirm.
• Confirm when you receive your payout.

For everyone
• A reminder before each due date, and a notification for every confirmation or payout.
• A clear record of every step in the circle, with time and name.
• Arabic and English, with dark mode.
• One member can hold more than one share.
• Bring a circle that already started and continue it on Daira.

Good to know
Daira is a record-keeping tool. It never holds or transfers money; members pay each other directly, the way they agree, and Daira records what happened.

Your privacy
No location, contacts or photos, and no ads. You can delete your account from the app at any time.
```

### الصور
| العنصر | الملف |
|---|---|
| App icon 512×512 | `design/store/play-icon-512.png` |
| Feature graphic 1024×500 | `design/store/feature-graphic-ar.png` / `feature-graphic-en.png` |
| Phone screenshots (2–8) | `design/store/screenshots/ar/*.png` و `en/*.png` (1080×1920، بالترتيب) |

ارفع لقطات الشاشة العربي في القائمة العربي والإنجليزي في الإنجليزي. Play بيطلب صور تابلت بس لو هتعلن إن التطبيق للتابلت؛ مش لازم دلوقتي.

## 3. Store settings

| الحقل | القيمة |
|---|---|
| Category | Finance (أو Productivity لو عايز تبعد عن متطلبات تطبيقات المال) |
| Tags | Savings, Budgeting / Personal finance (المتاح في القائمة) |
| Email | بريد التواصل |
| Website | `https://daira.rs-sa.com` (اختياري) |
| Phone | اختياري |

## 4. App content (Policy)

**Privacy policy:** `https://daira.rs-sa.com/daira/privacy`

**Ads:** No, my app does not contain ads.

**App access:** All or some functionality is restricted → أضف تعليمات:
```
Sign in with the review account below. It already belongs to a sample circle where it is the organizer, so you can see payments to confirm, the turn order and the activity log.
Email: <review account email>
Password: <review account password>
```

**Content rating (IARC questionnaire):**
- Category: Reference, News, or Educational? لا ← اختار **Utility, Productivity, Communication, or Other**.
- عنف، جنس، ألفاظ، مخدرات، قمار: كله **No**.
- Users can interact or exchange content: **Yes** (الأعضاء بيشوفوا أسماء بعض، والمنظّم بيكتب سبب الرفض). مفيش شات ولا صور.
- Shares user location: **No**. Allows purchases: **No**.
- النتيجة المتوقعة: Everyone / 3+ أو قريب منها.

**Target audience:** **18 and over** بس (تطبيق متعلّق بالفلوس؛ بيبعد عنك سياسة الأطفال والعائلات).

**News app:** No. **Government app:** No. **Health:** لا ينطبق.

**Financial features declaration:** التطبيق **لا يقدّم** قروض، ولا مدفوعات أو تحويلات، ولا حسابات بنكية، ولا تداول أو كريبتو. لو فيه اختيار زي «budgeting / money management / record keeping» اختاره، وإلا «My app doesn't provide any financial features». الجملة اللي توضّح ده (لو طلب وصف):
```
Daira only records savings-circle agreements between members (who paid, who confirmed, whose turn it is). It does not hold, collect, transfer or lend money, and has no payment features.
```

**Data safety:**

| السؤال | الإجابة |
|---|---|
| Does your app collect or share user data? | Yes |
| Encrypted in transit? | Yes (HTTPS) |
| Can users request deletion? | Yes — Delete account URL: `https://daira.rs-sa.com/daira/delete-account` |
| Shared with third parties? | No (Firebase مُعالج نيابة عنك، مش «مشاركة») |

البيانات المجمّعة (Collected، كلها **Required**، الغرض **App functionality** و**Account management**، وما فيش منها حاجة بتتباع أو للإعلانات):

| النوع | البند في Play | ملاحظة |
|---|---|---|
| Personal info | Name | اسم الحساب وأسماء الأعضاء |
| Personal info | Email address | تسجيل الدخول والرسائل |
| Personal info | User IDs | معرّف الحساب |
| Financial info | Other financial info | مبالغ الأقساط وحالة الدفع المسجّلة |
| App activity | Other user-generated content | سبب الرفض، أسماء الجمعيات |
| App activity | App interactions | سجل الحركات داخل الجمعية |
| Device or other IDs | Device or other IDs | رمز الإشعارات (FCM) وموديل الهاتف للجلسات |

مش بنجمع: الموقع، جهات الاتصال، الصور، الملفات، الرسائل، الصحة، سجل المتصفح، معرّف الإعلانات، أعطال التطبيق.
(بلد شبكة الموبايل بيُستخدم لحظيًا لاقتراح العملة ومش بيتخزن.)

## 5. الاختبار والإصدار

1. **Internal testing** الأول: ارفع الـ AAB، ضيف إيميلات المختبرين، وابعتلهم الرابط.
2. **Play App Signing**: وافق عليه. المفتاح اللي عندك (`.jks`) بيبقى **upload key**؛ احتفظ بنسخة منه ومن `key.properties` في مكان آمن خارج الجهاز.
3. **لو حساب صاحبك شخصي (Personal) واتعمل حديثًا:** جوجل بيطلب **Closed testing** بعدد مختبرين (12 وقت آخر تحديث) لمدة 14 يوم متصلين قبل ما يسمح بالـ Production. راجع صفحة Dashboard في الكونسول، هتلاقي الشرط لو منطبق.
4. **Production**: اختار الدول (مصر، الأردن، السعودية، الإمارات، الكويت، العراق…)، واكتب ملاحظات الإصدار:

```
<ar>
أول إصدار من دايرة: نظّم الجمعية، تابع الأقساط والأدوار، وخلي كل حركة متسجلة.
</ar>
<en-US>
First release of Daira: run your savings circle, track payments and turns, and keep a record of every step.
</en-US>
```

أول مراجعة ممكن تاخد من يوم لكام يوم.

## 6. حساب المراجعة (لجوجل وآبل)

على السيرفر:
1. اعمل حساب من التطبيق بإيميل مخصص للمراجعة وأكّده.
2. اعمل منه جمعية فيها 3–4 أعضاء وابدأها، وخلي فيه قسط «مبلّغ عنه» مستني تأكيد.
3. ما تحذفهوش ولا تغيّر كلمة السر من غير ما تحدّث الكونسول.

## 7. App Store (بعدين)

- حساب Apple Developer (رسوم سنوية) وجهاز Mac عليه Xcode.
- تطبيق iOS في Firebase (`GoogleService-Info.plist`) ومفتاح APNs (.p8) يترفع في Firebase.
- App Privacy: نفس إجابات Data safety.
- Screenshots: مقاس iPhone 6.9" (1320×2868) — نقدر نطلعها بنفس سكريبت اللقطات بتغيير المقاس.
- حذف الحساب من داخل التطبيق: موجود ✔.

---

## إعادة توليد لقطات الشاشة

```
flutter test test/store --dart-define=STORE_SHOTS=true   # الشاشات الخام → build/store_shots/
python tool/store_frames.py                               # الإطارات والعناوين → design/store/screenshots/
```
البيانات اللي بتظهر في اللقطات تجريبية ومكتوبة في `test/store/store_screenshots_test.dart`، والعناوين في `tool/store_frames.py`.
