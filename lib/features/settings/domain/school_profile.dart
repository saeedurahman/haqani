import 'package:equatable/equatable.dart';

/// The school's name, address, phone and logo. Shown in the app and on prints.
class SchoolProfile extends Equatable {
  const SchoolProfile({
    required this.name,
    this.address = '',
    this.phone = '',
    this.logoPath,
  });

  final String name;
  final String address;
  final String phone;

  /// Full path of the logo image, or null when there is no logo.
  final String? logoPath;

  @override
  List<Object?> get props => [name, address, phone, logoPath];
}

/// Thrown with a message that is safe to show to the user.
class SettingsException implements Exception {
  const SettingsException(this.message);

  final String message;

  @override
  String toString() => message;
}
