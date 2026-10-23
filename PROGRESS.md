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
| 2 | Classes & Sections | [ ] | |
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

## Known Issues
- Dashboard stat cards show 0 until the Students, Attendance, Fees and Staff modules add data.
- `school_name` and `last_backup_time` settings have no screen yet (Settings and Backup modules).
- Branch is `claude/focused-wright-p1vttv` (set by the environment), not `module/base-setup`. No PR opened.

## Owner Must Test Manually (Windows)
### Module 1
1. Run `flutter run -d windows`. The app opens with the dark side menu and the Dashboard.
2. Click each menu item. Dashboard opens real page, others show "coming soon".
3. Click the 4 quick action tiles. They should open Admissions, Attendance, Fees, Reports.
4. Resize the window. Cards should re-flow (4 -> 2 -> 1 per row) without overflow.
5. Check Inter text looks clean. Urdu text fields come with the Student module.

## Notes / Decisions
- Database: drift (SQLite), single local file.
- No login, no security features (client requirement).
- WhatsApp via wa.me link only.
