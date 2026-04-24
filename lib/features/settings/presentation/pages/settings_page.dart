import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_settings_model.dart';
import '../../../../core/backup/backup_datasource.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/app_bar.dart';
import '../cubit/theme_settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppAppBar(title: s.settings),
      body: BlocBuilder<ThemeSettingsCubit, ThemeSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.all(AppPadding.s),
            children: [
              _buildSectionTitle(s.appearance),
              _buildSettingsCard([
                _buildThemeModeTile(context, settings, s, theme),
                const Divider(height: 1),
                _buildLocaleTile(context, settings, s, theme),
              ]),
              const SizedBox(height: AppPadding.s),
              _buildSectionTitle(s.chooseColor),
              _buildSettingsCard([
                _buildColorTile(
                  context,
                  s.primaryColor,
                  settings.primaryColor,
                  (color) =>
                      context.read<ThemeSettingsCubit>().setPrimaryColor(color),
                ),
                const Divider(height: 1),
                _buildColorTile(
                  context,
                  s.secondaryColor,
                  settings.secondaryColor,
                  (color) => context
                      .read<ThemeSettingsCubit>()
                      .setSecondaryColor(color),
                ),
              ]),
              const SizedBox(height: AppPadding.s),
              _buildSectionTitle(s.backupRestore),
              _buildSettingsCard([
                _buildBackupTile(context, s, theme),
                const Divider(height: 1),
                _buildRestoreTile(context, s, theme),
              ]),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppPadding.s),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    ThemeSettings settings,
    S s,
    ThemeData theme,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          settings.themeMode == ThemeMode.dark
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
          color: theme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(s.darkMode),
      trailing: Switch.adaptive(
        value: settings.themeMode == ThemeMode.dark,
        activeColor: theme.primaryColor,
        onChanged: (value) => context.read<ThemeSettingsCubit>().setThemeMode(
          value ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
  }

  Widget _buildLocaleTile(
    BuildContext context,
    ThemeSettings settings,
    S s,
    ThemeData theme,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language_rounded,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
      ),
      title: Text(s.language),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: settings.locale.languageCode,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            items: [
              DropdownMenuItem(value: 'en', child: Text(s.english)),
              DropdownMenuItem(value: 'ar', child: Text(s.arabic)),
            ],
            onChanged: (value) =>
                context.read<ThemeSettingsCubit>().setLocale(Locale(value!)),
          ),
        ),
      ),
    );
  }

  Widget _buildColorTile(
    BuildContext context,
    String title,
    Color currentColor,
    ValueChanged<Color> onColorSelected,
  ) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showColorPicker(context, currentColor, onColorSelected),
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ColorPickerSheet(
        currentColor: currentColor,
        onColorSelected: (color) {
          onColorSelected(color);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildBackupTile(BuildContext context, S s, ThemeData theme) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.backup_rounded, color: Colors.blue, size: 20),
      ),
      title: Text(s.createBackup),
      subtitle: Text(s.exportData),
      onTap: () => _createBackup(context, s),
    );
  }

  Widget _buildRestoreTile(BuildContext context, S s, ThemeData theme) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.restore_rounded,
          color: Colors.orange,
          size: 20,
        ),
      ),
      title: Text(s.restoreBackup),
      subtitle: Text(s.importData),
      onTap: () => _restoreBackup(context, s),
    );
  }

  Future<void> _createBackup(BuildContext context, S s) async {
    try {
      final backupDataSource = BackupDataSource();
      final file = await backupDataSource.createBackupFile();
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.backupSaved}: ${file.path}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.backupFailed}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _restoreBackup(BuildContext context, S s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.restoreBackup),
        content: Text(s.restoreConfirm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(s.restoreBackup),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final backupDataSource = BackupDataSource();
      final filePath = await backupDataSource.pickBackupFile();
      if (filePath == null) return;
      final success = await backupDataSource.importData(filePath);
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? s.restoreSuccess : s.restoreFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.restoreFailed}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

class ColorPickerSheet extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;
  const ColorPickerSheet({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });
  static const List<Color> presetColors = [
    Color(0xFF6366F1),
    Color(0xFF4F46E5),
    Color(0xFF10B981),
    Color(0xFF0D9488),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF84CC16),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppPadding.l),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.chooseColor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.m),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppPadding.m,
              crossAxisSpacing: AppPadding.m,
            ),
            itemCount: presetColors.length,
            itemBuilder: (context, index) {
              final color = presetColors[index];
              final isSelected = color.toARGB32() == currentColor.toARGB32();
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: AppPadding.xl),
        ],
      ),
    );
  }
}
