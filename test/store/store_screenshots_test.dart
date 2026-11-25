// Store screenshots: the real screens with realistic sample data, saved as PNG
// files under build/store_shots/<ar|en>/. Nothing is sent anywhere.
//
//   flutter test test/store --dart-define=STORE_SHOTS=true
//
// Skipped in the normal `flutter test` run.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:daira/app/router.dart';
import 'package:daira/core/api/api_client.dart';
import 'package:daira/core/config.dart';
import 'package:daira/core/data/repositories.dart';
import 'package:daira/core/models/account.dart';
import 'package:daira/core/models/activity.dart';
import 'package:daira/core/models/circle.dart';
import 'package:daira/core/models/json.dart';
import 'package:daira/core/providers.dart';
import 'package:daira/design/theme.dart';
import 'package:daira/l10n/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

const _enabled = bool.fromEnvironment('STORE_SHOTS');

/// A common modern iPhone (logical points) and its pixel density, or an
/// iPad Pro 12.9" with --dart-define=STORE_DEVICE=ipad.
const _ipad = String.fromEnvironment('STORE_DEVICE') == 'ipad';
const _size = _ipad ? Size(1024, 1366) : Size(390, 844);
const _ratio = _ipad ? 2.0 : 3.0;
const _dir = _ipad ? 'build/store_shots_ipad' : 'build/store_shots';
const _currency = 'EGP';

final _frame = GlobalKey();

void main() {
  setUpAll(() async {
    if (_enabled) await _loadFonts();
  });

  for (final lang in ['ar', 'en']) {
    testWidgets('store screenshots: welcome ($lang)', (tester) async {
      await _start(tester, lang, signedIn: false);
      await _shot(tester, lang, 'welcome');
    }, skip: !_enabled);

    testWidgets('store screenshots: app ($lang)', (tester) async {
      final app = await _start(tester, lang, signedIn: true);
      final d = _Data(lang);

      await _shot(tester, lang, 'home');

      app.go(Routes.circles);
      await _shot(tester, lang, 'circles');

      app.go(Routes.circle(_Data.family));
      await _settle(tester);
      await _shot(tester, lang, 'circle');

      final t = _t(tester);
      await _scrollTo(tester, find.textContaining(RegExp(RegExp.escape(t.roundPaymentsTitle(999)).replaceAll('999', r'\d+'))));
      await _shot(tester, lang, 'payments');

      app.go(Routes.activity(_Data.family));
      await _shot(tester, lang, 'activity');

      app.go(Routes.notifications);
      await _shot(tester, lang, 'notifications');

      // Create wizard → turn order step.
      app.go(Routes.newCircle);
      await _settle(tester);
      await tester.enterText(find.byType(TextFormField).at(0), d.newCircle);
      await tester.enterText(find.byType(TextFormField).at(1), '1500');
      await tapText(tester, t.next);
      final names = d.newMembers;
      // One name field and an «add» button (by its tooltip).
      for (final name in names) {
        await tester.enterText(find.byType(TextFormField).first, name);
        await tester.pump();
        await tester.tap(find.byTooltip(t.addMember));
        await _settle(tester);
      }
      await _shot(tester, lang, 'create_members');
      await tapText(tester, t.next);
      await _shot(tester, lang, 'create_order');
    }, skip: !_enabled);
  }
}

// ------------------------------------------------------------ harness

class _App {
  _App(this.container);
  final ProviderContainer container;
  void go(String location) => container.read(routerProvider).go(location);
}

Future<_App> _start(WidgetTester tester, String lang, {required bool signedIn}) async {
  tester.view.physicalSize = _size * _ratio;
  tester.view.devicePixelRatio = _ratio;
  // The device's status bar (top) and home indicator (bottom), as on a real
  // iPhone/iPad: the app keeps clear of them and the framing script draws them.
  final insets = FakeViewPadding(top: (_ipad ? 24 : 47) * _ratio, bottom: (_ipad ? 20 : 34) * _ratio);
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'language': lang, 'theme': 'light'});
  final preferences = await SharedPreferences.getInstance();
  final d = _Data(lang);
  profileJson = {'id': 'p1', 'name': d.me, 'email': 'mona@example.invalid', 'lang': lang};
  final api = ApiClient(const AppConfig('https://daira.example.invalid'), MemoryVault(), testInfo);
  if (signedIn) await api.startSession(sessionJson());
  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(preferences),
      clientInfoProvider.overrideWithValue(testInfo),
      apiProvider.overrideWithValue(api),
      appRepositoryProvider.overrideWithValue(FakeAppRepository()),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(api)),
      accountRepositoryProvider.overrideWithValue(_Account(d)),
      circlesRepositoryProvider.overrideWithValue(_Circles(d)),
      notificationsRepositoryProvider.overrideWithValue(_Notifications(d)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: _frame,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: DairaTheme.light,
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: ref.watch(routerProvider),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1600)); // splash minimum
  await _settle(tester);
  return _App(container);
}

AppLocalizations _t(WidgetTester tester) => tester.element(find.byType(Scaffold).last).l10n;

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await _settle(tester);
  final scrollable = Scrollable.of(tester.element(finder.first));
  final box = tester.renderObject<RenderBox>(finder.first);
  final top = box.localToGlobal(Offset.zero).dy;
  // Bring the section near the top, under the app bar.
  scrollable.position.jumpTo((scrollable.position.pixels + top - 68).clamp(0.0, scrollable.position.maxScrollExtent).toDouble());
  await _settle(tester);
}

Future<void> _shot(WidgetTester tester, String lang, String name) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(tester);
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_frame));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$_dir/$lang/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Real fonts instead of the test font (Cairo, Phosphor icons, Material icons).
Future<void> _loadFonts() async {
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

// ------------------------------------------------------------ sample data

String _day(int days) {
  final d = DateTime.now().add(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String _ago(Duration d) => DateTime.now().subtract(d).toIso8601String();

class _Data {
  _Data(this.lang);
  final String lang;
  bool get ar => lang == 'ar';

  static const family = 'c-family';
  static const office = 'c-office';
  static const friends = 'c-friends';

  String get me => ar ? 'منى عادل' : 'Mona Adel';
  List<String> get people => ar
      ? ['منى عادل', 'أحمد سمير', 'سارة محمود', 'كريم حسن', 'ليلى فؤاد', 'عمر خالد', 'نور الهدى', 'يوسف إبراهيم', 'هبة مصطفى', 'مازن علي']
      : ['Mona Adel', 'Ahmed Samir', 'Sara Mahmoud', 'Karim Hassan', 'Laila Fouad', 'Omar Khaled', 'Nour Elhoda', 'Youssef Ibrahim', 'Heba Mostafa', 'Mazen Ali'];

  String get familyName => ar ? 'جمعية العيلة' : 'Family circle';
  String get officeName => ar ? 'جمعية الشغل' : 'Office circle';
  String get friendsName => ar ? 'جمعية الأصحاب' : 'Friends circle';
  String get draftName => ar ? 'جمعية رمضان' : 'Ramadan circle';
  String get doneName => ar ? 'جمعية الصيف' : 'Summer circle';
  String get newCircle => ar ? 'جمعية الجيران' : 'Neighbours circle';
  List<String> get newMembers => ar
      ? ['خالد يوسف', 'دينا سامي', 'طارق نبيل', 'رنا أشرف']
      : ['Khaled Youssef', 'Dina Samy', 'Tarek Nabil', 'Rana Ashraf'];
  String get officeOrganizer => ar ? 'خالد رضا' : 'Khaled Reda';

  Json money(int major) => {'amount_minor': major * 100, 'currency': _currency, 'decimals': 2};

  HomeData home() => HomeData.fromJson({
    'actions': [
      {'type': 'confirm', 'circle_id': family, 'circle': familyName, 'round_number': 4, ...money(2000), 'count': 3},
      {'type': 'pay', 'circle_id': office, 'circle': officeName, 'round_number': 7, ...money(1000), 'due_date': _day(3)},
    ],
    'upcoming': [
      {'circle_id': friends, 'circle': friendsName, 'round_number': 2, ...money(500), 'state': 'pending', 'due_date': _day(5)},
      {'circle_id': family, 'circle': familyName, 'round_number': 4, ...money(2000), 'state': 'approved', 'due_date': _day(6)},
    ],
    'next_turn': {
      'circle_id': office,
      'circle': officeName,
      'round_number': 9,
      'total_rounds': 12,
      ...money(12000),
      'rounds_before': 2,
      'due_date': _day(64),
    },
    'active_circles': 3,
    'unread_notifications': 2,
  });

  List<CircleSummary> circles(CircleFilter? filter) {
    Json summary(String id, String name, String status, int installment, int members, int? round, {
      bool organizer = false,
      String cadence = 'month',
      int collected = 0,
      String? mine,
      int? myTurn,
      int? turnIn,
      int? due,
    }) => {
      'id': id,
      'name': name,
      'status': status,
      'version': 1,
      'currency': _currency,
      'decimals': 2,
      'installment_minor': installment * 100,
      'cadence': cadence,
      'interval': 1,
      'is_organizer': organizer,
      'total_rounds': members,
      'collected_count': collected,
      'member_count': members,
      'current_round': round,
      'current_due_date': due == null ? null : _day(due),
      'current_state': round == null ? null : 'collecting',
      'my_obligation_state': mine,
      'my_next_turn': myTurn,
      'my_next_turn_date': myTurn == null ? null : _day(turnIn ?? 30),
    };
    final all = switch (filter) {
      CircleFilter.draft => [summary('c-draft', draftName, 'draft', 1000, 8, null, organizer: true)],
      CircleFilter.completed => [summary('c-done', doneName, 'completed', 750, 6, null)],
      _ => [
        summary(family, familyName, 'active', 2000, 10, 4, organizer: true, collected: 6, mine: 'approved', myTurn: 5, turnIn: 36, due: 6),
        summary(office, officeName, 'active', 1000, 12, 7, collected: 8, mine: 'pending', myTurn: 9, turnIn: 64, due: 3),
        summary(friends, friendsName, 'active', 500, 6, 2, cadence: 'week', collected: 2, mine: 'pending', myTurn: 4, turnIn: 19, due: 5),
      ],
    };
    return [for (final c in all) CircleSummary.fromJson(c)];
  }

  Circle familyCircle() {
    final p = people;
    // Turn order: who receives each round.
    const order = [1, 4, 5, 2, 0, 3, 6, 7, 8, 9];
    // Round 4: three reported payments waiting for the organizer.
    const states = ['approved', 'approved', 'approved', 'reported', 'reported', 'approved', 'reported', 'approved', 'pending', 'approved'];
    Json round(int number) {
      final recipient = order[number - 1];
      final current = number == 4;
      final done = number < 4;
      return {
        'number': number,
        'recipient_id': 'm${recipient + 1}',
        'recipient': p[recipient],
        'due_date': _day(6 + (number - 4) * 30),
        'expected_minor': 2000000,
        'approved_minor': done ? 2000000 : (current ? 1200000 : 0),
        'remaining_minor': done ? 0 : (current ? 800000 : 2000000),
        'state': done ? 'completed' : 'collecting',
        if (done) 'payout_at': _day(-((4 - number) * 30) + 2),
        if (done) 'received_at': _day(-((4 - number) * 30) + 3),
        'obligations': current
            ? [
                for (var i = 0; i < p.length; i++)
                  {
                    'id': 'o$i',
                    'member_id': 'm${i + 1}',
                    'member': p[i],
                    'amount_minor': 200000,
                    'state': states[i],
                    'version': 1,
                    if (states[i] != 'pending') 'reported_at': _ago(Duration(hours: 3 + i * 5)),
                    if (states[i] == 'approved') 'approved_at': _ago(Duration(hours: 1 + i * 4)),
                  },
              ]
            : <Json>[],
      };
    }

    return Circle.fromJson({
      'id': family,
      'name': familyName,
      'status': 'active',
      'version': 7,
      'currency': _currency,
      'decimals': 2,
      'installment_minor': 200000,
      'cadence': 'month',
      'interval': 1,
      'start_date': _day(-84),
      'organizer_id': 'p1',
      'actor_member_id': 'm1',
      'is_organizer': true,
      'current_round': 4,
      'members': [
        for (var i = 0; i < p.length; i++)
          {'id': 'm${i + 1}', 'name': p[i], 'shares': 1, 'organizer': i == 0, 'linked': i != 9 && i != 8},
      ],
      'rounds': [for (var n = 1; n <= 10; n++) round(n)],
    });
  }

  List<CircleEvent> events() {
    final p = people;
    Json e(String action, String actor, Duration ago, {int? round, String? member}) =>
        {'id': '$action$round$member', 'action': action, 'actor': actor, 'at': _ago(ago), 'round_number': round, 'member': member};
    return [
      for (final j in [
        e('report', p[6], const Duration(minutes: 40), round: 4, member: p[6]),
        e('report', p[4], const Duration(hours: 3), round: 4, member: p[4]),
        e('approve', me, const Duration(hours: 20), round: 4, member: p[7]),
        e('report', p[3], const Duration(hours: 26), round: 4, member: p[3]),
        e('approve', me, const Duration(days: 2), round: 4, member: p[5]),
        e('approve', me, const Duration(days: 2, hours: 3), round: 4, member: p[2]),
        e('receipt', p[2], const Duration(days: 27), round: 3),
        e('payout', me, const Duration(days: 28), round: 3),
        e('collection_completed', me, const Duration(days: 28, hours: 1), round: 3),
        e('invitation_accepted', p[7], const Duration(days: 40)),
      ])
        CircleEvent.fromJson(j),
    ];
  }

  List<AppNotification> notifications() {
    final p = people;
    Json n(String id, String kind, Duration ago, {
      bool read = true,
      bool action = false,
      String? circle,
      int? round,
      String? actor,
      String? member,
      int? amount,
    }) => {
      'id': id,
      'kind': kind,
      'read': read,
      'action_required': action,
      'circle_id': circle == null ? null : family,
      'circle': circle,
      'round_number': round,
      'actor': actor,
      'member': member,
      if (amount != null) ...money(amount),
      'at': _ago(ago),
    };
    return [
      for (final j in [
        n('n1', 'payment_reported', const Duration(minutes: 40), read: false, action: true, circle: familyName, round: 4, actor: p[6]),
        n('n2', 'payment_reported', const Duration(hours: 3), read: false, action: true, circle: familyName, round: 4, actor: p[4]),
        n('n3', 'payment_due_soon', const Duration(hours: 9), circle: officeName, round: 7, amount: 1000),
        n('n4', 'payment_confirmed', const Duration(days: 1), circle: officeName, round: 6, actor: officeOrganizer),
        n('n5', 'member_joined', const Duration(days: 3), circle: friendsName, actor: p[9]),
        n('n6', 'payout_received', const Duration(days: 27), circle: familyName, round: 3, actor: p[2]),
      ])
        AppNotification.fromJson(j),
    ];
  }
}

// ------------------------------------------------------------ fake repositories

class _Account implements AccountRepository {
  _Account(this.d);
  final _Data d;

  @override
  Future<HomeData> home() async => d.home();

  @override
  Future<Profile> me() async => Profile.fromJson(profileJson);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Circles implements CirclesRepository {
  _Circles(this.d);
  final _Data d;

  @override
  Future<List<CircleSummary>> list([CircleFilter? filter]) async => d.circles(filter);

  @override
  Future<Circle> get(String id) async => d.familyCircle();

  @override
  Future<Paged<CircleEvent>> events(String id, {String? cursor, int limit = 30}) async => Paged(d.events());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Notifications implements NotificationsRepository {
  _Notifications(this.d);
  final _Data d;

  @override
  Future<Paged<AppNotification>> page({String? cursor, int limit = 30}) async => Paged(d.notifications(), unread: 2);

  @override
  Future<int> unreadCount() async => 2;

  @override
  Future<int> markRead([List<String>? ids]) async => 2;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
