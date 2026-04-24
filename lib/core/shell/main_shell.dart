import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';
import '../../features/projects/presentation/cubit/project_state.dart';
import '../../features/sprints/presentation/cubit/sprint_cubit.dart';
import '../../features/sprints/presentation/cubit/sprint_state.dart';
import '../../features/sprints/presentation/pages/sprint_list_page.dart';
import '../../features/sprints/domain/repositories/sprint_repository.dart';
import '../../features/tasks/presentation/pages/kanban_board_page.dart';
import '../../features/tasks/presentation/cubit/task_cubit.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../core/utils/result.dart';
import '../di/injection.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  Project? _selectedProject;
  int? _selectedSprintId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(context),
          _buildSprints(context),
          _buildTasks(context),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          indicatorColor: theme.primaryColor.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.rocket_outlined),
              selectedIcon: Icon(Icons.rocket_rounded),
              label: 'Sprints',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_outlined),
              selectedIcon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        return DashboardPage(
          onProjectSelected: (projectId) {
            if (state is ProjectsLoaded) {
              final project = state.projects.firstWhere(
                (p) => p.id == projectId,
              );
              setState(() {
                _selectedProject = project;
                _selectedSprintId = null;
                _currentIndex = 1;
              });
            }
          },
        );
      },
    );
  }

  Widget _buildSprints(BuildContext context) {
    if (_selectedProject == null) {
      return _buildNoProjectSelected(context);
    }

    return BlocProvider(
      create: (_) => getIt<SprintCubit>()..loadSprints(_selectedProject!.id!),
      child: BlocBuilder<SprintCubit, SprintState>(
        builder: (context, state) {
          if (state is SprintsLoaded) {
            return SprintListPage(
              project: _selectedProject!,
              onSprintSelected: (sprintId) {
                setState(() {
                  _selectedSprintId = sprintId;
                  _currentIndex = 2;
                });
              },
            );
          }
          return Scaffold(
            appBar: AppBar(title: Text(_selectedProject!.name)),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildTasks(BuildContext context) {
    if (_selectedSprintId == null) {
      return _buildNoSprintSelected(context);
    }

    final sprintRepo = getIt<SprintRepository>();
    return FutureBuilder(
      future: sprintRepo.getSprintById(_selectedSprintId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data;
        if (result == null || result.isError || result.dataOrNull == null) {
          return _buildNoSprintSelected(context);
        }

        final sprint = result.dataOrNull!;

        return BlocProvider(
          create: (_) => getIt<TaskCubit>()..loadTasks(_selectedSprintId!),
          child: KanbanBoardPage(sprint: sprint),
        );
      },
    );
  }

  Widget _buildNoProjectSelected(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sprints')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a project first',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentIndex = 0),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSprintSelected(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a sprint first',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentIndex = 1),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go to Sprints'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
