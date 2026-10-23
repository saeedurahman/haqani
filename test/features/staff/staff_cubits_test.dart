import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/staff/domain/staff_exception.dart';
import 'package:haqani/features/staff/domain/staff_member.dart';
import 'package:haqani/features/staff/domain/staff_repository.dart';
import 'package:haqani/features/staff/presentation/cubit/staff_cubit.dart';
import 'package:haqani/features/staff/presentation/cubit/staff_form_cubit.dart';
import 'package:haqani/features/staff/presentation/cubit/staff_form_state.dart';
import 'package:haqani/features/staff/presentation/cubit/staff_state.dart';

class _FakeRepository implements StaffRepository {
  List<StaffMember> people = const [
    StaffMember(id: 1, name: 'Sana'),
    StaffMember(id: 2, name: 'Ali', isActive: false),
  ];
  bool fail = false;
  String? saveError;
  StaffMember? saved;
  String? lastQuery;
  bool? lastIncludeInactive;

  @override
  Future<List<StaffMember>> searchStaff({String query = '', bool includeInactive = false}) async {
    if (fail) throw Exception('db');
    lastQuery = query;
    lastIncludeInactive = includeInactive;
    return people;
  }

  @override
  Future<StaffMember?> getStaff(int id) async => people.where((s) => s.id == id).firstOrNull;

  @override
  Future<int> saveStaff(StaffMember member) async {
    if (saveError != null) throw StaffException(saveError!);
    if (fail) throw Exception('db');
    saved = member;
    return 5;
  }

  @override
  Future<void> setActive(int id, {required bool active}) async {
    if (fail) throw Exception('db');
    people = [
      for (final p in people)
        p.id == id
            ? StaffMember(id: p.id, name: p.name, isActive: active)
            : p,
    ];
  }
}

void main() {
  late _FakeRepository repo;

  setUp(() => repo = _FakeRepository());

  group('StaffCubit', () {
    test('load emits loading then success', () async {
      final cubit = StaffCubit(repo);
      final statuses = <StaffStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(statuses, [StaffStatus.loading, StaffStatus.success]);
      expect(cubit.state.staff, hasLength(2));
      await cubit.close();
    });

    test('failure shows a friendly message', () async {
      repo.fail = true;
      final cubit = StaffCubit(repo);

      await cubit.load();

      expect(cubit.state.status, StaffStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });

    test('search and show-inactive go to the repository', () async {
      final cubit = StaffCubit(repo);
      await cubit.load();

      await cubit.search('sana');
      await cubit.showInactive(true);

      expect(repo.lastQuery, 'sana');
      expect(repo.lastIncludeInactive, isTrue);
      expect(cubit.state.hasFilter, isTrue);
      await cubit.close();
    });
  });

  group('StaffFormCubit', () {
    test('a new person is ready at once', () async {
      final cubit = StaffFormCubit(repo);

      await cubit.load();

      expect(cubit.state.status, StaffFormStatus.ready);
      expect(cubit.state.isEditing, isFalse);
      await cubit.close();
    });

    test('edit loads the person; a missing person fails clearly', () async {
      final cubit = StaffFormCubit(repo);
      await cubit.load(staffId: 1);
      expect(cubit.state.member?.name, 'Sana');
      expect(cubit.state.isEditing, isTrue);

      final missing = StaffFormCubit(repo);
      await missing.load(staffId: 99);
      expect(missing.state.status, StaffFormStatus.failure);
      expect(missing.state.errorMessage, 'This person was not found.');
      await cubit.close();
      await missing.close();
    });

    test('save success, refused save and unexpected error', () async {
      final cubit = StaffFormCubit(repo);
      await cubit.load();

      await cubit.save(const StaffMember(name: 'Zain'));
      expect(cubit.state.status, StaffFormStatus.saved);
      expect(repo.saved?.name, 'Zain');

      repo.saveError = 'Name is required.';
      await cubit.save(const StaffMember(name: ''));
      expect(cubit.state.status, StaffFormStatus.ready);
      expect(cubit.state.errorMessage, 'Name is required.');

      repo.saveError = null;
      repo.fail = true;
      await cubit.save(const StaffMember(name: 'Zain'));
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });

    test('mark as left and make active again report a message', () async {
      final cubit = StaffFormCubit(repo);
      await cubit.load(staffId: 1);

      await cubit.setActive(active: false);
      expect(cubit.state.member?.isActive, isFalse);
      expect(cubit.state.feedback, 'Sana is marked as left.');

      await cubit.setActive(active: true);
      expect(cubit.state.member?.isActive, isTrue);
      expect(cubit.state.feedback, 'Sana is active again.');
      expect(cubit.state.feedbackId, 2);
      await cubit.close();
    });
  });
}
