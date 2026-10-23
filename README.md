# Rozatul Atfal - School Management System

A simple offline Windows desktop app for a small school (Iqra Schools Foundation).
Students, admissions, attendance, fees, exams, staff, reports, WhatsApp messages and backup.
All data stays on the computer in a local SQLite database.

## First-time setup on a new computer

1. Copy `lib/core/config/google_config.example.dart` to `lib/core/config/google_config.dart`.
   The app does not compile without this file. It is in `.gitignore`, so your Google keys are never committed.
2. Google Drive backup is optional. To turn it on, fill in `clientId` and `clientSecret` in that file
   (steps are written at the top of the file). Without them the app still works and backs up to a folder on the computer.
3. `flutter pub get`, then `dart run build_runner build --delete-conflicting-outputs`, then `flutter run -d windows`.
