# PROGRESS.md

Claude: update this file after every task. Keep it short and accurate.

## Status Legend
- [ ] Not started
- [~] In progress
- [x] Done (code + analyze + tests pass)
- [T] Owner tested locally

## Modules
| # | Module | Status | Branch/PR |
|---|--------|--------|-----------|
| 1 | Base setup (structure, theme, DI, DB, shell, dashboard) | [x] | claude/focused-wright-p1vttv |
| 2 | Classes & Sections | [x] | claude/focused-wright-p1vttv |
| 3 | Students | [ ] | |
| 4 | Admissions + Leaving Certificate | [ ] | |
| 5 | Attendance | [ ] | |
| 6 | Fees | [ ] | |
| 7 | Staff | [ ] | |
| 8 | Exams & Results | [ ] | |
| 9 | Reports | [ ] | |
| 10 | WhatsApp share | [ ] | |
| 11 | Backup & Restore (local + Google Drive) | [ ] | |
| 12 | Settings & Polish | [ ] | |

## Current Task
None.

## Done Log
- 2026-10-23 | Module 1 Base setup:
  - Added all packages from CLAUDE.md section 2; bundled Inter + Noto Naskh Arabic (Urdu) fonts in `assets/fonts`.
  - Premium theme (indigo/violet/teal, gradients, soft shadows, rounded cards) in `core/theme`.
  - drift database with all section 5 tables (`core/database`), generated `.g.dart` is committed.
  - get_it setup (`core/di/injection.dart`), utils (date, money, phone to wa.me, validators), shared widgets (AppButton, AppTextField, AppSearchField, EmptyState, LoadingView, ErrorView, ConfirmDialog, HoverCard, PageHeader, Snack, AdaptiveGrid, FadeSlideIn).
  - App shell with gradient side navigation (all 11 sections); sections without a module show a "coming soon" page.
  - Dashboard: welcome banner with last-backup chip, 4 quick actions (Add Student, Mark Attendance, Collect Fee, Reports), 4 live stat cards from the database (students, present today, fees this month, staff).
  - 16 tests (repository with in-memory drift, cubits, utils, shell widget test). `flutter analyze`: no issues.
- 2026-10-23 | Module 2 Classes & Sections:
  - Merged latest `origin/main` first (it was already up to date).
  - `ClassesDao` (drift) + `ClassesRepository` interface/impl + `ClassesCubit` (one state with status, search, feedback messages).
  - Classes: add, edit, delete, reorder (up/down arrows). Delete is blocked if the class has sections, students (active or left), or exams/subjects/fee structure. Duplicate names are rejected (any letter case).
  - Sections: add, edit, delete under a class; optional class teacher from active staff. Delete blocked if the section has students. Same section name allowed in different classes.
  - List shows each class with section count, active student count, and per-section teacher and student count. Search by class or section name; empty, loading, error states; confirmation before delete.
  - "Coming soon" page for Classes replaced by the real page. New shared `AppFormDialog` widget.
  - 25 new tests (repository, cubit, page). Total 43, all pass. `flutter analyze`: no issues.

## Known Issues
- Dashboard stat cards show 0 until the Students, Attendance, Fees and Staff modules add data.
- `school_name` and `last_backup_time` settings have no screen yet (Settings and Backup modules).
- Classes page: reorder is hidden while a search is active. Teachers list stays empty until the Staff module adds staff.
- Branch is `claude/focused-wright-p1vttv` (set by the environment), not `module/base-setup`. No PR opened.

## Owner Must Test Manually (Windows)
### Module 1
1. Run `flutter run -d windows`. The app opens with the dark side menu and the Dashboard.
2. Click each menu item. Dashboard opens real page, others show "coming soon".
3. Click the 4 quick action tiles. They should open Admissions, Attendance, Fees, Reports.
4. Resize the window. Cards should re-flow (4 -> 2 -> 1 per row) without overflow.
5. Check Inter text looks clean. Urdu text fields come with the Student module.

### Module 2
1. Open Classes. With no data you see "No classes yet" and an Add Class button.
2. Add classes (Nursery, Class 1, Class 2). Try an empty name and a repeated name: you get a clear message.
3. Use the up/down arrows. Order should stay after you close and reopen the app.
4. Edit a class name. Delete an empty class: a confirmation appears first.
5. Add sections (A, B) to a class. Try deleting the class: it must be blocked with a message.
6. Edit a section. Class teacher list will show staff only after the Staff module is built.
7. Type in the search box: it finds by class name or section name.
8. After the Students module: a class or section with students must not be deletable, and student counts must show.

## Notes / Decisions
- Database: drift (SQLite), single local file.
- No login, no security features (client requirement).
- WhatsApp via wa.me link only.
