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
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _onboardingRevisionMeta =
      const VerificationMeta('onboardingRevision');
  @override
  late final GeneratedColumn<int> onboardingRevision = GeneratedColumn<int>(
    'onboarding_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _disclosureAcceptedMeta =
      const VerificationMeta('disclosureAccepted');
  @override
  late final GeneratedColumn<bool> disclosureAccepted = GeneratedColumn<bool>(
    'disclosure_accepted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("disclosure_accepted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _disclosureRevisionMeta =
      const VerificationMeta('disclosureRevision');
  @override
  late final GeneratedColumn<int> disclosureRevision = GeneratedColumn<int>(
    'disclosure_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processingModeMeta = const VerificationMeta(
    'processingMode',
  );
  @override
  late final GeneratedColumn<String> processingMode = GeneratedColumn<String>(
    'processing_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('review'),
  );
  static const VerificationMeta _configurationRevisionMeta =
      const VerificationMeta('configurationRevision');
  @override
  late final GeneratedColumn<int> configurationRevision = GeneratedColumn<int>(
    'configuration_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rawCopyRetentionDaysMeta =
      const VerificationMeta('rawCopyRetentionDays');
  @override
  late final GeneratedColumn<int> rawCopyRetentionDays = GeneratedColumn<int>(
    'raw_copy_retention_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activityRetentionDaysMeta =
      const VerificationMeta('activityRetentionDays');
  @override
  late final GeneratedColumn<int> activityRetentionDays = GeneratedColumn<int>(
    'activity_retention_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(180),
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonId,
    privacyEpoch,
    onboardingCompleted,
    onboardingRevision,
    disclosureAccepted,
    disclosureRevision,
    processingMode,
    configurationRevision,
    rawCopyRetentionDays,
    activityRetentionDays,
  ];
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
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_revision')) {
      context.handle(
        _onboardingRevisionMeta,
        onboardingRevision.isAcceptableOrUnknown(
          data['onboarding_revision']!,
          _onboardingRevisionMeta,
        ),
      );
    }
    if (data.containsKey('disclosure_accepted')) {
      context.handle(
        _disclosureAcceptedMeta,
        disclosureAccepted.isAcceptableOrUnknown(
          data['disclosure_accepted']!,
          _disclosureAcceptedMeta,
        ),
      );
    }
    if (data.containsKey('disclosure_revision')) {
      context.handle(
        _disclosureRevisionMeta,
        disclosureRevision.isAcceptableOrUnknown(
          data['disclosure_revision']!,
          _disclosureRevisionMeta,
        ),
      );
    }
    if (data.containsKey('processing_mode')) {
      context.handle(
        _processingModeMeta,
        processingMode.isAcceptableOrUnknown(
          data['processing_mode']!,
          _processingModeMeta,
        ),
      );
    }
    if (data.containsKey('configuration_revision')) {
      context.handle(
        _configurationRevisionMeta,
        configurationRevision.isAcceptableOrUnknown(
          data['configuration_revision']!,
          _configurationRevisionMeta,
        ),
      );
    }
    if (data.containsKey('raw_copy_retention_days')) {
      context.handle(
        _rawCopyRetentionDaysMeta,
        rawCopyRetentionDays.isAcceptableOrUnknown(
          data['raw_copy_retention_days']!,
          _rawCopyRetentionDaysMeta,
        ),
      );
    }
    if (data.containsKey('activity_retention_days')) {
      context.handle(
        _activityRetentionDaysMeta,
        activityRetentionDays.isAcceptableOrUnknown(
          data['activity_retention_days']!,
          _activityRetentionDaysMeta,
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
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      onboardingRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_revision'],
      ),
      disclosureAccepted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}disclosure_accepted'],
      )!,
      disclosureRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disclosure_revision'],
      ),
      processingMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_mode'],
      )!,
      configurationRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}configuration_revision'],
      )!,
      rawCopyRetentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}raw_copy_retention_days'],
      )!,
      activityRetentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_retention_days'],
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
  final bool onboardingCompleted;
  final int? onboardingRevision;
  final bool disclosureAccepted;
  final int? disclosureRevision;
  final String processingMode;
  final int configurationRevision;
  final int rawCopyRetentionDays;
  final int activityRetentionDays;
  const AppSetting({
    required this.singletonId,
    required this.privacyEpoch,
    required this.onboardingCompleted,
    this.onboardingRevision,
    required this.disclosureAccepted,
    this.disclosureRevision,
    required this.processingMode,
    required this.configurationRevision,
    required this.rawCopyRetentionDays,
    required this.activityRetentionDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || onboardingRevision != null) {
      map['onboarding_revision'] = Variable<int>(onboardingRevision);
    }
    map['disclosure_accepted'] = Variable<bool>(disclosureAccepted);
    if (!nullToAbsent || disclosureRevision != null) {
      map['disclosure_revision'] = Variable<int>(disclosureRevision);
    }
    map['processing_mode'] = Variable<String>(processingMode);
    map['configuration_revision'] = Variable<int>(configurationRevision);
    map['raw_copy_retention_days'] = Variable<int>(rawCopyRetentionDays);
    map['activity_retention_days'] = Variable<int>(activityRetentionDays);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      singletonId: Value(singletonId),
      privacyEpoch: Value(privacyEpoch),
      onboardingCompleted: Value(onboardingCompleted),
      onboardingRevision: onboardingRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingRevision),
      disclosureAccepted: Value(disclosureAccepted),
      disclosureRevision: disclosureRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(disclosureRevision),
      processingMode: Value(processingMode),
      configurationRevision: Value(configurationRevision),
      rawCopyRetentionDays: Value(rawCopyRetentionDays),
      activityRetentionDays: Value(activityRetentionDays),
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
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      onboardingRevision: serializer.fromJson<int?>(json['onboardingRevision']),
      disclosureAccepted: serializer.fromJson<bool>(json['disclosureAccepted']),
      disclosureRevision: serializer.fromJson<int?>(json['disclosureRevision']),
      processingMode: serializer.fromJson<String>(json['processingMode']),
      configurationRevision: serializer.fromJson<int>(
        json['configurationRevision'],
      ),
      rawCopyRetentionDays: serializer.fromJson<int>(
        json['rawCopyRetentionDays'],
      ),
      activityRetentionDays: serializer.fromJson<int>(
        json['activityRetentionDays'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'onboardingRevision': serializer.toJson<int?>(onboardingRevision),
      'disclosureAccepted': serializer.toJson<bool>(disclosureAccepted),
      'disclosureRevision': serializer.toJson<int?>(disclosureRevision),
      'processingMode': serializer.toJson<String>(processingMode),
      'configurationRevision': serializer.toJson<int>(configurationRevision),
      'rawCopyRetentionDays': serializer.toJson<int>(rawCopyRetentionDays),
      'activityRetentionDays': serializer.toJson<int>(activityRetentionDays),
    };
  }

  AppSetting copyWith({
    int? singletonId,
    int? privacyEpoch,
    bool? onboardingCompleted,
    Value<int?> onboardingRevision = const Value.absent(),
    bool? disclosureAccepted,
    Value<int?> disclosureRevision = const Value.absent(),
    String? processingMode,
    int? configurationRevision,
    int? rawCopyRetentionDays,
    int? activityRetentionDays,
  }) => AppSetting(
    singletonId: singletonId ?? this.singletonId,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    onboardingRevision: onboardingRevision.present
        ? onboardingRevision.value
        : this.onboardingRevision,
    disclosureAccepted: disclosureAccepted ?? this.disclosureAccepted,
    disclosureRevision: disclosureRevision.present
        ? disclosureRevision.value
        : this.disclosureRevision,
    processingMode: processingMode ?? this.processingMode,
    configurationRevision: configurationRevision ?? this.configurationRevision,
    rawCopyRetentionDays: rawCopyRetentionDays ?? this.rawCopyRetentionDays,
    activityRetentionDays: activityRetentionDays ?? this.activityRetentionDays,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      privacyEpoch: data.privacyEpoch.present
          ? data.privacyEpoch.value
          : this.privacyEpoch,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      onboardingRevision: data.onboardingRevision.present
          ? data.onboardingRevision.value
          : this.onboardingRevision,
      disclosureAccepted: data.disclosureAccepted.present
          ? data.disclosureAccepted.value
          : this.disclosureAccepted,
      disclosureRevision: data.disclosureRevision.present
          ? data.disclosureRevision.value
          : this.disclosureRevision,
      processingMode: data.processingMode.present
          ? data.processingMode.value
          : this.processingMode,
      configurationRevision: data.configurationRevision.present
          ? data.configurationRevision.value
          : this.configurationRevision,
      rawCopyRetentionDays: data.rawCopyRetentionDays.present
          ? data.rawCopyRetentionDays.value
          : this.rawCopyRetentionDays,
      activityRetentionDays: data.activityRetentionDays.present
          ? data.activityRetentionDays.value
          : this.activityRetentionDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('singletonId: $singletonId, ')
          ..write('privacyEpoch: $privacyEpoch, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingRevision: $onboardingRevision, ')
          ..write('disclosureAccepted: $disclosureAccepted, ')
          ..write('disclosureRevision: $disclosureRevision, ')
          ..write('processingMode: $processingMode, ')
          ..write('configurationRevision: $configurationRevision, ')
          ..write('rawCopyRetentionDays: $rawCopyRetentionDays, ')
          ..write('activityRetentionDays: $activityRetentionDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonId,
    privacyEpoch,
    onboardingCompleted,
    onboardingRevision,
    disclosureAccepted,
    disclosureRevision,
    processingMode,
    configurationRevision,
    rawCopyRetentionDays,
    activityRetentionDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.singletonId == this.singletonId &&
          other.privacyEpoch == this.privacyEpoch &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.onboardingRevision == this.onboardingRevision &&
          other.disclosureAccepted == this.disclosureAccepted &&
          other.disclosureRevision == this.disclosureRevision &&
          other.processingMode == this.processingMode &&
          other.configurationRevision == this.configurationRevision &&
          other.rawCopyRetentionDays == this.rawCopyRetentionDays &&
          other.activityRetentionDays == this.activityRetentionDays);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> singletonId;
  final Value<int> privacyEpoch;
  final Value<bool> onboardingCompleted;
  final Value<int?> onboardingRevision;
  final Value<bool> disclosureAccepted;
  final Value<int?> disclosureRevision;
  final Value<String> processingMode;
  final Value<int> configurationRevision;
  final Value<int> rawCopyRetentionDays;
  final Value<int> activityRetentionDays;
  const AppSettingsCompanion({
    this.singletonId = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingRevision = const Value.absent(),
    this.disclosureAccepted = const Value.absent(),
    this.disclosureRevision = const Value.absent(),
    this.processingMode = const Value.absent(),
    this.configurationRevision = const Value.absent(),
    this.rawCopyRetentionDays = const Value.absent(),
    this.activityRetentionDays = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.singletonId = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingRevision = const Value.absent(),
    this.disclosureAccepted = const Value.absent(),
    this.disclosureRevision = const Value.absent(),
    this.processingMode = const Value.absent(),
    this.configurationRevision = const Value.absent(),
    this.rawCopyRetentionDays = const Value.absent(),
    this.activityRetentionDays = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? singletonId,
    Expression<int>? privacyEpoch,
    Expression<bool>? onboardingCompleted,
    Expression<int>? onboardingRevision,
    Expression<bool>? disclosureAccepted,
    Expression<int>? disclosureRevision,
    Expression<String>? processingMode,
    Expression<int>? configurationRevision,
    Expression<int>? rawCopyRetentionDays,
    Expression<int>? activityRetentionDays,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (onboardingRevision != null) 'onboarding_revision': onboardingRevision,
      if (disclosureAccepted != null) 'disclosure_accepted': disclosureAccepted,
      if (disclosureRevision != null) 'disclosure_revision': disclosureRevision,
      if (processingMode != null) 'processing_mode': processingMode,
      if (configurationRevision != null)
        'configuration_revision': configurationRevision,
      if (rawCopyRetentionDays != null)
        'raw_copy_retention_days': rawCopyRetentionDays,
      if (activityRetentionDays != null)
        'activity_retention_days': activityRetentionDays,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? singletonId,
    Value<int>? privacyEpoch,
    Value<bool>? onboardingCompleted,
    Value<int?>? onboardingRevision,
    Value<bool>? disclosureAccepted,
    Value<int?>? disclosureRevision,
    Value<String>? processingMode,
    Value<int>? configurationRevision,
    Value<int>? rawCopyRetentionDays,
    Value<int>? activityRetentionDays,
  }) {
    return AppSettingsCompanion(
      singletonId: singletonId ?? this.singletonId,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingRevision: onboardingRevision ?? this.onboardingRevision,
      disclosureAccepted: disclosureAccepted ?? this.disclosureAccepted,
      disclosureRevision: disclosureRevision ?? this.disclosureRevision,
      processingMode: processingMode ?? this.processingMode,
      configurationRevision:
          configurationRevision ?? this.configurationRevision,
      rawCopyRetentionDays: rawCopyRetentionDays ?? this.rawCopyRetentionDays,
      activityRetentionDays:
          activityRetentionDays ?? this.activityRetentionDays,
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
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (onboardingRevision.present) {
      map['onboarding_revision'] = Variable<int>(onboardingRevision.value);
    }
    if (disclosureAccepted.present) {
      map['disclosure_accepted'] = Variable<bool>(disclosureAccepted.value);
    }
    if (disclosureRevision.present) {
      map['disclosure_revision'] = Variable<int>(disclosureRevision.value);
    }
    if (processingMode.present) {
      map['processing_mode'] = Variable<String>(processingMode.value);
    }
    if (configurationRevision.present) {
      map['configuration_revision'] = Variable<int>(
        configurationRevision.value,
      );
    }
    if (rawCopyRetentionDays.present) {
      map['raw_copy_retention_days'] = Variable<int>(
        rawCopyRetentionDays.value,
      );
    }
    if (activityRetentionDays.present) {
      map['activity_retention_days'] = Variable<int>(
        activityRetentionDays.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('privacyEpoch: $privacyEpoch, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingRevision: $onboardingRevision, ')
          ..write('disclosureAccepted: $disclosureAccepted, ')
          ..write('disclosureRevision: $disclosureRevision, ')
          ..write('processingMode: $processingMode, ')
          ..write('configurationRevision: $configurationRevision, ')
          ..write('rawCopyRetentionDays: $rawCopyRetentionDays, ')
          ..write('activityRetentionDays: $activityRetentionDays')
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
  static const VerificationMeta _parserVersionMeta = const VerificationMeta(
    'parserVersion',
  );
  @override
  late final GeneratedColumn<String> parserVersion = GeneratedColumn<String>(
    'parser_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parserChecksumMeta = const VerificationMeta(
    'parserChecksum',
  );
  @override
  late final GeneratedColumn<String> parserChecksum = GeneratedColumn<String>(
    'parser_checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderHash,
    parserFamily,
    createdAtEpochMs,
    parserVersion,
    parserChecksum,
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
    if (data.containsKey('parser_version')) {
      context.handle(
        _parserVersionMeta,
        parserVersion.isAcceptableOrUnknown(
          data['parser_version']!,
          _parserVersionMeta,
        ),
      );
    }
    if (data.containsKey('parser_checksum')) {
      context.handle(
        _parserChecksumMeta,
        parserChecksum.isAcceptableOrUnknown(
          data['parser_checksum']!,
          _parserChecksumMeta,
        ),
      );
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
      parserVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_version'],
      ),
      parserChecksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_checksum'],
      ),
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
  final String? parserVersion;
  final String? parserChecksum;
  const SenderRule({
    required this.id,
    required this.senderHash,
    required this.parserFamily,
    required this.createdAtEpochMs,
    this.parserVersion,
    this.parserChecksum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender_hash'] = Variable<String>(senderHash);
    map['parser_family'] = Variable<String>(parserFamily);
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    if (!nullToAbsent || parserVersion != null) {
      map['parser_version'] = Variable<String>(parserVersion);
    }
    if (!nullToAbsent || parserChecksum != null) {
      map['parser_checksum'] = Variable<String>(parserChecksum);
    }
    return map;
  }

  SenderRulesCompanion toCompanion(bool nullToAbsent) {
    return SenderRulesCompanion(
      id: Value(id),
      senderHash: Value(senderHash),
      parserFamily: Value(parserFamily),
      createdAtEpochMs: Value(createdAtEpochMs),
      parserVersion: parserVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(parserVersion),
      parserChecksum: parserChecksum == null && nullToAbsent
          ? const Value.absent()
          : Value(parserChecksum),
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
      parserVersion: serializer.fromJson<String?>(json['parserVersion']),
      parserChecksum: serializer.fromJson<String?>(json['parserChecksum']),
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
      'parserVersion': serializer.toJson<String?>(parserVersion),
      'parserChecksum': serializer.toJson<String?>(parserChecksum),
    };
  }

  SenderRule copyWith({
    int? id,
    String? senderHash,
    String? parserFamily,
    int? createdAtEpochMs,
    Value<String?> parserVersion = const Value.absent(),
    Value<String?> parserChecksum = const Value.absent(),
  }) => SenderRule(
    id: id ?? this.id,
    senderHash: senderHash ?? this.senderHash,
    parserFamily: parserFamily ?? this.parserFamily,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    parserVersion: parserVersion.present
        ? parserVersion.value
        : this.parserVersion,
    parserChecksum: parserChecksum.present
        ? parserChecksum.value
        : this.parserChecksum,
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
      parserVersion: data.parserVersion.present
          ? data.parserVersion.value
          : this.parserVersion,
      parserChecksum: data.parserChecksum.present
          ? data.parserChecksum.value
          : this.parserChecksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SenderRule(')
          ..write('id: $id, ')
          ..write('senderHash: $senderHash, ')
          ..write('parserFamily: $parserFamily, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('parserChecksum: $parserChecksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    senderHash,
    parserFamily,
    createdAtEpochMs,
    parserVersion,
    parserChecksum,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SenderRule &&
          other.id == this.id &&
          other.senderHash == this.senderHash &&
          other.parserFamily == this.parserFamily &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.parserVersion == this.parserVersion &&
          other.parserChecksum == this.parserChecksum);
}

class SenderRulesCompanion extends UpdateCompanion<SenderRule> {
  final Value<int> id;
  final Value<String> senderHash;
  final Value<String> parserFamily;
  final Value<int> createdAtEpochMs;
  final Value<String?> parserVersion;
  final Value<String?> parserChecksum;
  const SenderRulesCompanion({
    this.id = const Value.absent(),
    this.senderHash = const Value.absent(),
    this.parserFamily = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.parserVersion = const Value.absent(),
    this.parserChecksum = const Value.absent(),
  });
  SenderRulesCompanion.insert({
    this.id = const Value.absent(),
    required String senderHash,
    required String parserFamily,
    required int createdAtEpochMs,
    this.parserVersion = const Value.absent(),
    this.parserChecksum = const Value.absent(),
  }) : senderHash = Value(senderHash),
       parserFamily = Value(parserFamily),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<SenderRule> custom({
    Expression<int>? id,
    Expression<String>? senderHash,
    Expression<String>? parserFamily,
    Expression<int>? createdAtEpochMs,
    Expression<String>? parserVersion,
    Expression<String>? parserChecksum,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderHash != null) 'sender_hash': senderHash,
      if (parserFamily != null) 'parser_family': parserFamily,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (parserVersion != null) 'parser_version': parserVersion,
      if (parserChecksum != null) 'parser_checksum': parserChecksum,
    });
  }

  SenderRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? senderHash,
    Value<String>? parserFamily,
    Value<int>? createdAtEpochMs,
    Value<String?>? parserVersion,
    Value<String?>? parserChecksum,
  }) {
    return SenderRulesCompanion(
      id: id ?? this.id,
      senderHash: senderHash ?? this.senderHash,
      parserFamily: parserFamily ?? this.parserFamily,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      parserVersion: parserVersion ?? this.parserVersion,
      parserChecksum: parserChecksum ?? this.parserChecksum,
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
    if (parserVersion.present) {
      map['parser_version'] = Variable<String>(parserVersion.value);
    }
    if (parserChecksum.present) {
      map['parser_checksum'] = Variable<String>(parserChecksum.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SenderRulesCompanion(')
          ..write('id: $id, ')
          ..write('senderHash: $senderHash, ')
          ..write('parserFamily: $parserFamily, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('parserChecksum: $parserChecksum')
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
  static const VerificationMeta _warningCodeMeta = const VerificationMeta(
    'warningCode',
  );
  @override
  late final GeneratedColumn<String> warningCode = GeneratedColumn<String>(
    'warning_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentEvidenceMeta = const VerificationMeta(
    'paymentEvidence',
  );
  @override
  late final GeneratedColumn<String> paymentEvidence = GeneratedColumn<String>(
    'payment_evidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instrumentEvidenceMeta =
      const VerificationMeta('instrumentEvidence');
  @override
  late final GeneratedColumn<String> instrumentEvidence =
      GeneratedColumn<String>(
        'instrument_evidence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originalCurrencyCodeMeta =
      const VerificationMeta('originalCurrencyCode');
  @override
  late final GeneratedColumn<String> originalCurrencyCode =
      GeneratedColumn<String>(
        'original_currency_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _walletCurrencyCodeMeta =
      const VerificationMeta('walletCurrencyCode');
  @override
  late final GeneratedColumn<String> walletCurrencyCode =
      GeneratedColumn<String>(
        'wallet_currency_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    smsEventId,
    state,
    encryptedPayload,
    revision,
    createdAtEpochMs,
    warningCode,
    paymentEvidence,
    instrumentEvidence,
    originalCurrencyCode,
    walletCurrencyCode,
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
    if (data.containsKey('warning_code')) {
      context.handle(
        _warningCodeMeta,
        warningCode.isAcceptableOrUnknown(
          data['warning_code']!,
          _warningCodeMeta,
        ),
      );
    }
    if (data.containsKey('payment_evidence')) {
      context.handle(
        _paymentEvidenceMeta,
        paymentEvidence.isAcceptableOrUnknown(
          data['payment_evidence']!,
          _paymentEvidenceMeta,
        ),
      );
    }
    if (data.containsKey('instrument_evidence')) {
      context.handle(
        _instrumentEvidenceMeta,
        instrumentEvidence.isAcceptableOrUnknown(
          data['instrument_evidence']!,
          _instrumentEvidenceMeta,
        ),
      );
    }
    if (data.containsKey('original_currency_code')) {
      context.handle(
        _originalCurrencyCodeMeta,
        originalCurrencyCode.isAcceptableOrUnknown(
          data['original_currency_code']!,
          _originalCurrencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('wallet_currency_code')) {
      context.handle(
        _walletCurrencyCodeMeta,
        walletCurrencyCode.isAcceptableOrUnknown(
          data['wallet_currency_code']!,
          _walletCurrencyCodeMeta,
        ),
      );
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
      warningCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warning_code'],
      ),
      paymentEvidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_evidence'],
      ),
      instrumentEvidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_evidence'],
      ),
      originalCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency_code'],
      ),
      walletCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_currency_code'],
      ),
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
  final String? warningCode;
  final String? paymentEvidence;
  final String? instrumentEvidence;
  final String? originalCurrencyCode;
  final String? walletCurrencyCode;
  const TransactionCandidate({
    required this.id,
    required this.smsEventId,
    required this.state,
    required this.encryptedPayload,
    required this.revision,
    required this.createdAtEpochMs,
    this.warningCode,
    this.paymentEvidence,
    this.instrumentEvidence,
    this.originalCurrencyCode,
    this.walletCurrencyCode,
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
    if (!nullToAbsent || warningCode != null) {
      map['warning_code'] = Variable<String>(warningCode);
    }
    if (!nullToAbsent || paymentEvidence != null) {
      map['payment_evidence'] = Variable<String>(paymentEvidence);
    }
    if (!nullToAbsent || instrumentEvidence != null) {
      map['instrument_evidence'] = Variable<String>(instrumentEvidence);
    }
    if (!nullToAbsent || originalCurrencyCode != null) {
      map['original_currency_code'] = Variable<String>(originalCurrencyCode);
    }
    if (!nullToAbsent || walletCurrencyCode != null) {
      map['wallet_currency_code'] = Variable<String>(walletCurrencyCode);
    }
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
      warningCode: warningCode == null && nullToAbsent
          ? const Value.absent()
          : Value(warningCode),
      paymentEvidence: paymentEvidence == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentEvidence),
      instrumentEvidence: instrumentEvidence == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentEvidence),
      originalCurrencyCode: originalCurrencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCurrencyCode),
      walletCurrencyCode: walletCurrencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(walletCurrencyCode),
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
      warningCode: serializer.fromJson<String?>(json['warningCode']),
      paymentEvidence: serializer.fromJson<String?>(json['paymentEvidence']),
      instrumentEvidence: serializer.fromJson<String?>(
        json['instrumentEvidence'],
      ),
      originalCurrencyCode: serializer.fromJson<String?>(
        json['originalCurrencyCode'],
      ),
      walletCurrencyCode: serializer.fromJson<String?>(
        json['walletCurrencyCode'],
      ),
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
      'warningCode': serializer.toJson<String?>(warningCode),
      'paymentEvidence': serializer.toJson<String?>(paymentEvidence),
      'instrumentEvidence': serializer.toJson<String?>(instrumentEvidence),
      'originalCurrencyCode': serializer.toJson<String?>(originalCurrencyCode),
      'walletCurrencyCode': serializer.toJson<String?>(walletCurrencyCode),
    };
  }

  TransactionCandidate copyWith({
    int? id,
    int? smsEventId,
    CandidateRecordState? state,
    String? encryptedPayload,
    int? revision,
    int? createdAtEpochMs,
    Value<String?> warningCode = const Value.absent(),
    Value<String?> paymentEvidence = const Value.absent(),
    Value<String?> instrumentEvidence = const Value.absent(),
    Value<String?> originalCurrencyCode = const Value.absent(),
    Value<String?> walletCurrencyCode = const Value.absent(),
  }) => TransactionCandidate(
    id: id ?? this.id,
    smsEventId: smsEventId ?? this.smsEventId,
    state: state ?? this.state,
    encryptedPayload: encryptedPayload ?? this.encryptedPayload,
    revision: revision ?? this.revision,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    warningCode: warningCode.present ? warningCode.value : this.warningCode,
    paymentEvidence: paymentEvidence.present
        ? paymentEvidence.value
        : this.paymentEvidence,
    instrumentEvidence: instrumentEvidence.present
        ? instrumentEvidence.value
        : this.instrumentEvidence,
    originalCurrencyCode: originalCurrencyCode.present
        ? originalCurrencyCode.value
        : this.originalCurrencyCode,
    walletCurrencyCode: walletCurrencyCode.present
        ? walletCurrencyCode.value
        : this.walletCurrencyCode,
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
      warningCode: data.warningCode.present
          ? data.warningCode.value
          : this.warningCode,
      paymentEvidence: data.paymentEvidence.present
          ? data.paymentEvidence.value
          : this.paymentEvidence,
      instrumentEvidence: data.instrumentEvidence.present
          ? data.instrumentEvidence.value
          : this.instrumentEvidence,
      originalCurrencyCode: data.originalCurrencyCode.present
          ? data.originalCurrencyCode.value
          : this.originalCurrencyCode,
      walletCurrencyCode: data.walletCurrencyCode.present
          ? data.walletCurrencyCode.value
          : this.walletCurrencyCode,
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
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('warningCode: $warningCode, ')
          ..write('paymentEvidence: $paymentEvidence, ')
          ..write('instrumentEvidence: $instrumentEvidence, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('walletCurrencyCode: $walletCurrencyCode')
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
    warningCode,
    paymentEvidence,
    instrumentEvidence,
    originalCurrencyCode,
    walletCurrencyCode,
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
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.warningCode == this.warningCode &&
          other.paymentEvidence == this.paymentEvidence &&
          other.instrumentEvidence == this.instrumentEvidence &&
          other.originalCurrencyCode == this.originalCurrencyCode &&
          other.walletCurrencyCode == this.walletCurrencyCode);
}

class TransactionCandidatesCompanion
    extends UpdateCompanion<TransactionCandidate> {
  final Value<int> id;
  final Value<int> smsEventId;
  final Value<CandidateRecordState> state;
  final Value<String> encryptedPayload;
  final Value<int> revision;
  final Value<int> createdAtEpochMs;
  final Value<String?> warningCode;
  final Value<String?> paymentEvidence;
  final Value<String?> instrumentEvidence;
  final Value<String?> originalCurrencyCode;
  final Value<String?> walletCurrencyCode;
  const TransactionCandidatesCompanion({
    this.id = const Value.absent(),
    this.smsEventId = const Value.absent(),
    this.state = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.warningCode = const Value.absent(),
    this.paymentEvidence = const Value.absent(),
    this.instrumentEvidence = const Value.absent(),
    this.originalCurrencyCode = const Value.absent(),
    this.walletCurrencyCode = const Value.absent(),
  });
  TransactionCandidatesCompanion.insert({
    this.id = const Value.absent(),
    required int smsEventId,
    required CandidateRecordState state,
    required String encryptedPayload,
    required int revision,
    required int createdAtEpochMs,
    this.warningCode = const Value.absent(),
    this.paymentEvidence = const Value.absent(),
    this.instrumentEvidence = const Value.absent(),
    this.originalCurrencyCode = const Value.absent(),
    this.walletCurrencyCode = const Value.absent(),
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
    Expression<String>? warningCode,
    Expression<String>? paymentEvidence,
    Expression<String>? instrumentEvidence,
    Expression<String>? originalCurrencyCode,
    Expression<String>? walletCurrencyCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (smsEventId != null) 'sms_event_id': smsEventId,
      if (state != null) 'state': state,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (revision != null) 'revision': revision,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (warningCode != null) 'warning_code': warningCode,
      if (paymentEvidence != null) 'payment_evidence': paymentEvidence,
      if (instrumentEvidence != null) 'instrument_evidence': instrumentEvidence,
      if (originalCurrencyCode != null)
        'original_currency_code': originalCurrencyCode,
      if (walletCurrencyCode != null)
        'wallet_currency_code': walletCurrencyCode,
    });
  }

  TransactionCandidatesCompanion copyWith({
    Value<int>? id,
    Value<int>? smsEventId,
    Value<CandidateRecordState>? state,
    Value<String>? encryptedPayload,
    Value<int>? revision,
    Value<int>? createdAtEpochMs,
    Value<String?>? warningCode,
    Value<String?>? paymentEvidence,
    Value<String?>? instrumentEvidence,
    Value<String?>? originalCurrencyCode,
    Value<String?>? walletCurrencyCode,
  }) {
    return TransactionCandidatesCompanion(
      id: id ?? this.id,
      smsEventId: smsEventId ?? this.smsEventId,
      state: state ?? this.state,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      revision: revision ?? this.revision,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      warningCode: warningCode ?? this.warningCode,
      paymentEvidence: paymentEvidence ?? this.paymentEvidence,
      instrumentEvidence: instrumentEvidence ?? this.instrumentEvidence,
      originalCurrencyCode: originalCurrencyCode ?? this.originalCurrencyCode,
      walletCurrencyCode: walletCurrencyCode ?? this.walletCurrencyCode,
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
    if (warningCode.present) {
      map['warning_code'] = Variable<String>(warningCode.value);
    }
    if (paymentEvidence.present) {
      map['payment_evidence'] = Variable<String>(paymentEvidence.value);
    }
    if (instrumentEvidence.present) {
      map['instrument_evidence'] = Variable<String>(instrumentEvidence.value);
    }
    if (originalCurrencyCode.present) {
      map['original_currency_code'] = Variable<String>(
        originalCurrencyCode.value,
      );
    }
    if (walletCurrencyCode.present) {
      map['wallet_currency_code'] = Variable<String>(walletCurrencyCode.value);
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
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('warningCode: $warningCode, ')
          ..write('paymentEvidence: $paymentEvidence, ')
          ..write('instrumentEvidence: $instrumentEvidence, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('walletCurrencyCode: $walletCurrencyCode')
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

class $AppLockStateTable extends AppLockState
    with TableInfo<$AppLockStateTable, AppLockStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppLockStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lockEnabledMeta = const VerificationMeta(
    'lockEnabled',
  );
  @override
  late final GeneratedColumn<bool> lockEnabled = GeneratedColumn<bool>(
    'lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _inactivityTimeoutSecondsMeta =
      const VerificationMeta('inactivityTimeoutSeconds');
  @override
  late final GeneratedColumn<int> inactivityTimeoutSeconds =
      GeneratedColumn<int>(
        'inactivity_timeout_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(300),
      );
  static const VerificationMeta _lockMetadataMeta = const VerificationMeta(
    'lockMetadata',
  );
  @override
  late final GeneratedColumn<String> lockMetadata = GeneratedColumn<String>(
    'lock_metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonId,
    lockEnabled,
    inactivityTimeoutSeconds,
    lockMetadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_lock_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLockStateData> instance, {
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
    if (data.containsKey('lock_enabled')) {
      context.handle(
        _lockEnabledMeta,
        lockEnabled.isAcceptableOrUnknown(
          data['lock_enabled']!,
          _lockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('inactivity_timeout_seconds')) {
      context.handle(
        _inactivityTimeoutSecondsMeta,
        inactivityTimeoutSeconds.isAcceptableOrUnknown(
          data['inactivity_timeout_seconds']!,
          _inactivityTimeoutSecondsMeta,
        ),
      );
    }
    if (data.containsKey('lock_metadata')) {
      context.handle(
        _lockMetadataMeta,
        lockMetadata.isAcceptableOrUnknown(
          data['lock_metadata']!,
          _lockMetadataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonId};
  @override
  AppLockStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLockStateData(
      singletonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_id'],
      )!,
      lockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lock_enabled'],
      )!,
      inactivityTimeoutSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inactivity_timeout_seconds'],
      )!,
      lockMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lock_metadata'],
      ),
    );
  }

  @override
  $AppLockStateTable createAlias(String alias) {
    return $AppLockStateTable(attachedDatabase, alias);
  }
}

class AppLockStateData extends DataClass
    implements Insertable<AppLockStateData> {
  final int singletonId;
  final bool lockEnabled;
  final int inactivityTimeoutSeconds;
  final String? lockMetadata;
  const AppLockStateData({
    required this.singletonId,
    required this.lockEnabled,
    required this.inactivityTimeoutSeconds,
    this.lockMetadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['lock_enabled'] = Variable<bool>(lockEnabled);
    map['inactivity_timeout_seconds'] = Variable<int>(inactivityTimeoutSeconds);
    if (!nullToAbsent || lockMetadata != null) {
      map['lock_metadata'] = Variable<String>(lockMetadata);
    }
    return map;
  }

  AppLockStateCompanion toCompanion(bool nullToAbsent) {
    return AppLockStateCompanion(
      singletonId: Value(singletonId),
      lockEnabled: Value(lockEnabled),
      inactivityTimeoutSeconds: Value(inactivityTimeoutSeconds),
      lockMetadata: lockMetadata == null && nullToAbsent
          ? const Value.absent()
          : Value(lockMetadata),
    );
  }

  factory AppLockStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLockStateData(
      singletonId: serializer.fromJson<int>(json['singletonId']),
      lockEnabled: serializer.fromJson<bool>(json['lockEnabled']),
      inactivityTimeoutSeconds: serializer.fromJson<int>(
        json['inactivityTimeoutSeconds'],
      ),
      lockMetadata: serializer.fromJson<String?>(json['lockMetadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'lockEnabled': serializer.toJson<bool>(lockEnabled),
      'inactivityTimeoutSeconds': serializer.toJson<int>(
        inactivityTimeoutSeconds,
      ),
      'lockMetadata': serializer.toJson<String?>(lockMetadata),
    };
  }

  AppLockStateData copyWith({
    int? singletonId,
    bool? lockEnabled,
    int? inactivityTimeoutSeconds,
    Value<String?> lockMetadata = const Value.absent(),
  }) => AppLockStateData(
    singletonId: singletonId ?? this.singletonId,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    inactivityTimeoutSeconds:
        inactivityTimeoutSeconds ?? this.inactivityTimeoutSeconds,
    lockMetadata: lockMetadata.present ? lockMetadata.value : this.lockMetadata,
  );
  AppLockStateData copyWithCompanion(AppLockStateCompanion data) {
    return AppLockStateData(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      lockEnabled: data.lockEnabled.present
          ? data.lockEnabled.value
          : this.lockEnabled,
      inactivityTimeoutSeconds: data.inactivityTimeoutSeconds.present
          ? data.inactivityTimeoutSeconds.value
          : this.inactivityTimeoutSeconds,
      lockMetadata: data.lockMetadata.present
          ? data.lockMetadata.value
          : this.lockMetadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLockStateData(')
          ..write('singletonId: $singletonId, ')
          ..write('lockEnabled: $lockEnabled, ')
          ..write('inactivityTimeoutSeconds: $inactivityTimeoutSeconds, ')
          ..write('lockMetadata: $lockMetadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonId,
    lockEnabled,
    inactivityTimeoutSeconds,
    lockMetadata,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLockStateData &&
          other.singletonId == this.singletonId &&
          other.lockEnabled == this.lockEnabled &&
          other.inactivityTimeoutSeconds == this.inactivityTimeoutSeconds &&
          other.lockMetadata == this.lockMetadata);
}

class AppLockStateCompanion extends UpdateCompanion<AppLockStateData> {
  final Value<int> singletonId;
  final Value<bool> lockEnabled;
  final Value<int> inactivityTimeoutSeconds;
  final Value<String?> lockMetadata;
  const AppLockStateCompanion({
    this.singletonId = const Value.absent(),
    this.lockEnabled = const Value.absent(),
    this.inactivityTimeoutSeconds = const Value.absent(),
    this.lockMetadata = const Value.absent(),
  });
  AppLockStateCompanion.insert({
    this.singletonId = const Value.absent(),
    this.lockEnabled = const Value.absent(),
    this.inactivityTimeoutSeconds = const Value.absent(),
    this.lockMetadata = const Value.absent(),
  });
  static Insertable<AppLockStateData> custom({
    Expression<int>? singletonId,
    Expression<bool>? lockEnabled,
    Expression<int>? inactivityTimeoutSeconds,
    Expression<String>? lockMetadata,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (lockEnabled != null) 'lock_enabled': lockEnabled,
      if (inactivityTimeoutSeconds != null)
        'inactivity_timeout_seconds': inactivityTimeoutSeconds,
      if (lockMetadata != null) 'lock_metadata': lockMetadata,
    });
  }

  AppLockStateCompanion copyWith({
    Value<int>? singletonId,
    Value<bool>? lockEnabled,
    Value<int>? inactivityTimeoutSeconds,
    Value<String?>? lockMetadata,
  }) {
    return AppLockStateCompanion(
      singletonId: singletonId ?? this.singletonId,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      inactivityTimeoutSeconds:
          inactivityTimeoutSeconds ?? this.inactivityTimeoutSeconds,
      lockMetadata: lockMetadata ?? this.lockMetadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonId.present) {
      map['singleton_id'] = Variable<int>(singletonId.value);
    }
    if (lockEnabled.present) {
      map['lock_enabled'] = Variable<bool>(lockEnabled.value);
    }
    if (inactivityTimeoutSeconds.present) {
      map['inactivity_timeout_seconds'] = Variable<int>(
        inactivityTimeoutSeconds.value,
      );
    }
    if (lockMetadata.present) {
      map['lock_metadata'] = Variable<String>(lockMetadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppLockStateCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('lockEnabled: $lockEnabled, ')
          ..write('inactivityTimeoutSeconds: $inactivityTimeoutSeconds, ')
          ..write('lockMetadata: $lockMetadata')
          ..write(')'))
        .toString();
  }
}

class $DeletionAuditEventsTable extends DeletionAuditEvents
    with TableInfo<$DeletionAuditEventsTable, DeletionAuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeletionAuditEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _privacyEpochBeforeMeta =
      const VerificationMeta('privacyEpochBefore');
  @override
  late final GeneratedColumn<int> privacyEpochBefore = GeneratedColumn<int>(
    'privacy_epoch_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyEpochAfterMeta = const VerificationMeta(
    'privacyEpochAfter',
  );
  @override
  late final GeneratedColumn<int> privacyEpochAfter = GeneratedColumn<int>(
    'privacy_epoch_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyEpochBefore,
    privacyEpochAfter,
    occurredAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deletion_audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeletionAuditEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('privacy_epoch_before')) {
      context.handle(
        _privacyEpochBeforeMeta,
        privacyEpochBefore.isAcceptableOrUnknown(
          data['privacy_epoch_before']!,
          _privacyEpochBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyEpochBeforeMeta);
    }
    if (data.containsKey('privacy_epoch_after')) {
      context.handle(
        _privacyEpochAfterMeta,
        privacyEpochAfter.isAcceptableOrUnknown(
          data['privacy_epoch_after']!,
          _privacyEpochAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyEpochAfterMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeletionAuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeletionAuditEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      privacyEpochBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch_before'],
      )!,
      privacyEpochAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch_after'],
      )!,
      occurredAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_epoch_ms'],
      )!,
    );
  }

  @override
  $DeletionAuditEventsTable createAlias(String alias) {
    return $DeletionAuditEventsTable(attachedDatabase, alias);
  }
}

class DeletionAuditEvent extends DataClass
    implements Insertable<DeletionAuditEvent> {
  final int id;
  final int privacyEpochBefore;
  final int privacyEpochAfter;
  final int occurredAtEpochMs;
  const DeletionAuditEvent({
    required this.id,
    required this.privacyEpochBefore,
    required this.privacyEpochAfter,
    required this.occurredAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['privacy_epoch_before'] = Variable<int>(privacyEpochBefore);
    map['privacy_epoch_after'] = Variable<int>(privacyEpochAfter);
    map['occurred_at_epoch_ms'] = Variable<int>(occurredAtEpochMs);
    return map;
  }

  DeletionAuditEventsCompanion toCompanion(bool nullToAbsent) {
    return DeletionAuditEventsCompanion(
      id: Value(id),
      privacyEpochBefore: Value(privacyEpochBefore),
      privacyEpochAfter: Value(privacyEpochAfter),
      occurredAtEpochMs: Value(occurredAtEpochMs),
    );
  }

  factory DeletionAuditEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeletionAuditEvent(
      id: serializer.fromJson<int>(json['id']),
      privacyEpochBefore: serializer.fromJson<int>(json['privacyEpochBefore']),
      privacyEpochAfter: serializer.fromJson<int>(json['privacyEpochAfter']),
      occurredAtEpochMs: serializer.fromJson<int>(json['occurredAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'privacyEpochBefore': serializer.toJson<int>(privacyEpochBefore),
      'privacyEpochAfter': serializer.toJson<int>(privacyEpochAfter),
      'occurredAtEpochMs': serializer.toJson<int>(occurredAtEpochMs),
    };
  }

  DeletionAuditEvent copyWith({
    int? id,
    int? privacyEpochBefore,
    int? privacyEpochAfter,
    int? occurredAtEpochMs,
  }) => DeletionAuditEvent(
    id: id ?? this.id,
    privacyEpochBefore: privacyEpochBefore ?? this.privacyEpochBefore,
    privacyEpochAfter: privacyEpochAfter ?? this.privacyEpochAfter,
    occurredAtEpochMs: occurredAtEpochMs ?? this.occurredAtEpochMs,
  );
  DeletionAuditEvent copyWithCompanion(DeletionAuditEventsCompanion data) {
    return DeletionAuditEvent(
      id: data.id.present ? data.id.value : this.id,
      privacyEpochBefore: data.privacyEpochBefore.present
          ? data.privacyEpochBefore.value
          : this.privacyEpochBefore,
      privacyEpochAfter: data.privacyEpochAfter.present
          ? data.privacyEpochAfter.value
          : this.privacyEpochAfter,
      occurredAtEpochMs: data.occurredAtEpochMs.present
          ? data.occurredAtEpochMs.value
          : this.occurredAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeletionAuditEvent(')
          ..write('id: $id, ')
          ..write('privacyEpochBefore: $privacyEpochBefore, ')
          ..write('privacyEpochAfter: $privacyEpochAfter, ')
          ..write('occurredAtEpochMs: $occurredAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, privacyEpochBefore, privacyEpochAfter, occurredAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeletionAuditEvent &&
          other.id == this.id &&
          other.privacyEpochBefore == this.privacyEpochBefore &&
          other.privacyEpochAfter == this.privacyEpochAfter &&
          other.occurredAtEpochMs == this.occurredAtEpochMs);
}

class DeletionAuditEventsCompanion extends UpdateCompanion<DeletionAuditEvent> {
  final Value<int> id;
  final Value<int> privacyEpochBefore;
  final Value<int> privacyEpochAfter;
  final Value<int> occurredAtEpochMs;
  const DeletionAuditEventsCompanion({
    this.id = const Value.absent(),
    this.privacyEpochBefore = const Value.absent(),
    this.privacyEpochAfter = const Value.absent(),
    this.occurredAtEpochMs = const Value.absent(),
  });
  DeletionAuditEventsCompanion.insert({
    this.id = const Value.absent(),
    required int privacyEpochBefore,
    required int privacyEpochAfter,
    required int occurredAtEpochMs,
  }) : privacyEpochBefore = Value(privacyEpochBefore),
       privacyEpochAfter = Value(privacyEpochAfter),
       occurredAtEpochMs = Value(occurredAtEpochMs);
  static Insertable<DeletionAuditEvent> custom({
    Expression<int>? id,
    Expression<int>? privacyEpochBefore,
    Expression<int>? privacyEpochAfter,
    Expression<int>? occurredAtEpochMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyEpochBefore != null)
        'privacy_epoch_before': privacyEpochBefore,
      if (privacyEpochAfter != null) 'privacy_epoch_after': privacyEpochAfter,
      if (occurredAtEpochMs != null) 'occurred_at_epoch_ms': occurredAtEpochMs,
    });
  }

  DeletionAuditEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? privacyEpochBefore,
    Value<int>? privacyEpochAfter,
    Value<int>? occurredAtEpochMs,
  }) {
    return DeletionAuditEventsCompanion(
      id: id ?? this.id,
      privacyEpochBefore: privacyEpochBefore ?? this.privacyEpochBefore,
      privacyEpochAfter: privacyEpochAfter ?? this.privacyEpochAfter,
      occurredAtEpochMs: occurredAtEpochMs ?? this.occurredAtEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (privacyEpochBefore.present) {
      map['privacy_epoch_before'] = Variable<int>(privacyEpochBefore.value);
    }
    if (privacyEpochAfter.present) {
      map['privacy_epoch_after'] = Variable<int>(privacyEpochAfter.value);
    }
    if (occurredAtEpochMs.present) {
      map['occurred_at_epoch_ms'] = Variable<int>(occurredAtEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeletionAuditEventsCompanion(')
          ..write('id: $id, ')
          ..write('privacyEpochBefore: $privacyEpochBefore, ')
          ..write('privacyEpochAfter: $privacyEpochAfter, ')
          ..write('occurredAtEpochMs: $occurredAtEpochMs')
          ..write(')'))
        .toString();
  }
}

class $WalletAccountCacheTable extends WalletAccountCache
    with TableInfo<$WalletAccountCacheTable, WalletAccountCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletAccountCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isBankSyncedMeta = const VerificationMeta(
    'isBankSynced',
  );
  @override
  late final GeneratedColumn<bool> isBankSynced = GeneratedColumn<bool>(
    'is_bank_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bank_synced" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isWritableMeta = const VerificationMeta(
    'isWritable',
  );
  @override
  late final GeneratedColumn<bool> isWritable = GeneratedColumn<bool>(
    'is_writable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_writable" IN (0, 1))',
    ),
  );
  static const VerificationMeta _eligibilityReasonMeta = const VerificationMeta(
    'eligibilityReason',
  );
  @override
  late final GeneratedColumn<String> eligibilityReason =
      GeneratedColumn<String>(
        'eligibility_reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _refreshedAtEpochMsMeta =
      const VerificationMeta('refreshedAtEpochMs');
  @override
  late final GeneratedColumn<int> refreshedAtEpochMs = GeneratedColumn<int>(
    'refreshed_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    currencyCode,
    isArchived,
    isBankSynced,
    isWritable,
    eligibilityReason,
    refreshedAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_account_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletAccountCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    } else if (isInserting) {
      context.missing(_isArchivedMeta);
    }
    if (data.containsKey('is_bank_synced')) {
      context.handle(
        _isBankSyncedMeta,
        isBankSynced.isAcceptableOrUnknown(
          data['is_bank_synced']!,
          _isBankSyncedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isBankSyncedMeta);
    }
    if (data.containsKey('is_writable')) {
      context.handle(
        _isWritableMeta,
        isWritable.isAcceptableOrUnknown(data['is_writable']!, _isWritableMeta),
      );
    } else if (isInserting) {
      context.missing(_isWritableMeta);
    }
    if (data.containsKey('eligibility_reason')) {
      context.handle(
        _eligibilityReasonMeta,
        eligibilityReason.isAcceptableOrUnknown(
          data['eligibility_reason']!,
          _eligibilityReasonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eligibilityReasonMeta);
    }
    if (data.containsKey('refreshed_at_epoch_ms')) {
      context.handle(
        _refreshedAtEpochMsMeta,
        refreshedAtEpochMs.isAcceptableOrUnknown(
          data['refreshed_at_epoch_ms']!,
          _refreshedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refreshedAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletAccountCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletAccountCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isBankSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bank_synced'],
      )!,
      isWritable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_writable'],
      )!,
      eligibilityReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eligibility_reason'],
      )!,
      refreshedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refreshed_at_epoch_ms'],
      )!,
    );
  }

  @override
  $WalletAccountCacheTable createAlias(String alias) {
    return $WalletAccountCacheTable(attachedDatabase, alias);
  }
}

class WalletAccountCacheData extends DataClass
    implements Insertable<WalletAccountCacheData> {
  final String id;
  final String name;
  final String currencyCode;
  final bool isArchived;
  final bool isBankSynced;
  final bool isWritable;
  final String eligibilityReason;
  final int refreshedAtEpochMs;
  const WalletAccountCacheData({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.isArchived,
    required this.isBankSynced,
    required this.isWritable,
    required this.eligibilityReason,
    required this.refreshedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['currency_code'] = Variable<String>(currencyCode);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_bank_synced'] = Variable<bool>(isBankSynced);
    map['is_writable'] = Variable<bool>(isWritable);
    map['eligibility_reason'] = Variable<String>(eligibilityReason);
    map['refreshed_at_epoch_ms'] = Variable<int>(refreshedAtEpochMs);
    return map;
  }

  WalletAccountCacheCompanion toCompanion(bool nullToAbsent) {
    return WalletAccountCacheCompanion(
      id: Value(id),
      name: Value(name),
      currencyCode: Value(currencyCode),
      isArchived: Value(isArchived),
      isBankSynced: Value(isBankSynced),
      isWritable: Value(isWritable),
      eligibilityReason: Value(eligibilityReason),
      refreshedAtEpochMs: Value(refreshedAtEpochMs),
    );
  }

  factory WalletAccountCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletAccountCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isBankSynced: serializer.fromJson<bool>(json['isBankSynced']),
      isWritable: serializer.fromJson<bool>(json['isWritable']),
      eligibilityReason: serializer.fromJson<String>(json['eligibilityReason']),
      refreshedAtEpochMs: serializer.fromJson<int>(json['refreshedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isBankSynced': serializer.toJson<bool>(isBankSynced),
      'isWritable': serializer.toJson<bool>(isWritable),
      'eligibilityReason': serializer.toJson<String>(eligibilityReason),
      'refreshedAtEpochMs': serializer.toJson<int>(refreshedAtEpochMs),
    };
  }

  WalletAccountCacheData copyWith({
    String? id,
    String? name,
    String? currencyCode,
    bool? isArchived,
    bool? isBankSynced,
    bool? isWritable,
    String? eligibilityReason,
    int? refreshedAtEpochMs,
  }) => WalletAccountCacheData(
    id: id ?? this.id,
    name: name ?? this.name,
    currencyCode: currencyCode ?? this.currencyCode,
    isArchived: isArchived ?? this.isArchived,
    isBankSynced: isBankSynced ?? this.isBankSynced,
    isWritable: isWritable ?? this.isWritable,
    eligibilityReason: eligibilityReason ?? this.eligibilityReason,
    refreshedAtEpochMs: refreshedAtEpochMs ?? this.refreshedAtEpochMs,
  );
  WalletAccountCacheData copyWithCompanion(WalletAccountCacheCompanion data) {
    return WalletAccountCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isBankSynced: data.isBankSynced.present
          ? data.isBankSynced.value
          : this.isBankSynced,
      isWritable: data.isWritable.present
          ? data.isWritable.value
          : this.isWritable,
      eligibilityReason: data.eligibilityReason.present
          ? data.eligibilityReason.value
          : this.eligibilityReason,
      refreshedAtEpochMs: data.refreshedAtEpochMs.present
          ? data.refreshedAtEpochMs.value
          : this.refreshedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletAccountCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isArchived: $isArchived, ')
          ..write('isBankSynced: $isBankSynced, ')
          ..write('isWritable: $isWritable, ')
          ..write('eligibilityReason: $eligibilityReason, ')
          ..write('refreshedAtEpochMs: $refreshedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    currencyCode,
    isArchived,
    isBankSynced,
    isWritable,
    eligibilityReason,
    refreshedAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletAccountCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.currencyCode == this.currencyCode &&
          other.isArchived == this.isArchived &&
          other.isBankSynced == this.isBankSynced &&
          other.isWritable == this.isWritable &&
          other.eligibilityReason == this.eligibilityReason &&
          other.refreshedAtEpochMs == this.refreshedAtEpochMs);
}

class WalletAccountCacheCompanion
    extends UpdateCompanion<WalletAccountCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> currencyCode;
  final Value<bool> isArchived;
  final Value<bool> isBankSynced;
  final Value<bool> isWritable;
  final Value<String> eligibilityReason;
  final Value<int> refreshedAtEpochMs;
  final Value<int> rowid;
  const WalletAccountCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isBankSynced = const Value.absent(),
    this.isWritable = const Value.absent(),
    this.eligibilityReason = const Value.absent(),
    this.refreshedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletAccountCacheCompanion.insert({
    required String id,
    required String name,
    required String currencyCode,
    required bool isArchived,
    required bool isBankSynced,
    required bool isWritable,
    required String eligibilityReason,
    required int refreshedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       currencyCode = Value(currencyCode),
       isArchived = Value(isArchived),
       isBankSynced = Value(isBankSynced),
       isWritable = Value(isWritable),
       eligibilityReason = Value(eligibilityReason),
       refreshedAtEpochMs = Value(refreshedAtEpochMs);
  static Insertable<WalletAccountCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? currencyCode,
    Expression<bool>? isArchived,
    Expression<bool>? isBankSynced,
    Expression<bool>? isWritable,
    Expression<String>? eligibilityReason,
    Expression<int>? refreshedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (isArchived != null) 'is_archived': isArchived,
      if (isBankSynced != null) 'is_bank_synced': isBankSynced,
      if (isWritable != null) 'is_writable': isWritable,
      if (eligibilityReason != null) 'eligibility_reason': eligibilityReason,
      if (refreshedAtEpochMs != null)
        'refreshed_at_epoch_ms': refreshedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletAccountCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? currencyCode,
    Value<bool>? isArchived,
    Value<bool>? isBankSynced,
    Value<bool>? isWritable,
    Value<String>? eligibilityReason,
    Value<int>? refreshedAtEpochMs,
    Value<int>? rowid,
  }) {
    return WalletAccountCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      isArchived: isArchived ?? this.isArchived,
      isBankSynced: isBankSynced ?? this.isBankSynced,
      isWritable: isWritable ?? this.isWritable,
      eligibilityReason: eligibilityReason ?? this.eligibilityReason,
      refreshedAtEpochMs: refreshedAtEpochMs ?? this.refreshedAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isBankSynced.present) {
      map['is_bank_synced'] = Variable<bool>(isBankSynced.value);
    }
    if (isWritable.present) {
      map['is_writable'] = Variable<bool>(isWritable.value);
    }
    if (eligibilityReason.present) {
      map['eligibility_reason'] = Variable<String>(eligibilityReason.value);
    }
    if (refreshedAtEpochMs.present) {
      map['refreshed_at_epoch_ms'] = Variable<int>(refreshedAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletAccountCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isArchived: $isArchived, ')
          ..write('isBankSynced: $isBankSynced, ')
          ..write('isWritable: $isWritable, ')
          ..write('eligibilityReason: $eligibilityReason, ')
          ..write('refreshedAtEpochMs: $refreshedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletCategoryCacheTable extends WalletCategoryCache
    with TableInfo<$WalletCategoryCacheTable, WalletCategoryCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletCategoryCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _refreshedAtEpochMsMeta =
      const VerificationMeta('refreshedAtEpochMs');
  @override
  late final GeneratedColumn<int> refreshedAtEpochMs = GeneratedColumn<int>(
    'refreshed_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, refreshedAtEpochMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_category_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletCategoryCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('refreshed_at_epoch_ms')) {
      context.handle(
        _refreshedAtEpochMsMeta,
        refreshedAtEpochMs.isAcceptableOrUnknown(
          data['refreshed_at_epoch_ms']!,
          _refreshedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refreshedAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletCategoryCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletCategoryCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      refreshedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refreshed_at_epoch_ms'],
      )!,
    );
  }

  @override
  $WalletCategoryCacheTable createAlias(String alias) {
    return $WalletCategoryCacheTable(attachedDatabase, alias);
  }
}

class WalletCategoryCacheData extends DataClass
    implements Insertable<WalletCategoryCacheData> {
  final String id;
  final String name;
  final int refreshedAtEpochMs;
  const WalletCategoryCacheData({
    required this.id,
    required this.name,
    required this.refreshedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['refreshed_at_epoch_ms'] = Variable<int>(refreshedAtEpochMs);
    return map;
  }

  WalletCategoryCacheCompanion toCompanion(bool nullToAbsent) {
    return WalletCategoryCacheCompanion(
      id: Value(id),
      name: Value(name),
      refreshedAtEpochMs: Value(refreshedAtEpochMs),
    );
  }

  factory WalletCategoryCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletCategoryCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      refreshedAtEpochMs: serializer.fromJson<int>(json['refreshedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'refreshedAtEpochMs': serializer.toJson<int>(refreshedAtEpochMs),
    };
  }

  WalletCategoryCacheData copyWith({
    String? id,
    String? name,
    int? refreshedAtEpochMs,
  }) => WalletCategoryCacheData(
    id: id ?? this.id,
    name: name ?? this.name,
    refreshedAtEpochMs: refreshedAtEpochMs ?? this.refreshedAtEpochMs,
  );
  WalletCategoryCacheData copyWithCompanion(WalletCategoryCacheCompanion data) {
    return WalletCategoryCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      refreshedAtEpochMs: data.refreshedAtEpochMs.present
          ? data.refreshedAtEpochMs.value
          : this.refreshedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletCategoryCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('refreshedAtEpochMs: $refreshedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, refreshedAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletCategoryCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.refreshedAtEpochMs == this.refreshedAtEpochMs);
}

class WalletCategoryCacheCompanion
    extends UpdateCompanion<WalletCategoryCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> refreshedAtEpochMs;
  final Value<int> rowid;
  const WalletCategoryCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.refreshedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletCategoryCacheCompanion.insert({
    required String id,
    required String name,
    required int refreshedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       refreshedAtEpochMs = Value(refreshedAtEpochMs);
  static Insertable<WalletCategoryCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? refreshedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (refreshedAtEpochMs != null)
        'refreshed_at_epoch_ms': refreshedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletCategoryCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? refreshedAtEpochMs,
    Value<int>? rowid,
  }) {
    return WalletCategoryCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      refreshedAtEpochMs: refreshedAtEpochMs ?? this.refreshedAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (refreshedAtEpochMs.present) {
      map['refreshed_at_epoch_ms'] = Variable<int>(refreshedAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletCategoryCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('refreshedAtEpochMs: $refreshedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletConnectionStatusTable extends WalletConnectionStatus
    with TableInfo<$WalletConnectionStatusTable, WalletConnectionStatusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletConnectionStatusTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('disconnected'),
  );
  static const VerificationMeta _lastSyncAtEpochMsMeta = const VerificationMeta(
    'lastSyncAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> lastSyncAtEpochMs = GeneratedColumn<int>(
    'last_sync_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonId,
    status,
    lastSyncAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_connection_status';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletConnectionStatusData> instance, {
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_sync_at_epoch_ms')) {
      context.handle(
        _lastSyncAtEpochMsMeta,
        lastSyncAtEpochMs.isAcceptableOrUnknown(
          data['last_sync_at_epoch_ms']!,
          _lastSyncAtEpochMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonId};
  @override
  WalletConnectionStatusData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletConnectionStatusData(
      singletonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastSyncAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_at_epoch_ms'],
      ),
    );
  }

  @override
  $WalletConnectionStatusTable createAlias(String alias) {
    return $WalletConnectionStatusTable(attachedDatabase, alias);
  }
}

class WalletConnectionStatusData extends DataClass
    implements Insertable<WalletConnectionStatusData> {
  final int singletonId;
  final String status;
  final int? lastSyncAtEpochMs;
  const WalletConnectionStatusData({
    required this.singletonId,
    required this.status,
    this.lastSyncAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastSyncAtEpochMs != null) {
      map['last_sync_at_epoch_ms'] = Variable<int>(lastSyncAtEpochMs);
    }
    return map;
  }

  WalletConnectionStatusCompanion toCompanion(bool nullToAbsent) {
    return WalletConnectionStatusCompanion(
      singletonId: Value(singletonId),
      status: Value(status),
      lastSyncAtEpochMs: lastSyncAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAtEpochMs),
    );
  }

  factory WalletConnectionStatusData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletConnectionStatusData(
      singletonId: serializer.fromJson<int>(json['singletonId']),
      status: serializer.fromJson<String>(json['status']),
      lastSyncAtEpochMs: serializer.fromJson<int?>(json['lastSyncAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'status': serializer.toJson<String>(status),
      'lastSyncAtEpochMs': serializer.toJson<int?>(lastSyncAtEpochMs),
    };
  }

  WalletConnectionStatusData copyWith({
    int? singletonId,
    String? status,
    Value<int?> lastSyncAtEpochMs = const Value.absent(),
  }) => WalletConnectionStatusData(
    singletonId: singletonId ?? this.singletonId,
    status: status ?? this.status,
    lastSyncAtEpochMs: lastSyncAtEpochMs.present
        ? lastSyncAtEpochMs.value
        : this.lastSyncAtEpochMs,
  );
  WalletConnectionStatusData copyWithCompanion(
    WalletConnectionStatusCompanion data,
  ) {
    return WalletConnectionStatusData(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      status: data.status.present ? data.status.value : this.status,
      lastSyncAtEpochMs: data.lastSyncAtEpochMs.present
          ? data.lastSyncAtEpochMs.value
          : this.lastSyncAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletConnectionStatusData(')
          ..write('singletonId: $singletonId, ')
          ..write('status: $status, ')
          ..write('lastSyncAtEpochMs: $lastSyncAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singletonId, status, lastSyncAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletConnectionStatusData &&
          other.singletonId == this.singletonId &&
          other.status == this.status &&
          other.lastSyncAtEpochMs == this.lastSyncAtEpochMs);
}

class WalletConnectionStatusCompanion
    extends UpdateCompanion<WalletConnectionStatusData> {
  final Value<int> singletonId;
  final Value<String> status;
  final Value<int?> lastSyncAtEpochMs;
  const WalletConnectionStatusCompanion({
    this.singletonId = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSyncAtEpochMs = const Value.absent(),
  });
  WalletConnectionStatusCompanion.insert({
    this.singletonId = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSyncAtEpochMs = const Value.absent(),
  });
  static Insertable<WalletConnectionStatusData> custom({
    Expression<int>? singletonId,
    Expression<String>? status,
    Expression<int>? lastSyncAtEpochMs,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (status != null) 'status': status,
      if (lastSyncAtEpochMs != null) 'last_sync_at_epoch_ms': lastSyncAtEpochMs,
    });
  }

  WalletConnectionStatusCompanion copyWith({
    Value<int>? singletonId,
    Value<String>? status,
    Value<int?>? lastSyncAtEpochMs,
  }) {
    return WalletConnectionStatusCompanion(
      singletonId: singletonId ?? this.singletonId,
      status: status ?? this.status,
      lastSyncAtEpochMs: lastSyncAtEpochMs ?? this.lastSyncAtEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonId.present) {
      map['singleton_id'] = Variable<int>(singletonId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastSyncAtEpochMs.present) {
      map['last_sync_at_epoch_ms'] = Variable<int>(lastSyncAtEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletConnectionStatusCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('status: $status, ')
          ..write('lastSyncAtEpochMs: $lastSyncAtEpochMs')
          ..write(')'))
        .toString();
  }
}

class $WalletMutationsTable extends WalletMutations
    with TableInfo<$WalletMutationsTable, WalletMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineageKeyMeta = const VerificationMeta(
    'lineageKey',
  );
  @override
  late final GeneratedColumn<String> lineageKey = GeneratedColumn<String>(
    'lineage_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
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
  static const VerificationMeta _updatedAtEpochMsMeta = const VerificationMeta(
    'updatedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtEpochMs = GeneratedColumn<int>(
    'updated_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    payload,
    state,
    lineageKey,
    fingerprint,
    createdAtEpochMs,
    updatedAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletMutation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('lineage_key')) {
      context.handle(
        _lineageKeyMeta,
        lineageKey.isAcceptableOrUnknown(data['lineage_key']!, _lineageKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_lineageKeyMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
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
    if (data.containsKey('updated_at_epoch_ms')) {
      context.handle(
        _updatedAtEpochMsMeta,
        updatedAtEpochMs.isAcceptableOrUnknown(
          data['updated_at_epoch_ms']!,
          _updatedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletMutation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lineageKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lineage_key'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      createdAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_epoch_ms'],
      )!,
      updatedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_epoch_ms'],
      )!,
    );
  }

  @override
  $WalletMutationsTable createAlias(String alias) {
    return $WalletMutationsTable(attachedDatabase, alias);
  }
}

class WalletMutation extends DataClass implements Insertable<WalletMutation> {
  final String id;
  final String operation;
  final String payload;
  final String state;
  final String lineageKey;
  final String fingerprint;
  final int createdAtEpochMs;
  final int updatedAtEpochMs;
  const WalletMutation({
    required this.id,
    required this.operation,
    required this.payload,
    required this.state,
    required this.lineageKey,
    required this.fingerprint,
    required this.createdAtEpochMs,
    required this.updatedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['state'] = Variable<String>(state);
    map['lineage_key'] = Variable<String>(lineageKey);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs);
    return map;
  }

  WalletMutationsCompanion toCompanion(bool nullToAbsent) {
    return WalletMutationsCompanion(
      id: Value(id),
      operation: Value(operation),
      payload: Value(payload),
      state: Value(state),
      lineageKey: Value(lineageKey),
      fingerprint: Value(fingerprint),
      createdAtEpochMs: Value(createdAtEpochMs),
      updatedAtEpochMs: Value(updatedAtEpochMs),
    );
  }

  factory WalletMutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletMutation(
      id: serializer.fromJson<String>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      state: serializer.fromJson<String>(json['state']),
      lineageKey: serializer.fromJson<String>(json['lineageKey']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
      updatedAtEpochMs: serializer.fromJson<int>(json['updatedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'state': serializer.toJson<String>(state),
      'lineageKey': serializer.toJson<String>(lineageKey),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
      'updatedAtEpochMs': serializer.toJson<int>(updatedAtEpochMs),
    };
  }

  WalletMutation copyWith({
    String? id,
    String? operation,
    String? payload,
    String? state,
    String? lineageKey,
    String? fingerprint,
    int? createdAtEpochMs,
    int? updatedAtEpochMs,
  }) => WalletMutation(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    state: state ?? this.state,
    lineageKey: lineageKey ?? this.lineageKey,
    fingerprint: fingerprint ?? this.fingerprint,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
  );
  WalletMutation copyWithCompanion(WalletMutationsCompanion data) {
    return WalletMutation(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      state: data.state.present ? data.state.value : this.state,
      lineageKey: data.lineageKey.present
          ? data.lineageKey.value
          : this.lineageKey,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
      updatedAtEpochMs: data.updatedAtEpochMs.present
          ? data.updatedAtEpochMs.value
          : this.updatedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletMutation(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('lineageKey: $lineageKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operation,
    payload,
    state,
    lineageKey,
    fingerprint,
    createdAtEpochMs,
    updatedAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletMutation &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.state == this.state &&
          other.lineageKey == this.lineageKey &&
          other.fingerprint == this.fingerprint &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.updatedAtEpochMs == this.updatedAtEpochMs);
}

class WalletMutationsCompanion extends UpdateCompanion<WalletMutation> {
  final Value<String> id;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> state;
  final Value<String> lineageKey;
  final Value<String> fingerprint;
  final Value<int> createdAtEpochMs;
  final Value<int> updatedAtEpochMs;
  final Value<int> rowid;
  const WalletMutationsCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.state = const Value.absent(),
    this.lineageKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletMutationsCompanion.insert({
    required String id,
    required String operation,
    required String payload,
    required String state,
    required String lineageKey,
    required String fingerprint,
    required int createdAtEpochMs,
    required int updatedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operation = Value(operation),
       payload = Value(payload),
       state = Value(state),
       lineageKey = Value(lineageKey),
       fingerprint = Value(fingerprint),
       createdAtEpochMs = Value(createdAtEpochMs),
       updatedAtEpochMs = Value(updatedAtEpochMs);
  static Insertable<WalletMutation> custom({
    Expression<String>? id,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? state,
    Expression<String>? lineageKey,
    Expression<String>? fingerprint,
    Expression<int>? createdAtEpochMs,
    Expression<int>? updatedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (state != null) 'state': state,
      if (lineageKey != null) 'lineage_key': lineageKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (updatedAtEpochMs != null) 'updated_at_epoch_ms': updatedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletMutationsCompanion copyWith({
    Value<String>? id,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? state,
    Value<String>? lineageKey,
    Value<String>? fingerprint,
    Value<int>? createdAtEpochMs,
    Value<int>? updatedAtEpochMs,
    Value<int>? rowid,
  }) {
    return WalletMutationsCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      state: state ?? this.state,
      lineageKey: lineageKey ?? this.lineageKey,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lineageKey.present) {
      map['lineage_key'] = Variable<String>(lineageKey.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (createdAtEpochMs.present) {
      map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs.value);
    }
    if (updatedAtEpochMs.present) {
      map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletMutationsCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('lineageKey: $lineageKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletRecordLinksTable extends WalletRecordLinks
    with TableInfo<$WalletRecordLinksTable, WalletRecordLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletRecordLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appIdMeta = const VerificationMeta('appId');
  @override
  late final GeneratedColumn<String> appId = GeneratedColumn<String>(
    'app_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [id, appId, remoteId, createdAtEpochMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_record_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletRecordLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('app_id')) {
      context.handle(
        _appIdMeta,
        appId.isAcceptableOrUnknown(data['app_id']!, _appIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
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
  WalletRecordLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletRecordLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      appId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      createdAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_epoch_ms'],
      )!,
    );
  }

  @override
  $WalletRecordLinksTable createAlias(String alias) {
    return $WalletRecordLinksTable(attachedDatabase, alias);
  }
}

class WalletRecordLink extends DataClass
    implements Insertable<WalletRecordLink> {
  final String id;
  final String appId;
  final String? remoteId;
  final int createdAtEpochMs;
  const WalletRecordLink({
    required this.id,
    required this.appId,
    this.remoteId,
    required this.createdAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['app_id'] = Variable<String>(appId);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    return map;
  }

  WalletRecordLinksCompanion toCompanion(bool nullToAbsent) {
    return WalletRecordLinksCompanion(
      id: Value(id),
      appId: Value(appId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      createdAtEpochMs: Value(createdAtEpochMs),
    );
  }

  factory WalletRecordLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletRecordLink(
      id: serializer.fromJson<String>(json['id']),
      appId: serializer.fromJson<String>(json['appId']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'appId': serializer.toJson<String>(appId),
      'remoteId': serializer.toJson<String?>(remoteId),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
    };
  }

  WalletRecordLink copyWith({
    String? id,
    String? appId,
    Value<String?> remoteId = const Value.absent(),
    int? createdAtEpochMs,
  }) => WalletRecordLink(
    id: id ?? this.id,
    appId: appId ?? this.appId,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
  );
  WalletRecordLink copyWithCompanion(WalletRecordLinksCompanion data) {
    return WalletRecordLink(
      id: data.id.present ? data.id.value : this.id,
      appId: data.appId.present ? data.appId.value : this.appId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletRecordLink(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAtEpochMs: $createdAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, appId, remoteId, createdAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletRecordLink &&
          other.id == this.id &&
          other.appId == this.appId &&
          other.remoteId == this.remoteId &&
          other.createdAtEpochMs == this.createdAtEpochMs);
}

class WalletRecordLinksCompanion extends UpdateCompanion<WalletRecordLink> {
  final Value<String> id;
  final Value<String> appId;
  final Value<String?> remoteId;
  final Value<int> createdAtEpochMs;
  final Value<int> rowid;
  const WalletRecordLinksCompanion({
    this.id = const Value.absent(),
    this.appId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletRecordLinksCompanion.insert({
    required String id,
    required String appId,
    this.remoteId = const Value.absent(),
    required int createdAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       appId = Value(appId),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<WalletRecordLink> custom({
    Expression<String>? id,
    Expression<String>? appId,
    Expression<String>? remoteId,
    Expression<int>? createdAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (remoteId != null) 'remote_id': remoteId,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletRecordLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? appId,
    Value<String?>? remoteId,
    Value<int>? createdAtEpochMs,
    Value<int>? rowid,
  }) {
    return WalletRecordLinksCompanion(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      remoteId: remoteId ?? this.remoteId,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (appId.present) {
      map['app_id'] = Variable<String>(appId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (createdAtEpochMs.present) {
      map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletRecordLinksCompanion(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapabilityLedgerTable extends CapabilityLedger
    with TableInfo<$CapabilityLedgerTable, CapabilityLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapabilityLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capabilityMeta = const VerificationMeta(
    'capability',
  );
  @override
  late final GeneratedColumn<String> capability = GeneratedColumn<String>(
    'capability',
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
  static const VerificationMeta _evidenceReferenceMeta = const VerificationMeta(
    'evidenceReference',
  );
  @override
  late final GeneratedColumn<String> evidenceReference =
      GeneratedColumn<String>(
        'evidence_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _observedOnMeta = const VerificationMeta(
    'observedOn',
  );
  @override
  late final GeneratedColumn<String> observedOn = GeneratedColumn<String>(
    'observed_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewDateMeta = const VerificationMeta(
    'reviewDate',
  );
  @override
  late final GeneratedColumn<String> reviewDate = GeneratedColumn<String>(
    'review_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    capability,
    status,
    evidenceReference,
    observedOn,
    reviewDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capability_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapabilityLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('capability')) {
      context.handle(
        _capabilityMeta,
        capability.isAcceptableOrUnknown(data['capability']!, _capabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_capabilityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('evidence_reference')) {
      context.handle(
        _evidenceReferenceMeta,
        evidenceReference.isAcceptableOrUnknown(
          data['evidence_reference']!,
          _evidenceReferenceMeta,
        ),
      );
    }
    if (data.containsKey('observed_on')) {
      context.handle(
        _observedOnMeta,
        observedOn.isAcceptableOrUnknown(data['observed_on']!, _observedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_observedOnMeta);
    }
    if (data.containsKey('review_date')) {
      context.handle(
        _reviewDateMeta,
        reviewDate.isAcceptableOrUnknown(data['review_date']!, _reviewDateMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapabilityLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapabilityLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      capability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capability'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      evidenceReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_reference'],
      ),
      observedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observed_on'],
      )!,
      reviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_date'],
      )!,
    );
  }

  @override
  $CapabilityLedgerTable createAlias(String alias) {
    return $CapabilityLedgerTable(attachedDatabase, alias);
  }
}

class CapabilityLedgerData extends DataClass
    implements Insertable<CapabilityLedgerData> {
  final String id;
  final String capability;
  final String status;
  final String? evidenceReference;
  final String observedOn;
  final String reviewDate;
  const CapabilityLedgerData({
    required this.id,
    required this.capability,
    required this.status,
    this.evidenceReference,
    required this.observedOn,
    required this.reviewDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['capability'] = Variable<String>(capability);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || evidenceReference != null) {
      map['evidence_reference'] = Variable<String>(evidenceReference);
    }
    map['observed_on'] = Variable<String>(observedOn);
    map['review_date'] = Variable<String>(reviewDate);
    return map;
  }

  CapabilityLedgerCompanion toCompanion(bool nullToAbsent) {
    return CapabilityLedgerCompanion(
      id: Value(id),
      capability: Value(capability),
      status: Value(status),
      evidenceReference: evidenceReference == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceReference),
      observedOn: Value(observedOn),
      reviewDate: Value(reviewDate),
    );
  }

  factory CapabilityLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapabilityLedgerData(
      id: serializer.fromJson<String>(json['id']),
      capability: serializer.fromJson<String>(json['capability']),
      status: serializer.fromJson<String>(json['status']),
      evidenceReference: serializer.fromJson<String?>(
        json['evidenceReference'],
      ),
      observedOn: serializer.fromJson<String>(json['observedOn']),
      reviewDate: serializer.fromJson<String>(json['reviewDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'capability': serializer.toJson<String>(capability),
      'status': serializer.toJson<String>(status),
      'evidenceReference': serializer.toJson<String?>(evidenceReference),
      'observedOn': serializer.toJson<String>(observedOn),
      'reviewDate': serializer.toJson<String>(reviewDate),
    };
  }

  CapabilityLedgerData copyWith({
    String? id,
    String? capability,
    String? status,
    Value<String?> evidenceReference = const Value.absent(),
    String? observedOn,
    String? reviewDate,
  }) => CapabilityLedgerData(
    id: id ?? this.id,
    capability: capability ?? this.capability,
    status: status ?? this.status,
    evidenceReference: evidenceReference.present
        ? evidenceReference.value
        : this.evidenceReference,
    observedOn: observedOn ?? this.observedOn,
    reviewDate: reviewDate ?? this.reviewDate,
  );
  CapabilityLedgerData copyWithCompanion(CapabilityLedgerCompanion data) {
    return CapabilityLedgerData(
      id: data.id.present ? data.id.value : this.id,
      capability: data.capability.present
          ? data.capability.value
          : this.capability,
      status: data.status.present ? data.status.value : this.status,
      evidenceReference: data.evidenceReference.present
          ? data.evidenceReference.value
          : this.evidenceReference,
      observedOn: data.observedOn.present
          ? data.observedOn.value
          : this.observedOn,
      reviewDate: data.reviewDate.present
          ? data.reviewDate.value
          : this.reviewDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapabilityLedgerData(')
          ..write('id: $id, ')
          ..write('capability: $capability, ')
          ..write('status: $status, ')
          ..write('evidenceReference: $evidenceReference, ')
          ..write('observedOn: $observedOn, ')
          ..write('reviewDate: $reviewDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    capability,
    status,
    evidenceReference,
    observedOn,
    reviewDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapabilityLedgerData &&
          other.id == this.id &&
          other.capability == this.capability &&
          other.status == this.status &&
          other.evidenceReference == this.evidenceReference &&
          other.observedOn == this.observedOn &&
          other.reviewDate == this.reviewDate);
}

class CapabilityLedgerCompanion extends UpdateCompanion<CapabilityLedgerData> {
  final Value<String> id;
  final Value<String> capability;
  final Value<String> status;
  final Value<String?> evidenceReference;
  final Value<String> observedOn;
  final Value<String> reviewDate;
  final Value<int> rowid;
  const CapabilityLedgerCompanion({
    this.id = const Value.absent(),
    this.capability = const Value.absent(),
    this.status = const Value.absent(),
    this.evidenceReference = const Value.absent(),
    this.observedOn = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapabilityLedgerCompanion.insert({
    required String id,
    required String capability,
    required String status,
    this.evidenceReference = const Value.absent(),
    required String observedOn,
    required String reviewDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       capability = Value(capability),
       status = Value(status),
       observedOn = Value(observedOn),
       reviewDate = Value(reviewDate);
  static Insertable<CapabilityLedgerData> custom({
    Expression<String>? id,
    Expression<String>? capability,
    Expression<String>? status,
    Expression<String>? evidenceReference,
    Expression<String>? observedOn,
    Expression<String>? reviewDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (capability != null) 'capability': capability,
      if (status != null) 'status': status,
      if (evidenceReference != null) 'evidence_reference': evidenceReference,
      if (observedOn != null) 'observed_on': observedOn,
      if (reviewDate != null) 'review_date': reviewDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapabilityLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? capability,
    Value<String>? status,
    Value<String?>? evidenceReference,
    Value<String>? observedOn,
    Value<String>? reviewDate,
    Value<int>? rowid,
  }) {
    return CapabilityLedgerCompanion(
      id: id ?? this.id,
      capability: capability ?? this.capability,
      status: status ?? this.status,
      evidenceReference: evidenceReference ?? this.evidenceReference,
      observedOn: observedOn ?? this.observedOn,
      reviewDate: reviewDate ?? this.reviewDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (capability.present) {
      map['capability'] = Variable<String>(capability.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (evidenceReference.present) {
      map['evidence_reference'] = Variable<String>(evidenceReference.value);
    }
    if (observedOn.present) {
      map['observed_on'] = Variable<String>(observedOn.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<String>(reviewDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapabilityLedgerCompanion(')
          ..write('id: $id, ')
          ..write('capability: $capability, ')
          ..write('status: $status, ')
          ..write('evidenceReference: $evidenceReference, ')
          ..write('observedOn: $observedOn, ')
          ..write('reviewDate: $reviewDate, ')
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
  late final $AppLockStateTable appLockState = $AppLockStateTable(this);
  late final $DeletionAuditEventsTable deletionAuditEvents =
      $DeletionAuditEventsTable(this);
  late final $WalletAccountCacheTable walletAccountCache =
      $WalletAccountCacheTable(this);
  late final $WalletCategoryCacheTable walletCategoryCache =
      $WalletCategoryCacheTable(this);
  late final $WalletConnectionStatusTable walletConnectionStatus =
      $WalletConnectionStatusTable(this);
  late final $WalletMutationsTable walletMutations = $WalletMutationsTable(
    this,
  );
  late final $WalletRecordLinksTable walletRecordLinks =
      $WalletRecordLinksTable(this);
  late final $CapabilityLedgerTable capabilityLedger = $CapabilityLedgerTable(
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
    appLockState,
    deletionAuditEvents,
    walletAccountCache,
    walletCategoryCache,
    walletConnectionStatus,
    walletMutations,
    walletRecordLinks,
    capabilityLedger,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> singletonId,
      Value<int> privacyEpoch,
      Value<bool> onboardingCompleted,
      Value<int?> onboardingRevision,
      Value<bool> disclosureAccepted,
      Value<int?> disclosureRevision,
      Value<String> processingMode,
      Value<int> configurationRevision,
      Value<int> rawCopyRetentionDays,
      Value<int> activityRetentionDays,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> singletonId,
      Value<int> privacyEpoch,
      Value<bool> onboardingCompleted,
      Value<int?> onboardingRevision,
      Value<bool> disclosureAccepted,
      Value<int?> disclosureRevision,
      Value<String> processingMode,
      Value<int> configurationRevision,
      Value<int> rawCopyRetentionDays,
      Value<int> activityRetentionDays,
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

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardingRevision => $composableBuilder(
    column: $table.onboardingRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get disclosureAccepted => $composableBuilder(
    column: $table.disclosureAccepted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disclosureRevision => $composableBuilder(
    column: $table.disclosureRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingMode => $composableBuilder(
    column: $table.processingMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configurationRevision => $composableBuilder(
    column: $table.configurationRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rawCopyRetentionDays => $composableBuilder(
    column: $table.rawCopyRetentionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activityRetentionDays => $composableBuilder(
    column: $table.activityRetentionDays,
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

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingRevision => $composableBuilder(
    column: $table.onboardingRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get disclosureAccepted => $composableBuilder(
    column: $table.disclosureAccepted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disclosureRevision => $composableBuilder(
    column: $table.disclosureRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingMode => $composableBuilder(
    column: $table.processingMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configurationRevision => $composableBuilder(
    column: $table.configurationRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rawCopyRetentionDays => $composableBuilder(
    column: $table.rawCopyRetentionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activityRetentionDays => $composableBuilder(
    column: $table.activityRetentionDays,
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

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get onboardingRevision => $composableBuilder(
    column: $table.onboardingRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get disclosureAccepted => $composableBuilder(
    column: $table.disclosureAccepted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get disclosureRevision => $composableBuilder(
    column: $table.disclosureRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processingMode => $composableBuilder(
    column: $table.processingMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get configurationRevision => $composableBuilder(
    column: $table.configurationRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rawCopyRetentionDays => $composableBuilder(
    column: $table.rawCopyRetentionDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activityRetentionDays => $composableBuilder(
    column: $table.activityRetentionDays,
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
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<int?> onboardingRevision = const Value.absent(),
                Value<bool> disclosureAccepted = const Value.absent(),
                Value<int?> disclosureRevision = const Value.absent(),
                Value<String> processingMode = const Value.absent(),
                Value<int> configurationRevision = const Value.absent(),
                Value<int> rawCopyRetentionDays = const Value.absent(),
                Value<int> activityRetentionDays = const Value.absent(),
              }) => AppSettingsCompanion(
                singletonId: singletonId,
                privacyEpoch: privacyEpoch,
                onboardingCompleted: onboardingCompleted,
                onboardingRevision: onboardingRevision,
                disclosureAccepted: disclosureAccepted,
                disclosureRevision: disclosureRevision,
                processingMode: processingMode,
                configurationRevision: configurationRevision,
                rawCopyRetentionDays: rawCopyRetentionDays,
                activityRetentionDays: activityRetentionDays,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<int?> onboardingRevision = const Value.absent(),
                Value<bool> disclosureAccepted = const Value.absent(),
                Value<int?> disclosureRevision = const Value.absent(),
                Value<String> processingMode = const Value.absent(),
                Value<int> configurationRevision = const Value.absent(),
                Value<int> rawCopyRetentionDays = const Value.absent(),
                Value<int> activityRetentionDays = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                singletonId: singletonId,
                privacyEpoch: privacyEpoch,
                onboardingCompleted: onboardingCompleted,
                onboardingRevision: onboardingRevision,
                disclosureAccepted: disclosureAccepted,
                disclosureRevision: disclosureRevision,
                processingMode: processingMode,
                configurationRevision: configurationRevision,
                rawCopyRetentionDays: rawCopyRetentionDays,
                activityRetentionDays: activityRetentionDays,
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
      Value<String?> parserVersion,
      Value<String?> parserChecksum,
    });
typedef $$SenderRulesTableUpdateCompanionBuilder =
    SenderRulesCompanion Function({
      Value<int> id,
      Value<String> senderHash,
      Value<String> parserFamily,
      Value<int> createdAtEpochMs,
      Value<String?> parserVersion,
      Value<String?> parserChecksum,
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

  ColumnFilters<String> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserChecksum => $composableBuilder(
    column: $table.parserChecksum,
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

  ColumnOrderings<String> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserChecksum => $composableBuilder(
    column: $table.parserChecksum,
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

  GeneratedColumn<String> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserChecksum => $composableBuilder(
    column: $table.parserChecksum,
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
                Value<String?> parserVersion = const Value.absent(),
                Value<String?> parserChecksum = const Value.absent(),
              }) => SenderRulesCompanion(
                id: id,
                senderHash: senderHash,
                parserFamily: parserFamily,
                createdAtEpochMs: createdAtEpochMs,
                parserVersion: parserVersion,
                parserChecksum: parserChecksum,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String senderHash,
                required String parserFamily,
                required int createdAtEpochMs,
                Value<String?> parserVersion = const Value.absent(),
                Value<String?> parserChecksum = const Value.absent(),
              }) => SenderRulesCompanion.insert(
                id: id,
                senderHash: senderHash,
                parserFamily: parserFamily,
                createdAtEpochMs: createdAtEpochMs,
                parserVersion: parserVersion,
                parserChecksum: parserChecksum,
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
      Value<String?> warningCode,
      Value<String?> paymentEvidence,
      Value<String?> instrumentEvidence,
      Value<String?> originalCurrencyCode,
      Value<String?> walletCurrencyCode,
    });
typedef $$TransactionCandidatesTableUpdateCompanionBuilder =
    TransactionCandidatesCompanion Function({
      Value<int> id,
      Value<int> smsEventId,
      Value<CandidateRecordState> state,
      Value<String> encryptedPayload,
      Value<int> revision,
      Value<int> createdAtEpochMs,
      Value<String?> warningCode,
      Value<String?> paymentEvidence,
      Value<String?> instrumentEvidence,
      Value<String?> originalCurrencyCode,
      Value<String?> walletCurrencyCode,
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

  ColumnFilters<String> get warningCode => $composableBuilder(
    column: $table.warningCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentEvidence => $composableBuilder(
    column: $table.paymentEvidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentEvidence => $composableBuilder(
    column: $table.instrumentEvidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletCurrencyCode => $composableBuilder(
    column: $table.walletCurrencyCode,
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

  ColumnOrderings<String> get warningCode => $composableBuilder(
    column: $table.warningCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentEvidence => $composableBuilder(
    column: $table.paymentEvidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentEvidence => $composableBuilder(
    column: $table.instrumentEvidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletCurrencyCode => $composableBuilder(
    column: $table.walletCurrencyCode,
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

  GeneratedColumn<String> get warningCode => $composableBuilder(
    column: $table.warningCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentEvidence => $composableBuilder(
    column: $table.paymentEvidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instrumentEvidence => $composableBuilder(
    column: $table.instrumentEvidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walletCurrencyCode => $composableBuilder(
    column: $table.walletCurrencyCode,
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
                Value<String?> warningCode = const Value.absent(),
                Value<String?> paymentEvidence = const Value.absent(),
                Value<String?> instrumentEvidence = const Value.absent(),
                Value<String?> originalCurrencyCode = const Value.absent(),
                Value<String?> walletCurrencyCode = const Value.absent(),
              }) => TransactionCandidatesCompanion(
                id: id,
                smsEventId: smsEventId,
                state: state,
                encryptedPayload: encryptedPayload,
                revision: revision,
                createdAtEpochMs: createdAtEpochMs,
                warningCode: warningCode,
                paymentEvidence: paymentEvidence,
                instrumentEvidence: instrumentEvidence,
                originalCurrencyCode: originalCurrencyCode,
                walletCurrencyCode: walletCurrencyCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int smsEventId,
                required CandidateRecordState state,
                required String encryptedPayload,
                required int revision,
                required int createdAtEpochMs,
                Value<String?> warningCode = const Value.absent(),
                Value<String?> paymentEvidence = const Value.absent(),
                Value<String?> instrumentEvidence = const Value.absent(),
                Value<String?> originalCurrencyCode = const Value.absent(),
                Value<String?> walletCurrencyCode = const Value.absent(),
              }) => TransactionCandidatesCompanion.insert(
                id: id,
                smsEventId: smsEventId,
                state: state,
                encryptedPayload: encryptedPayload,
                revision: revision,
                createdAtEpochMs: createdAtEpochMs,
                warningCode: warningCode,
                paymentEvidence: paymentEvidence,
                instrumentEvidence: instrumentEvidence,
                originalCurrencyCode: originalCurrencyCode,
                walletCurrencyCode: walletCurrencyCode,
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
typedef $$AppLockStateTableCreateCompanionBuilder =
    AppLockStateCompanion Function({
      Value<int> singletonId,
      Value<bool> lockEnabled,
      Value<int> inactivityTimeoutSeconds,
      Value<String?> lockMetadata,
    });
typedef $$AppLockStateTableUpdateCompanionBuilder =
    AppLockStateCompanion Function({
      Value<int> singletonId,
      Value<bool> lockEnabled,
      Value<int> inactivityTimeoutSeconds,
      Value<String?> lockMetadata,
    });

class $$AppLockStateTableFilterComposer
    extends Composer<_$AppDatabase, $AppLockStateTable> {
  $$AppLockStateTableFilterComposer({
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

  ColumnFilters<bool> get lockEnabled => $composableBuilder(
    column: $table.lockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inactivityTimeoutSeconds => $composableBuilder(
    column: $table.inactivityTimeoutSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lockMetadata => $composableBuilder(
    column: $table.lockMetadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppLockStateTableOrderingComposer
    extends Composer<_$AppDatabase, $AppLockStateTable> {
  $$AppLockStateTableOrderingComposer({
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

  ColumnOrderings<bool> get lockEnabled => $composableBuilder(
    column: $table.lockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inactivityTimeoutSeconds => $composableBuilder(
    column: $table.inactivityTimeoutSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lockMetadata => $composableBuilder(
    column: $table.lockMetadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppLockStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppLockStateTable> {
  $$AppLockStateTableAnnotationComposer({
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

  GeneratedColumn<bool> get lockEnabled => $composableBuilder(
    column: $table.lockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inactivityTimeoutSeconds => $composableBuilder(
    column: $table.inactivityTimeoutSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lockMetadata => $composableBuilder(
    column: $table.lockMetadata,
    builder: (column) => column,
  );
}

class $$AppLockStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppLockStateTable,
          AppLockStateData,
          $$AppLockStateTableFilterComposer,
          $$AppLockStateTableOrderingComposer,
          $$AppLockStateTableAnnotationComposer,
          $$AppLockStateTableCreateCompanionBuilder,
          $$AppLockStateTableUpdateCompanionBuilder,
          (
            AppLockStateData,
            BaseReferences<_$AppDatabase, $AppLockStateTable, AppLockStateData>,
          ),
          AppLockStateData,
          PrefetchHooks Function()
        > {
  $$AppLockStateTableTableManager(_$AppDatabase db, $AppLockStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppLockStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppLockStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppLockStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<bool> lockEnabled = const Value.absent(),
                Value<int> inactivityTimeoutSeconds = const Value.absent(),
                Value<String?> lockMetadata = const Value.absent(),
              }) => AppLockStateCompanion(
                singletonId: singletonId,
                lockEnabled: lockEnabled,
                inactivityTimeoutSeconds: inactivityTimeoutSeconds,
                lockMetadata: lockMetadata,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<bool> lockEnabled = const Value.absent(),
                Value<int> inactivityTimeoutSeconds = const Value.absent(),
                Value<String?> lockMetadata = const Value.absent(),
              }) => AppLockStateCompanion.insert(
                singletonId: singletonId,
                lockEnabled: lockEnabled,
                inactivityTimeoutSeconds: inactivityTimeoutSeconds,
                lockMetadata: lockMetadata,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppLockStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppLockStateTable,
      AppLockStateData,
      $$AppLockStateTableFilterComposer,
      $$AppLockStateTableOrderingComposer,
      $$AppLockStateTableAnnotationComposer,
      $$AppLockStateTableCreateCompanionBuilder,
      $$AppLockStateTableUpdateCompanionBuilder,
      (
        AppLockStateData,
        BaseReferences<_$AppDatabase, $AppLockStateTable, AppLockStateData>,
      ),
      AppLockStateData,
      PrefetchHooks Function()
    >;
typedef $$DeletionAuditEventsTableCreateCompanionBuilder =
    DeletionAuditEventsCompanion Function({
      Value<int> id,
      required int privacyEpochBefore,
      required int privacyEpochAfter,
      required int occurredAtEpochMs,
    });
typedef $$DeletionAuditEventsTableUpdateCompanionBuilder =
    DeletionAuditEventsCompanion Function({
      Value<int> id,
      Value<int> privacyEpochBefore,
      Value<int> privacyEpochAfter,
      Value<int> occurredAtEpochMs,
    });

class $$DeletionAuditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DeletionAuditEventsTable> {
  $$DeletionAuditEventsTableFilterComposer({
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

  ColumnFilters<int> get privacyEpochBefore => $composableBuilder(
    column: $table.privacyEpochBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privacyEpochAfter => $composableBuilder(
    column: $table.privacyEpochAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtEpochMs => $composableBuilder(
    column: $table.occurredAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeletionAuditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeletionAuditEventsTable> {
  $$DeletionAuditEventsTableOrderingComposer({
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

  ColumnOrderings<int> get privacyEpochBefore => $composableBuilder(
    column: $table.privacyEpochBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privacyEpochAfter => $composableBuilder(
    column: $table.privacyEpochAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtEpochMs => $composableBuilder(
    column: $table.occurredAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeletionAuditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeletionAuditEventsTable> {
  $$DeletionAuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get privacyEpochBefore => $composableBuilder(
    column: $table.privacyEpochBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get privacyEpochAfter => $composableBuilder(
    column: $table.privacyEpochAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAtEpochMs => $composableBuilder(
    column: $table.occurredAtEpochMs,
    builder: (column) => column,
  );
}

class $$DeletionAuditEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeletionAuditEventsTable,
          DeletionAuditEvent,
          $$DeletionAuditEventsTableFilterComposer,
          $$DeletionAuditEventsTableOrderingComposer,
          $$DeletionAuditEventsTableAnnotationComposer,
          $$DeletionAuditEventsTableCreateCompanionBuilder,
          $$DeletionAuditEventsTableUpdateCompanionBuilder,
          (
            DeletionAuditEvent,
            BaseReferences<
              _$AppDatabase,
              $DeletionAuditEventsTable,
              DeletionAuditEvent
            >,
          ),
          DeletionAuditEvent,
          PrefetchHooks Function()
        > {
  $$DeletionAuditEventsTableTableManager(
    _$AppDatabase db,
    $DeletionAuditEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeletionAuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeletionAuditEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeletionAuditEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> privacyEpochBefore = const Value.absent(),
                Value<int> privacyEpochAfter = const Value.absent(),
                Value<int> occurredAtEpochMs = const Value.absent(),
              }) => DeletionAuditEventsCompanion(
                id: id,
                privacyEpochBefore: privacyEpochBefore,
                privacyEpochAfter: privacyEpochAfter,
                occurredAtEpochMs: occurredAtEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int privacyEpochBefore,
                required int privacyEpochAfter,
                required int occurredAtEpochMs,
              }) => DeletionAuditEventsCompanion.insert(
                id: id,
                privacyEpochBefore: privacyEpochBefore,
                privacyEpochAfter: privacyEpochAfter,
                occurredAtEpochMs: occurredAtEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeletionAuditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeletionAuditEventsTable,
      DeletionAuditEvent,
      $$DeletionAuditEventsTableFilterComposer,
      $$DeletionAuditEventsTableOrderingComposer,
      $$DeletionAuditEventsTableAnnotationComposer,
      $$DeletionAuditEventsTableCreateCompanionBuilder,
      $$DeletionAuditEventsTableUpdateCompanionBuilder,
      (
        DeletionAuditEvent,
        BaseReferences<
          _$AppDatabase,
          $DeletionAuditEventsTable,
          DeletionAuditEvent
        >,
      ),
      DeletionAuditEvent,
      PrefetchHooks Function()
    >;
typedef $$WalletAccountCacheTableCreateCompanionBuilder =
    WalletAccountCacheCompanion Function({
      required String id,
      required String name,
      required String currencyCode,
      required bool isArchived,
      required bool isBankSynced,
      required bool isWritable,
      required String eligibilityReason,
      required int refreshedAtEpochMs,
      Value<int> rowid,
    });
typedef $$WalletAccountCacheTableUpdateCompanionBuilder =
    WalletAccountCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> currencyCode,
      Value<bool> isArchived,
      Value<bool> isBankSynced,
      Value<bool> isWritable,
      Value<String> eligibilityReason,
      Value<int> refreshedAtEpochMs,
      Value<int> rowid,
    });

class $$WalletAccountCacheTableFilterComposer
    extends Composer<_$AppDatabase, $WalletAccountCacheTable> {
  $$WalletAccountCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBankSynced => $composableBuilder(
    column: $table.isBankSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWritable => $composableBuilder(
    column: $table.isWritable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eligibilityReason => $composableBuilder(
    column: $table.eligibilityReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refreshedAtEpochMs => $composableBuilder(
    column: $table.refreshedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletAccountCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletAccountCacheTable> {
  $$WalletAccountCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBankSynced => $composableBuilder(
    column: $table.isBankSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWritable => $composableBuilder(
    column: $table.isWritable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eligibilityReason => $composableBuilder(
    column: $table.eligibilityReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refreshedAtEpochMs => $composableBuilder(
    column: $table.refreshedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletAccountCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletAccountCacheTable> {
  $$WalletAccountCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBankSynced => $composableBuilder(
    column: $table.isBankSynced,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWritable => $composableBuilder(
    column: $table.isWritable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eligibilityReason => $composableBuilder(
    column: $table.eligibilityReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refreshedAtEpochMs => $composableBuilder(
    column: $table.refreshedAtEpochMs,
    builder: (column) => column,
  );
}

class $$WalletAccountCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletAccountCacheTable,
          WalletAccountCacheData,
          $$WalletAccountCacheTableFilterComposer,
          $$WalletAccountCacheTableOrderingComposer,
          $$WalletAccountCacheTableAnnotationComposer,
          $$WalletAccountCacheTableCreateCompanionBuilder,
          $$WalletAccountCacheTableUpdateCompanionBuilder,
          (
            WalletAccountCacheData,
            BaseReferences<
              _$AppDatabase,
              $WalletAccountCacheTable,
              WalletAccountCacheData
            >,
          ),
          WalletAccountCacheData,
          PrefetchHooks Function()
        > {
  $$WalletAccountCacheTableTableManager(
    _$AppDatabase db,
    $WalletAccountCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletAccountCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletAccountCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletAccountCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isBankSynced = const Value.absent(),
                Value<bool> isWritable = const Value.absent(),
                Value<String> eligibilityReason = const Value.absent(),
                Value<int> refreshedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletAccountCacheCompanion(
                id: id,
                name: name,
                currencyCode: currencyCode,
                isArchived: isArchived,
                isBankSynced: isBankSynced,
                isWritable: isWritable,
                eligibilityReason: eligibilityReason,
                refreshedAtEpochMs: refreshedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String currencyCode,
                required bool isArchived,
                required bool isBankSynced,
                required bool isWritable,
                required String eligibilityReason,
                required int refreshedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => WalletAccountCacheCompanion.insert(
                id: id,
                name: name,
                currencyCode: currencyCode,
                isArchived: isArchived,
                isBankSynced: isBankSynced,
                isWritable: isWritable,
                eligibilityReason: eligibilityReason,
                refreshedAtEpochMs: refreshedAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletAccountCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletAccountCacheTable,
      WalletAccountCacheData,
      $$WalletAccountCacheTableFilterComposer,
      $$WalletAccountCacheTableOrderingComposer,
      $$WalletAccountCacheTableAnnotationComposer,
      $$WalletAccountCacheTableCreateCompanionBuilder,
      $$WalletAccountCacheTableUpdateCompanionBuilder,
      (
        WalletAccountCacheData,
        BaseReferences<
          _$AppDatabase,
          $WalletAccountCacheTable,
          WalletAccountCacheData
        >,
      ),
      WalletAccountCacheData,
      PrefetchHooks Function()
    >;
typedef $$WalletCategoryCacheTableCreateCompanionBuilder =
    WalletCategoryCacheCompanion Function({
      required String id,
      required String name,
      required int refreshedAtEpochMs,
      Value<int> rowid,
    });
typedef $$WalletCategoryCacheTableUpdateCompanionBuilder =
    WalletCategoryCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> refreshedAtEpochMs,
      Value<int> rowid,
    });

class $$WalletCategoryCacheTableFilterComposer
    extends Composer<_$AppDatabase, $WalletCategoryCacheTable> {
  $$WalletCategoryCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refreshedAtEpochMs => $composableBuilder(
    column: $table.refreshedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletCategoryCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletCategoryCacheTable> {
  $$WalletCategoryCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refreshedAtEpochMs => $composableBuilder(
    column: $table.refreshedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletCategoryCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletCategoryCacheTable> {
  $$WalletCategoryCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get refreshedAtEpochMs => $composableBuilder(
    column: $table.refreshedAtEpochMs,
    builder: (column) => column,
  );
}

class $$WalletCategoryCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletCategoryCacheTable,
          WalletCategoryCacheData,
          $$WalletCategoryCacheTableFilterComposer,
          $$WalletCategoryCacheTableOrderingComposer,
          $$WalletCategoryCacheTableAnnotationComposer,
          $$WalletCategoryCacheTableCreateCompanionBuilder,
          $$WalletCategoryCacheTableUpdateCompanionBuilder,
          (
            WalletCategoryCacheData,
            BaseReferences<
              _$AppDatabase,
              $WalletCategoryCacheTable,
              WalletCategoryCacheData
            >,
          ),
          WalletCategoryCacheData,
          PrefetchHooks Function()
        > {
  $$WalletCategoryCacheTableTableManager(
    _$AppDatabase db,
    $WalletCategoryCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletCategoryCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletCategoryCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WalletCategoryCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> refreshedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletCategoryCacheCompanion(
                id: id,
                name: name,
                refreshedAtEpochMs: refreshedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int refreshedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => WalletCategoryCacheCompanion.insert(
                id: id,
                name: name,
                refreshedAtEpochMs: refreshedAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletCategoryCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletCategoryCacheTable,
      WalletCategoryCacheData,
      $$WalletCategoryCacheTableFilterComposer,
      $$WalletCategoryCacheTableOrderingComposer,
      $$WalletCategoryCacheTableAnnotationComposer,
      $$WalletCategoryCacheTableCreateCompanionBuilder,
      $$WalletCategoryCacheTableUpdateCompanionBuilder,
      (
        WalletCategoryCacheData,
        BaseReferences<
          _$AppDatabase,
          $WalletCategoryCacheTable,
          WalletCategoryCacheData
        >,
      ),
      WalletCategoryCacheData,
      PrefetchHooks Function()
    >;
typedef $$WalletConnectionStatusTableCreateCompanionBuilder =
    WalletConnectionStatusCompanion Function({
      Value<int> singletonId,
      Value<String> status,
      Value<int?> lastSyncAtEpochMs,
    });
typedef $$WalletConnectionStatusTableUpdateCompanionBuilder =
    WalletConnectionStatusCompanion Function({
      Value<int> singletonId,
      Value<String> status,
      Value<int?> lastSyncAtEpochMs,
    });

class $$WalletConnectionStatusTableFilterComposer
    extends Composer<_$AppDatabase, $WalletConnectionStatusTable> {
  $$WalletConnectionStatusTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncAtEpochMs => $composableBuilder(
    column: $table.lastSyncAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletConnectionStatusTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletConnectionStatusTable> {
  $$WalletConnectionStatusTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncAtEpochMs => $composableBuilder(
    column: $table.lastSyncAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletConnectionStatusTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletConnectionStatusTable> {
  $$WalletConnectionStatusTableAnnotationComposer({
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get lastSyncAtEpochMs => $composableBuilder(
    column: $table.lastSyncAtEpochMs,
    builder: (column) => column,
  );
}

class $$WalletConnectionStatusTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletConnectionStatusTable,
          WalletConnectionStatusData,
          $$WalletConnectionStatusTableFilterComposer,
          $$WalletConnectionStatusTableOrderingComposer,
          $$WalletConnectionStatusTableAnnotationComposer,
          $$WalletConnectionStatusTableCreateCompanionBuilder,
          $$WalletConnectionStatusTableUpdateCompanionBuilder,
          (
            WalletConnectionStatusData,
            BaseReferences<
              _$AppDatabase,
              $WalletConnectionStatusTable,
              WalletConnectionStatusData
            >,
          ),
          WalletConnectionStatusData,
          PrefetchHooks Function()
        > {
  $$WalletConnectionStatusTableTableManager(
    _$AppDatabase db,
    $WalletConnectionStatusTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletConnectionStatusTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WalletConnectionStatusTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WalletConnectionStatusTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> lastSyncAtEpochMs = const Value.absent(),
              }) => WalletConnectionStatusCompanion(
                singletonId: singletonId,
                status: status,
                lastSyncAtEpochMs: lastSyncAtEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> lastSyncAtEpochMs = const Value.absent(),
              }) => WalletConnectionStatusCompanion.insert(
                singletonId: singletonId,
                status: status,
                lastSyncAtEpochMs: lastSyncAtEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletConnectionStatusTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletConnectionStatusTable,
      WalletConnectionStatusData,
      $$WalletConnectionStatusTableFilterComposer,
      $$WalletConnectionStatusTableOrderingComposer,
      $$WalletConnectionStatusTableAnnotationComposer,
      $$WalletConnectionStatusTableCreateCompanionBuilder,
      $$WalletConnectionStatusTableUpdateCompanionBuilder,
      (
        WalletConnectionStatusData,
        BaseReferences<
          _$AppDatabase,
          $WalletConnectionStatusTable,
          WalletConnectionStatusData
        >,
      ),
      WalletConnectionStatusData,
      PrefetchHooks Function()
    >;
typedef $$WalletMutationsTableCreateCompanionBuilder =
    WalletMutationsCompanion Function({
      required String id,
      required String operation,
      required String payload,
      required String state,
      required String lineageKey,
      required String fingerprint,
      required int createdAtEpochMs,
      required int updatedAtEpochMs,
      Value<int> rowid,
    });
typedef $$WalletMutationsTableUpdateCompanionBuilder =
    WalletMutationsCompanion Function({
      Value<String> id,
      Value<String> operation,
      Value<String> payload,
      Value<String> state,
      Value<String> lineageKey,
      Value<String> fingerprint,
      Value<int> createdAtEpochMs,
      Value<int> updatedAtEpochMs,
      Value<int> rowid,
    });

class $$WalletMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletMutationsTable> {
  $$WalletMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineageKey => $composableBuilder(
    column: $table.lineageKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletMutationsTable> {
  $$WalletMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineageKey => $composableBuilder(
    column: $table.lineageKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletMutationsTable> {
  $$WalletMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get lineageKey => $composableBuilder(
    column: $table.lineageKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => column,
  );
}

class $$WalletMutationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletMutationsTable,
          WalletMutation,
          $$WalletMutationsTableFilterComposer,
          $$WalletMutationsTableOrderingComposer,
          $$WalletMutationsTableAnnotationComposer,
          $$WalletMutationsTableCreateCompanionBuilder,
          $$WalletMutationsTableUpdateCompanionBuilder,
          (
            WalletMutation,
            BaseReferences<
              _$AppDatabase,
              $WalletMutationsTable,
              WalletMutation
            >,
          ),
          WalletMutation,
          PrefetchHooks Function()
        > {
  $$WalletMutationsTableTableManager(
    _$AppDatabase db,
    $WalletMutationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> lineageKey = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
                Value<int> updatedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletMutationsCompanion(
                id: id,
                operation: operation,
                payload: payload,
                state: state,
                lineageKey: lineageKey,
                fingerprint: fingerprint,
                createdAtEpochMs: createdAtEpochMs,
                updatedAtEpochMs: updatedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operation,
                required String payload,
                required String state,
                required String lineageKey,
                required String fingerprint,
                required int createdAtEpochMs,
                required int updatedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => WalletMutationsCompanion.insert(
                id: id,
                operation: operation,
                payload: payload,
                state: state,
                lineageKey: lineageKey,
                fingerprint: fingerprint,
                createdAtEpochMs: createdAtEpochMs,
                updatedAtEpochMs: updatedAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletMutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletMutationsTable,
      WalletMutation,
      $$WalletMutationsTableFilterComposer,
      $$WalletMutationsTableOrderingComposer,
      $$WalletMutationsTableAnnotationComposer,
      $$WalletMutationsTableCreateCompanionBuilder,
      $$WalletMutationsTableUpdateCompanionBuilder,
      (
        WalletMutation,
        BaseReferences<_$AppDatabase, $WalletMutationsTable, WalletMutation>,
      ),
      WalletMutation,
      PrefetchHooks Function()
    >;
typedef $$WalletRecordLinksTableCreateCompanionBuilder =
    WalletRecordLinksCompanion Function({
      required String id,
      required String appId,
      Value<String?> remoteId,
      required int createdAtEpochMs,
      Value<int> rowid,
    });
typedef $$WalletRecordLinksTableUpdateCompanionBuilder =
    WalletRecordLinksCompanion Function({
      Value<String> id,
      Value<String> appId,
      Value<String?> remoteId,
      Value<int> createdAtEpochMs,
      Value<int> rowid,
    });

class $$WalletRecordLinksTableFilterComposer
    extends Composer<_$AppDatabase, $WalletRecordLinksTable> {
  $$WalletRecordLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletRecordLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletRecordLinksTable> {
  $$WalletRecordLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletRecordLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletRecordLinksTable> {
  $$WalletRecordLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appId =>
      $composableBuilder(column: $table.appId, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => column,
  );
}

class $$WalletRecordLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletRecordLinksTable,
          WalletRecordLink,
          $$WalletRecordLinksTableFilterComposer,
          $$WalletRecordLinksTableOrderingComposer,
          $$WalletRecordLinksTableAnnotationComposer,
          $$WalletRecordLinksTableCreateCompanionBuilder,
          $$WalletRecordLinksTableUpdateCompanionBuilder,
          (
            WalletRecordLink,
            BaseReferences<
              _$AppDatabase,
              $WalletRecordLinksTable,
              WalletRecordLink
            >,
          ),
          WalletRecordLink,
          PrefetchHooks Function()
        > {
  $$WalletRecordLinksTableTableManager(
    _$AppDatabase db,
    $WalletRecordLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletRecordLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletRecordLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletRecordLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> appId = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletRecordLinksCompanion(
                id: id,
                appId: appId,
                remoteId: remoteId,
                createdAtEpochMs: createdAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String appId,
                Value<String?> remoteId = const Value.absent(),
                required int createdAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => WalletRecordLinksCompanion.insert(
                id: id,
                appId: appId,
                remoteId: remoteId,
                createdAtEpochMs: createdAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletRecordLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletRecordLinksTable,
      WalletRecordLink,
      $$WalletRecordLinksTableFilterComposer,
      $$WalletRecordLinksTableOrderingComposer,
      $$WalletRecordLinksTableAnnotationComposer,
      $$WalletRecordLinksTableCreateCompanionBuilder,
      $$WalletRecordLinksTableUpdateCompanionBuilder,
      (
        WalletRecordLink,
        BaseReferences<
          _$AppDatabase,
          $WalletRecordLinksTable,
          WalletRecordLink
        >,
      ),
      WalletRecordLink,
      PrefetchHooks Function()
    >;
typedef $$CapabilityLedgerTableCreateCompanionBuilder =
    CapabilityLedgerCompanion Function({
      required String id,
      required String capability,
      required String status,
      Value<String?> evidenceReference,
      required String observedOn,
      required String reviewDate,
      Value<int> rowid,
    });
typedef $$CapabilityLedgerTableUpdateCompanionBuilder =
    CapabilityLedgerCompanion Function({
      Value<String> id,
      Value<String> capability,
      Value<String> status,
      Value<String?> evidenceReference,
      Value<String> observedOn,
      Value<String> reviewDate,
      Value<int> rowid,
    });

class $$CapabilityLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $CapabilityLedgerTable> {
  $$CapabilityLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capability => $composableBuilder(
    column: $table.capability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceReference => $composableBuilder(
    column: $table.evidenceReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observedOn => $composableBuilder(
    column: $table.observedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapabilityLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $CapabilityLedgerTable> {
  $$CapabilityLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capability => $composableBuilder(
    column: $table.capability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceReference => $composableBuilder(
    column: $table.evidenceReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observedOn => $composableBuilder(
    column: $table.observedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapabilityLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapabilityLedgerTable> {
  $$CapabilityLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get capability => $composableBuilder(
    column: $table.capability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get evidenceReference => $composableBuilder(
    column: $table.evidenceReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observedOn => $composableBuilder(
    column: $table.observedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => column,
  );
}

class $$CapabilityLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapabilityLedgerTable,
          CapabilityLedgerData,
          $$CapabilityLedgerTableFilterComposer,
          $$CapabilityLedgerTableOrderingComposer,
          $$CapabilityLedgerTableAnnotationComposer,
          $$CapabilityLedgerTableCreateCompanionBuilder,
          $$CapabilityLedgerTableUpdateCompanionBuilder,
          (
            CapabilityLedgerData,
            BaseReferences<
              _$AppDatabase,
              $CapabilityLedgerTable,
              CapabilityLedgerData
            >,
          ),
          CapabilityLedgerData,
          PrefetchHooks Function()
        > {
  $$CapabilityLedgerTableTableManager(
    _$AppDatabase db,
    $CapabilityLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapabilityLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapabilityLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapabilityLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> capability = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> evidenceReference = const Value.absent(),
                Value<String> observedOn = const Value.absent(),
                Value<String> reviewDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapabilityLedgerCompanion(
                id: id,
                capability: capability,
                status: status,
                evidenceReference: evidenceReference,
                observedOn: observedOn,
                reviewDate: reviewDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String capability,
                required String status,
                Value<String?> evidenceReference = const Value.absent(),
                required String observedOn,
                required String reviewDate,
                Value<int> rowid = const Value.absent(),
              }) => CapabilityLedgerCompanion.insert(
                id: id,
                capability: capability,
                status: status,
                evidenceReference: evidenceReference,
                observedOn: observedOn,
                reviewDate: reviewDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapabilityLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapabilityLedgerTable,
      CapabilityLedgerData,
      $$CapabilityLedgerTableFilterComposer,
      $$CapabilityLedgerTableOrderingComposer,
      $$CapabilityLedgerTableAnnotationComposer,
      $$CapabilityLedgerTableCreateCompanionBuilder,
      $$CapabilityLedgerTableUpdateCompanionBuilder,
      (
        CapabilityLedgerData,
        BaseReferences<
          _$AppDatabase,
          $CapabilityLedgerTable,
          CapabilityLedgerData
        >,
      ),
      CapabilityLedgerData,
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
  $$AppLockStateTableTableManager get appLockState =>
      $$AppLockStateTableTableManager(_db, _db.appLockState);
  $$DeletionAuditEventsTableTableManager get deletionAuditEvents =>
      $$DeletionAuditEventsTableTableManager(_db, _db.deletionAuditEvents);
  $$WalletAccountCacheTableTableManager get walletAccountCache =>
      $$WalletAccountCacheTableTableManager(_db, _db.walletAccountCache);
  $$WalletCategoryCacheTableTableManager get walletCategoryCache =>
      $$WalletCategoryCacheTableTableManager(_db, _db.walletCategoryCache);
  $$WalletConnectionStatusTableTableManager get walletConnectionStatus =>
      $$WalletConnectionStatusTableTableManager(
        _db,
        _db.walletConnectionStatus,
      );
  $$WalletMutationsTableTableManager get walletMutations =>
      $$WalletMutationsTableTableManager(_db, _db.walletMutations);
  $$WalletRecordLinksTableTableManager get walletRecordLinks =>
      $$WalletRecordLinksTableTableManager(_db, _db.walletRecordLinks);
  $$CapabilityLedgerTableTableManager get capabilityLedger =>
      $$CapabilityLedgerTableTableManager(_db, _db.capabilityLedger);
}
