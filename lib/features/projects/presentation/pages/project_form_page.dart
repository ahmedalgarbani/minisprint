import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../domain/entities/project.dart';

class ProjectFormPage extends StatefulWidget {
  final Project? project;
  final Future<Failure?> Function(Project project) onSubmit;

  const ProjectFormPage({super.key, this.project, required this.onSubmit});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _descriptionController;
  // Suggest a key from the name until the user types one.
  late bool _keyEdited;
  bool _saving = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _nameController = TextEditingController(text: project?.name ?? '');
    _keyController = TextEditingController(text: project?.displayKey ?? '');
    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    _keyEdited = _isEditing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? s.editProject : s.addProject)),
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
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: s.projectName),
                  onChanged: (name) {
                    if (!_keyEdited) {
                      _keyController.text = Project.deriveKey(name);
                    }
                  },
                  validator: (v) => v == null || v.trim().isEmpty
                      ? s.pleaseEnterProjectName
                      : null,
                ),
                const SizedBox(height: AppPadding.m),
                TextFormField(
                  controller: _keyController,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[\p{L}\p{N}]', unicode: true),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: s.projectKey,
                    helperText: s.projectKeyHelp,
                  ),
                  onChanged: (_) => _keyEdited = true,
                ),
                const SizedBox(height: AppPadding.m),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: '${s.description} (${s.optional})',
                    alignLabelWithHint: true,
                  ),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = S(context);
    final base = widget.project ?? const Project(name: '', description: '');
    setState(() => _saving = true);
    final failure = await widget.onSubmit(
      base.copyWith(
        name: _nameController.text,
        key: _keyController.text,
        description: _descriptionController.text,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (showOperationResult(context, failure, success: s.projectSaved)) {
      Navigator.pop(context);
    }
  }
}
