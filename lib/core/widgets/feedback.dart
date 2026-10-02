import 'package:flutter/material.dart';

import '../error/failure.dart';
import '../theme/app_colors.dart';
import '../utils/failure_message.dart';
import '../utils/string_helper.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
}

/// Returns `true` when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final s = S(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(s.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows [failure] as an error snack bar, or [success] when there is none.
/// Returns `true` on success.
bool showOperationResult(
  BuildContext context,
  Failure? failure, {
  String? success,
}) {
  if (!context.mounted) return failure == null;
  if (failure != null) {
    showAppSnackBar(
      context,
      failureMessage(S(context), failure),
      isError: true,
    );
    return false;
  }
  if (success != null) showAppSnackBar(context, success);
  return true;
}
