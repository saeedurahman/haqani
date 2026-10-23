/// Thrown with a message that is safe to show to the user.
class StudentsException implements Exception {
  const StudentsException(this.message);

  final String message;

  @override
  String toString() => message;
}
