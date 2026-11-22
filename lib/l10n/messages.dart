import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/api/api_exception.dart';
import '../core/models/circle.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeName => AppLocalizations.of(this).localeName;
}

extension Messages on AppLocalizations {
  /// One clear sentence for any failure. Field errors are shown on the field instead.
  String error(Object error) {
    if (error is! ApiException) return errorGeneric;
    return switch (error.code) {
      'offline' => errorOffline,
      'invalid_phone' => phoneInvalid,
      'phone_in_use' => phoneInUse,
      'phone_not_registered' => phoneNotRegistered,
      'verification_unavailable' => phoneUnavailable,
      'phone_other_number' => phoneMismatch,
      'phone_hidden' => phoneHidden,
      'whatsapp_open_failed' => phoneCannotOpen,
      'invalid_phone_challenge' || 'phone_challenge_used' => phoneProofInvalid,
      'phone_completed' => phoneAlreadyFinished,
      'phone_required' => phoneAttachBody,
      'phone_already_verified' => phoneConfirmed,
      'review_restricted' => phoneReviewRestricted,
      'unavailable' => errorUnavailable,
      'invalid_credentials' => errorCredentials,
      'account_suspended' => errorSuspended,
      'session_expired' => errorSessionEnded,
      'conflict' || 'invalid_transition' => errorConflict,
      'forbidden' => errorForbidden,
      'rate_limited' => errorRateLimited,
      'invalid_input' => errorInvalidInput,
      'not_found' => errorNotFound,
      'circle_suspended' => errorCircleSuspended,
      'reminder_limit' => errorReminderLimit,
      'nobody_to_remind' => errorNobodyToRemind,
      'round_handed_over' => errorRoundHandedOver,
      'invalid_code' => errorInvalidAccountCode,
      'own_account' => errorOwnAccount,
      'member_linked' => errorAlreadyLinkedContact,
      'already_linked' => errorAccountLinkedElsewhere,
      'link_in_use' => errorLinkInUse,
      'contact_in_use' => errorContactInUse,
      'same_circle' => errorSameCircle,
      'linked_to_different_accounts' => errorDifferentAccounts,
      'maintenance' => maintenanceTitle,
      'update_required' => updateRequiredTitle,
      _ => errorGeneric,
    };
  }

  String obligation(ObligationState state, {bool overdue = false}) => switch (state) {
    ObligationState.approved => obligationApproved,
    ObligationState.reported => obligationReported,
    ObligationState.pending => overdue ? obligationOverdue : obligationPending,
  };

  String circleStatus(CircleStatus status) => switch (status) {
    CircleStatus.draft => circleDraft,
    CircleStatus.active => circleActive,
    CircleStatus.suspended => circleSuspended,
    CircleStatus.completed => circleCompleted,
    CircleStatus.cancelled => circleCancelled,
  };

  String roundState(RoundState state) => switch (state) {
    RoundState.collecting => roundCollecting,
    RoundState.readyForPayout => roundReady,
    RoundState.payoutReported => roundPayoutReported,
    RoundState.completed => roundCompleted,
  };

  /// "10 Nov 2026" in the app language.
  String date(DateTime value) => DateFormat.yMMMd(localeName).format(value.isUtc ? value.toLocal() : value);
}
