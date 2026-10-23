// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchoolClassesTable extends SchoolClasses
    with TableInfo<$SchoolClassesTable, SchoolClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchoolClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolClassesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SchoolClassesTable createAlias(String alias) {
    return $SchoolClassesTable(attachedDatabase, alias);
  }
}

class SchoolClassesData extends DataClass
    implements Insertable<SchoolClassesData> {
  final int id;
  final String name;
  final int sortOrder;
  const SchoolClassesData({
    required this.id,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SchoolClassesCompanion toCompanion(bool nullToAbsent) {
    return SchoolClassesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory SchoolClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolClassesData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  SchoolClassesData copyWith({int? id, String? name, int? sortOrder}) =>
      SchoolClassesData(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  SchoolClassesData copyWithCompanion(SchoolClassesCompanion data) {
    return SchoolClassesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolClassesData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolClassesData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class SchoolClassesCompanion extends UpdateCompanion<SchoolClassesData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  const SchoolClassesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SchoolClassesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SchoolClassesData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SchoolClassesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return SchoolClassesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolClassesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $StaffTable extends Staff with TableInfo<$StaffTable, StaffData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _designationMeta = const VerificationMeta(
    'designation',
  );
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
    'designation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cnicMeta = const VerificationMeta('cnic');
  @override
  late final GeneratedColumn<String> cnic = GeneratedColumn<String>(
    'cnic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _joiningDateMeta = const VerificationMeta(
    'joiningDate',
  );
  @override
  late final GeneratedColumn<String> joiningDate = GeneratedColumn<String>(
    'joining_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<int> salary = GeneratedColumn<int>(
    'salary',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fatherName,
    designation,
    phone,
    cnic,
    joiningDate,
    salary,
    address,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('designation')) {
      context.handle(
        _designationMeta,
        designation.isAcceptableOrUnknown(
          data['designation']!,
          _designationMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('cnic')) {
      context.handle(
        _cnicMeta,
        cnic.isAcceptableOrUnknown(data['cnic']!, _cnicMeta),
      );
    }
    if (data.containsKey('joining_date')) {
      context.handle(
        _joiningDateMeta,
        joiningDate.isAcceptableOrUnknown(
          data['joining_date']!,
          _joiningDateMeta,
        ),
      );
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      )!,
      designation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      cnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnic'],
      )!,
      joiningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}joining_date'],
      ),
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $StaffTable createAlias(String alias) {
    return $StaffTable(attachedDatabase, alias);
  }
}

class StaffData extends DataClass implements Insertable<StaffData> {
  final int id;
  final String name;
  final String fatherName;
  final String designation;
  final String phone;
  final String cnic;
  final String? joiningDate;
  final int salary;
  final String address;
  final bool isActive;
  const StaffData({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.designation,
    required this.phone,
    required this.cnic,
    this.joiningDate,
    required this.salary,
    required this.address,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['father_name'] = Variable<String>(fatherName);
    map['designation'] = Variable<String>(designation);
    map['phone'] = Variable<String>(phone);
    map['cnic'] = Variable<String>(cnic);
    if (!nullToAbsent || joiningDate != null) {
      map['joining_date'] = Variable<String>(joiningDate);
    }
    map['salary'] = Variable<int>(salary);
    map['address'] = Variable<String>(address);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  StaffCompanion toCompanion(bool nullToAbsent) {
    return StaffCompanion(
      id: Value(id),
      name: Value(name),
      fatherName: Value(fatherName),
      designation: Value(designation),
      phone: Value(phone),
      cnic: Value(cnic),
      joiningDate: joiningDate == null && nullToAbsent
          ? const Value.absent()
          : Value(joiningDate),
      salary: Value(salary),
      address: Value(address),
      isActive: Value(isActive),
    );
  }

  factory StaffData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      designation: serializer.fromJson<String>(json['designation']),
      phone: serializer.fromJson<String>(json['phone']),
      cnic: serializer.fromJson<String>(json['cnic']),
      joiningDate: serializer.fromJson<String?>(json['joiningDate']),
      salary: serializer.fromJson<int>(json['salary']),
      address: serializer.fromJson<String>(json['address']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fatherName': serializer.toJson<String>(fatherName),
      'designation': serializer.toJson<String>(designation),
      'phone': serializer.toJson<String>(phone),
      'cnic': serializer.toJson<String>(cnic),
      'joiningDate': serializer.toJson<String?>(joiningDate),
      'salary': serializer.toJson<int>(salary),
      'address': serializer.toJson<String>(address),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  StaffData copyWith({
    int? id,
    String? name,
    String? fatherName,
    String? designation,
    String? phone,
    String? cnic,
    Value<String?> joiningDate = const Value.absent(),
    int? salary,
    String? address,
    bool? isActive,
  }) => StaffData(
    id: id ?? this.id,
    name: name ?? this.name,
    fatherName: fatherName ?? this.fatherName,
    designation: designation ?? this.designation,
    phone: phone ?? this.phone,
    cnic: cnic ?? this.cnic,
    joiningDate: joiningDate.present ? joiningDate.value : this.joiningDate,
    salary: salary ?? this.salary,
    address: address ?? this.address,
    isActive: isActive ?? this.isActive,
  );
  StaffData copyWithCompanion(StaffCompanion data) {
    return StaffData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      designation: data.designation.present
          ? data.designation.value
          : this.designation,
      phone: data.phone.present ? data.phone.value : this.phone,
      cnic: data.cnic.present ? data.cnic.value : this.cnic,
      joiningDate: data.joiningDate.present
          ? data.joiningDate.value
          : this.joiningDate,
      salary: data.salary.present ? data.salary.value : this.salary,
      address: data.address.present ? data.address.value : this.address,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherName: $fatherName, ')
          ..write('designation: $designation, ')
          ..write('phone: $phone, ')
          ..write('cnic: $cnic, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('salary: $salary, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fatherName,
    designation,
    phone,
    cnic,
    joiningDate,
    salary,
    address,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffData &&
          other.id == this.id &&
          other.name == this.name &&
          other.fatherName == this.fatherName &&
          other.designation == this.designation &&
          other.phone == this.phone &&
          other.cnic == this.cnic &&
          other.joiningDate == this.joiningDate &&
          other.salary == this.salary &&
          other.address == this.address &&
          other.isActive == this.isActive);
}

class StaffCompanion extends UpdateCompanion<StaffData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> fatherName;
  final Value<String> designation;
  final Value<String> phone;
  final Value<String> cnic;
  final Value<String?> joiningDate;
  final Value<int> salary;
  final Value<String> address;
  final Value<bool> isActive;
  const StaffCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.designation = const Value.absent(),
    this.phone = const Value.absent(),
    this.cnic = const Value.absent(),
    this.joiningDate = const Value.absent(),
    this.salary = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  StaffCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.fatherName = const Value.absent(),
    this.designation = const Value.absent(),
    this.phone = const Value.absent(),
    this.cnic = const Value.absent(),
    this.joiningDate = const Value.absent(),
    this.salary = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<StaffData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? fatherName,
    Expression<String>? designation,
    Expression<String>? phone,
    Expression<String>? cnic,
    Expression<String>? joiningDate,
    Expression<int>? salary,
    Expression<String>? address,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fatherName != null) 'father_name': fatherName,
      if (designation != null) 'designation': designation,
      if (phone != null) 'phone': phone,
      if (cnic != null) 'cnic': cnic,
      if (joiningDate != null) 'joining_date': joiningDate,
      if (salary != null) 'salary': salary,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
    });
  }

  StaffCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? fatherName,
    Value<String>? designation,
    Value<String>? phone,
    Value<String>? cnic,
    Value<String?>? joiningDate,
    Value<int>? salary,
    Value<String>? address,
    Value<bool>? isActive,
  }) {
    return StaffCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      joiningDate: joiningDate ?? this.joiningDate,
      salary: salary ?? this.salary,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (cnic.present) {
      map['cnic'] = Variable<String>(cnic.value);
    }
    if (joiningDate.present) {
      map['joining_date'] = Variable<String>(joiningDate.value);
    }
    if (salary.present) {
      map['salary'] = Variable<int>(salary.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherName: $fatherName, ')
          ..write('designation: $designation, ')
          ..write('phone: $phone, ')
          ..write('cnic: $cnic, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('salary: $salary, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_classes (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classTeacherIdMeta = const VerificationMeta(
    'classTeacherId',
  );
  @override
  late final GeneratedColumn<int> classTeacherId = GeneratedColumn<int>(
    'class_teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES staff (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, classId, name, classTeacherId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('class_teacher_id')) {
      context.handle(
        _classTeacherIdMeta,
        classTeacherId.isAcceptableOrUnknown(
          data['class_teacher_id']!,
          _classTeacherIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      classTeacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_teacher_id'],
      ),
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final int id;
  final int classId;
  final String name;
  final int? classTeacherId;
  const Section({
    required this.id,
    required this.classId,
    required this.name,
    this.classTeacherId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || classTeacherId != null) {
      map['class_teacher_id'] = Variable<int>(classTeacherId);
    }
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      classId: Value(classId),
      name: Value(name),
      classTeacherId: classTeacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(classTeacherId),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      name: serializer.fromJson<String>(json['name']),
      classTeacherId: serializer.fromJson<int?>(json['classTeacherId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'name': serializer.toJson<String>(name),
      'classTeacherId': serializer.toJson<int?>(classTeacherId),
    };
  }

  Section copyWith({
    int? id,
    int? classId,
    String? name,
    Value<int?> classTeacherId = const Value.absent(),
  }) => Section(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    name: name ?? this.name,
    classTeacherId: classTeacherId.present
        ? classTeacherId.value
        : this.classTeacherId,
  );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      name: data.name.present ? data.name.value : this.name,
      classTeacherId: data.classTeacherId.present
          ? data.classTeacherId.value
          : this.classTeacherId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('classTeacherId: $classTeacherId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, name, classTeacherId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.name == this.name &&
          other.classTeacherId == this.classTeacherId);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> name;
  final Value<int?> classTeacherId;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.name = const Value.absent(),
    this.classTeacherId = const Value.absent(),
  });
  SectionsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required String name,
    this.classTeacherId = const Value.absent(),
  }) : classId = Value(classId),
       name = Value(name);
  static Insertable<Section> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? name,
    Expression<int>? classTeacherId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (name != null) 'name': name,
      if (classTeacherId != null) 'class_teacher_id': classTeacherId,
    });
  }

  SectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<String>? name,
    Value<int?>? classTeacherId,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      classTeacherId: classTeacherId ?? this.classTeacherId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (classTeacherId.present) {
      map['class_teacher_id'] = Variable<int>(classTeacherId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('classTeacherId: $classTeacherId')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _admissionNoMeta = const VerificationMeta(
    'admissionNo',
  );
  @override
  late final GeneratedColumn<String> admissionNo = GeneratedColumn<String>(
    'admission_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _registrationNoMeta = const VerificationMeta(
    'registrationNo',
  );
  @override
  late final GeneratedColumn<String> registrationNo = GeneratedColumn<String>(
    'registration_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fatherCnicMeta = const VerificationMeta(
    'fatherCnic',
  );
  @override
  late final GeneratedColumn<String> fatherCnic = GeneratedColumn<String>(
    'father_cnic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<String> dob = GeneratedColumn<String>(
    'dob',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('male'),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _whatsappNoMeta = const VerificationMeta(
    'whatsappNo',
  );
  @override
  late final GeneratedColumn<String> whatsappNo = GeneratedColumn<String>(
    'whatsapp_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fatherProfessionMeta = const VerificationMeta(
    'fatherProfession',
  );
  @override
  late final GeneratedColumn<String> fatherProfession = GeneratedColumn<String>(
    'father_profession',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fatherEducationMeta = const VerificationMeta(
    'fatherEducation',
  );
  @override
  late final GeneratedColumn<String> fatherEducation = GeneratedColumn<String>(
    'father_education',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _previousSchoolMeta = const VerificationMeta(
    'previousSchool',
  );
  @override
  late final GeneratedColumn<String> previousSchool = GeneratedColumn<String>(
    'previous_school',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _previousClassMeta = const VerificationMeta(
    'previousClass',
  );
  @override
  late final GeneratedColumn<String> previousClass = GeneratedColumn<String>(
    'previous_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_classes (id)',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
    ),
  );
  static const VerificationMeta _admissionDateMeta = const VerificationMeta(
    'admissionDate',
  );
  @override
  late final GeneratedColumn<String> admissionDate = GeneratedColumn<String>(
    'admission_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _leavingDateMeta = const VerificationMeta(
    'leavingDate',
  );
  @override
  late final GeneratedColumn<String> leavingDate = GeneratedColumn<String>(
    'leaving_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    admissionNo,
    registrationNo,
    name,
    fatherName,
    fatherCnic,
    dob,
    gender,
    phone,
    whatsappNo,
    address,
    fatherProfession,
    fatherEducation,
    previousSchool,
    previousClass,
    classId,
    sectionId,
    admissionDate,
    status,
    leavingDate,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('admission_no')) {
      context.handle(
        _admissionNoMeta,
        admissionNo.isAcceptableOrUnknown(
          data['admission_no']!,
          _admissionNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_admissionNoMeta);
    }
    if (data.containsKey('registration_no')) {
      context.handle(
        _registrationNoMeta,
        registrationNo.isAcceptableOrUnknown(
          data['registration_no']!,
          _registrationNoMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('father_cnic')) {
      context.handle(
        _fatherCnicMeta,
        fatherCnic.isAcceptableOrUnknown(data['father_cnic']!, _fatherCnicMeta),
      );
    }
    if (data.containsKey('dob')) {
      context.handle(
        _dobMeta,
        dob.isAcceptableOrUnknown(data['dob']!, _dobMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('whatsapp_no')) {
      context.handle(
        _whatsappNoMeta,
        whatsappNo.isAcceptableOrUnknown(data['whatsapp_no']!, _whatsappNoMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('father_profession')) {
      context.handle(
        _fatherProfessionMeta,
        fatherProfession.isAcceptableOrUnknown(
          data['father_profession']!,
          _fatherProfessionMeta,
        ),
      );
    }
    if (data.containsKey('father_education')) {
      context.handle(
        _fatherEducationMeta,
        fatherEducation.isAcceptableOrUnknown(
          data['father_education']!,
          _fatherEducationMeta,
        ),
      );
    }
    if (data.containsKey('previous_school')) {
      context.handle(
        _previousSchoolMeta,
        previousSchool.isAcceptableOrUnknown(
          data['previous_school']!,
          _previousSchoolMeta,
        ),
      );
    }
    if (data.containsKey('previous_class')) {
      context.handle(
        _previousClassMeta,
        previousClass.isAcceptableOrUnknown(
          data['previous_class']!,
          _previousClassMeta,
        ),
      );
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    }
    if (data.containsKey('admission_date')) {
      context.handle(
        _admissionDateMeta,
        admissionDate.isAcceptableOrUnknown(
          data['admission_date']!,
          _admissionDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('leaving_date')) {
      context.handle(
        _leavingDateMeta,
        leavingDate.isAcceptableOrUnknown(
          data['leaving_date']!,
          _leavingDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      admissionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admission_no'],
      )!,
      registrationNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_no'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      )!,
      fatherCnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_cnic'],
      )!,
      dob: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dob'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      whatsappNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whatsapp_no'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      fatherProfession: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_profession'],
      )!,
      fatherEducation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_education'],
      )!,
      previousSchool: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_school'],
      )!,
      previousClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_class'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      ),
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      ),
      admissionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admission_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      leavingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaving_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final String admissionNo;
  final String registrationNo;
  final String name;
  final String fatherName;
  final String fatherCnic;
  final String? dob;
  final String gender;
  final String phone;
  final String whatsappNo;
  final String address;
  final String fatherProfession;
  final String fatherEducation;
  final String previousSchool;
  final String previousClass;
  final int? classId;
  final int? sectionId;
  final String? admissionDate;

  /// `active` or `left`.
  final String status;
  final String? leavingDate;
  final String notes;
  final DateTime createdAt;
  const Student({
    required this.id,
    required this.admissionNo,
    required this.registrationNo,
    required this.name,
    required this.fatherName,
    required this.fatherCnic,
    this.dob,
    required this.gender,
    required this.phone,
    required this.whatsappNo,
    required this.address,
    required this.fatherProfession,
    required this.fatherEducation,
    required this.previousSchool,
    required this.previousClass,
    this.classId,
    this.sectionId,
    this.admissionDate,
    required this.status,
    this.leavingDate,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['admission_no'] = Variable<String>(admissionNo);
    map['registration_no'] = Variable<String>(registrationNo);
    map['name'] = Variable<String>(name);
    map['father_name'] = Variable<String>(fatherName);
    map['father_cnic'] = Variable<String>(fatherCnic);
    if (!nullToAbsent || dob != null) {
      map['dob'] = Variable<String>(dob);
    }
    map['gender'] = Variable<String>(gender);
    map['phone'] = Variable<String>(phone);
    map['whatsapp_no'] = Variable<String>(whatsappNo);
    map['address'] = Variable<String>(address);
    map['father_profession'] = Variable<String>(fatherProfession);
    map['father_education'] = Variable<String>(fatherEducation);
    map['previous_school'] = Variable<String>(previousSchool);
    map['previous_class'] = Variable<String>(previousClass);
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<int>(classId);
    }
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<int>(sectionId);
    }
    if (!nullToAbsent || admissionDate != null) {
      map['admission_date'] = Variable<String>(admissionDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || leavingDate != null) {
      map['leaving_date'] = Variable<String>(leavingDate);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      admissionNo: Value(admissionNo),
      registrationNo: Value(registrationNo),
      name: Value(name),
      fatherName: Value(fatherName),
      fatherCnic: Value(fatherCnic),
      dob: dob == null && nullToAbsent ? const Value.absent() : Value(dob),
      gender: Value(gender),
      phone: Value(phone),
      whatsappNo: Value(whatsappNo),
      address: Value(address),
      fatherProfession: Value(fatherProfession),
      fatherEducation: Value(fatherEducation),
      previousSchool: Value(previousSchool),
      previousClass: Value(previousClass),
      classId: classId == null && nullToAbsent
          ? const Value.absent()
          : Value(classId),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      admissionDate: admissionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(admissionDate),
      status: Value(status),
      leavingDate: leavingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(leavingDate),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      admissionNo: serializer.fromJson<String>(json['admissionNo']),
      registrationNo: serializer.fromJson<String>(json['registrationNo']),
      name: serializer.fromJson<String>(json['name']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      fatherCnic: serializer.fromJson<String>(json['fatherCnic']),
      dob: serializer.fromJson<String?>(json['dob']),
      gender: serializer.fromJson<String>(json['gender']),
      phone: serializer.fromJson<String>(json['phone']),
      whatsappNo: serializer.fromJson<String>(json['whatsappNo']),
      address: serializer.fromJson<String>(json['address']),
      fatherProfession: serializer.fromJson<String>(json['fatherProfession']),
      fatherEducation: serializer.fromJson<String>(json['fatherEducation']),
      previousSchool: serializer.fromJson<String>(json['previousSchool']),
      previousClass: serializer.fromJson<String>(json['previousClass']),
      classId: serializer.fromJson<int?>(json['classId']),
      sectionId: serializer.fromJson<int?>(json['sectionId']),
      admissionDate: serializer.fromJson<String?>(json['admissionDate']),
      status: serializer.fromJson<String>(json['status']),
      leavingDate: serializer.fromJson<String?>(json['leavingDate']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'admissionNo': serializer.toJson<String>(admissionNo),
      'registrationNo': serializer.toJson<String>(registrationNo),
      'name': serializer.toJson<String>(name),
      'fatherName': serializer.toJson<String>(fatherName),
      'fatherCnic': serializer.toJson<String>(fatherCnic),
      'dob': serializer.toJson<String?>(dob),
      'gender': serializer.toJson<String>(gender),
      'phone': serializer.toJson<String>(phone),
      'whatsappNo': serializer.toJson<String>(whatsappNo),
      'address': serializer.toJson<String>(address),
      'fatherProfession': serializer.toJson<String>(fatherProfession),
      'fatherEducation': serializer.toJson<String>(fatherEducation),
      'previousSchool': serializer.toJson<String>(previousSchool),
      'previousClass': serializer.toJson<String>(previousClass),
      'classId': serializer.toJson<int?>(classId),
      'sectionId': serializer.toJson<int?>(sectionId),
      'admissionDate': serializer.toJson<String?>(admissionDate),
      'status': serializer.toJson<String>(status),
      'leavingDate': serializer.toJson<String?>(leavingDate),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Student copyWith({
    int? id,
    String? admissionNo,
    String? registrationNo,
    String? name,
    String? fatherName,
    String? fatherCnic,
    Value<String?> dob = const Value.absent(),
    String? gender,
    String? phone,
    String? whatsappNo,
    String? address,
    String? fatherProfession,
    String? fatherEducation,
    String? previousSchool,
    String? previousClass,
    Value<int?> classId = const Value.absent(),
    Value<int?> sectionId = const Value.absent(),
    Value<String?> admissionDate = const Value.absent(),
    String? status,
    Value<String?> leavingDate = const Value.absent(),
    String? notes,
    DateTime? createdAt,
  }) => Student(
    id: id ?? this.id,
    admissionNo: admissionNo ?? this.admissionNo,
    registrationNo: registrationNo ?? this.registrationNo,
    name: name ?? this.name,
    fatherName: fatherName ?? this.fatherName,
    fatherCnic: fatherCnic ?? this.fatherCnic,
    dob: dob.present ? dob.value : this.dob,
    gender: gender ?? this.gender,
    phone: phone ?? this.phone,
    whatsappNo: whatsappNo ?? this.whatsappNo,
    address: address ?? this.address,
    fatherProfession: fatherProfession ?? this.fatherProfession,
    fatherEducation: fatherEducation ?? this.fatherEducation,
    previousSchool: previousSchool ?? this.previousSchool,
    previousClass: previousClass ?? this.previousClass,
    classId: classId.present ? classId.value : this.classId,
    sectionId: sectionId.present ? sectionId.value : this.sectionId,
    admissionDate: admissionDate.present
        ? admissionDate.value
        : this.admissionDate,
    status: status ?? this.status,
    leavingDate: leavingDate.present ? leavingDate.value : this.leavingDate,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      admissionNo: data.admissionNo.present
          ? data.admissionNo.value
          : this.admissionNo,
      registrationNo: data.registrationNo.present
          ? data.registrationNo.value
          : this.registrationNo,
      name: data.name.present ? data.name.value : this.name,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      fatherCnic: data.fatherCnic.present
          ? data.fatherCnic.value
          : this.fatherCnic,
      dob: data.dob.present ? data.dob.value : this.dob,
      gender: data.gender.present ? data.gender.value : this.gender,
      phone: data.phone.present ? data.phone.value : this.phone,
      whatsappNo: data.whatsappNo.present
          ? data.whatsappNo.value
          : this.whatsappNo,
      address: data.address.present ? data.address.value : this.address,
      fatherProfession: data.fatherProfession.present
          ? data.fatherProfession.value
          : this.fatherProfession,
      fatherEducation: data.fatherEducation.present
          ? data.fatherEducation.value
          : this.fatherEducation,
      previousSchool: data.previousSchool.present
          ? data.previousSchool.value
          : this.previousSchool,
      previousClass: data.previousClass.present
          ? data.previousClass.value
          : this.previousClass,
      classId: data.classId.present ? data.classId.value : this.classId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      admissionDate: data.admissionDate.present
          ? data.admissionDate.value
          : this.admissionDate,
      status: data.status.present ? data.status.value : this.status,
      leavingDate: data.leavingDate.present
          ? data.leavingDate.value
          : this.leavingDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('admissionNo: $admissionNo, ')
          ..write('registrationNo: $registrationNo, ')
          ..write('name: $name, ')
          ..write('fatherName: $fatherName, ')
          ..write('fatherCnic: $fatherCnic, ')
          ..write('dob: $dob, ')
          ..write('gender: $gender, ')
          ..write('phone: $phone, ')
          ..write('whatsappNo: $whatsappNo, ')
          ..write('address: $address, ')
          ..write('fatherProfession: $fatherProfession, ')
          ..write('fatherEducation: $fatherEducation, ')
          ..write('previousSchool: $previousSchool, ')
          ..write('previousClass: $previousClass, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('status: $status, ')
          ..write('leavingDate: $leavingDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    admissionNo,
    registrationNo,
    name,
    fatherName,
    fatherCnic,
    dob,
    gender,
    phone,
    whatsappNo,
    address,
    fatherProfession,
    fatherEducation,
    previousSchool,
    previousClass,
    classId,
    sectionId,
    admissionDate,
    status,
    leavingDate,
    notes,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.admissionNo == this.admissionNo &&
          other.registrationNo == this.registrationNo &&
          other.name == this.name &&
          other.fatherName == this.fatherName &&
          other.fatherCnic == this.fatherCnic &&
          other.dob == this.dob &&
          other.gender == this.gender &&
          other.phone == this.phone &&
          other.whatsappNo == this.whatsappNo &&
          other.address == this.address &&
          other.fatherProfession == this.fatherProfession &&
          other.fatherEducation == this.fatherEducation &&
          other.previousSchool == this.previousSchool &&
          other.previousClass == this.previousClass &&
          other.classId == this.classId &&
          other.sectionId == this.sectionId &&
          other.admissionDate == this.admissionDate &&
          other.status == this.status &&
          other.leavingDate == this.leavingDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<String> admissionNo;
  final Value<String> registrationNo;
  final Value<String> name;
  final Value<String> fatherName;
  final Value<String> fatherCnic;
  final Value<String?> dob;
  final Value<String> gender;
  final Value<String> phone;
  final Value<String> whatsappNo;
  final Value<String> address;
  final Value<String> fatherProfession;
  final Value<String> fatherEducation;
  final Value<String> previousSchool;
  final Value<String> previousClass;
  final Value<int?> classId;
  final Value<int?> sectionId;
  final Value<String?> admissionDate;
  final Value<String> status;
  final Value<String?> leavingDate;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.admissionNo = const Value.absent(),
    this.registrationNo = const Value.absent(),
    this.name = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.fatherCnic = const Value.absent(),
    this.dob = const Value.absent(),
    this.gender = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsappNo = const Value.absent(),
    this.address = const Value.absent(),
    this.fatherProfession = const Value.absent(),
    this.fatherEducation = const Value.absent(),
    this.previousSchool = const Value.absent(),
    this.previousClass = const Value.absent(),
    this.classId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.leavingDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required String admissionNo,
    this.registrationNo = const Value.absent(),
    required String name,
    this.fatherName = const Value.absent(),
    this.fatherCnic = const Value.absent(),
    this.dob = const Value.absent(),
    this.gender = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsappNo = const Value.absent(),
    this.address = const Value.absent(),
    this.fatherProfession = const Value.absent(),
    this.fatherEducation = const Value.absent(),
    this.previousSchool = const Value.absent(),
    this.previousClass = const Value.absent(),
    this.classId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.leavingDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : admissionNo = Value(admissionNo),
       name = Value(name);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<String>? admissionNo,
    Expression<String>? registrationNo,
    Expression<String>? name,
    Expression<String>? fatherName,
    Expression<String>? fatherCnic,
    Expression<String>? dob,
    Expression<String>? gender,
    Expression<String>? phone,
    Expression<String>? whatsappNo,
    Expression<String>? address,
    Expression<String>? fatherProfession,
    Expression<String>? fatherEducation,
    Expression<String>? previousSchool,
    Expression<String>? previousClass,
    Expression<int>? classId,
    Expression<int>? sectionId,
    Expression<String>? admissionDate,
    Expression<String>? status,
    Expression<String>? leavingDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (admissionNo != null) 'admission_no': admissionNo,
      if (registrationNo != null) 'registration_no': registrationNo,
      if (name != null) 'name': name,
      if (fatherName != null) 'father_name': fatherName,
      if (fatherCnic != null) 'father_cnic': fatherCnic,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      if (whatsappNo != null) 'whatsapp_no': whatsappNo,
      if (address != null) 'address': address,
      if (fatherProfession != null) 'father_profession': fatherProfession,
      if (fatherEducation != null) 'father_education': fatherEducation,
      if (previousSchool != null) 'previous_school': previousSchool,
      if (previousClass != null) 'previous_class': previousClass,
      if (classId != null) 'class_id': classId,
      if (sectionId != null) 'section_id': sectionId,
      if (admissionDate != null) 'admission_date': admissionDate,
      if (status != null) 'status': status,
      if (leavingDate != null) 'leaving_date': leavingDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<String>? admissionNo,
    Value<String>? registrationNo,
    Value<String>? name,
    Value<String>? fatherName,
    Value<String>? fatherCnic,
    Value<String?>? dob,
    Value<String>? gender,
    Value<String>? phone,
    Value<String>? whatsappNo,
    Value<String>? address,
    Value<String>? fatherProfession,
    Value<String>? fatherEducation,
    Value<String>? previousSchool,
    Value<String>? previousClass,
    Value<int?>? classId,
    Value<int?>? sectionId,
    Value<String?>? admissionDate,
    Value<String>? status,
    Value<String?>? leavingDate,
    Value<String>? notes,
    Value<DateTime>? createdAt,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      admissionNo: admissionNo ?? this.admissionNo,
      registrationNo: registrationNo ?? this.registrationNo,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      fatherCnic: fatherCnic ?? this.fatherCnic,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      whatsappNo: whatsappNo ?? this.whatsappNo,
      address: address ?? this.address,
      fatherProfession: fatherProfession ?? this.fatherProfession,
      fatherEducation: fatherEducation ?? this.fatherEducation,
      previousSchool: previousSchool ?? this.previousSchool,
      previousClass: previousClass ?? this.previousClass,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      admissionDate: admissionDate ?? this.admissionDate,
      status: status ?? this.status,
      leavingDate: leavingDate ?? this.leavingDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (admissionNo.present) {
      map['admission_no'] = Variable<String>(admissionNo.value);
    }
    if (registrationNo.present) {
      map['registration_no'] = Variable<String>(registrationNo.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (fatherCnic.present) {
      map['father_cnic'] = Variable<String>(fatherCnic.value);
    }
    if (dob.present) {
      map['dob'] = Variable<String>(dob.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (whatsappNo.present) {
      map['whatsapp_no'] = Variable<String>(whatsappNo.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (fatherProfession.present) {
      map['father_profession'] = Variable<String>(fatherProfession.value);
    }
    if (fatherEducation.present) {
      map['father_education'] = Variable<String>(fatherEducation.value);
    }
    if (previousSchool.present) {
      map['previous_school'] = Variable<String>(previousSchool.value);
    }
    if (previousClass.present) {
      map['previous_class'] = Variable<String>(previousClass.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (admissionDate.present) {
      map['admission_date'] = Variable<String>(admissionDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (leavingDate.present) {
      map['leaving_date'] = Variable<String>(leavingDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('admissionNo: $admissionNo, ')
          ..write('registrationNo: $registrationNo, ')
          ..write('name: $name, ')
          ..write('fatherName: $fatherName, ')
          ..write('fatherCnic: $fatherCnic, ')
          ..write('dob: $dob, ')
          ..write('gender: $gender, ')
          ..write('phone: $phone, ')
          ..write('whatsappNo: $whatsappNo, ')
          ..write('address: $address, ')
          ..write('fatherProfession: $fatherProfession, ')
          ..write('fatherEducation: $fatherEducation, ')
          ..write('previousSchool: $previousSchool, ')
          ..write('previousClass: $previousClass, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('status: $status, ')
          ..write('leavingDate: $leavingDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StudentDocumentsTable extends StudentDocuments
    with TableInfo<$StudentDocumentsTable, StudentDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, title, filePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
    );
  }

  @override
  $StudentDocumentsTable createAlias(String alias) {
    return $StudentDocumentsTable(attachedDatabase, alias);
  }
}

class StudentDocument extends DataClass implements Insertable<StudentDocument> {
  final int id;
  final int studentId;
  final String title;
  final String filePath;
  const StudentDocument({
    required this.id,
    required this.studentId,
    required this.title,
    required this.filePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    return map;
  }

  StudentDocumentsCompanion toCompanion(bool nullToAbsent) {
    return StudentDocumentsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      title: Value(title),
      filePath: Value(filePath),
    );
  }

  factory StudentDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentDocument(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
    };
  }

  StudentDocument copyWith({
    int? id,
    int? studentId,
    String? title,
    String? filePath,
  }) => StudentDocument(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    title: title ?? this.title,
    filePath: filePath ?? this.filePath,
  );
  StudentDocument copyWithCompanion(StudentDocumentsCompanion data) {
    return StudentDocument(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentDocument(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, title, filePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentDocument &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.title == this.title &&
          other.filePath == this.filePath);
}

class StudentDocumentsCompanion extends UpdateCompanion<StudentDocument> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> title;
  final Value<String> filePath;
  const StudentDocumentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
  });
  StudentDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String title,
    required String filePath,
  }) : studentId = Value(studentId),
       title = Value(title),
       filePath = Value(filePath);
  static Insertable<StudentDocument> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? title,
    Expression<String>? filePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
    });
  }

  StudentDocumentsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? title,
    Value<String>? filePath,
  }) {
    return StudentDocumentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, date, status, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, date},
  ];
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final int id;
  final int studentId;
  final String date;

  /// `present`, `absent` or `leave`.
  final String status;
  final String note;
  const AttendanceData({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    map['note'] = Variable<String>(note);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      studentId: Value(studentId),
      date: Value(date),
      status: Value(status),
      note: Value(note),
    );
  }

  factory AttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String>(note),
    };
  }

  AttendanceData copyWith({
    int? id,
    int? studentId,
    String? date,
    String? status,
    String? note,
  }) => AttendanceData(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    date: date ?? this.date,
    status: status ?? this.status,
    note: note ?? this.note,
  );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, date, status, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.status == this.status &&
          other.note == this.note);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> date;
  final Value<String> status;
  final Value<String> note;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String date,
    required String status,
    this.note = const Value.absent(),
  }) : studentId = Value(studentId),
       date = Value(date),
       status = Value(status);
  static Insertable<AttendanceData> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
    });
  }

  AttendanceCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? date,
    Value<String>? status,
    Value<String>? note,
  }) {
    return AttendanceCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $FeeStructureTable extends FeeStructure
    with TableInfo<$FeeStructureTable, FeeStructureData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeStructureTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES school_classes (id)',
    ),
  );
  static const VerificationMeta _monthlyFeeMeta = const VerificationMeta(
    'monthlyFee',
  );
  @override
  late final GeneratedColumn<int> monthlyFee = GeneratedColumn<int>(
    'monthly_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _annualFeeMeta = const VerificationMeta(
    'annualFee',
  );
  @override
  late final GeneratedColumn<int> annualFee = GeneratedColumn<int>(
    'annual_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _admissionFeeMeta = const VerificationMeta(
    'admissionFee',
  );
  @override
  late final GeneratedColumn<int> admissionFee = GeneratedColumn<int>(
    'admission_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classId,
    monthlyFee,
    annualFee,
    admissionFee,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_structure';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeeStructureData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('monthly_fee')) {
      context.handle(
        _monthlyFeeMeta,
        monthlyFee.isAcceptableOrUnknown(data['monthly_fee']!, _monthlyFeeMeta),
      );
    }
    if (data.containsKey('annual_fee')) {
      context.handle(
        _annualFeeMeta,
        annualFee.isAcceptableOrUnknown(data['annual_fee']!, _annualFeeMeta),
      );
    }
    if (data.containsKey('admission_fee')) {
      context.handle(
        _admissionFeeMeta,
        admissionFee.isAcceptableOrUnknown(
          data['admission_fee']!,
          _admissionFeeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeeStructureData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeStructureData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      monthlyFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_fee'],
      )!,
      annualFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_fee'],
      )!,
      admissionFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}admission_fee'],
      )!,
    );
  }

  @override
  $FeeStructureTable createAlias(String alias) {
    return $FeeStructureTable(attachedDatabase, alias);
  }
}

class FeeStructureData extends DataClass
    implements Insertable<FeeStructureData> {
  final int id;
  final int classId;
  final int monthlyFee;
  final int annualFee;
  final int admissionFee;
  const FeeStructureData({
    required this.id,
    required this.classId,
    required this.monthlyFee,
    required this.annualFee,
    required this.admissionFee,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['monthly_fee'] = Variable<int>(monthlyFee);
    map['annual_fee'] = Variable<int>(annualFee);
    map['admission_fee'] = Variable<int>(admissionFee);
    return map;
  }

  FeeStructureCompanion toCompanion(bool nullToAbsent) {
    return FeeStructureCompanion(
      id: Value(id),
      classId: Value(classId),
      monthlyFee: Value(monthlyFee),
      annualFee: Value(annualFee),
      admissionFee: Value(admissionFee),
    );
  }

  factory FeeStructureData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeStructureData(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      monthlyFee: serializer.fromJson<int>(json['monthlyFee']),
      annualFee: serializer.fromJson<int>(json['annualFee']),
      admissionFee: serializer.fromJson<int>(json['admissionFee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'monthlyFee': serializer.toJson<int>(monthlyFee),
      'annualFee': serializer.toJson<int>(annualFee),
      'admissionFee': serializer.toJson<int>(admissionFee),
    };
  }

  FeeStructureData copyWith({
    int? id,
    int? classId,
    int? monthlyFee,
    int? annualFee,
    int? admissionFee,
  }) => FeeStructureData(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    monthlyFee: monthlyFee ?? this.monthlyFee,
    annualFee: annualFee ?? this.annualFee,
    admissionFee: admissionFee ?? this.admissionFee,
  );
  FeeStructureData copyWithCompanion(FeeStructureCompanion data) {
    return FeeStructureData(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      monthlyFee: data.monthlyFee.present
          ? data.monthlyFee.value
          : this.monthlyFee,
      annualFee: data.annualFee.present ? data.annualFee.value : this.annualFee,
      admissionFee: data.admissionFee.present
          ? data.admissionFee.value
          : this.admissionFee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeStructureData(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('annualFee: $annualFee, ')
          ..write('admissionFee: $admissionFee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, classId, monthlyFee, annualFee, admissionFee);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeStructureData &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.monthlyFee == this.monthlyFee &&
          other.annualFee == this.annualFee &&
          other.admissionFee == this.admissionFee);
}

class FeeStructureCompanion extends UpdateCompanion<FeeStructureData> {
  final Value<int> id;
  final Value<int> classId;
  final Value<int> monthlyFee;
  final Value<int> annualFee;
  final Value<int> admissionFee;
  const FeeStructureCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.monthlyFee = const Value.absent(),
    this.annualFee = const Value.absent(),
    this.admissionFee = const Value.absent(),
  });
  FeeStructureCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    this.monthlyFee = const Value.absent(),
    this.annualFee = const Value.absent(),
    this.admissionFee = const Value.absent(),
  }) : classId = Value(classId);
  static Insertable<FeeStructureData> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<int>? monthlyFee,
    Expression<int>? annualFee,
    Expression<int>? admissionFee,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (monthlyFee != null) 'monthly_fee': monthlyFee,
      if (annualFee != null) 'annual_fee': annualFee,
      if (admissionFee != null) 'admission_fee': admissionFee,
    });
  }

  FeeStructureCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<int>? monthlyFee,
    Value<int>? annualFee,
    Value<int>? admissionFee,
  }) {
    return FeeStructureCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      annualFee: annualFee ?? this.annualFee,
      admissionFee: admissionFee ?? this.admissionFee,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (monthlyFee.present) {
      map['monthly_fee'] = Variable<int>(monthlyFee.value);
    }
    if (annualFee.present) {
      map['annual_fee'] = Variable<int>(annualFee.value);
    }
    if (admissionFee.present) {
      map['admission_fee'] = Variable<int>(admissionFee.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeStructureCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('annualFee: $annualFee, ')
          ..write('admissionFee: $admissionFee')
          ..write(')'))
        .toString();
  }
}

class $FeeVouchersTable extends FeeVouchers
    with TableInfo<$FeeVouchersTable, FeeVoucher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeVouchersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _receiptNoMeta = const VerificationMeta(
    'receiptNo',
  );
  @override
  late final GeneratedColumn<String> receiptNo = GeneratedColumn<String>(
    'receipt_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _forMonthMeta = const VerificationMeta(
    'forMonth',
  );
  @override
  late final GeneratedColumn<String> forMonth = GeneratedColumn<String>(
    'for_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyFeeMeta = const VerificationMeta(
    'monthlyFee',
  );
  @override
  late final GeneratedColumn<int> monthlyFee = GeneratedColumn<int>(
    'monthly_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _annualFeeMeta = const VerificationMeta(
    'annualFee',
  );
  @override
  late final GeneratedColumn<int> annualFee = GeneratedColumn<int>(
    'annual_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _admissionFeeMeta = const VerificationMeta(
    'admissionFee',
  );
  @override
  late final GeneratedColumn<int> admissionFee = GeneratedColumn<int>(
    'admission_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _miscFeeMeta = const VerificationMeta(
    'miscFee',
  );
  @override
  late final GeneratedColumn<int> miscFee = GeneratedColumn<int>(
    'misc_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _previousDuesMeta = const VerificationMeta(
    'previousDues',
  );
  @override
  late final GeneratedColumn<int> previousDues = GeneratedColumn<int>(
    'previous_dues',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<int> paidAmount = GeneratedColumn<int>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unpaid'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptNo,
    date,
    studentId,
    forMonth,
    monthlyFee,
    annualFee,
    admissionFee,
    miscFee,
    discount,
    previousDues,
    total,
    paidAmount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_vouchers';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeeVoucher> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receipt_no')) {
      context.handle(
        _receiptNoMeta,
        receiptNo.isAcceptableOrUnknown(data['receipt_no']!, _receiptNoMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptNoMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('for_month')) {
      context.handle(
        _forMonthMeta,
        forMonth.isAcceptableOrUnknown(data['for_month']!, _forMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_forMonthMeta);
    }
    if (data.containsKey('monthly_fee')) {
      context.handle(
        _monthlyFeeMeta,
        monthlyFee.isAcceptableOrUnknown(data['monthly_fee']!, _monthlyFeeMeta),
      );
    }
    if (data.containsKey('annual_fee')) {
      context.handle(
        _annualFeeMeta,
        annualFee.isAcceptableOrUnknown(data['annual_fee']!, _annualFeeMeta),
      );
    }
    if (data.containsKey('admission_fee')) {
      context.handle(
        _admissionFeeMeta,
        admissionFee.isAcceptableOrUnknown(
          data['admission_fee']!,
          _admissionFeeMeta,
        ),
      );
    }
    if (data.containsKey('misc_fee')) {
      context.handle(
        _miscFeeMeta,
        miscFee.isAcceptableOrUnknown(data['misc_fee']!, _miscFeeMeta),
      );
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('previous_dues')) {
      context.handle(
        _previousDuesMeta,
        previousDues.isAcceptableOrUnknown(
          data['previous_dues']!,
          _previousDuesMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeeVoucher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeVoucher(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_no'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      forMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}for_month'],
      )!,
      monthlyFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_fee'],
      )!,
      annualFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_fee'],
      )!,
      admissionFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}admission_fee'],
      )!,
      miscFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}misc_fee'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount'],
      )!,
      previousDues: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_dues'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_amount'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $FeeVouchersTable createAlias(String alias) {
    return $FeeVouchersTable(attachedDatabase, alias);
  }
}

class FeeVoucher extends DataClass implements Insertable<FeeVoucher> {
  final int id;
  final String receiptNo;
  final String date;
  final int studentId;

  /// Month the fee is for, e.g. `2026-05`.
  final String forMonth;
  final int monthlyFee;
  final int annualFee;
  final int admissionFee;
  final int miscFee;
  final int discount;
  final int previousDues;
  final int total;
  final int paidAmount;

  /// `paid`, `partial` or `unpaid`.
  final String status;
  const FeeVoucher({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.studentId,
    required this.forMonth,
    required this.monthlyFee,
    required this.annualFee,
    required this.admissionFee,
    required this.miscFee,
    required this.discount,
    required this.previousDues,
    required this.total,
    required this.paidAmount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receipt_no'] = Variable<String>(receiptNo);
    map['date'] = Variable<String>(date);
    map['student_id'] = Variable<int>(studentId);
    map['for_month'] = Variable<String>(forMonth);
    map['monthly_fee'] = Variable<int>(monthlyFee);
    map['annual_fee'] = Variable<int>(annualFee);
    map['admission_fee'] = Variable<int>(admissionFee);
    map['misc_fee'] = Variable<int>(miscFee);
    map['discount'] = Variable<int>(discount);
    map['previous_dues'] = Variable<int>(previousDues);
    map['total'] = Variable<int>(total);
    map['paid_amount'] = Variable<int>(paidAmount);
    map['status'] = Variable<String>(status);
    return map;
  }

  FeeVouchersCompanion toCompanion(bool nullToAbsent) {
    return FeeVouchersCompanion(
      id: Value(id),
      receiptNo: Value(receiptNo),
      date: Value(date),
      studentId: Value(studentId),
      forMonth: Value(forMonth),
      monthlyFee: Value(monthlyFee),
      annualFee: Value(annualFee),
      admissionFee: Value(admissionFee),
      miscFee: Value(miscFee),
      discount: Value(discount),
      previousDues: Value(previousDues),
      total: Value(total),
      paidAmount: Value(paidAmount),
      status: Value(status),
    );
  }

  factory FeeVoucher.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeVoucher(
      id: serializer.fromJson<int>(json['id']),
      receiptNo: serializer.fromJson<String>(json['receiptNo']),
      date: serializer.fromJson<String>(json['date']),
      studentId: serializer.fromJson<int>(json['studentId']),
      forMonth: serializer.fromJson<String>(json['forMonth']),
      monthlyFee: serializer.fromJson<int>(json['monthlyFee']),
      annualFee: serializer.fromJson<int>(json['annualFee']),
      admissionFee: serializer.fromJson<int>(json['admissionFee']),
      miscFee: serializer.fromJson<int>(json['miscFee']),
      discount: serializer.fromJson<int>(json['discount']),
      previousDues: serializer.fromJson<int>(json['previousDues']),
      total: serializer.fromJson<int>(json['total']),
      paidAmount: serializer.fromJson<int>(json['paidAmount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receiptNo': serializer.toJson<String>(receiptNo),
      'date': serializer.toJson<String>(date),
      'studentId': serializer.toJson<int>(studentId),
      'forMonth': serializer.toJson<String>(forMonth),
      'monthlyFee': serializer.toJson<int>(monthlyFee),
      'annualFee': serializer.toJson<int>(annualFee),
      'admissionFee': serializer.toJson<int>(admissionFee),
      'miscFee': serializer.toJson<int>(miscFee),
      'discount': serializer.toJson<int>(discount),
      'previousDues': serializer.toJson<int>(previousDues),
      'total': serializer.toJson<int>(total),
      'paidAmount': serializer.toJson<int>(paidAmount),
      'status': serializer.toJson<String>(status),
    };
  }

  FeeVoucher copyWith({
    int? id,
    String? receiptNo,
    String? date,
    int? studentId,
    String? forMonth,
    int? monthlyFee,
    int? annualFee,
    int? admissionFee,
    int? miscFee,
    int? discount,
    int? previousDues,
    int? total,
    int? paidAmount,
    String? status,
  }) => FeeVoucher(
    id: id ?? this.id,
    receiptNo: receiptNo ?? this.receiptNo,
    date: date ?? this.date,
    studentId: studentId ?? this.studentId,
    forMonth: forMonth ?? this.forMonth,
    monthlyFee: monthlyFee ?? this.monthlyFee,
    annualFee: annualFee ?? this.annualFee,
    admissionFee: admissionFee ?? this.admissionFee,
    miscFee: miscFee ?? this.miscFee,
    discount: discount ?? this.discount,
    previousDues: previousDues ?? this.previousDues,
    total: total ?? this.total,
    paidAmount: paidAmount ?? this.paidAmount,
    status: status ?? this.status,
  );
  FeeVoucher copyWithCompanion(FeeVouchersCompanion data) {
    return FeeVoucher(
      id: data.id.present ? data.id.value : this.id,
      receiptNo: data.receiptNo.present ? data.receiptNo.value : this.receiptNo,
      date: data.date.present ? data.date.value : this.date,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      forMonth: data.forMonth.present ? data.forMonth.value : this.forMonth,
      monthlyFee: data.monthlyFee.present
          ? data.monthlyFee.value
          : this.monthlyFee,
      annualFee: data.annualFee.present ? data.annualFee.value : this.annualFee,
      admissionFee: data.admissionFee.present
          ? data.admissionFee.value
          : this.admissionFee,
      miscFee: data.miscFee.present ? data.miscFee.value : this.miscFee,
      discount: data.discount.present ? data.discount.value : this.discount,
      previousDues: data.previousDues.present
          ? data.previousDues.value
          : this.previousDues,
      total: data.total.present ? data.total.value : this.total,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeVoucher(')
          ..write('id: $id, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('date: $date, ')
          ..write('studentId: $studentId, ')
          ..write('forMonth: $forMonth, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('annualFee: $annualFee, ')
          ..write('admissionFee: $admissionFee, ')
          ..write('miscFee: $miscFee, ')
          ..write('discount: $discount, ')
          ..write('previousDues: $previousDues, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receiptNo,
    date,
    studentId,
    forMonth,
    monthlyFee,
    annualFee,
    admissionFee,
    miscFee,
    discount,
    previousDues,
    total,
    paidAmount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeVoucher &&
          other.id == this.id &&
          other.receiptNo == this.receiptNo &&
          other.date == this.date &&
          other.studentId == this.studentId &&
          other.forMonth == this.forMonth &&
          other.monthlyFee == this.monthlyFee &&
          other.annualFee == this.annualFee &&
          other.admissionFee == this.admissionFee &&
          other.miscFee == this.miscFee &&
          other.discount == this.discount &&
          other.previousDues == this.previousDues &&
          other.total == this.total &&
          other.paidAmount == this.paidAmount &&
          other.status == this.status);
}

class FeeVouchersCompanion extends UpdateCompanion<FeeVoucher> {
  final Value<int> id;
  final Value<String> receiptNo;
  final Value<String> date;
  final Value<int> studentId;
  final Value<String> forMonth;
  final Value<int> monthlyFee;
  final Value<int> annualFee;
  final Value<int> admissionFee;
  final Value<int> miscFee;
  final Value<int> discount;
  final Value<int> previousDues;
  final Value<int> total;
  final Value<int> paidAmount;
  final Value<String> status;
  const FeeVouchersCompanion({
    this.id = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.date = const Value.absent(),
    this.studentId = const Value.absent(),
    this.forMonth = const Value.absent(),
    this.monthlyFee = const Value.absent(),
    this.annualFee = const Value.absent(),
    this.admissionFee = const Value.absent(),
    this.miscFee = const Value.absent(),
    this.discount = const Value.absent(),
    this.previousDues = const Value.absent(),
    this.total = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.status = const Value.absent(),
  });
  FeeVouchersCompanion.insert({
    this.id = const Value.absent(),
    required String receiptNo,
    required String date,
    required int studentId,
    required String forMonth,
    this.monthlyFee = const Value.absent(),
    this.annualFee = const Value.absent(),
    this.admissionFee = const Value.absent(),
    this.miscFee = const Value.absent(),
    this.discount = const Value.absent(),
    this.previousDues = const Value.absent(),
    this.total = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.status = const Value.absent(),
  }) : receiptNo = Value(receiptNo),
       date = Value(date),
       studentId = Value(studentId),
       forMonth = Value(forMonth);
  static Insertable<FeeVoucher> custom({
    Expression<int>? id,
    Expression<String>? receiptNo,
    Expression<String>? date,
    Expression<int>? studentId,
    Expression<String>? forMonth,
    Expression<int>? monthlyFee,
    Expression<int>? annualFee,
    Expression<int>? admissionFee,
    Expression<int>? miscFee,
    Expression<int>? discount,
    Expression<int>? previousDues,
    Expression<int>? total,
    Expression<int>? paidAmount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (date != null) 'date': date,
      if (studentId != null) 'student_id': studentId,
      if (forMonth != null) 'for_month': forMonth,
      if (monthlyFee != null) 'monthly_fee': monthlyFee,
      if (annualFee != null) 'annual_fee': annualFee,
      if (admissionFee != null) 'admission_fee': admissionFee,
      if (miscFee != null) 'misc_fee': miscFee,
      if (discount != null) 'discount': discount,
      if (previousDues != null) 'previous_dues': previousDues,
      if (total != null) 'total': total,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (status != null) 'status': status,
    });
  }

  FeeVouchersCompanion copyWith({
    Value<int>? id,
    Value<String>? receiptNo,
    Value<String>? date,
    Value<int>? studentId,
    Value<String>? forMonth,
    Value<int>? monthlyFee,
    Value<int>? annualFee,
    Value<int>? admissionFee,
    Value<int>? miscFee,
    Value<int>? discount,
    Value<int>? previousDues,
    Value<int>? total,
    Value<int>? paidAmount,
    Value<String>? status,
  }) {
    return FeeVouchersCompanion(
      id: id ?? this.id,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      studentId: studentId ?? this.studentId,
      forMonth: forMonth ?? this.forMonth,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      annualFee: annualFee ?? this.annualFee,
      admissionFee: admissionFee ?? this.admissionFee,
      miscFee: miscFee ?? this.miscFee,
      discount: discount ?? this.discount,
      previousDues: previousDues ?? this.previousDues,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receiptNo.present) {
      map['receipt_no'] = Variable<String>(receiptNo.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (forMonth.present) {
      map['for_month'] = Variable<String>(forMonth.value);
    }
    if (monthlyFee.present) {
      map['monthly_fee'] = Variable<int>(monthlyFee.value);
    }
    if (annualFee.present) {
      map['annual_fee'] = Variable<int>(annualFee.value);
    }
    if (admissionFee.present) {
      map['admission_fee'] = Variable<int>(admissionFee.value);
    }
    if (miscFee.present) {
      map['misc_fee'] = Variable<int>(miscFee.value);
    }
    if (discount.present) {
      map['discount'] = Variable<int>(discount.value);
    }
    if (previousDues.present) {
      map['previous_dues'] = Variable<int>(previousDues.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<int>(paidAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeVouchersCompanion(')
          ..write('id: $id, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('date: $date, ')
          ..write('studentId: $studentId, ')
          ..write('forMonth: $forMonth, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('annualFee: $annualFee, ')
          ..write('admissionFee: $admissionFee, ')
          ..write('miscFee: $miscFee, ')
          ..write('discount: $discount, ')
          ..write('previousDues: $previousDues, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, Exam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_classes (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, classId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class Exam extends DataClass implements Insertable<Exam> {
  final int id;
  final String name;
  final int classId;
  final String? date;
  const Exam({
    required this.id,
    required this.name,
    required this.classId,
    this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['class_id'] = Variable<int>(classId);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      id: Value(id),
      name: Value(name),
      classId: Value(classId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
    );
  }

  factory Exam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exam(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      classId: serializer.fromJson<int>(json['classId']),
      date: serializer.fromJson<String?>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'classId': serializer.toJson<int>(classId),
      'date': serializer.toJson<String?>(date),
    };
  }

  Exam copyWith({
    int? id,
    String? name,
    int? classId,
    Value<String?> date = const Value.absent(),
  }) => Exam(
    id: id ?? this.id,
    name: name ?? this.name,
    classId: classId ?? this.classId,
    date: date.present ? date.value : this.date,
  );
  Exam copyWithCompanion(ExamsCompanion data) {
    return Exam(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      classId: data.classId.present ? data.classId.value : this.classId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exam(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('classId: $classId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, classId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exam &&
          other.id == this.id &&
          other.name == this.name &&
          other.classId == this.classId &&
          other.date == this.date);
}

class ExamsCompanion extends UpdateCompanion<Exam> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> classId;
  final Value<String?> date;
  const ExamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.classId = const Value.absent(),
    this.date = const Value.absent(),
  });
  ExamsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int classId,
    this.date = const Value.absent(),
  }) : name = Value(name),
       classId = Value(classId);
  static Insertable<Exam> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? classId,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (classId != null) 'class_id': classId,
      if (date != null) 'date': date,
    });
  }

  ExamsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? classId,
    Value<String?>? date,
  }) {
    return ExamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      classId: classId ?? this.classId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('classId: $classId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_classes (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMarksMeta = const VerificationMeta(
    'totalMarks',
  );
  @override
  late final GeneratedColumn<int> totalMarks = GeneratedColumn<int>(
    'total_marks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  @override
  List<GeneratedColumn> get $columns => [id, classId, name, totalMarks];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_marks')) {
      context.handle(
        _totalMarksMeta,
        totalMarks.isAcceptableOrUnknown(data['total_marks']!, _totalMarksMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      totalMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_marks'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final int classId;
  final String name;
  final int totalMarks;
  const Subject({
    required this.id,
    required this.classId,
    required this.name,
    required this.totalMarks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['name'] = Variable<String>(name);
    map['total_marks'] = Variable<int>(totalMarks);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      classId: Value(classId),
      name: Value(name),
      totalMarks: Value(totalMarks),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      name: serializer.fromJson<String>(json['name']),
      totalMarks: serializer.fromJson<int>(json['totalMarks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'name': serializer.toJson<String>(name),
      'totalMarks': serializer.toJson<int>(totalMarks),
    };
  }

  Subject copyWith({int? id, int? classId, String? name, int? totalMarks}) =>
      Subject(
        id: id ?? this.id,
        classId: classId ?? this.classId,
        name: name ?? this.name,
        totalMarks: totalMarks ?? this.totalMarks,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      name: data.name.present ? data.name.value : this.name,
      totalMarks: data.totalMarks.present
          ? data.totalMarks.value
          : this.totalMarks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('totalMarks: $totalMarks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, name, totalMarks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.name == this.name &&
          other.totalMarks == this.totalMarks);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> name;
  final Value<int> totalMarks;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.name = const Value.absent(),
    this.totalMarks = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required String name,
    this.totalMarks = const Value.absent(),
  }) : classId = Value(classId),
       name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? name,
    Expression<int>? totalMarks,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (name != null) 'name': name,
      if (totalMarks != null) 'total_marks': totalMarks,
    });
  }

  SubjectsCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<String>? name,
    Value<int>? totalMarks,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      totalMarks: totalMarks ?? this.totalMarks,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalMarks.present) {
      map['total_marks'] = Variable<int>(totalMarks.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('totalMarks: $totalMarks')
          ..write(')'))
        .toString();
  }
}

class $ResultsTable extends Results with TableInfo<$ResultsTable, Result> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exams (id)',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _obtainedMarksMeta = const VerificationMeta(
    'obtainedMarks',
  );
  @override
  late final GeneratedColumn<int> obtainedMarks = GeneratedColumn<int>(
    'obtained_marks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    studentId,
    subjectId,
    obtainedMarks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'results';
  @override
  VerificationContext validateIntegrity(
    Insertable<Result> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('obtained_marks')) {
      context.handle(
        _obtainedMarksMeta,
        obtainedMarks.isAcceptableOrUnknown(
          data['obtained_marks']!,
          _obtainedMarksMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Result map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Result(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      obtainedMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}obtained_marks'],
      )!,
    );
  }

  @override
  $ResultsTable createAlias(String alias) {
    return $ResultsTable(attachedDatabase, alias);
  }
}

class Result extends DataClass implements Insertable<Result> {
  final int id;
  final int examId;
  final int studentId;
  final int subjectId;
  final int obtainedMarks;
  const Result({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.subjectId,
    required this.obtainedMarks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<int>(examId);
    map['student_id'] = Variable<int>(studentId);
    map['subject_id'] = Variable<int>(subjectId);
    map['obtained_marks'] = Variable<int>(obtainedMarks);
    return map;
  }

  ResultsCompanion toCompanion(bool nullToAbsent) {
    return ResultsCompanion(
      id: Value(id),
      examId: Value(examId),
      studentId: Value(studentId),
      subjectId: Value(subjectId),
      obtainedMarks: Value(obtainedMarks),
    );
  }

  factory Result.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Result(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<int>(json['examId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      obtainedMarks: serializer.fromJson<int>(json['obtainedMarks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<int>(examId),
      'studentId': serializer.toJson<int>(studentId),
      'subjectId': serializer.toJson<int>(subjectId),
      'obtainedMarks': serializer.toJson<int>(obtainedMarks),
    };
  }

  Result copyWith({
    int? id,
    int? examId,
    int? studentId,
    int? subjectId,
    int? obtainedMarks,
  }) => Result(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    studentId: studentId ?? this.studentId,
    subjectId: subjectId ?? this.subjectId,
    obtainedMarks: obtainedMarks ?? this.obtainedMarks,
  );
  Result copyWithCompanion(ResultsCompanion data) {
    return Result(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      obtainedMarks: data.obtainedMarks.present
          ? data.obtainedMarks.value
          : this.obtainedMarks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Result(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('studentId: $studentId, ')
          ..write('subjectId: $subjectId, ')
          ..write('obtainedMarks: $obtainedMarks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, examId, studentId, subjectId, obtainedMarks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Result &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.studentId == this.studentId &&
          other.subjectId == this.subjectId &&
          other.obtainedMarks == this.obtainedMarks);
}

class ResultsCompanion extends UpdateCompanion<Result> {
  final Value<int> id;
  final Value<int> examId;
  final Value<int> studentId;
  final Value<int> subjectId;
  final Value<int> obtainedMarks;
  const ResultsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.obtainedMarks = const Value.absent(),
  });
  ResultsCompanion.insert({
    this.id = const Value.absent(),
    required int examId,
    required int studentId,
    required int subjectId,
    this.obtainedMarks = const Value.absent(),
  }) : examId = Value(examId),
       studentId = Value(studentId),
       subjectId = Value(subjectId);
  static Insertable<Result> custom({
    Expression<int>? id,
    Expression<int>? examId,
    Expression<int>? studentId,
    Expression<int>? subjectId,
    Expression<int>? obtainedMarks,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (studentId != null) 'student_id': studentId,
      if (subjectId != null) 'subject_id': subjectId,
      if (obtainedMarks != null) 'obtained_marks': obtainedMarks,
    });
  }

  ResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? examId,
    Value<int>? studentId,
    Value<int>? subjectId,
    Value<int>? obtainedMarks,
  }) {
    return ResultsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (obtainedMarks.present) {
      map['obtained_marks'] = Variable<int>(obtainedMarks.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResultsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('studentId: $studentId, ')
          ..write('subjectId: $subjectId, ')
          ..write('obtainedMarks: $obtainedMarks')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchoolClassesTable schoolClasses = $SchoolClassesTable(this);
  late final $StaffTable staff = $StaffTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $StudentDocumentsTable studentDocuments = $StudentDocumentsTable(
    this,
  );
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $FeeStructureTable feeStructure = $FeeStructureTable(this);
  late final $FeeVouchersTable feeVouchers = $FeeVouchersTable(this);
  late final $ExamsTable exams = $ExamsTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ResultsTable results = $ResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schoolClasses,
    staff,
    sections,
    appSettings,
    students,
    studentDocuments,
    attendance,
    feeStructure,
    feeVouchers,
    exams,
    subjects,
    results,
  ];
}

typedef $$SchoolClassesTableCreateCompanionBuilder =
    SchoolClassesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sortOrder,
    });
typedef $$SchoolClassesTableUpdateCompanionBuilder =
    SchoolClassesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sortOrder,
    });

final class $$SchoolClassesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SchoolClassesTable, SchoolClassesData> {
  $$SchoolClassesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SectionsTable, List<Section>> _sectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sections,
    aliasName: 'school_classes__id__sections__class_id',
  );

  $$SectionsTableProcessedTableManager get sectionsRefs {
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudentsTable, List<Student>> _studentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.students,
    aliasName: 'school_classes__id__students__class_id',
  );

  $$StudentsTableProcessedTableManager get studentsRefs {
    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeeStructureTable, List<FeeStructureData>>
  _feeStructureRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feeStructure,
    aliasName: 'school_classes__id__fee_structure__class_id',
  );

  $$FeeStructureTableProcessedTableManager get feeStructureRefs {
    final manager = $$FeeStructureTableTableManager(
      $_db,
      $_db.feeStructure,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_feeStructureRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamsTable, List<Exam>> _examsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exams,
    aliasName: 'school_classes__id__exams__class_id',
  );

  $$ExamsTableProcessedTableManager get examsRefs {
    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubjectsTable, List<Subject>> _subjectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.subjects,
    aliasName: 'school_classes__id__subjects__class_id',
  );

  $$SubjectsTableProcessedTableManager get subjectsRefs {
    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SchoolClassesTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolClassesTable> {
  $$SchoolClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sectionsRefs(
    Expression<bool> Function($$SectionsTableFilterComposer f) f,
  ) {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studentsRefs(
    Expression<bool> Function($$StudentsTableFilterComposer f) f,
  ) {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feeStructureRefs(
    Expression<bool> Function($$FeeStructureTableFilterComposer f) f,
  ) {
    final $$FeeStructureTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeStructure,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeeStructureTableFilterComposer(
            $db: $db,
            $table: $db.feeStructure,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examsRefs(
    Expression<bool> Function($$ExamsTableFilterComposer f) f,
  ) {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subjectsRefs(
    Expression<bool> Function($$SubjectsTableFilterComposer f) f,
  ) {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchoolClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolClassesTable> {
  $$SchoolClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolClassesTable> {
  $$SchoolClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> sectionsRefs<T extends Object>(
    Expression<T> Function($$SectionsTableAnnotationComposer a) f,
  ) {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> studentsRefs<T extends Object>(
    Expression<T> Function($$StudentsTableAnnotationComposer a) f,
  ) {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feeStructureRefs<T extends Object>(
    Expression<T> Function($$FeeStructureTableAnnotationComposer a) f,
  ) {
    final $$FeeStructureTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeStructure,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeeStructureTableAnnotationComposer(
            $db: $db,
            $table: $db.feeStructure,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examsRefs<T extends Object>(
    Expression<T> Function($$ExamsTableAnnotationComposer a) f,
  ) {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subjectsRefs<T extends Object>(
    Expression<T> Function($$SubjectsTableAnnotationComposer a) f,
  ) {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.classId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchoolClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolClassesTable,
          SchoolClassesData,
          $$SchoolClassesTableFilterComposer,
          $$SchoolClassesTableOrderingComposer,
          $$SchoolClassesTableAnnotationComposer,
          $$SchoolClassesTableCreateCompanionBuilder,
          $$SchoolClassesTableUpdateCompanionBuilder,
          (SchoolClassesData, $$SchoolClassesTableReferences),
          SchoolClassesData,
          PrefetchHooks Function({
            bool sectionsRefs,
            bool studentsRefs,
            bool feeStructureRefs,
            bool examsRefs,
            bool subjectsRefs,
          })
        > {
  $$SchoolClassesTableTableManager(_$AppDatabase db, $SchoolClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SchoolClassesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
              }) => SchoolClassesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchoolClassesTable, SchoolClassesData>(table),
                  $$SchoolClassesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sectionsRefs = false,
                studentsRefs = false,
                feeStructureRefs = false,
                examsRefs = false,
                subjectsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sectionsRefs) db.sections,
                    if (studentsRefs) db.students,
                    if (feeStructureRefs) db.feeStructure,
                    if (examsRefs) db.exams,
                    if (subjectsRefs) db.subjects,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sectionsRefs)
                        await $_getPrefetchedData<
                          SchoolClassesData,
                          $SchoolClassesTable,
                          Section
                        >(
                          currentTable: table,
                          referencedTable: $$SchoolClassesTableReferences
                              ._sectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).sectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studentsRefs)
                        await $_getPrefetchedData<
                          SchoolClassesData,
                          $SchoolClassesTable,
                          Student
                        >(
                          currentTable: table,
                          referencedTable: $$SchoolClassesTableReferences
                              ._studentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).studentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feeStructureRefs)
                        await $_getPrefetchedData<
                          SchoolClassesData,
                          $SchoolClassesTable,
                          FeeStructureData
                        >(
                          currentTable: table,
                          referencedTable: $$SchoolClassesTableReferences
                              ._feeStructureRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).feeStructureRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examsRefs)
                        await $_getPrefetchedData<
                          SchoolClassesData,
                          $SchoolClassesTable,
                          Exam
                        >(
                          currentTable: table,
                          referencedTable: $$SchoolClassesTableReferences
                              ._examsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).examsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (subjectsRefs)
                        await $_getPrefetchedData<
                          SchoolClassesData,
                          $SchoolClassesTable,
                          Subject
                        >(
                          currentTable: table,
                          referencedTable: $$SchoolClassesTableReferences
                              ._subjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).subjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.classId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SchoolClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolClassesTable,
      SchoolClassesData,
      $$SchoolClassesTableFilterComposer,
      $$SchoolClassesTableOrderingComposer,
      $$SchoolClassesTableAnnotationComposer,
      $$SchoolClassesTableCreateCompanionBuilder,
      $$SchoolClassesTableUpdateCompanionBuilder,
      (SchoolClassesData, $$SchoolClassesTableReferences),
      SchoolClassesData,
      PrefetchHooks Function({
        bool sectionsRefs,
        bool studentsRefs,
        bool feeStructureRefs,
        bool examsRefs,
        bool subjectsRefs,
      })
    >;
typedef $$StaffTableCreateCompanionBuilder = StaffCompanion Function({
  Value<int> id,
  required String name,
  Value<String> fatherName,
  Value<String> designation,
  Value<String> phone,
  Value<String> cnic,
  Value<String?> joiningDate,
  Value<int> salary,
  Value<String> address,
  Value<bool> isActive,
});
typedef $$StaffTableUpdateCompanionBuilder = StaffCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> fatherName,
  Value<String> designation,
  Value<String> phone,
  Value<String> cnic,
  Value<String?> joiningDate,
  Value<int> salary,
  Value<String> address,
  Value<bool> isActive,
});

final class $$StaffTableReferences
    extends BaseReferences<_$AppDatabase, $StaffTable, StaffData> {
  $$StaffTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SectionsTable, List<Section>> _sectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sections,
    aliasName: 'staff__id__sections__class_teacher_id',
  );

  $$SectionsTableProcessedTableManager get sectionsRefs {
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.classTeacherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StaffTableFilterComposer extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnic => $composableBuilder(
    column: $table.cnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sectionsRefs(
    Expression<bool> Function($$SectionsTableFilterComposer f) f,
  ) {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.classTeacherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StaffTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnic => $composableBuilder(
    column: $table.cnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get cnic =>
      $composableBuilder(column: $table.cnic, builder: (column) => column);

  GeneratedColumn<String> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> sectionsRefs<T extends Object>(
    Expression<T> Function($$SectionsTableAnnotationComposer a) f,
  ) {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.classTeacherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StaffTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffTable,
          StaffData,
          $$StaffTableFilterComposer,
          $$StaffTableOrderingComposer,
          $$StaffTableAnnotationComposer,
          $$StaffTableCreateCompanionBuilder,
          $$StaffTableUpdateCompanionBuilder,
          (StaffData, $$StaffTableReferences),
          StaffData,
          PrefetchHooks Function({bool sectionsRefs})
        > {
  $$StaffTableTableManager(_$AppDatabase db, $StaffTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fatherName = const Value.absent(),
                Value<String> designation = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> cnic = const Value.absent(),
                Value<String?> joiningDate = const Value.absent(),
                Value<int> salary = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => StaffCompanion(
                id: id,
                name: name,
                fatherName: fatherName,
                designation: designation,
                phone: phone,
                cnic: cnic,
                joiningDate: joiningDate,
                salary: salary,
                address: address,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> fatherName = const Value.absent(),
                Value<String> designation = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> cnic = const Value.absent(),
                Value<String?> joiningDate = const Value.absent(),
                Value<int> salary = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => StaffCompanion.insert(
                id: id,
                name: name,
                fatherName: fatherName,
                designation: designation,
                phone: phone,
                cnic: cnic,
                joiningDate: joiningDate,
                salary: salary,
                address: address,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StaffTable, StaffData>(table),
                  $$StaffTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sectionsRefs) db.sections],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sectionsRefs)
                    await $_getPrefetchedData<StaffData, $StaffTable, Section>(
                      currentTable: table,
                      referencedTable: $$StaffTableReferences
                          ._sectionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StaffTableReferences(db, table, p0).sectionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.classTeacherId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StaffTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffTable,
      StaffData,
      $$StaffTableFilterComposer,
      $$StaffTableOrderingComposer,
      $$StaffTableAnnotationComposer,
      $$StaffTableCreateCompanionBuilder,
      $$StaffTableUpdateCompanionBuilder,
      (StaffData, $$StaffTableReferences),
      StaffData,
      PrefetchHooks Function({bool sectionsRefs})
    >;
typedef $$SectionsTableCreateCompanionBuilder = SectionsCompanion Function({
  Value<int> id,
  required int classId,
  required String name,
  Value<int?> classTeacherId,
});
typedef $$SectionsTableUpdateCompanionBuilder = SectionsCompanion Function({
  Value<int> id,
  Value<int> classId,
  Value<String> name,
  Value<int?> classTeacherId,
});

final class $$SectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SectionsTable, Section> {
  $$SectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchoolClassesTable _classIdTable(_$AppDatabase db) =>
      db.schoolClasses.createAlias('sections__class_id__school_classes__id');

  $$SchoolClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$SchoolClassesTableTableManager(
      $_db,
      $_db.schoolClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StaffTable _classTeacherIdTable(_$AppDatabase db) =>
      db.staff.createAlias('sections__class_teacher_id__staff__id');

  $$StaffTableProcessedTableManager? get classTeacherId {
    final $_column = $_itemColumn<int>('class_teacher_id');
    if ($_column == null) return null;
    final manager = $$StaffTableTableManager(
      $_db,
      $_db.staff,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classTeacherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudentsTable, List<Student>> _studentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.students,
    aliasName: 'sections__id__students__section_id',
  );

  $$StudentsTableProcessedTableManager get studentsRefs {
    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolClassesTableFilterComposer get classId {
    final $$SchoolClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableFilterComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StaffTableFilterComposer get classTeacherId {
    final $$StaffTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classTeacherId,
      referencedTable: $db.staff,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffTableFilterComposer(
            $db: $db,
            $table: $db.staff,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studentsRefs(
    Expression<bool> Function($$StudentsTableFilterComposer f) f,
  ) {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolClassesTableOrderingComposer get classId {
    final $$SchoolClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableOrderingComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StaffTableOrderingComposer get classTeacherId {
    final $$StaffTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classTeacherId,
      referencedTable: $db.staff,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffTableOrderingComposer(
            $db: $db,
            $table: $db.staff,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$SchoolClassesTableAnnotationComposer get classId {
    final $$SchoolClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StaffTableAnnotationComposer get classTeacherId {
    final $$StaffTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classTeacherId,
      referencedTable: $db.staff,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffTableAnnotationComposer(
            $db: $db,
            $table: $db.staff,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studentsRefs<T extends Object>(
    Expression<T> Function($$StudentsTableAnnotationComposer a) f,
  ) {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, $$SectionsTableReferences),
          Section,
          PrefetchHooks Function({
            bool classId,
            bool classTeacherId,
            bool studentsRefs,
          })
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> classTeacherId = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                classId: classId,
                name: name,
                classTeacherId: classTeacherId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required String name,
                Value<int?> classTeacherId = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                classId: classId,
                name: name,
                classTeacherId: classTeacherId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SectionsTable, Section>(table),
                  $$SectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                classId = false,
                classTeacherId = false,
                studentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (studentsRefs) db.students],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (classId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.classId,
                            referencedTable: $$SectionsTableReferences
                                ._classIdTable(db),
                            referencedColumn: $$SectionsTableReferences
                                ._classIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (classTeacherId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.classTeacherId,
                            referencedTable: $$SectionsTableReferences
                                ._classTeacherIdTable(db),
                            referencedColumn: $$SectionsTableReferences
                                ._classTeacherIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studentsRefs)
                        await $_getPrefetchedData<
                          Section,
                          $SectionsTable,
                          Student
                        >(
                          currentTable: table,
                          referencedTable: $$SectionsTableReferences
                              ._studentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, $$SectionsTableReferences),
      Section,
      PrefetchHooks Function({
        bool classId,
        bool classTeacherId,
        bool studentsRefs,
      })
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder = StudentsCompanion Function({
  Value<int> id,
  required String admissionNo,
  Value<String> registrationNo,
  required String name,
  Value<String> fatherName,
  Value<String> fatherCnic,
  Value<String?> dob,
  Value<String> gender,
  Value<String> phone,
  Value<String> whatsappNo,
  Value<String> address,
  Value<String> fatherProfession,
  Value<String> fatherEducation,
  Value<String> previousSchool,
  Value<String> previousClass,
  Value<int?> classId,
  Value<int?> sectionId,
  Value<String?> admissionDate,
  Value<String> status,
  Value<String?> leavingDate,
  Value<String> notes,
  Value<DateTime> createdAt,
});
typedef $$StudentsTableUpdateCompanionBuilder = StudentsCompanion Function({
  Value<int> id,
  Value<String> admissionNo,
  Value<String> registrationNo,
  Value<String> name,
  Value<String> fatherName,
  Value<String> fatherCnic,
  Value<String?> dob,
  Value<String> gender,
  Value<String> phone,
  Value<String> whatsappNo,
  Value<String> address,
  Value<String> fatherProfession,
  Value<String> fatherEducation,
  Value<String> previousSchool,
  Value<String> previousClass,
  Value<int?> classId,
  Value<int?> sectionId,
  Value<String?> admissionDate,
  Value<String> status,
  Value<String?> leavingDate,
  Value<String> notes,
  Value<DateTime> createdAt,
});

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchoolClassesTable _classIdTable(_$AppDatabase db) =>
      db.schoolClasses.createAlias('students__class_id__school_classes__id');

  $$SchoolClassesTableProcessedTableManager? get classId {
    final $_column = $_itemColumn<int>('class_id');
    if ($_column == null) return null;
    final manager = $$SchoolClassesTableTableManager(
      $_db,
      $_db.schoolClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias('students__section_id__sections__id');

  $$SectionsTableProcessedTableManager? get sectionId {
    final $_column = $_itemColumn<int>('section_id');
    if ($_column == null) return null;
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudentDocumentsTable, List<StudentDocument>>
  _studentDocumentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studentDocuments,
    aliasName: 'students__id__student_documents__student_id',
  );

  $$StudentDocumentsTableProcessedTableManager get studentDocumentsRefs {
    final manager = $$StudentDocumentsTableTableManager(
      $_db,
      $_db.studentDocuments,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studentDocumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceTable, List<AttendanceData>>
  _attendanceRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendance,
    aliasName: 'students__id__attendance__student_id',
  );

  $$AttendanceTableProcessedTableManager get attendanceRefs {
    final manager = $$AttendanceTableTableManager(
      $_db,
      $_db.attendance,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeeVouchersTable, List<FeeVoucher>>
  _feeVouchersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feeVouchers,
    aliasName: 'students__id__fee_vouchers__student_id',
  );

  $$FeeVouchersTableProcessedTableManager get feeVouchersRefs {
    final manager = $$FeeVouchersTableTableManager(
      $_db,
      $_db.feeVouchers,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_feeVouchersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResultsTable, List<Result>> _resultsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.results,
    aliasName: 'students__id__results__student_id',
  );

  $$ResultsTableProcessedTableManager get resultsRefs {
    final manager = $$ResultsTableTableManager(
      $_db,
      $_db.results,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get admissionNo => $composableBuilder(
    column: $table.admissionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNo => $composableBuilder(
    column: $table.registrationNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatsappNo => $composableBuilder(
    column: $table.whatsappNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherProfession => $composableBuilder(
    column: $table.fatherProfession,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherEducation => $composableBuilder(
    column: $table.fatherEducation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousSchool => $composableBuilder(
    column: $table.previousSchool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousClass => $composableBuilder(
    column: $table.previousClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leavingDate => $composableBuilder(
    column: $table.leavingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolClassesTableFilterComposer get classId {
    final $$SchoolClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableFilterComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studentDocumentsRefs(
    Expression<bool> Function($$StudentDocumentsTableFilterComposer f) f,
  ) {
    final $$StudentDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentDocuments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.studentDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceRefs(
    Expression<bool> Function($$AttendanceTableFilterComposer f) f,
  ) {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceTableFilterComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feeVouchersRefs(
    Expression<bool> Function($$FeeVouchersTableFilterComposer f) f,
  ) {
    final $$FeeVouchersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeVouchers,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeeVouchersTableFilterComposer(
            $db: $db,
            $table: $db.feeVouchers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resultsRefs(
    Expression<bool> Function($$ResultsTableFilterComposer f) f,
  ) {
    final $$ResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableFilterComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get admissionNo => $composableBuilder(
    column: $table.admissionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNo => $composableBuilder(
    column: $table.registrationNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatsappNo => $composableBuilder(
    column: $table.whatsappNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherProfession => $composableBuilder(
    column: $table.fatherProfession,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherEducation => $composableBuilder(
    column: $table.fatherEducation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousSchool => $composableBuilder(
    column: $table.previousSchool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousClass => $composableBuilder(
    column: $table.previousClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leavingDate => $composableBuilder(
    column: $table.leavingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolClassesTableOrderingComposer get classId {
    final $$SchoolClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableOrderingComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get admissionNo => $composableBuilder(
    column: $table.admissionNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registrationNo => $composableBuilder(
    column: $table.registrationNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get whatsappNo => $composableBuilder(
    column: $table.whatsappNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get fatherProfession => $composableBuilder(
    column: $table.fatherProfession,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherEducation => $composableBuilder(
    column: $table.fatherEducation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousSchool => $composableBuilder(
    column: $table.previousSchool,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousClass => $composableBuilder(
    column: $table.previousClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get leavingDate => $composableBuilder(
    column: $table.leavingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SchoolClassesTableAnnotationComposer get classId {
    final $$SchoolClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studentDocumentsRefs<T extends Object>(
    Expression<T> Function($$StudentDocumentsTableAnnotationComposer a) f,
  ) {
    final $$StudentDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentDocuments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.studentDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceRefs<T extends Object>(
    Expression<T> Function($$AttendanceTableAnnotationComposer a) f,
  ) {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceTableAnnotationComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feeVouchersRefs<T extends Object>(
    Expression<T> Function($$FeeVouchersTableAnnotationComposer a) f,
  ) {
    final $$FeeVouchersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeVouchers,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeeVouchersTableAnnotationComposer(
            $db: $db,
            $table: $db.feeVouchers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resultsRefs<T extends Object>(
    Expression<T> Function($$ResultsTableAnnotationComposer a) f,
  ) {
    final $$ResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({
            bool classId,
            bool sectionId,
            bool studentDocumentsRefs,
            bool attendanceRefs,
            bool feeVouchersRefs,
            bool resultsRefs,
          })
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> admissionNo = const Value.absent(),
                Value<String> registrationNo = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fatherName = const Value.absent(),
                Value<String> fatherCnic = const Value.absent(),
                Value<String?> dob = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> whatsappNo = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> fatherProfession = const Value.absent(),
                Value<String> fatherEducation = const Value.absent(),
                Value<String> previousSchool = const Value.absent(),
                Value<String> previousClass = const Value.absent(),
                Value<int?> classId = const Value.absent(),
                Value<int?> sectionId = const Value.absent(),
                Value<String?> admissionDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> leavingDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                admissionNo: admissionNo,
                registrationNo: registrationNo,
                name: name,
                fatherName: fatherName,
                fatherCnic: fatherCnic,
                dob: dob,
                gender: gender,
                phone: phone,
                whatsappNo: whatsappNo,
                address: address,
                fatherProfession: fatherProfession,
                fatherEducation: fatherEducation,
                previousSchool: previousSchool,
                previousClass: previousClass,
                classId: classId,
                sectionId: sectionId,
                admissionDate: admissionDate,
                status: status,
                leavingDate: leavingDate,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String admissionNo,
                Value<String> registrationNo = const Value.absent(),
                required String name,
                Value<String> fatherName = const Value.absent(),
                Value<String> fatherCnic = const Value.absent(),
                Value<String?> dob = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> whatsappNo = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> fatherProfession = const Value.absent(),
                Value<String> fatherEducation = const Value.absent(),
                Value<String> previousSchool = const Value.absent(),
                Value<String> previousClass = const Value.absent(),
                Value<int?> classId = const Value.absent(),
                Value<int?> sectionId = const Value.absent(),
                Value<String?> admissionDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> leavingDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                admissionNo: admissionNo,
                registrationNo: registrationNo,
                name: name,
                fatherName: fatherName,
                fatherCnic: fatherCnic,
                dob: dob,
                gender: gender,
                phone: phone,
                whatsappNo: whatsappNo,
                address: address,
                fatherProfession: fatherProfession,
                fatherEducation: fatherEducation,
                previousSchool: previousSchool,
                previousClass: previousClass,
                classId: classId,
                sectionId: sectionId,
                admissionDate: admissionDate,
                status: status,
                leavingDate: leavingDate,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudentsTable, Student>(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                classId = false,
                sectionId = false,
                studentDocumentsRefs = false,
                attendanceRefs = false,
                feeVouchersRefs = false,
                resultsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studentDocumentsRefs) db.studentDocuments,
                    if (attendanceRefs) db.attendance,
                    if (feeVouchersRefs) db.feeVouchers,
                    if (resultsRefs) db.results,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (classId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.classId,
                            referencedTable: $$StudentsTableReferences
                                ._classIdTable(db),
                            referencedColumn: $$StudentsTableReferences
                                ._classIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sectionId,
                            referencedTable: $$StudentsTableReferences
                                ._sectionIdTable(db),
                            referencedColumn: $$StudentsTableReferences
                                ._sectionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studentDocumentsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          StudentDocument
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._studentDocumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentDocumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          AttendanceData
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._attendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feeVouchersRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          FeeVoucher
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._feeVouchersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).feeVouchersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resultsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Result
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._resultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).resultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({
        bool classId,
        bool sectionId,
        bool studentDocumentsRefs,
        bool attendanceRefs,
        bool feeVouchersRefs,
        bool resultsRefs,
      })
    >;
typedef $$StudentDocumentsTableCreateCompanionBuilder =
    StudentDocumentsCompanion Function({
      Value<int> id,
      required int studentId,
      required String title,
      required String filePath,
    });
typedef $$StudentDocumentsTableUpdateCompanionBuilder =
    StudentDocumentsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<String> title,
      Value<String> filePath,
    });

final class $$StudentDocumentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StudentDocumentsTable, StudentDocument> {
  $$StudentDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('student_documents__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudentDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentDocumentsTable> {
  $$StudentDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentDocumentsTable> {
  $$StudentDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentDocumentsTable> {
  $$StudentDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentDocumentsTable,
          StudentDocument,
          $$StudentDocumentsTableFilterComposer,
          $$StudentDocumentsTableOrderingComposer,
          $$StudentDocumentsTableAnnotationComposer,
          $$StudentDocumentsTableCreateCompanionBuilder,
          $$StudentDocumentsTableUpdateCompanionBuilder,
          (StudentDocument, $$StudentDocumentsTableReferences),
          StudentDocument,
          PrefetchHooks Function({bool studentId})
        > {
  $$StudentDocumentsTableTableManager(
    _$AppDatabase db,
    $StudentDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> filePath = const Value.absent(),
              }) => StudentDocumentsCompanion(
                id: id,
                studentId: studentId,
                title: title,
                filePath: filePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String title,
                required String filePath,
              }) => StudentDocumentsCompanion.insert(
                id: id,
                studentId: studentId,
                title: title,
                filePath: filePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudentDocumentsTable, StudentDocument>(table),
                  $$StudentDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $$StudentDocumentsTableReferences
                            ._studentIdTable(db),
                        referencedColumn: $$StudentDocumentsTableReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StudentDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentDocumentsTable,
      StudentDocument,
      $$StudentDocumentsTableFilterComposer,
      $$StudentDocumentsTableOrderingComposer,
      $$StudentDocumentsTableAnnotationComposer,
      $$StudentDocumentsTableCreateCompanionBuilder,
      $$StudentDocumentsTableUpdateCompanionBuilder,
      (StudentDocument, $$StudentDocumentsTableReferences),
      StudentDocument,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$AttendanceTableCreateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  required int studentId,
  required String date,
  required String status,
  Value<String> note,
});
typedef $$AttendanceTableUpdateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  Value<int> studentId,
  Value<String> date,
  Value<String> status,
  Value<String> note,
});

final class $$AttendanceTableReferences
    extends BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData> {
  $$AttendanceTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('attendance__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceTable,
          AttendanceData,
          $$AttendanceTableFilterComposer,
          $$AttendanceTableOrderingComposer,
          $$AttendanceTableAnnotationComposer,
          $$AttendanceTableCreateCompanionBuilder,
          $$AttendanceTableUpdateCompanionBuilder,
          (AttendanceData, $$AttendanceTableReferences),
          AttendanceData,
          PrefetchHooks Function({bool studentId})
        > {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => AttendanceCompanion(
                id: id,
                studentId: studentId,
                date: date,
                status: status,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String date,
                required String status,
                Value<String> note = const Value.absent(),
              }) => AttendanceCompanion.insert(
                id: id,
                studentId: studentId,
                date: date,
                status: status,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceTable, AttendanceData>(table),
                  $$AttendanceTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $$AttendanceTableReferences
                            ._studentIdTable(db),
                        referencedColumn: $$AttendanceTableReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceTable,
      AttendanceData,
      $$AttendanceTableFilterComposer,
      $$AttendanceTableOrderingComposer,
      $$AttendanceTableAnnotationComposer,
      $$AttendanceTableCreateCompanionBuilder,
      $$AttendanceTableUpdateCompanionBuilder,
      (AttendanceData, $$AttendanceTableReferences),
      AttendanceData,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$FeeStructureTableCreateCompanionBuilder =
    FeeStructureCompanion Function({
      Value<int> id,
      required int classId,
      Value<int> monthlyFee,
      Value<int> annualFee,
      Value<int> admissionFee,
    });
typedef $$FeeStructureTableUpdateCompanionBuilder =
    FeeStructureCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<int> monthlyFee,
      Value<int> annualFee,
      Value<int> admissionFee,
    });

final class $$FeeStructureTableReferences
    extends
        BaseReferences<_$AppDatabase, $FeeStructureTable, FeeStructureData> {
  $$FeeStructureTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchoolClassesTable _classIdTable(_$AppDatabase db) => db.schoolClasses
      .createAlias('fee_structure__class_id__school_classes__id');

  $$SchoolClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$SchoolClassesTableTableManager(
      $_db,
      $_db.schoolClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeeStructureTableFilterComposer
    extends Composer<_$AppDatabase, $FeeStructureTable> {
  $$FeeStructureTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualFee => $composableBuilder(
    column: $table.annualFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get admissionFee => $composableBuilder(
    column: $table.admissionFee,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolClassesTableFilterComposer get classId {
    final $$SchoolClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableFilterComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeeStructureTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeStructureTable> {
  $$FeeStructureTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualFee => $composableBuilder(
    column: $table.annualFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get admissionFee => $composableBuilder(
    column: $table.admissionFee,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolClassesTableOrderingComposer get classId {
    final $$SchoolClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableOrderingComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeeStructureTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeStructureTable> {
  $$FeeStructureTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get annualFee =>
      $composableBuilder(column: $table.annualFee, builder: (column) => column);

  GeneratedColumn<int> get admissionFee => $composableBuilder(
    column: $table.admissionFee,
    builder: (column) => column,
  );

  $$SchoolClassesTableAnnotationComposer get classId {
    final $$SchoolClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeeStructureTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeeStructureTable,
          FeeStructureData,
          $$FeeStructureTableFilterComposer,
          $$FeeStructureTableOrderingComposer,
          $$FeeStructureTableAnnotationComposer,
          $$FeeStructureTableCreateCompanionBuilder,
          $$FeeStructureTableUpdateCompanionBuilder,
          (FeeStructureData, $$FeeStructureTableReferences),
          FeeStructureData,
          PrefetchHooks Function({bool classId})
        > {
  $$FeeStructureTableTableManager(_$AppDatabase db, $FeeStructureTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeStructureTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeStructureTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeStructureTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<int> monthlyFee = const Value.absent(),
                Value<int> annualFee = const Value.absent(),
                Value<int> admissionFee = const Value.absent(),
              }) => FeeStructureCompanion(
                id: id,
                classId: classId,
                monthlyFee: monthlyFee,
                annualFee: annualFee,
                admissionFee: admissionFee,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                Value<int> monthlyFee = const Value.absent(),
                Value<int> annualFee = const Value.absent(),
                Value<int> admissionFee = const Value.absent(),
              }) => FeeStructureCompanion.insert(
                id: id,
                classId: classId,
                monthlyFee: monthlyFee,
                annualFee: annualFee,
                admissionFee: admissionFee,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeeStructureTable, FeeStructureData>(table),
                  $$FeeStructureTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (classId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.classId,
                        referencedTable: $$FeeStructureTableReferences
                            ._classIdTable(db),
                        referencedColumn: $$FeeStructureTableReferences
                            ._classIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FeeStructureTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeeStructureTable,
      FeeStructureData,
      $$FeeStructureTableFilterComposer,
      $$FeeStructureTableOrderingComposer,
      $$FeeStructureTableAnnotationComposer,
      $$FeeStructureTableCreateCompanionBuilder,
      $$FeeStructureTableUpdateCompanionBuilder,
      (FeeStructureData, $$FeeStructureTableReferences),
      FeeStructureData,
      PrefetchHooks Function({bool classId})
    >;
typedef $$FeeVouchersTableCreateCompanionBuilder =
    FeeVouchersCompanion Function({
      Value<int> id,
      required String receiptNo,
      required String date,
      required int studentId,
      required String forMonth,
      Value<int> monthlyFee,
      Value<int> annualFee,
      Value<int> admissionFee,
      Value<int> miscFee,
      Value<int> discount,
      Value<int> previousDues,
      Value<int> total,
      Value<int> paidAmount,
      Value<String> status,
    });
typedef $$FeeVouchersTableUpdateCompanionBuilder =
    FeeVouchersCompanion Function({
      Value<int> id,
      Value<String> receiptNo,
      Value<String> date,
      Value<int> studentId,
      Value<String> forMonth,
      Value<int> monthlyFee,
      Value<int> annualFee,
      Value<int> admissionFee,
      Value<int> miscFee,
      Value<int> discount,
      Value<int> previousDues,
      Value<int> total,
      Value<int> paidAmount,
      Value<String> status,
    });

final class $$FeeVouchersTableReferences
    extends BaseReferences<_$AppDatabase, $FeeVouchersTable, FeeVoucher> {
  $$FeeVouchersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('fee_vouchers__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeeVouchersTableFilterComposer
    extends Composer<_$AppDatabase, $FeeVouchersTable> {
  $$FeeVouchersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forMonth => $composableBuilder(
    column: $table.forMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualFee => $composableBuilder(
    column: $table.annualFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get admissionFee => $composableBuilder(
    column: $table.admissionFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get miscFee => $composableBuilder(
    column: $table.miscFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousDues => $composableBuilder(
    column: $table.previousDues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeeVouchersTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeVouchersTable> {
  $$FeeVouchersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forMonth => $composableBuilder(
    column: $table.forMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualFee => $composableBuilder(
    column: $table.annualFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get admissionFee => $composableBuilder(
    column: $table.admissionFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get miscFee => $composableBuilder(
    column: $table.miscFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousDues => $composableBuilder(
    column: $table.previousDues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeeVouchersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeVouchersTable> {
  $$FeeVouchersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get receiptNo =>
      $composableBuilder(column: $table.receiptNo, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get forMonth =>
      $composableBuilder(column: $table.forMonth, builder: (column) => column);

  GeneratedColumn<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get annualFee =>
      $composableBuilder(column: $table.annualFee, builder: (column) => column);

  GeneratedColumn<int> get admissionFee => $composableBuilder(
    column: $table.admissionFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get miscFee =>
      $composableBuilder(column: $table.miscFee, builder: (column) => column);

  GeneratedColumn<int> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get previousDues => $composableBuilder(
    column: $table.previousDues,
    builder: (column) => column,
  );

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeeVouchersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeeVouchersTable,
          FeeVoucher,
          $$FeeVouchersTableFilterComposer,
          $$FeeVouchersTableOrderingComposer,
          $$FeeVouchersTableAnnotationComposer,
          $$FeeVouchersTableCreateCompanionBuilder,
          $$FeeVouchersTableUpdateCompanionBuilder,
          (FeeVoucher, $$FeeVouchersTableReferences),
          FeeVoucher,
          PrefetchHooks Function({bool studentId})
        > {
  $$FeeVouchersTableTableManager(_$AppDatabase db, $FeeVouchersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeVouchersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeVouchersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeVouchersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> receiptNo = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> forMonth = const Value.absent(),
                Value<int> monthlyFee = const Value.absent(),
                Value<int> annualFee = const Value.absent(),
                Value<int> admissionFee = const Value.absent(),
                Value<int> miscFee = const Value.absent(),
                Value<int> discount = const Value.absent(),
                Value<int> previousDues = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> paidAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => FeeVouchersCompanion(
                id: id,
                receiptNo: receiptNo,
                date: date,
                studentId: studentId,
                forMonth: forMonth,
                monthlyFee: monthlyFee,
                annualFee: annualFee,
                admissionFee: admissionFee,
                miscFee: miscFee,
                discount: discount,
                previousDues: previousDues,
                total: total,
                paidAmount: paidAmount,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String receiptNo,
                required String date,
                required int studentId,
                required String forMonth,
                Value<int> monthlyFee = const Value.absent(),
                Value<int> annualFee = const Value.absent(),
                Value<int> admissionFee = const Value.absent(),
                Value<int> miscFee = const Value.absent(),
                Value<int> discount = const Value.absent(),
                Value<int> previousDues = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> paidAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => FeeVouchersCompanion.insert(
                id: id,
                receiptNo: receiptNo,
                date: date,
                studentId: studentId,
                forMonth: forMonth,
                monthlyFee: monthlyFee,
                annualFee: annualFee,
                admissionFee: admissionFee,
                miscFee: miscFee,
                discount: discount,
                previousDues: previousDues,
                total: total,
                paidAmount: paidAmount,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeeVouchersTable, FeeVoucher>(table),
                  $$FeeVouchersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $$FeeVouchersTableReferences
                            ._studentIdTable(db),
                        referencedColumn: $$FeeVouchersTableReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FeeVouchersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeeVouchersTable,
      FeeVoucher,
      $$FeeVouchersTableFilterComposer,
      $$FeeVouchersTableOrderingComposer,
      $$FeeVouchersTableAnnotationComposer,
      $$FeeVouchersTableCreateCompanionBuilder,
      $$FeeVouchersTableUpdateCompanionBuilder,
      (FeeVoucher, $$FeeVouchersTableReferences),
      FeeVoucher,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$ExamsTableCreateCompanionBuilder = ExamsCompanion Function({
  Value<int> id,
  required String name,
  required int classId,
  Value<String?> date,
});
typedef $$ExamsTableUpdateCompanionBuilder = ExamsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> classId,
  Value<String?> date,
});

final class $$ExamsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamsTable, Exam> {
  $$ExamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchoolClassesTable _classIdTable(_$AppDatabase db) =>
      db.schoolClasses.createAlias('exams__class_id__school_classes__id');

  $$SchoolClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$SchoolClassesTableTableManager(
      $_db,
      $_db.schoolClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ResultsTable, List<Result>> _resultsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.results,
    aliasName: 'exams__id__results__exam_id',
  );

  $$ResultsTableProcessedTableManager get resultsRefs {
    final manager = $$ResultsTableTableManager(
      $_db,
      $_db.results,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamsTableFilterComposer extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolClassesTableFilterComposer get classId {
    final $$SchoolClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableFilterComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> resultsRefs(
    Expression<bool> Function($$ResultsTableFilterComposer f) f,
  ) {
    final $$ResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableFilterComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolClassesTableOrderingComposer get classId {
    final $$SchoolClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableOrderingComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$SchoolClassesTableAnnotationComposer get classId {
    final $$SchoolClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> resultsRefs<T extends Object>(
    Expression<T> Function($$ResultsTableAnnotationComposer a) f,
  ) {
    final $$ResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamsTable,
          Exam,
          $$ExamsTableFilterComposer,
          $$ExamsTableOrderingComposer,
          $$ExamsTableAnnotationComposer,
          $$ExamsTableCreateCompanionBuilder,
          $$ExamsTableUpdateCompanionBuilder,
          (Exam, $$ExamsTableReferences),
          Exam,
          PrefetchHooks Function({bool classId, bool resultsRefs})
        > {
  $$ExamsTableTableManager(_$AppDatabase db, $ExamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String?> date = const Value.absent(),
              }) => ExamsCompanion(
                id: id,
                name: name,
                classId: classId,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int classId,
                Value<String?> date = const Value.absent(),
              }) => ExamsCompanion.insert(
                id: id,
                name: name,
                classId: classId,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamsTable, Exam>(table),
                  $$ExamsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false, resultsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (resultsRefs) db.results],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (classId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.classId,
                        referencedTable: $$ExamsTableReferences._classIdTable(
                          db,
                        ),
                        referencedColumn: $$ExamsTableReferences
                            ._classIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (resultsRefs)
                    await $_getPrefetchedData<Exam, $ExamsTable, Result>(
                      currentTable: table,
                      referencedTable: $$ExamsTableReferences._resultsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$ExamsTableReferences(db, table, p0).resultsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.examId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamsTable,
      Exam,
      $$ExamsTableFilterComposer,
      $$ExamsTableOrderingComposer,
      $$ExamsTableAnnotationComposer,
      $$ExamsTableCreateCompanionBuilder,
      $$ExamsTableUpdateCompanionBuilder,
      (Exam, $$ExamsTableReferences),
      Exam,
      PrefetchHooks Function({bool classId, bool resultsRefs})
    >;
typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required int classId,
  required String name,
  Value<int> totalMarks,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<int> classId,
  Value<String> name,
  Value<int> totalMarks,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchoolClassesTable _classIdTable(_$AppDatabase db) =>
      db.schoolClasses.createAlias('subjects__class_id__school_classes__id');

  $$SchoolClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$SchoolClassesTableTableManager(
      $_db,
      $_db.schoolClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ResultsTable, List<Result>> _resultsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.results,
    aliasName: 'subjects__id__results__subject_id',
  );

  $$ResultsTableProcessedTableManager get resultsRefs {
    final manager = $$ResultsTableTableManager(
      $_db,
      $_db.results,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMarks => $composableBuilder(
    column: $table.totalMarks,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolClassesTableFilterComposer get classId {
    final $$SchoolClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableFilterComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> resultsRefs(
    Expression<bool> Function($$ResultsTableFilterComposer f) f,
  ) {
    final $$ResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableFilterComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMarks => $composableBuilder(
    column: $table.totalMarks,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolClassesTableOrderingComposer get classId {
    final $$SchoolClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableOrderingComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalMarks => $composableBuilder(
    column: $table.totalMarks,
    builder: (column) => column,
  );

  $$SchoolClassesTableAnnotationComposer get classId {
    final $$SchoolClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.classId,
      referencedTable: $db.schoolClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> resultsRefs<T extends Object>(
    Expression<T> Function($$ResultsTableAnnotationComposer a) f,
  ) {
    final $$ResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({bool classId, bool resultsRefs})
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> totalMarks = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                classId: classId,
                name: name,
                totalMarks: totalMarks,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required String name,
                Value<int> totalMarks = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                classId: classId,
                name: name,
                totalMarks: totalMarks,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubjectsTable, Subject>(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({classId = false, resultsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (resultsRefs) db.results],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (classId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.classId,
                        referencedTable: $$SubjectsTableReferences
                            ._classIdTable(db),
                        referencedColumn: $$SubjectsTableReferences
                            ._classIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (resultsRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable, Result>(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._resultsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubjectsTableReferences(db, table, p0).resultsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.subjectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({bool classId, bool resultsRefs})
    >;
typedef $$ResultsTableCreateCompanionBuilder = ResultsCompanion Function({
  Value<int> id,
  required int examId,
  required int studentId,
  required int subjectId,
  Value<int> obtainedMarks,
});
typedef $$ResultsTableUpdateCompanionBuilder = ResultsCompanion Function({
  Value<int> id,
  Value<int> examId,
  Value<int> studentId,
  Value<int> subjectId,
  Value<int> obtainedMarks,
});

final class $$ResultsTableReferences
    extends BaseReferences<_$AppDatabase, $ResultsTable, Result> {
  $$ResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamsTable _examIdTable(_$AppDatabase db) =>
      db.exams.createAlias('results__exam_id__exams__id');

  $$ExamsTableProcessedTableManager get examId {
    final $_column = $_itemColumn<int>('exam_id')!;

    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('results__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('results__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get obtainedMarks => $composableBuilder(
    column: $table.obtainedMarks,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamsTableFilterComposer get examId {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get obtainedMarks => $composableBuilder(
    column: $table.obtainedMarks,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamsTableOrderingComposer get examId {
    final $$ExamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableOrderingComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get obtainedMarks => $composableBuilder(
    column: $table.obtainedMarks,
    builder: (column) => column,
  );

  $$ExamsTableAnnotationComposer get examId {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResultsTable,
          Result,
          $$ResultsTableFilterComposer,
          $$ResultsTableOrderingComposer,
          $$ResultsTableAnnotationComposer,
          $$ResultsTableCreateCompanionBuilder,
          $$ResultsTableUpdateCompanionBuilder,
          (Result, $$ResultsTableReferences),
          Result,
          PrefetchHooks Function({bool examId, bool studentId, bool subjectId})
        > {
  $$ResultsTableTableManager(_$AppDatabase db, $ResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<int> obtainedMarks = const Value.absent(),
              }) => ResultsCompanion(
                id: id,
                examId: examId,
                studentId: studentId,
                subjectId: subjectId,
                obtainedMarks: obtainedMarks,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examId,
                required int studentId,
                required int subjectId,
                Value<int> obtainedMarks = const Value.absent(),
              }) => ResultsCompanion.insert(
                id: id,
                examId: examId,
                studentId: studentId,
                subjectId: subjectId,
                obtainedMarks: obtainedMarks,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResultsTable, Result>(table),
                  $$ResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({examId = false, studentId = false, subjectId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (examId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.examId,
                            referencedTable: $$ResultsTableReferences
                                ._examIdTable(db),
                            referencedColumn: $$ResultsTableReferences
                                ._examIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (studentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.studentId,
                            referencedTable: $$ResultsTableReferences
                                ._studentIdTable(db),
                            referencedColumn: $$ResultsTableReferences
                                ._studentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (subjectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$ResultsTableReferences
                                ._subjectIdTable(db),
                            referencedColumn: $$ResultsTableReferences
                                ._subjectIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResultsTable,
      Result,
      $$ResultsTableFilterComposer,
      $$ResultsTableOrderingComposer,
      $$ResultsTableAnnotationComposer,
      $$ResultsTableCreateCompanionBuilder,
      $$ResultsTableUpdateCompanionBuilder,
      (Result, $$ResultsTableReferences),
      Result,
      PrefetchHooks Function({bool examId, bool studentId, bool subjectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchoolClassesTableTableManager get schoolClasses =>
      $$SchoolClassesTableTableManager(_db, _db.schoolClasses);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db, _db.staff);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$StudentDocumentsTableTableManager get studentDocuments =>
      $$StudentDocumentsTableTableManager(_db, _db.studentDocuments);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$FeeStructureTableTableManager get feeStructure =>
      $$FeeStructureTableTableManager(_db, _db.feeStructure);
  $$FeeVouchersTableTableManager get feeVouchers =>
      $$FeeVouchersTableTableManager(_db, _db.feeVouchers);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ResultsTableTableManager get results =>
      $$ResultsTableTableManager(_db, _db.results);
}
