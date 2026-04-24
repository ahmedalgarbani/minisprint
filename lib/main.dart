import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_settings_model.dart';
import 'core/shell/main_shell.dart';
import 'features/settings/presentation/cubit/theme_settings_cubit.dart';
import 'features/projects/presentation/cubit/project_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MiniSprintApp());
}

class MiniSprintApp extends StatelessWidget {
  const MiniSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ThemeSettingsCubit>()..loadSettings(),
      child: BlocBuilder<ThemeSettingsCubit, ThemeSettings>(
        builder: (context, settings) {
          final theme = settings.themeMode == ThemeMode.dark
              ? AppTheme.darkTheme(
                  settings.primaryColor,
                  settings.secondaryColor,
                )
              : AppTheme.lightTheme(
                  settings.primaryColor,
                  settings.secondaryColor,
                );

          return MaterialApp(
            title: 'MiniSprint',
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: settings.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: BlocProvider(
              create: (_) => getIt<ProjectCubit>()..loadProjects(),
              child: const MainShell(),
            ),
          );
        },
      ),
    );
  }
}
