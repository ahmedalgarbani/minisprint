import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/sprint.dart';
import 'sprint_status_pill.dart';

/// App bar title that shows the current sprint and opens a picker.
class SprintSelector extends StatelessWidget {
  final Sprint? selected;
  final List<Sprint> sprints;
  final ValueChanged<Sprint> onSelected;
  final String fallbackTitle;

  const SprintSelector({
    super.key,
    required this.selected,
    required this.sprints,
    required this.onSelected,
    required this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S(context);
    final sprint = selected;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.s),
      onTap: sprints.isEmpty ? null : () => _pick(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    sprint?.name ?? fallbackTitle,
                    overflow: TextOverflow.ellipsis,
                    style: theme.appBarTheme.titleTextStyle,
                  ),
                ),
                if (sprints.isNotEmpty)
                  const Icon(Icons.expand_more_rounded, size: 20),
              ],
            ),
            if (sprint != null)
              Text(
                sprint.isActive
                    ? s.daysLeft(sprint.daysRemaining(DateTime.now()))
                    : '${s.sprintStatusLabel(sprint.status.value)} · '
                          '${formatDateRange(context, sprint.startDate, sprint.endDate)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final s = S(context);
    final groups = [
      for (final status in [
        SprintStatus.active,
        SprintStatus.planned,
        SprintStatus.completed,
      ])
        (status, sprints.where((sp) => sp.status == status).toList()),
    ];
    final picked = await showModalBottomSheet<Sprint>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final (status, items) in groups)
                if (items.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      12,
                      16,
                      4,
                    ),
                    child: Text(
                      s.sprintStatusLabel(status.value).toUpperCase(),
                      style: Theme.of(sheetContext).textTheme.labelSmall,
                    ),
                  ),
                  for (final sprint in items)
                    ListTile(
                      selected: sprint.id == selected?.id,
                      title: Text(sprint.name),
                      subtitle: Text(
                        formatDateRange(
                          context,
                          sprint.startDate,
                          sprint.endDate,
                        ),
                      ),
                      trailing: SprintStatusPill(status: sprint.status),
                      onTap: () => Navigator.pop(sheetContext, sprint),
                    ),
                ],
            ],
          ),
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }
}
