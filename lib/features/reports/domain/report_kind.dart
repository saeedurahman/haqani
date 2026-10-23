enum ReportKind {
  students(
    'Students',
    'Total students, boys and girls, class and section wise',
  ),
  admissions('New Admissions', 'Students admitted between two dates'),
  attendance('Attendance', 'Present, absent and leave of a class for a month'),
  fees('Fee Paid / Unpaid', 'Who paid and who did not, for any month'),
  defaulters('Fee Defaulters', 'Students who still owe fee, biggest first'),
  examResults('Exam Results', 'Class result sheet with positions and grades'),
  studentHistory(
    'Student History',
    'Attendance, fees and results of one student',
  );

  const ReportKind(this.label, this.description);

  final String label;
  final String description;
}
