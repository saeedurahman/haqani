/// Thrown with a message that is safe to show to the user.
class StaffException implements Exception {
  const StaffException(this.message);

  final String message;

  @override
  String toString() => message;
}
