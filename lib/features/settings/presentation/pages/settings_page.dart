import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/preferences/work_mode.dart';
import '../../../../core/theme/theme_settings_model.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../projects/presentation/cubit/project_cubit.dart';
import '../cubit/data_settings_cubit.dart';
import '../cubit/theme_settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocProvider(
      create: (_) => getIt<DataSettingsCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(s.settings)),
        body: BlocBuilder<ThemeSettingsCubit, ThemeSettings>(
          builder: (context, settings) {
            final cubit = context.read<ThemeSettingsCubit>();
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    SectionHeader(title: s.workspace),
                    _WorkModeCard(
                      mode: settings.workMode,
                      onChanged: cubit.setWorkMode,
                    ),
                    SectionHeader(title: s.appearance),
                    Card(
                      child: Column(
                        children: [
                          _SettingRow(
                            icon: Icons.brightness_6_outlined,
                            title: s.theme,
                            child: SegmentedButton<ThemeMode>(
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  label: Text(s.themeSystem),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  label: Text(s.themeLight),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  label: Text(s.themeDark),
                                ),
                              ],
                              selected: {settings.themeMode},
                              onSelectionChanged: (v) =>
                                  cubit.setThemeMode(v.first),
                            ),
                          ),
                          const Divider(),
                          _SettingRow(
                            icon: Icons.translate_rounded,
                            title: s.language,
                            child: SegmentedButton<String>(
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: 'en',
                                  label: Text(s.english),
                                ),
                                ButtonSegment(
                                  value: 'ar',
                                  label: Text(s.arabic),
                                ),
                              ],
                              selected: {settings.locale.languageCode},
                              onSelectionChanged: (v) =>
                                  cubit.setLocale(Locale(v.first)),
                            ),
                          ),
                          const Divider(),
                          _ColorTile(
                            title: s.primaryColor,
                            color: settings.primaryColor,
                            onSelected: cubit.setPrimaryColor,
                          ),
                          const Divider(),
                          _ColorTile(
                            title: s.secondaryColor,
                            color: settings.secondaryColor,
                            onSelected: cubit.setSecondaryColor,
                          ),
                        ],
                      ),
                    ),
                    SectionHeader(title: s.data),
                    const _DataCard(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorkModeCard extends StatelessWidget {
  final WorkMode mode;
  final ValueChanged<WorkMode> onChanged;

  const _WorkModeCard({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    Widget option(WorkMode value, IconData icon, String title, String hint) {
      final selected = value == mode;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.s),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? theme.colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(AppRadius.s),
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: selected ? theme.colorScheme.primary : null,
                    ),
                    const Spacer(),
                    if (selected)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: AppPadding.s),
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(hint, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              option(
                WorkMode.simple,
                Icons.view_column_outlined,
                s.simpleMode,
                s.simpleModeHint,
              ),
              const SizedBox(width: AppPadding.s),
              option(
                WorkMode.advanced,
                Icons.dashboard_customize_outlined,
                s.advancedMode,
                s.advancedModeHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: AppPadding.s,
        spacing: AppPadding.m,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  static const presets = [
    Color(0xFF2563EB),
    Color(0xFF0052CC),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF0D9488),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
    Color(0xFF475569),
  ];

  final String title;
  final Color color;
  final ValueChanged<Color> onSelected;

  const _ColorTile({
    required this.title,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(radius: 12, backgroundColor: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () async {
        final picked = await showModalBottomSheet<Color>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final preset in presets)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(sheetContext, preset),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: preset,
                        child: preset.toARGB32() == color.toARGB32()
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        if (picked != null) onSelected(picked);
      },
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard();

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocBuilder<DataSettingsCubit, DataSettingsState>(
      builder: (context, state) {
        final local = state.source == DataSourceType.local;
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  local ? Icons.storage_rounded : Icons.cloud_outlined,
                ),
                title: Text(s.dataSource),
                subtitle: Text(
                  '${local ? s.localDatabase : s.remoteServer(state.apiBaseUrl)}\n${s.dataSourceHint}',
                ),
                isThreeLine: true,
              ),
              const Divider(),
              if (state.supportsBackup) ...[
                ListTile(
                  enabled: !state.isBusy,
                  leading: const Icon(Icons.download_outlined),
                  title: Text(s.createBackup),
                  subtitle: Text(s.exportData),
                  onTap: () => _backup(context),
                ),
                const Divider(),
                ListTile(
                  enabled: !state.isBusy,
                  leading: const Icon(Icons.upload_outlined),
                  title: Text(s.restoreBackup),
                  subtitle: Text(s.importData),
                  trailing: state.isBusy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: () => _restore(context),
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(s.backupOnlyLocal),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _backup(BuildContext context) async {
    final s = S(context);
    final result = await context.read<DataSettingsCubit>().backup();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final data):
        showAppSnackBar(context, '${s.backupSaved}: $data');
      case Error(:final failure):
        showAppSnackBar(context, failureMessage(s, failure), isError: true);
    }
  }

  Future<void> _restore(BuildContext context) async {
    final s = S(context);
    final confirmed = await showConfirmDialog(
      context,
      title: s.restoreBackup,
      message: s.restoreConfirm,
      confirmLabel: s.restoreBackup,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await context.read<DataSettingsCubit>().restore();
    if (!context.mounted) return;
    switch (result) {
      case Success(data: true):
        showAppSnackBar(context, s.restoreSuccess);
        await context.read<ProjectCubit>().loadProjects();
      case Success():
        break; // Cancelled.
      case Error(:final failure):
        showAppSnackBar(context, failureMessage(s, failure), isError: true);
    }
  }
}
