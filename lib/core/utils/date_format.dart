import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _locale(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// `Oct 2`
String formatShortDate(BuildContext context, DateTime date) =>
    DateFormat.MMMd(_locale(context)).format(date);

/// `Oct 2, 2026`
String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(_locale(context)).format(date);

/// `Oct 2 – Oct 16`
String formatDateRange(BuildContext context, DateTime start, DateTime end) =>
    '${formatShortDate(context, start)} – ${formatShortDate(context, end)}';
