# CLAUDE.md — School Management System (Rozatul Atfal)

Target: Flutter Windows desktop app. Fully offline. No backend.

Read this file fully before every task. After each task, update `PROGRESS.md`.

## 1. Project Summary
A simple desktop app for a small school in Pakistan (Rozatul Atfal, Iqra Schools Foundation). It replaces paper registers.
- Works fully offline. No internet needed for daily work.
- Data is stored in a local SQLite database.
- Backup: local folder + Google Drive.
- Users are non-technical school staff. The app must be very simple and easy.
- Security is NOT a focus. No login system is required. Do not spend time on encryption or roles.

## 2. Tech Stack (do not change without asking)
- Flutter (Windows desktop), Dart
- State management: `flutter_bloc` (Cubit only, no Bloc events)
- Dependency injection: `get_it`
- Database: `drift` (SQLite) with `sqlite3_flutter_libs`, `path_provider`, `path`
- Models: `equatable`
- Google Drive backup: `googleapis`, `googleapis_auth` (desktop loopback OAuth), `url_launcher`
- WhatsApp: `url_launcher` with `https://wa.me/<number>?text=<message>` (opens WhatsApp Desktop/Web). No paid API.
- PDF/print: `pdf`, `printing`
- Other: `intl`, `file_picker`, `archive` (for backup zip)

## 3. Architecture (feature-first)
```
lib/
  core/
    di/            # get_it setup (injection.dart)
    database/      # drift database, tables, DAOs
    theme/         # app theme, colors, text styles
    widgets/       # shared widgets (AppButton, AppTextField, EmptyState, ConfirmDialog, ...)
    utils/         # date, money, validators, phone formatter
    constants/
  features/
    <feature_name>/
      data/        # repository implementation + drift DAO usage
      domain/      # models (Equatable) + repository interface
      presentation/
        cubit/     # <feature>_cubit.dart, <feature>_state.dart
        pages/
        widgets/
  main.dart
```
Features: `dashboard`, `students`, `admissions`, `attendance`, `classes`, `fees`, `staff`, `exams`, `reports`, `backup`, `settings`.

## 4. Rules
1. **All business logic lives in Cubits.** Widgets only show state and call Cubit methods. No logic in widgets, no DB calls in widgets.
2. Flow: Page -> Cubit -> Repository (interface) -> DAO/drift. Cubits depend on repository interfaces only.
3. Register everything in `get_it` (`core/di/injection.dart`). Repositories: `registerLazySingleton`. Cubits: `registerFactory`. Provide Cubits with `BlocProvider(create: (_) => getIt<...>())`.
4. State classes: use one state class per Cubit with `status` enum (`initial, loading, success, failure`), data fields, `errorMessage`, and `copyWith`. Use `Equatable`.
5. Keep files small (under ~300 lines). Split widgets.
6. Naming: files `snake_case.dart`, classes `PascalCase`. Use clear names.
7. UI text is in **simple English**. Short labels. No jargon. Support Urdu/English names in text fields (use a font that shows Urdu well, e.g. Noto Nastaliq Urdu or Noto Naskh Arabic bundled in assets).
8. UI must be simple: big buttons, clear forms, a dashboard with the daily actions (Add Student, Mark Attendance, Collect Fee, Reports), confirmation before delete, clear success/error messages.
9. Every list page needs: search, empty state, loading state, error state.
10. Money is stored as integer (PKR, no decimals). Dates stored as ISO strings or drift `DateTime`.
11. Use soft delete (`isActive` flag) for students and staff. Do not hard delete records that have history.
12. Do not add packages outside section 2 without asking. Do not add authentication, encryption, or analytics.
13. Do not leave dead code, TODO placeholders, or fake data in finished modules.

## 5. Database (drift) — main tables
- `students`: id, admissionNo (unique), registrationNo, name, fatherName, fatherCnic, dob, gender, phone, whatsappNo, address, fatherProfession, fatherEducation, previousSchool, previousClass, classId, sectionId, admissionDate, status (active/left), leavingDate, notes, createdAt
- `student_documents`: id, studentId, title, filePath
- `school_classes`: id, name, sortOrder
- `sections`: id, classId, name, classTeacherId (nullable)
- `staff`: id, name, fatherName, designation, phone, cnic, joiningDate, salary (int), address, isActive
- `attendance`: id, studentId, date, status (present/absent/leave), note. Unique (studentId, date)
- `fee_structure`: id, classId, monthlyFee, annualFee, admissionFee
- `fee_vouchers` (receipts): id, receiptNo, date, studentId, forMonth (e.g. 2026-05), monthlyFee, annualFee, admissionFee, miscFee, discount, previousDues, total, paidAmount, status (paid/partial/unpaid)
- `exams`: id, name (e.g. Annual 2026), classId, date
- `subjects`: id, classId, name, totalMarks
- `results`: id, examId, studentId, subjectId, obtainedMarks
- `app_settings`: key, value (school name, school address, phone, logo path, backup folder, last backup time, Drive settings)

Siblings: one fee receipt may cover more than one student of the same family. Support this by allowing a "family/father" lookup and collecting fees for several students in one screen (separate voucher rows, one printed receipt).

## 6. Modules (build in this order, one module per task)
1. **Base setup**: project structure, theme, get_it, drift database, shared widgets, app shell with side navigation, dashboard (placeholder cards).
2. **Classes & Sections**: CRUD classes, sections, assign class teacher.
3. **Students**: profile with all fields above, document attach, search by name/ID/father name, filter by class, student detail page with tabs (Info, Attendance, Fees, Results).
4. **Admissions**: admission form (fields like the school's Urdu admission form), auto admission number, assign class, saves student automatically. School Leaving Certificate print (PDF) with fields: admission no, name, father name, DOB (figures and words), attended from–to, dues cleared, class, exam, promoted class, date of admission, attendance, discipline.
5. **Attendance**: daily class-wise marking (default Present, tap to change), monthly report per student, date-wise report per class.
6. **Fees**: fee structure per class, monthly fee voucher generation for a class, collect fee (partial payment allowed), previous dues carry forward, fee history per student, paid/unpaid lists, printable receipt (fields: receipt no, date, registration no, student name, class/section, month, monthly fee, annual fee, admission fee, misc, total).
7. **Staff**: CRUD teachers and staff, list and search.
8. **Exams & Results**: create exam, enter marks per subject, auto total/percentage/grade/position, result card print (PDF), previous results history.
9. **Reports**: total students, class-wise students, new admissions (date range), attendance reports, fee paid/unpaid, defaulters, student history, exam results. Export to PDF (and CSV where simple).
10. **WhatsApp share**: from student detail/fee/result/attendance screens, a button "Send to Parent on WhatsApp" that opens `wa.me` with a prepared message (Pakistan numbers: convert `03xx` to `92 3xx`). No automation.
11. **Backup & Restore**: see section 7.
12. **Settings & Polish**: school info + logo, dashboard final, consistent UI, error handling, empty states, performance with 1000+ students.

## 7. Backup system
- Database file is a single SQLite file in the app documents directory.
- **Manual backup** button: copies DB (+ attached documents folder) into a `.zip` named `school_backup_YYYY-MM-DD_HH-mm.zip`.
- **Local backup**: saves zip to a folder chosen by the user in Settings.
- **Google Drive backup**: user connects Google account once (desktop OAuth loopback flow with `googleapis_auth`), app uploads the zip to a folder named "School Backups" in Drive. Handle offline gracefully (queue/skip with clear message, never crash).
- **Auto backup**: on app close (or once per day on start) create local backup; upload to Drive if internet is available.
- Keep the last 10 local backups, delete older ones.
- **Restore**: choose a backup zip (local or from Drive), confirm, replace DB, restart app.
- Show "Last backup" date on dashboard.
- Google OAuth client ID/secret must come from a config file that is NOT committed (`lib/core/config/google_config.dart` in `.gitignore`, with a `google_config.example.dart` committed).

## 8. Workflow for each task
1. Read `CLAUDE.md` and `PROGRESS.md`.
2. Work on **only the one module** given in the task. Do not touch other modules except shared code that must change.
3. Run `dart run build_runner build --delete-conflicting-outputs` when drift tables change.
4. Run `flutter analyze` — it must have **zero errors and zero warnings**.
5. Write unit tests for Cubits and repositories of the module (use in-memory drift database). Run `flutter test` — must pass.
6. Update `PROGRESS.md`: mark module status, list what was done, list known issues, list what the owner must test manually on Windows.
7. Commit with clear message: `feat(<module>): ...`. Work on branch `module/<name>` and open a PR to `main`.
8. Note: the cloud environment cannot run the Windows GUI. Do not claim UI was visually tested. The owner tests the UI locally.

## 9. Code quality
- Use `const` constructors where possible.
- Handle errors in Cubits with try/catch and emit failure state with a friendly message.
- Validate forms (required fields, phone format, CNIC format `xxxxx-xxxxxxx-x`).
- Do not hardcode strings repeated in many places; use constants.
- No print statements; use `debugPrint` only when needed.
