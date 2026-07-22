// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonIdMeta = const VerificationMeta(
    'singletonId',
  );
  @override
  late final GeneratedColumn<int> singletonId = GeneratedColumn<int>(
    'singleton_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _privacyEpochMeta = const VerificationMeta(
    'privacyEpoch',
  );
  @override
  late final GeneratedColumn<int> privacyEpoch = GeneratedColumn<int>(
    'privacy_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [singletonId, privacyEpoch];
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
    if (data.containsKey('singleton_id')) {
      context.handle(
        _singletonIdMeta,
        singletonId.isAcceptableOrUnknown(
          data['singleton_id']!,
          _singletonIdMeta,
        ),
      );
    }
    if (data.containsKey('privacy_epoch')) {
      context.handle(
        _privacyEpochMeta,
        privacyEpoch.isAcceptableOrUnknown(
          data['privacy_epoch']!,
          _privacyEpochMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonId};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      singletonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_id'],
      )!,
      privacyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int singletonId;
  final int privacyEpoch;
  const AppSetting({required this.singletonId, required this.privacyEpoch});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      singletonId: Value(singletonId),
      privacyEpoch: Value(privacyEpoch),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      singletonId: serializer.fromJson<int>(json['singletonId']),
      privacyEpoch: serializer.fromJson<int>(json['privacyEpoch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
    };
  }

  AppSetting copyWith({int? singletonId, int? privacyEpoch}) => AppSetting(
    singletonId: singletonId ?? this.singletonId,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      privacyEpoch: data.privacyEpoch.present
          ? data.privacyEpoch.value
          : this.privacyEpoch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('singletonId: $singletonId, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singletonId, privacyEpoch);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.singletonId == this.singletonId &&
          other.privacyEpoch == this.privacyEpoch);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> singletonId;
  final Value<int> privacyEpoch;
  const AppSettingsCompanion({
    this.singletonId = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.singletonId = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? singletonId,
    Expression<int>? privacyEpoch,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? singletonId,
    Value<int>? privacyEpoch,
  }) {
    return AppSettingsCompanion(
      singletonId: singletonId ?? this.singletonId,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonId.present) {
      map['singleton_id'] = Variable<int>(singletonId.value);
    }
    if (privacyEpoch.present) {
      map['privacy_epoch'] = Variable<int>(privacyEpoch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }
}

class $SenderRulesTable extends SenderRules
    with TableInfo<$SenderRulesTable, SenderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SenderRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _senderHashMeta = const VerificationMeta(
    'senderHash',
  );
  @override
  late final GeneratedColumn<String> senderHash = GeneratedColumn<String>(
    'sender_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parserFamilyMeta = const VerificationMeta(
    'parserFamily',
  );
  @override
  late final GeneratedColumn<String> parserFamily = GeneratedColumn<String>(
    'parser_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtEpochMsMeta = const VerificationMeta(
    'createdAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> createdAtEpochMs = GeneratedColumn<int>(
    'created_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderHash,
    parserFamily,
    createdAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parser_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<SenderRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sender_hash')) {
      context.handle(
        _senderHashMeta,
        senderHash.isAcceptableOrUnknown(data['sender_hash']!, _senderHashMeta),
      );
    } else if (isInserting) {
      context.missing(_senderHashMeta);
    }
    if (data.containsKey('parser_family')) {
      context.handle(
        _parserFamilyMeta,
        parserFamily.isAcceptableOrUnknown(
          data['parser_family']!,
          _parserFamilyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parserFamilyMeta);
    }
    if (data.containsKey('created_at_epoch_ms')) {
      context.handle(
        _createdAtEpochMsMeta,
        createdAtEpochMs.isAcceptableOrUnknown(
          data['created_at_epoch_ms']!,
          _createdAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SenderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SenderRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      senderHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_hash'],
      )!,
      parserFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_family'],
      )!,
      createdAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_epoch_ms'],
      )!,
    );
  }

  @override
  $SenderRulesTable createAlias(String alias) {
    return $SenderRulesTable(attachedDatabase, alias);
  }
}

class SenderRule extends DataClass implements Insertable<SenderRule> {
  final int id;
  final String senderHash;
  final String parserFamily;
  final int createdAtEpochMs;
  const SenderRule({
    required this.id,
    required this.senderHash,
    required this.parserFamily,
    required this.createdAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender_hash'] = Variable<String>(senderHash);
    map['parser_family'] = Variable<String>(parserFamily);
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    return map;
  }

  SenderRulesCompanion toCompanion(bool nullToAbsent) {
    return SenderRulesCompanion(
      id: Value(id),
      senderHash: Value(senderHash),
      parserFamily: Value(parserFamily),
      createdAtEpochMs: Value(createdAtEpochMs),
    );
  }

  factory SenderRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SenderRule(
      id: serializer.fromJson<int>(json['id']),
      senderHash: serializer.fromJson<String>(json['senderHash']),
      parserFamily: serializer.fromJson<String>(json['parserFamily']),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'senderHash': serializer.toJson<String>(senderHash),
      'parserFamily': serializer.toJson<String>(parserFamily),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
    };
  }

  SenderRule copyWith({
    int? id,
    String? senderHash,
    String? parserFamily,
    int? createdAtEpochMs,
  }) => SenderRule(
    id: id ?? this.id,
    senderHash: senderHash ?? this.senderHash,
    parserFamily: parserFamily ?? this.parserFamily,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
  );
  SenderRule copyWithCompanion(SenderRulesCompanion data) {
    return SenderRule(
      id: data.id.present ? data.id.value : this.id,
      senderHash: data.senderHash.present
          ? data.senderHash.value
          : this.senderHash,
      parserFamily: data.parserFamily.present
          ? data.parserFamily.value
          : this.parserFamily,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SenderRule(')
          ..write('id: $id, ')
          ..write('senderHash: $senderHash, ')
          ..write('parserFamily: $parserFamily, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, senderHash, parserFamily, createdAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SenderRule &&
          other.id == this.id &&
          other.senderHash == this.senderHash &&
          other.parserFamily == this.parserFamily &&
          other.createdAtEpochMs == this.createdAtEpochMs);
}

class SenderRulesCompanion extends UpdateCompanion<SenderRule> {
  final Value<int> id;
  final Value<String> senderHash;
  final Value<String> parserFamily;
  final Value<int> createdAtEpochMs;
  const SenderRulesCompanion({
    this.id = const Value.absent(),
    this.senderHash = const Value.absent(),
    this.parserFamily = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
  });
  SenderRulesCompanion.insert({
    this.id = const Value.absent(),
    required String senderHash,
    required String parserFamily,
    required int createdAtEpochMs,
  }) : senderHash = Value(senderHash),
       parserFamily = Value(parserFamily),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<SenderRule> custom({
    Expression<int>? id,
    Expression<String>? senderHash,
    Expression<String>? parserFamily,
    Expression<int>? createdAtEpochMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderHash != null) 'sender_hash': senderHash,
      if (parserFamily != null) 'parser_family': parserFamily,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
    });
  }

  SenderRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? senderHash,
    Value<String>? parserFamily,
    Value<int>? createdAtEpochMs,
  }) {
    return SenderRulesCompanion(
      id: id ?? this.id,
      senderHash: senderHash ?? this.senderHash,
      parserFamily: parserFamily ?? this.parserFamily,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (senderHash.present) {
      map['sender_hash'] = Variable<String>(senderHash.value);
    }
    if (parserFamily.present) {
      map['parser_family'] = Variable<String>(parserFamily.value);
    }
    if (createdAtEpochMs.present) {
      map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SenderRulesCompanion(')
          ..write('id: $id, ')
          ..write('senderHash: $senderHash, ')
          ..write('parserFamily: $parserFamily, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }
}

class $SmsEventsTable extends SmsEvents
    with TableInfo<$SmsEventsTable, SmsEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _senderHashMeta = const VerificationMeta(
    'senderHash',
  );
  @override
  late final GeneratedColumn<String> senderHash = GeneratedColumn<String>(
    'sender_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedBodyMeta = const VerificationMeta(
    'encryptedBody',
  );
  @override
  late final GeneratedColumn<String> encryptedBody = GeneratedColumn<String>(
    'encrypted_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _redactedBodyMeta = const VerificationMeta(
    'redactedBody',
  );
  @override
  late final GeneratedColumn<String> redactedBody = GeneratedColumn<String>(
    'redacted_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingestionSourceMeta = const VerificationMeta(
    'ingestionSource',
  );
  @override
  late final GeneratedColumn<String> ingestionSource = GeneratedColumn<String>(
    'ingestion_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtEpochMsMeta = const VerificationMeta(
    'receivedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> receivedAtEpochMs = GeneratedColumn<int>(
    'received_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtEpochMsMeta = const VerificationMeta(
    'expiresAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> expiresAtEpochMs = GeneratedColumn<int>(
    'expires_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _privacyEpochMeta = const VerificationMeta(
    'privacyEpoch',
  );
  @override
  late final GeneratedColumn<int> privacyEpoch = GeneratedColumn<int>(
    'privacy_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceKey,
    senderHash,
    encryptedBody,
    redactedBody,
    ingestionSource,
    receivedAtEpochMs,
    expiresAtEpochMs,
    status,
    privacyEpoch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('sender_hash')) {
      context.handle(
        _senderHashMeta,
        senderHash.isAcceptableOrUnknown(data['sender_hash']!, _senderHashMeta),
      );
    } else if (isInserting) {
      context.missing(_senderHashMeta);
    }
    if (data.containsKey('encrypted_body')) {
      context.handle(
        _encryptedBodyMeta,
        encryptedBody.isAcceptableOrUnknown(
          data['encrypted_body']!,
          _encryptedBodyMeta,
        ),
      );
    }
    if (data.containsKey('redacted_body')) {
      context.handle(
        _redactedBodyMeta,
        redactedBody.isAcceptableOrUnknown(
          data['redacted_body']!,
          _redactedBodyMeta,
        ),
      );
    }
    if (data.containsKey('ingestion_source')) {
      context.handle(
        _ingestionSourceMeta,
        ingestionSource.isAcceptableOrUnknown(
          data['ingestion_source']!,
          _ingestionSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingestionSourceMeta);
    }
    if (data.containsKey('received_at_epoch_ms')) {
      context.handle(
        _receivedAtEpochMsMeta,
        receivedAtEpochMs.isAcceptableOrUnknown(
          data['received_at_epoch_ms']!,
          _receivedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedAtEpochMsMeta);
    }
    if (data.containsKey('expires_at_epoch_ms')) {
      context.handle(
        _expiresAtEpochMsMeta,
        expiresAtEpochMs.isAcceptableOrUnknown(
          data['expires_at_epoch_ms']!,
          _expiresAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('privacy_epoch')) {
      context.handle(
        _privacyEpochMeta,
        privacyEpoch.isAcceptableOrUnknown(
          data['privacy_epoch']!,
          _privacyEpochMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyEpochMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      senderHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_hash'],
      )!,
      encryptedBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_body'],
      ),
      redactedBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redacted_body'],
      ),
      ingestionSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingestion_source'],
      )!,
      receivedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at_epoch_ms'],
      )!,
      expiresAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at_epoch_ms'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      privacyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch'],
      )!,
    );
  }

  @override
  $SmsEventsTable createAlias(String alias) {
    return $SmsEventsTable(attachedDatabase, alias);
  }
}

class SmsEvent extends DataClass implements Insertable<SmsEvent> {
  final int id;
  final String sourceKey;
  final String senderHash;
  final String? encryptedBody;
  final String? redactedBody;
  final String ingestionSource;
  final int receivedAtEpochMs;
  final int? expiresAtEpochMs;
  final String status;
  final int privacyEpoch;
  const SmsEvent({
    required this.id,
    required this.sourceKey,
    required this.senderHash,
    this.encryptedBody,
    this.redactedBody,
    required this.ingestionSource,
    required this.receivedAtEpochMs,
    this.expiresAtEpochMs,
    required this.status,
    required this.privacyEpoch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_key'] = Variable<String>(sourceKey);
    map['sender_hash'] = Variable<String>(senderHash);
    if (!nullToAbsent || encryptedBody != null) {
      map['encrypted_body'] = Variable<String>(encryptedBody);
    }
    if (!nullToAbsent || redactedBody != null) {
      map['redacted_body'] = Variable<String>(redactedBody);
    }
    map['ingestion_source'] = Variable<String>(ingestionSource);
    map['received_at_epoch_ms'] = Variable<int>(receivedAtEpochMs);
    if (!nullToAbsent || expiresAtEpochMs != null) {
      map['expires_at_epoch_ms'] = Variable<int>(expiresAtEpochMs);
    }
    map['status'] = Variable<String>(status);
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    return map;
  }

  SmsEventsCompanion toCompanion(bool nullToAbsent) {
    return SmsEventsCompanion(
      id: Value(id),
      sourceKey: Value(sourceKey),
      senderHash: Value(senderHash),
      encryptedBody: encryptedBody == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedBody),
      redactedBody: redactedBody == null && nullToAbsent
          ? const Value.absent()
          : Value(redactedBody),
      ingestionSource: Value(ingestionSource),
      receivedAtEpochMs: Value(receivedAtEpochMs),
      expiresAtEpochMs: expiresAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAtEpochMs),
      status: Value(status),
      privacyEpoch: Value(privacyEpoch),
    );
  }

  factory SmsEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsEvent(
      id: serializer.fromJson<int>(json['id']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      senderHash: serializer.fromJson<String>(json['senderHash']),
      encryptedBody: serializer.fromJson<String?>(json['encryptedBody']),
      redactedBody: serializer.fromJson<String?>(json['redactedBody']),
      ingestionSource: serializer.fromJson<String>(json['ingestionSource']),
      receivedAtEpochMs: serializer.fromJson<int>(json['receivedAtEpochMs']),
      expiresAtEpochMs: serializer.fromJson<int?>(json['expiresAtEpochMs']),
      status: serializer.fromJson<String>(json['status']),
      privacyEpoch: serializer.fromJson<int>(json['privacyEpoch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'senderHash': serializer.toJson<String>(senderHash),
      'encryptedBody': serializer.toJson<String?>(encryptedBody),
      'redactedBody': serializer.toJson<String?>(redactedBody),
      'ingestionSource': serializer.toJson<String>(ingestionSource),
      'receivedAtEpochMs': serializer.toJson<int>(receivedAtEpochMs),
      'expiresAtEpochMs': serializer.toJson<int?>(expiresAtEpochMs),
      'status': serializer.toJson<String>(status),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
    };
  }

  SmsEvent copyWith({
    int? id,
    String? sourceKey,
    String? senderHash,
    Value<String?> encryptedBody = const Value.absent(),
    Value<String?> redactedBody = const Value.absent(),
    String? ingestionSource,
    int? receivedAtEpochMs,
    Value<int?> expiresAtEpochMs = const Value.absent(),
    String? status,
    int? privacyEpoch,
  }) => SmsEvent(
    id: id ?? this.id,
    sourceKey: sourceKey ?? this.sourceKey,
    senderHash: senderHash ?? this.senderHash,
    encryptedBody: encryptedBody.present
        ? encryptedBody.value
        : this.encryptedBody,
    redactedBody: redactedBody.present ? redactedBody.value : this.redactedBody,
    ingestionSource: ingestionSource ?? this.ingestionSource,
    receivedAtEpochMs: receivedAtEpochMs ?? this.receivedAtEpochMs,
    expiresAtEpochMs: expiresAtEpochMs.present
        ? expiresAtEpochMs.value
        : this.expiresAtEpochMs,
    status: status ?? this.status,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
  );
  SmsEvent copyWithCompanion(SmsEventsCompanion data) {
    return SmsEvent(
      id: data.id.present ? data.id.value : this.id,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      senderHash: data.senderHash.present
          ? data.senderHash.value
          : this.senderHash,
      encryptedBody: data.encryptedBody.present
          ? data.encryptedBody.value
          : this.encryptedBody,
      redactedBody: data.redactedBody.present
          ? data.redactedBody.value
          : this.redactedBody,
      ingestionSource: data.ingestionSource.present
          ? data.ingestionSource.value
          : this.ingestionSource,
      receivedAtEpochMs: data.receivedAtEpochMs.present
          ? data.receivedAtEpochMs.value
          : this.receivedAtEpochMs,
      expiresAtEpochMs: data.expiresAtEpochMs.present
          ? data.expiresAtEpochMs.value
          : this.expiresAtEpochMs,
      status: data.status.present ? data.status.value : this.status,
      privacyEpoch: data.privacyEpoch.present
          ? data.privacyEpoch.value
          : this.privacyEpoch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsEvent(')
          ..write('id: $id, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('senderHash: $senderHash, ')
          ..write('encryptedBody: $encryptedBody, ')
          ..write('redactedBody: $redactedBody, ')
          ..write('ingestionSource: $ingestionSource, ')
          ..write('receivedAtEpochMs: $receivedAtEpochMs, ')
          ..write('expiresAtEpochMs: $expiresAtEpochMs, ')
          ..write('status: $status, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceKey,
    senderHash,
    encryptedBody,
    redactedBody,
    ingestionSource,
    receivedAtEpochMs,
    expiresAtEpochMs,
    status,
    privacyEpoch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsEvent &&
          other.id == this.id &&
          other.sourceKey == this.sourceKey &&
          other.senderHash == this.senderHash &&
          other.encryptedBody == this.encryptedBody &&
          other.redactedBody == this.redactedBody &&
          other.ingestionSource == this.ingestionSource &&
          other.receivedAtEpochMs == this.receivedAtEpochMs &&
          other.expiresAtEpochMs == this.expiresAtEpochMs &&
          other.status == this.status &&
          other.privacyEpoch == this.privacyEpoch);
}

class SmsEventsCompanion extends UpdateCompanion<SmsEvent> {
  final Value<int> id;
  final Value<String> sourceKey;
  final Value<String> senderHash;
  final Value<String?> encryptedBody;
  final Value<String?> redactedBody;
  final Value<String> ingestionSource;
  final Value<int> receivedAtEpochMs;
  final Value<int?> expiresAtEpochMs;
  final Value<String> status;
  final Value<int> privacyEpoch;
  const SmsEventsCompanion({
    this.id = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.senderHash = const Value.absent(),
    this.encryptedBody = const Value.absent(),
    this.redactedBody = const Value.absent(),
    this.ingestionSource = const Value.absent(),
    this.receivedAtEpochMs = const Value.absent(),
    this.expiresAtEpochMs = const Value.absent(),
    this.status = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  SmsEventsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceKey,
    required String senderHash,
    this.encryptedBody = const Value.absent(),
    this.redactedBody = const Value.absent(),
    required String ingestionSource,
    required int receivedAtEpochMs,
    this.expiresAtEpochMs = const Value.absent(),
    required String status,
    required int privacyEpoch,
  }) : sourceKey = Value(sourceKey),
       senderHash = Value(senderHash),
       ingestionSource = Value(ingestionSource),
       receivedAtEpochMs = Value(receivedAtEpochMs),
       status = Value(status),
       privacyEpoch = Value(privacyEpoch);
  static Insertable<SmsEvent> custom({
    Expression<int>? id,
    Expression<String>? sourceKey,
    Expression<String>? senderHash,
    Expression<String>? encryptedBody,
    Expression<String>? redactedBody,
    Expression<String>? ingestionSource,
    Expression<int>? receivedAtEpochMs,
    Expression<int>? expiresAtEpochMs,
    Expression<String>? status,
    Expression<int>? privacyEpoch,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceKey != null) 'source_key': sourceKey,
      if (senderHash != null) 'sender_hash': senderHash,
      if (encryptedBody != null) 'encrypted_body': encryptedBody,
      if (redactedBody != null) 'redacted_body': redactedBody,
      if (ingestionSource != null) 'ingestion_source': ingestionSource,
      if (receivedAtEpochMs != null) 'received_at_epoch_ms': receivedAtEpochMs,
      if (expiresAtEpochMs != null) 'expires_at_epoch_ms': expiresAtEpochMs,
      if (status != null) 'status': status,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
    });
  }

  SmsEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceKey,
    Value<String>? senderHash,
    Value<String?>? encryptedBody,
    Value<String?>? redactedBody,
    Value<String>? ingestionSource,
    Value<int>? receivedAtEpochMs,
    Value<int?>? expiresAtEpochMs,
    Value<String>? status,
    Value<int>? privacyEpoch,
  }) {
    return SmsEventsCompanion(
      id: id ?? this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      senderHash: senderHash ?? this.senderHash,
      encryptedBody: encryptedBody ?? this.encryptedBody,
      redactedBody: redactedBody ?? this.redactedBody,
      ingestionSource: ingestionSource ?? this.ingestionSource,
      receivedAtEpochMs: receivedAtEpochMs ?? this.receivedAtEpochMs,
      expiresAtEpochMs: expiresAtEpochMs ?? this.expiresAtEpochMs,
      status: status ?? this.status,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (senderHash.present) {
      map['sender_hash'] = Variable<String>(senderHash.value);
    }
    if (encryptedBody.present) {
      map['encrypted_body'] = Variable<String>(encryptedBody.value);
    }
    if (redactedBody.present) {
      map['redacted_body'] = Variable<String>(redactedBody.value);
    }
    if (ingestionSource.present) {
      map['ingestion_source'] = Variable<String>(ingestionSource.value);
    }
    if (receivedAtEpochMs.present) {
      map['received_at_epoch_ms'] = Variable<int>(receivedAtEpochMs.value);
    }
    if (expiresAtEpochMs.present) {
      map['expires_at_epoch_ms'] = Variable<int>(expiresAtEpochMs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (privacyEpoch.present) {
      map['privacy_epoch'] = Variable<int>(privacyEpoch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsEventsCompanion(')
          ..write('id: $id, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('senderHash: $senderHash, ')
          ..write('encryptedBody: $encryptedBody, ')
          ..write('redactedBody: $redactedBody, ')
          ..write('ingestionSource: $ingestionSource, ')
          ..write('receivedAtEpochMs: $receivedAtEpochMs, ')
          ..write('expiresAtEpochMs: $expiresAtEpochMs, ')
          ..write('status: $status, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }
}

class $TransactionCandidatesTable extends TransactionCandidates
    with TableInfo<$TransactionCandidatesTable, TransactionCandidate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionCandidatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _smsEventIdMeta = const VerificationMeta(
    'smsEventId',
  );
  @override
  late final GeneratedColumn<int> smsEventId = GeneratedColumn<int>(
    'sms_event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES sms_events (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CandidateRecordState, String>
  state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CandidateRecordState>(
        $TransactionCandidatesTable.$converterstate,
      );
  static const VerificationMeta _encryptedPayloadMeta = const VerificationMeta(
    'encryptedPayload',
  );
  @override
  late final GeneratedColumn<String> encryptedPayload = GeneratedColumn<String>(
    'encrypted_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtEpochMsMeta = const VerificationMeta(
    'createdAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> createdAtEpochMs = GeneratedColumn<int>(
    'created_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    smsEventId,
    state,
    encryptedPayload,
    revision,
    createdAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_candidates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionCandidate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sms_event_id')) {
      context.handle(
        _smsEventIdMeta,
        smsEventId.isAcceptableOrUnknown(
          data['sms_event_id']!,
          _smsEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_smsEventIdMeta);
    }
    if (data.containsKey('encrypted_payload')) {
      context.handle(
        _encryptedPayloadMeta,
        encryptedPayload.isAcceptableOrUnknown(
          data['encrypted_payload']!,
          _encryptedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPayloadMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('created_at_epoch_ms')) {
      context.handle(
        _createdAtEpochMsMeta,
        createdAtEpochMs.isAcceptableOrUnknown(
          data['created_at_epoch_ms']!,
          _createdAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionCandidate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionCandidate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      smsEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sms_event_id'],
      )!,
      state: $TransactionCandidatesTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      encryptedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_payload'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_epoch_ms'],
      )!,
    );
  }

  @override
  $TransactionCandidatesTable createAlias(String alias) {
    return $TransactionCandidatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CandidateRecordState, String, String>
  $converterstate = const EnumNameConverter<CandidateRecordState>(
    CandidateRecordState.values,
  );
}

class TransactionCandidate extends DataClass
    implements Insertable<TransactionCandidate> {
  final int id;
  final int smsEventId;
  final CandidateRecordState state;
  final String encryptedPayload;
  final int revision;
  final int createdAtEpochMs;
  const TransactionCandidate({
    required this.id,
    required this.smsEventId,
    required this.state,
    required this.encryptedPayload,
    required this.revision,
    required this.createdAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sms_event_id'] = Variable<int>(smsEventId);
    {
      map['state'] = Variable<String>(
        $TransactionCandidatesTable.$converterstate.toSql(state),
      );
    }
    map['encrypted_payload'] = Variable<String>(encryptedPayload);
    map['revision'] = Variable<int>(revision);
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    return map;
  }

  TransactionCandidatesCompanion toCompanion(bool nullToAbsent) {
    return TransactionCandidatesCompanion(
      id: Value(id),
      smsEventId: Value(smsEventId),
      state: Value(state),
      encryptedPayload: Value(encryptedPayload),
      revision: Value(revision),
      createdAtEpochMs: Value(createdAtEpochMs),
    );
  }

  factory TransactionCandidate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionCandidate(
      id: serializer.fromJson<int>(json['id']),
      smsEventId: serializer.fromJson<int>(json['smsEventId']),
      state: $TransactionCandidatesTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      encryptedPayload: serializer.fromJson<String>(json['encryptedPayload']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'smsEventId': serializer.toJson<int>(smsEventId),
      'state': serializer.toJson<String>(
        $TransactionCandidatesTable.$converterstate.toJson(state),
      ),
      'encryptedPayload': serializer.toJson<String>(encryptedPayload),
      'revision': serializer.toJson<int>(revision),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
    };
  }

  TransactionCandidate copyWith({
    int? id,
    int? smsEventId,
    CandidateRecordState? state,
    String? encryptedPayload,
    int? revision,
    int? createdAtEpochMs,
  }) => TransactionCandidate(
    id: id ?? this.id,
    smsEventId: smsEventId ?? this.smsEventId,
    state: state ?? this.state,
    encryptedPayload: encryptedPayload ?? this.encryptedPayload,
    revision: revision ?? this.revision,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
  );
  TransactionCandidate copyWithCompanion(TransactionCandidatesCompanion data) {
    return TransactionCandidate(
      id: data.id.present ? data.id.value : this.id,
      smsEventId: data.smsEventId.present
          ? data.smsEventId.value
          : this.smsEventId,
      state: data.state.present ? data.state.value : this.state,
      encryptedPayload: data.encryptedPayload.present
          ? data.encryptedPayload.value
          : this.encryptedPayload,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCandidate(')
          ..write('id: $id, ')
          ..write('smsEventId: $smsEventId, ')
          ..write('state: $state, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('revision: $revision, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    smsEventId,
    state,
    encryptedPayload,
    revision,
    createdAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionCandidate &&
          other.id == this.id &&
          other.smsEventId == this.smsEventId &&
          other.state == this.state &&
          other.encryptedPayload == this.encryptedPayload &&
          other.revision == this.revision &&
          other.createdAtEpochMs == this.createdAtEpochMs);
}

class TransactionCandidatesCompanion
    extends UpdateCompanion<TransactionCandidate> {
  final Value<int> id;
  final Value<int> smsEventId;
  final Value<CandidateRecordState> state;
  final Value<String> encryptedPayload;
  final Value<int> revision;
  final Value<int> createdAtEpochMs;
  const TransactionCandidatesCompanion({
    this.id = const Value.absent(),
    this.smsEventId = const Value.absent(),
    this.state = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
  });
  TransactionCandidatesCompanion.insert({
    this.id = const Value.absent(),
    required int smsEventId,
    required CandidateRecordState state,
    required String encryptedPayload,
    required int revision,
    required int createdAtEpochMs,
  }) : smsEventId = Value(smsEventId),
       state = Value(state),
       encryptedPayload = Value(encryptedPayload),
       revision = Value(revision),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<TransactionCandidate> custom({
    Expression<int>? id,
    Expression<int>? smsEventId,
    Expression<String>? state,
    Expression<String>? encryptedPayload,
    Expression<int>? revision,
    Expression<int>? createdAtEpochMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (smsEventId != null) 'sms_event_id': smsEventId,
      if (state != null) 'state': state,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (revision != null) 'revision': revision,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
    });
  }

  TransactionCandidatesCompanion copyWith({
    Value<int>? id,
    Value<int>? smsEventId,
    Value<CandidateRecordState>? state,
    Value<String>? encryptedPayload,
    Value<int>? revision,
    Value<int>? createdAtEpochMs,
  }) {
    return TransactionCandidatesCompanion(
      id: id ?? this.id,
      smsEventId: smsEventId ?? this.smsEventId,
      state: state ?? this.state,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      revision: revision ?? this.revision,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (smsEventId.present) {
      map['sms_event_id'] = Variable<int>(smsEventId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $TransactionCandidatesTable.$converterstate.toSql(state.value),
      );
    }
    if (encryptedPayload.present) {
      map['encrypted_payload'] = Variable<String>(encryptedPayload.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAtEpochMs.present) {
      map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCandidatesCompanion(')
          ..write('id: $id, ')
          ..write('smsEventId: $smsEventId, ')
          ..write('state: $state, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('revision: $revision, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<ActivityEventCode, String>
  eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityEventCode>($ActivityEventsTable.$convertereventType);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityStateTransition, String>
  sanitizedDetail =
      GeneratedColumn<String>(
        'sanitized_detail',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActivityStateTransition>(
        $ActivityEventsTable.$convertersanitizedDetail,
      );
  static const VerificationMeta _occurredAtEpochMsMeta = const VerificationMeta(
    'occurredAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> occurredAtEpochMs = GeneratedColumn<int>(
    'occurred_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyEpochMeta = const VerificationMeta(
    'privacyEpoch',
  );
  @override
  late final GeneratedColumn<int> privacyEpoch = GeneratedColumn<int>(
    'privacy_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    sanitizedDetail,
    occurredAtEpochMs,
    privacyEpoch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('occurred_at_epoch_ms')) {
      context.handle(
        _occurredAtEpochMsMeta,
        occurredAtEpochMs.isAcceptableOrUnknown(
          data['occurred_at_epoch_ms']!,
          _occurredAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtEpochMsMeta);
    }
    if (data.containsKey('privacy_epoch')) {
      context.handle(
        _privacyEpochMeta,
        privacyEpoch.isAcceptableOrUnknown(
          data['privacy_epoch']!,
          _privacyEpochMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyEpochMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventType: $ActivityEventsTable.$convertereventType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event_type'],
        )!,
      ),
      sanitizedDetail: $ActivityEventsTable.$convertersanitizedDetail.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sanitized_detail'],
        )!,
      ),
      occurredAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_epoch_ms'],
      )!,
      privacyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch'],
      )!,
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityEventCode, String, String>
  $convertereventType = const EnumNameConverter<ActivityEventCode>(
    ActivityEventCode.values,
  );
  static JsonTypeConverter2<ActivityStateTransition, String, String>
  $convertersanitizedDetail = const EnumNameConverter<ActivityStateTransition>(
    ActivityStateTransition.values,
  );
}

class ActivityEvent extends DataClass implements Insertable<ActivityEvent> {
  final int id;
  final ActivityEventCode eventType;
  final ActivityStateTransition sanitizedDetail;
  final int occurredAtEpochMs;
  final int privacyEpoch;
  const ActivityEvent({
    required this.id,
    required this.eventType,
    required this.sanitizedDetail,
    required this.occurredAtEpochMs,
    required this.privacyEpoch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['event_type'] = Variable<String>(
        $ActivityEventsTable.$convertereventType.toSql(eventType),
      );
    }
    {
      map['sanitized_detail'] = Variable<String>(
        $ActivityEventsTable.$convertersanitizedDetail.toSql(sanitizedDetail),
      );
    }
    map['occurred_at_epoch_ms'] = Variable<int>(occurredAtEpochMs);
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      sanitizedDetail: Value(sanitizedDetail),
      occurredAtEpochMs: Value(occurredAtEpochMs),
      privacyEpoch: Value(privacyEpoch),
    );
  }

  factory ActivityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEvent(
      id: serializer.fromJson<int>(json['id']),
      eventType: $ActivityEventsTable.$convertereventType.fromJson(
        serializer.fromJson<String>(json['eventType']),
      ),
      sanitizedDetail: $ActivityEventsTable.$convertersanitizedDetail.fromJson(
        serializer.fromJson<String>(json['sanitizedDetail']),
      ),
      occurredAtEpochMs: serializer.fromJson<int>(json['occurredAtEpochMs']),
      privacyEpoch: serializer.fromJson<int>(json['privacyEpoch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventType': serializer.toJson<String>(
        $ActivityEventsTable.$convertereventType.toJson(eventType),
      ),
      'sanitizedDetail': serializer.toJson<String>(
        $ActivityEventsTable.$convertersanitizedDetail.toJson(sanitizedDetail),
      ),
      'occurredAtEpochMs': serializer.toJson<int>(occurredAtEpochMs),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
    };
  }

  ActivityEvent copyWith({
    int? id,
    ActivityEventCode? eventType,
    ActivityStateTransition? sanitizedDetail,
    int? occurredAtEpochMs,
    int? privacyEpoch,
  }) => ActivityEvent(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    sanitizedDetail: sanitizedDetail ?? this.sanitizedDetail,
    occurredAtEpochMs: occurredAtEpochMs ?? this.occurredAtEpochMs,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
  );
  ActivityEvent copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      sanitizedDetail: data.sanitizedDetail.present
          ? data.sanitizedDetail.value
          : this.sanitizedDetail,
      occurredAtEpochMs: data.occurredAtEpochMs.present
          ? data.occurredAtEpochMs.value
          : this.occurredAtEpochMs,
      privacyEpoch: data.privacyEpoch.present
          ? data.privacyEpoch.value
          : this.privacyEpoch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('sanitizedDetail: $sanitizedDetail, ')
          ..write('occurredAtEpochMs: $occurredAtEpochMs, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventType,
    sanitizedDetail,
    occurredAtEpochMs,
    privacyEpoch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.sanitizedDetail == this.sanitizedDetail &&
          other.occurredAtEpochMs == this.occurredAtEpochMs &&
          other.privacyEpoch == this.privacyEpoch);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<int> id;
  final Value<ActivityEventCode> eventType;
  final Value<ActivityStateTransition> sanitizedDetail;
  final Value<int> occurredAtEpochMs;
  final Value<int> privacyEpoch;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.sanitizedDetail = const Value.absent(),
    this.occurredAtEpochMs = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    this.id = const Value.absent(),
    required ActivityEventCode eventType,
    required ActivityStateTransition sanitizedDetail,
    required int occurredAtEpochMs,
    required int privacyEpoch,
  }) : eventType = Value(eventType),
       sanitizedDetail = Value(sanitizedDetail),
       occurredAtEpochMs = Value(occurredAtEpochMs),
       privacyEpoch = Value(privacyEpoch);
  static Insertable<ActivityEvent> custom({
    Expression<int>? id,
    Expression<String>? eventType,
    Expression<String>? sanitizedDetail,
    Expression<int>? occurredAtEpochMs,
    Expression<int>? privacyEpoch,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (sanitizedDetail != null) 'sanitized_detail': sanitizedDetail,
      if (occurredAtEpochMs != null) 'occurred_at_epoch_ms': occurredAtEpochMs,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<int>? id,
    Value<ActivityEventCode>? eventType,
    Value<ActivityStateTransition>? sanitizedDetail,
    Value<int>? occurredAtEpochMs,
    Value<int>? privacyEpoch,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      sanitizedDetail: sanitizedDetail ?? this.sanitizedDetail,
      occurredAtEpochMs: occurredAtEpochMs ?? this.occurredAtEpochMs,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(
        $ActivityEventsTable.$convertereventType.toSql(eventType.value),
      );
    }
    if (sanitizedDetail.present) {
      map['sanitized_detail'] = Variable<String>(
        $ActivityEventsTable.$convertersanitizedDetail.toSql(
          sanitizedDetail.value,
        ),
      );
    }
    if (occurredAtEpochMs.present) {
      map['occurred_at_epoch_ms'] = Variable<int>(occurredAtEpochMs.value);
    }
    if (privacyEpoch.present) {
      map['privacy_epoch'] = Variable<int>(privacyEpoch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('sanitizedDetail: $sanitizedDetail, ')
          ..write('occurredAtEpochMs: $occurredAtEpochMs, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }
}

class $DecisionTracesTable extends DecisionTraces
    with TableInfo<$DecisionTracesTable, DecisionTrace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionTracesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<int> candidateId = GeneratedColumn<int>(
    'candidate_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transaction_candidates (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DecisionTraceCode, String>
  traceCode = GeneratedColumn<String>(
    'trace_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DecisionTraceCode>($DecisionTracesTable.$convertertraceCode);
  static const VerificationMeta _createdAtEpochMsMeta = const VerificationMeta(
    'createdAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> createdAtEpochMs = GeneratedColumn<int>(
    'created_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    candidateId,
    traceCode,
    createdAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decision_traces';
  @override
  VerificationContext validateIntegrity(
    Insertable<DecisionTrace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_epoch_ms')) {
      context.handle(
        _createdAtEpochMsMeta,
        createdAtEpochMs.isAcceptableOrUnknown(
          data['created_at_epoch_ms']!,
          _createdAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DecisionTrace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DecisionTrace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}candidate_id'],
      ),
      traceCode: $DecisionTracesTable.$convertertraceCode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trace_code'],
        )!,
      ),
      createdAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_epoch_ms'],
      )!,
    );
  }

  @override
  $DecisionTracesTable createAlias(String alias) {
    return $DecisionTracesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DecisionTraceCode, String, String>
  $convertertraceCode = const EnumNameConverter<DecisionTraceCode>(
    DecisionTraceCode.values,
  );
}

class DecisionTrace extends DataClass implements Insertable<DecisionTrace> {
  final int id;
  final int? candidateId;
  final DecisionTraceCode traceCode;
  final int createdAtEpochMs;
  const DecisionTrace({
    required this.id,
    this.candidateId,
    required this.traceCode,
    required this.createdAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || candidateId != null) {
      map['candidate_id'] = Variable<int>(candidateId);
    }
    {
      map['trace_code'] = Variable<String>(
        $DecisionTracesTable.$convertertraceCode.toSql(traceCode),
      );
    }
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    return map;
  }

  DecisionTracesCompanion toCompanion(bool nullToAbsent) {
    return DecisionTracesCompanion(
      id: Value(id),
      candidateId: candidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateId),
      traceCode: Value(traceCode),
      createdAtEpochMs: Value(createdAtEpochMs),
    );
  }

  factory DecisionTrace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DecisionTrace(
      id: serializer.fromJson<int>(json['id']),
      candidateId: serializer.fromJson<int?>(json['candidateId']),
      traceCode: $DecisionTracesTable.$convertertraceCode.fromJson(
        serializer.fromJson<String>(json['traceCode']),
      ),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'candidateId': serializer.toJson<int?>(candidateId),
      'traceCode': serializer.toJson<String>(
        $DecisionTracesTable.$convertertraceCode.toJson(traceCode),
      ),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
    };
  }

  DecisionTrace copyWith({
    int? id,
    Value<int?> candidateId = const Value.absent(),
    DecisionTraceCode? traceCode,
    int? createdAtEpochMs,
  }) => DecisionTrace(
    id: id ?? this.id,
    candidateId: candidateId.present ? candidateId.value : this.candidateId,
    traceCode: traceCode ?? this.traceCode,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
  );
  DecisionTrace copyWithCompanion(DecisionTracesCompanion data) {
    return DecisionTrace(
      id: data.id.present ? data.id.value : this.id,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      traceCode: data.traceCode.present ? data.traceCode.value : this.traceCode,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DecisionTrace(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('traceCode: $traceCode, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, candidateId, traceCode, createdAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DecisionTrace &&
          other.id == this.id &&
          other.candidateId == this.candidateId &&
          other.traceCode == this.traceCode &&
          other.createdAtEpochMs == this.createdAtEpochMs);
}

class DecisionTracesCompanion extends UpdateCompanion<DecisionTrace> {
  final Value<int> id;
  final Value<int?> candidateId;
  final Value<DecisionTraceCode> traceCode;
  final Value<int> createdAtEpochMs;
  const DecisionTracesCompanion({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.traceCode = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
  });
  DecisionTracesCompanion.insert({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
    required DecisionTraceCode traceCode,
    required int createdAtEpochMs,
  }) : traceCode = Value(traceCode),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<DecisionTrace> custom({
    Expression<int>? id,
    Expression<int>? candidateId,
    Expression<String>? traceCode,
    Expression<int>? createdAtEpochMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      if (traceCode != null) 'trace_code': traceCode,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
    });
  }

  DecisionTracesCompanion copyWith({
    Value<int>? id,
    Value<int?>? candidateId,
    Value<DecisionTraceCode>? traceCode,
    Value<int>? createdAtEpochMs,
  }) {
    return DecisionTracesCompanion(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      traceCode: traceCode ?? this.traceCode,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<int>(candidateId.value);
    }
    if (traceCode.present) {
      map['trace_code'] = Variable<String>(
        $DecisionTracesTable.$convertertraceCode.toSql(traceCode.value),
      );
    }
    if (createdAtEpochMs.present) {
      map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionTracesCompanion(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('traceCode: $traceCode, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }
}

class $DatabaseMetadataTable extends DatabaseMetadata
    with TableInfo<$DatabaseMetadataTable, DatabaseMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabaseMetadataTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'schema_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabaseMetadataData> instance, {
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
  DatabaseMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseMetadataData(
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
  $DatabaseMetadataTable createAlias(String alias) {
    return $DatabaseMetadataTable(attachedDatabase, alias);
  }
}

class DatabaseMetadataData extends DataClass
    implements Insertable<DatabaseMetadataData> {
  final String key;
  final String value;
  const DatabaseMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  DatabaseMetadataCompanion toCompanion(bool nullToAbsent) {
    return DatabaseMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory DatabaseMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseMetadataData(
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

  DatabaseMetadataData copyWith({String? key, String? value}) =>
      DatabaseMetadataData(key: key ?? this.key, value: value ?? this.value);
  DatabaseMetadataData copyWithCompanion(DatabaseMetadataCompanion data) {
    return DatabaseMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseMetadataData(')
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
      (other is DatabaseMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class DatabaseMetadataCompanion extends UpdateCompanion<DatabaseMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const DatabaseMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatabaseMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DatabaseMetadataData> custom({
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

  DatabaseMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return DatabaseMetadataCompanion(
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
    return (StringBuffer('DatabaseMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SenderRulesTable senderRules = $SenderRulesTable(this);
  late final $SmsEventsTable smsEvents = $SmsEventsTable(this);
  late final $TransactionCandidatesTable transactionCandidates =
      $TransactionCandidatesTable(this);
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $DecisionTracesTable decisionTraces = $DecisionTracesTable(this);
  late final $DatabaseMetadataTable databaseMetadata = $DatabaseMetadataTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    senderRules,
    smsEvents,
    transactionCandidates,
    activityEvents,
    decisionTraces,
    databaseMetadata,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> singletonId,
      Value<int> privacyEpoch,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> singletonId,
      Value<int> privacyEpoch,
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
  ColumnFilters<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
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
  ColumnOrderings<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
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
  GeneratedColumn<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => column,
  );
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
          updateCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => AppSettingsCompanion(
                singletonId: singletonId,
                privacyEpoch: privacyEpoch,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                singletonId: singletonId,
                privacyEpoch: privacyEpoch,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
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
typedef $$SenderRulesTableCreateCompanionBuilder =
    SenderRulesCompanion Function({
      Value<int> id,
      required String senderHash,
      required String parserFamily,
      required int createdAtEpochMs,
    });
typedef $$SenderRulesTableUpdateCompanionBuilder =
    SenderRulesCompanion Function({
      Value<int> id,
      Value<String> senderHash,
      Value<String> parserFamily,
      Value<int> createdAtEpochMs,
    });

class $$SenderRulesTableFilterComposer
    extends Composer<_$AppDatabase, $SenderRulesTable> {
  $$SenderRulesTableFilterComposer({
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

  ColumnFilters<String> get senderHash => $composableBuilder(
    column: $table.senderHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserFamily => $composableBuilder(
    column: $table.parserFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SenderRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SenderRulesTable> {
  $$SenderRulesTableOrderingComposer({
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

  ColumnOrderings<String> get senderHash => $composableBuilder(
    column: $table.senderHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserFamily => $composableBuilder(
    column: $table.parserFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SenderRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SenderRulesTable> {
  $$SenderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderHash => $composableBuilder(
    column: $table.senderHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserFamily => $composableBuilder(
    column: $table.parserFamily,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => column,
  );
}

class $$SenderRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SenderRulesTable,
          SenderRule,
          $$SenderRulesTableFilterComposer,
          $$SenderRulesTableOrderingComposer,
          $$SenderRulesTableAnnotationComposer,
          $$SenderRulesTableCreateCompanionBuilder,
          $$SenderRulesTableUpdateCompanionBuilder,
          (
            SenderRule,
            BaseReferences<_$AppDatabase, $SenderRulesTable, SenderRule>,
          ),
          SenderRule,
          PrefetchHooks Function()
        > {
  $$SenderRulesTableTableManager(_$AppDatabase db, $SenderRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SenderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SenderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SenderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> senderHash = const Value.absent(),
                Value<String> parserFamily = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
              }) => SenderRulesCompanion(
                id: id,
                senderHash: senderHash,
                parserFamily: parserFamily,
                createdAtEpochMs: createdAtEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String senderHash,
                required String parserFamily,
                required int createdAtEpochMs,
              }) => SenderRulesCompanion.insert(
                id: id,
                senderHash: senderHash,
                parserFamily: parserFamily,
                createdAtEpochMs: createdAtEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SenderRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SenderRulesTable,
      SenderRule,
      $$SenderRulesTableFilterComposer,
      $$SenderRulesTableOrderingComposer,
      $$SenderRulesTableAnnotationComposer,
      $$SenderRulesTableCreateCompanionBuilder,
      $$SenderRulesTableUpdateCompanionBuilder,
      (
        SenderRule,
        BaseReferences<_$AppDatabase, $SenderRulesTable, SenderRule>,
      ),
      SenderRule,
      PrefetchHooks Function()
    >;
typedef $$SmsEventsTableCreateCompanionBuilder =
    SmsEventsCompanion Function({
      Value<int> id,
      required String sourceKey,
      required String senderHash,
      Value<String?> encryptedBody,
      Value<String?> redactedBody,
      required String ingestionSource,
      required int receivedAtEpochMs,
      Value<int?> expiresAtEpochMs,
      required String status,
      required int privacyEpoch,
    });
typedef $$SmsEventsTableUpdateCompanionBuilder =
    SmsEventsCompanion Function({
      Value<int> id,
      Value<String> sourceKey,
      Value<String> senderHash,
      Value<String?> encryptedBody,
      Value<String?> redactedBody,
      Value<String> ingestionSource,
      Value<int> receivedAtEpochMs,
      Value<int?> expiresAtEpochMs,
      Value<String> status,
      Value<int> privacyEpoch,
    });

final class $$SmsEventsTableReferences
    extends BaseReferences<_$AppDatabase, $SmsEventsTable, SmsEvent> {
  $$SmsEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $TransactionCandidatesTable,
    List<TransactionCandidate>
  >
  _transactionCandidatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionCandidates,
        aliasName: 'sms_events__id__transaction_candidates__sms_event_id',
      );

  $$TransactionCandidatesTableProcessedTableManager
  get transactionCandidatesRefs {
    final manager = $$TransactionCandidatesTableTableManager(
      $_db,
      $_db.transactionCandidates,
    ).filter((f) => f.smsEventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionCandidatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SmsEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SmsEventsTable> {
  $$SmsEventsTableFilterComposer({
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

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderHash => $composableBuilder(
    column: $table.senderHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedBody => $composableBuilder(
    column: $table.encryptedBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redactedBody => $composableBuilder(
    column: $table.redactedBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingestionSource => $composableBuilder(
    column: $table.ingestionSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAtEpochMs => $composableBuilder(
    column: $table.receivedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAtEpochMs => $composableBuilder(
    column: $table.expiresAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionCandidatesRefs(
    Expression<bool> Function($$TransactionCandidatesTableFilterComposer f) f,
  ) {
    final $$TransactionCandidatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionCandidates,
          getReferencedColumn: (t) => t.smsEventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionCandidatesTableFilterComposer(
                $db: $db,
                $table: $db.transactionCandidates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SmsEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SmsEventsTable> {
  $$SmsEventsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderHash => $composableBuilder(
    column: $table.senderHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedBody => $composableBuilder(
    column: $table.encryptedBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redactedBody => $composableBuilder(
    column: $table.redactedBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingestionSource => $composableBuilder(
    column: $table.ingestionSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAtEpochMs => $composableBuilder(
    column: $table.receivedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAtEpochMs => $composableBuilder(
    column: $table.expiresAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmsEventsTable> {
  $$SmsEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<String> get senderHash => $composableBuilder(
    column: $table.senderHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedBody => $composableBuilder(
    column: $table.encryptedBody,
    builder: (column) => column,
  );

  GeneratedColumn<String> get redactedBody => $composableBuilder(
    column: $table.redactedBody,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingestionSource => $composableBuilder(
    column: $table.ingestionSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedAtEpochMs => $composableBuilder(
    column: $table.receivedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAtEpochMs => $composableBuilder(
    column: $table.expiresAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => column,
  );

  Expression<T> transactionCandidatesRefs<T extends Object>(
    Expression<T> Function($$TransactionCandidatesTableAnnotationComposer a) f,
  ) {
    final $$TransactionCandidatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionCandidates,
          getReferencedColumn: (t) => t.smsEventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionCandidatesTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionCandidates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SmsEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmsEventsTable,
          SmsEvent,
          $$SmsEventsTableFilterComposer,
          $$SmsEventsTableOrderingComposer,
          $$SmsEventsTableAnnotationComposer,
          $$SmsEventsTableCreateCompanionBuilder,
          $$SmsEventsTableUpdateCompanionBuilder,
          (SmsEvent, $$SmsEventsTableReferences),
          SmsEvent,
          PrefetchHooks Function({bool transactionCandidatesRefs})
        > {
  $$SmsEventsTableTableManager(_$AppDatabase db, $SmsEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String> senderHash = const Value.absent(),
                Value<String?> encryptedBody = const Value.absent(),
                Value<String?> redactedBody = const Value.absent(),
                Value<String> ingestionSource = const Value.absent(),
                Value<int> receivedAtEpochMs = const Value.absent(),
                Value<int?> expiresAtEpochMs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => SmsEventsCompanion(
                id: id,
                sourceKey: sourceKey,
                senderHash: senderHash,
                encryptedBody: encryptedBody,
                redactedBody: redactedBody,
                ingestionSource: ingestionSource,
                receivedAtEpochMs: receivedAtEpochMs,
                expiresAtEpochMs: expiresAtEpochMs,
                status: status,
                privacyEpoch: privacyEpoch,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceKey,
                required String senderHash,
                Value<String?> encryptedBody = const Value.absent(),
                Value<String?> redactedBody = const Value.absent(),
                required String ingestionSource,
                required int receivedAtEpochMs,
                Value<int?> expiresAtEpochMs = const Value.absent(),
                required String status,
                required int privacyEpoch,
              }) => SmsEventsCompanion.insert(
                id: id,
                sourceKey: sourceKey,
                senderHash: senderHash,
                encryptedBody: encryptedBody,
                redactedBody: redactedBody,
                ingestionSource: ingestionSource,
                receivedAtEpochMs: receivedAtEpochMs,
                expiresAtEpochMs: expiresAtEpochMs,
                status: status,
                privacyEpoch: privacyEpoch,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SmsEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionCandidatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionCandidatesRefs) db.transactionCandidates,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionCandidatesRefs)
                    await $_getPrefetchedData<
                      SmsEvent,
                      $SmsEventsTable,
                      TransactionCandidate
                    >(
                      currentTable: table,
                      referencedTable: $$SmsEventsTableReferences
                          ._transactionCandidatesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SmsEventsTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionCandidatesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.smsEventId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SmsEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmsEventsTable,
      SmsEvent,
      $$SmsEventsTableFilterComposer,
      $$SmsEventsTableOrderingComposer,
      $$SmsEventsTableAnnotationComposer,
      $$SmsEventsTableCreateCompanionBuilder,
      $$SmsEventsTableUpdateCompanionBuilder,
      (SmsEvent, $$SmsEventsTableReferences),
      SmsEvent,
      PrefetchHooks Function({bool transactionCandidatesRefs})
    >;
typedef $$TransactionCandidatesTableCreateCompanionBuilder =
    TransactionCandidatesCompanion Function({
      Value<int> id,
      required int smsEventId,
      required CandidateRecordState state,
      required String encryptedPayload,
      required int revision,
      required int createdAtEpochMs,
    });
typedef $$TransactionCandidatesTableUpdateCompanionBuilder =
    TransactionCandidatesCompanion Function({
      Value<int> id,
      Value<int> smsEventId,
      Value<CandidateRecordState> state,
      Value<String> encryptedPayload,
      Value<int> revision,
      Value<int> createdAtEpochMs,
    });

final class $$TransactionCandidatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionCandidatesTable,
          TransactionCandidate
        > {
  $$TransactionCandidatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SmsEventsTable _smsEventIdTable(_$AppDatabase db) => db.smsEvents
      .createAlias('transaction_candidates__sms_event_id__sms_events__id');

  $$SmsEventsTableProcessedTableManager get smsEventId {
    final $_column = $_itemColumn<int>('sms_event_id')!;

    final manager = $$SmsEventsTableTableManager(
      $_db,
      $_db.smsEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_smsEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DecisionTracesTable, List<DecisionTrace>>
  _decisionTracesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.decisionTraces,
    aliasName: 'transaction_candidates__id__decision_traces__candidate_id',
  );

  $$DecisionTracesTableProcessedTableManager get decisionTracesRefs {
    final manager = $$DecisionTracesTableTableManager(
      $_db,
      $_db.decisionTraces,
    ).filter((f) => f.candidateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_decisionTracesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionCandidatesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionCandidatesTable> {
  $$TransactionCandidatesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<
    CandidateRecordState,
    CandidateRecordState,
    String
  >
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  $$SmsEventsTableFilterComposer get smsEventId {
    final $$SmsEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.smsEventId,
      referencedTable: $db.smsEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmsEventsTableFilterComposer(
            $db: $db,
            $table: $db.smsEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> decisionTracesRefs(
    Expression<bool> Function($$DecisionTracesTableFilterComposer f) f,
  ) {
    final $$DecisionTracesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionTraces,
      getReferencedColumn: (t) => t.candidateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionTracesTableFilterComposer(
            $db: $db,
            $table: $db.decisionTraces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionCandidatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionCandidatesTable> {
  $$TransactionCandidatesTableOrderingComposer({
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

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$SmsEventsTableOrderingComposer get smsEventId {
    final $$SmsEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.smsEventId,
      referencedTable: $db.smsEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmsEventsTableOrderingComposer(
            $db: $db,
            $table: $db.smsEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionCandidatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionCandidatesTable> {
  $$TransactionCandidatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CandidateRecordState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => column,
  );

  $$SmsEventsTableAnnotationComposer get smsEventId {
    final $$SmsEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.smsEventId,
      referencedTable: $db.smsEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmsEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.smsEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> decisionTracesRefs<T extends Object>(
    Expression<T> Function($$DecisionTracesTableAnnotationComposer a) f,
  ) {
    final $$DecisionTracesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionTraces,
      getReferencedColumn: (t) => t.candidateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionTracesTableAnnotationComposer(
            $db: $db,
            $table: $db.decisionTraces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionCandidatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionCandidatesTable,
          TransactionCandidate,
          $$TransactionCandidatesTableFilterComposer,
          $$TransactionCandidatesTableOrderingComposer,
          $$TransactionCandidatesTableAnnotationComposer,
          $$TransactionCandidatesTableCreateCompanionBuilder,
          $$TransactionCandidatesTableUpdateCompanionBuilder,
          (TransactionCandidate, $$TransactionCandidatesTableReferences),
          TransactionCandidate,
          PrefetchHooks Function({bool smsEventId, bool decisionTracesRefs})
        > {
  $$TransactionCandidatesTableTableManager(
    _$AppDatabase db,
    $TransactionCandidatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionCandidatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TransactionCandidatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionCandidatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> smsEventId = const Value.absent(),
                Value<CandidateRecordState> state = const Value.absent(),
                Value<String> encryptedPayload = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
              }) => TransactionCandidatesCompanion(
                id: id,
                smsEventId: smsEventId,
                state: state,
                encryptedPayload: encryptedPayload,
                revision: revision,
                createdAtEpochMs: createdAtEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int smsEventId,
                required CandidateRecordState state,
                required String encryptedPayload,
                required int revision,
                required int createdAtEpochMs,
              }) => TransactionCandidatesCompanion.insert(
                id: id,
                smsEventId: smsEventId,
                state: state,
                encryptedPayload: encryptedPayload,
                revision: revision,
                createdAtEpochMs: createdAtEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionCandidatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({smsEventId = false, decisionTracesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (decisionTracesRefs) db.decisionTraces,
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
                        if (smsEventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.smsEventId,
                                    referencedTable:
                                        $$TransactionCandidatesTableReferences
                                            ._smsEventIdTable(db),
                                    referencedColumn:
                                        $$TransactionCandidatesTableReferences
                                            ._smsEventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (decisionTracesRefs)
                        await $_getPrefetchedData<
                          TransactionCandidate,
                          $TransactionCandidatesTable,
                          DecisionTrace
                        >(
                          currentTable: table,
                          referencedTable:
                              $$TransactionCandidatesTableReferences
                                  ._decisionTracesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionCandidatesTableReferences(
                                db,
                                table,
                                p0,
                              ).decisionTracesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.candidateId == item.id,
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

typedef $$TransactionCandidatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionCandidatesTable,
      TransactionCandidate,
      $$TransactionCandidatesTableFilterComposer,
      $$TransactionCandidatesTableOrderingComposer,
      $$TransactionCandidatesTableAnnotationComposer,
      $$TransactionCandidatesTableCreateCompanionBuilder,
      $$TransactionCandidatesTableUpdateCompanionBuilder,
      (TransactionCandidate, $$TransactionCandidatesTableReferences),
      TransactionCandidate,
      PrefetchHooks Function({bool smsEventId, bool decisionTracesRefs})
    >;
typedef $$ActivityEventsTableCreateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<int> id,
      required ActivityEventCode eventType,
      required ActivityStateTransition sanitizedDetail,
      required int occurredAtEpochMs,
      required int privacyEpoch,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<int> id,
      Value<ActivityEventCode> eventType,
      Value<ActivityStateTransition> sanitizedDetail,
      Value<int> occurredAtEpochMs,
      Value<int> privacyEpoch,
    });

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ActivityEventCode, ActivityEventCode, String>
  get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ActivityStateTransition,
    ActivityStateTransition,
    String
  >
  get sanitizedDetail => $composableBuilder(
    column: $table.sanitizedDetail,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get occurredAtEpochMs => $composableBuilder(
    column: $table.occurredAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
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

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanitizedDetail => $composableBuilder(
    column: $table.sanitizedDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtEpochMs => $composableBuilder(
    column: $table.occurredAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityEventCode, String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityStateTransition, String>
  get sanitizedDetail => $composableBuilder(
    column: $table.sanitizedDetail,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAtEpochMs => $composableBuilder(
    column: $table.occurredAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => column,
  );
}

class $$ActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTable,
          ActivityEvent,
          $$ActivityEventsTableFilterComposer,
          $$ActivityEventsTableOrderingComposer,
          $$ActivityEventsTableAnnotationComposer,
          $$ActivityEventsTableCreateCompanionBuilder,
          $$ActivityEventsTableUpdateCompanionBuilder,
          (
            ActivityEvent,
            BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
          ),
          ActivityEvent,
          PrefetchHooks Function()
        > {
  $$ActivityEventsTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ActivityEventCode> eventType = const Value.absent(),
                Value<ActivityStateTransition> sanitizedDetail =
                    const Value.absent(),
                Value<int> occurredAtEpochMs = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                eventType: eventType,
                sanitizedDetail: sanitizedDetail,
                occurredAtEpochMs: occurredAtEpochMs,
                privacyEpoch: privacyEpoch,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ActivityEventCode eventType,
                required ActivityStateTransition sanitizedDetail,
                required int occurredAtEpochMs,
                required int privacyEpoch,
              }) => ActivityEventsCompanion.insert(
                id: id,
                eventType: eventType,
                sanitizedDetail: sanitizedDetail,
                occurredAtEpochMs: occurredAtEpochMs,
                privacyEpoch: privacyEpoch,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTable,
      ActivityEvent,
      $$ActivityEventsTableFilterComposer,
      $$ActivityEventsTableOrderingComposer,
      $$ActivityEventsTableAnnotationComposer,
      $$ActivityEventsTableCreateCompanionBuilder,
      $$ActivityEventsTableUpdateCompanionBuilder,
      (
        ActivityEvent,
        BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
      ),
      ActivityEvent,
      PrefetchHooks Function()
    >;
typedef $$DecisionTracesTableCreateCompanionBuilder =
    DecisionTracesCompanion Function({
      Value<int> id,
      Value<int?> candidateId,
      required DecisionTraceCode traceCode,
      required int createdAtEpochMs,
    });
typedef $$DecisionTracesTableUpdateCompanionBuilder =
    DecisionTracesCompanion Function({
      Value<int> id,
      Value<int?> candidateId,
      Value<DecisionTraceCode> traceCode,
      Value<int> createdAtEpochMs,
    });

final class $$DecisionTracesTableReferences
    extends BaseReferences<_$AppDatabase, $DecisionTracesTable, DecisionTrace> {
  $$DecisionTracesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionCandidatesTable _candidateIdTable(_$AppDatabase db) => db
      .transactionCandidates
      .createAlias('decision_traces__candidate_id__transaction_candidates__id');

  $$TransactionCandidatesTableProcessedTableManager? get candidateId {
    final $_column = $_itemColumn<int>('candidate_id');
    if ($_column == null) return null;
    final manager = $$TransactionCandidatesTableTableManager(
      $_db,
      $_db.transactionCandidates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_candidateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecisionTracesTableFilterComposer
    extends Composer<_$AppDatabase, $DecisionTracesTable> {
  $$DecisionTracesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DecisionTraceCode, DecisionTraceCode, String>
  get traceCode => $composableBuilder(
    column: $table.traceCode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionCandidatesTableFilterComposer get candidateId {
    final $$TransactionCandidatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.candidateId,
          referencedTable: $db.transactionCandidates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionCandidatesTableFilterComposer(
                $db: $db,
                $table: $db.transactionCandidates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DecisionTracesTableOrderingComposer
    extends Composer<_$AppDatabase, $DecisionTracesTable> {
  $$DecisionTracesTableOrderingComposer({
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

  ColumnOrderings<String> get traceCode => $composableBuilder(
    column: $table.traceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionCandidatesTableOrderingComposer get candidateId {
    final $$TransactionCandidatesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.candidateId,
          referencedTable: $db.transactionCandidates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionCandidatesTableOrderingComposer(
                $db: $db,
                $table: $db.transactionCandidates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DecisionTracesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecisionTracesTable> {
  $$DecisionTracesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DecisionTraceCode, String> get traceCode =>
      $composableBuilder(column: $table.traceCode, builder: (column) => column);

  GeneratedColumn<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => column,
  );

  $$TransactionCandidatesTableAnnotationComposer get candidateId {
    final $$TransactionCandidatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.candidateId,
          referencedTable: $db.transactionCandidates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionCandidatesTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionCandidates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DecisionTracesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecisionTracesTable,
          DecisionTrace,
          $$DecisionTracesTableFilterComposer,
          $$DecisionTracesTableOrderingComposer,
          $$DecisionTracesTableAnnotationComposer,
          $$DecisionTracesTableCreateCompanionBuilder,
          $$DecisionTracesTableUpdateCompanionBuilder,
          (DecisionTrace, $$DecisionTracesTableReferences),
          DecisionTrace,
          PrefetchHooks Function({bool candidateId})
        > {
  $$DecisionTracesTableTableManager(
    _$AppDatabase db,
    $DecisionTracesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionTracesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionTracesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionTracesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> candidateId = const Value.absent(),
                Value<DecisionTraceCode> traceCode = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
              }) => DecisionTracesCompanion(
                id: id,
                candidateId: candidateId,
                traceCode: traceCode,
                createdAtEpochMs: createdAtEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> candidateId = const Value.absent(),
                required DecisionTraceCode traceCode,
                required int createdAtEpochMs,
              }) => DecisionTracesCompanion.insert(
                id: id,
                candidateId: candidateId,
                traceCode: traceCode,
                createdAtEpochMs: createdAtEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionTracesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({candidateId = false}) {
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
                    if (candidateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.candidateId,
                                referencedTable: $$DecisionTracesTableReferences
                                    ._candidateIdTable(db),
                                referencedColumn:
                                    $$DecisionTracesTableReferences
                                        ._candidateIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$DecisionTracesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecisionTracesTable,
      DecisionTrace,
      $$DecisionTracesTableFilterComposer,
      $$DecisionTracesTableOrderingComposer,
      $$DecisionTracesTableAnnotationComposer,
      $$DecisionTracesTableCreateCompanionBuilder,
      $$DecisionTracesTableUpdateCompanionBuilder,
      (DecisionTrace, $$DecisionTracesTableReferences),
      DecisionTrace,
      PrefetchHooks Function({bool candidateId})
    >;
typedef $$DatabaseMetadataTableCreateCompanionBuilder =
    DatabaseMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$DatabaseMetadataTableUpdateCompanionBuilder =
    DatabaseMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$DatabaseMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $DatabaseMetadataTable> {
  $$DatabaseMetadataTableFilterComposer({
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

class $$DatabaseMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabaseMetadataTable> {
  $$DatabaseMetadataTableOrderingComposer({
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

class $$DatabaseMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabaseMetadataTable> {
  $$DatabaseMetadataTableAnnotationComposer({
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

class $$DatabaseMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabaseMetadataTable,
          DatabaseMetadataData,
          $$DatabaseMetadataTableFilterComposer,
          $$DatabaseMetadataTableOrderingComposer,
          $$DatabaseMetadataTableAnnotationComposer,
          $$DatabaseMetadataTableCreateCompanionBuilder,
          $$DatabaseMetadataTableUpdateCompanionBuilder,
          (
            DatabaseMetadataData,
            BaseReferences<
              _$AppDatabase,
              $DatabaseMetadataTable,
              DatabaseMetadataData
            >,
          ),
          DatabaseMetadataData,
          PrefetchHooks Function()
        > {
  $$DatabaseMetadataTableTableManager(
    _$AppDatabase db,
    $DatabaseMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabaseMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DatabaseMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DatabaseMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabaseMetadataCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => DatabaseMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DatabaseMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabaseMetadataTable,
      DatabaseMetadataData,
      $$DatabaseMetadataTableFilterComposer,
      $$DatabaseMetadataTableOrderingComposer,
      $$DatabaseMetadataTableAnnotationComposer,
      $$DatabaseMetadataTableCreateCompanionBuilder,
      $$DatabaseMetadataTableUpdateCompanionBuilder,
      (
        DatabaseMetadataData,
        BaseReferences<
          _$AppDatabase,
          $DatabaseMetadataTable,
          DatabaseMetadataData
        >,
      ),
      DatabaseMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SenderRulesTableTableManager get senderRules =>
      $$SenderRulesTableTableManager(_db, _db.senderRules);
  $$SmsEventsTableTableManager get smsEvents =>
      $$SmsEventsTableTableManager(_db, _db.smsEvents);
  $$TransactionCandidatesTableTableManager get transactionCandidates =>
      $$TransactionCandidatesTableTableManager(_db, _db.transactionCandidates);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$DecisionTracesTableTableManager get decisionTraces =>
      $$DecisionTracesTableTableManager(_db, _db.decisionTraces);
  $$DatabaseMetadataTableTableManager get databaseMetadata =>
      $$DatabaseMetadataTableTableManager(_db, _db.databaseMetadata);
}
