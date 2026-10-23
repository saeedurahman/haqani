import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/classes/data/classes_repository_impl.dart';
import 'package:haqani/features/classes/domain/classes_exception.dart';

void main() {
  late AppDatabase db;
  late ClassesRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ClassesRepositoryImpl(db);
  });

  tearDown(() => db.close());

  Future<int> classId(String name) async =>
      (await repo.getClasses()).firstWhere((c) => c.name == name).id;

  Future<int> addStudent(String no,
      {int? classId, int? sectionId, String status = 'active'}) {
    return db.into(db.students).insert(StudentsCompanion.insert(
          admissionNo: no,
          name: 'Student $no',
          classId: Value(classId),
          sectionId: Value(sectionId),
          status: Value(status),
        ));
  }

  Future<int> sectionId(int classId, String name) async {
    final c = (await repo.getClasses()).firstWhere((c) => c.id == classId);
    return c.sections.firstWhere((s) => s.name == name).id;
  }

  group('classes', () {
    test('adds classes in order and trims names', () async {
      await repo.addClass('  Nursery ');
      await repo.addClass('Class 1');

      final classes = await repo.getClasses();
      expect(classes.map((c) => c.name), ['Nursery', 'Class 1']);
      expect(classes.map((c) => c.sortOrder), [0, 1]);
    });

    test('rejects empty and duplicate names (any letter case)', () async {
      await repo.addClass('Class 1');

      expect(() => repo.addClass('  '), throwsA(isA<ClassesException>()));
      expect(() => repo.addClass('class 1'), throwsA(isA<ClassesException>()));
    });

    test('renames a class, and allows keeping the same name', () async {
      await repo.addClass('Class 1');
      final id = await classId('Class 1');

      await repo.renameClass(id, 'Class 1');
      await repo.renameClass(id, 'Class One');

      expect((await repo.getClasses()).single.name, 'Class One');
    });

    test('saves a new order', () async {
      await repo.addClass('A');
      await repo.addClass('B');
      await repo.addClass('C');
      final ids = [for (final c in await repo.getClasses()) c.id];

      await repo.saveClassOrder([ids[2], ids[0], ids[1]]);

      expect((await repo.getClasses()).map((c) => c.name), ['C', 'A', 'B']);
    });

    test('deletes an empty class', () async {
      await repo.addClass('Class 1');
      await repo.deleteClass(await classId('Class 1'));

      expect(await repo.getClasses(), isEmpty);
    });

    test('blocks delete when the class has sections', () async {
      await repo.addClass('Class 1');
      final id = await classId('Class 1');
      await repo.addSection(id, 'A');

      expect(() => repo.deleteClass(id), throwsA(isA<ClassesException>()));
      expect(await repo.getClasses(), hasLength(1));
    });

    test('blocks delete when the class has students, even left ones', () async {
      await repo.addClass('Class 1');
      final id = await classId('Class 1');
      await addStudent('1', classId: id, status: 'left');

      expect(() => repo.deleteClass(id), throwsA(isA<ClassesException>()));
    });

    test('blocks delete when the class is used by an exam', () async {
      await repo.addClass('Class 1');
      final id = await classId('Class 1');
      await db.into(db.exams).insert(
            ExamsCompanion.insert(name: 'Annual', classId: id),
          );

      expect(() => repo.deleteClass(id), throwsA(isA<ClassesException>()));
    });

    test('counts only active students per class and section', () async {
      await repo.addClass('Class 1');
      final id = await classId('Class 1');
      await repo.addSection(id, 'A');
      final sid = await sectionId(id, 'A');
      await addStudent('1', classId: id, sectionId: sid);
      await addStudent('2', classId: id);
      await addStudent('3', classId: id, status: 'left');

      final c = (await repo.getClasses()).single;
      expect(c.studentCount, 2);
      expect(c.sections.single.studentCount, 1);
    });
  });

  group('sections', () {
    late int cid;

    setUp(() async {
      await repo.addClass('Class 1');
      cid = await classId('Class 1');
    });

    test('adds a section without a teacher', () async {
      await repo.addSection(cid, ' A ');

      final s = (await repo.getClasses()).single.sections.single;
      expect(s.name, 'A');
      expect(s.classTeacherId, isNull);
      expect(s.classTeacherName, isNull);
    });

    test('rejects empty and duplicate section names in the same class', () async {
      await repo.addSection(cid, 'A');

      expect(() => repo.addSection(cid, ''), throwsA(isA<ClassesException>()));
      expect(() => repo.addSection(cid, 'a'), throwsA(isA<ClassesException>()));
    });

    test('allows the same section name in a different class', () async {
      await repo.addClass('Class 2');
      await repo.addSection(cid, 'A');
      await repo.addSection(await classId('Class 2'), 'A');

      expect((await repo.getClasses()).every((c) => c.sections.length == 1), isTrue);
    });

    test('assigns, changes and removes the class teacher', () async {
      final t1 = await db.into(db.staff).insert(StaffCompanion.insert(name: 'Ms Sana'));
      final t2 = await db.into(db.staff).insert(StaffCompanion.insert(name: 'Mr Ali'));
      await repo.addSection(cid, 'A', teacherId: t1);
      final sid = await sectionId(cid, 'A');

      expect((await repo.getClasses()).single.sections.single.classTeacherName,
          'Ms Sana');

      await repo.updateSection(sid, 'B', teacherId: t2);
      var s = (await repo.getClasses()).single.sections.single;
      expect((s.name, s.classTeacherName), ('B', 'Mr Ali'));

      await repo.updateSection(sid, 'B');
      s = (await repo.getClasses()).single.sections.single;
      expect(s.classTeacherId, isNull);
    });

    test('teacher list has active staff only', () async {
      await db.into(db.staff).insert(StaffCompanion.insert(name: 'Active'));
      await db.into(db.staff).insert(
            StaffCompanion.insert(name: 'Gone', isActive: const Value(false)),
          );

      expect((await repo.getTeachers()).map((t) => t.name), ['Active']);
    });

    test('keeps the teacher name even if the teacher is no longer active', () async {
      final t = await db.into(db.staff).insert(StaffCompanion.insert(name: 'Old Teacher'));
      await repo.addSection(cid, 'A', teacherId: t);
      await (db.update(db.staff)..where((s) => s.id.equals(t)))
          .write(const StaffCompanion(isActive: Value(false)));

      expect((await repo.getClasses()).single.sections.single.classTeacherName,
          'Old Teacher');
    });

    test('deletes an empty section but blocks one with students', () async {
      await repo.addSection(cid, 'A');
      await repo.addSection(cid, 'B');
      final a = await sectionId(cid, 'A');
      final b = await sectionId(cid, 'B');
      await addStudent('1', classId: cid, sectionId: b);

      await repo.deleteSection(a);
      expect(() => repo.deleteSection(b), throwsA(isA<ClassesException>()));

      expect((await repo.getClasses()).single.sections.map((s) => s.name), ['B']);
    });
  });
}
