import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';

class TaskFormPage extends StatefulWidget {
  final int sprintId;
  final Task? task;

  const TaskFormPage({super.key, required this.sprintId, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assigneeController;
  late TextEditingController _tagsController;
  late String _status;
  late String _priority;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _assigneeController = TextEditingController(
      text: widget.task?.assignee ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.task?.tags.join(', ') ?? '',
    );
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
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
    final theme = Theme.of(context);

    return BlocListener<TaskCubit, TaskState>(
      listener: (context, state) {
        if (state is TaskOperationSuccess) {
          Navigator.pop(context);
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? s.editTask : s.addTask),
          leading: IconButton(
            icon: Icon(
              s.isAr ? Icons.arrow_back_rounded : Icons.arrow_back_ios_new_rounded,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppPadding.l),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppPadding.l),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 60,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.xl),
              Text(
                s.taskDetails,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppPadding.s),
              Text(
                s.describeWork,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppPadding.xl),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: s.taskTitle,
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return s.pleaseEnterTaskTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppPadding.m),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: s.description,
                  prefixIcon: const Icon(Icons.description_rounded),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppPadding.m),
              _buildDropdownLayout(
                label: s.status,
                icon: Icons.info_outline_rounded,
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(border: InputBorder.none, filled: false),
                  items: [
                    const DropdownMenuItem(value: TaskStatus.backlog, child: Text('Backlog')),
                    DropdownMenuItem(value: TaskStatus.todo, child: Text(s.toDo)),
                    DropdownMenuItem(value: TaskStatus.inProgress, child: Text(s.inProgress)),
                    const DropdownMenuItem(value: TaskStatus.review, child: Text('Review')),
                    DropdownMenuItem(value: TaskStatus.done, child: Text(s.done)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ),
              const SizedBox(height: AppPadding.m),
              TextFormField(
                controller: _assigneeController,
                decoration: const InputDecoration(
                  hintText: 'Assignee',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppPadding.m),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: 'Tags (design, api)',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: AppPadding.m),
              _buildDropdownLayout(
                label: s.priority,
                icon: Icons.flag_rounded,
                child: DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(border: InputBorder.none, filled: false),
                  items: [
                    DropdownMenuItem(value: TaskPriority.low, child: Text(s.low)),
                    DropdownMenuItem(value: TaskPriority.medium, child: Text(s.medium)),
                    DropdownMenuItem(value: TaskPriority.high, child: Text(s.high)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
              ),
              const SizedBox(height: AppPadding.xxl),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(isEditing ? s.save : s.addTask),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownLayout({required String label, required IconData icon, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.m),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: AppPadding.m),
          Expanded(child: child),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<TaskCubit>();
      final task = Task(
        id: widget.task?.id,
        sprintId: widget.sprintId,
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        assignee: _assigneeController.text.trim(),
        tags: _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
      );
      if (isEditing) {
        cubit.editTask(task);
      } else {
        cubit.addTask(task);
      }
    }
  }
}
