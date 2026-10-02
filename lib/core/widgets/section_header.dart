import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      AppPadding.xs,
      AppPadding.m,
      AppPadding.xs,
      AppPadding.s,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
