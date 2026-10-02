# MiniSprint REST API contract

The app talks to a backend through `ApiClient` (`lib/core/network/`) when it is
built with:

```sh
flutter run --dart-define=DATA_SOURCE=remote \
            --dart-define=API_BASE_URL=https://api.example.com/v1
```

Without these flags (or with an invalid URL) the app uses the local SQLite
database. Board settings (columns, filters, swimlanes) and appearance are
per-device preferences and always stay local.

## Conventions

- JSON, `snake_case` fields — the same shape as the SQLite rows.
- Responses may be bare (`[...]`, `{...}`) or wrapped (`{"data": ...}`).
- IDs are integers assigned by the server; `POST` returns the created object.
- `PUT` may return the updated object or an empty body (`204`).
- Errors: `401/403` → unauthorized, `404` → not found, other non-2xx → server
  error. Network failures and timeouts (20 s) are reported as offline.
- Auth: if the app is configured with a token provider, every request carries
  `Authorization: Bearer <token>` (see `HttpApiClient.authTokenProvider`).

## Resources

### Project
| Field | Type | Notes |
|---|---|---|
| id | int | |
| name | string | required |
| description | string | |
| key | string | e.g. `MOB`; may be empty |
| sprint_count | int | read-only |
| task_count | int | read-only |

| Method | Path |
|---|---|
| GET | `/projects` |
| GET | `/projects/{id}` |
| POST | `/projects` |
| PUT | `/projects/{id}` |
| DELETE | `/projects/{id}` — must delete its sprints and tasks |

### Sprint
| Field | Type | Notes |
|---|---|---|
| id | int | |
| project_id | int | |
| name | string | |
| goal | string | |
| start_date / end_date | ISO-8601 string | |
| status | `Planned` \| `Active` \| `Completed` | |

| Method | Path |
|---|---|
| GET | `/projects/{id}/sprints` |
| GET | `/sprints/{id}` |
| POST | `/sprints` |
| PUT | `/sprints/{id}` |
| DELETE | `/sprints/{id}` — must move its tasks to the backlog (`sprint_id = null`) |

### Task (work item)
| Field | Type | Notes |
|---|---|---|
| id | int | |
| project_id | int | |
| sprint_id | int \| null | `null` = product backlog |
| title | string | |
| description | string | |
| status | string | `To Do`, `In Progress`, `Review`, `Done`, or a custom board column |
| priority | `Low` \| `Medium` \| `High` | |
| type | `story` \| `task` \| `bug` | |
| story_points | int \| null | |
| assignee | string | |
| tags | string[] | |
| created_at | ISO-8601 string \| null | |

| Method | Path |
|---|---|
| GET | `/projects/{id}/tasks` — backlog and all sprints |
| GET | `/sprints/{id}/tasks` |
| GET | `/tasks/{id}` |
| POST | `/tasks` |
| PUT | `/tasks/{id}` |
| DELETE | `/tasks/{id}` |

Business rules (one active sprint per project, completing a sprint moves
unfinished work to the backlog, validation) live in the app's domain layer, so
the server only needs plain CRUD. It may enforce the same rules as well.

### Recommended: atomic sprint completion

Completing a sprint currently issues one `PUT /tasks/{id}` per unfinished task
and then `PUT /sprints/{id}`. A partial failure leaves some tasks moved; a
retry finishes the job. For atomicity, a backend can expose
`POST /sprints/{id}/complete` and `CompleteSprint` can call it instead.
