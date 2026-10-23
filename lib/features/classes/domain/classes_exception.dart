/// Thrown with a message that is safe to show to the user.
class ClassesException implements Exception {
  const ClassesException(this.message);

  final String message;

  @override
  String toString() => message;
}
