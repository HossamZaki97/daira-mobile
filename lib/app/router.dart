import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/account/account_screen.dart';
import '../features/account/content_screen.dart';
import '../features/account/password_screen.dart';
import '../features/account/sessions_screen.dart';
import '../features/auth/auth_screens.dart';
import '../features/auth/welcome_screen.dart';
import '../features/auth/add_phone_screen.dart';
import '../features/auth/phone_auth_screen.dart';
import '../core/data/phone_auth_repository.dart';
import '../features/circles/circle_screen.dart';
import '../features/circles/circles_screen.dart';
import '../features/circles/activity_screen.dart';
import '../features/circles/installments_screen.dart';
import '../features/circles/turn_order_screen.dart';
import '../features/create/create_circle_screen.dart';
import '../features/home/home_screen.dart';
import '../features/contacts/contacts_screen.dart';
import '../features/contacts/links_screen.dart';
import '../features/contacts/scan_screen.dart';
import '../features/invitations/join_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/startup/gate_screens.dart';
import 'shell.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const maintenance = '/maintenance';
  static const update = '/update';
  static const offline = '/offline';

  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const verify = '/verify';
  static const forgot = '/forgot';
  static const emailSignIn = '/sign-in/email';
  static const emailForgot = '/forgot/email';
  static const phone = '/verify-phone';
  static const attachPhone = '/account/phone';
  static const changePhone = '/account/change-phone';

  static const home = '/';
  static const circles = '/circles';
  static const notifications = '/notifications';
  static const account = '/account';

  static const newCircle = '/circles/new';
  static String circle(String id) => '/circles/$id';
  static String editDraft(String id) => '/circles/$id/edit';
  static String activity(String id) => '/circles/$id/activity';
  static String installments(String id) => '/circles/$id/installments';
  static String turnOrder(String id) => '/circles/$id/order';
  static String join([String? code]) => code == null ? '/join' : '/join?code=${Uri.encodeQueryComponent(code)}';
  static const contacts = '/account/contacts';
  static const links = '/account/links';
  static const scanCode = '/scan';
  static const sessions = '/account/sessions';
  static const password = '/account/password';
  static String content(String slug) => '/content/$slug';

  static const gates = {splash, maintenance, update, offline};

  /// Screens for signed-out people.
  static const auth = {welcome, signIn, signUp, verify, forgot, emailSignIn, emailForgot};

  static bool isContent(String location) => location.startsWith('/content/');
}

/// Where the app must be, given the backend gates and the session. Pure, so it is unit-tested.
String? redirectFor({
  required StartupStatus status,
  required bool signedIn,
  required String location,
  bool phoneRequired = false,
}) {
  final gate = switch (status) {
    StartupStatus.loading => Routes.splash,
    StartupStatus.offline || StartupStatus.unavailable => Routes.offline,
    StartupStatus.maintenance => Routes.maintenance,
    StartupStatus.updateRequired => Routes.update,
    StartupStatus.ready => null,
  };
  if (gate != null) return location == gate ? null : gate;
  if (Routes.isContent(location)) {
    return null; // terms and privacy are readable by anyone
  }
  if (!signedIn) return Routes.auth.contains(location) ? null : Routes.welcome;
  if (phoneRequired) return location == Routes.phone ? null : Routes.phone;
  if (location == Routes.phone) return Routes.home;
  if (Routes.auth.contains(location) || Routes.gates.contains(location)) {
    return Routes.home;
  }
  return null;
}

final _rootKey = GlobalKey<NavigatorState>();

Widget _phoneScreen(Ref ref, PhonePurpose purpose, {bool forced = false}) =>
    ref.read(settingsProvider)?.phoneVerificationAvailable == true
    ? PhoneAuthScreen(purpose: purpose)
    : AddPhoneScreen(forced: forced);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(startupProvider.select((s) => s.status), (_, _) => refresh.value++);
  ref.listen(sessionProvider.select((s) => s != null), (_, _) => refresh.value++);
  ref.listen(
    sessionProvider.select((s) => (s?.profile.phoneVerified, s?.profile.phoneRequired)),
    (_, _) => refresh.value++,
  );

  GoRoute page(String path, Widget Function(GoRouterState state) build) =>
      GoRoute(path: path, parentNavigatorKey: _rootKey, builder: (_, state) => build(state));

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(
      status: ref.read(startupProvider).status,
      signedIn: ref.read(sessionProvider) != null,
      location: state.matchedLocation,
      // The server decides (no phone yet, or WhatsApp is ready and it is unconfirmed).
      phoneRequired: ref.read(sessionProvider)?.profile.phoneRequired == true,
    ),
    routes: [
      page(Routes.splash, (_) => const SplashScreen()),
      page(Routes.maintenance, (_) => const MaintenanceScreen()),
      page(Routes.update, (_) => const UpdateRequiredScreen()),
      page(Routes.offline, (_) => const OfflineScreen()),
      page(Routes.welcome, (_) => const WelcomeScreen()),
      page(
        Routes.signIn,
        (s) => ref.read(settingsProvider)?.phoneAuthEnabled == true || ref.read(settingsProvider)?.reviewEnabled == true
            ? const PhoneAuthScreen()
            : SignInScreen(email: s.uri.queryParameters['email']),
      ),
      page(Routes.emailSignIn, (s) => SignInScreen(email: s.uri.queryParameters['email'])),
      page(Routes.emailForgot, (s) => ForgotPasswordScreen(email: s.uri.queryParameters['email'])),
      page(
        Routes.signUp,
        (_) => ref.read(settingsProvider)?.phoneVerificationAvailable == true
            ? const PhoneAuthScreen(purpose: PhonePurpose.signup)
            : const SignUpScreen(),
      ),
      page(Routes.verify, (s) => VerifyEmailScreen(email: s.uri.queryParameters['email'] ?? '')),
      page(
        Routes.forgot,
        (s) => ref.read(settingsProvider)?.phoneVerificationAvailable == true
            ? const PhoneAuthScreen(purpose: PhonePurpose.reset)
            : ForgotPasswordScreen(email: s.uri.queryParameters['email']),
      ),
      // Without WhatsApp the number is typed and saved; with it, it is confirmed.
      page(Routes.phone, (_) => _phoneScreen(ref, PhonePurpose.attach, forced: true)),
      page(Routes.attachPhone, (_) => _phoneScreen(ref, PhonePurpose.attach)),
      page(Routes.changePhone, (_) => _phoneScreen(ref, PhonePurpose.change)),
      page('/content/:slug', (s) => ContentScreen(slug: s.pathParameters['slug']!)),
      // Full-screen tasks (no tab bar). Listed before the tabs so "/circles/new"
      // is not read as a circle id.
      page(Routes.newCircle, (_) => const CreateCircleScreen()),
      page('/circles/:id/edit', (s) => CreateCircleScreen(draftId: s.pathParameters['id'])),
      page('/join', (s) => JoinScreen(code: s.uri.queryParameters['code'])),
      page(Routes.scanCode, (_) => const ScanCodeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          // A circle and its pages keep the tab bar, under «جمعياتي».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.circles,
                builder: (_, _) => const CirclesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) => CircleScreen(id: s.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'activity',
                        builder: (_, s) => ActivityScreen(circleId: s.pathParameters['id']!),
                      ),
                      GoRoute(
                        path: 'installments',
                        builder: (_, s) => InstallmentsScreen(circleId: s.pathParameters['id']!),
                      ),
                      GoRoute(
                        path: 'order',
                        builder: (_, s) => TurnOrderScreen(circleId: s.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.account,
                builder: (_, _) => const AccountScreen(),
                routes: [
                  GoRoute(path: 'contacts', builder: (_, _) => const ContactsScreen()),
                  GoRoute(path: 'links', builder: (_, _) => const LinksScreen()),
                  GoRoute(path: 'sessions', builder: (_, _) => const SessionsScreen()),
                  GoRoute(path: 'password', builder: (_, _) => const PasswordScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
