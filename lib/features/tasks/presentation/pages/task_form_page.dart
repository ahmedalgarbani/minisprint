import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../domain/entities/task.dart';
import '../widgets/work_item_visuals.dart';

/// Create / edit a work item. Saving goes through [onSubmit] so the page
/// does not depend on a specific cubit; it stays open if saving fails.
class TaskFormPage extends StatefulWidget {
  final Task? task;
  final int projectId;
  final String projectKey;
  final int? initialSprintId;
  final String initialStatus;
  final List<String> statuses;
  final List<Sprint> sprints;
  final bool advanced;
  final Future<Failure?> Function(Task task) onSubmit;
  final Future<Failure?> Function(Task task)? onDelete;

  const TaskFormPage({
    super.key,
    this.task,
    required this.projectId,
    required this.projectKey,
    this.initialSprintId,
    this.initialStatus = TaskStatus.todo,
    required this.statuses,
    required this.sprints,
    required this.advanced,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _assigneeController;
  late final TextEditingController _tagsController;
  late WorkItemType _type;
  late String _status;
  late String _priority;
  late int? _sprintId;
  late int? _storyPoints;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _assigneeController = TextEditingController(text: task?.assignee ?? '');
    _tagsController = TextEditingController(text: task?.tags.join(', ') ?? '');
    _type = task?.type ?? WorkItemType.task;
    _status = task?.status ?? widget.initialStatus;
    _priority = task?.priority ?? TaskPriority.medium;
    _sprintId = task == null ? widget.initialSprintId : task.sprintId;
    _storyPoints = task?.storyPoints;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final advanced = widget.advanced;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? widget.task!.keyFor(widget.projectKey) : s.addTask,
        ),
        actions: [
          if (_isEditing && widget.onDelete != null)
            IconButton(
              tooltip: s.delete,
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppPadding.m),
              children: [
                if (advanced) ...[
                  _TypeSelector(
                    value: _type,
                    onChanged: (type) => setState(() => _type = type),
                  ),
                  const SizedBox(height: AppPadding.m),
                ],
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: InputDecoration(labelText: s.taskTitle),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? s.pleaseEnterTaskTitle
                      : null,
                ),
                const SizedBox(height: AppPadding.m),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: s.description,
                    alignLabelWithHint: true,
                  ),
                ),
                SectionHeader(title: s.details),
                _statusField(s),
                const SizedBox(height: AppPadding.m),
                Text(
                  s.priority,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppPadding.xs),
                _PrioritySelector(
                  value: _priority,
                  onChanged: (p) => setState(() => _priority = p),
                ),
                if (advanced) ...[
                  const SizedBox(height: AppPadding.m),
                  TextFormField(
                    controller: _assigneeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: s.assignee,
                      hintText: s.assigneeHint,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                ],
                SectionHeader(title: s.planning),
                _sprintField(s),
                if (advanced) ...[
                  const SizedBox(height: AppPadding.m),
                  Text(
                    s.storyPoints,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppPadding.xs),
                  _StoryPointsSelector(
                    value: _storyPoints,
                    onChanged: (v) => setState(() => _storyPoints = v),
                  ),
                  const SizedBox(height: AppPadding.m),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: s.tags,
                      hintText: s.tagsHint,
                      prefixIcon: const Icon(Icons.sell_outlined),
                    ),
                  ),
                ],
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

  Widget _statusField(S s) {
    final statuses = [
      ...widget.statuses,
      if (!widget.statuses.contains(_status)) _status,
    ];
    return DropdownButtonFormField<String>(
      initialValue: _status,
      decoration: InputDecoration(labelText: s.status),
      items: [
        for (final status in statuses)
          DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: AppColors.statusColor(status),
                ),
                const SizedBox(width: AppPadding.s),
                Text(s.statusLabel(status)),
              ],
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _status = value);
      },
    );
  }

  Widget _sprintField(S s) {
    return DropdownButtonFormField<int?>(
      initialValue: _sprintId,
      decoration: InputDecoration(
        labelText: s.sprint,
        prefixIcon: const Icon(Icons.directions_run_rounded),
      ),
      items: [
        DropdownMenuItem<int?>(value: null, child: Text(s.productBacklog)),
        for (final sprint in widget.sprints)
          DropdownMenuItem<int?>(
            value: sprint.id,
            child: Text(
              '${sprint.name} · ${s.sprintStatusLabel(sprint.status.value)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Callers pass open sprints; keep a task's current sprint selectable.
        if (_sprintId != null &&
            widget.sprints.every((sp) => sp.id != _sprintId))
          DropdownMenuItem<int?>(
            value: _sprintId,
            child: Text('${s.sprint} #$_sprintId'),
          ),
      ],
      onChanged: (value) => setState(() => _sprintId = value),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = S(context);
    final base = widget.task ?? Task(projectId: widget.projectId, title: '');
    final task = base.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      status: _status,
      priority: _priority,
      type: _type,
      sprintId: _sprintId,
      clearSprint: _sprintId == null,
      storyPoints: _storyPoints,
      clearStoryPoints: _storyPoints == null,
      assignee: _assigneeController.text,
      tags: _tagsController.text.split(','),
    );
    setState(() => _saving = true);
    final failure = await widget.onSubmit(task);
    if (!mounted) return;
    setState(() => _saving = false);
    if (showOperationResult(context, failure, success: s.taskSaved)) {
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final s = S(context);
    final confirmed = await showConfirmDialog(
      context,
      title: s.deleteTask,
      message: s.deleteConfirmTask,
      confirmLabel: s.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    final failure = await widget.onDelete!(widget.task!);
    if (!mounted) return;
    setState(() => _saving = false);
    if (showOperationResult(context, failure, success: s.taskDeleted)) {
      Navigator.pop(context);
    }
  }
}

class _TypeSelector extends StatelessWidget {
  final WorkItemType value;
  final ValueChanged<WorkItemType> onChanged;

  const _TypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return SegmentedButton<WorkItemType>(
      showSelectedIcon: false,
      segments: [
        for (final type in WorkItemType.values)
          ButtonSegment(
            value: type,
            icon: WorkItemTypeIcon(type: type),
            label: Text(s.typeLabel(type.name)),
          ),
      ],
      selected: {value},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PrioritySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        for (final priority in TaskPriority.values.reversed)
          ButtonSegment(
            value: priority,
            icon: Icon(
              priorityIcon(priority),
              color: AppColors.priorityColor(priority),
            ),
            label: Text(s.priorityLabel(priority)),
          ),
      ],
      selected: {value},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _StoryPointsSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _StoryPointsSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppPadding.s,
      runSpacing: AppPadding.s,
      children: [
        ChoiceChip(
          label: const Text('–'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final points in {...storyPointScale, ?value}.toList()..sort())
          ChoiceChip(
            label: Text('$points'),
            selected: value == points,
            onSelected: (_) => onChanged(points),
          ),
      ],
    );
  }
}
