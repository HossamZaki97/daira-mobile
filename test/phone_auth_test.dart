import 'package:daira/app/router.dart';
import 'package:daira/core/api/api_client.dart';
import 'package:daira/core/api/api_exception.dart';
import 'package:daira/core/config.dart';
import 'package:daira/core/data/phone_auth_repository.dart';
import 'package:daira/core/models/account.dart';
import 'package:daira/core/models/app_settings.dart';
import 'package:daira/core/models/json.dart';
import 'package:daira/core/providers.dart';
import 'package:daira/features/auth/phone_auth_screen.dart';
import 'package:daira/design/theme.dart';
import 'package:daira/l10n/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'support/fakes.dart';

class ProofMemory extends PhonePendingVault {
  final values = <String, PhoneChallenge>{};
  String key(String scope, String actor, PhonePurpose p) => '$scope:$actor:${p.name}';
  @override
  Future<void> save(String scope, String actor, PhonePurpose p, PhoneChallenge v) async =>
      values[key(scope, actor, p)] = v;
  @override
  Future<PhoneChallenge?> read(String scope, String actor, PhonePurpose p) async => values[key(scope, actor, p)];
  @override
  Future<void> clear(String scope, String actor, PhonePurpose p) async {
    values.remove(key(scope, actor, p));
  }
}

class FakePhone extends PhoneAuthRepository {
  FakePhone(super.api) : super(vault: ProofMemory());
  String state = 'waiting';
  bool arabicCountries = false;
  Object? failure;
  int starts = 0, finishes = 0, polls = 0;
  Json? lastFinish;
  @override
  Future<List<PhoneCountry>> countries() async => [
    PhoneCountry('EG', arabicCountries ? 'مصر' : 'Egypt', '20', 'Egypt'),
    PhoneCountry('SA', arabicCountries ? 'المملكة العربية السعودية' : 'Saudi Arabia', '966', 'Saudi Arabia'),
  ];
  @override
  Future<PhoneChallenge> start(String phone, String country, PhonePurpose p, {String? password}) async {
    starts++;
    if (failure != null) throw failure!;
    return PhoneChallenge(
      secret: 'test-opaque-secret-not-a-code',
      phone: '+201055555551',
      number: '+201000000000',
      text: 'Daira verification code: 1234',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      commandId: newCommandId(),
    );
  }

  @override
  Future<Json> status(PhonePurpose p, PhoneChallenge ch) async {
    polls++;
    return {'state': state};
  }

  @override
  Future<void> finish(PhonePurpose p, Json body) async {
    finishes++;
    lastFinish = body;
    if (failure != null) throw failure!;
    if (p == PhonePurpose.attach || p == PhonePurpose.change) {
      await api.updateProfile(Profile.fromJson({...profileJson, 'phone': '+201055555551', 'phone_verified': true}));
    } else {
      await api.startSession({
        ...sessionJson(),
        'profile': {...profileJson, 'phone': '+201055555551', 'phone_verified': true},
      });
    }
  }

  @override
  Future<void> login(String phone, String country, String password) async {
    if (failure != null) throw failure!;
    await api.startSession(sessionJson());
  }
}

AppSettings phoneSettings() => AppSettings.fromJson({
  'phone_auth': {'enabled': true},
  'content': ['terms', 'privacy'],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in [
      ('Cairo', 'assets/fonts/Cairo-Regular.ttf'),
      ('Cairo', 'assets/fonts/Cairo-SemiBold.ttf'),
      ('Cairo', 'assets/fonts/Cairo-Bold.ttf'),
      ('Phosphor', 'assets/fonts/phosphor/Phosphor.ttf'),
      ('PhosphorFill', 'assets/fonts/phosphor/Phosphor-Fill.ttf'),
    ]) {
      await (FontLoader(entry.$1)..addFont(rootBundle.load(entry.$2))).load();
    }
  });
  test('international paste suggestions retain country choice for shared calling codes', () {
    const countries = [
      PhoneCountry('EG', 'Egypt', '20'),
      PhoneCountry('SA', 'Saudi Arabia', '966'),
      PhoneCountry('US', 'United States', '1'),
      PhoneCountry('CA', 'Canada', '1'),
    ];
    expect(countryForPastedPhone('٠٠٩٦٦ ٥٠١٢٣٤٥٦٧', 'EG', countries), 'SA');
    expect(countryForPastedPhone('+1 650 5551234', 'CA', countries), 'CA');
    expect(countryForPastedPhone('01055555551', 'EG', countries), isNull);
    expect(phoneDigits('۰۱۲٣٤'), '01234');
  });

  test('pending proof is isolated by server, actor and purpose and cleared on logout', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const store = PhonePendingVault();
    final ch = PhoneChallenge(
      secret: 'opaque',
      phone: '+201055555551',
      number: '+201000000000',
      text: 'Daira verification code: 1234',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      commandId: newCommandId(),
    );
    await store.save('https://one.example', 'p1', PhonePurpose.attach, ch);
    expect((await store.read('https://one.example', 'p1', PhonePurpose.attach))?.secret, 'opaque');
    expect(await store.read('https://two.example', 'p1', PhonePurpose.attach), isNull);
    expect(await store.read('https://one.example', 'p2', PhonePurpose.attach), isNull);
    expect(await store.read('https://one.example', 'p1', PhonePurpose.reset), isNull);
    final api = ApiClient(const AppConfig('https://one.example'), MemoryVault(), testInfo);
    await api.startSession(sessionJson());
    await api.endSession();
    expect(await store.read('https://one.example', 'p1', PhonePurpose.attach), isNull);
  });

  test('expired pending proof is discarded, never restored as success', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const store = PhonePendingVault();
    await store.save(
      'https://one.example',
      'guest',
      PhonePurpose.signup,
      PhoneChallenge(
        secret: 'expired',
        phone: '+201055555551',
        number: '+201000000000',
        text: 'old',
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        commandId: newCommandId(),
      ),
    );
    expect(await store.read('https://one.example', 'guest', PhonePurpose.signup), isNull);
  });
  test('phone gate intercepts a stored session and deep links, never content/help', () {
    for (final route in [Routes.home, Routes.circle('c1'), Routes.join('ABCDEFGH2345')]) {
      expect(
        redirectFor(status: StartupStatus.ready, signedIn: true, location: route, phoneRequired: true),
        Routes.phone,
      );
    }
    expect(
      redirectFor(status: StartupStatus.ready, signedIn: true, location: Routes.phone, phoneRequired: true),
      isNull,
    );
    expect(
      redirectFor(status: StartupStatus.ready, signedIn: true, location: Routes.content('help'), phoneRequired: true),
      isNull,
    );
    expect(redirectFor(status: StartupStatus.ready, signedIn: true, location: Routes.phone), Routes.home);
  });

  test('phone return link carries no proof and cannot replace invitation links', () {
    expect(DeepLink.parse(Uri.parse('daira://phone-return')), isA<PhoneReturnLink>());
    expect(DeepLink.parse(Uri.parse('daira://phone-return?verified=true')), isNull);
    expect(DeepLink.parse(Uri.parse('https://evil.example/phone-return')), isNull);
    expect(DeepLink.parse(Uri.parse('daira://join?invite=ABCDEFGH2345')), isA<InviteLink>());
  });

  test('profile retains independent phone and email verification requirements', () {
    final profile = Profile.fromJson({...profileJson, 'phone_required': true});
    expect(profile.phoneRequired, isTrue);
    expect(profile.phoneVerified, isFalse);
    expect(Profile.fromJson(profile.toJson()).phoneRequired, isTrue);
  });

  testWidgets('main login uses phone and exposes email as an alternative', (tester) async {
    final app = await TestHarness.start(tester, settings: phoneSettings(), phoneRepository: FakePhone.new);
    app.go(Routes.signIn);
    await TestHarness.settle(tester);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Sign in with email'), findsOneWidget);
    await tapText(tester, 'Sign in with email');
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('registration checks account before opening WhatsApp', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    app.go(Routes.signUp);
    await TestHarness.settle(tester);
    phone.failure = const ApiException('phone_in_use', status: 409);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tapText(tester, 'Continue');
    expect(phone.starts, 1);
    expect(find.text('This phone is linked to an account. Sign in or reset your password.'), findsOneWidget);
    expect(find.text('Confirm on WhatsApp'), findsNothing);
  });

  testWidgets('signup waits for server proof before collecting final details', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    app.go(Routes.signUp);
    await TestHarness.settle(tester);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tapText(tester, 'Continue');
    expect(phone.finishes, 0);
    expect(find.text('Waiting for your WhatsApp message…'), findsOneWidget);
    expect(find.text('Name'), findsNothing);
    phone.state = 'verified';
    await tapText(tester, 'I sent it — check now');
    expect(find.text('Finish creating your account'), findsOneWidget);
    expect(phone.finishes, 0);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'New member');
    await tester.enterText(fields.at(1), 'safe-password-19');
    await tester.enterText(fields.at(2), 'different');
    await tapText(tester, 'Continue');
    expect(phone.finishes, 0);
    expect(find.text('Passwords do not match.'), findsOneWidget);
    await tester.enterText(fields.at(2), 'safe-password-19');
    await tapText(tester, 'Continue');
    expect(phone.finishes, 1);
    expect(app.api.session.value?.profile.phoneVerified, isTrue);
  });

  testWidgets('saved login is forced to attach phone without replacing its identity', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      signedIn: true,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    await app.api.updateProfile(Profile.fromJson({...profileJson, 'phone_required': true}));
    await TestHarness.settle(tester);
    expect(find.text('Complete your account'), findsOneWidget);
    app.go(Routes.circles);
    await TestHarness.settle(tester);
    expect(find.text('Complete your account'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tapText(tester, 'Continue');
    phone.state = 'verified';
    await tapText(tester, 'I sent it — check now');
    expect(phone.finishes, 1);
    expect(app.api.session.value?.profile.id, profileJson['id']);
    expect(app.api.session.value?.profile.phoneVerified, isTrue);
    expect(find.text('Complete your account'), findsNothing);
  });

  testWidgets('a restored pending request resumes without creating or cancelling another one', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    final saved = await phone.start('01055555551', 'EG', PhonePurpose.signup);
    await phone.vault.save(phone.scope, 'guest', PhonePurpose.signup, saved);
    phone.starts = 0;
    app.go(Routes.signUp);
    await TestHarness.settle(tester);
    expect(find.text('Waiting for your WhatsApp message…'), findsOneWidget);
    expect(phone.starts, 0);
    expect(phone.finishes, 0);
    phone.state = 'verified';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await TestHarness.settle(tester);
    expect(find.text('Finish creating your account'), findsOneWidget);
    expect(phone.starts, 0);
  });

  testWidgets('uncertain completion is retried with the same frozen command', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    app.go(Routes.signUp);
    await TestHarness.settle(tester);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tapText(tester, 'Continue');
    phone.state = 'verified';
    await tapText(tester, 'I sent it — check now');
    await tester.enterText(find.byType(TextFormField).at(0), 'New member');
    await tester.enterText(find.byType(TextFormField).at(1), 'safe-password-19');
    await tester.enterText(find.byType(TextFormField).at(2), 'safe-password-19');
    phone.failure = const ApiException('offline');
    await tapText(tester, 'Continue');
    final first = Map<String, dynamic>.from(phone.lastFinish!);
    expect(app.api.session.value, isNull);
    expect(tester.widget<TextFormField>(find.byType(TextFormField).first).enabled, isFalse);
    phone.failure = null;
    await tapText(tester, 'Retry with the same details');
    expect(phone.lastFinish, first);
    expect(phone.finishes, 2);
    expect(app.api.session.value, isNotNull);
  });

  testWidgets('a completed request restored without a session offers login, not another WhatsApp request', (
    tester,
  ) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    final saved = await phone.start('01055555551', 'EG', PhonePurpose.signup);
    await phone.vault.save(phone.scope, 'guest', PhonePurpose.signup, saved);
    phone.state = 'completed';
    phone.starts = 0;
    app.go(Routes.signUp);
    await TestHarness.settle(tester);
    expect(find.text('This request is complete. You can sign in with your phone.'), findsOneWidget);
    expect(find.text('Confirm on WhatsApp'), findsNothing);
    expect(find.text('Start a new verification'), findsNothing);
    await tapText(tester, 'Sign in');
    expect(find.text('Password'), findsOneWidget);
    expect(phone.starts, 0);
  });

  testWidgets('phone password recovery asks for a matching new password without creating an account', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    app.go(Routes.forgot);
    await TestHarness.settle(tester);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tapText(tester, 'Continue');
    phone.state = 'verified';
    await tapText(tester, 'I sent it — check now');
    expect(find.text('Name'), findsNothing);
    await tester.enterText(find.byType(TextFormField).at(0), 'new-password-19');
    await tester.enterText(find.byType(TextFormField).at(1), 'new-password-19');
    await tapText(tester, 'Continue');
    expect(phone.finishes, 1);
    expect(phone.lastFinish!.containsKey('name'), isFalse);
    expect(app.api.session.value, isNotNull);
  });

  testWidgets('double tapping start creates only one verification request', (tester) async {
    late FakePhone phone;
    final app = await TestHarness.start(
      tester,
      settings: phoneSettings(),
      phoneRepository: (api) => phone = FakePhone(api),
    );
    app.go(Routes.signUp);
    await TestHarness.settle(tester);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tester.tap(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await TestHarness.settle(tester);
    expect(phone.starts, 1);
  });

  testWidgets('Arabic phone flow visual review', (tester) async {
    const output = String.fromEnvironment('DAIRA_PHONE_REVIEW_DIR');
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'language': 'ar'});
    final prefs = await SharedPreferences.getInstance();
    final api = ApiClient(const AppConfig('https://daira.example.invalid'), MemoryVault(), testInfo);
    final repo = FakePhone(api)..arabicCountries = true;
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(prefs),
        apiProvider.overrideWithValue(api),
        clientInfoProvider.overrideWithValue(testInfo),
        phoneAuthRepositoryProvider.overrideWithValue(repo),
        appRepositoryProvider.overrideWithValue(FakeAppRepository(phoneSettings())),
      ],
    );
    addTearDown(container.dispose);
    final boundary = GlobalKey();
    Future<void> show(PhonePurpose? purpose) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: DairaTheme.light,
              home: PhoneAuthScreen(key: ValueKey(purpose), purpose: purpose),
            ),
          ),
        ),
      );
      await TestHarness.settle(tester);
    }

    Future<void> capture(String file) async {
      if (output.isEmpty) return;
      await tester.runAsync(() async {
        final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        await Directory(output).create(recursive: true);
        await File('$output/$file.png').writeAsBytes(bytes);
        image.dispose();
      });
    }

    await show(null);
    expect(tester.takeException(), isNull);
    await capture('phone-login-ar');
    await show(PhonePurpose.signup);
    await tester.enterText(find.byType(TextFormField).first, '01055555551');
    await tapText(tester, 'متابعة');
    expect(tester.takeException(), isNull);
    await capture('phone-verification-ar');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final lang in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets('phone screens fit 320x568 scale 1.5 $lang dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({'language': lang});
        final prefs = await SharedPreferences.getInstance();
        final api = ApiClient(const AppConfig('https://daira.example.invalid'), MemoryVault(), testInfo);
        final repo = FakePhone(api)..arabicCountries = lang == 'ar';
        final container = ProviderContainer(
          overrides: [
            preferencesProvider.overrideWithValue(prefs),
            apiProvider.overrideWithValue(api),
            clientInfoProvider.overrideWithValue(testInfo),
            phoneAuthRepositoryProvider.overrideWithValue(repo),
            appRepositoryProvider.overrideWithValue(FakeAppRepository(phoneSettings())),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: dark ? DairaTheme.dark : DairaTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: const PhoneAuthScreen(purpose: PhonePurpose.signup),
            ),
          ),
        );
        await TestHarness.settle(tester);
        expect(tester.takeException(), isNull);
        if (lang == 'ar' && !dark) {
          await tester.tap(find.text('مصر'));
          await TestHarness.settle(tester);
          tester.view.viewInsets = const FakeViewPadding(bottom: 220);
          await tester.pump();
          await tester.enterText(find.byType(TextFormField).last, '966');
          await TestHarness.settle(tester);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text('المملكة العربية السعودية'));
          await tester.tap(find.text('المملكة العربية السعودية'));
          tester.view.viewInsets = const FakeViewPadding();
          await TestHarness.settle(tester);
          expect(find.text('+966'), findsOneWidget);
        }
        if (find.byType(TextFormField).evaluate().isEmpty) {
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
          await TestHarness.settle(tester);
        }
        await tester.enterText(find.byType(TextFormField).first, '+201055555551');
        await tester.ensureVisible(find.text(lang == 'ar' ? 'متابعة' : 'Continue').last);
        await tester.tap(find.text(lang == 'ar' ? 'متابعة' : 'Continue').last);
        await TestHarness.settle(tester);
        if (find.text('+201055555551').evaluate().isEmpty) {
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
          await TestHarness.settle(tester);
        }
        expect(find.text('+201055555551'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
