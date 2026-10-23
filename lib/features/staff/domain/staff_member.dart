import 'package:equatable/equatable.dart';

class StaffMember extends Equatable {
  const StaffMember({
    this.id = 0,
    required this.name,
    this.fatherName = '',
    this.designation = '',
    this.phone = '',
    this.cnic = '',
    this.joiningDate,
    this.salary = 0,
    this.address = '',
    this.isActive = true,
  });

  /// 0 means not saved yet.
  final int id;
  final String name;
  final String fatherName;

  /// Example: Teacher, Principal, Peon.
  final String designation;
  final String phone;
  final String cnic;
  final DateTime? joiningDate;

  /// Whole PKR per month.
  final int salary;
  final String address;
  final bool isActive;

  @override
  List<Object?> get props =>
      [id, name, fatherName, designation, phone, cnic, joiningDate, salary, address, isActive];
}
