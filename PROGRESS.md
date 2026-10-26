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
| 8 | Exams & Results | [x] | claude/focused-wright-p1vttv |
| 9 | Reports | [x] | claude/focused-wright-p1vttv |
| 10 | WhatsApp share | [x] | claude/focused-wright-p1vttv |
| 11 | Backup & Restore (local + Google Drive) | [x] | claude/focused-wright-p1vttv |
| 12 | Settings & Polish | [x] | claude/focused-wright-p1vttv |

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
  - School Leaving Certificate: opens from each row. Values are filled from school records (class, admission date, attended from/to, dues cleared from fee records, attendance %, last exam, next class as "promoted to") and every value can be changed. DOB shown in figures and in words. Live PDF preview with Print and Save/Share (printing package). (Earlier note said Urdu names were correct in this PDF. That was wrong: they came out disconnected and backwards. Fixed, see "Urdu in PDFs".)
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
  - **Receipt (PDF, A5, print/save):** receipt no, date, registration no, student, class/section, month, monthly, annual, admission, misc, previous dues, discount, total, received now, paid so far, balance. Several students on one receipt. (Urdu names were wrong here until the "Urdu in PDFs" fix.)
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
- 2026-10-23 | Module 8 Exams & Results:
  - `ExamsDao` + `ExamsRepository` (interface/impl) + 4 Cubits (exams, subjects, marks, result card). Pure `ResultCalculator` and `GradeScale` hold the rules and are unit tested.
  - **Exams tab:** create, edit, delete exams (name, class, date), filter by class, search. An exam that has marks cannot be deleted; its class cannot change after marks.
  - **Subjects tab:** subjects and total marks per class (add, edit, delete). A subject with marks cannot be deleted, and its total cannot go below a mark already given.
  - **Enter Marks:** one grid per exam: students down, subjects across. Total, % and grade update while typing. A mark above the subject total turns red and blocks Save. Empty box = no mark. Everything is saved in one step, or nothing if one mark is wrong.
  - **Results tab:** students ordered by position (1st, 2nd, 3rd get gold/silver/bronze badges) with total, %, grade and Pass / Fail / Incomplete.
  - **Rules (default):** grade A+ 80+, A 70+, B 60+, C 50+, D 40+, E 33+, F below 33. Pass = total at least 33% AND every subject at least 33%. Absent / empty subject counts as 0 in the total, and the student is shown as Incomplete (no position) until every subject has marks. Equal totals share a position (1, 1, 3).
  - **Result card (PDF, A4):** school, exam, student, class/section, subject table with grades, total, percentage, grade, position ("1st of 24"), result, signature lines. Print one card, or all cards of the class in one PDF. (Urdu names were wrong here until the "Urdu in PDFs" fix.) A "Previous results" list shows the student's other exams.
  - Marks are stored in the existing `results` table (no schema change). Student detail > Results tab shows them too.
  - 51 new tests (calculator, repository, 4 cubits, PDF, page flow). Total 248, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 9 Reports:
  - Reports hub with 7 report cards. Every report is built as a `ReportDocument` (title, numbers, tables) by `ReportsRepository`, which uses the other modules' repositories (no new tables). One `ReportsCubit` per report holds the choices.
  - **Students:** total, boys, girls; class-wise and section-wise tables with totals.
  - **New Admissions:** between two dates (starts with this month), includes students who later left.
  - **Attendance:** class/section and month: present, absent, leave, days marked and % per student, with average.
  - **Fee Paid / Unpaid:** any month, all classes or one class, All/Paid/Partial/Unpaid choice, totals (billed, collected, pending).
  - **Fee Defaulters:** active students who still owe fee, biggest balance first, months pending, class filter. New `FeesRepository.getDefaulters`.
  - **Exam Results:** pick an exam: class result sheet with every subject's marks, total, %, grade, position and result.
  - **Student History:** pick a student: profile numbers, attendance by month, fee history, exam results.
  - Search box filters the rows of any list report (on screen and in the exported file).
  - **Export:** "PDF / Print" opens a PDF preview (print or save; wide reports print sideways, several pages with page numbers, school name in the header). "Save as CSV" opens a Save dialog; the file opens in Excel with Urdu names and money as plain numbers.
  - 42 new tests (CSV, search filter, all 7 reports with a real database, cubit, PDF, page flows, defaulters). Total 290, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 10 WhatsApp share:
  - `WhatsAppService` (core): finds the parent's number from the student record (WhatsApp number first, then phone), converts `03xx` to `92 3xx` (existing `PhoneUtils`), and opens `https://wa.me/92...?text=...` with `url_launcher` (external app / browser). Nothing is sent automatically: the user checks the message and presses Send in WhatsApp.
  - The message always starts with "Assalam o Alaikum," and ends with the school name (from Settings, default Rozatul Atfal). Message texts are in one place (`WhatsAppMessages`), simple English.
  - Clear messages when WhatsApp opened, when no valid number is saved ("Add it in the student profile"), or when WhatsApp cannot be opened.
  - Buttons: **Student page** (WhatsApp button in the header: attendance % and fee due), **Fees > Vouchers** (green chat icon on every voucher with a balance: fee reminder), **Receipt page** ("Send to Parent on WhatsApp": receipt no, amount, balance; sisters on one receipt go to the first student's parent), **Result card page** (marks, grade, position, result), **Attendance** (green chat icon next to an Absent student on Mark Attendance and on Daily Report; "Send to Parent on WhatsApp" in the monthly student dialog with present/absent/leave/%).
  - 6 cubits got a WhatsApp action (constructor takes the service); DI registers it. Existing tests updated; shared `FakeWhatsAppService` for tests.
  - 32 new tests (service with fake launcher, all message texts, 6 cubit actions, receipt cubit, 3 page flows). Total 322, all pass. `flutter analyze`: no issues.
- 2026-10-23 | Module 11 Backup & Restore:
  - **Back Up Now:** one zip `school_backup_YYYY-MM-DD_HH-mm.zip` with the database (copied safely with `VACUUM INTO`, even while the app runs), the attached documents folder and an info file. Written under a temporary name first, so a half-written file never looks like a backup.
  - **Backup folder:** chosen on the Backup page (default: `Documents/RozatulAtfal/Backups`); the folder is tested for writing before it is saved. Only the newest 10 `school_backup_*.zip` files are kept.
  - **Google Drive:** connect once (browser opens, user presses Allow; loopback OAuth with `googleapis_auth`, permission `drive.file` only). Backups go to the Drive folder "School Backups". The login is saved in `app_settings` and refreshed automatically. Disconnect any time (nothing is deleted on Drive).
  - **Offline:** if Drive cannot be reached the local backup is still made, the page shows a clear message, and the upload is queued ("Waiting to upload"). The queued upload is sent on the next app start when the internet is back. Nothing crashes.
  - **Automatic backup:** each time the app starts, if there is no backup yet today, one is made in the background (and uploaded to Drive when connected). Failures are ignored so the app always opens.
  - **Restore:** from a backup on this computer or from Drive. Confirmation first; a safety copy `school_before_restore_*.zip` of the current data is saved; the zip is checked (valid zip, SQLite database, not from a newer app version); database and documents are replaced; attached-document paths from another computer are fixed; then the app restarts (button "Restart App").
  - Dashboard "Last backup" now shows real values.
  - Google keys: `lib/core/config/google_config.dart` is in `.gitignore`; `google_config.example.dart` is committed with the setup steps. README explains the one-time copy.
  - New shared `AppPaths` (database file, documents, backup folder), `AppRestarter`, `FileSize`.
  - 62 new tests (zip contents, real restore round trip, prune, path fix, bad files, daily auto backup, offline queue, Drive fakes, cubit, page flows, file size). Total 384, all pass. `flutter analyze`: no issues.

- 2026-10-23 | Module 12 Settings & Polish:
  - **Settings page:** school name (required), address, phone, and logo (PNG/JPG up to 5 MB, checked by file content, old logo file removed). Shows data folder with "Open Folder", app version, and a "Go to Backup" button.
  - **Logo and name everywhere:** sidebar brand, and the headers of the receipt, result card, leaving certificate and report PDFs (with school phone). A missing logo file falls back to the default icon.
  - **Dashboard final:** six clickable cards (students, present, absent, fee collected, pending fees, defaulters), quick actions, and a "Last backup" chip that opens Backup and turns gold when the backup is missing or 7+ days old.
  - **Polish:** the "coming soon" page is removed (every menu item has a real page). In release builds an unexpected screen error shows a friendly message and is logged, instead of the red error screen. Windows window title, size and file info set to the school.
  - **Code:** `SettingsStore` moved to `core/database`. The reports repository (497 lines) was split into people, class and fee report files; behaviour unchanged.
  - **Performance:** tested with 1,500 students, 30,000 attendance rows, 7,500 vouchers, 9,000 marks. All main queries under about 170 ms (in-memory DB). No indexes were needed.
  - 38 new tests. Total 422, all pass. `flutter analyze`: no issues.

- 2026-10-23 | Fee payments table (follow-up to Module 6):
  - New table `fee_payments` (id, voucherId, receiptNo, date, amount, note). Every payment has its own row and receipt number; brothers and sisters paying together share one receipt number (one row per child).
  - **Migration (database version 1 -> 2):** money already taken on a voucher becomes one payment with that voucher's receipt number and date. The old `receipt_no` on vouchers is cleared (column kept, unused). Totals, paid amounts and status are not changed. Receipt numbers keep counting up from the biggest existing one.
  - **Collect fee:** adds a payment row and updates the voucher; a second payment on the same voucher gets a new receipt number and no longer replaces the first. If anything is refused nothing is saved and no number is used.
  - **Reprint any receipt:** an old receipt shows its own date, the amount received on that day, and the paid/balance as they were after that payment.
  - **Fee history and vouchers list:** a voucher with one payment shows one "Receipt N" button; with more it shows "N receipts" with a menu (receipt number, date, amount).
  - **Reports and student page:** student history report and the student Fees tab list every receipt number ("4, 8") and the date of the last payment. Dashboard "Fees collected this month" now adds up the payments taken in that month (before, it used the voucher's last payment date).
  - **Backup/restore:** needs no change (the table is inside the database file). A backup made before this change can still be restored; it is upgraded when the app restarts. Backups made after this change cannot be opened by the older app (the existing "newer version" message).
  - Tests: migration test with a version 1 file (payments copied, nothing lost, run twice, old receipts print, numbering continues), repository tests, dashboard, student history, receipt links widget, backup restore of an older version. Total 436, all pass. `flutter analyze`: no issues.

- 2026-10-23 | Fee receipt note:
  - Collect Fee has an optional "Note" box above "Receive Fee". The note is saved on every payment of that receipt (`fee_payments.note`), printed as "Note: ..." on the receipt (also when printed again later), and cleared after a successful payment or when another student is chosen. A refused payment keeps what was typed.
  - If a reprinted receipt has different notes on its rows, they are shown once each, joined with ". ".
  - Tests: cubit (note sent, cleared, kept on refusal), repository (saved, reprinted, empty), PDF with English and Urdu notes, page shows the box.

- 2026-10-25 | Urdu in PDFs (bug fix):
  - **The bug:** the `pdf` package does not join or reverse Arabic letters, so Urdu in every PDF came out as separate backwards letters. Earlier entries said Urdu names were correct in PDFs; that was wrong (the old check only looked at a sample that I did not read closely enough).
  - **Fix:** new shared helper `core/utils/pdf_urdu_text.dart` (`PdfUrduText`). Any text with Arabic-script letters is drawn with Flutter's own text engine (correct joining, right-to-left, Noto Naskh Arabic, Inter for English letters and digits in the same line), saved as a 3x PNG and put in the PDF as an image. English/number-only text stays normal PDF text. Mixed text ("Ali S/O زاہد خان") is one picture for the whole line; the first letter decides left-to-right or right-to-left. The sentence on the leaving certificate wraps inside the page width.
  - **How it runs:** each PDF is built twice only when it contains Urdu (pass 1 finds the strings, they are drawn once each, pass 2 uses the pictures). English-only PDFs are built once. Pictures are cached per string for that one PDF (a 400-row report with 40 different names draws 40 pictures).
  - **Used by:** leaving certificate, fee receipt (and its note), result card (one and all), report PDFs (header, stats, headings, table cells). Urdu table cells and certificate fields sit on the right; sizes, table layouts and page counts are unchanged. Urdu is drawn 20% bigger than its font size because Naskh letters look small beside English.
  - **Checked visually:** I rendered sample PDFs of all four documents to PNG (pdftoppm) and looked at them: letters joined, in the right order ("زاہد خان", "عائشہ خان", "روضۃ الاطفال"), mixed English/Urdu lines correct, layouts intact.
  - Tests: helper (script detection, direction, picture has ink and right size, one picture per string, wrapping, one build vs two builds), each PDF builder with Urdu (pictures embedded; English-only has none), long report speed. `flutter analyze`: no issues.

## Known Issues
- PDFs: Urdu parts are pictures (sharp when printed), so they cannot be copied or searched inside the PDF. English text is real text.
- Classes page: reorder is hidden while a search is active. Teachers list stays empty until the Staff module adds staff.
- Students: Admissions (module 4) will add the automatic admission number flow and certificate; the form here only suggests the next number.
- Students: opening attached files uses the Windows default app; untested on Windows.
- Admissions: the certificate page (PDF preview, print, save) could not be run in the cloud (needs Windows plugins). Only the PDF itself was checked.
- Admissions: issuing a certificate does not mark the student as left. Use Mark as Left on the student page.
- Attendance: the per-student note column exists in the database and is kept when saving, but there is no screen to type a note yet.
- Attendance: PDF/CSV export of these reports comes with the Reports module.
- Fees: the receipt screen (PDF preview, print, save) could not be run in the cloud; the PDF itself was checked.
- Fees: paid/unpaid lists and defaulters for all classes come with the Reports module; here they are per class and month.
- Staff: salary is only stored and shown. No salary slips, attendance or payroll (not in the module list).
- Exams: grade bands and pass mark (33%) are my defaults. If the school uses different ones, tell me and I will change `GradeScale` (one place).
- Exams: the result card screen (PDF preview, print, save) could not be run in the cloud; the PDF itself was checked.
- Exams: no "absent" mark type; an empty box is treated as absent. Class-wide result sheets / reports come with the Reports module.
- Reports: the PDF preview screen and the CSV save dialog could not be run in the cloud (they need Windows plugins). The PDF and CSV content were checked.
- Reports: Defaulters lists active students only. A student who left with unpaid fee is not shown.
- Reports: the Dashboard and WhatsApp sharing are separate modules; there is no "send report" button here.
- WhatsApp: opening WhatsApp could not be tested in the cloud. The link format and the number conversion are tested; the owner must try it on Windows.
- WhatsApp: one message at a time (no bulk send), by design. If the parent has no valid number the button shows a message instead.
- Backup: **a fresh clone does not compile until `google_config.example.dart` is copied to `google_config.dart`** (see README). This is on purpose, to keep Google keys out of git.
- Backup: the real Google sign-in, upload, download and the "Restart App" button could not be tested in the cloud (no Google account, no Windows GUI). Everything around them is tested with fakes. The owner must test with a real Google account.
- Backup: automatic backup runs when the app starts (once a day). A backup "on app close" is not done, because Windows gives no safe time to run it. If the PC is never closed and the app stays open for days, press Back Up Now.
- Backup: the Drive file imports `package:http` (already installed by googleapis_auth) in the Drive file, with an `ignore` comment, because googleapis_auth needs an http client. No new package was added to `pubspec.yaml`.
- Backup: attached documents are included in the zip; a very large documents folder makes backups big and slow.
- Settings: the logo picker, "Open Folder", the PDFs with a logo and the Windows title/file info could not be run or built in the cloud (no Windows). The owner must check them.
- Performance numbers are from an in-memory database in the cloud, not from a real Windows PC.
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

### Module 8
1. Exams > Subjects: pick a class, add English (100), Urdu (100), Math (50). Try a repeated name and total 0: clear messages.
2. Exams > Exams: Create Exam (name, class, date). Try the same name twice for one class.
3. Open the exam. Enter marks for the class. Type a mark above the total: red box, Save is disabled. Watch Total, % and Grade change while typing.
4. Leave one box empty for a student and save: the student is "Incomplete" with no position. Fill it: Pass/Fail and a position appear.
5. Results tab: order by position, equal totals share a position. Check a student who fails one subject but has a high total is Fail.
6. Click a student: Result Card with Previous results on the left and the PDF on the right. Print to "Microsoft Print to PDF". Also "Print All Result Cards".
7. Check the PDF: fields, 1st/2nd/3rd, Urdu name, fits on one A4 page per student.
8. Try deleting an exam that has marks (blocked) and one without (allowed). Try deleting a subject that has marks (blocked).
9. Create a second exam for the same class and enter marks: both show in the student's Previous results.
10. Student detail > Results tab shows the marks of each exam.

### Module 9
1. Open Reports: 7 cards. Open each one in turn.
2. Students: check totals, class-wise and section-wise tables match the Students list.
3. New Admissions: change From/To dates. Students who left still show with status Left.
4. Attendance: pick class, section, month with the arrows. Compare with the Attendance > Monthly Report.
5. Fee Paid / Unpaid: pick a month and class, try Paid / Partial / Unpaid. Check Billed / Collected / Pending.
6. Fee Defaulters: compare with students who have unpaid fee in Fees.
7. Exam Results: choose an exam, check positions and grades match the exam Results tab.
8. Student History: search a student, check the three tables.
9. Type in "Search in this report" and see the rows narrow.
10. Click "PDF / Print": check the preview, then print to "Microsoft Print to PDF". Wide reports (many subjects) should print sideways. Check Urdu names.
11. Click "Save as CSV", choose a folder, open the file in Excel: columns, Urdu names, money as numbers.

### Module 10
1. In Students, open a student whose profile has a phone like 0300-1234567 (or a WhatsApp number). Click the WhatsApp button in the header: WhatsApp (Desktop or Web) opens with a message ready. The number in the chat should be +92 300 1234567. Press Send there yourself.
2. Open a student with no phone: a message says no valid number is saved.
3. Attendance > Mark Attendance: mark a student Absent. A green chat icon appears next to the buttons. Click it: message "... was absent from school on ...".
4. Attendance > Daily Report: green icon for Absent students. Monthly Report: click a student, click "Send to Parent on WhatsApp": monthly counts.
5. Fees > Vouchers: green icon on unpaid/partial vouchers: reminder with the balance. No icon on paid vouchers.
6. Receive a fee: on the receipt page click "Send to Parent on WhatsApp". Try with two sisters on one receipt.
7. Exams > open an exam > Results > click a student: "Send to Parent on WhatsApp" with marks and position.
8. Check Urdu names show correctly in the WhatsApp message text.
9. If WhatsApp is not installed, the browser (web.whatsapp.com) should open, or the app shows "WhatsApp could not be opened".

### Module 11
1. Copy `google_config.example.dart` to `google_config.dart` (README). The app should build.
2. Backup page: press Back Up Now. A zip appears in the shown folder, "Last backup" updates, and the Dashboard shows the same date.
3. Press it 12 times (or change the PC clock): only the newest 10 `school_backup_*` files stay.
4. Change Folder to a USB drive folder, back up again. Use the app folder returns to default.
5. Close and reopen the app: if it is a new day a backup is made by itself (check the folder and the date).
6. Google Drive (needs a Google account and the keys in `google_config.dart`): Connect Google Drive, allow in the browser. The email shows. Back Up Now: the message says it was uploaded; check Drive has a folder "School Backups" with the zip.
7. Turn off the internet and press Back Up Now: red message "saved on this computer ... no internet", "Waiting to upload" shows. Turn the internet on and restart the app: the upload is sent.
8. Restore from this computer: first add a test student. Back up. Add another student. Restore the backup: confirm, wait, press Restart App. The app restarts and only the first student is there; attached documents open. Check a `school_before_restore_*` file was saved.
9. Restore from Google Drive: On Google Drive tab, Load backups, Restore one.
10. Try restoring a wrong file (rename a .txt to a backup name is not possible from the page; the list only shows real backups). Try Disconnect: Drive tab disappears, nothing is deleted on Drive.
11. If possible, copy a backup zip to another Windows user/PC, restore there, and check attached documents still open.

### Module 12
1. Settings: change school name, address, phone and Save. The sidebar name updates at once. Empty name: red message.
2. Choose Logo: pick a PNG or JPG. It shows in Settings and in the sidebar. Try a .txt renamed to .png and a very large picture: clear red message.
3. Remove Logo: the default icon returns. Close and reopen the app: the logo/name stay.
4. Print a fee receipt, a result card, a leaving certificate and a report PDF: each shows logo, name, address and phone.
5. Open Folder opens the data folder in Explorer. Go to Backup opens the Backup page.
6. Dashboard: all six cards open their pages; the backup chip opens Backup. Numbers match the real data.
7. The window title reads "Rozatul Atfal - School Management" and opens at a good size.
8. With a school of 1000+ students, check lists, search, attendance and the dashboard feel quick.

### Fee payments table
1. First open the new version with your real school database (copy it first!). Fees > Collect Fee: old receipts still open from the voucher list/history and show the right amounts and dates.
2. Take a part payment on a voucher, then another day take the rest: two receipts, numbers different. Fee history shows "2 receipts"; open both from the menu. The first one still shows the part amount and the balance at that time.
3. Collect for two sisters together: one receipt number, both on one receipt. Print it again from either sister's history.
4. Dashboard "Fees collected this month" equals the sum of the payments received this month.
5. Restore an old backup (made before this update) in Backup: restart the app and check fee history and receipts are all there.
6. Fee receipt note: on Collect Fee type a note (also Urdu) and press Receive Fee: the receipt shows "Note: ...". Open the same receipt again from the history: the note is still there. The box is empty for the next payment.

### Urdu in PDFs
1. Open a student with an Urdu name (and an Urdu father name). Print a fee receipt, a result card (one and all), a leaving certificate and a report that lists students: in every PDF the name must be joined letters, reading right to left, same as on screen.
2. Set the school name and address in Urdu in Settings and print again: the header is joined and centred.
3. English names must look as before; check page counts and that nothing is cut off at the edges of tables.
4. Print a long report (many Urdu names): it should still open in a few seconds. Text in the PDF is now a picture for Urdu parts, so Urdu cannot be selected or searched in the PDF (English can).

### Windows exe name
1. Build with `flutter build windows`: the output is `build\windowsdunner\Release\IqraRozatulAtfal.exe` (was haqani.exe). Right-click the exe > Properties > Details: name and description read "Iqra Rozatul Atfal".
2. Open the app: the window title is unchanged and your existing students, fees and backups are all still there (data folder was not changed).
3. Update any old desktop shortcut or installer that points to haqani.exe.

### App icon
1. Build: `flutter build windows`, then look at `IqraRozatulAtfal.exe` in Explorer: it shows the school logo (not the Flutter logo). Check in Large icons and Small icons view.
2. Run the app: the taskbar and the window corner show the logo. Pin it to the taskbar and check again.
3. If Explorer still shows the old icon, it is the Windows icon cache: copy the exe to another folder or restart Explorer.
4. The sidebar logo and the Settings logo work as before.

(Source: `assets/icon/app_icon.png`. `flutter_launcher_icons` (dev only, Windows only) made the first `app_icon.ico`; it writes one 256 size only, so the .ico was rebuilt with 16, 24, 32, 48, 64, 128 and 256 from the same PNG. Running `dart run flutter_launcher_icons` again overwrites it with the single size.)

## Notes / Decisions
- Database: drift (SQLite), single local file.
- No login, no security features (client requirement).
- WhatsApp via wa.me link only.
