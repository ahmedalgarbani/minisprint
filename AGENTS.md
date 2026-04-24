# Repository Guidelines

## Project Structure & Module Organization

MiniSprint is a Flutter app for offline project, sprint, and task management. Application code lives in `lib/`, with `lib/main.dart` as the entry point. Shared infrastructure belongs in `lib/core/`, including database, dependency injection, theme, utilities, widgets, and errors. Feature code belongs in `lib/features/{feature_name}/` and should keep the layer split: `data/`, `domain/`, and `presentation/`. Platform runners are in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`. Tests live in `test/`; static assets are in `assets/`.

## Build, Test, and Development Commands

- `flutter pub get` installs Dart and Flutter dependencies from `pubspec.yaml`.
- `flutter run` starts the app on the selected emulator, device, or desktop target.
- `flutter test` runs unit and widget tests under `test/`.
- `flutter analyze` runs the analyzer and `flutter_lints` checks.
- `dart format lib test` formats Dart sources and tests.
- `flutter build apk --release` creates an Android release APK.

## Coding Style & Naming Conventions

Follow Effective Dart and `flutter_lints` from `analysis_options.yaml`. Use two-space indentation, `lower_snake_case.dart` file names, `UpperCamelCase` classes, and `lowerCamelCase` members. Prefer `const` constructors. Keep business logic out of widgets: UI renders state, domain owns business rules, and data owns SQLite, preferences, files, and other persistence.

## Architecture & Dependencies

Use Bloc/Cubit for feature and application state. Cubits should depend on use cases, not directly on repositories or data sources. Use `get_it` and register dependencies from `lib/core/di/`. Do not add packages without a clear reason. Avoid code generation; prefer Dart 3 features such as sealed classes, pattern matching, and records.

## Testing Guidelines

Write deterministic tests with one behavior per case. Add domain and data tests for business rules, persistence behavior, and bug fixes. Use widget tests for UI behavior that depends on rendering or interaction. Name test files with `_test.dart`, for example `task_status_test.dart`, and run `flutter test` before submitting changes.

## Commit & Pull Request Guidelines

This workspace does not include Git history, so use concise, imperative commit messages such as `Add task repository tests` or `Fix sprint progress calculation`. Pull requests should include a description, test results, linked issues when applicable, and screenshots for visible UI changes. Note database, asset, signing, or platform-specific changes.

## Security & Configuration Tips

Do not hardcode secrets or credentials. Treat signing files such as `upload-keystore.jks` and Android key properties as sensitive. Avoid logging user data or persistence contents during normal app flows.
