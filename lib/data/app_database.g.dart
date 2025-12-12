// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _securityLevelMeta =
      const VerificationMeta('securityLevel');
  @override
  late final GeneratedColumn<String> securityLevel = GeneratedColumn<String>(
      'security_level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentSiteMeta =
      const VerificationMeta('currentSite');
  @override
  late final GeneratedColumn<String> currentSite = GeneratedColumn<String>(
      'current_site', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _specializationMeta =
      const VerificationMeta('specialization');
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
      'specialization', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, email, securityLevel, currentSite, specialization];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(Insertable<AppUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('security_level')) {
      context.handle(
          _securityLevelMeta,
          securityLevel.isAcceptableOrUnknown(
              data['security_level']!, _securityLevelMeta));
    } else if (isInserting) {
      context.missing(_securityLevelMeta);
    }
    if (data.containsKey('current_site')) {
      context.handle(
          _currentSiteMeta,
          currentSite.isAcceptableOrUnknown(
              data['current_site']!, _currentSiteMeta));
    }
    if (data.containsKey('specialization')) {
      context.handle(
          _specializationMeta,
          specialization.isAcceptableOrUnknown(
              data['specialization']!, _specializationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      securityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}security_level'])!,
      currentSite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}current_site']),
      specialization: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specialization']),
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final int id;
  final String name;
  final String email;
  final String securityLevel;
  final String? currentSite;
  final String? specialization;
  const AppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.securityLevel,
      this.currentSite,
      this.specialization});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['security_level'] = Variable<String>(securityLevel);
    if (!nullToAbsent || currentSite != null) {
      map['current_site'] = Variable<String>(currentSite);
    }
    if (!nullToAbsent || specialization != null) {
      map['specialization'] = Variable<String>(specialization);
    }
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      securityLevel: Value(securityLevel),
      currentSite: currentSite == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSite),
      specialization: specialization == null && nullToAbsent
          ? const Value.absent()
          : Value(specialization),
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      securityLevel: serializer.fromJson<String>(json['securityLevel']),
      currentSite: serializer.fromJson<String?>(json['currentSite']),
      specialization: serializer.fromJson<String?>(json['specialization']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'securityLevel': serializer.toJson<String>(securityLevel),
      'currentSite': serializer.toJson<String?>(currentSite),
      'specialization': serializer.toJson<String?>(specialization),
    };
  }

  AppUser copyWith(
          {int? id,
          String? name,
          String? email,
          String? securityLevel,
          Value<String?> currentSite = const Value.absent(),
          Value<String?> specialization = const Value.absent()}) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        securityLevel: securityLevel ?? this.securityLevel,
        currentSite: currentSite.present ? currentSite.value : this.currentSite,
        specialization:
            specialization.present ? specialization.value : this.specialization,
      );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      securityLevel: data.securityLevel.present
          ? data.securityLevel.value
          : this.securityLevel,
      currentSite:
          data.currentSite.present ? data.currentSite.value : this.currentSite,
      specialization: data.specialization.present
          ? data.specialization.value
          : this.specialization,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('securityLevel: $securityLevel, ')
          ..write('currentSite: $currentSite, ')
          ..write('specialization: $specialization')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, securityLevel, currentSite, specialization);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.securityLevel == this.securityLevel &&
          other.currentSite == this.currentSite &&
          other.specialization == this.specialization);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> securityLevel;
  final Value<String?> currentSite;
  final Value<String?> specialization;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.securityLevel = const Value.absent(),
    this.currentSite = const Value.absent(),
    this.specialization = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String securityLevel,
    this.currentSite = const Value.absent(),
    this.specialization = const Value.absent(),
  })  : name = Value(name),
        email = Value(email),
        securityLevel = Value(securityLevel);
  static Insertable<AppUser> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? securityLevel,
    Expression<String>? currentSite,
    Expression<String>? specialization,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (securityLevel != null) 'security_level': securityLevel,
      if (currentSite != null) 'current_site': currentSite,
      if (specialization != null) 'specialization': specialization,
    });
  }

  AppUsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? email,
      Value<String>? securityLevel,
      Value<String?>? currentSite,
      Value<String?>? specialization}) {
    return AppUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      securityLevel: securityLevel ?? this.securityLevel,
      currentSite: currentSite ?? this.currentSite,
      specialization: specialization ?? this.specialization,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (securityLevel.present) {
      map['security_level'] = Variable<String>(securityLevel.value);
    }
    if (currentSite.present) {
      map['current_site'] = Variable<String>(currentSite.value);
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('securityLevel: $securityLevel, ')
          ..write('currentSite: $currentSite, ')
          ..write('specialization: $specialization')
          ..write(')'))
        .toString();
  }
}

class $KeyRiskConditionsTable extends KeyRiskConditions
    with TableInfo<$KeyRiskConditionsTable, KeyRiskCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyRiskConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hexIdMeta = const VerificationMeta('hexId');
  @override
  late final GeneratedColumn<String> hexId = GeneratedColumn<String>(
      'hex_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, hexId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_risk_conditions';
  @override
  VerificationContext validateIntegrity(Insertable<KeyRiskCondition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('hex_id')) {
      context.handle(
          _hexIdMeta, hexId.isAcceptableOrUnknown(data['hex_id']!, _hexIdMeta));
    } else if (isInserting) {
      context.missing(_hexIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KeyRiskCondition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyRiskCondition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      hexId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hex_id'])!,
    );
  }

  @override
  $KeyRiskConditionsTable createAlias(String alias) {
    return $KeyRiskConditionsTable(attachedDatabase, alias);
  }
}

class KeyRiskCondition extends DataClass
    implements Insertable<KeyRiskCondition> {
  final int id;
  final String name;
  final String icon;
  final String hexId;
  const KeyRiskCondition(
      {required this.id,
      required this.name,
      required this.icon,
      required this.hexId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['hex_id'] = Variable<String>(hexId);
    return map;
  }

  KeyRiskConditionsCompanion toCompanion(bool nullToAbsent) {
    return KeyRiskConditionsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      hexId: Value(hexId),
    );
  }

  factory KeyRiskCondition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyRiskCondition(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      hexId: serializer.fromJson<String>(json['hexId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'hexId': serializer.toJson<String>(hexId),
    };
  }

  KeyRiskCondition copyWith(
          {int? id, String? name, String? icon, String? hexId}) =>
      KeyRiskCondition(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        hexId: hexId ?? this.hexId,
      );
  KeyRiskCondition copyWithCompanion(KeyRiskConditionsCompanion data) {
    return KeyRiskCondition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      hexId: data.hexId.present ? data.hexId.value : this.hexId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyRiskCondition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('hexId: $hexId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, hexId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyRiskCondition &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.hexId == this.hexId);
}

class KeyRiskConditionsCompanion extends UpdateCompanion<KeyRiskCondition> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> hexId;
  const KeyRiskConditionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.hexId = const Value.absent(),
  });
  KeyRiskConditionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required String hexId,
  })  : name = Value(name),
        icon = Value(icon),
        hexId = Value(hexId);
  static Insertable<KeyRiskCondition> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? hexId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (hexId != null) 'hex_id': hexId,
    });
  }

  KeyRiskConditionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<String>? hexId}) {
    return KeyRiskConditionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      hexId: hexId ?? this.hexId,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (hexId.present) {
      map['hex_id'] = Variable<String>(hexId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyRiskConditionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('hexId: $hexId')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserLite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserLite> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLite(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserLite extends DataClass implements Insertable<UserLite> {
  final int id;
  final String name;
  const UserLite({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory UserLite.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLite(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  UserLite copyWith({int? id, String? name}) => UserLite(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  UserLite copyWithCompanion(UsersCompanion data) {
    return UserLite(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLite(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLite && other.id == this.id && other.name == this.name);
}

class UsersCompanion extends UpdateCompanion<UserLite> {
  final Value<int> id;
  final Value<String> name;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<UserLite> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  UsersCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $SitesTable extends Sites with TableInfo<$SitesTable, Site> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name, uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(Insertable<Site> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Site map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Site(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
    );
  }

  @override
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }
}

class Site extends DataClass implements Insertable<Site> {
  final int id;
  final String name;
  final String uuid;
  const Site({required this.id, required this.name, required this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['uuid'] = Variable<String>(uuid);
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      name: Value(name),
      uuid: Value(uuid),
    );
  }

  factory Site.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Site(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      uuid: serializer.fromJson<String>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'uuid': serializer.toJson<String>(uuid),
    };
  }

  Site copyWith({int? id, String? name, String? uuid}) => Site(
        id: id ?? this.id,
        name: name ?? this.name,
        uuid: uuid ?? this.uuid,
      );
  Site copyWithCompanion(SitesCompanion data) {
    return Site(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Site(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, uuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Site &&
          other.id == this.id &&
          other.name == this.name &&
          other.uuid == this.uuid);
}

class SitesCompanion extends UpdateCompanion<Site> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> uuid;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  SitesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String uuid,
  })  : name = Value(name),
        uuid = Value(uuid);
  static Insertable<Site> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (uuid != null) 'uuid': uuid,
    });
  }

  SitesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? uuid}) {
    return SitesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
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
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
      'site_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sites (id)'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name, siteId, uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(Insertable<Location> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}site_id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final int id;
  final String name;
  final int siteId;
  final String uuid;
  const Location(
      {required this.id,
      required this.name,
      required this.siteId,
      required this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['site_id'] = Variable<int>(siteId);
    map['uuid'] = Variable<String>(uuid);
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      siteId: Value(siteId),
      uuid: Value(uuid),
    );
  }

  factory Location.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      siteId: serializer.fromJson<int>(json['siteId']),
      uuid: serializer.fromJson<String>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'siteId': serializer.toJson<int>(siteId),
      'uuid': serializer.toJson<String>(uuid),
    };
  }

  Location copyWith({int? id, String? name, int? siteId, String? uuid}) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
        siteId: siteId ?? this.siteId,
        uuid: uuid ?? this.uuid,
      );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('siteId: $siteId, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, siteId, uuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.name == this.name &&
          other.siteId == this.siteId &&
          other.uuid == this.uuid);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> siteId;
  final Value<String> uuid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.siteId = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  LocationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int siteId,
    required String uuid,
  })  : name = Value(name),
        siteId = Value(siteId),
        uuid = Value(uuid);
  static Insertable<Location> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? siteId,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (siteId != null) 'site_id': siteId,
      if (uuid != null) 'uuid': uuid,
    });
  }

  LocationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? siteId,
      Value<String>? uuid}) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      siteId: siteId ?? this.siteId,
      uuid: uuid ?? this.uuid,
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
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('siteId: $siteId, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

class $SafetyCardsTable extends SafetyCards
    with TableInfo<$SafetyCardsTable, SafetyCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafetyCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _imageDataMeta =
      const VerificationMeta('imageData');
  @override
  late final GeneratedColumn<Uint8List> imageData = GeneratedColumn<Uint8List>(
      'image_data', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _imageListBase64Meta =
      const VerificationMeta('imageListBase64');
  @override
  late final GeneratedColumn<String> imageListBase64 = GeneratedColumn<String>(
      'image_list_base64', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keyRiskConditionIdMeta =
      const VerificationMeta('keyRiskConditionId');
  @override
  late final GeneratedColumn<int> keyRiskConditionId = GeneratedColumn<int>(
      'key_risk_condition_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES key_risk_conditions (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _raisedByIdMeta =
      const VerificationMeta('raisedById');
  @override
  late final GeneratedColumn<int> raisedById = GeneratedColumn<int>(
      'raised_by_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
      'site_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sites (id)'));
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<int> locationId = GeneratedColumn<int>(
      'location_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES locations (id)'));
  static const VerificationMeta _safetyStatusMeta =
      const VerificationMeta('safetyStatus');
  @override
  late final GeneratedColumn<String> safetyStatus = GeneratedColumn<String>(
      'safety_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Open'));
  static const VerificationMeta _observationMeta =
      const VerificationMeta('observation');
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
      'observation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionTakenMeta =
      const VerificationMeta('actionTaken');
  @override
  late final GeneratedColumn<String> actionTaken = GeneratedColumn<String>(
      'action_taken', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personResponsibleIdMeta =
      const VerificationMeta('personResponsibleId');
  @override
  late final GeneratedColumn<int> personResponsibleId = GeneratedColumn<int>(
      'person_responsible_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _adminModifiedMeta =
      const VerificationMeta('adminModified');
  @override
  late final GeneratedColumn<bool> adminModified = GeneratedColumn<bool>(
      'admin_modified', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("admin_modified" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        imageData,
        imageListBase64,
        keyRiskConditionId,
        date,
        time,
        raisedById,
        department,
        siteId,
        locationId,
        safetyStatus,
        status,
        observation,
        actionTaken,
        personResponsibleId,
        filePath,
        adminModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safety_cards';
  @override
  VerificationContext validateIntegrity(Insertable<SafetyCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('image_data')) {
      context.handle(_imageDataMeta,
          imageData.isAcceptableOrUnknown(data['image_data']!, _imageDataMeta));
    }
    if (data.containsKey('image_list_base64')) {
      context.handle(
          _imageListBase64Meta,
          imageListBase64.isAcceptableOrUnknown(
              data['image_list_base64']!, _imageListBase64Meta));
    }
    if (data.containsKey('key_risk_condition_id')) {
      context.handle(
          _keyRiskConditionIdMeta,
          keyRiskConditionId.isAcceptableOrUnknown(
              data['key_risk_condition_id']!, _keyRiskConditionIdMeta));
    } else if (isInserting) {
      context.missing(_keyRiskConditionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('raised_by_id')) {
      context.handle(
          _raisedByIdMeta,
          raisedById.isAcceptableOrUnknown(
              data['raised_by_id']!, _raisedByIdMeta));
    } else if (isInserting) {
      context.missing(_raisedByIdMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    } else if (isInserting) {
      context.missing(_departmentMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('safety_status')) {
      context.handle(
          _safetyStatusMeta,
          safetyStatus.isAcceptableOrUnknown(
              data['safety_status']!, _safetyStatusMeta));
    } else if (isInserting) {
      context.missing(_safetyStatusMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('observation')) {
      context.handle(
          _observationMeta,
          observation.isAcceptableOrUnknown(
              data['observation']!, _observationMeta));
    } else if (isInserting) {
      context.missing(_observationMeta);
    }
    if (data.containsKey('action_taken')) {
      context.handle(
          _actionTakenMeta,
          actionTaken.isAcceptableOrUnknown(
              data['action_taken']!, _actionTakenMeta));
    } else if (isInserting) {
      context.missing(_actionTakenMeta);
    }
    if (data.containsKey('person_responsible_id')) {
      context.handle(
          _personResponsibleIdMeta,
          personResponsibleId.isAcceptableOrUnknown(
              data['person_responsible_id']!, _personResponsibleIdMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('admin_modified')) {
      context.handle(
          _adminModifiedMeta,
          adminModified.isAcceptableOrUnknown(
              data['admin_modified']!, _adminModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SafetyCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafetyCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      imageData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}image_data']),
      imageListBase64: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}image_list_base64']),
      keyRiskConditionId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}key_risk_condition_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      raisedById: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}raised_by_id'])!,
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department'])!,
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}site_id'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}location_id'])!,
      safetyStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}safety_status'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      observation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observation'])!,
      actionTaken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_taken'])!,
      personResponsibleId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}person_responsible_id']),
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      adminModified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}admin_modified']),
    );
  }

  @override
  $SafetyCardsTable createAlias(String alias) {
    return $SafetyCardsTable(attachedDatabase, alias);
  }
}

class SafetyCard extends DataClass implements Insertable<SafetyCard> {
  final int id;
  final String uuid;
  final Uint8List? imageData;
  final String? imageListBase64;
  final int keyRiskConditionId;
  final String date;
  final String time;
  final int raisedById;
  final String department;
  final int siteId;
  final int locationId;
  final String safetyStatus;
  final String status;
  final String observation;
  final String actionTaken;
  final int? personResponsibleId;
  final String? filePath;
  final bool? adminModified;
  const SafetyCard(
      {required this.id,
      required this.uuid,
      this.imageData,
      this.imageListBase64,
      required this.keyRiskConditionId,
      required this.date,
      required this.time,
      required this.raisedById,
      required this.department,
      required this.siteId,
      required this.locationId,
      required this.safetyStatus,
      required this.status,
      required this.observation,
      required this.actionTaken,
      this.personResponsibleId,
      this.filePath,
      this.adminModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || imageData != null) {
      map['image_data'] = Variable<Uint8List>(imageData);
    }
    if (!nullToAbsent || imageListBase64 != null) {
      map['image_list_base64'] = Variable<String>(imageListBase64);
    }
    map['key_risk_condition_id'] = Variable<int>(keyRiskConditionId);
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    map['raised_by_id'] = Variable<int>(raisedById);
    map['department'] = Variable<String>(department);
    map['site_id'] = Variable<int>(siteId);
    map['location_id'] = Variable<int>(locationId);
    map['safety_status'] = Variable<String>(safetyStatus);
    map['status'] = Variable<String>(status);
    map['observation'] = Variable<String>(observation);
    map['action_taken'] = Variable<String>(actionTaken);
    if (!nullToAbsent || personResponsibleId != null) {
      map['person_responsible_id'] = Variable<int>(personResponsibleId);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || adminModified != null) {
      map['admin_modified'] = Variable<bool>(adminModified);
    }
    return map;
  }

  SafetyCardsCompanion toCompanion(bool nullToAbsent) {
    return SafetyCardsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      imageData: imageData == null && nullToAbsent
          ? const Value.absent()
          : Value(imageData),
      imageListBase64: imageListBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(imageListBase64),
      keyRiskConditionId: Value(keyRiskConditionId),
      date: Value(date),
      time: Value(time),
      raisedById: Value(raisedById),
      department: Value(department),
      siteId: Value(siteId),
      locationId: Value(locationId),
      safetyStatus: Value(safetyStatus),
      status: Value(status),
      observation: Value(observation),
      actionTaken: Value(actionTaken),
      personResponsibleId: personResponsibleId == null && nullToAbsent
          ? const Value.absent()
          : Value(personResponsibleId),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      adminModified: adminModified == null && nullToAbsent
          ? const Value.absent()
          : Value(adminModified),
    );
  }

  factory SafetyCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafetyCard(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      imageData: serializer.fromJson<Uint8List?>(json['imageData']),
      imageListBase64: serializer.fromJson<String?>(json['imageListBase64']),
      keyRiskConditionId: serializer.fromJson<int>(json['keyRiskConditionId']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      raisedById: serializer.fromJson<int>(json['raisedById']),
      department: serializer.fromJson<String>(json['department']),
      siteId: serializer.fromJson<int>(json['siteId']),
      locationId: serializer.fromJson<int>(json['locationId']),
      safetyStatus: serializer.fromJson<String>(json['safetyStatus']),
      status: serializer.fromJson<String>(json['status']),
      observation: serializer.fromJson<String>(json['observation']),
      actionTaken: serializer.fromJson<String>(json['actionTaken']),
      personResponsibleId:
          serializer.fromJson<int?>(json['personResponsibleId']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      adminModified: serializer.fromJson<bool?>(json['adminModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'imageData': serializer.toJson<Uint8List?>(imageData),
      'imageListBase64': serializer.toJson<String?>(imageListBase64),
      'keyRiskConditionId': serializer.toJson<int>(keyRiskConditionId),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'raisedById': serializer.toJson<int>(raisedById),
      'department': serializer.toJson<String>(department),
      'siteId': serializer.toJson<int>(siteId),
      'locationId': serializer.toJson<int>(locationId),
      'safetyStatus': serializer.toJson<String>(safetyStatus),
      'status': serializer.toJson<String>(status),
      'observation': serializer.toJson<String>(observation),
      'actionTaken': serializer.toJson<String>(actionTaken),
      'personResponsibleId': serializer.toJson<int?>(personResponsibleId),
      'filePath': serializer.toJson<String?>(filePath),
      'adminModified': serializer.toJson<bool?>(adminModified),
    };
  }

  SafetyCard copyWith(
          {int? id,
          String? uuid,
          Value<Uint8List?> imageData = const Value.absent(),
          Value<String?> imageListBase64 = const Value.absent(),
          int? keyRiskConditionId,
          String? date,
          String? time,
          int? raisedById,
          String? department,
          int? siteId,
          int? locationId,
          String? safetyStatus,
          String? status,
          String? observation,
          String? actionTaken,
          Value<int?> personResponsibleId = const Value.absent(),
          Value<String?> filePath = const Value.absent(),
          Value<bool?> adminModified = const Value.absent()}) =>
      SafetyCard(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        imageData: imageData.present ? imageData.value : this.imageData,
        imageListBase64: imageListBase64.present
            ? imageListBase64.value
            : this.imageListBase64,
        keyRiskConditionId: keyRiskConditionId ?? this.keyRiskConditionId,
        date: date ?? this.date,
        time: time ?? this.time,
        raisedById: raisedById ?? this.raisedById,
        department: department ?? this.department,
        siteId: siteId ?? this.siteId,
        locationId: locationId ?? this.locationId,
        safetyStatus: safetyStatus ?? this.safetyStatus,
        status: status ?? this.status,
        observation: observation ?? this.observation,
        actionTaken: actionTaken ?? this.actionTaken,
        personResponsibleId: personResponsibleId.present
            ? personResponsibleId.value
            : this.personResponsibleId,
        filePath: filePath.present ? filePath.value : this.filePath,
        adminModified:
            adminModified.present ? adminModified.value : this.adminModified,
      );
  SafetyCard copyWithCompanion(SafetyCardsCompanion data) {
    return SafetyCard(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      imageData: data.imageData.present ? data.imageData.value : this.imageData,
      imageListBase64: data.imageListBase64.present
          ? data.imageListBase64.value
          : this.imageListBase64,
      keyRiskConditionId: data.keyRiskConditionId.present
          ? data.keyRiskConditionId.value
          : this.keyRiskConditionId,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      raisedById:
          data.raisedById.present ? data.raisedById.value : this.raisedById,
      department:
          data.department.present ? data.department.value : this.department,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      safetyStatus: data.safetyStatus.present
          ? data.safetyStatus.value
          : this.safetyStatus,
      status: data.status.present ? data.status.value : this.status,
      observation:
          data.observation.present ? data.observation.value : this.observation,
      actionTaken:
          data.actionTaken.present ? data.actionTaken.value : this.actionTaken,
      personResponsibleId: data.personResponsibleId.present
          ? data.personResponsibleId.value
          : this.personResponsibleId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      adminModified: data.adminModified.present
          ? data.adminModified.value
          : this.adminModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafetyCard(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('imageData: $imageData, ')
          ..write('imageListBase64: $imageListBase64, ')
          ..write('keyRiskConditionId: $keyRiskConditionId, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('raisedById: $raisedById, ')
          ..write('department: $department, ')
          ..write('siteId: $siteId, ')
          ..write('locationId: $locationId, ')
          ..write('safetyStatus: $safetyStatus, ')
          ..write('status: $status, ')
          ..write('observation: $observation, ')
          ..write('actionTaken: $actionTaken, ')
          ..write('personResponsibleId: $personResponsibleId, ')
          ..write('filePath: $filePath, ')
          ..write('adminModified: $adminModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      $driftBlobEquality.hash(imageData),
      imageListBase64,
      keyRiskConditionId,
      date,
      time,
      raisedById,
      department,
      siteId,
      locationId,
      safetyStatus,
      status,
      observation,
      actionTaken,
      personResponsibleId,
      filePath,
      adminModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafetyCard &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          $driftBlobEquality.equals(other.imageData, this.imageData) &&
          other.imageListBase64 == this.imageListBase64 &&
          other.keyRiskConditionId == this.keyRiskConditionId &&
          other.date == this.date &&
          other.time == this.time &&
          other.raisedById == this.raisedById &&
          other.department == this.department &&
          other.siteId == this.siteId &&
          other.locationId == this.locationId &&
          other.safetyStatus == this.safetyStatus &&
          other.status == this.status &&
          other.observation == this.observation &&
          other.actionTaken == this.actionTaken &&
          other.personResponsibleId == this.personResponsibleId &&
          other.filePath == this.filePath &&
          other.adminModified == this.adminModified);
}

class SafetyCardsCompanion extends UpdateCompanion<SafetyCard> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<Uint8List?> imageData;
  final Value<String?> imageListBase64;
  final Value<int> keyRiskConditionId;
  final Value<String> date;
  final Value<String> time;
  final Value<int> raisedById;
  final Value<String> department;
  final Value<int> siteId;
  final Value<int> locationId;
  final Value<String> safetyStatus;
  final Value<String> status;
  final Value<String> observation;
  final Value<String> actionTaken;
  final Value<int?> personResponsibleId;
  final Value<String?> filePath;
  final Value<bool?> adminModified;
  const SafetyCardsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.imageData = const Value.absent(),
    this.imageListBase64 = const Value.absent(),
    this.keyRiskConditionId = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.raisedById = const Value.absent(),
    this.department = const Value.absent(),
    this.siteId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.safetyStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.observation = const Value.absent(),
    this.actionTaken = const Value.absent(),
    this.personResponsibleId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.adminModified = const Value.absent(),
  });
  SafetyCardsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.imageData = const Value.absent(),
    this.imageListBase64 = const Value.absent(),
    required int keyRiskConditionId,
    required String date,
    required String time,
    required int raisedById,
    required String department,
    required int siteId,
    required int locationId,
    required String safetyStatus,
    this.status = const Value.absent(),
    required String observation,
    required String actionTaken,
    this.personResponsibleId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.adminModified = const Value.absent(),
  })  : uuid = Value(uuid),
        keyRiskConditionId = Value(keyRiskConditionId),
        date = Value(date),
        time = Value(time),
        raisedById = Value(raisedById),
        department = Value(department),
        siteId = Value(siteId),
        locationId = Value(locationId),
        safetyStatus = Value(safetyStatus),
        observation = Value(observation),
        actionTaken = Value(actionTaken);
  static Insertable<SafetyCard> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<Uint8List>? imageData,
    Expression<String>? imageListBase64,
    Expression<int>? keyRiskConditionId,
    Expression<String>? date,
    Expression<String>? time,
    Expression<int>? raisedById,
    Expression<String>? department,
    Expression<int>? siteId,
    Expression<int>? locationId,
    Expression<String>? safetyStatus,
    Expression<String>? status,
    Expression<String>? observation,
    Expression<String>? actionTaken,
    Expression<int>? personResponsibleId,
    Expression<String>? filePath,
    Expression<bool>? adminModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (imageData != null) 'image_data': imageData,
      if (imageListBase64 != null) 'image_list_base64': imageListBase64,
      if (keyRiskConditionId != null)
        'key_risk_condition_id': keyRiskConditionId,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (raisedById != null) 'raised_by_id': raisedById,
      if (department != null) 'department': department,
      if (siteId != null) 'site_id': siteId,
      if (locationId != null) 'location_id': locationId,
      if (safetyStatus != null) 'safety_status': safetyStatus,
      if (status != null) 'status': status,
      if (observation != null) 'observation': observation,
      if (actionTaken != null) 'action_taken': actionTaken,
      if (personResponsibleId != null)
        'person_responsible_id': personResponsibleId,
      if (filePath != null) 'file_path': filePath,
      if (adminModified != null) 'admin_modified': adminModified,
    });
  }

  SafetyCardsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<Uint8List?>? imageData,
      Value<String?>? imageListBase64,
      Value<int>? keyRiskConditionId,
      Value<String>? date,
      Value<String>? time,
      Value<int>? raisedById,
      Value<String>? department,
      Value<int>? siteId,
      Value<int>? locationId,
      Value<String>? safetyStatus,
      Value<String>? status,
      Value<String>? observation,
      Value<String>? actionTaken,
      Value<int?>? personResponsibleId,
      Value<String?>? filePath,
      Value<bool?>? adminModified}) {
    return SafetyCardsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      imageData: imageData ?? this.imageData,
      imageListBase64: imageListBase64 ?? this.imageListBase64,
      keyRiskConditionId: keyRiskConditionId ?? this.keyRiskConditionId,
      date: date ?? this.date,
      time: time ?? this.time,
      raisedById: raisedById ?? this.raisedById,
      department: department ?? this.department,
      siteId: siteId ?? this.siteId,
      locationId: locationId ?? this.locationId,
      safetyStatus: safetyStatus ?? this.safetyStatus,
      status: status ?? this.status,
      observation: observation ?? this.observation,
      actionTaken: actionTaken ?? this.actionTaken,
      personResponsibleId: personResponsibleId ?? this.personResponsibleId,
      filePath: filePath ?? this.filePath,
      adminModified: adminModified ?? this.adminModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (imageData.present) {
      map['image_data'] = Variable<Uint8List>(imageData.value);
    }
    if (imageListBase64.present) {
      map['image_list_base64'] = Variable<String>(imageListBase64.value);
    }
    if (keyRiskConditionId.present) {
      map['key_risk_condition_id'] = Variable<int>(keyRiskConditionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (raisedById.present) {
      map['raised_by_id'] = Variable<int>(raisedById.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<int>(locationId.value);
    }
    if (safetyStatus.present) {
      map['safety_status'] = Variable<String>(safetyStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (actionTaken.present) {
      map['action_taken'] = Variable<String>(actionTaken.value);
    }
    if (personResponsibleId.present) {
      map['person_responsible_id'] = Variable<int>(personResponsibleId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (adminModified.present) {
      map['admin_modified'] = Variable<bool>(adminModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafetyCardsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('imageData: $imageData, ')
          ..write('imageListBase64: $imageListBase64, ')
          ..write('keyRiskConditionId: $keyRiskConditionId, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('raisedById: $raisedById, ')
          ..write('department: $department, ')
          ..write('siteId: $siteId, ')
          ..write('locationId: $locationId, ')
          ..write('safetyStatus: $safetyStatus, ')
          ..write('status: $status, ')
          ..write('observation: $observation, ')
          ..write('actionTaken: $actionTaken, ')
          ..write('personResponsibleId: $personResponsibleId, ')
          ..write('filePath: $filePath, ')
          ..write('adminModified: $adminModified')
          ..write(')'))
        .toString();
  }
}

class $SignOffSitesTable extends SignOffSites
    with TableInfo<$SignOffSitesTable, SignOffSite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignOffSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
      'site_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _siteDprMeta =
      const VerificationMeta('siteDpr');
  @override
  late final GeneratedColumn<bool> siteDpr = GeneratedColumn<bool>(
      'site_dpr', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("site_dpr" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _siteCustomerMeta =
      const VerificationMeta('siteCustomer');
  @override
  late final GeneratedColumn<String> siteCustomer = GeneratedColumn<String>(
      'site_customer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _temp3Meta = const VerificationMeta('temp3');
  @override
  late final GeneratedColumn<String> temp3 = GeneratedColumn<String>(
      'temp3', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, siteId, name, image, siteDpr, siteCustomer, temp3];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sign_off_sites';
  @override
  VerificationContext validateIntegrity(Insertable<SignOffSite> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    if (data.containsKey('site_dpr')) {
      context.handle(_siteDprMeta,
          siteDpr.isAcceptableOrUnknown(data['site_dpr']!, _siteDprMeta));
    }
    if (data.containsKey('site_customer')) {
      context.handle(
          _siteCustomerMeta,
          siteCustomer.isAcceptableOrUnknown(
              data['site_customer']!, _siteCustomerMeta));
    }
    if (data.containsKey('temp3')) {
      context.handle(
          _temp3Meta, temp3.isAcceptableOrUnknown(data['temp3']!, _temp3Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignOffSite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignOffSite(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image']),
      siteDpr: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}site_dpr'])!,
      siteCustomer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site_customer']),
      temp3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}temp3']),
    );
  }

  @override
  $SignOffSitesTable createAlias(String alias) {
    return $SignOffSitesTable(attachedDatabase, alias);
  }
}

class SignOffSite extends DataClass implements Insertable<SignOffSite> {
  final int id;
  final String siteId;
  final String name;
  final String? image;
  final bool siteDpr;
  final String? siteCustomer;
  final String? temp3;
  const SignOffSite(
      {required this.id,
      required this.siteId,
      required this.name,
      this.image,
      required this.siteDpr,
      this.siteCustomer,
      this.temp3});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<String>(siteId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    map['site_dpr'] = Variable<bool>(siteDpr);
    if (!nullToAbsent || siteCustomer != null) {
      map['site_customer'] = Variable<String>(siteCustomer);
    }
    if (!nullToAbsent || temp3 != null) {
      map['temp3'] = Variable<String>(temp3);
    }
    return map;
  }

  SignOffSitesCompanion toCompanion(bool nullToAbsent) {
    return SignOffSitesCompanion(
      id: Value(id),
      siteId: Value(siteId),
      name: Value(name),
      image:
          image == null && nullToAbsent ? const Value.absent() : Value(image),
      siteDpr: Value(siteDpr),
      siteCustomer: siteCustomer == null && nullToAbsent
          ? const Value.absent()
          : Value(siteCustomer),
      temp3:
          temp3 == null && nullToAbsent ? const Value.absent() : Value(temp3),
    );
  }

  factory SignOffSite.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignOffSite(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      name: serializer.fromJson<String>(json['name']),
      image: serializer.fromJson<String?>(json['image']),
      siteDpr: serializer.fromJson<bool>(json['siteDpr']),
      siteCustomer: serializer.fromJson<String?>(json['siteCustomer']),
      temp3: serializer.fromJson<String?>(json['temp3']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<String>(siteId),
      'name': serializer.toJson<String>(name),
      'image': serializer.toJson<String?>(image),
      'siteDpr': serializer.toJson<bool>(siteDpr),
      'siteCustomer': serializer.toJson<String?>(siteCustomer),
      'temp3': serializer.toJson<String?>(temp3),
    };
  }

  SignOffSite copyWith(
          {int? id,
          String? siteId,
          String? name,
          Value<String?> image = const Value.absent(),
          bool? siteDpr,
          Value<String?> siteCustomer = const Value.absent(),
          Value<String?> temp3 = const Value.absent()}) =>
      SignOffSite(
        id: id ?? this.id,
        siteId: siteId ?? this.siteId,
        name: name ?? this.name,
        image: image.present ? image.value : this.image,
        siteDpr: siteDpr ?? this.siteDpr,
        siteCustomer:
            siteCustomer.present ? siteCustomer.value : this.siteCustomer,
        temp3: temp3.present ? temp3.value : this.temp3,
      );
  SignOffSite copyWithCompanion(SignOffSitesCompanion data) {
    return SignOffSite(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      name: data.name.present ? data.name.value : this.name,
      image: data.image.present ? data.image.value : this.image,
      siteDpr: data.siteDpr.present ? data.siteDpr.value : this.siteDpr,
      siteCustomer: data.siteCustomer.present
          ? data.siteCustomer.value
          : this.siteCustomer,
      temp3: data.temp3.present ? data.temp3.value : this.temp3,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignOffSite(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('siteDpr: $siteDpr, ')
          ..write('siteCustomer: $siteCustomer, ')
          ..write('temp3: $temp3')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, siteId, name, image, siteDpr, siteCustomer, temp3);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignOffSite &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.name == this.name &&
          other.image == this.image &&
          other.siteDpr == this.siteDpr &&
          other.siteCustomer == this.siteCustomer &&
          other.temp3 == this.temp3);
}

class SignOffSitesCompanion extends UpdateCompanion<SignOffSite> {
  final Value<int> id;
  final Value<String> siteId;
  final Value<String> name;
  final Value<String?> image;
  final Value<bool> siteDpr;
  final Value<String?> siteCustomer;
  final Value<String?> temp3;
  const SignOffSitesCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.name = const Value.absent(),
    this.image = const Value.absent(),
    this.siteDpr = const Value.absent(),
    this.siteCustomer = const Value.absent(),
    this.temp3 = const Value.absent(),
  });
  SignOffSitesCompanion.insert({
    this.id = const Value.absent(),
    required String siteId,
    required String name,
    this.image = const Value.absent(),
    this.siteDpr = const Value.absent(),
    this.siteCustomer = const Value.absent(),
    this.temp3 = const Value.absent(),
  })  : siteId = Value(siteId),
        name = Value(name);
  static Insertable<SignOffSite> custom({
    Expression<int>? id,
    Expression<String>? siteId,
    Expression<String>? name,
    Expression<String>? image,
    Expression<bool>? siteDpr,
    Expression<String>? siteCustomer,
    Expression<String>? temp3,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (name != null) 'name': name,
      if (image != null) 'image': image,
      if (siteDpr != null) 'site_dpr': siteDpr,
      if (siteCustomer != null) 'site_customer': siteCustomer,
      if (temp3 != null) 'temp3': temp3,
    });
  }

  SignOffSitesCompanion copyWith(
      {Value<int>? id,
      Value<String>? siteId,
      Value<String>? name,
      Value<String?>? image,
      Value<bool>? siteDpr,
      Value<String?>? siteCustomer,
      Value<String?>? temp3}) {
    return SignOffSitesCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      image: image ?? this.image,
      siteDpr: siteDpr ?? this.siteDpr,
      siteCustomer: siteCustomer ?? this.siteCustomer,
      temp3: temp3 ?? this.temp3,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (siteDpr.present) {
      map['site_dpr'] = Variable<bool>(siteDpr.value);
    }
    if (siteCustomer.present) {
      map['site_customer'] = Variable<String>(siteCustomer.value);
    }
    if (temp3.present) {
      map['temp3'] = Variable<String>(temp3.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignOffSitesCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('siteDpr: $siteDpr, ')
          ..write('siteCustomer: $siteCustomer, ')
          ..write('temp3: $temp3')
          ..write(')'))
        .toString();
  }
}

class $SignOffLocationsTable extends SignOffLocations
    with TableInfo<$SignOffLocationsTable, SignOffLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignOffLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latLongMeta =
      const VerificationMeta('latLong');
  @override
  late final GeneratedColumn<String> latLong = GeneratedColumn<String>(
      'lat_long', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
      'site_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sign_off_sites (site_id)'));
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
      'field', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _taskLocationMeta =
      const VerificationMeta('taskLocation');
  @override
  late final GeneratedColumn<String> taskLocation = GeneratedColumn<String>(
      'task_location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, locationId, name, latLong, siteId, field, taskLocation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sign_off_locations';
  @override
  VerificationContext validateIntegrity(Insertable<SignOffLocation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lat_long')) {
      context.handle(_latLongMeta,
          latLong.isAcceptableOrUnknown(data['lat_long']!, _latLongMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
          _fieldMeta, field.isAcceptableOrUnknown(data['field']!, _fieldMeta));
    }
    if (data.containsKey('task_location')) {
      context.handle(
          _taskLocationMeta,
          taskLocation.isAcceptableOrUnknown(
              data['task_location']!, _taskLocationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignOffLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignOffLocation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      latLong: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lat_long']),
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site_id'])!,
      field: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field']),
      taskLocation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_location']),
    );
  }

  @override
  $SignOffLocationsTable createAlias(String alias) {
    return $SignOffLocationsTable(attachedDatabase, alias);
  }
}

class SignOffLocation extends DataClass implements Insertable<SignOffLocation> {
  final int id;
  final String locationId;
  final String name;
  final String? latLong;
  final String siteId;
  final String? field;
  final String? taskLocation;
  const SignOffLocation(
      {required this.id,
      required this.locationId,
      required this.name,
      this.latLong,
      required this.siteId,
      this.field,
      this.taskLocation});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['location_id'] = Variable<String>(locationId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || latLong != null) {
      map['lat_long'] = Variable<String>(latLong);
    }
    map['site_id'] = Variable<String>(siteId);
    if (!nullToAbsent || field != null) {
      map['field'] = Variable<String>(field);
    }
    if (!nullToAbsent || taskLocation != null) {
      map['task_location'] = Variable<String>(taskLocation);
    }
    return map;
  }

  SignOffLocationsCompanion toCompanion(bool nullToAbsent) {
    return SignOffLocationsCompanion(
      id: Value(id),
      locationId: Value(locationId),
      name: Value(name),
      latLong: latLong == null && nullToAbsent
          ? const Value.absent()
          : Value(latLong),
      siteId: Value(siteId),
      field:
          field == null && nullToAbsent ? const Value.absent() : Value(field),
      taskLocation: taskLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(taskLocation),
    );
  }

  factory SignOffLocation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignOffLocation(
      id: serializer.fromJson<int>(json['id']),
      locationId: serializer.fromJson<String>(json['locationId']),
      name: serializer.fromJson<String>(json['name']),
      latLong: serializer.fromJson<String?>(json['latLong']),
      siteId: serializer.fromJson<String>(json['siteId']),
      field: serializer.fromJson<String?>(json['field']),
      taskLocation: serializer.fromJson<String?>(json['taskLocation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locationId': serializer.toJson<String>(locationId),
      'name': serializer.toJson<String>(name),
      'latLong': serializer.toJson<String?>(latLong),
      'siteId': serializer.toJson<String>(siteId),
      'field': serializer.toJson<String?>(field),
      'taskLocation': serializer.toJson<String?>(taskLocation),
    };
  }

  SignOffLocation copyWith(
          {int? id,
          String? locationId,
          String? name,
          Value<String?> latLong = const Value.absent(),
          String? siteId,
          Value<String?> field = const Value.absent(),
          Value<String?> taskLocation = const Value.absent()}) =>
      SignOffLocation(
        id: id ?? this.id,
        locationId: locationId ?? this.locationId,
        name: name ?? this.name,
        latLong: latLong.present ? latLong.value : this.latLong,
        siteId: siteId ?? this.siteId,
        field: field.present ? field.value : this.field,
        taskLocation:
            taskLocation.present ? taskLocation.value : this.taskLocation,
      );
  SignOffLocation copyWithCompanion(SignOffLocationsCompanion data) {
    return SignOffLocation(
      id: data.id.present ? data.id.value : this.id,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      name: data.name.present ? data.name.value : this.name,
      latLong: data.latLong.present ? data.latLong.value : this.latLong,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      field: data.field.present ? data.field.value : this.field,
      taskLocation: data.taskLocation.present
          ? data.taskLocation.value
          : this.taskLocation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignOffLocation(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('latLong: $latLong, ')
          ..write('siteId: $siteId, ')
          ..write('field: $field, ')
          ..write('taskLocation: $taskLocation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locationId, name, latLong, siteId, field, taskLocation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignOffLocation &&
          other.id == this.id &&
          other.locationId == this.locationId &&
          other.name == this.name &&
          other.latLong == this.latLong &&
          other.siteId == this.siteId &&
          other.field == this.field &&
          other.taskLocation == this.taskLocation);
}

class SignOffLocationsCompanion extends UpdateCompanion<SignOffLocation> {
  final Value<int> id;
  final Value<String> locationId;
  final Value<String> name;
  final Value<String?> latLong;
  final Value<String> siteId;
  final Value<String?> field;
  final Value<String?> taskLocation;
  const SignOffLocationsCompanion({
    this.id = const Value.absent(),
    this.locationId = const Value.absent(),
    this.name = const Value.absent(),
    this.latLong = const Value.absent(),
    this.siteId = const Value.absent(),
    this.field = const Value.absent(),
    this.taskLocation = const Value.absent(),
  });
  SignOffLocationsCompanion.insert({
    this.id = const Value.absent(),
    required String locationId,
    required String name,
    this.latLong = const Value.absent(),
    required String siteId,
    this.field = const Value.absent(),
    this.taskLocation = const Value.absent(),
  })  : locationId = Value(locationId),
        name = Value(name),
        siteId = Value(siteId);
  static Insertable<SignOffLocation> custom({
    Expression<int>? id,
    Expression<String>? locationId,
    Expression<String>? name,
    Expression<String>? latLong,
    Expression<String>? siteId,
    Expression<String>? field,
    Expression<String>? taskLocation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationId != null) 'location_id': locationId,
      if (name != null) 'name': name,
      if (latLong != null) 'lat_long': latLong,
      if (siteId != null) 'site_id': siteId,
      if (field != null) 'field': field,
      if (taskLocation != null) 'task_location': taskLocation,
    });
  }

  SignOffLocationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? locationId,
      Value<String>? name,
      Value<String?>? latLong,
      Value<String>? siteId,
      Value<String?>? field,
      Value<String?>? taskLocation}) {
    return SignOffLocationsCompanion(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      latLong: latLong ?? this.latLong,
      siteId: siteId ?? this.siteId,
      field: field ?? this.field,
      taskLocation: taskLocation ?? this.taskLocation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latLong.present) {
      map['lat_long'] = Variable<String>(latLong.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (taskLocation.present) {
      map['task_location'] = Variable<String>(taskLocation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignOffLocationsCompanion(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('latLong: $latLong, ')
          ..write('siteId: $siteId, ')
          ..write('field: $field, ')
          ..write('taskLocation: $taskLocation')
          ..write(')'))
        .toString();
  }
}

class $SafetyCommunicationsTable extends SafetyCommunications
    with TableInfo<$SafetyCommunicationsTable, SafetyCommunication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafetyCommunicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
      'site_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sign_off_sites (site_id)'));
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sign_off_locations (location_id)'));
  static const VerificationMeta _projectMeta =
      const VerificationMeta('project');
  @override
  late final GeneratedColumn<String> project = GeneratedColumn<String>(
      'project', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deliveredByMeta =
      const VerificationMeta('deliveredBy');
  @override
  late final GeneratedColumn<String> deliveredBy = GeneratedColumn<String>(
      'delivered_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inductionMeta =
      const VerificationMeta('induction');
  @override
  late final GeneratedColumn<bool> induction = GeneratedColumn<bool>(
      'induction', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("induction" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _trainingMeta =
      const VerificationMeta('training');
  @override
  late final GeneratedColumn<bool> training = GeneratedColumn<bool>(
      'training', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("training" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _toolboxTalkMeta =
      const VerificationMeta('toolboxTalk');
  @override
  late final GeneratedColumn<bool> toolboxTalk = GeneratedColumn<bool>(
      'toolbox_talk', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("toolbox_talk" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _procedureMeta =
      const VerificationMeta('procedure');
  @override
  late final GeneratedColumn<bool> procedure = GeneratedColumn<bool>(
      'procedure', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("procedure" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _riskAssessmentMeta =
      const VerificationMeta('riskAssessment');
  @override
  late final GeneratedColumn<bool> riskAssessment = GeneratedColumn<bool>(
      'risk_assessment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("risk_assessment" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _coshhAssessmentMeta =
      const VerificationMeta('coshhAssessment');
  @override
  late final GeneratedColumn<bool> coshhAssessment = GeneratedColumn<bool>(
      'coshh_assessment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("coshh_assessment" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _otherMeta = const VerificationMeta('other');
  @override
  late final GeneratedColumn<bool> other = GeneratedColumn<bool>(
      'other', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("other" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _commentsMeta =
      const VerificationMeta('comments');
  @override
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
      'comments', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _generateReportMeta =
      const VerificationMeta('generateReport');
  @override
  late final GeneratedColumn<bool> generateReport = GeneratedColumn<bool>(
      'generate_report', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("generate_report" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _creationDateTimeMeta =
      const VerificationMeta('creationDateTime');
  @override
  late final GeneratedColumn<String> creationDateTime = GeneratedColumn<String>(
      'creation_date_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        id,
        title,
        date,
        description,
        siteId,
        department,
        location,
        project,
        deliveredBy,
        category,
        induction,
        training,
        toolboxTalk,
        procedure,
        riskAssessment,
        coshhAssessment,
        other,
        comments,
        generateReport,
        filePath,
        isSynced,
        isDeleted,
        creationDateTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safety_communications';
  @override
  VerificationContext validateIntegrity(
      Insertable<SafetyCommunication> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('project')) {
      context.handle(_projectMeta,
          project.isAcceptableOrUnknown(data['project']!, _projectMeta));
    }
    if (data.containsKey('delivered_by')) {
      context.handle(
          _deliveredByMeta,
          deliveredBy.isAcceptableOrUnknown(
              data['delivered_by']!, _deliveredByMeta));
    } else if (isInserting) {
      context.missing(_deliveredByMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('induction')) {
      context.handle(_inductionMeta,
          induction.isAcceptableOrUnknown(data['induction']!, _inductionMeta));
    }
    if (data.containsKey('training')) {
      context.handle(_trainingMeta,
          training.isAcceptableOrUnknown(data['training']!, _trainingMeta));
    }
    if (data.containsKey('toolbox_talk')) {
      context.handle(
          _toolboxTalkMeta,
          toolboxTalk.isAcceptableOrUnknown(
              data['toolbox_talk']!, _toolboxTalkMeta));
    }
    if (data.containsKey('procedure')) {
      context.handle(_procedureMeta,
          procedure.isAcceptableOrUnknown(data['procedure']!, _procedureMeta));
    }
    if (data.containsKey('risk_assessment')) {
      context.handle(
          _riskAssessmentMeta,
          riskAssessment.isAcceptableOrUnknown(
              data['risk_assessment']!, _riskAssessmentMeta));
    }
    if (data.containsKey('coshh_assessment')) {
      context.handle(
          _coshhAssessmentMeta,
          coshhAssessment.isAcceptableOrUnknown(
              data['coshh_assessment']!, _coshhAssessmentMeta));
    }
    if (data.containsKey('other')) {
      context.handle(
          _otherMeta, other.isAcceptableOrUnknown(data['other']!, _otherMeta));
    }
    if (data.containsKey('comments')) {
      context.handle(_commentsMeta,
          comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta));
    }
    if (data.containsKey('generate_report')) {
      context.handle(
          _generateReportMeta,
          generateReport.isAcceptableOrUnknown(
              data['generate_report']!, _generateReportMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('creation_date_time')) {
      context.handle(
          _creationDateTimeMeta,
          creationDateTime.isAcceptableOrUnknown(
              data['creation_date_time']!, _creationDateTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  SafetyCommunication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafetyCommunication(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site_id'])!,
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      project: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project']),
      deliveredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}delivered_by'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      induction: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}induction'])!,
      training: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}training'])!,
      toolboxTalk: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}toolbox_talk'])!,
      procedure: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}procedure'])!,
      riskAssessment: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}risk_assessment'])!,
      coshhAssessment: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}coshh_assessment'])!,
      other: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}other'])!,
      comments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comments']),
      generateReport: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}generate_report'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      creationDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}creation_date_time']),
    );
  }

  @override
  $SafetyCommunicationsTable createAlias(String alias) {
    return $SafetyCommunicationsTable(attachedDatabase, alias);
  }
}

class SafetyCommunication extends DataClass
    implements Insertable<SafetyCommunication> {
  final int localId;
  final String id;
  final String title;
  final String date;
  final String? description;
  final String siteId;
  final String? department;
  final String location;
  final String? project;
  final String deliveredBy;
  final String category;
  final bool induction;
  final bool training;
  final bool toolboxTalk;
  final bool procedure;
  final bool riskAssessment;
  final bool coshhAssessment;
  final bool other;
  final String? comments;
  final bool generateReport;
  final String? filePath;
  final bool isSynced;
  final bool isDeleted;
  final String? creationDateTime;
  const SafetyCommunication(
      {required this.localId,
      required this.id,
      required this.title,
      required this.date,
      this.description,
      required this.siteId,
      this.department,
      required this.location,
      this.project,
      required this.deliveredBy,
      required this.category,
      required this.induction,
      required this.training,
      required this.toolboxTalk,
      required this.procedure,
      required this.riskAssessment,
      required this.coshhAssessment,
      required this.other,
      this.comments,
      required this.generateReport,
      this.filePath,
      required this.isSynced,
      required this.isDeleted,
      this.creationDateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['site_id'] = Variable<String>(siteId);
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || project != null) {
      map['project'] = Variable<String>(project);
    }
    map['delivered_by'] = Variable<String>(deliveredBy);
    map['category'] = Variable<String>(category);
    map['induction'] = Variable<bool>(induction);
    map['training'] = Variable<bool>(training);
    map['toolbox_talk'] = Variable<bool>(toolboxTalk);
    map['procedure'] = Variable<bool>(procedure);
    map['risk_assessment'] = Variable<bool>(riskAssessment);
    map['coshh_assessment'] = Variable<bool>(coshhAssessment);
    map['other'] = Variable<bool>(other);
    if (!nullToAbsent || comments != null) {
      map['comments'] = Variable<String>(comments);
    }
    map['generate_report'] = Variable<bool>(generateReport);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || creationDateTime != null) {
      map['creation_date_time'] = Variable<String>(creationDateTime);
    }
    return map;
  }

  SafetyCommunicationsCompanion toCompanion(bool nullToAbsent) {
    return SafetyCommunicationsCompanion(
      localId: Value(localId),
      id: Value(id),
      title: Value(title),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      siteId: Value(siteId),
      department: department == null && nullToAbsent
          ? const Value.absent()
          : Value(department),
      location: Value(location),
      project: project == null && nullToAbsent
          ? const Value.absent()
          : Value(project),
      deliveredBy: Value(deliveredBy),
      category: Value(category),
      induction: Value(induction),
      training: Value(training),
      toolboxTalk: Value(toolboxTalk),
      procedure: Value(procedure),
      riskAssessment: Value(riskAssessment),
      coshhAssessment: Value(coshhAssessment),
      other: Value(other),
      comments: comments == null && nullToAbsent
          ? const Value.absent()
          : Value(comments),
      generateReport: Value(generateReport),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      creationDateTime: creationDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(creationDateTime),
    );
  }

  factory SafetyCommunication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafetyCommunication(
      localId: serializer.fromJson<int>(json['localId']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      siteId: serializer.fromJson<String>(json['siteId']),
      department: serializer.fromJson<String?>(json['department']),
      location: serializer.fromJson<String>(json['location']),
      project: serializer.fromJson<String?>(json['project']),
      deliveredBy: serializer.fromJson<String>(json['deliveredBy']),
      category: serializer.fromJson<String>(json['category']),
      induction: serializer.fromJson<bool>(json['induction']),
      training: serializer.fromJson<bool>(json['training']),
      toolboxTalk: serializer.fromJson<bool>(json['toolboxTalk']),
      procedure: serializer.fromJson<bool>(json['procedure']),
      riskAssessment: serializer.fromJson<bool>(json['riskAssessment']),
      coshhAssessment: serializer.fromJson<bool>(json['coshhAssessment']),
      other: serializer.fromJson<bool>(json['other']),
      comments: serializer.fromJson<String?>(json['comments']),
      generateReport: serializer.fromJson<bool>(json['generateReport']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      creationDateTime: serializer.fromJson<String?>(json['creationDateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'description': serializer.toJson<String?>(description),
      'siteId': serializer.toJson<String>(siteId),
      'department': serializer.toJson<String?>(department),
      'location': serializer.toJson<String>(location),
      'project': serializer.toJson<String?>(project),
      'deliveredBy': serializer.toJson<String>(deliveredBy),
      'category': serializer.toJson<String>(category),
      'induction': serializer.toJson<bool>(induction),
      'training': serializer.toJson<bool>(training),
      'toolboxTalk': serializer.toJson<bool>(toolboxTalk),
      'procedure': serializer.toJson<bool>(procedure),
      'riskAssessment': serializer.toJson<bool>(riskAssessment),
      'coshhAssessment': serializer.toJson<bool>(coshhAssessment),
      'other': serializer.toJson<bool>(other),
      'comments': serializer.toJson<String?>(comments),
      'generateReport': serializer.toJson<bool>(generateReport),
      'filePath': serializer.toJson<String?>(filePath),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'creationDateTime': serializer.toJson<String?>(creationDateTime),
    };
  }

  SafetyCommunication copyWith(
          {int? localId,
          String? id,
          String? title,
          String? date,
          Value<String?> description = const Value.absent(),
          String? siteId,
          Value<String?> department = const Value.absent(),
          String? location,
          Value<String?> project = const Value.absent(),
          String? deliveredBy,
          String? category,
          bool? induction,
          bool? training,
          bool? toolboxTalk,
          bool? procedure,
          bool? riskAssessment,
          bool? coshhAssessment,
          bool? other,
          Value<String?> comments = const Value.absent(),
          bool? generateReport,
          Value<String?> filePath = const Value.absent(),
          bool? isSynced,
          bool? isDeleted,
          Value<String?> creationDateTime = const Value.absent()}) =>
      SafetyCommunication(
        localId: localId ?? this.localId,
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        description: description.present ? description.value : this.description,
        siteId: siteId ?? this.siteId,
        department: department.present ? department.value : this.department,
        location: location ?? this.location,
        project: project.present ? project.value : this.project,
        deliveredBy: deliveredBy ?? this.deliveredBy,
        category: category ?? this.category,
        induction: induction ?? this.induction,
        training: training ?? this.training,
        toolboxTalk: toolboxTalk ?? this.toolboxTalk,
        procedure: procedure ?? this.procedure,
        riskAssessment: riskAssessment ?? this.riskAssessment,
        coshhAssessment: coshhAssessment ?? this.coshhAssessment,
        other: other ?? this.other,
        comments: comments.present ? comments.value : this.comments,
        generateReport: generateReport ?? this.generateReport,
        filePath: filePath.present ? filePath.value : this.filePath,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        creationDateTime: creationDateTime.present
            ? creationDateTime.value
            : this.creationDateTime,
      );
  SafetyCommunication copyWithCompanion(SafetyCommunicationsCompanion data) {
    return SafetyCommunication(
      localId: data.localId.present ? data.localId.value : this.localId,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      department:
          data.department.present ? data.department.value : this.department,
      location: data.location.present ? data.location.value : this.location,
      project: data.project.present ? data.project.value : this.project,
      deliveredBy:
          data.deliveredBy.present ? data.deliveredBy.value : this.deliveredBy,
      category: data.category.present ? data.category.value : this.category,
      induction: data.induction.present ? data.induction.value : this.induction,
      training: data.training.present ? data.training.value : this.training,
      toolboxTalk:
          data.toolboxTalk.present ? data.toolboxTalk.value : this.toolboxTalk,
      procedure: data.procedure.present ? data.procedure.value : this.procedure,
      riskAssessment: data.riskAssessment.present
          ? data.riskAssessment.value
          : this.riskAssessment,
      coshhAssessment: data.coshhAssessment.present
          ? data.coshhAssessment.value
          : this.coshhAssessment,
      other: data.other.present ? data.other.value : this.other,
      comments: data.comments.present ? data.comments.value : this.comments,
      generateReport: data.generateReport.present
          ? data.generateReport.value
          : this.generateReport,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      creationDateTime: data.creationDateTime.present
          ? data.creationDateTime.value
          : this.creationDateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafetyCommunication(')
          ..write('localId: $localId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('siteId: $siteId, ')
          ..write('department: $department, ')
          ..write('location: $location, ')
          ..write('project: $project, ')
          ..write('deliveredBy: $deliveredBy, ')
          ..write('category: $category, ')
          ..write('induction: $induction, ')
          ..write('training: $training, ')
          ..write('toolboxTalk: $toolboxTalk, ')
          ..write('procedure: $procedure, ')
          ..write('riskAssessment: $riskAssessment, ')
          ..write('coshhAssessment: $coshhAssessment, ')
          ..write('other: $other, ')
          ..write('comments: $comments, ')
          ..write('generateReport: $generateReport, ')
          ..write('filePath: $filePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('creationDateTime: $creationDateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        localId,
        id,
        title,
        date,
        description,
        siteId,
        department,
        location,
        project,
        deliveredBy,
        category,
        induction,
        training,
        toolboxTalk,
        procedure,
        riskAssessment,
        coshhAssessment,
        other,
        comments,
        generateReport,
        filePath,
        isSynced,
        isDeleted,
        creationDateTime
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafetyCommunication &&
          other.localId == this.localId &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.description == this.description &&
          other.siteId == this.siteId &&
          other.department == this.department &&
          other.location == this.location &&
          other.project == this.project &&
          other.deliveredBy == this.deliveredBy &&
          other.category == this.category &&
          other.induction == this.induction &&
          other.training == this.training &&
          other.toolboxTalk == this.toolboxTalk &&
          other.procedure == this.procedure &&
          other.riskAssessment == this.riskAssessment &&
          other.coshhAssessment == this.coshhAssessment &&
          other.other == this.other &&
          other.comments == this.comments &&
          other.generateReport == this.generateReport &&
          other.filePath == this.filePath &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.creationDateTime == this.creationDateTime);
}

class SafetyCommunicationsCompanion
    extends UpdateCompanion<SafetyCommunication> {
  final Value<int> localId;
  final Value<String> id;
  final Value<String> title;
  final Value<String> date;
  final Value<String?> description;
  final Value<String> siteId;
  final Value<String?> department;
  final Value<String> location;
  final Value<String?> project;
  final Value<String> deliveredBy;
  final Value<String> category;
  final Value<bool> induction;
  final Value<bool> training;
  final Value<bool> toolboxTalk;
  final Value<bool> procedure;
  final Value<bool> riskAssessment;
  final Value<bool> coshhAssessment;
  final Value<bool> other;
  final Value<String?> comments;
  final Value<bool> generateReport;
  final Value<String?> filePath;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String?> creationDateTime;
  const SafetyCommunicationsCompanion({
    this.localId = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.siteId = const Value.absent(),
    this.department = const Value.absent(),
    this.location = const Value.absent(),
    this.project = const Value.absent(),
    this.deliveredBy = const Value.absent(),
    this.category = const Value.absent(),
    this.induction = const Value.absent(),
    this.training = const Value.absent(),
    this.toolboxTalk = const Value.absent(),
    this.procedure = const Value.absent(),
    this.riskAssessment = const Value.absent(),
    this.coshhAssessment = const Value.absent(),
    this.other = const Value.absent(),
    this.comments = const Value.absent(),
    this.generateReport = const Value.absent(),
    this.filePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.creationDateTime = const Value.absent(),
  });
  SafetyCommunicationsCompanion.insert({
    this.localId = const Value.absent(),
    required String id,
    required String title,
    required String date,
    this.description = const Value.absent(),
    required String siteId,
    this.department = const Value.absent(),
    required String location,
    this.project = const Value.absent(),
    required String deliveredBy,
    required String category,
    this.induction = const Value.absent(),
    this.training = const Value.absent(),
    this.toolboxTalk = const Value.absent(),
    this.procedure = const Value.absent(),
    this.riskAssessment = const Value.absent(),
    this.coshhAssessment = const Value.absent(),
    this.other = const Value.absent(),
    this.comments = const Value.absent(),
    this.generateReport = const Value.absent(),
    this.filePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.creationDateTime = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        date = Value(date),
        siteId = Value(siteId),
        location = Value(location),
        deliveredBy = Value(deliveredBy),
        category = Value(category);
  static Insertable<SafetyCommunication> custom({
    Expression<int>? localId,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? description,
    Expression<String>? siteId,
    Expression<String>? department,
    Expression<String>? location,
    Expression<String>? project,
    Expression<String>? deliveredBy,
    Expression<String>? category,
    Expression<bool>? induction,
    Expression<bool>? training,
    Expression<bool>? toolboxTalk,
    Expression<bool>? procedure,
    Expression<bool>? riskAssessment,
    Expression<bool>? coshhAssessment,
    Expression<bool>? other,
    Expression<String>? comments,
    Expression<bool>? generateReport,
    Expression<String>? filePath,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? creationDateTime,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (siteId != null) 'site_id': siteId,
      if (department != null) 'department': department,
      if (location != null) 'location': location,
      if (project != null) 'project': project,
      if (deliveredBy != null) 'delivered_by': deliveredBy,
      if (category != null) 'category': category,
      if (induction != null) 'induction': induction,
      if (training != null) 'training': training,
      if (toolboxTalk != null) 'toolbox_talk': toolboxTalk,
      if (procedure != null) 'procedure': procedure,
      if (riskAssessment != null) 'risk_assessment': riskAssessment,
      if (coshhAssessment != null) 'coshh_assessment': coshhAssessment,
      if (other != null) 'other': other,
      if (comments != null) 'comments': comments,
      if (generateReport != null) 'generate_report': generateReport,
      if (filePath != null) 'file_path': filePath,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (creationDateTime != null) 'creation_date_time': creationDateTime,
    });
  }

  SafetyCommunicationsCompanion copyWith(
      {Value<int>? localId,
      Value<String>? id,
      Value<String>? title,
      Value<String>? date,
      Value<String?>? description,
      Value<String>? siteId,
      Value<String?>? department,
      Value<String>? location,
      Value<String?>? project,
      Value<String>? deliveredBy,
      Value<String>? category,
      Value<bool>? induction,
      Value<bool>? training,
      Value<bool>? toolboxTalk,
      Value<bool>? procedure,
      Value<bool>? riskAssessment,
      Value<bool>? coshhAssessment,
      Value<bool>? other,
      Value<String?>? comments,
      Value<bool>? generateReport,
      Value<String?>? filePath,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String?>? creationDateTime}) {
    return SafetyCommunicationsCompanion(
      localId: localId ?? this.localId,
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      siteId: siteId ?? this.siteId,
      department: department ?? this.department,
      location: location ?? this.location,
      project: project ?? this.project,
      deliveredBy: deliveredBy ?? this.deliveredBy,
      category: category ?? this.category,
      induction: induction ?? this.induction,
      training: training ?? this.training,
      toolboxTalk: toolboxTalk ?? this.toolboxTalk,
      procedure: procedure ?? this.procedure,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      coshhAssessment: coshhAssessment ?? this.coshhAssessment,
      other: other ?? this.other,
      comments: comments ?? this.comments,
      generateReport: generateReport ?? this.generateReport,
      filePath: filePath ?? this.filePath,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      creationDateTime: creationDateTime ?? this.creationDateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (project.present) {
      map['project'] = Variable<String>(project.value);
    }
    if (deliveredBy.present) {
      map['delivered_by'] = Variable<String>(deliveredBy.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (induction.present) {
      map['induction'] = Variable<bool>(induction.value);
    }
    if (training.present) {
      map['training'] = Variable<bool>(training.value);
    }
    if (toolboxTalk.present) {
      map['toolbox_talk'] = Variable<bool>(toolboxTalk.value);
    }
    if (procedure.present) {
      map['procedure'] = Variable<bool>(procedure.value);
    }
    if (riskAssessment.present) {
      map['risk_assessment'] = Variable<bool>(riskAssessment.value);
    }
    if (coshhAssessment.present) {
      map['coshh_assessment'] = Variable<bool>(coshhAssessment.value);
    }
    if (other.present) {
      map['other'] = Variable<bool>(other.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    if (generateReport.present) {
      map['generate_report'] = Variable<bool>(generateReport.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (creationDateTime.present) {
      map['creation_date_time'] = Variable<String>(creationDateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafetyCommunicationsCompanion(')
          ..write('localId: $localId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('siteId: $siteId, ')
          ..write('department: $department, ')
          ..write('location: $location, ')
          ..write('project: $project, ')
          ..write('deliveredBy: $deliveredBy, ')
          ..write('category: $category, ')
          ..write('induction: $induction, ')
          ..write('training: $training, ')
          ..write('toolboxTalk: $toolboxTalk, ')
          ..write('procedure: $procedure, ')
          ..write('riskAssessment: $riskAssessment, ')
          ..write('coshhAssessment: $coshhAssessment, ')
          ..write('other: $other, ')
          ..write('comments: $comments, ')
          ..write('generateReport: $generateReport, ')
          ..write('filePath: $filePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('creationDateTime: $creationDateTime')
          ..write(')'))
        .toString();
  }
}

class $SafetyCommSignaturesTable extends SafetyCommSignatures
    with TableInfo<$SafetyCommSignaturesTable, SafetyCommSignature> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafetyCommSignaturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _communicationIdMeta =
      const VerificationMeta('communicationId');
  @override
  late final GeneratedColumn<String> communicationId = GeneratedColumn<String>(
      'communication_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES safety_communications (id)'));
  static const VerificationMeta _teamMemberMeta =
      const VerificationMeta('teamMember');
  @override
  late final GeneratedColumn<String> teamMember = GeneratedColumn<String>(
      'team_member', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signatureMeta =
      const VerificationMeta('signature');
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
      'signature', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shiftMeta = const VerificationMeta('shift');
  @override
  late final GeneratedColumn<String> shift = GeneratedColumn<String>(
      'shift', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        id,
        communicationId,
        teamMember,
        signature,
        shift,
        isSynced,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safety_comm_signatures';
  @override
  VerificationContext validateIntegrity(
      Insertable<SafetyCommSignature> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('communication_id')) {
      context.handle(
          _communicationIdMeta,
          communicationId.isAcceptableOrUnknown(
              data['communication_id']!, _communicationIdMeta));
    } else if (isInserting) {
      context.missing(_communicationIdMeta);
    }
    if (data.containsKey('team_member')) {
      context.handle(
          _teamMemberMeta,
          teamMember.isAcceptableOrUnknown(
              data['team_member']!, _teamMemberMeta));
    } else if (isInserting) {
      context.missing(_teamMemberMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(_signatureMeta,
          signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta));
    }
    if (data.containsKey('shift')) {
      context.handle(
          _shiftMeta, shift.isAcceptableOrUnknown(data['shift']!, _shiftMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  SafetyCommSignature map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafetyCommSignature(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      communicationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}communication_id'])!,
      teamMember: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_member'])!,
      signature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature']),
      shift: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $SafetyCommSignaturesTable createAlias(String alias) {
    return $SafetyCommSignaturesTable(attachedDatabase, alias);
  }
}

class SafetyCommSignature extends DataClass
    implements Insertable<SafetyCommSignature> {
  final int localId;
  final String id;
  final String communicationId;
  final String teamMember;
  final String? signature;
  final String? shift;
  final bool isSynced;
  final bool isDeleted;
  const SafetyCommSignature(
      {required this.localId,
      required this.id,
      required this.communicationId,
      required this.teamMember,
      this.signature,
      this.shift,
      required this.isSynced,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['id'] = Variable<String>(id);
    map['communication_id'] = Variable<String>(communicationId);
    map['team_member'] = Variable<String>(teamMember);
    if (!nullToAbsent || signature != null) {
      map['signature'] = Variable<String>(signature);
    }
    if (!nullToAbsent || shift != null) {
      map['shift'] = Variable<String>(shift);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SafetyCommSignaturesCompanion toCompanion(bool nullToAbsent) {
    return SafetyCommSignaturesCompanion(
      localId: Value(localId),
      id: Value(id),
      communicationId: Value(communicationId),
      teamMember: Value(teamMember),
      signature: signature == null && nullToAbsent
          ? const Value.absent()
          : Value(signature),
      shift:
          shift == null && nullToAbsent ? const Value.absent() : Value(shift),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
    );
  }

  factory SafetyCommSignature.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafetyCommSignature(
      localId: serializer.fromJson<int>(json['localId']),
      id: serializer.fromJson<String>(json['id']),
      communicationId: serializer.fromJson<String>(json['communicationId']),
      teamMember: serializer.fromJson<String>(json['teamMember']),
      signature: serializer.fromJson<String?>(json['signature']),
      shift: serializer.fromJson<String?>(json['shift']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'id': serializer.toJson<String>(id),
      'communicationId': serializer.toJson<String>(communicationId),
      'teamMember': serializer.toJson<String>(teamMember),
      'signature': serializer.toJson<String?>(signature),
      'shift': serializer.toJson<String?>(shift),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  SafetyCommSignature copyWith(
          {int? localId,
          String? id,
          String? communicationId,
          String? teamMember,
          Value<String?> signature = const Value.absent(),
          Value<String?> shift = const Value.absent(),
          bool? isSynced,
          bool? isDeleted}) =>
      SafetyCommSignature(
        localId: localId ?? this.localId,
        id: id ?? this.id,
        communicationId: communicationId ?? this.communicationId,
        teamMember: teamMember ?? this.teamMember,
        signature: signature.present ? signature.value : this.signature,
        shift: shift.present ? shift.value : this.shift,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  SafetyCommSignature copyWithCompanion(SafetyCommSignaturesCompanion data) {
    return SafetyCommSignature(
      localId: data.localId.present ? data.localId.value : this.localId,
      id: data.id.present ? data.id.value : this.id,
      communicationId: data.communicationId.present
          ? data.communicationId.value
          : this.communicationId,
      teamMember:
          data.teamMember.present ? data.teamMember.value : this.teamMember,
      signature: data.signature.present ? data.signature.value : this.signature,
      shift: data.shift.present ? data.shift.value : this.shift,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafetyCommSignature(')
          ..write('localId: $localId, ')
          ..write('id: $id, ')
          ..write('communicationId: $communicationId, ')
          ..write('teamMember: $teamMember, ')
          ..write('signature: $signature, ')
          ..write('shift: $shift, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, id, communicationId, teamMember,
      signature, shift, isSynced, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafetyCommSignature &&
          other.localId == this.localId &&
          other.id == this.id &&
          other.communicationId == this.communicationId &&
          other.teamMember == this.teamMember &&
          other.signature == this.signature &&
          other.shift == this.shift &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted);
}

class SafetyCommSignaturesCompanion
    extends UpdateCompanion<SafetyCommSignature> {
  final Value<int> localId;
  final Value<String> id;
  final Value<String> communicationId;
  final Value<String> teamMember;
  final Value<String?> signature;
  final Value<String?> shift;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  const SafetyCommSignaturesCompanion({
    this.localId = const Value.absent(),
    this.id = const Value.absent(),
    this.communicationId = const Value.absent(),
    this.teamMember = const Value.absent(),
    this.signature = const Value.absent(),
    this.shift = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  SafetyCommSignaturesCompanion.insert({
    this.localId = const Value.absent(),
    required String id,
    required String communicationId,
    required String teamMember,
    this.signature = const Value.absent(),
    this.shift = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : id = Value(id),
        communicationId = Value(communicationId),
        teamMember = Value(teamMember);
  static Insertable<SafetyCommSignature> custom({
    Expression<int>? localId,
    Expression<String>? id,
    Expression<String>? communicationId,
    Expression<String>? teamMember,
    Expression<String>? signature,
    Expression<String>? shift,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (id != null) 'id': id,
      if (communicationId != null) 'communication_id': communicationId,
      if (teamMember != null) 'team_member': teamMember,
      if (signature != null) 'signature': signature,
      if (shift != null) 'shift': shift,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  SafetyCommSignaturesCompanion copyWith(
      {Value<int>? localId,
      Value<String>? id,
      Value<String>? communicationId,
      Value<String>? teamMember,
      Value<String?>? signature,
      Value<String?>? shift,
      Value<bool>? isSynced,
      Value<bool>? isDeleted}) {
    return SafetyCommSignaturesCompanion(
      localId: localId ?? this.localId,
      id: id ?? this.id,
      communicationId: communicationId ?? this.communicationId,
      teamMember: teamMember ?? this.teamMember,
      signature: signature ?? this.signature,
      shift: shift ?? this.shift,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (communicationId.present) {
      map['communication_id'] = Variable<String>(communicationId.value);
    }
    if (teamMember.present) {
      map['team_member'] = Variable<String>(teamMember.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (shift.present) {
      map['shift'] = Variable<String>(shift.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafetyCommSignaturesCompanion(')
          ..write('localId: $localId, ')
          ..write('id: $id, ')
          ..write('communicationId: $communicationId, ')
          ..write('teamMember: $teamMember, ')
          ..write('signature: $signature, ')
          ..write('shift: $shift, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $KeyRiskConditionsTable keyRiskConditions =
      $KeyRiskConditionsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $SafetyCardsTable safetyCards = $SafetyCardsTable(this);
  late final $SignOffSitesTable signOffSites = $SignOffSitesTable(this);
  late final $SignOffLocationsTable signOffLocations =
      $SignOffLocationsTable(this);
  late final $SafetyCommunicationsTable safetyCommunications =
      $SafetyCommunicationsTable(this);
  late final $SafetyCommSignaturesTable safetyCommSignatures =
      $SafetyCommSignaturesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        appUsers,
        keyRiskConditions,
        users,
        sites,
        locations,
        safetyCards,
        signOffSites,
        signOffLocations,
        safetyCommunications,
        safetyCommSignatures
      ];
}

typedef $$AppUsersTableCreateCompanionBuilder = AppUsersCompanion Function({
  Value<int> id,
  required String name,
  required String email,
  required String securityLevel,
  Value<String?> currentSite,
  Value<String?> specialization,
});
typedef $$AppUsersTableUpdateCompanionBuilder = AppUsersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> email,
  Value<String> securityLevel,
  Value<String?> currentSite,
  Value<String?> specialization,
});

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get securityLevel => $composableBuilder(
      column: $table.securityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentSite => $composableBuilder(
      column: $table.currentSite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialization => $composableBuilder(
      column: $table.specialization,
      builder: (column) => ColumnFilters(column));
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get securityLevel => $composableBuilder(
      column: $table.securityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentSite => $composableBuilder(
      column: $table.currentSite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialization => $composableBuilder(
      column: $table.specialization,
      builder: (column) => ColumnOrderings(column));
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get securityLevel => $composableBuilder(
      column: $table.securityLevel, builder: (column) => column);

  GeneratedColumn<String> get currentSite => $composableBuilder(
      column: $table.currentSite, builder: (column) => column);

  GeneratedColumn<String> get specialization => $composableBuilder(
      column: $table.specialization, builder: (column) => column);
}

class $$AppUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppUsersTable,
    AppUser,
    $$AppUsersTableFilterComposer,
    $$AppUsersTableOrderingComposer,
    $$AppUsersTableAnnotationComposer,
    $$AppUsersTableCreateCompanionBuilder,
    $$AppUsersTableUpdateCompanionBuilder,
    (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
    AppUser,
    PrefetchHooks Function()> {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> securityLevel = const Value.absent(),
            Value<String?> currentSite = const Value.absent(),
            Value<String?> specialization = const Value.absent(),
          }) =>
              AppUsersCompanion(
            id: id,
            name: name,
            email: email,
            securityLevel: securityLevel,
            currentSite: currentSite,
            specialization: specialization,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String email,
            required String securityLevel,
            Value<String?> currentSite = const Value.absent(),
            Value<String?> specialization = const Value.absent(),
          }) =>
              AppUsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            securityLevel: securityLevel,
            currentSite: currentSite,
            specialization: specialization,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppUsersTable,
    AppUser,
    $$AppUsersTableFilterComposer,
    $$AppUsersTableOrderingComposer,
    $$AppUsersTableAnnotationComposer,
    $$AppUsersTableCreateCompanionBuilder,
    $$AppUsersTableUpdateCompanionBuilder,
    (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
    AppUser,
    PrefetchHooks Function()>;
typedef $$KeyRiskConditionsTableCreateCompanionBuilder
    = KeyRiskConditionsCompanion Function({
  Value<int> id,
  required String name,
  required String icon,
  required String hexId,
});
typedef $$KeyRiskConditionsTableUpdateCompanionBuilder
    = KeyRiskConditionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> hexId,
});

final class $$KeyRiskConditionsTableReferences extends BaseReferences<
    _$AppDatabase, $KeyRiskConditionsTable, KeyRiskCondition> {
  $$KeyRiskConditionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SafetyCardsTable, List<SafetyCard>>
      _safetyCardsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.safetyCards,
              aliasName: $_aliasNameGenerator(
                  db.keyRiskConditions.id, db.safetyCards.keyRiskConditionId));

  $$SafetyCardsTableProcessedTableManager get safetyCardsRefs {
    final manager = $$SafetyCardsTableTableManager($_db, $_db.safetyCards)
        .filter(
            (f) => f.keyRiskConditionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_safetyCardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$KeyRiskConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $KeyRiskConditionsTable> {
  $$KeyRiskConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hexId => $composableBuilder(
      column: $table.hexId, builder: (column) => ColumnFilters(column));

  Expression<bool> safetyCardsRefs(
      Expression<bool> Function($$SafetyCardsTableFilterComposer f) f) {
    final $$SafetyCardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCards,
        getReferencedColumn: (t) => t.keyRiskConditionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCardsTableFilterComposer(
              $db: $db,
              $table: $db.safetyCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$KeyRiskConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyRiskConditionsTable> {
  $$KeyRiskConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hexId => $composableBuilder(
      column: $table.hexId, builder: (column) => ColumnOrderings(column));
}

class $$KeyRiskConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyRiskConditionsTable> {
  $$KeyRiskConditionsTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get hexId =>
      $composableBuilder(column: $table.hexId, builder: (column) => column);

  Expression<T> safetyCardsRefs<T extends Object>(
      Expression<T> Function($$SafetyCardsTableAnnotationComposer a) f) {
    final $$SafetyCardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCards,
        getReferencedColumn: (t) => t.keyRiskConditionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCardsTableAnnotationComposer(
              $db: $db,
              $table: $db.safetyCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$KeyRiskConditionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KeyRiskConditionsTable,
    KeyRiskCondition,
    $$KeyRiskConditionsTableFilterComposer,
    $$KeyRiskConditionsTableOrderingComposer,
    $$KeyRiskConditionsTableAnnotationComposer,
    $$KeyRiskConditionsTableCreateCompanionBuilder,
    $$KeyRiskConditionsTableUpdateCompanionBuilder,
    (KeyRiskCondition, $$KeyRiskConditionsTableReferences),
    KeyRiskCondition,
    PrefetchHooks Function({bool safetyCardsRefs})> {
  $$KeyRiskConditionsTableTableManager(
      _$AppDatabase db, $KeyRiskConditionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyRiskConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyRiskConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyRiskConditionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> hexId = const Value.absent(),
          }) =>
              KeyRiskConditionsCompanion(
            id: id,
            name: name,
            icon: icon,
            hexId: hexId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String icon,
            required String hexId,
          }) =>
              KeyRiskConditionsCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            hexId: hexId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$KeyRiskConditionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({safetyCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (safetyCardsRefs) db.safetyCards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (safetyCardsRefs)
                    await $_getPrefetchedData<KeyRiskCondition,
                            $KeyRiskConditionsTable, SafetyCard>(
                        currentTable: table,
                        referencedTable: $$KeyRiskConditionsTableReferences
                            ._safetyCardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$KeyRiskConditionsTableReferences(db, table, p0)
                                .safetyCardsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.keyRiskConditionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$KeyRiskConditionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KeyRiskConditionsTable,
    KeyRiskCondition,
    $$KeyRiskConditionsTableFilterComposer,
    $$KeyRiskConditionsTableOrderingComposer,
    $$KeyRiskConditionsTableAnnotationComposer,
    $$KeyRiskConditionsTableCreateCompanionBuilder,
    $$KeyRiskConditionsTableUpdateCompanionBuilder,
    (KeyRiskCondition, $$KeyRiskConditionsTableReferences),
    KeyRiskCondition,
    PrefetchHooks Function({bool safetyCardsRefs})>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
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
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserLite,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserLite, BaseReferences<_$AppDatabase, $UsersTable, UserLite>),
    UserLite,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserLite,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserLite, BaseReferences<_$AppDatabase, $UsersTable, UserLite>),
    UserLite,
    PrefetchHooks Function()>;
typedef $$SitesTableCreateCompanionBuilder = SitesCompanion Function({
  Value<int> id,
  required String name,
  required String uuid,
});
typedef $$SitesTableUpdateCompanionBuilder = SitesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> uuid,
});

final class $$SitesTableReferences
    extends BaseReferences<_$AppDatabase, $SitesTable, Site> {
  $$SitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocationsTable, List<Location>>
      _locationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.locations,
          aliasName: $_aliasNameGenerator(db.sites.id, db.locations.siteId));

  $$LocationsTableProcessedTableManager get locationsRefs {
    final manager = $$LocationsTableTableManager($_db, $_db.locations)
        .filter((f) => f.siteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_locationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SafetyCardsTable, List<SafetyCard>>
      _safetyCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.safetyCards,
          aliasName: $_aliasNameGenerator(db.sites.id, db.safetyCards.siteId));

  $$SafetyCardsTableProcessedTableManager get safetyCardsRefs {
    final manager = $$SafetyCardsTableTableManager($_db, $_db.safetyCards)
        .filter((f) => f.siteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_safetyCardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SitesTableFilterComposer extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  Expression<bool> locationsRefs(
      Expression<bool> Function($$LocationsTableFilterComposer f) f) {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.locations,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableFilterComposer(
              $db: $db,
              $table: $db.locations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> safetyCardsRefs(
      Expression<bool> Function($$SafetyCardsTableFilterComposer f) f) {
    final $$SafetyCardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCards,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCardsTableFilterComposer(
              $db: $db,
              $table: $db.safetyCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));
}

class $$SitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  Expression<T> locationsRefs<T extends Object>(
      Expression<T> Function($$LocationsTableAnnotationComposer a) f) {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.locations,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.locations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> safetyCardsRefs<T extends Object>(
      Expression<T> Function($$SafetyCardsTableAnnotationComposer a) f) {
    final $$SafetyCardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCards,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCardsTableAnnotationComposer(
              $db: $db,
              $table: $db.safetyCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SitesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SitesTable,
    Site,
    $$SitesTableFilterComposer,
    $$SitesTableOrderingComposer,
    $$SitesTableAnnotationComposer,
    $$SitesTableCreateCompanionBuilder,
    $$SitesTableUpdateCompanionBuilder,
    (Site, $$SitesTableReferences),
    Site,
    PrefetchHooks Function({bool locationsRefs, bool safetyCardsRefs})> {
  $$SitesTableTableManager(_$AppDatabase db, $SitesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> uuid = const Value.absent(),
          }) =>
              SitesCompanion(
            id: id,
            name: name,
            uuid: uuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String uuid,
          }) =>
              SitesCompanion.insert(
            id: id,
            name: name,
            uuid: uuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SitesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {locationsRefs = false, safetyCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (locationsRefs) db.locations,
                if (safetyCardsRefs) db.safetyCards
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (locationsRefs)
                    await $_getPrefetchedData<Site, $SitesTable, Location>(
                        currentTable: table,
                        referencedTable:
                            $$SitesTableReferences._locationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SitesTableReferences(db, table, p0).locationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siteId == item.id),
                        typedResults: items),
                  if (safetyCardsRefs)
                    await $_getPrefetchedData<Site, $SitesTable, SafetyCard>(
                        currentTable: table,
                        referencedTable:
                            $$SitesTableReferences._safetyCardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SitesTableReferences(db, table, p0)
                                .safetyCardsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SitesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SitesTable,
    Site,
    $$SitesTableFilterComposer,
    $$SitesTableOrderingComposer,
    $$SitesTableAnnotationComposer,
    $$SitesTableCreateCompanionBuilder,
    $$SitesTableUpdateCompanionBuilder,
    (Site, $$SitesTableReferences),
    Site,
    PrefetchHooks Function({bool locationsRefs, bool safetyCardsRefs})>;
typedef $$LocationsTableCreateCompanionBuilder = LocationsCompanion Function({
  Value<int> id,
  required String name,
  required int siteId,
  required String uuid,
});
typedef $$LocationsTableUpdateCompanionBuilder = LocationsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> siteId,
  Value<String> uuid,
});

final class $$LocationsTableReferences
    extends BaseReferences<_$AppDatabase, $LocationsTable, Location> {
  $$LocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites
      .createAlias($_aliasNameGenerator(db.locations.siteId, db.sites.id));

  $$SitesTableProcessedTableManager get siteId {
    final $_column = $_itemColumn<int>('site_id')!;

    final manager = $$SitesTableTableManager($_db, $_db.sites)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SafetyCardsTable, List<SafetyCard>>
      _safetyCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.safetyCards,
          aliasName:
              $_aliasNameGenerator(db.locations.id, db.safetyCards.locationId));

  $$SafetyCardsTableProcessedTableManager get safetyCardsRefs {
    final manager = $$SafetyCardsTableTableManager($_db, $_db.safetyCards)
        .filter((f) => f.locationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_safetyCardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  $$SitesTableFilterComposer get siteId {
    final $$SitesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableFilterComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> safetyCardsRefs(
      Expression<bool> Function($$SafetyCardsTableFilterComposer f) f) {
    final $$SafetyCardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCards,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCardsTableFilterComposer(
              $db: $db,
              $table: $db.safetyCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  $$SitesTableOrderingComposer get siteId {
    final $$SitesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableOrderingComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  $$SitesTableAnnotationComposer get siteId {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableAnnotationComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> safetyCardsRefs<T extends Object>(
      Expression<T> Function($$SafetyCardsTableAnnotationComposer a) f) {
    final $$SafetyCardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCards,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCardsTableAnnotationComposer(
              $db: $db,
              $table: $db.safetyCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationsTable,
    Location,
    $$LocationsTableFilterComposer,
    $$LocationsTableOrderingComposer,
    $$LocationsTableAnnotationComposer,
    $$LocationsTableCreateCompanionBuilder,
    $$LocationsTableUpdateCompanionBuilder,
    (Location, $$LocationsTableReferences),
    Location,
    PrefetchHooks Function({bool siteId, bool safetyCardsRefs})> {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> siteId = const Value.absent(),
            Value<String> uuid = const Value.absent(),
          }) =>
              LocationsCompanion(
            id: id,
            name: name,
            siteId: siteId,
            uuid: uuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int siteId,
            required String uuid,
          }) =>
              LocationsCompanion.insert(
            id: id,
            name: name,
            siteId: siteId,
            uuid: uuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({siteId = false, safetyCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (safetyCardsRefs) db.safetyCards],
              addJoins: <
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
                      dynamic>>(state) {
                if (siteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siteId,
                    referencedTable:
                        $$LocationsTableReferences._siteIdTable(db),
                    referencedColumn:
                        $$LocationsTableReferences._siteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (safetyCardsRefs)
                    await $_getPrefetchedData<Location, $LocationsTable,
                            SafetyCard>(
                        currentTable: table,
                        referencedTable: $$LocationsTableReferences
                            ._safetyCardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocationsTableReferences(db, table, p0)
                                .safetyCardsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.locationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocationsTable,
    Location,
    $$LocationsTableFilterComposer,
    $$LocationsTableOrderingComposer,
    $$LocationsTableAnnotationComposer,
    $$LocationsTableCreateCompanionBuilder,
    $$LocationsTableUpdateCompanionBuilder,
    (Location, $$LocationsTableReferences),
    Location,
    PrefetchHooks Function({bool siteId, bool safetyCardsRefs})>;
typedef $$SafetyCardsTableCreateCompanionBuilder = SafetyCardsCompanion
    Function({
  Value<int> id,
  required String uuid,
  Value<Uint8List?> imageData,
  Value<String?> imageListBase64,
  required int keyRiskConditionId,
  required String date,
  required String time,
  required int raisedById,
  required String department,
  required int siteId,
  required int locationId,
  required String safetyStatus,
  Value<String> status,
  required String observation,
  required String actionTaken,
  Value<int?> personResponsibleId,
  Value<String?> filePath,
  Value<bool?> adminModified,
});
typedef $$SafetyCardsTableUpdateCompanionBuilder = SafetyCardsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<Uint8List?> imageData,
  Value<String?> imageListBase64,
  Value<int> keyRiskConditionId,
  Value<String> date,
  Value<String> time,
  Value<int> raisedById,
  Value<String> department,
  Value<int> siteId,
  Value<int> locationId,
  Value<String> safetyStatus,
  Value<String> status,
  Value<String> observation,
  Value<String> actionTaken,
  Value<int?> personResponsibleId,
  Value<String?> filePath,
  Value<bool?> adminModified,
});

final class $$SafetyCardsTableReferences
    extends BaseReferences<_$AppDatabase, $SafetyCardsTable, SafetyCard> {
  $$SafetyCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KeyRiskConditionsTable _keyRiskConditionIdTable(_$AppDatabase db) =>
      db.keyRiskConditions.createAlias($_aliasNameGenerator(
          db.safetyCards.keyRiskConditionId, db.keyRiskConditions.id));

  $$KeyRiskConditionsTableProcessedTableManager get keyRiskConditionId {
    final $_column = $_itemColumn<int>('key_risk_condition_id')!;

    final manager =
        $$KeyRiskConditionsTableTableManager($_db, $_db.keyRiskConditions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_keyRiskConditionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _raisedByIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.safetyCards.raisedById, db.users.id));

  $$UsersTableProcessedTableManager get raisedById {
    final $_column = $_itemColumn<int>('raised_by_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_raisedByIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites
      .createAlias($_aliasNameGenerator(db.safetyCards.siteId, db.sites.id));

  $$SitesTableProcessedTableManager get siteId {
    final $_column = $_itemColumn<int>('site_id')!;

    final manager = $$SitesTableTableManager($_db, $_db.sites)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocationsTable _locationIdTable(_$AppDatabase db) =>
      db.locations.createAlias(
          $_aliasNameGenerator(db.safetyCards.locationId, db.locations.id));

  $$LocationsTableProcessedTableManager get locationId {
    final $_column = $_itemColumn<int>('location_id')!;

    final manager = $$LocationsTableTableManager($_db, $_db.locations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_locationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _personResponsibleIdTable(_$AppDatabase db) =>
      db.users.createAlias($_aliasNameGenerator(
          db.safetyCards.personResponsibleId, db.users.id));

  $$UsersTableProcessedTableManager? get personResponsibleId {
    final $_column = $_itemColumn<int>('person_responsible_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personResponsibleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SafetyCardsTableFilterComposer
    extends Composer<_$AppDatabase, $SafetyCardsTable> {
  $$SafetyCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageListBase64 => $composableBuilder(
      column: $table.imageListBase64,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get safetyStatus => $composableBuilder(
      column: $table.safetyStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observation => $composableBuilder(
      column: $table.observation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionTaken => $composableBuilder(
      column: $table.actionTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get adminModified => $composableBuilder(
      column: $table.adminModified, builder: (column) => ColumnFilters(column));

  $$KeyRiskConditionsTableFilterComposer get keyRiskConditionId {
    final $$KeyRiskConditionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.keyRiskConditionId,
        referencedTable: $db.keyRiskConditions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KeyRiskConditionsTableFilterComposer(
              $db: $db,
              $table: $db.keyRiskConditions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get raisedById {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.raisedById,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SitesTableFilterComposer get siteId {
    final $$SitesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableFilterComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocationsTableFilterComposer get locationId {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.locations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableFilterComposer(
              $db: $db,
              $table: $db.locations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get personResponsibleId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personResponsibleId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SafetyCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $SafetyCardsTable> {
  $$SafetyCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageListBase64 => $composableBuilder(
      column: $table.imageListBase64,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get safetyStatus => $composableBuilder(
      column: $table.safetyStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observation => $composableBuilder(
      column: $table.observation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionTaken => $composableBuilder(
      column: $table.actionTaken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get adminModified => $composableBuilder(
      column: $table.adminModified,
      builder: (column) => ColumnOrderings(column));

  $$KeyRiskConditionsTableOrderingComposer get keyRiskConditionId {
    final $$KeyRiskConditionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.keyRiskConditionId,
        referencedTable: $db.keyRiskConditions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KeyRiskConditionsTableOrderingComposer(
              $db: $db,
              $table: $db.keyRiskConditions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get raisedById {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.raisedById,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SitesTableOrderingComposer get siteId {
    final $$SitesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableOrderingComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocationsTableOrderingComposer get locationId {
    final $$LocationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.locations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableOrderingComposer(
              $db: $db,
              $table: $db.locations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get personResponsibleId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personResponsibleId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SafetyCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SafetyCardsTable> {
  $$SafetyCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageData =>
      $composableBuilder(column: $table.imageData, builder: (column) => column);

  GeneratedColumn<String> get imageListBase64 => $composableBuilder(
      column: $table.imageListBase64, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<String> get safetyStatus => $composableBuilder(
      column: $table.safetyStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
      column: $table.observation, builder: (column) => column);

  GeneratedColumn<String> get actionTaken => $composableBuilder(
      column: $table.actionTaken, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<bool> get adminModified => $composableBuilder(
      column: $table.adminModified, builder: (column) => column);

  $$KeyRiskConditionsTableAnnotationComposer get keyRiskConditionId {
    final $$KeyRiskConditionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.keyRiskConditionId,
            referencedTable: $db.keyRiskConditions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$KeyRiskConditionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.keyRiskConditions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$UsersTableAnnotationComposer get raisedById {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.raisedById,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SitesTableAnnotationComposer get siteId {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableAnnotationComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocationsTableAnnotationComposer get locationId {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.locations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.locations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get personResponsibleId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personResponsibleId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SafetyCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SafetyCardsTable,
    SafetyCard,
    $$SafetyCardsTableFilterComposer,
    $$SafetyCardsTableOrderingComposer,
    $$SafetyCardsTableAnnotationComposer,
    $$SafetyCardsTableCreateCompanionBuilder,
    $$SafetyCardsTableUpdateCompanionBuilder,
    (SafetyCard, $$SafetyCardsTableReferences),
    SafetyCard,
    PrefetchHooks Function(
        {bool keyRiskConditionId,
        bool raisedById,
        bool siteId,
        bool locationId,
        bool personResponsibleId})> {
  $$SafetyCardsTableTableManager(_$AppDatabase db, $SafetyCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SafetyCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SafetyCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SafetyCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<Uint8List?> imageData = const Value.absent(),
            Value<String?> imageListBase64 = const Value.absent(),
            Value<int> keyRiskConditionId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<int> raisedById = const Value.absent(),
            Value<String> department = const Value.absent(),
            Value<int> siteId = const Value.absent(),
            Value<int> locationId = const Value.absent(),
            Value<String> safetyStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> observation = const Value.absent(),
            Value<String> actionTaken = const Value.absent(),
            Value<int?> personResponsibleId = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<bool?> adminModified = const Value.absent(),
          }) =>
              SafetyCardsCompanion(
            id: id,
            uuid: uuid,
            imageData: imageData,
            imageListBase64: imageListBase64,
            keyRiskConditionId: keyRiskConditionId,
            date: date,
            time: time,
            raisedById: raisedById,
            department: department,
            siteId: siteId,
            locationId: locationId,
            safetyStatus: safetyStatus,
            status: status,
            observation: observation,
            actionTaken: actionTaken,
            personResponsibleId: personResponsibleId,
            filePath: filePath,
            adminModified: adminModified,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<Uint8List?> imageData = const Value.absent(),
            Value<String?> imageListBase64 = const Value.absent(),
            required int keyRiskConditionId,
            required String date,
            required String time,
            required int raisedById,
            required String department,
            required int siteId,
            required int locationId,
            required String safetyStatus,
            Value<String> status = const Value.absent(),
            required String observation,
            required String actionTaken,
            Value<int?> personResponsibleId = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<bool?> adminModified = const Value.absent(),
          }) =>
              SafetyCardsCompanion.insert(
            id: id,
            uuid: uuid,
            imageData: imageData,
            imageListBase64: imageListBase64,
            keyRiskConditionId: keyRiskConditionId,
            date: date,
            time: time,
            raisedById: raisedById,
            department: department,
            siteId: siteId,
            locationId: locationId,
            safetyStatus: safetyStatus,
            status: status,
            observation: observation,
            actionTaken: actionTaken,
            personResponsibleId: personResponsibleId,
            filePath: filePath,
            adminModified: adminModified,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SafetyCardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {keyRiskConditionId = false,
              raisedById = false,
              siteId = false,
              locationId = false,
              personResponsibleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (keyRiskConditionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.keyRiskConditionId,
                    referencedTable: $$SafetyCardsTableReferences
                        ._keyRiskConditionIdTable(db),
                    referencedColumn: $$SafetyCardsTableReferences
                        ._keyRiskConditionIdTable(db)
                        .id,
                  ) as T;
                }
                if (raisedById) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.raisedById,
                    referencedTable:
                        $$SafetyCardsTableReferences._raisedByIdTable(db),
                    referencedColumn:
                        $$SafetyCardsTableReferences._raisedByIdTable(db).id,
                  ) as T;
                }
                if (siteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siteId,
                    referencedTable:
                        $$SafetyCardsTableReferences._siteIdTable(db),
                    referencedColumn:
                        $$SafetyCardsTableReferences._siteIdTable(db).id,
                  ) as T;
                }
                if (locationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.locationId,
                    referencedTable:
                        $$SafetyCardsTableReferences._locationIdTable(db),
                    referencedColumn:
                        $$SafetyCardsTableReferences._locationIdTable(db).id,
                  ) as T;
                }
                if (personResponsibleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.personResponsibleId,
                    referencedTable: $$SafetyCardsTableReferences
                        ._personResponsibleIdTable(db),
                    referencedColumn: $$SafetyCardsTableReferences
                        ._personResponsibleIdTable(db)
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
        ));
}

typedef $$SafetyCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SafetyCardsTable,
    SafetyCard,
    $$SafetyCardsTableFilterComposer,
    $$SafetyCardsTableOrderingComposer,
    $$SafetyCardsTableAnnotationComposer,
    $$SafetyCardsTableCreateCompanionBuilder,
    $$SafetyCardsTableUpdateCompanionBuilder,
    (SafetyCard, $$SafetyCardsTableReferences),
    SafetyCard,
    PrefetchHooks Function(
        {bool keyRiskConditionId,
        bool raisedById,
        bool siteId,
        bool locationId,
        bool personResponsibleId})>;
typedef $$SignOffSitesTableCreateCompanionBuilder = SignOffSitesCompanion
    Function({
  Value<int> id,
  required String siteId,
  required String name,
  Value<String?> image,
  Value<bool> siteDpr,
  Value<String?> siteCustomer,
  Value<String?> temp3,
});
typedef $$SignOffSitesTableUpdateCompanionBuilder = SignOffSitesCompanion
    Function({
  Value<int> id,
  Value<String> siteId,
  Value<String> name,
  Value<String?> image,
  Value<bool> siteDpr,
  Value<String?> siteCustomer,
  Value<String?> temp3,
});

final class $$SignOffSitesTableReferences
    extends BaseReferences<_$AppDatabase, $SignOffSitesTable, SignOffSite> {
  $$SignOffSitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SignOffLocationsTable, List<SignOffLocation>>
      _signOffLocationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.signOffLocations,
              aliasName: $_aliasNameGenerator(
                  db.signOffSites.siteId, db.signOffLocations.siteId));

  $$SignOffLocationsTableProcessedTableManager get signOffLocationsRefs {
    final manager =
        $$SignOffLocationsTableTableManager($_db, $_db.signOffLocations).filter(
            (f) => f.siteId.siteId.sqlEquals($_itemColumn<String>('site_id')!));

    final cache =
        $_typedResult.readTableOrNull(_signOffLocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SafetyCommunicationsTable,
      List<SafetyCommunication>> _safetyCommunicationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.safetyCommunications,
          aliasName: $_aliasNameGenerator(
              db.signOffSites.siteId, db.safetyCommunications.siteId));

  $$SafetyCommunicationsTableProcessedTableManager
      get safetyCommunicationsRefs {
    final manager = $$SafetyCommunicationsTableTableManager(
            $_db, $_db.safetyCommunications)
        .filter(
            (f) => f.siteId.siteId.sqlEquals($_itemColumn<String>('site_id')!));

    final cache =
        $_typedResult.readTableOrNull(_safetyCommunicationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SignOffSitesTableFilterComposer
    extends Composer<_$AppDatabase, $SignOffSitesTable> {
  $$SignOffSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get siteId => $composableBuilder(
      column: $table.siteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get siteDpr => $composableBuilder(
      column: $table.siteDpr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get siteCustomer => $composableBuilder(
      column: $table.siteCustomer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get temp3 => $composableBuilder(
      column: $table.temp3, builder: (column) => ColumnFilters(column));

  Expression<bool> signOffLocationsRefs(
      Expression<bool> Function($$SignOffLocationsTableFilterComposer f) f) {
    final $$SignOffLocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffLocations,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffLocationsTableFilterComposer(
              $db: $db,
              $table: $db.signOffLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> safetyCommunicationsRefs(
      Expression<bool> Function($$SafetyCommunicationsTableFilterComposer f)
          f) {
    final $$SafetyCommunicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.safetyCommunications,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCommunicationsTableFilterComposer(
              $db: $db,
              $table: $db.safetyCommunications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SignOffSitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SignOffSitesTable> {
  $$SignOffSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get siteId => $composableBuilder(
      column: $table.siteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get siteDpr => $composableBuilder(
      column: $table.siteDpr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get siteCustomer => $composableBuilder(
      column: $table.siteCustomer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get temp3 => $composableBuilder(
      column: $table.temp3, builder: (column) => ColumnOrderings(column));
}

class $$SignOffSitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignOffSitesTable> {
  $$SignOffSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<bool> get siteDpr =>
      $composableBuilder(column: $table.siteDpr, builder: (column) => column);

  GeneratedColumn<String> get siteCustomer => $composableBuilder(
      column: $table.siteCustomer, builder: (column) => column);

  GeneratedColumn<String> get temp3 =>
      $composableBuilder(column: $table.temp3, builder: (column) => column);

  Expression<T> signOffLocationsRefs<T extends Object>(
      Expression<T> Function($$SignOffLocationsTableAnnotationComposer a) f) {
    final $$SignOffLocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffLocations,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffLocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.signOffLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> safetyCommunicationsRefs<T extends Object>(
      Expression<T> Function($$SafetyCommunicationsTableAnnotationComposer a)
          f) {
    final $$SafetyCommunicationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.siteId,
            referencedTable: $db.safetyCommunications,
            getReferencedColumn: (t) => t.siteId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SafetyCommunicationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.safetyCommunications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SignOffSitesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SignOffSitesTable,
    SignOffSite,
    $$SignOffSitesTableFilterComposer,
    $$SignOffSitesTableOrderingComposer,
    $$SignOffSitesTableAnnotationComposer,
    $$SignOffSitesTableCreateCompanionBuilder,
    $$SignOffSitesTableUpdateCompanionBuilder,
    (SignOffSite, $$SignOffSitesTableReferences),
    SignOffSite,
    PrefetchHooks Function(
        {bool signOffLocationsRefs, bool safetyCommunicationsRefs})> {
  $$SignOffSitesTableTableManager(_$AppDatabase db, $SignOffSitesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignOffSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignOffSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignOffSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> siteId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<bool> siteDpr = const Value.absent(),
            Value<String?> siteCustomer = const Value.absent(),
            Value<String?> temp3 = const Value.absent(),
          }) =>
              SignOffSitesCompanion(
            id: id,
            siteId: siteId,
            name: name,
            image: image,
            siteDpr: siteDpr,
            siteCustomer: siteCustomer,
            temp3: temp3,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String siteId,
            required String name,
            Value<String?> image = const Value.absent(),
            Value<bool> siteDpr = const Value.absent(),
            Value<String?> siteCustomer = const Value.absent(),
            Value<String?> temp3 = const Value.absent(),
          }) =>
              SignOffSitesCompanion.insert(
            id: id,
            siteId: siteId,
            name: name,
            image: image,
            siteDpr: siteDpr,
            siteCustomer: siteCustomer,
            temp3: temp3,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SignOffSitesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {signOffLocationsRefs = false,
              safetyCommunicationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (signOffLocationsRefs) db.signOffLocations,
                if (safetyCommunicationsRefs) db.safetyCommunications
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (signOffLocationsRefs)
                    await $_getPrefetchedData<SignOffSite, $SignOffSitesTable,
                            SignOffLocation>(
                        currentTable: table,
                        referencedTable: $$SignOffSitesTableReferences
                            ._signOffLocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SignOffSitesTableReferences(db, table, p0)
                                .signOffLocationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.siteId == item.siteId),
                        typedResults: items),
                  if (safetyCommunicationsRefs)
                    await $_getPrefetchedData<SignOffSite, $SignOffSitesTable,
                            SafetyCommunication>(
                        currentTable: table,
                        referencedTable: $$SignOffSitesTableReferences
                            ._safetyCommunicationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SignOffSitesTableReferences(db, table, p0)
                                .safetyCommunicationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.siteId == item.siteId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SignOffSitesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SignOffSitesTable,
    SignOffSite,
    $$SignOffSitesTableFilterComposer,
    $$SignOffSitesTableOrderingComposer,
    $$SignOffSitesTableAnnotationComposer,
    $$SignOffSitesTableCreateCompanionBuilder,
    $$SignOffSitesTableUpdateCompanionBuilder,
    (SignOffSite, $$SignOffSitesTableReferences),
    SignOffSite,
    PrefetchHooks Function(
        {bool signOffLocationsRefs, bool safetyCommunicationsRefs})>;
typedef $$SignOffLocationsTableCreateCompanionBuilder
    = SignOffLocationsCompanion Function({
  Value<int> id,
  required String locationId,
  required String name,
  Value<String?> latLong,
  required String siteId,
  Value<String?> field,
  Value<String?> taskLocation,
});
typedef $$SignOffLocationsTableUpdateCompanionBuilder
    = SignOffLocationsCompanion Function({
  Value<int> id,
  Value<String> locationId,
  Value<String> name,
  Value<String?> latLong,
  Value<String> siteId,
  Value<String?> field,
  Value<String?> taskLocation,
});

final class $$SignOffLocationsTableReferences extends BaseReferences<
    _$AppDatabase, $SignOffLocationsTable, SignOffLocation> {
  $$SignOffLocationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SignOffSitesTable _siteIdTable(_$AppDatabase db) =>
      db.signOffSites.createAlias($_aliasNameGenerator(
          db.signOffLocations.siteId, db.signOffSites.siteId));

  $$SignOffSitesTableProcessedTableManager get siteId {
    final $_column = $_itemColumn<String>('site_id')!;

    final manager = $$SignOffSitesTableTableManager($_db, $_db.signOffSites)
        .filter((f) => f.siteId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SafetyCommunicationsTable,
      List<SafetyCommunication>> _safetyCommunicationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.safetyCommunications,
          aliasName: $_aliasNameGenerator(db.signOffLocations.locationId,
              db.safetyCommunications.location));

  $$SafetyCommunicationsTableProcessedTableManager
      get safetyCommunicationsRefs {
    final manager =
        $$SafetyCommunicationsTableTableManager($_db, $_db.safetyCommunications)
            .filter((f) => f.location.locationId
                .sqlEquals($_itemColumn<String>('location_id')!));

    final cache =
        $_typedResult.readTableOrNull(_safetyCommunicationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SignOffLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $SignOffLocationsTable> {
  $$SignOffLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get latLong => $composableBuilder(
      column: $table.latLong, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get field => $composableBuilder(
      column: $table.field, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskLocation => $composableBuilder(
      column: $table.taskLocation, builder: (column) => ColumnFilters(column));

  $$SignOffSitesTableFilterComposer get siteId {
    final $$SignOffSitesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffSites,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffSitesTableFilterComposer(
              $db: $db,
              $table: $db.signOffSites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> safetyCommunicationsRefs(
      Expression<bool> Function($$SafetyCommunicationsTableFilterComposer f)
          f) {
    final $$SafetyCommunicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.safetyCommunications,
        getReferencedColumn: (t) => t.location,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCommunicationsTableFilterComposer(
              $db: $db,
              $table: $db.safetyCommunications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SignOffLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SignOffLocationsTable> {
  $$SignOffLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get latLong => $composableBuilder(
      column: $table.latLong, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get field => $composableBuilder(
      column: $table.field, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskLocation => $composableBuilder(
      column: $table.taskLocation,
      builder: (column) => ColumnOrderings(column));

  $$SignOffSitesTableOrderingComposer get siteId {
    final $$SignOffSitesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffSites,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffSitesTableOrderingComposer(
              $db: $db,
              $table: $db.signOffSites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SignOffLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignOffLocationsTable> {
  $$SignOffLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get latLong =>
      $composableBuilder(column: $table.latLong, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get taskLocation => $composableBuilder(
      column: $table.taskLocation, builder: (column) => column);

  $$SignOffSitesTableAnnotationComposer get siteId {
    final $$SignOffSitesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffSites,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffSitesTableAnnotationComposer(
              $db: $db,
              $table: $db.signOffSites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> safetyCommunicationsRefs<T extends Object>(
      Expression<T> Function($$SafetyCommunicationsTableAnnotationComposer a)
          f) {
    final $$SafetyCommunicationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.locationId,
            referencedTable: $db.safetyCommunications,
            getReferencedColumn: (t) => t.location,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SafetyCommunicationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.safetyCommunications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SignOffLocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SignOffLocationsTable,
    SignOffLocation,
    $$SignOffLocationsTableFilterComposer,
    $$SignOffLocationsTableOrderingComposer,
    $$SignOffLocationsTableAnnotationComposer,
    $$SignOffLocationsTableCreateCompanionBuilder,
    $$SignOffLocationsTableUpdateCompanionBuilder,
    (SignOffLocation, $$SignOffLocationsTableReferences),
    SignOffLocation,
    PrefetchHooks Function({bool siteId, bool safetyCommunicationsRefs})> {
  $$SignOffLocationsTableTableManager(
      _$AppDatabase db, $SignOffLocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignOffLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignOffLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignOffLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> locationId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> latLong = const Value.absent(),
            Value<String> siteId = const Value.absent(),
            Value<String?> field = const Value.absent(),
            Value<String?> taskLocation = const Value.absent(),
          }) =>
              SignOffLocationsCompanion(
            id: id,
            locationId: locationId,
            name: name,
            latLong: latLong,
            siteId: siteId,
            field: field,
            taskLocation: taskLocation,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String locationId,
            required String name,
            Value<String?> latLong = const Value.absent(),
            required String siteId,
            Value<String?> field = const Value.absent(),
            Value<String?> taskLocation = const Value.absent(),
          }) =>
              SignOffLocationsCompanion.insert(
            id: id,
            locationId: locationId,
            name: name,
            latLong: latLong,
            siteId: siteId,
            field: field,
            taskLocation: taskLocation,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SignOffLocationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {siteId = false, safetyCommunicationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (safetyCommunicationsRefs) db.safetyCommunications
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (siteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siteId,
                    referencedTable:
                        $$SignOffLocationsTableReferences._siteIdTable(db),
                    referencedColumn: $$SignOffLocationsTableReferences
                        ._siteIdTable(db)
                        .siteId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (safetyCommunicationsRefs)
                    await $_getPrefetchedData<SignOffLocation,
                            $SignOffLocationsTable, SafetyCommunication>(
                        currentTable: table,
                        referencedTable: $$SignOffLocationsTableReferences
                            ._safetyCommunicationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SignOffLocationsTableReferences(db, table, p0)
                                .safetyCommunicationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.location == item.locationId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SignOffLocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SignOffLocationsTable,
    SignOffLocation,
    $$SignOffLocationsTableFilterComposer,
    $$SignOffLocationsTableOrderingComposer,
    $$SignOffLocationsTableAnnotationComposer,
    $$SignOffLocationsTableCreateCompanionBuilder,
    $$SignOffLocationsTableUpdateCompanionBuilder,
    (SignOffLocation, $$SignOffLocationsTableReferences),
    SignOffLocation,
    PrefetchHooks Function({bool siteId, bool safetyCommunicationsRefs})>;
typedef $$SafetyCommunicationsTableCreateCompanionBuilder
    = SafetyCommunicationsCompanion Function({
  Value<int> localId,
  required String id,
  required String title,
  required String date,
  Value<String?> description,
  required String siteId,
  Value<String?> department,
  required String location,
  Value<String?> project,
  required String deliveredBy,
  required String category,
  Value<bool> induction,
  Value<bool> training,
  Value<bool> toolboxTalk,
  Value<bool> procedure,
  Value<bool> riskAssessment,
  Value<bool> coshhAssessment,
  Value<bool> other,
  Value<String?> comments,
  Value<bool> generateReport,
  Value<String?> filePath,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String?> creationDateTime,
});
typedef $$SafetyCommunicationsTableUpdateCompanionBuilder
    = SafetyCommunicationsCompanion Function({
  Value<int> localId,
  Value<String> id,
  Value<String> title,
  Value<String> date,
  Value<String?> description,
  Value<String> siteId,
  Value<String?> department,
  Value<String> location,
  Value<String?> project,
  Value<String> deliveredBy,
  Value<String> category,
  Value<bool> induction,
  Value<bool> training,
  Value<bool> toolboxTalk,
  Value<bool> procedure,
  Value<bool> riskAssessment,
  Value<bool> coshhAssessment,
  Value<bool> other,
  Value<String?> comments,
  Value<bool> generateReport,
  Value<String?> filePath,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String?> creationDateTime,
});

final class $$SafetyCommunicationsTableReferences extends BaseReferences<
    _$AppDatabase, $SafetyCommunicationsTable, SafetyCommunication> {
  $$SafetyCommunicationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SignOffSitesTable _siteIdTable(_$AppDatabase db) =>
      db.signOffSites.createAlias($_aliasNameGenerator(
          db.safetyCommunications.siteId, db.signOffSites.siteId));

  $$SignOffSitesTableProcessedTableManager get siteId {
    final $_column = $_itemColumn<String>('site_id')!;

    final manager = $$SignOffSitesTableTableManager($_db, $_db.signOffSites)
        .filter((f) => f.siteId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SignOffLocationsTable _locationTable(_$AppDatabase db) =>
      db.signOffLocations.createAlias($_aliasNameGenerator(
          db.safetyCommunications.location, db.signOffLocations.locationId));

  $$SignOffLocationsTableProcessedTableManager get location {
    final $_column = $_itemColumn<String>('location')!;

    final manager =
        $$SignOffLocationsTableTableManager($_db, $_db.signOffLocations)
            .filter((f) => f.locationId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_locationTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SafetyCommSignaturesTable,
      List<SafetyCommSignature>> _safetyCommSignaturesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.safetyCommSignatures,
          aliasName: $_aliasNameGenerator(db.safetyCommunications.id,
              db.safetyCommSignatures.communicationId));

  $$SafetyCommSignaturesTableProcessedTableManager
      get safetyCommSignaturesRefs {
    final manager = $$SafetyCommSignaturesTableTableManager(
            $_db, $_db.safetyCommSignatures)
        .filter(
            (f) => f.communicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_safetyCommSignaturesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SafetyCommunicationsTableFilterComposer
    extends Composer<_$AppDatabase, $SafetyCommunicationsTable> {
  $$SafetyCommunicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get project => $composableBuilder(
      column: $table.project, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveredBy => $composableBuilder(
      column: $table.deliveredBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get induction => $composableBuilder(
      column: $table.induction, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get training => $composableBuilder(
      column: $table.training, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get toolboxTalk => $composableBuilder(
      column: $table.toolboxTalk, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get procedure => $composableBuilder(
      column: $table.procedure, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get riskAssessment => $composableBuilder(
      column: $table.riskAssessment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get coshhAssessment => $composableBuilder(
      column: $table.coshhAssessment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get other => $composableBuilder(
      column: $table.other, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get generateReport => $composableBuilder(
      column: $table.generateReport,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creationDateTime => $composableBuilder(
      column: $table.creationDateTime,
      builder: (column) => ColumnFilters(column));

  $$SignOffSitesTableFilterComposer get siteId {
    final $$SignOffSitesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffSites,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffSitesTableFilterComposer(
              $db: $db,
              $table: $db.signOffSites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SignOffLocationsTableFilterComposer get location {
    final $$SignOffLocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.location,
        referencedTable: $db.signOffLocations,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffLocationsTableFilterComposer(
              $db: $db,
              $table: $db.signOffLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> safetyCommSignaturesRefs(
      Expression<bool> Function($$SafetyCommSignaturesTableFilterComposer f)
          f) {
    final $$SafetyCommSignaturesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.safetyCommSignatures,
        getReferencedColumn: (t) => t.communicationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCommSignaturesTableFilterComposer(
              $db: $db,
              $table: $db.safetyCommSignatures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SafetyCommunicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SafetyCommunicationsTable> {
  $$SafetyCommunicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get project => $composableBuilder(
      column: $table.project, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveredBy => $composableBuilder(
      column: $table.deliveredBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get induction => $composableBuilder(
      column: $table.induction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get training => $composableBuilder(
      column: $table.training, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get toolboxTalk => $composableBuilder(
      column: $table.toolboxTalk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get procedure => $composableBuilder(
      column: $table.procedure, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get riskAssessment => $composableBuilder(
      column: $table.riskAssessment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get coshhAssessment => $composableBuilder(
      column: $table.coshhAssessment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get other => $composableBuilder(
      column: $table.other, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get generateReport => $composableBuilder(
      column: $table.generateReport,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creationDateTime => $composableBuilder(
      column: $table.creationDateTime,
      builder: (column) => ColumnOrderings(column));

  $$SignOffSitesTableOrderingComposer get siteId {
    final $$SignOffSitesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffSites,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffSitesTableOrderingComposer(
              $db: $db,
              $table: $db.signOffSites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SignOffLocationsTableOrderingComposer get location {
    final $$SignOffLocationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.location,
        referencedTable: $db.signOffLocations,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffLocationsTableOrderingComposer(
              $db: $db,
              $table: $db.signOffLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SafetyCommunicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SafetyCommunicationsTable> {
  $$SafetyCommunicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<String> get project =>
      $composableBuilder(column: $table.project, builder: (column) => column);

  GeneratedColumn<String> get deliveredBy => $composableBuilder(
      column: $table.deliveredBy, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get induction =>
      $composableBuilder(column: $table.induction, builder: (column) => column);

  GeneratedColumn<bool> get training =>
      $composableBuilder(column: $table.training, builder: (column) => column);

  GeneratedColumn<bool> get toolboxTalk => $composableBuilder(
      column: $table.toolboxTalk, builder: (column) => column);

  GeneratedColumn<bool> get procedure =>
      $composableBuilder(column: $table.procedure, builder: (column) => column);

  GeneratedColumn<bool> get riskAssessment => $composableBuilder(
      column: $table.riskAssessment, builder: (column) => column);

  GeneratedColumn<bool> get coshhAssessment => $composableBuilder(
      column: $table.coshhAssessment, builder: (column) => column);

  GeneratedColumn<bool> get other =>
      $composableBuilder(column: $table.other, builder: (column) => column);

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

  GeneratedColumn<bool> get generateReport => $composableBuilder(
      column: $table.generateReport, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get creationDateTime => $composableBuilder(
      column: $table.creationDateTime, builder: (column) => column);

  $$SignOffSitesTableAnnotationComposer get siteId {
    final $$SignOffSitesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.signOffSites,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffSitesTableAnnotationComposer(
              $db: $db,
              $table: $db.signOffSites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SignOffLocationsTableAnnotationComposer get location {
    final $$SignOffLocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.location,
        referencedTable: $db.signOffLocations,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SignOffLocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.signOffLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> safetyCommSignaturesRefs<T extends Object>(
      Expression<T> Function($$SafetyCommSignaturesTableAnnotationComposer a)
          f) {
    final $$SafetyCommSignaturesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.safetyCommSignatures,
            getReferencedColumn: (t) => t.communicationId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SafetyCommSignaturesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.safetyCommSignatures,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SafetyCommunicationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SafetyCommunicationsTable,
    SafetyCommunication,
    $$SafetyCommunicationsTableFilterComposer,
    $$SafetyCommunicationsTableOrderingComposer,
    $$SafetyCommunicationsTableAnnotationComposer,
    $$SafetyCommunicationsTableCreateCompanionBuilder,
    $$SafetyCommunicationsTableUpdateCompanionBuilder,
    (SafetyCommunication, $$SafetyCommunicationsTableReferences),
    SafetyCommunication,
    PrefetchHooks Function(
        {bool siteId, bool location, bool safetyCommSignaturesRefs})> {
  $$SafetyCommunicationsTableTableManager(
      _$AppDatabase db, $SafetyCommunicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SafetyCommunicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SafetyCommunicationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SafetyCommunicationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> siteId = const Value.absent(),
            Value<String?> department = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String?> project = const Value.absent(),
            Value<String> deliveredBy = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<bool> induction = const Value.absent(),
            Value<bool> training = const Value.absent(),
            Value<bool> toolboxTalk = const Value.absent(),
            Value<bool> procedure = const Value.absent(),
            Value<bool> riskAssessment = const Value.absent(),
            Value<bool> coshhAssessment = const Value.absent(),
            Value<bool> other = const Value.absent(),
            Value<String?> comments = const Value.absent(),
            Value<bool> generateReport = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String?> creationDateTime = const Value.absent(),
          }) =>
              SafetyCommunicationsCompanion(
            localId: localId,
            id: id,
            title: title,
            date: date,
            description: description,
            siteId: siteId,
            department: department,
            location: location,
            project: project,
            deliveredBy: deliveredBy,
            category: category,
            induction: induction,
            training: training,
            toolboxTalk: toolboxTalk,
            procedure: procedure,
            riskAssessment: riskAssessment,
            coshhAssessment: coshhAssessment,
            other: other,
            comments: comments,
            generateReport: generateReport,
            filePath: filePath,
            isSynced: isSynced,
            isDeleted: isDeleted,
            creationDateTime: creationDateTime,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            required String id,
            required String title,
            required String date,
            Value<String?> description = const Value.absent(),
            required String siteId,
            Value<String?> department = const Value.absent(),
            required String location,
            Value<String?> project = const Value.absent(),
            required String deliveredBy,
            required String category,
            Value<bool> induction = const Value.absent(),
            Value<bool> training = const Value.absent(),
            Value<bool> toolboxTalk = const Value.absent(),
            Value<bool> procedure = const Value.absent(),
            Value<bool> riskAssessment = const Value.absent(),
            Value<bool> coshhAssessment = const Value.absent(),
            Value<bool> other = const Value.absent(),
            Value<String?> comments = const Value.absent(),
            Value<bool> generateReport = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String?> creationDateTime = const Value.absent(),
          }) =>
              SafetyCommunicationsCompanion.insert(
            localId: localId,
            id: id,
            title: title,
            date: date,
            description: description,
            siteId: siteId,
            department: department,
            location: location,
            project: project,
            deliveredBy: deliveredBy,
            category: category,
            induction: induction,
            training: training,
            toolboxTalk: toolboxTalk,
            procedure: procedure,
            riskAssessment: riskAssessment,
            coshhAssessment: coshhAssessment,
            other: other,
            comments: comments,
            generateReport: generateReport,
            filePath: filePath,
            isSynced: isSynced,
            isDeleted: isDeleted,
            creationDateTime: creationDateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SafetyCommunicationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {siteId = false,
              location = false,
              safetyCommSignaturesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (safetyCommSignaturesRefs) db.safetyCommSignatures
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (siteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siteId,
                    referencedTable:
                        $$SafetyCommunicationsTableReferences._siteIdTable(db),
                    referencedColumn: $$SafetyCommunicationsTableReferences
                        ._siteIdTable(db)
                        .siteId,
                  ) as T;
                }
                if (location) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.location,
                    referencedTable: $$SafetyCommunicationsTableReferences
                        ._locationTable(db),
                    referencedColumn: $$SafetyCommunicationsTableReferences
                        ._locationTable(db)
                        .locationId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (safetyCommSignaturesRefs)
                    await $_getPrefetchedData<SafetyCommunication,
                            $SafetyCommunicationsTable, SafetyCommSignature>(
                        currentTable: table,
                        referencedTable: $$SafetyCommunicationsTableReferences
                            ._safetyCommSignaturesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SafetyCommunicationsTableReferences(db, table, p0)
                                .safetyCommSignaturesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.communicationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SafetyCommunicationsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SafetyCommunicationsTable,
        SafetyCommunication,
        $$SafetyCommunicationsTableFilterComposer,
        $$SafetyCommunicationsTableOrderingComposer,
        $$SafetyCommunicationsTableAnnotationComposer,
        $$SafetyCommunicationsTableCreateCompanionBuilder,
        $$SafetyCommunicationsTableUpdateCompanionBuilder,
        (SafetyCommunication, $$SafetyCommunicationsTableReferences),
        SafetyCommunication,
        PrefetchHooks Function(
            {bool siteId, bool location, bool safetyCommSignaturesRefs})>;
typedef $$SafetyCommSignaturesTableCreateCompanionBuilder
    = SafetyCommSignaturesCompanion Function({
  Value<int> localId,
  required String id,
  required String communicationId,
  required String teamMember,
  Value<String?> signature,
  Value<String?> shift,
  Value<bool> isSynced,
  Value<bool> isDeleted,
});
typedef $$SafetyCommSignaturesTableUpdateCompanionBuilder
    = SafetyCommSignaturesCompanion Function({
  Value<int> localId,
  Value<String> id,
  Value<String> communicationId,
  Value<String> teamMember,
  Value<String?> signature,
  Value<String?> shift,
  Value<bool> isSynced,
  Value<bool> isDeleted,
});

final class $$SafetyCommSignaturesTableReferences extends BaseReferences<
    _$AppDatabase, $SafetyCommSignaturesTable, SafetyCommSignature> {
  $$SafetyCommSignaturesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SafetyCommunicationsTable _communicationIdTable(_$AppDatabase db) =>
      db.safetyCommunications.createAlias($_aliasNameGenerator(
          db.safetyCommSignatures.communicationId, db.safetyCommunications.id));

  $$SafetyCommunicationsTableProcessedTableManager get communicationId {
    final $_column = $_itemColumn<String>('communication_id')!;

    final manager =
        $$SafetyCommunicationsTableTableManager($_db, $_db.safetyCommunications)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_communicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SafetyCommSignaturesTableFilterComposer
    extends Composer<_$AppDatabase, $SafetyCommSignaturesTable> {
  $$SafetyCommSignaturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamMember => $composableBuilder(
      column: $table.teamMember, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signature => $composableBuilder(
      column: $table.signature, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shift => $composableBuilder(
      column: $table.shift, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  $$SafetyCommunicationsTableFilterComposer get communicationId {
    final $$SafetyCommunicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.communicationId,
        referencedTable: $db.safetyCommunications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SafetyCommunicationsTableFilterComposer(
              $db: $db,
              $table: $db.safetyCommunications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SafetyCommSignaturesTableOrderingComposer
    extends Composer<_$AppDatabase, $SafetyCommSignaturesTable> {
  $$SafetyCommSignaturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamMember => $composableBuilder(
      column: $table.teamMember, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signature => $composableBuilder(
      column: $table.signature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shift => $composableBuilder(
      column: $table.shift, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  $$SafetyCommunicationsTableOrderingComposer get communicationId {
    final $$SafetyCommunicationsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.communicationId,
            referencedTable: $db.safetyCommunications,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SafetyCommunicationsTableOrderingComposer(
                  $db: $db,
                  $table: $db.safetyCommunications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$SafetyCommSignaturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SafetyCommSignaturesTable> {
  $$SafetyCommSignaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get teamMember => $composableBuilder(
      column: $table.teamMember, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<String> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$SafetyCommunicationsTableAnnotationComposer get communicationId {
    final $$SafetyCommunicationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.communicationId,
            referencedTable: $db.safetyCommunications,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SafetyCommunicationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.safetyCommunications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$SafetyCommSignaturesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SafetyCommSignaturesTable,
    SafetyCommSignature,
    $$SafetyCommSignaturesTableFilterComposer,
    $$SafetyCommSignaturesTableOrderingComposer,
    $$SafetyCommSignaturesTableAnnotationComposer,
    $$SafetyCommSignaturesTableCreateCompanionBuilder,
    $$SafetyCommSignaturesTableUpdateCompanionBuilder,
    (SafetyCommSignature, $$SafetyCommSignaturesTableReferences),
    SafetyCommSignature,
    PrefetchHooks Function({bool communicationId})> {
  $$SafetyCommSignaturesTableTableManager(
      _$AppDatabase db, $SafetyCommSignaturesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SafetyCommSignaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SafetyCommSignaturesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SafetyCommSignaturesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> communicationId = const Value.absent(),
            Value<String> teamMember = const Value.absent(),
            Value<String?> signature = const Value.absent(),
            Value<String?> shift = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              SafetyCommSignaturesCompanion(
            localId: localId,
            id: id,
            communicationId: communicationId,
            teamMember: teamMember,
            signature: signature,
            shift: shift,
            isSynced: isSynced,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            required String id,
            required String communicationId,
            required String teamMember,
            Value<String?> signature = const Value.absent(),
            Value<String?> shift = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              SafetyCommSignaturesCompanion.insert(
            localId: localId,
            id: id,
            communicationId: communicationId,
            teamMember: teamMember,
            signature: signature,
            shift: shift,
            isSynced: isSynced,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SafetyCommSignaturesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({communicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (communicationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.communicationId,
                    referencedTable: $$SafetyCommSignaturesTableReferences
                        ._communicationIdTable(db),
                    referencedColumn: $$SafetyCommSignaturesTableReferences
                        ._communicationIdTable(db)
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
        ));
}

typedef $$SafetyCommSignaturesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SafetyCommSignaturesTable,
        SafetyCommSignature,
        $$SafetyCommSignaturesTableFilterComposer,
        $$SafetyCommSignaturesTableOrderingComposer,
        $$SafetyCommSignaturesTableAnnotationComposer,
        $$SafetyCommSignaturesTableCreateCompanionBuilder,
        $$SafetyCommSignaturesTableUpdateCompanionBuilder,
        (SafetyCommSignature, $$SafetyCommSignaturesTableReferences),
        SafetyCommSignature,
        PrefetchHooks Function({bool communicationId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$KeyRiskConditionsTableTableManager get keyRiskConditions =>
      $$KeyRiskConditionsTableTableManager(_db, _db.keyRiskConditions);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$SafetyCardsTableTableManager get safetyCards =>
      $$SafetyCardsTableTableManager(_db, _db.safetyCards);
  $$SignOffSitesTableTableManager get signOffSites =>
      $$SignOffSitesTableTableManager(_db, _db.signOffSites);
  $$SignOffLocationsTableTableManager get signOffLocations =>
      $$SignOffLocationsTableTableManager(_db, _db.signOffLocations);
  $$SafetyCommunicationsTableTableManager get safetyCommunications =>
      $$SafetyCommunicationsTableTableManager(_db, _db.safetyCommunications);
  $$SafetyCommSignaturesTableTableManager get safetyCommSignatures =>
      $$SafetyCommSignaturesTableTableManager(_db, _db.safetyCommSignatures);
}
