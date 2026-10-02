import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/date_math.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../domain/entities/sprint.dart';

/// Create / edit a sprint: name, goal and timebox. Status changes happen
/// through the Start / Complete actions, not here.
class SprintFormPage extends StatefulWidget {
  final int projectId;
  final Sprint? sprint;
  final String suggestedName;
  final DateTime suggestedStart;
  final Future<Failure?> Function(Sprint sprint) onSubmit;

  const SprintFormPage({
    super.key,
    required this.projectId,
    this.sprint,
    required this.suggestedName,
    required this.suggestedStart,
    required this.onSubmit,
  });

  @override
  State<SprintFormPage> createState() => _SprintFormPageState();
}

class _SprintFormPageState extends State<SprintFormPage> {
  static const _presetWeeks = [1, 2, 3, 4];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _saving = false;

  bool get _isEditing => widget.sprint != null;

  /// Selected preset in weeks, or null for a custom range.
  int? get _weeks {
    final days = calendarDaysBetween(_startDate, _endDate);
    return days % 7 == 0 && _presetWeeks.contains(days ~/ 7) ? days ~/ 7 : null;
  }

  @override
  void initState() {
    super.initState();
    final sprint = widget.sprint;
    _nameController = TextEditingController(
      text: sprint?.name ?? widget.suggestedName,
    );
    _goalController = TextEditingController(text: sprint?.goal ?? '');
    _startDate = sprint?.startDate ?? addCalendarDays(widget.suggestedStart, 0);
    _endDate = sprint?.endDate ?? addCalendarDays(_startDate, 14);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? s.editSprint : s.addSprint)),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(AppPadding.m),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.sprintName),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? s.pleaseEnterSprintName
                      : null,
                ),
                const SizedBox(height: AppPadding.m),
                TextFormField(
                  controller: _goalController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: '${s.sprintGoal} (${s.optional})',
                    hintText: s.sprintGoalHint,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppPadding.l),
                Text(s.duration, style: theme.textTheme.labelMedium),
                const SizedBox(height: AppPadding.s),
                Wrap(
                  spacing: AppPadding.s,
                  runSpacing: AppPadding.s,
                  children: [
                    for (final weeks in _presetWeeks)
                      ChoiceChip(
                        label: Text(s.weeks(weeks)),
                        selected: _weeks == weeks,
                        onSelected: (_) => setState(
                          () =>
                              _endDate = addCalendarDays(_startDate, weeks * 7),
                        ),
                      ),
                    ChoiceChip(
                      label: Text(s.custom),
                      selected: _weeks == null,
                      onSelected: (_) => _pickDate(start: false),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.m),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: s.startDate,
                        value: formatDate(context, _startDate),
                        onTap: () => _pickDate(start: true),
                      ),
                    ),
                    const SizedBox(width: AppPadding.s),
                    Expanded(
                      child: _DateField(
                        label: s.endDate,
                        value: formatDate(context, _endDate),
                        onTap: () => _pickDate(start: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.xl),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? s.save : s.create),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 5),
      lastDate: DateTime(initial.year + 5),
    );
    if (date == null) return;
    setState(() {
      if (start) {
        // Keep the chosen duration when moving the start date.
        final length = calendarDaysBetween(_startDate, _endDate);
        _startDate = date;
        _endDate = addCalendarDays(date, length < 0 ? 14 : length);
      } else {
        _endDate = date.isBefore(_startDate) ? _startDate : date;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = S(context);
    final base =
        widget.sprint ??
        Sprint(
          projectId: widget.projectId,
          name: '',
          startDate: _startDate,
          endDate: _endDate,
        );
    setState(() => _saving = true);
    final failure = await widget.onSubmit(
      base.copyWith(
        name: _nameController.text,
        goal: _goalController.text,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (showOperationResult(context, failure, success: s.sprintSaved)) {
      Navigator.pop(context);
    }
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}
