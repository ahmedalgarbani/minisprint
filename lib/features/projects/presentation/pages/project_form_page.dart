import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/project.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';

class ProjectFormPage extends StatefulWidget {
  final Project? project;

  const ProjectFormPage({super.key, this.project});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  bool get isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);

    return BlocListener<ProjectCubit, ProjectState>(
      listener: (context, state) {
        if (state is ProjectOperationSuccess) {
          Navigator.pop(context);
        } else if (state is ProjectError) {
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
          title: Text(isEditing ? s.edit : s.addProject),
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
                child: Hero(
                  tag: 'project_icon',
                  child: Container(
                    padding: const EdgeInsets.all(AppPadding.l),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      size: 60,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.xl),
              Text(
                s.projectDetails,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppPadding.s),
              Text(
                s.fillInfo,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppPadding.xl),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: s.projectName,
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return s.isAr
                        ? 'يرجى إدخال اسم المشروع'
                        : 'Please enter a project name';
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
              const SizedBox(height: AppPadding.xxl),
              ElevatedButton(
                onPressed: _saveProject,
                child: Text(isEditing ? s.save : s.addProject),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<ProjectCubit>();
      if (isEditing) {
        cubit.editProject(
          widget.project!.copyWith(
            name: _nameController.text,
            description: _descriptionController.text,
          ),
        );
      } else {
        cubit.addProject(_nameController.text, _descriptionController.text);
      }
    }
  }
}
