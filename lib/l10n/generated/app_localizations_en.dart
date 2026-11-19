// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Daira';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get continueAction => 'Continue';

  @override
  String get loading => 'Loading…';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInBody => 'Sign in to follow your circles.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get requiredField => 'Fill in this field.';

  @override
  String get invalidEmail => 'Enter a valid email.';

  @override
  String get errorOffline =>
      'No connection. Check your internet and try again.';

  @override
  String get errorUnavailable =>
      'Daira is not responding right now. Try again shortly.';

  @override
  String get errorCredentials =>
      'Check your email and password. New accounts must confirm their email first.';

  @override
  String get errorSuspended =>
      'This account is suspended. Contact Daira support.';

  @override
  String get errorSessionEnded => 'Your session ended. Sign in again.';

  @override
  String get errorConflict =>
      'This changed in the meantime. We refreshed it — check and try again.';

  @override
  String get errorForbidden => 'You can\'t do this in this circle.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a little and try again.';

  @override
  String get errorInvalidInput => 'Check the highlighted information.';

  @override
  String get errorNotFound => 'This item is no longer available.';

  @override
  String get errorCircleSuspended =>
      'This circle is suspended by Daira support.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get maintenanceTitle => 'Daira is under maintenance';

  @override
  String get maintenanceBody =>
      'We\'re improving the service. Your data is safe — come back shortly.';

  @override
  String maintenanceUntil(String until) {
    return 'Expected back: $until';
  }

  @override
  String get updateRequiredTitle => 'Update Daira to continue';

  @override
  String get updateRequiredBody =>
      'This version is no longer supported. Update from the store to keep using Daira.';

  @override
  String get updateAvailableTitle => 'A new version is available';

  @override
  String updateAvailableBody(String version) {
    return 'Version $version is ready in the store.';
  }

  @override
  String updateRequiredFrom(String date) {
    return 'Required from $date';
  }

  @override
  String get updateNow => 'Update';

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get offlineBody =>
      'Daira needs the internet to keep your circles in sync.';

  @override
  String get unavailableTitle => 'Can\'t reach Daira';

  @override
  String get unavailableBody =>
      'The service didn\'t respond. Try again in a moment.';

  @override
  String get obligationPending => 'Due';

  @override
  String get obligationReported => 'Awaiting confirmation';

  @override
  String get obligationApproved => 'Confirmed';

  @override
  String get obligationOverdue => 'Overdue';

  @override
  String get actionPaid => 'I paid';

  @override
  String get actionReceived => 'Received';

  @override
  String get actionNotReceived => 'Not received';

  @override
  String get actionPayout => 'I handed it over';

  @override
  String get actionReceipt => 'I received it';

  @override
  String get circleDraft => 'Draft';

  @override
  String get circleActive => 'Active';

  @override
  String get circleSuspended => 'Suspended';

  @override
  String get circleCompleted => 'Completed';

  @override
  String get circleCancelled => 'Cancelled';

  @override
  String get roundCollecting => 'Collecting';

  @override
  String get roundReady => 'Ready to hand over';

  @override
  String get roundPayoutReported => 'Awaiting receipt';

  @override
  String get roundCompleted => 'Completed';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get emptyCirclesTitle => 'No circles yet';

  @override
  String get emptyCirclesBody =>
      'Create a circle for your group, or join one with an invitation code.';

  @override
  String get createCircle => 'Create a circle';

  @override
  String get joinWithCode => 'Join with a code';

  @override
  String roundOf(int number, int total) {
    return 'Round $number of $total';
  }

  @override
  String get tabHome => 'Home';

  @override
  String get tabCircles => 'Circles';

  @override
  String get tabNotifications => 'Notifications';

  @override
  String get tabAccount => 'Account';

  @override
  String get welcomeTitle => 'Your circles, clearly';

  @override
  String get welcomeBody =>
      'Track every installment and every turn with your group. Money moves outside Daira.';

  @override
  String get welcomePoint1 => 'Every due date in one place';

  @override
  String get welcomePoint2 => 'Payments confirmed by the organizer';

  @override
  String get welcomePoint3 => 'Everyone knows their turn';

  @override
  String get welcomeTermsPrefix => 'By continuing you agree to the ';

  @override
  String get createAccount => 'Create account';

  @override
  String get terms => 'Terms of use';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get faq => 'Questions';

  @override
  String get help => 'Help';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpBody => 'We will send a code to confirm your email.';

  @override
  String get fullName => 'Full name';

  @override
  String passwordHint(int min) {
    return 'At least $min characters.';
  }

  @override
  String get signUpTerms =>
      'By creating an account you agree to the terms of use.';

  @override
  String get haveAccountSignIn => 'I already have an account';

  @override
  String get noAccountCreate => 'New here? Create an account';

  @override
  String get confirmEmailLink => 'I have a confirmation code';

  @override
  String errorWeakPassword(int min) {
    return 'Use a password of at least $min characters.';
  }

  @override
  String get errorSignupDisabled =>
      'New accounts are paused for now. Try again later.';

  @override
  String get errorVerificationCode =>
      'The code is wrong or expired. Check the latest email or send a new code.';

  @override
  String get verifyTitle => 'Confirm your email';

  @override
  String get verifyBody =>
      'Enter the 8-digit code from the email we sent. You can also tap the link in the same email.';

  @override
  String get verificationCode => 'Confirmation code';

  @override
  String get verificationCodeHint => 'Enter the 8 digits.';

  @override
  String get confirmEmail => 'Confirm';

  @override
  String get resendCode => 'Send a new code';

  @override
  String resendIn(int seconds) {
    return 'Send again in ${seconds}s';
  }

  @override
  String get confirmationResent =>
      'If the email needs confirming, a new code is on its way.';

  @override
  String get emailConfirmed => 'Email confirmed. Sign in to continue.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotBody =>
      'Enter your email. We will send a link to choose a new password.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get resetSentBody =>
      'If an account uses this email, a reset link is on its way. Choose the new password from the link, then sign in here.';

  @override
  String get useAnotherEmail => 'Use another email';

  @override
  String hello(String name) {
    return 'Hi $name';
  }

  @override
  String get needsYou => 'Needs you';

  @override
  String get nothingNeeded => 'You are all set. Nothing needs you now.';

  @override
  String get upcomingPayments => 'Coming up';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get yourTurn => 'Your turn';

  @override
  String get turnIsNow => 'This round is yours';

  @override
  String turnInRounds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count rounds',
      one: 'Next round',
    );
    return '$_temp0';
  }

  @override
  String get actionPayTitle => 'Pay your installment';

  @override
  String get actionReceiptTitle => 'Confirm you received the payout';

  @override
  String actionConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments to confirm',
      one: '1 payment to confirm',
    );
    return '$_temp0';
  }

  @override
  String actionPayoutTitle(String name) {
    return 'Hand the amount to $name';
  }

  @override
  String get review => 'Review';

  @override
  String notReceivedReason(String reason) {
    return 'Not received: $reason';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String dueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due tomorrow',
    );
    return '$_temp0';
  }

  @override
  String daysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days late',
      one: '1 day late',
    );
    return '$_temp0';
  }

  @override
  String everyDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String get filterActive => 'Active';

  @override
  String get filterDrafts => 'Drafts';

  @override
  String get filterCompleted => 'Finished';

  @override
  String get noDrafts => 'No drafts';

  @override
  String get noCompleted => 'No finished circles yet';

  @override
  String get organizer => 'Organizer';

  @override
  String myTurnRound(int round) {
    return 'Your turn: round $round';
  }

  @override
  String get draftHint => 'Draft — finish it and start the circle.';

  @override
  String get activityLog => 'Activity';

  @override
  String get confirmPaidTitle => 'Did you pay this installment?';

  @override
  String get confirmPaidBody =>
      'Daira does not move money. This tells the organizer you paid so they can confirm it.';

  @override
  String get paidDone => 'Sent to the organizer for confirmation.';

  @override
  String approvedDone(String member) {
    return '$member\'s payment confirmed.';
  }

  @override
  String get rejectedDone => 'The member will see your reason.';

  @override
  String get confirmPayoutTitle => 'Did you hand over the amount?';

  @override
  String confirmPayoutBody(String recipient) {
    return '$recipient will be asked to confirm receiving it.';
  }

  @override
  String get payoutDone => 'Waiting for the recipient to confirm.';

  @override
  String get confirmReceiptTitle => 'Did you receive the amount?';

  @override
  String get confirmReceiptBody => 'Confirming closes this round for everyone.';

  @override
  String get receiptDone => 'Round closed. Thank you!';

  @override
  String get circleSuspendedTitle => 'This circle is paused';

  @override
  String get circleSuspendedBody =>
      'Daira support paused it. Payments resume when it is resumed.';

  @override
  String get circleCancelledTitle => 'This circle was cancelled';

  @override
  String get circleCompletedTitle =>
      'Circle completed — everyone got their turn';

  @override
  String get yourPayment => 'Your installment';

  @override
  String get yourPayout => 'Your payout';

  @override
  String payoutSentToYou(String amount) {
    return 'The organizer says $amount was handed to you.';
  }

  @override
  String get handOver => 'Hand over';

  @override
  String readyForPayoutBody(String recipient) {
    return 'Everyone paid. Hand the amount to $recipient.';
  }

  @override
  String waitingRecipient(String name) {
    return 'Waiting for $name to confirm receipt.';
  }

  @override
  String get paymentsThisRound => 'Payments this round';

  @override
  String toReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to review',
      one: '1 to review',
    );
    return '$_temp0';
  }

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get turnOrder => 'Turn order';

  @override
  String perShare(String amount) {
    return '$amount per share';
  }

  @override
  String get youOrganize => 'You organize';

  @override
  String get yourTurnNow => 'This round is yours';

  @override
  String recipientIs(String name) {
    return '$name receives this round';
  }

  @override
  String collectedOf(String collected, String total) {
    return '$collected of $total confirmed';
  }

  @override
  String get notReceivedHint =>
      'Pay again or talk to the organizer, then tap «I paid».';

  @override
  String get payHint =>
      'Pay the organizer the way you agreed, then tell them here.';

  @override
  String get waitingOrganizer => 'Waiting for the organizer to confirm.';

  @override
  String get paymentConfirmed => 'Confirmed by the organizer.';

  @override
  String youName(String name) {
    return '$name (you)';
  }

  @override
  String reportedAt(String time) {
    return 'Paid $time';
  }

  @override
  String rejectTitle(String member) {
    return 'Payment from $member did not arrive?';
  }

  @override
  String get rejectBody =>
      'Write the reason. The member will see it and can pay again.';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'e.g. no transfer received yet';

  @override
  String sharesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shares',
      one: '1 share',
    );
    return '$_temp0';
  }

  @override
  String get memberJoined => 'Joined';

  @override
  String get memberNotJoined => 'Not joined yet';

  @override
  String get invite => 'Invite';

  @override
  String get importedRound => 'Before Daira';

  @override
  String get startCircleTitle => 'Start this circle?';

  @override
  String get startCircleBody =>
      'Members, amounts and turns can no longer change after the start.';

  @override
  String get startCircle => 'Start the circle';

  @override
  String get circleStarted => 'The circle has started.';

  @override
  String get draftTitle => 'Draft';

  @override
  String get draftBody =>
      'Only you can see it. Edit it or start it when ready.';

  @override
  String get editDraft => 'Edit draft';

  @override
  String inviteTitle(String name) {
    return 'Invite $name';
  }

  @override
  String inviteBody(int hours) {
    return 'Share a single-use code. It works for $hours hours and links this member to their own account.';
  }

  @override
  String get createInvite => 'Create invitation code';

  @override
  String get inviteActive => 'An invitation is already active';

  @override
  String inviteActiveBody(String date) {
    return 'Valid until $date. For safety the code is shown only once — revoke it to create a new one.';
  }

  @override
  String get revokeAndNew => 'Revoke and create a new one';

  @override
  String get revoke => 'Revoke invitation';

  @override
  String get revokeTitle => 'Revoke this invitation?';

  @override
  String get revokeBody => 'The code will stop working right away.';

  @override
  String expiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get share => 'Share';

  @override
  String get copyCode => 'Copy code';

  @override
  String get copied => 'Copied';

  @override
  String inviteMessage(String member, String circle, String code, String link) {
    return 'Hi $member! Join \"$circle\" on Daira with this code: $code\nOr open: $link';
  }

  @override
  String get joinTitle => 'Enter your invitation code';

  @override
  String get joinBody => 'The organizer shares a 12-character code with you.';

  @override
  String get inviteCode => 'Invitation code';

  @override
  String get inviteCodeHint => 'Enter the 12 characters of the code.';

  @override
  String get inviteInvalid =>
      'This code is not valid. Ask the organizer for a new one.';

  @override
  String get inviteExpired =>
      'This code expired. Ask the organizer for a new one.';

  @override
  String get inviteAlreadyMember =>
      'You are already in this circle, or this place is taken.';

  @override
  String get featureDisabled => 'This option is turned off for now.';

  @override
  String get joinPreviewTitle => 'Join this circle?';

  @override
  String organizedBy(String name) {
    return 'Organized by $name';
  }

  @override
  String get joinAs => 'You join as';

  @override
  String yourTurnRound(int round) {
    return 'Your turn: round $round';
  }

  @override
  String get joinNote =>
      'You confirm your own payments here; the organizer confirms receiving them.';

  @override
  String get joinCircle => 'Join the circle';

  @override
  String joinedCircle(String circle) {
    return 'You joined $circle.';
  }

  @override
  String get noActivity => 'No activity yet';

  @override
  String get byDairaSupport => 'Daira support';

  @override
  String get evCircleSaved => 'Circle details saved';

  @override
  String evReport(String member, int round) {
    return '$member paid round $round';
  }

  @override
  String evApprove(String member, int round) {
    return 'Payment of $member for round $round confirmed';
  }

  @override
  String evReject(String member, int round) {
    return 'Payment of $member for round $round not received';
  }

  @override
  String evCollectionCompleted(int round) {
    return 'Round $round fully collected';
  }

  @override
  String evPayout(int round) {
    return 'Round $round amount handed over';
  }

  @override
  String evReceipt(int round) {
    return 'Round $round received and closed';
  }

  @override
  String get evCircleCompleted => 'Circle completed';

  @override
  String get evInvitationCreated => 'Invitation created';

  @override
  String get evInvitationRevoked => 'Invitation revoked';

  @override
  String get evInvitationAccepted => 'Member joined';

  @override
  String get evCircleSuspended => 'Circle paused by support';

  @override
  String get evCircleResumed => 'Circle resumed';

  @override
  String get evCircleCancelled => 'Circle cancelled';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsBody =>
      'Payments, confirmations and turns will show up here.';

  @override
  String get needsAction => 'Needs your action';

  @override
  String ntPaymentReported(String actor, int round) {
    return '$actor paid round $round — confirm it';
  }

  @override
  String ntPaymentConfirmed(String actor, int round) {
    return '$actor confirmed your payment for round $round';
  }

  @override
  String ntPaymentNotReceived(int round, String reason) {
    return 'Your payment for round $round did not arrive: $reason';
  }

  @override
  String ntReadyForPayout(int round, String member) {
    return 'Round $round is collected — hand it to $member';
  }

  @override
  String ntPayoutSent(String actor, String amount) {
    return '$actor handed you $amount — confirm receipt';
  }

  @override
  String ntPayoutReceived(String actor, int round) {
    return '$actor confirmed receiving round $round';
  }

  @override
  String ntMemberJoined(String actor) {
    return '$actor joined the circle';
  }

  @override
  String ntDueSoon(int round, String amount) {
    return 'Installment for round $round is due soon ($amount)';
  }

  @override
  String ntOverdue(int round, String amount) {
    return 'Installment for round $round is overdue ($amount)';
  }

  @override
  String get ntCircleCompleted => 'The circle is complete';

  @override
  String get ntCircleSuspended => 'The circle was paused by support';

  @override
  String get ntCircleResumed => 'The circle is active again';

  @override
  String get ntCircleCancelled => 'The circle was cancelled';

  @override
  String get ntGeneric => 'New update';

  @override
  String get security => 'Security';

  @override
  String get changePassword => 'Change password';

  @override
  String get signedInDevices => 'Signed-in devices';

  @override
  String get helpAndAbout => 'Help and about';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody => 'You can sign back in any time.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteBody =>
      'Your account will be closed and your name removed from finished circles. You cannot undo this.';

  @override
  String get deleteBlocked =>
      'You are still in an active circle. Finish it before deleting your account.';

  @override
  String get wrongPassword => 'The password is not correct.';

  @override
  String get deleteForever => 'Delete my account';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get editName => 'Your name';

  @override
  String get editNameBody => 'Shown to the members of your circles.';

  @override
  String get save => 'Save';

  @override
  String get changePasswordBody =>
      'Other devices will be signed out. This one stays signed in.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get devicesBody => 'End any session you do not recognise.';

  @override
  String get thisDevice => 'This device';

  @override
  String get endSession => 'Sign out device';

  @override
  String get endSessionTitle => 'Sign out this device?';

  @override
  String get endOthersTitle => 'Sign out all other devices?';

  @override
  String get endSessionBody => 'It will need to sign in again.';

  @override
  String get endOthers => 'Sign out all other devices';

  @override
  String get contentEmpty => 'Nothing here yet.';

  @override
  String lastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get newCircle => 'New circle';

  @override
  String stepOf(int step, int total, String title) {
    return 'Step $step of $total · $title';
  }

  @override
  String get stepBasics => 'Basics';

  @override
  String get stepMembers => 'Members';

  @override
  String get stepOrder => 'Turns';

  @override
  String get stepReview => 'Review';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get saveDraft => 'Save as draft';

  @override
  String get draftSaved => 'Draft saved.';

  @override
  String get discardTitle => 'Discard this circle?';

  @override
  String get discardBody => 'What you entered will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get startDatePast =>
      'The first due date is in the past. Choose today or later, or mark rounds already completed.';

  @override
  String get draftChanged =>
      'This draft changed on another device. Reopen it and try again.';

  @override
  String get circleName => 'Circle name';

  @override
  String get circleNameHint => 'e.g. Family circle 2026';

  @override
  String get installmentPerShare => 'Installment per share';

  @override
  String get amountInvalid => 'Enter a valid amount.';

  @override
  String get currency => 'Currency';

  @override
  String get cadence => 'Payment schedule';

  @override
  String get cadenceDays => 'Days';

  @override
  String get cadenceWeeks => 'Weeks';

  @override
  String get cadenceMonths => 'Months';

  @override
  String get firstDueDate => 'First due date';

  @override
  String get lastDueDate => 'Last due date';

  @override
  String get firstDueDateHint =>
      'Each round follows the schedule from this date.';

  @override
  String get change => 'Change';

  @override
  String get membersStepBody =>
      'Add the other members by name. They can join with an invitation later.';

  @override
  String memberNumber(int number) {
    return 'Member $number';
  }

  @override
  String get removeMember => 'Remove member';

  @override
  String get addMember => 'Add member';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String totalShares(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shares in total = $count rounds',
      one: '1 share in total',
    );
    return '$_temp0';
  }

  @override
  String payoutPerRound(String amount) {
    return 'Each round collects $amount.';
  }

  @override
  String sharesLimit(int max) {
    return 'A circle needs 2 to $max shares in total.';
  }

  @override
  String get orderBody =>
      'Drag to set who receives each round. One turn per share.';

  @override
  String get orderFixedBody =>
      'Turns follow the order members were added; you receive last.';

  @override
  String get resetOrder => 'Reset order';

  @override
  String get noImportedRounds => 'New circle (no rounds before Daira)';

  @override
  String importedRounds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds already completed',
      one: '1 round already completed',
    );
    return '$_temp0';
  }

  @override
  String get importedHint =>
      'For a circle that already started: the first rounds are marked done.';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get membersLabel => 'Members';

  @override
  String get roundsLabel => 'Rounds';

  @override
  String get importedLabel => 'Completed before Daira';

  @override
  String get eachRoundCollects => 'Each round collects';

  @override
  String get reviewNoteTitle => 'Money moves outside Daira';

  @override
  String get reviewNoteBody =>
      'Daira records who paid and who received, so everyone sees the same truth.';

  @override
  String get name => 'Name';

  @override
  String paidOf(int paid, int total) {
    return '$paid of $total paid';
  }

  @override
  String get unpaidGroup => 'Not paid yet';

  @override
  String paidGroup(int count) {
    return 'Paid ($count)';
  }

  @override
  String get recordPayment => 'Record payment';

  @override
  String get recordSeveral => 'Record several';

  @override
  String recordSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Record $count payments',
      one: 'Record 1 payment',
    );
    return '$_temp0';
  }

  @override
  String get selectWhoPaid => 'Select who paid';

  @override
  String recordTitle(String member) {
    return 'Record payment for $member';
  }

  @override
  String get recordBody =>
      'Use this when the installment reached you, in cash or any other way.';

  @override
  String get paymentMethodOptional => 'Payment method (optional)';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodTransfer => 'Transfer';

  @override
  String get methodWallet => 'Wallet';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get recordedDone => 'Payment recorded';

  @override
  String get recordedByOrganizer => 'Recorded by the organizer';

  @override
  String get reportedAndConfirmed =>
      'Reported by the member, confirmed by the organizer';

  @override
  String get paymentDetails => 'Payment details';

  @override
  String confirmedAt(String time) {
    return 'Confirmed $time';
  }

  @override
  String get undoPayment => 'Cancel this record';

  @override
  String undoPaymentTitle(String member) {
    return 'Cancel the payment of $member?';
  }

  @override
  String get undoPaymentBody =>
      'The installment goes back to not paid. This stays in the activity log.';

  @override
  String get undoneDone => 'Record cancelled';

  @override
  String get remindUnpaid => 'Remind unpaid members';

  @override
  String get remindTitle => 'Send a reminder?';

  @override
  String remindBody(int left) {
    return 'Members who use Daira and have not paid get a notification. Left this round: $left.';
  }

  @override
  String get remindAction => 'Send reminder';

  @override
  String get remindDone => 'Reminder sent';

  @override
  String remindNextAt(String time) {
    return 'Next reminder $time';
  }

  @override
  String get remindLimitReached => 'No reminders left this round';

  @override
  String get markReceived => 'Record receipt';

  @override
  String markReceivedTitle(String member) {
    return 'Did $member receive the amount?';
  }

  @override
  String markReceivedBody(String member) {
    return 'The round closes and $member is told. They can say it did not arrive.';
  }

  @override
  String get receivedDone => 'Round closed';

  @override
  String get undoPayout => 'Cancel the handover';

  @override
  String get undoPayoutTitle => 'Cancel the recorded handover?';

  @override
  String get undoPayoutBody => 'The round goes back to ready for handover.';

  @override
  String get undoPayoutDone => 'Handover cancelled';

  @override
  String reopenRound(int number) {
    return 'Reopen round $number';
  }

  @override
  String get reopenBody =>
      'Use this if the receipt was recorded by mistake. The current round waits until this one closes again.';

  @override
  String get reopenedDone => 'Round reopened';

  @override
  String receiptRecordedForYou(int number) {
    return 'The organizer recorded that you received round $number.';
  }

  @override
  String get notReceivedMine => 'I did not receive it';

  @override
  String get disputeTitle => 'You did not receive the amount?';

  @override
  String get disputeBody => 'The round reopens and the organizer is told.';

  @override
  String get disputeDone => 'The organizer was told';

  @override
  String get receivedLabel => 'Received';

  @override
  String receivedRound(int number) {
    return 'Received round $number';
  }

  @override
  String get turnNowLabel => 'Turn now';

  @override
  String accountNameLabel(String name) {
    return 'Account name: $name';
  }

  @override
  String get moreActions => 'More';

  @override
  String get installmentsTable => 'Installments table';

  @override
  String get editTurnOrder => 'Change turn order';

  @override
  String get reminderSettings => 'Reminders';

  @override
  String get muteReminders => 'Turn reminders off';

  @override
  String get unmuteReminders => 'Turn reminders on';

  @override
  String get mutedDone => 'Reminders are off for this circle';

  @override
  String get unmutedDone => 'Reminders are on';

  @override
  String get reminderSettingsBody =>
      'Automatic reminders go to registered members who have not paid.';

  @override
  String get remindBefore => 'Before the due date';

  @override
  String get remindOff => 'Off';

  @override
  String remindDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get remindOnDue => 'On the due date';

  @override
  String get remindOverdue => 'When late';

  @override
  String get reminderSaved => 'Reminders updated';

  @override
  String get tableLegend => 'Tap a box to see the details.';

  @override
  String roundColumn(int number) {
    return 'Round $number';
  }

  @override
  String get reorderBody =>
      'Any turn that has not been handed over can move. Amounts do not change.';

  @override
  String get lockedTurns => 'Already handed over';

  @override
  String get dragHint => 'Hold a name and drag it up or down';

  @override
  String get reviewChanges => 'Review changes';

  @override
  String get reorderConfirmTitle => 'Save the new order?';

  @override
  String reorderChange(String member, int from, int to) {
    return '$member: round $from → $to';
  }

  @override
  String get reorderNotice =>
      'Each member whose turn moved gets a notification.';

  @override
  String get reorderDone => 'Turn order saved';

  @override
  String get noChanges => 'Nothing changed';

  @override
  String get moveToRound => 'Move to round…';

  @override
  String get errorReminderLimit => 'No reminders available right now.';

  @override
  String get errorNobodyToRemind => 'Every registered member has paid.';

  @override
  String get errorRoundHandedOver =>
      'This round was handed over. Cancel the handover first.';

  @override
  String ntPaymentDueToday(int round, String amount) {
    return 'Installment for round $round is due today ($amount)';
  }

  @override
  String ntReminder(String actor, int round) {
    return '$actor reminds you of the round $round installment';
  }

  @override
  String ntPaymentRecorded(String actor, int round) {
    return '$actor recorded your round $round payment';
  }

  @override
  String ntPaymentUndone(String actor, int round) {
    return '$actor cancelled the record of your round $round payment';
  }

  @override
  String ntReceiptRecorded(String actor, int round) {
    return '$actor recorded that you received round $round';
  }

  @override
  String ntReceiptDisputed(String member, int round) {
    return '$member says round $round did not arrive';
  }

  @override
  String ntPayoutUndone(int round) {
    return 'The handover of round $round was cancelled';
  }

  @override
  String ntReceiptUndone(int round) {
    return 'Round $round was reopened';
  }

  @override
  String ntTurnChanged(int round) {
    return 'Your turn moved to round $round';
  }

  @override
  String ntLinkRequest(String actor, String member) {
    return '$actor wants to link your account as $member';
  }

  @override
  String ntJoinRequest(String actor, String member) {
    return '$actor used the invitation for $member. Is this the right person?';
  }

  @override
  String ntCircleInvitation(String actor) {
    return '$actor invites you to a circle';
  }

  @override
  String ntLinkAccepted(String member) {
    return '$member is now linked to the account';
  }

  @override
  String ntAddedToCircle(String actor) {
    return '$actor added you to this circle';
  }

  @override
  String evRecordPayment(String member, int round) {
    return 'Payment of $member for round $round recorded by the organizer';
  }

  @override
  String evUndoPayment(String member, int round) {
    return 'Payment record of $member for round $round cancelled';
  }

  @override
  String evUndoPayout(int round) {
    return 'Handover of round $round cancelled';
  }

  @override
  String evReceiptRecorded(int round) {
    return 'Receipt of round $round recorded by the organizer';
  }

  @override
  String evUndoReceipt(int round) {
    return 'Round $round reopened';
  }

  @override
  String evReceiptDisputed(int round) {
    return 'Recipient of round $round said it did not arrive';
  }

  @override
  String get evOrderChanged => 'Turn order changed';

  @override
  String evRemind(int round) {
    return 'Reminder sent for round $round';
  }

  @override
  String get evReminderSettings => 'Reminder settings changed';

  @override
  String evMemberLinked(String member) {
    return '$member joined with an account';
  }

  @override
  String evMemberUnlinked(String member) {
    return '$member is no longer linked to an account';
  }

  @override
  String get startedQuestion => 'The circle already started';

  @override
  String get startedHint => 'Some members received before using Daira.';

  @override
  String get nextDueDate => 'Next installment date';

  @override
  String get nextDueHint => 'Daira works out the earlier dates by itself.';

  @override
  String get markLastReceivedHint =>
      'Put members in the order they received, then tap the last one who received.';

  @override
  String get shuffleOrder => 'Random order';

  @override
  String get evCircleSavedRandom => 'Circle saved with a random turn order';

  @override
  String get installmentDue => 'Installment due';

  @override
  String get tabPayments => 'Installments';

  @override
  String get tabTurns => 'Turns';

  @override
  String selectedSummary(int count, String amount) {
    return 'Selected $count · $amount';
  }

  @override
  String roundPaymentsTitle(int number) {
    return 'Round $number installments';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get selectToRecordHint =>
      'Tap the members who paid, then record their payments in one step.';

  @override
  String roundsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds',
      one: '1 round',
    );
    return '$_temp0';
  }

  @override
  String get randomOrderChip => 'Drawn at random';

  @override
  String get yourTurnTag => 'Your turn';

  @override
  String get tableMember => 'Member';

  @override
  String get tablePaid => 'Paid';

  @override
  String get tableRecipient => 'Receives this round';

  @override
  String paidRatio(int paid, int total) {
    return '$paid of $total paid';
  }

  @override
  String moveMemberTo(String name) {
    return 'Move $name to…';
  }

  @override
  String get resetChanges => 'Undo changes';

  @override
  String get reorderHowTo =>
      'Drag a card by ⇅, or tap it to pick its new round.';

  @override
  String get movableTurns => 'Turns you can move';

  @override
  String wasRound(int number) {
    return 'Was round $number';
  }

  @override
  String get currentRoundTag => 'Current round';

  @override
  String get noChangesYet => 'No changes yet';

  @override
  String reviewChangesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Review $count changes',
      one: 'Review 1 change',
    );
    return '$_temp0';
  }

  @override
  String reorderReviewBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members get a new turn. Amounts stay the same.',
      one: 'One member gets a new turn. Amounts stay the same.',
    );
    return '$_temp0';
  }

  @override
  String get saveOrder => 'Save order';

  @override
  String get orderStepHint =>
      'Draw the order at random, or drag a card by ⇅ to arrange it yourself.';

  @override
  String get shufflingNow => 'Drawing…';

  @override
  String get receivedBeforeTitle => 'Received before Daira';

  @override
  String get receivedBeforeHint => 'The first turns in the list below.';

  @override
  String get dateToday => 'Today';

  @override
  String get dateNextWeek => 'In a week';

  @override
  String get dateNextMonthStart => '1st of next month';

  @override
  String get dateOther => 'Another date';

  @override
  String get orderRandom => 'Random draw';

  @override
  String get orderArranged => 'As arranged';
}
