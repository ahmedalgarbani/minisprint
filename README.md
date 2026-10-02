# MiniSprint

A lightweight Agile work tracker inspired by Jira and Azure DevOps. It works
fully offline, and its data layer can be switched to a REST backend.

> **بالعربية:** MiniSprint أداة لإدارة المشاريع بأسلوب Jira / Azure DevOps:
> قائمة مهام (Backlog)، تخطيط الدورات (Sprints)، لوحة Kanban، وتقارير.
> تعمل بوضعين: **بسيط** و**متقدم**، وتدعم العربية والإنجليزية والوضع الداكن.
> البيانات محلية (SQLite) افتراضياً، ويمكن التبديل إلى خادم API دون تعديل الواجهات
> (انظر قسم «التبديل إلى الخادم» أدناه و`docs/API_CONTRACT.md`).

## Workflow

1. **Projects** – each project has a key (e.g. `MBA`) used in work item keys (`MBA-12`).
2. **Backlog** – capture work, then plan it into sprints (Jira backlog /
   Azure DevOps sprint planning). Quick-add items inline; move items between
   sprints and the backlog from the item menu.
3. **Sprints** – *Planned → Active → Completed*. One sprint is active per
   project. Completing a sprint moves unfinished items back to the backlog.
4. **Board** – Kanban board of the selected sprint. Long-press a card to drag
   it, or use its `⋯` menu. Search by title, key, assignee or tag.
5. **Reports** – sprint health (completion vs. time), status / type / priority
   breakdowns, team workload and velocity.

### Simple vs. Advanced mode (Settings → Work mode)

| | Simple | Advanced |
|---|---|---|
| Board columns | To Do / In Progress / Done | Configurable: add, hide, reorder, WIP limits |
| Work item fields | Title, description, status, priority, sprint | + type (story/task/bug), story points, assignee, tags |
| Board tools | Search | + filters, swimlanes (priority / assignee / type), sorting |
| Reports tab | – | ✓ |

Switching modes never hides work: items whose status has no column (for
example `Review` on the simple board) appear in the closest column.

## Architecture

Clean architecture per feature (`data` → `domain` → `presentation`), Cubit for
state, `get_it` for DI, no code generation.

```
lib/
  core/            config, DI, database, network, errors, theme, shared widgets
  features/
    projects/      projects + the project workspace (Board/Backlog/Reports shell)
    sprints/       sprint lifecycle, backlog & planning page
    tasks/         work items, board config, board view builder, board page
    reports/       sprint report builder and dashboard
    settings/      appearance, work mode, data source info, backup/restore
```

- Repositories depend on a `*DataSource` interface per feature, with a local
  (`*LocalDataSource`, SQLite) and a remote (`*RemoteDataSource`, REST)
  implementation. `lib/core/di/injection.dart` picks one from `AppConfig`.
- Data sources throw `AppException`s; repositories convert them to typed
  `Failure`s via `guard()`; the UI maps failures to localized messages.
- Business rules (sprint lifecycle, validation, board filtering/grouping,
  report metrics) are pure Dart in `domain/` and unit tested.

### Switching to the server

1. Implement the endpoints in [`docs/API_CONTRACT.md`](docs/API_CONTRACT.md).
2. Build with
   `--dart-define=DATA_SOURCE=remote --dart-define=API_BASE_URL=https://…`.
3. For authentication, pass an `authTokenProvider` to `HttpApiClient` in
   `core/di/injection.dart` (read the token from secure storage — never
   hardcode it).

No UI, cubit or use case changes are needed.

## Development

```sh
flutter pub get
flutter analyze
flutter test        # domain, data (real SQLite via sqflite_common_ffi), API client
flutter run
```

Database schema version 3 adds project keys, sprint goals and a product
backlog (tasks keep `project_id`; `sprint_id` is nullable). Existing v1/v2
databases and v2 JSON backups are migrated automatically.
