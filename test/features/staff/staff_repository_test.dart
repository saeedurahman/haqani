import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/classes/data/classes_repository_impl.dart';
import 'package:haqani/features/staff/data/staff_repository_impl.dart';
import 'package:haqani/features/staff/domain/staff_exception.dart';
import 'package:haqani/features/staff/domain/staff_member.dart';

void main() {
  late AppDatabase db;
  late StaffRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = StaffRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('saves every field and reads it back', () async {
    final id = await repo.saveStaff(StaffMember(
      name: ' Sana Khan ',
      fatherName: 'Imran Khan',
      designation: 'Teacher',
      phone: '0300-1234567',
      cnic: '12345-1234567-1',
      joiningDate: DateTime(2024, 4, 1),
      salary: 25000,
      address: 'Lahore',
    ));

    final saved = (await repo.getStaff(id))!;
    expect(saved.name, 'Sana Khan');
    expect(saved.fatherName, 'Imran Khan');
    expect(saved.designation, 'Teacher');
    expect(saved.phone, '0300-1234567');
    expect(saved.cnic, '12345-1234567-1');
    expect(saved.joiningDate, DateTime(2024, 4, 1));
    expect(saved.salary, 25000);
    expect(saved.address, 'Lahore');
    expect(saved.isActive, isTrue);
  });

  test('requires a name and a salary of 0 or more', () async {
    expect(() => repo.saveStaff(const StaffMember(name: '  ')), throwsA(isA<StaffException>()));
    expect(() => repo.saveStaff(const StaffMember(name: 'A', salary: -1)),
        throwsA(isA<StaffException>()));
  });

  test('editing changes the person and keeps the active flag', () async {
    final id = await repo.saveStaff(const StaffMember(name: 'Sana', salary: 20000));
    await repo.setActive(id, active: false);

    await repo.saveStaff(StaffMember(id: id, name: 'Sana Khan', salary: 22000));

    final saved = (await repo.getStaff(id))!;
    expect((saved.name, saved.salary, saved.isActive), ('Sana Khan', 22000, false));
    expect(await db.select(db.staff).get(), hasLength(1));
  });

  test('editing a person that does not exist is refused', () async {
    expect(() => repo.saveStaff(const StaffMember(id: 99, name: 'Ghost')),
        throwsA(isA<StaffException>()));
  });

  group('search', () {
    setUp(() async {
      await repo.saveStaff(const StaffMember(name: 'Sana Khan', designation: 'Teacher', phone: '0300-1111111'));
      await repo.saveStaff(const StaffMember(name: 'Ali Raza', designation: 'Principal', phone: '0321-2222222'));
      await repo.saveStaff(const StaffMember(name: 'Bashir', fatherName: 'Noor Din', designation: 'Peon'));
    });

    test('sorted by name', () async {
      expect((await repo.searchStaff()).map((s) => s.name), ['Ali Raza', 'Bashir', 'Sana Khan']);
    });

    test('finds by name, father name, designation and phone', () async {
      expect((await repo.searchStaff(query: 'sana')).single.name, 'Sana Khan');
      expect((await repo.searchStaff(query: 'noor')).single.name, 'Bashir');
      expect((await repo.searchStaff(query: 'princ')).single.name, 'Ali Raza');
      expect((await repo.searchStaff(query: '0321')).single.name, 'Ali Raza');
      expect(await repo.searchStaff(query: 'zzz'), isEmpty);
    });

    test('hides staff who left unless asked, and brings them back when active again', () async {
      final ali = (await repo.searchStaff(query: 'ali')).single;
      await repo.setActive(ali.id, active: false);

      expect(await repo.searchStaff(), hasLength(2));
      expect(await repo.searchStaff(includeInactive: true), hasLength(3));

      await repo.setActive(ali.id, active: true);
      expect(await repo.searchStaff(), hasLength(3));
    });
  });

  test('staff added here can be picked as class teacher; marking them left keeps the name', () async {
    final classes = ClassesRepositoryImpl(db);
    final id = await repo.saveStaff(const StaffMember(name: 'Sana Khan'));
    await classes.addClass('Class 1');
    final classId = (await classes.getClasses()).single.id;

    expect((await classes.getTeachers()).map((t) => t.name), ['Sana Khan']);
    await classes.addSection(classId, 'A', teacherId: id);

    await repo.setActive(id, active: false);

    expect(await classes.getTeachers(), isEmpty);
    expect((await classes.getClasses()).single.sections.single.classTeacherName, 'Sana Khan');
  });
}
