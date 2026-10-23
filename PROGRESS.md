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
| 3 | Students | [x] | claude/focused-wright-p1vttv |
| 4 | Admissions + Leaving Certificate | [x] | claude/focused-wright-p1vttv |
| 5 | Attendance | [x] | claude/focused-wright-p1vttv |
| 6 | Fees | [x] | claude/focused-wright-p1vttv |
| 7 | Staff | [x] | claude/focused-wright-p1vttv |
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
- 2026-10-23 | Module 3 Students:
  - `StudentsDao` + `StudentsRepository` (interface/impl) + 3 Cubits (list, form, detail), all with status/copyWith states.
  - Students list: search by name, father name, admission no or registration no (done in SQL, safe for 1000+ students), filter by class, "Show students who left" switch, empty/loading/error states.
  - Add/Edit form with all section 5 fields: validation for required fields, phone (03xx-xxxxxxx) and CNIC; admission no is pre-filled with the next free number and must be unique; class and section dropdowns.
  - Student detail page with Info, Attendance, Fees and Results tabs. The history tabs read real records from the database (empty until those modules save data).
  - Documents: attach any file (copied to `Documents/RozatulAtfal/documents/<studentId>/`), open it, remove it.
  - Soft delete: "Mark as Left" (asks first, keeps all records) and "Make Active" to undo.
  - Students section has its own navigator, so the side menu stays visible on detail and form pages.
  - Fixed a ConfirmDialog button overflow (buttons now wrap).
  - 31 new tests (repository, 3 cubits, pages). Total 74, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 4 Admissions + Leaving Certificate:
  - Admission register page: newest first, search by name/father/number, "admitted from/to" date range, empty/loading/error states.
  - New Admission form (same fields as the student form): admission number is automatic and read-only. The number is chosen inside the same database transaction as the save, so two admissions can never get the same number. Saves the student as active with class and section.
  - School Leaving Certificate: opens from each row. Values are filled from school records (class, admission date, attended from/to, dues cleared from fee records, attendance %, last exam, next class as "promoted to") and every value can be changed. DOB shown in figures and in words. Live PDF preview with Print and Save/Share (printing package). Urdu names show correctly in the PDF (checked by rendering a sample).
  - School name and address come from `app_settings` (keys `school_name`, `school_address`); defaults are used until the Settings module adds a screen.
  - Moved student-to-domain mapping into `students/data/student_mapper.dart` (shared). `PersonalSection` got an `autoAdmissionNo` option; `AppTextField` got `readOnly` and `helper`; `Student.withAdmissionNo`; `NumberWords` util.
  - 30 new tests (repository, 3 cubits, PDF builder, page flow, number words). Total 104, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 5 Attendance:
  - `AttendanceDao` + `AttendanceRepository` (interface/impl) + 3 Cubits (mark, daily report, monthly report).
  - Mark Attendance: choose class, optional section and date (today by default, future dates not allowed). Everyone starts as Present; tap Present / Absent / Leave per student, or "All Present". Counts update live. A bar shows "Not saved yet", "You changed this day" or "Saved for this day". Saving a day again replaces it (unique per student and date, no duplicates). What is typed stays when you look at another tab.
  - Daily Report (date-wise, per class/section): counts for Total, Present, Absent, Leave, Not marked, and a status for every student.
  - Monthly Report: month switcher (no future months), class/section, present/absent/leave and % per student (percent = present days out of days marked). Click a student for a day-by-day colour grid.
  - Only active students are listed. Dashboard "Present today" now shows real numbers.
  - `AppDateField` got `clearable`. Fixed in tests: attendance buttons no longer have a fixed width.
  - 44 new tests (repository, 3 cubits, page flow). Total 130, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 6 Fees:
  - `FeesDao` + `FeesRepository` (interface/impl) + 4 Cubits (fee structure, vouchers, collect fee, receipt). Uses the existing `fee_structure` and `fee_vouchers` tables (no schema change).
  - **Fee Structure tab:** monthly, annual and admission fee per class, own Save button per class.
  - **Vouchers tab:** class/section + month (up to next month). "Generate Vouchers" makes one unpaid voucher per active student: monthly fee, optional annual fee (checkbox), admission fee automatically in the student's admission month, and previous dues. Students who already have that month (or a later one) are skipped. Totals (billed/collected/pending), All/Unpaid/Partial/Paid filter with counts, search, and Receipt button to print again.
  - **Previous dues carry forward:** unpaid balance of the newest earlier voucher is added to the new voucher. The older voucher shows "Carried forward", so money is never counted twice.
  - **Collect Fee tab:** search by name, father name or ID. Brothers and sisters (same father CNIC, or same father name + phone) show together; tick who is paying, edit misc fee, discount and "Receive now" per student (partial payment allowed, cannot pass the balance). One receipt number for all (separate voucher rows). Students with nothing due have a "Create this month's voucher" button. Fee history of the student at the bottom.
  - **Receipt (PDF, A5, print/save):** receipt no, date, registration no, student, class/section, month, monthly, annual, admission, misc, previous dues, discount, total, received now, paid so far, balance. Several students on one receipt. Urdu names work.
  - Receipt numbers are 1, 2, 3... and all steps run in one database transaction.
  - New shared `MonthSwitcher` and `MoneyField`. Dashboard "Fees collected this month" now shows real numbers.
  - 48 new tests (repository, 4 cubits, receipt PDF, page flow). Total 178, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 7 Staff:
  - `StaffDao` + `StaffRepository` (interface/impl) + 2 Cubits (list, form). Domain model is `StaffMember` (the database table class is called `Staff`).
  - List: search by name, father name, designation or phone; "Show staff who left" switch; shows designation, phone, joining date, salary, status. Empty, loading, error states.
  - Add/Edit form: name (required), father name, designation, phone and CNIC (format checked), joining date, monthly salary (digits only), address.
  - Soft delete: "Mark as Left" (asks first, keeps the record) and "Make Active". A person who left is hidden from the main list, from the teacher choice in Classes and from the dashboard staff count, but a section still shows their name as class teacher.
  - Staff added here now appear in the Classes > class teacher dropdown.
  - 17 new tests (repository including the Classes link, 2 cubits, page flows). Total 197, all pass. `flutter analyze`: no issues.

## Known Issues
- Dashboard stat cards show 0 until the Students, Attendance, Fees and Staff modules add data.
- `school_name` and `last_backup_time` settings have no screen yet (Settings and Backup modules).
- Classes page: reorder is hidden while a search is active. Teachers list stays empty until the Staff module adds staff.
- Students: Admissions (module 4) will add the automatic admission number flow and certificate; the form here only suggests the next number.
- Students: opening attached files uses the Windows default app; untested on Windows.
- Admissions: the certificate page (PDF preview, print, save) could not be run in the cloud (needs Windows plugins). Only the PDF itself was checked.
- Admissions: issuing a certificate does not mark the student as left. Use Mark as Left on the student page.
- Attendance: the per-student note column exists in the database and is kept when saving, but there is no screen to type a note yet.
- Attendance: PDF/CSV export of these reports comes with the Reports module.
- Fees: the database keeps one receipt number and one date per voucher (no separate payments table). If a voucher is paid in two parts, the second receipt replaces the first receipt number on that voucher, and the dashboard counts the whole paid amount in the month of the last payment. The old receipt can no longer be printed again. Adding a payments table would fix this; ask before changing the schema.
- Fees: the receipt screen (PDF preview, print, save) could not be run in the cloud; the PDF itself was checked.
- Fees: paid/unpaid lists and defaulters for all classes come with the Reports module; here they are per class and month.
- Staff: salary is only stored and shown. No salary slips, attendance or payroll (not in the module list).
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

### Module 3
1. Open Students: "No students yet" and Add Student button.
2. Add a student with only Admission No and Name. Then add one with every field, including Urdu in the name and father name (text should look clean, not boxes).
3. Try bad phone (123), bad CNIC (12345) and a repeated admission number: clear red messages.
4. Search by name, father name and ID. Filter by class. Switch on "Show students who left".
5. Open a student: check Info, Attendance, Fees, Results tabs (empty states for now).
6. Edit a student and save. Check the changes show on the detail page and list.
7. Attach a PDF or image, open it (Windows should open it), remove it.
8. Mark as Left: confirm dialog, student disappears from the main list, appears with "Show students who left". Make Active brings back.
9. Go to Classes: student counts match, and a class with students cannot be deleted.
10. Resize the window to check the form and detail page.

### Module 4
1. Open Admissions: "No admissions yet". Click New Admission.
2. Admission No is grey and cannot be typed. Save with an empty name: red message. Fill the name and class, click Admit Student.
3. Message "Admission done. Admission No N." shows and the student is at the top of the list. Check the student also appears in Students and counts in Classes.
4. Admit a second student: number goes up by one. Delete nothing, then check no number is repeated.
5. Use the search box and the "Admitted from / to" dates. Clear a date with the x button.
6. Click Leaving Certificate on a student. Check the form is pre-filled, the PDF preview shows on the right and changes as you type.
7. Check DOB in words (example: Five March Two Thousand Eighteen), Dues cleared Yes/No, and an Urdu name.
8. Click Print in the preview. Print to "Microsoft Print to PDF" and open the file. Also try the save/share button.
9. Check the certificate fits on one A4 page.

### Module 5
1. Open Attendance. Without classes you see "No classes yet". With classes and students, pick a class.
2. Everyone is Present (green). Tap Absent and Leave for a few students. Counts at the top change.
3. Press Save Attendance: "Attendance saved." Check the bar says "Saved for this day."
4. Change the date to yesterday: all Present again, not saved. Mark and save. Go back to today: today's marks are still there.
5. Change one student and save again on the same day. Open Daily Report: no duplicate students, correct counts.
6. Switch tabs before saving: your taps on Mark Attendance must still be there.
7. Use a class with sections: choose a section, check only that section's students show.
8. Daily Report: students never marked show "Not marked".
9. Monthly Report: check counts and %, use the arrows for another month, click a student to see the day grid.
10. Dashboard: "Present today" matches today's saved attendance.
11. Mark a student as Left (Students module): they disappear from the attendance lists.

### Module 6
1. Fees > Fee Structure: set monthly, annual and admission fee for each class and press Save. "Fee is set" shows.
2. Fees > Vouchers: pick the class and month, press Generate Vouchers. Try with and without the annual fee. Press it again: nothing new, no duplicates.
3. Generate a class without a fee set: clear message to set the fee first.
4. Collect Fee: search a student. Pay part of the fee (for example Rs 500 of 1500): status becomes Partial, receipt opens. Pay the rest: Paid.
5. Receipt: check all fields, then Print to "Microsoft Print to PDF" and Save. Also open an old receipt from the Vouchers tab and from fee history.
6. Two brothers/sisters (same father CNIC in both profiles): search one, both show. Tick both, receive: ONE receipt with both students.
7. Generate next month's vouchers while some fee is unpaid: "previous dues" is added, and the old month shows "Carried forward".
8. Try Misc fee and Discount. Try typing more than the balance in "Receive now": it stops at the balance.
9. A student with nothing due shows "Create this month's voucher".
10. Student detail > Fees tab shows the same vouchers. Dashboard "Fees collected this month" matches what you received.

### Module 7
1. Open Staff: "No staff yet". Click Add Staff.
2. Save with an empty name: red message. Try a wrong phone (123) and a wrong CNIC: clear messages.
3. Add a teacher with all fields (also one with an Urdu name). Check the row shows designation, phone, joining date and salary.
4. Search by name, designation and phone.
5. Open a person, change the salary, Save Changes. Check the list.
6. Mark as Left: a confirmation appears, the person leaves the main list. Turn on "Show staff who left": they appear as Left. Make Active brings them back.
7. Go to Classes > Add/Edit Section: the new teacher is in the class teacher list. After marking them as Left they are gone from the list but the section still shows the name.
8. Dashboard "Teachers & staff" counts only active people.

## Notes / Decisions
- Database: drift (SQLite), single local file.
- No login, no security features (client requirement).
- WhatsApp via wa.me link only.
