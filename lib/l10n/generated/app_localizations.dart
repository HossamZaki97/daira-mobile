import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Daira'**
  String get appName;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to follow your circles.'**
  String get signInBody;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Fill in this field.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorOffline;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Daira is not responding right now. Try again shortly.'**
  String get errorUnavailable;

  /// No description provided for @errorCredentials.
  ///
  /// In en, this message translates to:
  /// **'Check your email and password. New accounts must confirm their email first.'**
  String get errorCredentials;

  /// No description provided for @errorSuspended.
  ///
  /// In en, this message translates to:
  /// **'This account is suspended. Contact Daira support.'**
  String get errorSuspended;

  /// No description provided for @errorSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Sign in again.'**
  String get errorSessionEnded;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This changed in the meantime. We refreshed it — check and try again.'**
  String get errorConflict;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You can\'t do this in this circle.'**
  String get errorForbidden;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a little and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Check the highlighted information.'**
  String get errorInvalidInput;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available.'**
  String get errorNotFound;

  /// No description provided for @errorCircleSuspended.
  ///
  /// In en, this message translates to:
  /// **'This circle is suspended by Daira support.'**
  String get errorCircleSuspended;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Daira is under maintenance'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re improving the service. Your data is safe — come back shortly.'**
  String get maintenanceBody;

  /// No description provided for @maintenanceUntil.
  ///
  /// In en, this message translates to:
  /// **'Expected back: {until}'**
  String maintenanceUntil(String until);

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Daira to continue'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Update from the store to keep using Daira.'**
  String get updateRequiredBody;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is ready in the store.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateRequiredFrom.
  ///
  /// In en, this message translates to:
  /// **'Required from {date}'**
  String updateRequiredFrom(String date);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNow;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Daira needs the internet to keep your circles in sync.'**
  String get offlineBody;

  /// No description provided for @unavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach Daira'**
  String get unavailableTitle;

  /// No description provided for @unavailableBody.
  ///
  /// In en, this message translates to:
  /// **'The service didn\'t respond. Try again in a moment.'**
  String get unavailableBody;

  /// No description provided for @obligationPending.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get obligationPending;

  /// No description provided for @obligationReported.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get obligationReported;

  /// No description provided for @obligationApproved.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get obligationApproved;

  /// No description provided for @obligationOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get obligationOverdue;

  /// No description provided for @actionPaid.
  ///
  /// In en, this message translates to:
  /// **'I paid'**
  String get actionPaid;

  /// No description provided for @actionReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get actionReceived;

  /// No description provided for @actionNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Not received'**
  String get actionNotReceived;

  /// No description provided for @actionPayout.
  ///
  /// In en, this message translates to:
  /// **'I handed it over'**
  String get actionPayout;

  /// No description provided for @actionReceipt.
  ///
  /// In en, this message translates to:
  /// **'I received it'**
  String get actionReceipt;

  /// No description provided for @circleDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get circleDraft;

  /// No description provided for @circleActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get circleActive;

  /// No description provided for @circleSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get circleSuspended;

  /// No description provided for @circleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get circleCompleted;

  /// No description provided for @circleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get circleCancelled;

  /// No description provided for @roundCollecting.
  ///
  /// In en, this message translates to:
  /// **'Collecting'**
  String get roundCollecting;

  /// No description provided for @roundReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to hand over'**
  String get roundReady;

  /// No description provided for @roundPayoutReported.
  ///
  /// In en, this message translates to:
  /// **'Awaiting receipt'**
  String get roundPayoutReported;

  /// No description provided for @roundCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get roundCompleted;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @emptyCirclesTitle.
  ///
  /// In en, this message translates to:
  /// **'No circles yet'**
  String get emptyCirclesTitle;

  /// No description provided for @emptyCirclesBody.
  ///
  /// In en, this message translates to:
  /// **'Create a circle for your group, or join one with an invitation code.'**
  String get emptyCirclesBody;

  /// No description provided for @createCircle.
  ///
  /// In en, this message translates to:
  /// **'Create a circle'**
  String get createCircle;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get joinWithCode;

  /// No description provided for @roundOf.
  ///
  /// In en, this message translates to:
  /// **'Round {number} of {total}'**
  String roundOf(int number, int total);

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabCircles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get tabCircles;

  /// No description provided for @tabNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tabNotifications;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your circles, clearly'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Track every installment and every turn with your group. Money moves outside Daira.'**
  String get welcomeBody;

  /// No description provided for @welcomePoint1.
  ///
  /// In en, this message translates to:
  /// **'Every due date in one place'**
  String get welcomePoint1;

  /// No description provided for @welcomePoint2.
  ///
  /// In en, this message translates to:
  /// **'Payments confirmed by the organizer'**
  String get welcomePoint2;

  /// No description provided for @welcomePoint3.
  ///
  /// In en, this message translates to:
  /// **'Everyone knows their turn'**
  String get welcomePoint3;

  /// No description provided for @welcomeTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the '**
  String get welcomeTermsPrefix;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get faq;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @signUpBody.
  ///
  /// In en, this message translates to:
  /// **'We will send a code to confirm your email.'**
  String get signUpBody;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters.'**
  String passwordHint(int min);

  /// No description provided for @signUpTerms.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to the terms of use.'**
  String get signUpTerms;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccountSignIn;

  /// No description provided for @noAccountCreate.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccountCreate;

  /// No description provided for @confirmEmailLink.
  ///
  /// In en, this message translates to:
  /// **'I have a confirmation code'**
  String get confirmEmailLink;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a password of at least {min} characters.'**
  String errorWeakPassword(int min);

  /// No description provided for @errorSignupDisabled.
  ///
  /// In en, this message translates to:
  /// **'New accounts are paused for now. Try again later.'**
  String get errorSignupDisabled;

  /// No description provided for @errorVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or expired. Check the latest email or send a new code.'**
  String get errorVerificationCode;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8-digit code from the email we sent. You can also tap the link in the same email.'**
  String get verifyBody;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get verificationCode;

  /// No description provided for @verificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8 digits.'**
  String get verificationCodeHint;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmEmail;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Send again in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @confirmationResent.
  ///
  /// In en, this message translates to:
  /// **'If the email needs confirming, a new code is on its way.'**
  String get confirmationResent;

  /// No description provided for @emailConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed. Sign in to continue.'**
  String get emailConfirmed;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email. We will send a link to choose a new password.'**
  String get forgotBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @resetSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account uses this email, a reset link is on its way. Choose the new password from the link, then sign in here.'**
  String get resetSentBody;

  /// No description provided for @useAnotherEmail.
  ///
  /// In en, this message translates to:
  /// **'Use another email'**
  String get useAnotherEmail;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String hello(String name);

  /// No description provided for @needsYou.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get needsYou;

  /// No description provided for @nothingNeeded.
  ///
  /// In en, this message translates to:
  /// **'You are all set. Nothing needs you now.'**
  String get nothingNeeded;

  /// No description provided for @upcomingPayments.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get upcomingPayments;

  /// No description provided for @roundNumber.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundNumber(int number);

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurn;

  /// No description provided for @turnIsNow.
  ///
  /// In en, this message translates to:
  /// **'This round is yours'**
  String get turnIsNow;

  /// No description provided for @turnInRounds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Next round} other{In {count} rounds}}'**
  String turnInRounds(int count);

  /// No description provided for @actionPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay your installment'**
  String get actionPayTitle;

  /// No description provided for @actionReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm you received the payout'**
  String get actionReceiptTitle;

  /// No description provided for @actionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment to confirm} other{{count} payments to confirm}}'**
  String actionConfirmTitle(int count);

  /// No description provided for @actionPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand the amount to {name}'**
  String actionPayoutTitle(String name);

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @notReceivedReason.
  ///
  /// In en, this message translates to:
  /// **'Not received: {reason}'**
  String notReceivedReason(String reason);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Due tomorrow} other{Due in {count} days}}'**
  String dueInDays(int count);

  /// No description provided for @daysLate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day late} other{{count} days late}}'**
  String daysLate(int count);

  /// No description provided for @everyDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String everyDays(int count);

  /// No description provided for @everyWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String everyWeeks(int count);

  /// No description provided for @everyMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String everyMonths(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 h ago} other{{count} h ago}}'**
  String hoursAgo(int count);

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get filterDrafts;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get filterCompleted;

  /// No description provided for @noDrafts.
  ///
  /// In en, this message translates to:
  /// **'No drafts'**
  String get noDrafts;

  /// No description provided for @noCompleted.
  ///
  /// In en, this message translates to:
  /// **'No finished circles yet'**
  String get noCompleted;

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @myTurnRound.
  ///
  /// In en, this message translates to:
  /// **'Your turn: round {round}'**
  String myTurnRound(int round);

  /// No description provided for @draftHint.
  ///
  /// In en, this message translates to:
  /// **'Draft — finish it and start the circle.'**
  String get draftHint;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLog;

  /// No description provided for @confirmPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you pay this installment?'**
  String get confirmPaidTitle;

  /// No description provided for @confirmPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Daira does not move money. This tells the organizer you paid so they can confirm it.'**
  String get confirmPaidBody;

  /// No description provided for @paidDone.
  ///
  /// In en, this message translates to:
  /// **'Sent to the organizer for confirmation.'**
  String get paidDone;

  /// No description provided for @approvedDone.
  ///
  /// In en, this message translates to:
  /// **'{member}\'s payment confirmed.'**
  String approvedDone(String member);

  /// No description provided for @rejectedDone.
  ///
  /// In en, this message translates to:
  /// **'The member will see your reason.'**
  String get rejectedDone;

  /// No description provided for @confirmPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you hand over the amount?'**
  String get confirmPayoutTitle;

  /// No description provided for @confirmPayoutBody.
  ///
  /// In en, this message translates to:
  /// **'{recipient} will be asked to confirm receiving it.'**
  String confirmPayoutBody(String recipient);

  /// No description provided for @payoutDone.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the recipient to confirm.'**
  String get payoutDone;

  /// No description provided for @confirmReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you receive the amount?'**
  String get confirmReceiptTitle;

  /// No description provided for @confirmReceiptBody.
  ///
  /// In en, this message translates to:
  /// **'Confirming closes this round for everyone.'**
  String get confirmReceiptBody;

  /// No description provided for @receiptDone.
  ///
  /// In en, this message translates to:
  /// **'Round closed. Thank you!'**
  String get receiptDone;

  /// No description provided for @circleSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'This circle is paused'**
  String get circleSuspendedTitle;

  /// No description provided for @circleSuspendedBody.
  ///
  /// In en, this message translates to:
  /// **'Daira support paused it. Payments resume when it is resumed.'**
  String get circleSuspendedBody;

  /// No description provided for @circleCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'This circle was cancelled'**
  String get circleCancelledTitle;

  /// No description provided for @circleCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Circle completed — everyone got their turn'**
  String get circleCompletedTitle;

  /// No description provided for @yourPayment.
  ///
  /// In en, this message translates to:
  /// **'Your installment'**
  String get yourPayment;

  /// No description provided for @yourPayout.
  ///
  /// In en, this message translates to:
  /// **'Your payout'**
  String get yourPayout;

  /// No description provided for @payoutSentToYou.
  ///
  /// In en, this message translates to:
  /// **'The organizer says {amount} was handed to you.'**
  String payoutSentToYou(String amount);

  /// No description provided for @handOver.
  ///
  /// In en, this message translates to:
  /// **'Hand over'**
  String get handOver;

  /// No description provided for @readyForPayoutBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone paid. Hand the amount to {recipient}.'**
  String readyForPayoutBody(String recipient);

  /// No description provided for @waitingRecipient.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm receipt.'**
  String waitingRecipient(String name);

  /// No description provided for @paymentsThisRound.
  ///
  /// In en, this message translates to:
  /// **'Payments this round'**
  String get paymentsThisRound;

  /// No description provided for @toReview.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 to review} other{{count} to review}}'**
  String toReview(int count);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String membersCount(int count);

  /// No description provided for @turnOrder.
  ///
  /// In en, this message translates to:
  /// **'Turn order'**
  String get turnOrder;

  /// No description provided for @perShare.
  ///
  /// In en, this message translates to:
  /// **'{amount} per share'**
  String perShare(String amount);

  /// No description provided for @youOrganize.
  ///
  /// In en, this message translates to:
  /// **'You organize'**
  String get youOrganize;

  /// No description provided for @yourTurnNow.
  ///
  /// In en, this message translates to:
  /// **'This round is yours'**
  String get yourTurnNow;

  /// No description provided for @recipientIs.
  ///
  /// In en, this message translates to:
  /// **'{name} receives this round'**
  String recipientIs(String name);

  /// No description provided for @collectedOf.
  ///
  /// In en, this message translates to:
  /// **'{collected} of {total} confirmed'**
  String collectedOf(String collected, String total);

  /// No description provided for @notReceivedHint.
  ///
  /// In en, this message translates to:
  /// **'Pay again or talk to the organizer, then tap «I paid».'**
  String get notReceivedHint;

  /// No description provided for @payHint.
  ///
  /// In en, this message translates to:
  /// **'Pay the organizer the way you agreed, then tell them here.'**
  String get payHint;

  /// No description provided for @waitingOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the organizer to confirm.'**
  String get waitingOrganizer;

  /// No description provided for @paymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by the organizer.'**
  String get paymentConfirmed;

  /// No description provided for @youName.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String youName(String name);

  /// No description provided for @reportedAt.
  ///
  /// In en, this message translates to:
  /// **'Paid {time}'**
  String reportedAt(String time);

  /// No description provided for @rejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment from {member} did not arrive?'**
  String rejectTitle(String member);

  /// No description provided for @rejectBody.
  ///
  /// In en, this message translates to:
  /// **'Write the reason. The member will see it and can pay again.'**
  String get rejectBody;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. no transfer received yet'**
  String get reasonHint;

  /// No description provided for @sharesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 share} other{{count} shares}}'**
  String sharesCount(int count);

  /// No description provided for @memberJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get memberJoined;

  /// No description provided for @memberNotJoined.
  ///
  /// In en, this message translates to:
  /// **'Not joined yet'**
  String get memberNotJoined;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @importedRound.
  ///
  /// In en, this message translates to:
  /// **'Before Daira'**
  String get importedRound;

  /// No description provided for @startCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Start this circle?'**
  String get startCircleTitle;

  /// No description provided for @startCircleBody.
  ///
  /// In en, this message translates to:
  /// **'Members, amounts and turns can no longer change after the start.'**
  String get startCircleBody;

  /// No description provided for @startCircle.
  ///
  /// In en, this message translates to:
  /// **'Start the circle'**
  String get startCircle;

  /// No description provided for @circleStarted.
  ///
  /// In en, this message translates to:
  /// **'The circle has started.'**
  String get circleStarted;

  /// No description provided for @draftTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftTitle;

  /// No description provided for @draftBody.
  ///
  /// In en, this message translates to:
  /// **'Only you can see it. Edit it or start it when ready.'**
  String get draftBody;

  /// No description provided for @editDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get editDraft;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite {name}'**
  String inviteTitle(String name);

  /// No description provided for @inviteBody.
  ///
  /// In en, this message translates to:
  /// **'Share a single-use code. It works for {hours} hours and links this member to their own account.'**
  String inviteBody(int hours);

  /// No description provided for @createInvite.
  ///
  /// In en, this message translates to:
  /// **'Create invitation code'**
  String get createInvite;

  /// No description provided for @inviteActive.
  ///
  /// In en, this message translates to:
  /// **'An invitation is already active'**
  String get inviteActive;

  /// No description provided for @inviteActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}. For safety the code is shown only once — revoke it to create a new one.'**
  String inviteActiveBody(String date);

  /// No description provided for @revokeAndNew.
  ///
  /// In en, this message translates to:
  /// **'Revoke and create a new one'**
  String get revokeAndNew;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke invitation'**
  String get revoke;

  /// No description provided for @revokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this invitation?'**
  String get revokeTitle;

  /// No description provided for @revokeBody.
  ///
  /// In en, this message translates to:
  /// **'The code will stop working right away.'**
  String get revokeBody;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(String date);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @inviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi {member}! Join \"{circle}\" on Daira with this code: {code}\nOr open: {link}'**
  String inviteMessage(String member, String circle, String code, String link);

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your invitation code'**
  String get joinTitle;

  /// No description provided for @joinBody.
  ///
  /// In en, this message translates to:
  /// **'The organizer shares a 12-character code with you.'**
  String get joinBody;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get inviteCode;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 12 characters of the code.'**
  String get inviteCodeHint;

  /// No description provided for @inviteInvalid.
  ///
  /// In en, this message translates to:
  /// **'This code is not valid. Ask the organizer for a new one.'**
  String get inviteInvalid;

  /// No description provided for @inviteExpired.
  ///
  /// In en, this message translates to:
  /// **'This code expired. Ask the organizer for a new one.'**
  String get inviteExpired;

  /// No description provided for @inviteAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already in this circle, or this place is taken.'**
  String get inviteAlreadyMember;

  /// No description provided for @featureDisabled.
  ///
  /// In en, this message translates to:
  /// **'This option is turned off for now.'**
  String get featureDisabled;

  /// No description provided for @joinPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Join this circle?'**
  String get joinPreviewTitle;

  /// No description provided for @organizedBy.
  ///
  /// In en, this message translates to:
  /// **'Organized by {name}'**
  String organizedBy(String name);

  /// No description provided for @joinAs.
  ///
  /// In en, this message translates to:
  /// **'You join as'**
  String get joinAs;

  /// No description provided for @yourTurnRound.
  ///
  /// In en, this message translates to:
  /// **'Your turn: round {round}'**
  String yourTurnRound(int round);

  /// No description provided for @joinNote.
  ///
  /// In en, this message translates to:
  /// **'You confirm your own payments here; the organizer confirms receiving them.'**
  String get joinNote;

  /// No description provided for @joinCircle.
  ///
  /// In en, this message translates to:
  /// **'Join the circle'**
  String get joinCircle;

  /// No description provided for @joinedCircle.
  ///
  /// In en, this message translates to:
  /// **'You joined {circle}.'**
  String joinedCircle(String circle);

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivity;

  /// No description provided for @byDairaSupport.
  ///
  /// In en, this message translates to:
  /// **'Daira support'**
  String get byDairaSupport;

  /// No description provided for @evCircleSaved.
  ///
  /// In en, this message translates to:
  /// **'Circle saved'**
  String get evCircleSaved;

  /// No description provided for @evReport.
  ///
  /// In en, this message translates to:
  /// **'{member} said they paid round {round}'**
  String evReport(String member, int round);

  /// No description provided for @evApprove.
  ///
  /// In en, this message translates to:
  /// **'{member}\'s installment confirmed · round {round}'**
  String evApprove(String member, int round);

  /// No description provided for @evReject.
  ///
  /// In en, this message translates to:
  /// **'{member}\'s installment did not arrive · round {round}'**
  String evReject(String member, int round);

  /// No description provided for @evCollectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'All installments of round {round} collected'**
  String evCollectionCompleted(int round);

  /// No description provided for @evPayout.
  ///
  /// In en, this message translates to:
  /// **'Round {round} handed over'**
  String evPayout(int round);

  /// No description provided for @evReceipt.
  ///
  /// In en, this message translates to:
  /// **'Round {round} received'**
  String evReceipt(int round);

  /// No description provided for @evCircleCompleted.
  ///
  /// In en, this message translates to:
  /// **'The circle finished'**
  String get evCircleCompleted;

  /// No description provided for @evInvitationCreated.
  ///
  /// In en, this message translates to:
  /// **'Invitation created'**
  String get evInvitationCreated;

  /// No description provided for @evInvitationRevoked.
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled'**
  String get evInvitationRevoked;

  /// No description provided for @evInvitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'A member joined with an invitation'**
  String get evInvitationAccepted;

  /// No description provided for @evCircleSuspended.
  ///
  /// In en, this message translates to:
  /// **'Daira support paused the circle'**
  String get evCircleSuspended;

  /// No description provided for @evCircleResumed.
  ///
  /// In en, this message translates to:
  /// **'The circle is running again'**
  String get evCircleResumed;

  /// No description provided for @evCircleCancelled.
  ///
  /// In en, this message translates to:
  /// **'The circle was cancelled'**
  String get evCircleCancelled;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Payments, confirmations and turns will show up here.'**
  String get noNotificationsBody;

  /// No description provided for @needsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs your action'**
  String get needsAction;

  /// No description provided for @ntPaymentReported.
  ///
  /// In en, this message translates to:
  /// **'{actor} paid round {round} — confirm it'**
  String ntPaymentReported(String actor, int round);

  /// No description provided for @ntPaymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{actor} confirmed your payment for round {round}'**
  String ntPaymentConfirmed(String actor, int round);

  /// No description provided for @ntPaymentNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Your payment for round {round} did not arrive: {reason}'**
  String ntPaymentNotReceived(int round, String reason);

  /// No description provided for @ntReadyForPayout.
  ///
  /// In en, this message translates to:
  /// **'Round {round} is collected — hand it to {member}'**
  String ntReadyForPayout(int round, String member);

  /// No description provided for @ntPayoutSent.
  ///
  /// In en, this message translates to:
  /// **'{actor} handed you {amount} — confirm receipt'**
  String ntPayoutSent(String actor, String amount);

  /// No description provided for @ntPayoutReceived.
  ///
  /// In en, this message translates to:
  /// **'{actor} confirmed receiving round {round}'**
  String ntPayoutReceived(String actor, int round);

  /// No description provided for @ntMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'{actor} joined the circle'**
  String ntMemberJoined(String actor);

  /// No description provided for @ntDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Installment for round {round} is due soon ({amount})'**
  String ntDueSoon(int round, String amount);

  /// No description provided for @ntOverdue.
  ///
  /// In en, this message translates to:
  /// **'Installment for round {round} is overdue ({amount})'**
  String ntOverdue(int round, String amount);

  /// No description provided for @ntCircleCompleted.
  ///
  /// In en, this message translates to:
  /// **'The circle is complete'**
  String get ntCircleCompleted;

  /// No description provided for @ntCircleSuspended.
  ///
  /// In en, this message translates to:
  /// **'The circle was paused by support'**
  String get ntCircleSuspended;

  /// No description provided for @ntCircleResumed.
  ///
  /// In en, this message translates to:
  /// **'The circle is active again'**
  String get ntCircleResumed;

  /// No description provided for @ntCircleCancelled.
  ///
  /// In en, this message translates to:
  /// **'The circle was cancelled'**
  String get ntCircleCancelled;

  /// No description provided for @ntGeneric.
  ///
  /// In en, this message translates to:
  /// **'New update'**
  String get ntGeneric;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @signedInDevices.
  ///
  /// In en, this message translates to:
  /// **'Signed-in devices'**
  String get signedInDevices;

  /// No description provided for @helpAndAbout.
  ///
  /// In en, this message translates to:
  /// **'Help and about'**
  String get helpAndAbout;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time.'**
  String get signOutBody;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be closed and your name removed from finished circles. You cannot undo this.'**
  String get deleteBody;

  /// No description provided for @deleteBlocked.
  ///
  /// In en, this message translates to:
  /// **'You are still in an active circle. Finish it before deleting your account.'**
  String get deleteBlocked;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is not correct.'**
  String get wrongPassword;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteForever;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get editName;

  /// No description provided for @editNameBody.
  ///
  /// In en, this message translates to:
  /// **'Shown to the members of your circles.'**
  String get editNameBody;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Other devices will be signed out. This one stays signed in.'**
  String get changePasswordBody;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordChanged;

  /// No description provided for @devicesBody.
  ///
  /// In en, this message translates to:
  /// **'End any session you do not recognise.'**
  String get devicesBody;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'Sign out device'**
  String get endSession;

  /// No description provided for @endSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out this device?'**
  String get endSessionTitle;

  /// No description provided for @endOthersTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out all other devices?'**
  String get endOthersTitle;

  /// No description provided for @endSessionBody.
  ///
  /// In en, this message translates to:
  /// **'It will need to sign in again.'**
  String get endSessionBody;

  /// No description provided for @endOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out all other devices'**
  String get endOthers;

  /// No description provided for @contentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get contentEmpty;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String lastUpdated(String date);

  /// No description provided for @newCircle.
  ///
  /// In en, this message translates to:
  /// **'New circle'**
  String get newCircle;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total} · {title}'**
  String stepOf(int step, int total, String title);

  /// No description provided for @stepBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get stepBasics;

  /// No description provided for @stepMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get stepMembers;

  /// No description provided for @stepOrder.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get stepOrder;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get saveDraft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get draftSaved;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this circle?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'What you entered will be lost.'**
  String get discardBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @startDatePast.
  ///
  /// In en, this message translates to:
  /// **'The first due date is in the past. Choose today or later, or mark rounds already completed.'**
  String get startDatePast;

  /// No description provided for @draftChanged.
  ///
  /// In en, this message translates to:
  /// **'This draft changed on another device. Reopen it and try again.'**
  String get draftChanged;

  /// No description provided for @circleName.
  ///
  /// In en, this message translates to:
  /// **'Circle name'**
  String get circleName;

  /// No description provided for @circleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Family circle 2026'**
  String get circleNameHint;

  /// No description provided for @installmentPerShare.
  ///
  /// In en, this message translates to:
  /// **'Installment per share'**
  String get installmentPerShare;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get amountInvalid;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @cadence.
  ///
  /// In en, this message translates to:
  /// **'Payment schedule'**
  String get cadence;

  /// No description provided for @cadenceDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get cadenceDays;

  /// No description provided for @cadenceWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get cadenceWeeks;

  /// No description provided for @cadenceMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get cadenceMonths;

  /// No description provided for @firstDueDate.
  ///
  /// In en, this message translates to:
  /// **'First due date'**
  String get firstDueDate;

  /// No description provided for @lastDueDate.
  ///
  /// In en, this message translates to:
  /// **'Last due date'**
  String get lastDueDate;

  /// No description provided for @firstDueDateHint.
  ///
  /// In en, this message translates to:
  /// **'Each round follows the schedule from this date.'**
  String get firstDueDateHint;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @membersStepBody.
  ///
  /// In en, this message translates to:
  /// **'Add the other members by name. They can join with an invitation later.'**
  String get membersStepBody;

  /// No description provided for @memberNumber.
  ///
  /// In en, this message translates to:
  /// **'Member {number}'**
  String memberNumber(int number);

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMember;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @totalShares.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 share in total} other{{count} shares in total = {count} rounds}}'**
  String totalShares(int count);

  /// No description provided for @payoutPerRound.
  ///
  /// In en, this message translates to:
  /// **'Each round collects {amount}.'**
  String payoutPerRound(String amount);

  /// No description provided for @sharesLimit.
  ///
  /// In en, this message translates to:
  /// **'A circle needs 2 to {max} shares in total.'**
  String sharesLimit(int max);

  /// No description provided for @orderBody.
  ///
  /// In en, this message translates to:
  /// **'Drag to set who receives each round. One turn per share.'**
  String get orderBody;

  /// No description provided for @orderFixedBody.
  ///
  /// In en, this message translates to:
  /// **'Turns follow the order members were added; you receive last.'**
  String get orderFixedBody;

  /// No description provided for @resetOrder.
  ///
  /// In en, this message translates to:
  /// **'Reset order'**
  String get resetOrder;

  /// No description provided for @noImportedRounds.
  ///
  /// In en, this message translates to:
  /// **'New circle (no rounds before Daira)'**
  String get noImportedRounds;

  /// No description provided for @importedRounds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 round already completed} other{{count} rounds already completed}}'**
  String importedRounds(int count);

  /// No description provided for @importedHint.
  ///
  /// In en, this message translates to:
  /// **'For a circle that already started: the first rounds are marked done.'**
  String get importedHint;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @membersLabel.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersLabel;

  /// No description provided for @roundsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get roundsLabel;

  /// No description provided for @importedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed before Daira'**
  String get importedLabel;

  /// No description provided for @eachRoundCollects.
  ///
  /// In en, this message translates to:
  /// **'Each round collects'**
  String get eachRoundCollects;

  /// No description provided for @reviewNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Money moves outside Daira'**
  String get reviewNoteTitle;

  /// No description provided for @reviewNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Daira records who paid and who received, so everyone sees the same truth.'**
  String get reviewNoteBody;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @paidOf.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} paid'**
  String paidOf(int paid, int total);

  /// No description provided for @unpaidGroup.
  ///
  /// In en, this message translates to:
  /// **'Not paid yet'**
  String get unpaidGroup;

  /// No description provided for @paidGroup.
  ///
  /// In en, this message translates to:
  /// **'Paid ({count})'**
  String paidGroup(int count);

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @recordSeveral.
  ///
  /// In en, this message translates to:
  /// **'Record several'**
  String get recordSeveral;

  /// No description provided for @recordSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Record 1 payment} other{Record {count} payments}}'**
  String recordSelected(int count);

  /// No description provided for @selectWhoPaid.
  ///
  /// In en, this message translates to:
  /// **'Select who paid'**
  String get selectWhoPaid;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record payment for {member}'**
  String recordTitle(String member);

  /// No description provided for @recordBody.
  ///
  /// In en, this message translates to:
  /// **'Use this when the installment reached you, in cash or any other way.'**
  String get recordBody;

  /// No description provided for @paymentMethodOptional.
  ///
  /// In en, this message translates to:
  /// **'Payment method (optional)'**
  String get paymentMethodOptional;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @methodTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get methodTransfer;

  /// No description provided for @methodWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get methodWallet;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @recordedDone.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get recordedDone;

  /// No description provided for @recordedByOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Recorded by the organizer'**
  String get recordedByOrganizer;

  /// No description provided for @reportedAndConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reported by the member, confirmed by the organizer'**
  String get reportedAndConfirmed;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get paymentDetails;

  /// No description provided for @confirmedAt.
  ///
  /// In en, this message translates to:
  /// **'Confirmed {time}'**
  String confirmedAt(String time);

  /// No description provided for @undoPayment.
  ///
  /// In en, this message translates to:
  /// **'Cancel this record'**
  String get undoPayment;

  /// No description provided for @undoPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the payment of {member}?'**
  String undoPaymentTitle(String member);

  /// No description provided for @undoPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'The installment goes back to not paid. This stays in the activity log.'**
  String get undoPaymentBody;

  /// No description provided for @undoneDone.
  ///
  /// In en, this message translates to:
  /// **'Record cancelled'**
  String get undoneDone;

  /// No description provided for @remindUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Remind unpaid members'**
  String get remindUnpaid;

  /// No description provided for @remindTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a reminder?'**
  String get remindTitle;

  /// No description provided for @remindBody.
  ///
  /// In en, this message translates to:
  /// **'Members who use Daira and have not paid get a notification. Left this round: {left}.'**
  String remindBody(int left);

  /// No description provided for @remindAction.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get remindAction;

  /// No description provided for @remindDone.
  ///
  /// In en, this message translates to:
  /// **'Reminder sent'**
  String get remindDone;

  /// No description provided for @remindNextAt.
  ///
  /// In en, this message translates to:
  /// **'Next reminder {time}'**
  String remindNextAt(String time);

  /// No description provided for @remindLimitReached.
  ///
  /// In en, this message translates to:
  /// **'No reminders left this round'**
  String get remindLimitReached;

  /// No description provided for @markReceived.
  ///
  /// In en, this message translates to:
  /// **'Record receipt'**
  String get markReceived;

  /// No description provided for @markReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Did {member} receive the amount?'**
  String markReceivedTitle(String member);

  /// No description provided for @markReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'The round closes and {member} is told. They can say it did not arrive.'**
  String markReceivedBody(String member);

  /// No description provided for @receivedDone.
  ///
  /// In en, this message translates to:
  /// **'Round closed'**
  String get receivedDone;

  /// No description provided for @undoPayout.
  ///
  /// In en, this message translates to:
  /// **'Cancel the handover'**
  String get undoPayout;

  /// No description provided for @undoPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the recorded handover?'**
  String get undoPayoutTitle;

  /// No description provided for @undoPayoutBody.
  ///
  /// In en, this message translates to:
  /// **'The round goes back to ready for handover.'**
  String get undoPayoutBody;

  /// No description provided for @undoPayoutDone.
  ///
  /// In en, this message translates to:
  /// **'Handover cancelled'**
  String get undoPayoutDone;

  /// No description provided for @reopenRound.
  ///
  /// In en, this message translates to:
  /// **'Reopen round {number}'**
  String reopenRound(int number);

  /// No description provided for @reopenBody.
  ///
  /// In en, this message translates to:
  /// **'Use this if the receipt was recorded by mistake. The current round waits until this one closes again.'**
  String get reopenBody;

  /// No description provided for @reopenedDone.
  ///
  /// In en, this message translates to:
  /// **'Round reopened'**
  String get reopenedDone;

  /// No description provided for @receiptRecordedForYou.
  ///
  /// In en, this message translates to:
  /// **'The organizer recorded that you received round {number}.'**
  String receiptRecordedForYou(int number);

  /// No description provided for @notReceivedMine.
  ///
  /// In en, this message translates to:
  /// **'I did not receive it'**
  String get notReceivedMine;

  /// No description provided for @disputeTitle.
  ///
  /// In en, this message translates to:
  /// **'You did not receive the amount?'**
  String get disputeTitle;

  /// No description provided for @disputeBody.
  ///
  /// In en, this message translates to:
  /// **'The round reopens and the organizer is told.'**
  String get disputeBody;

  /// No description provided for @disputeDone.
  ///
  /// In en, this message translates to:
  /// **'The organizer was told'**
  String get disputeDone;

  /// No description provided for @receivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedLabel;

  /// No description provided for @receivedRound.
  ///
  /// In en, this message translates to:
  /// **'Received round {number}'**
  String receivedRound(int number);

  /// No description provided for @turnNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Turn now'**
  String get turnNowLabel;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name: {name}'**
  String accountNameLabel(String name);

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreActions;

  /// No description provided for @installmentsTable.
  ///
  /// In en, this message translates to:
  /// **'Installments table'**
  String get installmentsTable;

  /// No description provided for @editTurnOrder.
  ///
  /// In en, this message translates to:
  /// **'Change turn order'**
  String get editTurnOrder;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminderSettings;

  /// No description provided for @muteReminders.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders off'**
  String get muteReminders;

  /// No description provided for @unmuteReminders.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders on'**
  String get unmuteReminders;

  /// No description provided for @mutedDone.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off for this circle'**
  String get mutedDone;

  /// No description provided for @unmutedDone.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on'**
  String get unmutedDone;

  /// No description provided for @reminderSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Automatic reminders go to registered members who have not paid.'**
  String get reminderSettingsBody;

  /// No description provided for @remindBefore.
  ///
  /// In en, this message translates to:
  /// **'Before the due date'**
  String get remindBefore;

  /// No description provided for @remindOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindOff;

  /// No description provided for @remindDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String remindDays(int count);

  /// No description provided for @remindOnDue.
  ///
  /// In en, this message translates to:
  /// **'On the due date'**
  String get remindOnDue;

  /// No description provided for @remindOverdue.
  ///
  /// In en, this message translates to:
  /// **'When late'**
  String get remindOverdue;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminders updated'**
  String get reminderSaved;

  /// No description provided for @tableLegend.
  ///
  /// In en, this message translates to:
  /// **'Tap a box to see the details.'**
  String get tableLegend;

  /// No description provided for @roundColumn.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundColumn(int number);

  /// No description provided for @reorderBody.
  ///
  /// In en, this message translates to:
  /// **'Any turn that has not been handed over can move. Amounts do not change.'**
  String get reorderBody;

  /// No description provided for @lockedTurns.
  ///
  /// In en, this message translates to:
  /// **'Already handed over'**
  String get lockedTurns;

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Hold a name and drag it up or down'**
  String get dragHint;

  /// No description provided for @reviewChanges.
  ///
  /// In en, this message translates to:
  /// **'Review changes'**
  String get reviewChanges;

  /// No description provided for @reorderConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Save the new order?'**
  String get reorderConfirmTitle;

  /// No description provided for @reorderChange.
  ///
  /// In en, this message translates to:
  /// **'{member}: round {from} → {to}'**
  String reorderChange(String member, int from, int to);

  /// No description provided for @reorderNotice.
  ///
  /// In en, this message translates to:
  /// **'Each member whose turn moved gets a notification.'**
  String get reorderNotice;

  /// No description provided for @reorderDone.
  ///
  /// In en, this message translates to:
  /// **'Turn order saved'**
  String get reorderDone;

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed'**
  String get noChanges;

  /// No description provided for @moveToRound.
  ///
  /// In en, this message translates to:
  /// **'Move to round…'**
  String get moveToRound;

  /// No description provided for @errorReminderLimit.
  ///
  /// In en, this message translates to:
  /// **'No reminders available right now.'**
  String get errorReminderLimit;

  /// No description provided for @errorNobodyToRemind.
  ///
  /// In en, this message translates to:
  /// **'Every registered member has paid.'**
  String get errorNobodyToRemind;

  /// No description provided for @errorRoundHandedOver.
  ///
  /// In en, this message translates to:
  /// **'This round was handed over. Cancel the handover first.'**
  String get errorRoundHandedOver;

  /// No description provided for @ntPaymentDueToday.
  ///
  /// In en, this message translates to:
  /// **'Installment for round {round} is due today ({amount})'**
  String ntPaymentDueToday(int round, String amount);

  /// No description provided for @ntReminder.
  ///
  /// In en, this message translates to:
  /// **'{actor} reminds you of the round {round} installment'**
  String ntReminder(String actor, int round);

  /// No description provided for @ntPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'{actor} recorded your round {round} payment'**
  String ntPaymentRecorded(String actor, int round);

  /// No description provided for @ntPaymentUndone.
  ///
  /// In en, this message translates to:
  /// **'{actor} cancelled the record of your round {round} payment'**
  String ntPaymentUndone(String actor, int round);

  /// No description provided for @ntReceiptRecorded.
  ///
  /// In en, this message translates to:
  /// **'{actor} recorded that you received round {round}'**
  String ntReceiptRecorded(String actor, int round);

  /// No description provided for @ntReceiptDisputed.
  ///
  /// In en, this message translates to:
  /// **'{member} says round {round} did not arrive'**
  String ntReceiptDisputed(String member, int round);

  /// No description provided for @ntPayoutUndone.
  ///
  /// In en, this message translates to:
  /// **'The handover of round {round} was cancelled'**
  String ntPayoutUndone(int round);

  /// No description provided for @ntReceiptUndone.
  ///
  /// In en, this message translates to:
  /// **'Round {round} was reopened'**
  String ntReceiptUndone(int round);

  /// No description provided for @ntTurnChanged.
  ///
  /// In en, this message translates to:
  /// **'Your turn moved to round {round}'**
  String ntTurnChanged(int round);

  /// No description provided for @ntLinkRequest.
  ///
  /// In en, this message translates to:
  /// **'{actor} wants to link your account as {member}'**
  String ntLinkRequest(String actor, String member);

  /// No description provided for @ntJoinRequest.
  ///
  /// In en, this message translates to:
  /// **'{actor} used the invitation for {member}. Is this the right person?'**
  String ntJoinRequest(String actor, String member);

  /// No description provided for @ntCircleInvitation.
  ///
  /// In en, this message translates to:
  /// **'{actor} invites you to a circle'**
  String ntCircleInvitation(String actor);

  /// No description provided for @ntLinkAccepted.
  ///
  /// In en, this message translates to:
  /// **'{member} is now linked to the account'**
  String ntLinkAccepted(String member);

  /// No description provided for @ntAddedToCircle.
  ///
  /// In en, this message translates to:
  /// **'{actor} added you to this circle'**
  String ntAddedToCircle(String actor);

  /// No description provided for @evRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Organizer recorded {member}\'s installment · round {round}'**
  String evRecordPayment(String member, int round);

  /// No description provided for @evUndoPayment.
  ///
  /// In en, this message translates to:
  /// **'{member}\'s recorded installment undone · round {round}'**
  String evUndoPayment(String member, int round);

  /// No description provided for @evUndoPayout.
  ///
  /// In en, this message translates to:
  /// **'Hand-over of round {round} undone'**
  String evUndoPayout(int round);

  /// No description provided for @evReceiptRecorded.
  ///
  /// In en, this message translates to:
  /// **'Organizer recorded the payout of round {round}'**
  String evReceiptRecorded(int round);

  /// No description provided for @evUndoReceipt.
  ///
  /// In en, this message translates to:
  /// **'Round {round} reopened'**
  String evUndoReceipt(int round);

  /// No description provided for @evReceiptDisputed.
  ///
  /// In en, this message translates to:
  /// **'The recipient of round {round} says it did not arrive'**
  String evReceiptDisputed(int round);

  /// No description provided for @evOrderChanged.
  ///
  /// In en, this message translates to:
  /// **'Turn order changed'**
  String get evOrderChanged;

  /// No description provided for @evRemind.
  ///
  /// In en, this message translates to:
  /// **'Reminder sent for round {round}'**
  String evRemind(int round);

  /// No description provided for @evReminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder settings changed'**
  String get evReminderSettings;

  /// No description provided for @evMemberLinked.
  ///
  /// In en, this message translates to:
  /// **'{member} joined with their account'**
  String evMemberLinked(String member);

  /// No description provided for @evMemberUnlinked.
  ///
  /// In en, this message translates to:
  /// **'{member} is no longer linked to an account'**
  String evMemberUnlinked(String member);

  /// No description provided for @startedQuestion.
  ///
  /// In en, this message translates to:
  /// **'The circle already started'**
  String get startedQuestion;

  /// No description provided for @startedHint.
  ///
  /// In en, this message translates to:
  /// **'Some members received before using Daira.'**
  String get startedHint;

  /// No description provided for @nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next installment date'**
  String get nextDueDate;

  /// No description provided for @nextDueHint.
  ///
  /// In en, this message translates to:
  /// **'Daira works out the earlier dates by itself.'**
  String get nextDueHint;

  /// No description provided for @markLastReceivedHint.
  ///
  /// In en, this message translates to:
  /// **'Put members in the order they received, then tap the last one who received.'**
  String get markLastReceivedHint;

  /// No description provided for @shuffleOrder.
  ///
  /// In en, this message translates to:
  /// **'Random order'**
  String get shuffleOrder;

  /// No description provided for @evCircleSavedRandom.
  ///
  /// In en, this message translates to:
  /// **'Circle saved with turns drawn at random'**
  String get evCircleSavedRandom;

  /// No description provided for @installmentDue.
  ///
  /// In en, this message translates to:
  /// **'Installment due'**
  String get installmentDue;

  /// No description provided for @tabPayments.
  ///
  /// In en, this message translates to:
  /// **'Installments'**
  String get tabPayments;

  /// No description provided for @tabTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get tabTurns;

  /// No description provided for @selectedSummary.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} · {amount}'**
  String selectedSummary(int count, String amount);

  /// No description provided for @roundPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Round {number} installments'**
  String roundPaymentsTitle(int number);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @selectToRecordHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the members who paid, then record their payments in one step.'**
  String get selectToRecordHint;

  /// No description provided for @roundsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 round} other{{count} rounds}}'**
  String roundsCount(int count);

  /// No description provided for @randomOrderChip.
  ///
  /// In en, this message translates to:
  /// **'Drawn at random'**
  String get randomOrderChip;

  /// No description provided for @yourTurnTag.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurnTag;

  /// No description provided for @tableMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get tableMember;

  /// No description provided for @tablePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get tablePaid;

  /// No description provided for @tableRecipient.
  ///
  /// In en, this message translates to:
  /// **'Receives this round'**
  String get tableRecipient;

  /// No description provided for @paidRatio.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} paid'**
  String paidRatio(int paid, int total);

  /// No description provided for @moveMemberTo.
  ///
  /// In en, this message translates to:
  /// **'Move {name} to…'**
  String moveMemberTo(String name);

  /// No description provided for @resetChanges.
  ///
  /// In en, this message translates to:
  /// **'Undo changes'**
  String get resetChanges;

  /// No description provided for @reorderHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag a card by ⇅, or tap it to pick its new round.'**
  String get reorderHowTo;

  /// No description provided for @movableTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns you can move'**
  String get movableTurns;

  /// No description provided for @wasRound.
  ///
  /// In en, this message translates to:
  /// **'Was round {number}'**
  String wasRound(int number);

  /// No description provided for @currentRoundTag.
  ///
  /// In en, this message translates to:
  /// **'Current round'**
  String get currentRoundTag;

  /// No description provided for @noChangesYet.
  ///
  /// In en, this message translates to:
  /// **'No changes yet'**
  String get noChangesYet;

  /// No description provided for @reviewChangesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Review 1 change} other{Review {count} changes}}'**
  String reviewChangesCount(int count);

  /// No description provided for @reorderReviewBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One member gets a new turn. Amounts stay the same.} other{{count} members get a new turn. Amounts stay the same.}}'**
  String reorderReviewBody(int count);

  /// No description provided for @saveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get saveOrder;

  /// No description provided for @orderStepHint.
  ///
  /// In en, this message translates to:
  /// **'Draw the order at random, or drag a card by ⇅ to arrange it yourself.'**
  String get orderStepHint;

  /// No description provided for @shufflingNow.
  ///
  /// In en, this message translates to:
  /// **'Drawing…'**
  String get shufflingNow;

  /// No description provided for @receivedBeforeTitle.
  ///
  /// In en, this message translates to:
  /// **'Received before Daira'**
  String get receivedBeforeTitle;

  /// No description provided for @receivedBeforeHint.
  ///
  /// In en, this message translates to:
  /// **'The first turns in the list below.'**
  String get receivedBeforeHint;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateNextWeek.
  ///
  /// In en, this message translates to:
  /// **'In a week'**
  String get dateNextWeek;

  /// No description provided for @dateNextMonthStart.
  ///
  /// In en, this message translates to:
  /// **'1st of next month'**
  String get dateNextMonthStart;

  /// No description provided for @dateOther.
  ///
  /// In en, this message translates to:
  /// **'Another date'**
  String get dateOther;

  /// No description provided for @orderRandom.
  ///
  /// In en, this message translates to:
  /// **'Random draw'**
  String get orderRandom;

  /// No description provided for @orderArranged.
  ///
  /// In en, this message translates to:
  /// **'As arranged'**
  String get orderArranged;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @circleKindTitle.
  ///
  /// In en, this message translates to:
  /// **'Is this circle new?'**
  String get circleKindTitle;

  /// No description provided for @kindNew.
  ///
  /// In en, this message translates to:
  /// **'New circle'**
  String get kindNew;

  /// No description provided for @kindNewHint.
  ///
  /// In en, this message translates to:
  /// **'Starts from the first turn.'**
  String get kindNewHint;

  /// No description provided for @kindRunning.
  ///
  /// In en, this message translates to:
  /// **'Already running'**
  String get kindRunning;

  /// No description provided for @kindRunningHint.
  ///
  /// In en, this message translates to:
  /// **'Started before Daira; continue it here.'**
  String get kindRunningHint;

  /// No description provided for @currentDueDate.
  ///
  /// In en, this message translates to:
  /// **'Current round\'s due date'**
  String get currentDueDate;

  /// No description provided for @currentRoundQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which round is it now?'**
  String get currentRoundQuestion;

  /// No description provided for @currentRoundFirst.
  ///
  /// In en, this message translates to:
  /// **'Nobody has received yet.'**
  String get currentRoundFirst;

  /// No description provided for @currentRoundHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The turn before it counts as received.} other{The {count} turns before it count as received.}}'**
  String currentRoundHint(int count);

  /// No description provided for @orderStepHintRunning.
  ///
  /// In en, this message translates to:
  /// **'Put members in the order they receive (those who already received first), then set the current round.'**
  String get orderStepHintRunning;

  /// No description provided for @myPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'Not paid yet'**
  String get myPaymentDue;

  /// No description provided for @myPaymentLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get myPaymentLate;

  /// No description provided for @myPaymentDone.
  ///
  /// In en, this message translates to:
  /// **'You paid'**
  String get myPaymentDone;

  /// No description provided for @collectedInstallments.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} installments collected'**
  String collectedInstallments(int paid, int total);

  /// No description provided for @nextPayoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Your next payout'**
  String get nextPayoutLabel;

  /// No description provided for @myTurnNow.
  ///
  /// In en, this message translates to:
  /// **'Your turn now'**
  String get myTurnNow;

  /// No description provided for @showEarlierRounds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 earlier round} other{Show {count} earlier rounds}}'**
  String showEarlierRounds(int count);

  /// No description provided for @showAllRounds.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} rounds'**
  String showAllRounds(int count);

  /// No description provided for @showFewerRounds.
  ///
  /// In en, this message translates to:
  /// **'Show fewer'**
  String get showFewerRounds;

  /// No description provided for @accountCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Your account ID'**
  String get accountCodeLabel;

  /// No description provided for @accountCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Give it to an organizer to link you to their circles.'**
  String get accountCodeHint;

  /// No description provided for @accountCodeSheetBody.
  ///
  /// In en, this message translates to:
  /// **'The organizer scans this code or types the ID. You confirm the link before anything changes.'**
  String get accountCodeSheetBody;

  /// No description provided for @accountCodeShare.
  ///
  /// In en, this message translates to:
  /// **'My Daira account ID: {code}'**
  String accountCodeShare(String code);

  /// No description provided for @accountCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Type the ID as it appears in their app, e.g. DA-7K3M9Q.'**
  String get accountCodeInvalid;

  /// No description provided for @accountNameIs.
  ///
  /// In en, this message translates to:
  /// **'Their account name is «{name}»'**
  String accountNameIs(String name);

  /// No description provided for @unifyNameBody.
  ///
  /// In en, this message translates to:
  /// **'Use one name so everyone recognizes them in every circle.'**
  String get unifyNameBody;

  /// No description provided for @useAccountName.
  ///
  /// In en, this message translates to:
  /// **'Use the account name'**
  String get useAccountName;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated in every open circle'**
  String get nameUpdated;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContact;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get reject;

  /// No description provided for @autoJoin.
  ///
  /// In en, this message translates to:
  /// **'Add me directly'**
  String get autoJoin;

  /// No description provided for @autoJoinHint.
  ///
  /// In en, this message translates to:
  /// **'Organizers linked with you can add you to new circles without waiting for your approval.'**
  String get autoJoinHint;

  /// No description provided for @callsYou.
  ///
  /// In en, this message translates to:
  /// **'Calls you «{name}»'**
  String callsYou(String name);

  /// No description provided for @circlesAndLinks.
  ///
  /// In en, this message translates to:
  /// **'Contacts and links'**
  String get circlesAndLinks;

  /// No description provided for @circlesLabel.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get circlesLabel;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @contactsSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} people · {registered} registered'**
  String contactsSummary(int total, int registered);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteContactTitle(String name);

  /// No description provided for @deleteContactBody.
  ///
  /// In en, this message translates to:
  /// **'They are not in any circle. You can add them again later.'**
  String get deleteContactBody;

  /// No description provided for @fromContacts.
  ///
  /// In en, this message translates to:
  /// **'From your contacts'**
  String get fromContacts;

  /// No description provided for @inCircles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 circle} other{In {count} circles}}'**
  String inCircles(int count);

  /// No description provided for @inNoCircle.
  ///
  /// In en, this message translates to:
  /// **'Not in a circle'**
  String get inNoCircle;

  /// No description provided for @leaveLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Not you in {organizer}\'s circles?'**
  String leaveLinkTitle(String organizer);

  /// No description provided for @leaveLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Your account leaves their open circles, and this shows in each circle\'s activity.'**
  String get leaveLinkBody;

  /// No description provided for @linkAcceptedDone.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linkAcceptedDone;

  /// No description provided for @linkDeclinedDone.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get linkDeclinedDone;

  /// No description provided for @linkTitle.
  ///
  /// In en, this message translates to:
  /// **'Link {name} to an account'**
  String linkTitle(String name);

  /// No description provided for @linkBody.
  ///
  /// In en, this message translates to:
  /// **'Ask them for the account ID shown on their «Account» page. They confirm, then they join every circle you put them in.'**
  String get linkBody;

  /// No description provided for @linkByAccountCode.
  ///
  /// In en, this message translates to:
  /// **'Link by account ID'**
  String get linkByAccountCode;

  /// No description provided for @linkToAccount.
  ///
  /// In en, this message translates to:
  /// **'Link to an account'**
  String get linkToAccount;

  /// No description provided for @linkRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. {name} will be linked once they accept.'**
  String linkRequestSent(String name);

  /// No description provided for @linkPendingShort.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get linkPendingShort;

  /// No description provided for @linkPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for their approval'**
  String get linkPendingTitle;

  /// No description provided for @linkPendingBody.
  ///
  /// In en, this message translates to:
  /// **'{name} gets a request in the app.'**
  String linkPendingBody(String name);

  /// No description provided for @linkRequests.
  ///
  /// In en, this message translates to:
  /// **'Link requests'**
  String get linkRequests;

  /// No description provided for @linkedOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers linked with you'**
  String get linkedOrganizers;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @mergeAction.
  ///
  /// In en, this message translates to:
  /// **'Merge with another contact'**
  String get mergeAction;

  /// No description provided for @mergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Who else is {name}?'**
  String mergeTitle(String name);

  /// No description provided for @mergeBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the contact for the same person. Their circles come together under one name.'**
  String get mergeBody;

  /// No description provided for @mergeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge the two contacts?'**
  String get mergeConfirmTitle;

  /// No description provided for @mergeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'«{from}» joins «{into}». This cannot be undone.'**
  String mergeConfirmBody(String from, String into);

  /// No description provided for @mergedDone.
  ///
  /// In en, this message translates to:
  /// **'Contacts merged'**
  String get mergedDone;

  /// No description provided for @noContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get noContacts;

  /// No description provided for @noContactsBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone you add to a circle appears here.'**
  String get noContactsBody;

  /// No description provided for @noLinks.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get noLinks;

  /// No description provided for @noLinksBody.
  ///
  /// In en, this message translates to:
  /// **'Requests to link your account appear here.'**
  String get noLinksBody;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @notMe.
  ///
  /// In en, this message translates to:
  /// **'Not me'**
  String get notMe;

  /// No description provided for @yesItsMe.
  ///
  /// In en, this message translates to:
  /// **'Yes, it is me'**
  String get yesItsMe;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get notRegistered;

  /// No description provided for @paidOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get paidOnTime;

  /// No description provided for @paidLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get paidLate;

  /// No description provided for @renameContact.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get renameContact;

  /// No description provided for @renameContactBody.
  ///
  /// In en, this message translates to:
  /// **'The new name appears in every open circle.'**
  String get renameContactBody;

  /// No description provided for @reqCode.
  ///
  /// In en, this message translates to:
  /// **'{organizer} wants to link your account as «{name}»'**
  String reqCode(String organizer, String name);

  /// No description provided for @reqCodeHint.
  ///
  /// In en, this message translates to:
  /// **'If you accept, you join their circles where you are listed under this name.'**
  String get reqCodeHint;

  /// No description provided for @reqAdd.
  ///
  /// In en, this message translates to:
  /// **'{organizer} added you to «{circle}» as «{name}»'**
  String reqAdd(String organizer, String circle, String name);

  /// No description provided for @reqInvite.
  ///
  /// In en, this message translates to:
  /// **'{account} used the invitation for «{name}» in «{circle}»'**
  String reqInvite(String account, String name, String circle);

  /// No description provided for @scanCode.
  ///
  /// In en, this message translates to:
  /// **'Scan the code'**
  String get scanCode;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the code on their «Account» page.'**
  String get scanHint;

  /// No description provided for @scanNotDaira.
  ///
  /// In en, this message translates to:
  /// **'This is not a Daira account code.'**
  String get scanNotDaira;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchContacts;

  /// No description provided for @sendLinkRequest.
  ///
  /// In en, this message translates to:
  /// **'Send link request'**
  String get sendLinkRequest;

  /// No description provided for @sentRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests you sent'**
  String get sentRequests;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get unlink;

  /// No description provided for @unlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the link with {name}?'**
  String unlinkTitle(String name);

  /// No description provided for @unlinkBody.
  ///
  /// In en, this message translates to:
  /// **'Their account leaves your open circles; their name and record stay.'**
  String get unlinkBody;

  /// No description provided for @unlinkedDone.
  ///
  /// In en, this message translates to:
  /// **'Link removed'**
  String get unlinkedDone;

  /// No description provided for @useContact.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useContact;

  /// No description provided for @waitingForYou.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get waitingForYou;

  /// No description provided for @errorInvalidAccountCode.
  ///
  /// In en, this message translates to:
  /// **'No account has this ID. Check it and try again.'**
  String get errorInvalidAccountCode;

  /// No description provided for @errorOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'This is your own account ID.'**
  String get errorOwnAccount;

  /// No description provided for @errorAlreadyLinkedContact.
  ///
  /// In en, this message translates to:
  /// **'This contact is already linked to an account.'**
  String get errorAlreadyLinkedContact;

  /// No description provided for @errorAccountLinkedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'This account is already linked to another of your contacts. Merge the two instead.'**
  String get errorAccountLinkedElsewhere;

  /// No description provided for @errorLinkInUse.
  ///
  /// In en, this message translates to:
  /// **'They already reported payments from their account, so the link stays.'**
  String get errorLinkInUse;

  /// No description provided for @errorContactInUse.
  ///
  /// In en, this message translates to:
  /// **'This contact is in a circle and cannot be deleted.'**
  String get errorContactInUse;

  /// No description provided for @errorSameCircle.
  ///
  /// In en, this message translates to:
  /// **'Both contacts are in the same circle, so they are different people.'**
  String get errorSameCircle;

  /// No description provided for @errorDifferentAccounts.
  ///
  /// In en, this message translates to:
  /// **'Both contacts are linked to different accounts.'**
  String get errorDifferentAccounts;

  /// No description provided for @memberAccountCode.
  ///
  /// In en, this message translates to:
  /// **'Member\'s account ID'**
  String get memberAccountCode;

  /// No description provided for @recordShort.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get recordShort;

  /// No description provided for @linkPendingMemberBody.
  ///
  /// In en, this message translates to:
  /// **'A request went to the account owner. You can withdraw it, then send another ID.'**
  String get linkPendingMemberBody;

  /// No description provided for @withdrawRequest.
  ///
  /// In en, this message translates to:
  /// **'Withdraw request'**
  String get withdrawRequest;

  /// No description provided for @withdrawRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw the link request?'**
  String get withdrawRequestTitle;

  /// No description provided for @withdrawRequestBody.
  ///
  /// In en, this message translates to:
  /// **'The request for {name} will no longer be shown to the account owner.'**
  String withdrawRequestBody(String name);

  /// No description provided for @requestWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Request withdrawn'**
  String get requestWithdrawn;

  /// No description provided for @mergeKeepTitle.
  ///
  /// In en, this message translates to:
  /// **'Which name stays?'**
  String get mergeKeepTitle;

  /// No description provided for @mergeKeepBody.
  ///
  /// In en, this message translates to:
  /// **'The other name disappears from every open circle.'**
  String get mergeKeepBody;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @linkRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Link request'**
  String get linkRequestTitle;

  /// No description provided for @ntLinkDeclined.
  ///
  /// In en, this message translates to:
  /// **'{actor} did not accept being linked as «{member}»'**
  String ntLinkDeclined(String actor, String member);

  /// No description provided for @ntLinkRemoved.
  ///
  /// In en, this message translates to:
  /// **'{actor} removed the link to «{member}»'**
  String ntLinkRemoved(String actor, String member);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get filterNeedsAction;

  /// No description provided for @noPendingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for you'**
  String get noPendingNotifications;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @addMemberField.
  ///
  /// In en, this message translates to:
  /// **'Member name'**
  String get addMemberField;

  /// No description provided for @fromYourContacts.
  ///
  /// In en, this message translates to:
  /// **'Or pick from your contacts'**
  String get fromYourContacts;

  /// No description provided for @tapToSetShares.
  ///
  /// In en, this message translates to:
  /// **'Tap a name to set shares'**
  String get tapToSetShares;

  /// No description provided for @addAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one member.'**
  String get addAtLeastOne;

  /// No description provided for @sharesFor.
  ///
  /// In en, this message translates to:
  /// **'Shares of {name}'**
  String sharesFor(String name);

  /// No description provided for @sharesTitle.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get sharesTitle;

  /// No description provided for @sharesExplain.
  ///
  /// In en, this message translates to:
  /// **'Each share is one turn to receive, and one installment every round.'**
  String get sharesExplain;

  /// No description provided for @sharesMeaning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pays {amount} each round and receives once} other{Pays {amount} each round and receives {count} times}}'**
  String sharesMeaning(int count, String amount);

  /// No description provided for @renameLeavesContact.
  ///
  /// In en, this message translates to:
  /// **'A new name makes them a separate person from your contact.'**
  String get renameLeavesContact;

  /// No description provided for @pickFromCalendar.
  ///
  /// In en, this message translates to:
  /// **'Pick from the calendar'**
  String get pickFromCalendar;

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDraft;

  /// No description provided for @deleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get deleteDraftTitle;

  /// No description provided for @deleteDraftBody.
  ///
  /// In en, this message translates to:
  /// **'The plan is removed. Nothing was paid in it, and you can create a new circle any time.'**
  String get deleteDraftBody;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted'**
  String get draftDeleted;

  /// No description provided for @editShort.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editShort;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get phoneCountry;

  /// No description provided for @phoneCountrySearch.
  ///
  /// In en, this message translates to:
  /// **'Search country or calling code'**
  String get phoneCountrySearch;

  /// No description provided for @phoneSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Use your phone number and password.'**
  String get phoneSignInBody;

  /// No description provided for @phoneSignupBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm your phone to create your Daira account.'**
  String get phoneSignupBody;

  /// No description provided for @phoneEmailLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get phoneEmailLogin;

  /// No description provided for @phoneLoginInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get phoneLoginInstead;

  /// No description provided for @phoneAttachTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your account'**
  String get phoneAttachTitle;

  /// No description provided for @phoneAttachBody.
  ///
  /// In en, this message translates to:
  /// **'Add and confirm your phone. Your account and circles stay the same.'**
  String get phoneAttachBody;

  /// No description provided for @phoneChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get phoneChangeTitle;

  /// No description provided for @phoneChangeBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your new phone number and current password.'**
  String get phoneChangeBody;

  /// No description provided for @phoneRecoverBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm your account phone on WhatsApp to set a new password.'**
  String get phoneRecoverBody;

  /// No description provided for @phoneWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Confirm on WhatsApp'**
  String get phoneWhatsApp;

  /// No description provided for @phoneWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your phone'**
  String get phoneWaitingTitle;

  /// No description provided for @phoneWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Send the ready message from WhatsApp on this number, then return to Daira.'**
  String get phoneWaitingBody;

  /// No description provided for @phoneWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your WhatsApp message…'**
  String get phoneWaiting;

  /// No description provided for @phoneCheckNow.
  ///
  /// In en, this message translates to:
  /// **'I sent it — check now'**
  String get phoneCheckNow;

  /// No description provided for @phoneEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit number'**
  String get phoneEdit;

  /// No description provided for @phoneExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification expired. Start a new request.'**
  String get phoneExpired;

  /// No description provided for @phoneMismatch.
  ///
  /// In en, this message translates to:
  /// **'The message came from a different number. Send it from WhatsApp on the number shown.'**
  String get phoneMismatch;

  /// No description provided for @phoneHidden.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp did not share your phone number, so we could not confirm it. Share it if WhatsApp offers that option, then retry or contact support.'**
  String get phoneHidden;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the phone number and selected country.'**
  String get phoneInvalid;

  /// No description provided for @phoneInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone is linked to an account. Sign in or reset your password.'**
  String get phoneInUse;

  /// No description provided for @phoneNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'No account uses this phone. Check it or create an account.'**
  String get phoneNotRegistered;

  /// No description provided for @phoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp verification is unavailable. Please try later.'**
  String get phoneUnavailable;

  /// No description provided for @phoneCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Check it is installed and try again.'**
  String get phoneCannotOpen;

  /// No description provided for @phoneConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Phone confirmed'**
  String get phoneConfirmed;

  /// No description provided for @phoneFinishSignup.
  ///
  /// In en, this message translates to:
  /// **'Finish creating your account'**
  String get phoneFinishSignup;

  /// No description provided for @phoneFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone is confirmed. Complete the last step.'**
  String get phoneFinishBody;

  /// No description provided for @phoneConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get phoneConfirmPassword;

  /// No description provided for @phonePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get phonePasswordMismatch;

  /// No description provided for @phoneRestart.
  ///
  /// In en, this message translates to:
  /// **'Start a new verification'**
  String get phoneRestart;

  /// No description provided for @phoneAlreadyFinished.
  ///
  /// In en, this message translates to:
  /// **'This request is complete. You can sign in with your phone.'**
  String get phoneAlreadyFinished;

  /// No description provided for @phoneRetryFinish.
  ///
  /// In en, this message translates to:
  /// **'Retry with the same details'**
  String get phoneRetryFinish;

  /// No description provided for @phoneProofInvalid.
  ///
  /// In en, this message translates to:
  /// **'This verification request is no longer valid. Start again.'**
  String get phoneProofInvalid;

  /// No description provided for @phoneReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Review account — sample data only'**
  String get phoneReviewNotice;

  /// No description provided for @phoneLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get phoneLinkAction;

  /// No description provided for @phoneVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified phone'**
  String get phoneVerifiedLabel;

  /// No description provided for @phoneHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get phoneHelp;

  /// No description provided for @phoneEmailRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recover with email'**
  String get phoneEmailRecovery;

  /// No description provided for @phoneCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get phoneCurrentPassword;

  /// No description provided for @phoneSaved.
  ///
  /// In en, this message translates to:
  /// **'Your phone number was updated'**
  String get phoneSaved;

  /// No description provided for @phoneReviewRestricted.
  ///
  /// In en, this message translates to:
  /// **'This is a review account. Account linking, invitations and login changes are unavailable.'**
  String get phoneReviewRestricted;

  /// No description provided for @phoneStepNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get phoneStepNumber;

  /// No description provided for @phoneStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get phoneStepConfirm;

  /// No description provided for @phoneStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get phoneStepPassword;

  /// No description provided for @phoneOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp and send'**
  String get phoneOpenWhatsApp;

  /// No description provided for @phoneSendFrom.
  ///
  /// In en, this message translates to:
  /// **'Send it from WhatsApp on'**
  String get phoneSendFrom;

  /// No description provided for @phoneManualHint.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp did not open? Send this text to this number:'**
  String get phoneManualHint;

  /// No description provided for @phoneOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get phoneOr;

  /// No description provided for @phoneAddBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in to Daira now uses your phone number. Add it once — your account and circles stay the same.'**
  String get phoneAddBody;

  /// No description provided for @phoneAddHint.
  ///
  /// In en, this message translates to:
  /// **'Use the number you have on WhatsApp. You will confirm it later with one message.'**
  String get phoneAddHint;

  /// No description provided for @phoneConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm number'**
  String get phoneConfirmAction;

  /// No description provided for @phoneNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed yet'**
  String get phoneNotConfirmed;

  /// No description provided for @ntAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number: signing in now uses it.'**
  String get ntAddPhone;

  /// No description provided for @currencyLine.
  ///
  /// In en, this message translates to:
  /// **'In {currency}'**
  String currencyLine(String currency);

  /// No description provided for @currencyRare.
  ///
  /// In en, this message translates to:
  /// **'Most circles use the same currency. Change it only if this circle collects in another one.'**
  String get currencyRare;

  /// No description provided for @accountIdTab.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get accountIdTab;

  /// No description provided for @linkByPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Enter their phone number. If they are on Daira, they confirm and join every circle you put them in. If not, you can invite them on WhatsApp.'**
  String get linkByPhoneBody;

  /// No description provided for @notOnDairaTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is not on Daira yet'**
  String notOnDairaTitle(String name);

  /// No description provided for @notOnDairaBody.
  ///
  /// In en, this message translates to:
  /// **'Their number is saved. Invite them on WhatsApp; once they join with this number, you can link them in one tap.'**
  String notOnDairaBody(String name);

  /// No description provided for @inviteOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Invite on WhatsApp'**
  String get inviteOnWhatsApp;

  /// No description provided for @inviteOnWhatsAppText.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, {organizer} added you to a savings circle on Daira. Get the app and sign up with this number: {url}'**
  String inviteOnWhatsAppText(String name, String organizer, String url);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @addByPhone.
  ///
  /// In en, this message translates to:
  /// **'Add by phone number'**
  String get addByPhone;

  /// No description provided for @addByPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add by phone number'**
  String get addByPhoneTitle;

  /// No description provided for @addByPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'If they are on Daira, they get a request to join. If not, you can invite them on WhatsApp.'**
  String get addByPhoneBody;

  /// No description provided for @waRemindAction.
  ///
  /// In en, this message translates to:
  /// **'Remind on WhatsApp ({count} not on Daira)'**
  String waRemindAction(int count);

  /// No description provided for @waRemindTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind on WhatsApp'**
  String get waRemindTitle;

  /// No description provided for @waRemindBody.
  ///
  /// In en, this message translates to:
  /// **'These members are not on Daira, so the app cannot remind them. Send each one a ready message.'**
  String get waRemindBody;

  /// No description provided for @waReminderText.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, a reminder for «{circle}»: round {round} installment {amount} is due {date}. Thank you!'**
  String waReminderText(
    String name,
    String circle,
    int round,
    String amount,
    String date,
  );

  /// No description provided for @waSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get waSend;

  /// No description provided for @waSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get waSent;

  /// No description provided for @addNumber.
  ///
  /// In en, this message translates to:
  /// **'Add number'**
  String get addNumber;

  /// No description provided for @memberPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s phone number'**
  String memberPhoneTitle(String name);

  /// No description provided for @memberPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Only you see it. It is kept for WhatsApp reminders and linking later.'**
  String get memberPhoneBody;

  /// No description provided for @waSaveAndSend.
  ///
  /// In en, this message translates to:
  /// **'Save and open WhatsApp'**
  String get waSaveAndSend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
