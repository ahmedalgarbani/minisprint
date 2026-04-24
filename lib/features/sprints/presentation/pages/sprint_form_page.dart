import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minisprint/core/utils/string_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/sprint.dart';
import '../cubit/sprint_cubit.dart';
import '../cubit/sprint_state.dart';

class SprintFormPage extends StatefulWidget {
  final int projectId;
  final Sprint? sprint;

  const SprintFormPage({super.key, required this.projectId, this.sprint});

  @override
  State<SprintFormPage> createState() => _SprintFormPageState();
}

class _SprintFormPageState extends State<SprintFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _status;

  bool get isEditing => widget.sprint != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sprint?.name ?? '');
    _startDate = widget.sprint?.startDate ?? DateTime.now();
    _endDate =
        widget.sprint?.endDate ?? DateTime.now().add(const Duration(days: 14));
    _status = widget.sprint?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocListener<SprintCubit, SprintState>(
      listener: (context, state) {
        if (state is SprintOperationSuccess) {
          Navigator.pop(context);
        } else if (state is SprintError) {
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
          title: Text(isEditing ? s.editSprint : s.createSprint),
          leading: IconButton(
            icon: Icon(
              s.isAr
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_back_ios_new_rounded,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppPadding.l),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surface,
                  child: Icon(
                    Icons.speed_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.xl),
              Text(
                s.sprintDetails,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppPadding.s),
              Text(
                s.sprintGoal,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppPadding.xl),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: s.sprintName,
                  prefixIcon: const Icon(Icons.bolt_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return s.pleaseEnterSprintName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppPadding.m),
              _buildDateTile(
                title: s.startDate,
                date: _startDate,
                onTap: () => _selectDate(true),
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(height: AppPadding.m),
              _buildDateTile(
                title: s.endDate,
                date: _endDate,
                onTap: () => _selectDate(false),
                icon: Icons.event_rounded,
              ),
              const SizedBox(height: AppPadding.m),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  hintText: s.status,
                  prefixIcon: const Icon(Icons.info_outline_rounded),
                ),
                items: [
                  DropdownMenuItem(value: 'Active', child: Text(s.active)),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text(s.completed),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: AppPadding.xxl),
              ElevatedButton(
                onPressed: _saveSprint,
                child: Text(isEditing ? s.updateSprint : s.createSprint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.todo,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 14));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _saveSprint() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<SprintCubit>();
      final sprint = Sprint(
        id: widget.sprint?.id,
        projectId: widget.projectId,
        name: _nameController.text,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
      );
      if (isEditing) {
        cubit.editSprint(sprint);
      } else {
        cubit.addSprint(sprint);
      }
    }
  }
}
