import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/classes/domain/classes_exception.dart';
import 'package:haqani/features/classes/domain/classes_repository.dart';
import 'package:haqani/features/classes/domain/school_class.dart';
import 'package:haqani/features/classes/presentation/cubit/classes_cubit.dart';
import 'package:haqani/features/classes/presentation/cubit/classes_state.dart';

class _FakeRepository implements ClassesRepository {
  List<SchoolClass> classes = const [
    SchoolClass(id: 1, name: 'Nursery', sortOrder: 0),
    SchoolClass(
      id: 2,
      name: 'Class 1',
      sortOrder: 1,
      sections: [SchoolSection(id: 10, classId: 2, name: 'Rose')],
    ),
    SchoolClass(id: 3, name: 'Class 2', sortOrder: 2),
  ];
  bool failLoad = false;
  String? blockWith;
  List<int>? savedOrder;
  String? lastAdded;
  ({String name, int? teacherId})? lastSection;

  void _check() {
    if (blockWith != null) throw ClassesException(blockWith!);
  }

  @override
  Future<List<SchoolClass>> getClasses() async {
    if (failLoad) throw Exception('db');
    return classes;
  }

  @override
  Future<List<TeacherOption>> getTeachers() async =>
      const [TeacherOption(id: 5, name: 'Ms Sana')];

  @override
  Future<void> addClass(String name) async {
    _check();
    lastAdded = name;
  }

  @override
  Future<void> renameClass(int id, String name) async => _check();

  @override
  Future<void> deleteClass(int id) async => _check();

  @override
  Future<void> saveClassOrder(List<int> orderedIds) async {
    _check();
    savedOrder = orderedIds;
    classes = [
      for (final id in orderedIds) classes.firstWhere((c) => c.id == id),
    ];
  }

  @override
  Future<void> addSection(int classId, String name, {int? teacherId}) async {
    _check();
    lastSection = (name: name, teacherId: teacherId);
  }

  @override
  Future<void> updateSection(int id, String name, {int? teacherId}) async =>
      _check();

  @override
  Future<void> deleteSection(int id) async => _check();
}

void main() {
  late _FakeRepository repo;
  late ClassesCubit cubit;

  setUp(() {
    repo = _FakeRepository();
    cubit = ClassesCubit(repo);
  });

  tearDown(() => cubit.close());

  test('load emits loading then success with classes and teachers', () async {
    final statuses = <ClassesStatus>[];
    final sub = cubit.stream.listen((s) => statuses.add(s.status));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(statuses, [ClassesStatus.loading, ClassesStatus.success]);
    expect(cubit.state.classes, hasLength(3));
    expect(cubit.state.teachers.single.name, 'Ms Sana');
  });

  test('load failure emits a friendly message', () async {
    repo.failLoad = true;

    await cubit.load();

    expect(cubit.state.status, ClassesStatus.failure);
    expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
  });

  test('search filters by class name and section name', () async {
    await cubit.load();

    cubit.search('nurs');
    expect(cubit.state.visibleClasses.map((c) => c.name), ['Nursery']);

    cubit.search('rose');
    expect(cubit.state.visibleClasses.map((c) => c.name), ['Class 1']);

    cubit.search('zzz');
    expect(cubit.state.visibleClasses, isEmpty);
    expect(cubit.state.classes, hasLength(3));
  });

  test('addClass reloads and sends a success message', () async {
    await cubit.load();
    final before = cubit.state.feedbackId;

    await cubit.addClass('Class 3');

    expect(repo.lastAdded, 'Class 3');
    expect(cubit.state.feedback, 'Class added.');
    expect(cubit.state.feedbackIsError, isFalse);
    expect(cubit.state.feedbackId, before + 1);
  });

  test('a blocked delete shows the rule message and keeps the list', () async {
    await cubit.load();
    repo.blockWith = 'This class has sections. Delete the sections first.';

    await cubit.deleteClass(2);

    expect(cubit.state.feedback, repo.blockWith);
    expect(cubit.state.feedbackIsError, isTrue);
    expect(cubit.state.status, ClassesStatus.success);
    expect(cubit.state.classes, hasLength(3));
  });

  test('unexpected errors show a friendly message', () async {
    await cubit.load();
    repo.blockWith = null;
    repo.classes = const [];
    repo.failLoad = true;

    await cubit.addClass('X');

    expect(cubit.state.feedback, AppStrings.somethingWentWrong);
    expect(cubit.state.feedbackIsError, isTrue);
  });

  test('moveClass swaps with the neighbour and saves the full order', () async {
    await cubit.load();

    await cubit.moveClass(2, -1);
    expect(repo.savedOrder, [2, 1, 3]);

    repo.savedOrder = null;
    await cubit.moveClass(3, 1);
    expect(repo.savedOrder, isNull, reason: 'last item cannot move down');

    await cubit.moveClass(1, -1);
    expect(repo.savedOrder, [1, 2, 3]);
  });

  test('moveClass does nothing at the top', () async {
    await cubit.load();

    await cubit.moveClass(1, -1);

    expect(repo.savedOrder, isNull);
  });

  test('addSection passes the teacher and reports success', () async {
    await cubit.load();

    await cubit.addSection(1, 'A', teacherId: 5);

    expect(repo.lastSection, (name: 'A', teacherId: 5));
    expect(cubit.state.feedback, 'Section added.');
  });
}
