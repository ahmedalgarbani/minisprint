import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_settings_model.dart';
import 'features/projects/presentation/cubit/project_cubit.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'features/settings/presentation/cubit/theme_settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MiniSprintApp());
}

class MiniSprintApp extends StatelessWidget {
  const MiniSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeSettingsCubit>()..loadSettings()),
        BlocProvider(create: (_) => getIt<ProjectCubit>()..loadProjects()),
      ],
      child: BlocBuilder<ThemeSettingsCubit, ThemeSettings>(
        buildWhen: (a, b) =>
            a.themeMode != b.themeMode ||
            a.primaryColor != b.primaryColor ||
            a.secondaryColor != b.secondaryColor ||
            a.locale != b.locale,
        builder: (context, settings) {
          return MaterialApp(
            title: 'MiniSprint',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(
              settings.primaryColor,
              settings.secondaryColor,
            ),
            darkTheme: AppTheme.darkTheme(
              settings.primaryColor,
              settings.secondaryColor,
            ),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: const ProjectsPage(),
          );
        },
      ),
    );
  }
}
