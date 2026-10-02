import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../settings/presentation/cubit/theme_settings_cubit.dart';
import '../../../sprints/presentation/pages/backlog_page.dart';
import '../../../tasks/presentation/cubit/board_cubit.dart';
import '../../../tasks/presentation/pages/board_page.dart';
import '../../domain/entities/project.dart';
import '../cubit/project_workspace_cubit.dart';
import '../cubit/project_workspace_state.dart';

enum _ProjectTab { board, backlog, reports }

/// One project: Board · Backlog · Reports (reports in advanced mode only).
/// Bottom navigation on phones, a navigation rail on wide screens.
class ProjectShellPage extends StatelessWidget {
  final Project project;

  const ProjectShellPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProjectWorkspaceCubit>()..load(project.id!),
        ),
        BlocProvider(create: (_) => getIt<BoardCubit>()..load(project.id!)),
      ],
      child: _ProjectShellView(project: project),
    );
  }
}

class _ProjectShellView extends StatefulWidget {
  final Project project;

  const _ProjectShellView({required this.project});

  @override
  State<_ProjectShellView> createState() => _ProjectShellViewState();
}

class _ProjectShellViewState extends State<_ProjectShellView> {
  _ProjectTab _tab = _ProjectTab.board;

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final advanced = context.select(
      (ThemeSettingsCubit c) => c.state.workMode.isAdvanced,
    );
    final tabs = [
      _ProjectTab.board,
      _ProjectTab.backlog,
      if (advanced) _ProjectTab.reports,
    ];
    // Reports disappear when switching to simple mode.
    final current = tabs.contains(_tab) ? _tab : _ProjectTab.board;
    final destinations = [
      for (final tab in tabs)
        switch (tab) {
          _ProjectTab.board => (
            Icons.view_kanban_outlined,
            Icons.view_kanban,
            s.board,
          ),
          _ProjectTab.backlog => (
            Icons.list_alt_outlined,
            Icons.list_alt,
            s.backlog,
          ),
          _ProjectTab.reports => (
            Icons.insights_outlined,
            Icons.insights,
            s.reports,
          ),
        },
    ];

    return BlocBuilder<ProjectWorkspaceCubit, ProjectWorkspaceState>(
      buildWhen: (a, b) => a.runtimeType != b.runtimeType,
      builder: (context, state) {
        final Widget body = switch (state) {
          WorkspaceLoading() => const LoadingView(),
          WorkspaceError(:final failure) => ErrorStateView(
            message: failureMessage(s, failure),
            onRetry: () =>
                context.read<ProjectWorkspaceCubit>().load(widget.project.id!),
          ),
          WorkspaceLoaded() => IndexedStack(
            index: tabs.indexOf(current),
            children: [
              for (final tab in tabs)
                switch (tab) {
                  _ProjectTab.board => BoardPage(
                    onOpenBacklog: () =>
                        setState(() => _tab = _ProjectTab.backlog),
                  ),
                  _ProjectTab.backlog => const BacklogPage(),
                  _ProjectTab.reports => const ReportsPage(),
                },
            ],
          ),
        };
        if (state is! WorkspaceLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.project.name)),
            body: body,
          );
        }

        final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
        void select(int index) => setState(() => _tab = tabs[index]);
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: tabs.indexOf(current),
                  onDestinationSelected: select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final (icon, selected, label) in destinations)
                      NavigationRailDestination(
                        icon: Icon(icon),
                        selectedIcon: Icon(selected),
                        label: Text(label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabs.indexOf(current),
            onDestinationSelected: select,
            destinations: [
              for (final (icon, selected, label) in destinations)
                NavigationDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(selected),
                  label: label,
                ),
            ],
          ),
        );
      },
    );
  }
}
