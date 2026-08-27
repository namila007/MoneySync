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
  static const VerificationMeta _smsDisclosureRevisionMeta =
      const VerificationMeta('smsDisclosureRevision');
  @override
  late final GeneratedColumn<int> smsDisclosureRevision = GeneratedColumn<int>(
    'sms_disclosure_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _historySmsEnabledMeta = const VerificationMeta(
    'historySmsEnabled',
  );
  @override
  late final GeneratedColumn<bool> historySmsEnabled = GeneratedColumn<bool>(
    'history_sms_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("history_sms_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _historyWindowDaysMeta = const VerificationMeta(
    'historyWindowDays',
  );
  @override
  late final GeneratedColumn<int> historyWindowDays = GeneratedColumn<int>(
    'history_window_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _historyMessageCapMeta = const VerificationMeta(
    'historyMessageCap',
  );
  @override
  late final GeneratedColumn<int> historyMessageCap = GeneratedColumn<int>(
    'history_message_cap',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _autoImportEnabledMeta = const VerificationMeta(
    'autoImportEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoImportEnabled = GeneratedColumn<bool>(
    'auto_import_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_import_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoCreateEnabledMeta = const VerificationMeta(
    'autoCreateEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoCreateEnabled = GeneratedColumn<bool>(
    'auto_create_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_create_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoImportIntervalMinutesMeta =
      const VerificationMeta('autoImportIntervalMinutes');
  @override
  late final GeneratedColumn<int> autoImportIntervalMinutes =
      GeneratedColumn<int>(
        'auto_import_interval_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(15),
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
    smsDisclosureRevision,
    historySmsEnabled,
    historyWindowDays,
    historyMessageCap,
    autoImportEnabled,
    autoCreateEnabled,
    autoImportIntervalMinutes,
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
    if (data.containsKey('sms_disclosure_revision')) {
      context.handle(
        _smsDisclosureRevisionMeta,
        smsDisclosureRevision.isAcceptableOrUnknown(
          data['sms_disclosure_revision']!,
          _smsDisclosureRevisionMeta,
        ),
      );
    }
    if (data.containsKey('history_sms_enabled')) {
      context.handle(
        _historySmsEnabledMeta,
        historySmsEnabled.isAcceptableOrUnknown(
          data['history_sms_enabled']!,
          _historySmsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('history_window_days')) {
      context.handle(
        _historyWindowDaysMeta,
        historyWindowDays.isAcceptableOrUnknown(
          data['history_window_days']!,
          _historyWindowDaysMeta,
        ),
      );
    }
    if (data.containsKey('history_message_cap')) {
      context.handle(
        _historyMessageCapMeta,
        historyMessageCap.isAcceptableOrUnknown(
          data['history_message_cap']!,
          _historyMessageCapMeta,
        ),
      );
    }
    if (data.containsKey('auto_import_enabled')) {
      context.handle(
        _autoImportEnabledMeta,
        autoImportEnabled.isAcceptableOrUnknown(
          data['auto_import_enabled']!,
          _autoImportEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_create_enabled')) {
      context.handle(
        _autoCreateEnabledMeta,
        autoCreateEnabled.isAcceptableOrUnknown(
          data['auto_create_enabled']!,
          _autoCreateEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_import_interval_minutes')) {
      context.handle(
        _autoImportIntervalMinutesMeta,
        autoImportIntervalMinutes.isAcceptableOrUnknown(
          data['auto_import_interval_minutes']!,
          _autoImportIntervalMinutesMeta,
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
      smsDisclosureRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sms_disclosure_revision'],
      ),
      historySmsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}history_sms_enabled'],
      )!,
      historyWindowDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_window_days'],
      )!,
      historyMessageCap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_message_cap'],
      )!,
      autoImportEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_import_enabled'],
      )!,
      autoCreateEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_create_enabled'],
      )!,
      autoImportIntervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_import_interval_minutes'],
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
  final int? smsDisclosureRevision;
  final bool historySmsEnabled;
  final int historyWindowDays;
  final int historyMessageCap;
  final bool autoImportEnabled;
  final bool autoCreateEnabled;
  final int autoImportIntervalMinutes;
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
    this.smsDisclosureRevision,
    required this.historySmsEnabled,
    required this.historyWindowDays,
    required this.historyMessageCap,
    required this.autoImportEnabled,
    required this.autoCreateEnabled,
    required this.autoImportIntervalMinutes,
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
    if (!nullToAbsent || smsDisclosureRevision != null) {
      map['sms_disclosure_revision'] = Variable<int>(smsDisclosureRevision);
    }
    map['history_sms_enabled'] = Variable<bool>(historySmsEnabled);
    map['history_window_days'] = Variable<int>(historyWindowDays);
    map['history_message_cap'] = Variable<int>(historyMessageCap);
    map['auto_import_enabled'] = Variable<bool>(autoImportEnabled);
    map['auto_create_enabled'] = Variable<bool>(autoCreateEnabled);
    map['auto_import_interval_minutes'] = Variable<int>(
      autoImportIntervalMinutes,
    );
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
      smsDisclosureRevision: smsDisclosureRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(smsDisclosureRevision),
      historySmsEnabled: Value(historySmsEnabled),
      historyWindowDays: Value(historyWindowDays),
      historyMessageCap: Value(historyMessageCap),
      autoImportEnabled: Value(autoImportEnabled),
      autoCreateEnabled: Value(autoCreateEnabled),
      autoImportIntervalMinutes: Value(autoImportIntervalMinutes),
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
      smsDisclosureRevision: serializer.fromJson<int?>(
        json['smsDisclosureRevision'],
      ),
      historySmsEnabled: serializer.fromJson<bool>(json['historySmsEnabled']),
      historyWindowDays: serializer.fromJson<int>(json['historyWindowDays']),
      historyMessageCap: serializer.fromJson<int>(json['historyMessageCap']),
      autoImportEnabled: serializer.fromJson<bool>(json['autoImportEnabled']),
      autoCreateEnabled: serializer.fromJson<bool>(json['autoCreateEnabled']),
      autoImportIntervalMinutes: serializer.fromJson<int>(
        json['autoImportIntervalMinutes'],
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
      'smsDisclosureRevision': serializer.toJson<int?>(smsDisclosureRevision),
      'historySmsEnabled': serializer.toJson<bool>(historySmsEnabled),
      'historyWindowDays': serializer.toJson<int>(historyWindowDays),
      'historyMessageCap': serializer.toJson<int>(historyMessageCap),
      'autoImportEnabled': serializer.toJson<bool>(autoImportEnabled),
      'autoCreateEnabled': serializer.toJson<bool>(autoCreateEnabled),
      'autoImportIntervalMinutes': serializer.toJson<int>(
        autoImportIntervalMinutes,
      ),
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
    Value<int?> smsDisclosureRevision = const Value.absent(),
    bool? historySmsEnabled,
    int? historyWindowDays,
    int? historyMessageCap,
    bool? autoImportEnabled,
    bool? autoCreateEnabled,
    int? autoImportIntervalMinutes,
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
    smsDisclosureRevision: smsDisclosureRevision.present
        ? smsDisclosureRevision.value
        : this.smsDisclosureRevision,
    historySmsEnabled: historySmsEnabled ?? this.historySmsEnabled,
    historyWindowDays: historyWindowDays ?? this.historyWindowDays,
    historyMessageCap: historyMessageCap ?? this.historyMessageCap,
    autoImportEnabled: autoImportEnabled ?? this.autoImportEnabled,
    autoCreateEnabled: autoCreateEnabled ?? this.autoCreateEnabled,
    autoImportIntervalMinutes:
        autoImportIntervalMinutes ?? this.autoImportIntervalMinutes,
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
      smsDisclosureRevision: data.smsDisclosureRevision.present
          ? data.smsDisclosureRevision.value
          : this.smsDisclosureRevision,
      historySmsEnabled: data.historySmsEnabled.present
          ? data.historySmsEnabled.value
          : this.historySmsEnabled,
      historyWindowDays: data.historyWindowDays.present
          ? data.historyWindowDays.value
          : this.historyWindowDays,
      historyMessageCap: data.historyMessageCap.present
          ? data.historyMessageCap.value
          : this.historyMessageCap,
      autoImportEnabled: data.autoImportEnabled.present
          ? data.autoImportEnabled.value
          : this.autoImportEnabled,
      autoCreateEnabled: data.autoCreateEnabled.present
          ? data.autoCreateEnabled.value
          : this.autoCreateEnabled,
      autoImportIntervalMinutes: data.autoImportIntervalMinutes.present
          ? data.autoImportIntervalMinutes.value
          : this.autoImportIntervalMinutes,
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
          ..write('activityRetentionDays: $activityRetentionDays, ')
          ..write('smsDisclosureRevision: $smsDisclosureRevision, ')
          ..write('historySmsEnabled: $historySmsEnabled, ')
          ..write('historyWindowDays: $historyWindowDays, ')
          ..write('historyMessageCap: $historyMessageCap, ')
          ..write('autoImportEnabled: $autoImportEnabled, ')
          ..write('autoCreateEnabled: $autoCreateEnabled, ')
          ..write('autoImportIntervalMinutes: $autoImportIntervalMinutes')
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
    smsDisclosureRevision,
    historySmsEnabled,
    historyWindowDays,
    historyMessageCap,
    autoImportEnabled,
    autoCreateEnabled,
    autoImportIntervalMinutes,
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
          other.activityRetentionDays == this.activityRetentionDays &&
          other.smsDisclosureRevision == this.smsDisclosureRevision &&
          other.historySmsEnabled == this.historySmsEnabled &&
          other.historyWindowDays == this.historyWindowDays &&
          other.historyMessageCap == this.historyMessageCap &&
          other.autoImportEnabled == this.autoImportEnabled &&
          other.autoCreateEnabled == this.autoCreateEnabled &&
          other.autoImportIntervalMinutes == this.autoImportIntervalMinutes);
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
  final Value<int?> smsDisclosureRevision;
  final Value<bool> historySmsEnabled;
  final Value<int> historyWindowDays;
  final Value<int> historyMessageCap;
  final Value<bool> autoImportEnabled;
  final Value<bool> autoCreateEnabled;
  final Value<int> autoImportIntervalMinutes;
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
    this.smsDisclosureRevision = const Value.absent(),
    this.historySmsEnabled = const Value.absent(),
    this.historyWindowDays = const Value.absent(),
    this.historyMessageCap = const Value.absent(),
    this.autoImportEnabled = const Value.absent(),
    this.autoCreateEnabled = const Value.absent(),
    this.autoImportIntervalMinutes = const Value.absent(),
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
    this.smsDisclosureRevision = const Value.absent(),
    this.historySmsEnabled = const Value.absent(),
    this.historyWindowDays = const Value.absent(),
    this.historyMessageCap = const Value.absent(),
    this.autoImportEnabled = const Value.absent(),
    this.autoCreateEnabled = const Value.absent(),
    this.autoImportIntervalMinutes = const Value.absent(),
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
    Expression<int>? smsDisclosureRevision,
    Expression<bool>? historySmsEnabled,
    Expression<int>? historyWindowDays,
    Expression<int>? historyMessageCap,
    Expression<bool>? autoImportEnabled,
    Expression<bool>? autoCreateEnabled,
    Expression<int>? autoImportIntervalMinutes,
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
      if (smsDisclosureRevision != null)
        'sms_disclosure_revision': smsDisclosureRevision,
      if (historySmsEnabled != null) 'history_sms_enabled': historySmsEnabled,
      if (historyWindowDays != null) 'history_window_days': historyWindowDays,
      if (historyMessageCap != null) 'history_message_cap': historyMessageCap,
      if (autoImportEnabled != null) 'auto_import_enabled': autoImportEnabled,
      if (autoCreateEnabled != null) 'auto_create_enabled': autoCreateEnabled,
      if (autoImportIntervalMinutes != null)
        'auto_import_interval_minutes': autoImportIntervalMinutes,
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
    Value<int?>? smsDisclosureRevision,
    Value<bool>? historySmsEnabled,
    Value<int>? historyWindowDays,
    Value<int>? historyMessageCap,
    Value<bool>? autoImportEnabled,
    Value<bool>? autoCreateEnabled,
    Value<int>? autoImportIntervalMinutes,
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
      smsDisclosureRevision:
          smsDisclosureRevision ?? this.smsDisclosureRevision,
      historySmsEnabled: historySmsEnabled ?? this.historySmsEnabled,
      historyWindowDays: historyWindowDays ?? this.historyWindowDays,
      historyMessageCap: historyMessageCap ?? this.historyMessageCap,
      autoImportEnabled: autoImportEnabled ?? this.autoImportEnabled,
      autoCreateEnabled: autoCreateEnabled ?? this.autoCreateEnabled,
      autoImportIntervalMinutes:
          autoImportIntervalMinutes ?? this.autoImportIntervalMinutes,
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
    if (smsDisclosureRevision.present) {
      map['sms_disclosure_revision'] = Variable<int>(
        smsDisclosureRevision.value,
      );
    }
    if (historySmsEnabled.present) {
      map['history_sms_enabled'] = Variable<bool>(historySmsEnabled.value);
    }
    if (historyWindowDays.present) {
      map['history_window_days'] = Variable<int>(historyWindowDays.value);
    }
    if (historyMessageCap.present) {
      map['history_message_cap'] = Variable<int>(historyMessageCap.value);
    }
    if (autoImportEnabled.present) {
      map['auto_import_enabled'] = Variable<bool>(autoImportEnabled.value);
    }
    if (autoCreateEnabled.present) {
      map['auto_create_enabled'] = Variable<bool>(autoCreateEnabled.value);
    }
    if (autoImportIntervalMinutes.present) {
      map['auto_import_interval_minutes'] = Variable<int>(
        autoImportIntervalMinutes.value,
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
          ..write('activityRetentionDays: $activityRetentionDays, ')
          ..write('smsDisclosureRevision: $smsDisclosureRevision, ')
          ..write('historySmsEnabled: $historySmsEnabled, ')
          ..write('historyWindowDays: $historyWindowDays, ')
          ..write('historyMessageCap: $historyMessageCap, ')
          ..write('autoImportEnabled: $autoImportEnabled, ')
          ..write('autoCreateEnabled: $autoCreateEnabled, ')
          ..write('autoImportIntervalMinutes: $autoImportIntervalMinutes')
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
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    priority,
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
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
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
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
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
  final int priority;
  final String? parserVersion;
  final String? parserChecksum;
  const SenderRule({
    required this.id,
    required this.senderHash,
    required this.parserFamily,
    required this.createdAtEpochMs,
    required this.priority,
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
    map['priority'] = Variable<int>(priority);
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
      priority: Value(priority),
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
      priority: serializer.fromJson<int>(json['priority']),
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
      'priority': serializer.toJson<int>(priority),
      'parserVersion': serializer.toJson<String?>(parserVersion),
      'parserChecksum': serializer.toJson<String?>(parserChecksum),
    };
  }

  SenderRule copyWith({
    int? id,
    String? senderHash,
    String? parserFamily,
    int? createdAtEpochMs,
    int? priority,
    Value<String?> parserVersion = const Value.absent(),
    Value<String?> parserChecksum = const Value.absent(),
  }) => SenderRule(
    id: id ?? this.id,
    senderHash: senderHash ?? this.senderHash,
    parserFamily: parserFamily ?? this.parserFamily,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    priority: priority ?? this.priority,
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
      priority: data.priority.present ? data.priority.value : this.priority,
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
          ..write('priority: $priority, ')
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
    priority,
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
          other.priority == this.priority &&
          other.parserVersion == this.parserVersion &&
          other.parserChecksum == this.parserChecksum);
}

class SenderRulesCompanion extends UpdateCompanion<SenderRule> {
  final Value<int> id;
  final Value<String> senderHash;
  final Value<String> parserFamily;
  final Value<int> createdAtEpochMs;
  final Value<int> priority;
  final Value<String?> parserVersion;
  final Value<String?> parserChecksum;
  const SenderRulesCompanion({
    this.id = const Value.absent(),
    this.senderHash = const Value.absent(),
    this.parserFamily = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.priority = const Value.absent(),
    this.parserVersion = const Value.absent(),
    this.parserChecksum = const Value.absent(),
  });
  SenderRulesCompanion.insert({
    this.id = const Value.absent(),
    required String senderHash,
    required String parserFamily,
    required int createdAtEpochMs,
    this.priority = const Value.absent(),
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
    Expression<int>? priority,
    Expression<String>? parserVersion,
    Expression<String>? parserChecksum,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderHash != null) 'sender_hash': senderHash,
      if (parserFamily != null) 'parser_family': parserFamily,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (priority != null) 'priority': priority,
      if (parserVersion != null) 'parser_version': parserVersion,
      if (parserChecksum != null) 'parser_checksum': parserChecksum,
    });
  }

  SenderRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? senderHash,
    Value<String>? parserFamily,
    Value<int>? createdAtEpochMs,
    Value<int>? priority,
    Value<String?>? parserVersion,
    Value<String?>? parserChecksum,
  }) {
    return SenderRulesCompanion(
      id: id ?? this.id,
      senderHash: senderHash ?? this.senderHash,
      parserFamily: parserFamily ?? this.parserFamily,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      priority: priority ?? this.priority,
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
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
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
          ..write('priority: $priority, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('parserChecksum: $parserChecksum')
          ..write(')'))
        .toString();
  }
}

class $TrackedSendersTable extends TrackedSenders
    with TableInfo<$TrackedSendersTable, TrackedSenderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedSendersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _senderKeyMeta = const VerificationMeta(
    'senderKey',
  );
  @override
  late final GeneratedColumn<String> senderKey = GeneratedColumn<String>(
    'sender_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderDisplayMeta = const VerificationMeta(
    'senderDisplay',
  );
  @override
  late final GeneratedColumn<String> senderDisplay = GeneratedColumn<String>(
    'sender_display',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _addedAtEpochMsMeta = const VerificationMeta(
    'addedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> addedAtEpochMs = GeneratedColumn<int>(
    'added_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    senderKey,
    senderDisplay,
    enabled,
    addedAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_senders';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackedSenderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sender_key')) {
      context.handle(
        _senderKeyMeta,
        senderKey.isAcceptableOrUnknown(data['sender_key']!, _senderKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_senderKeyMeta);
    }
    if (data.containsKey('sender_display')) {
      context.handle(
        _senderDisplayMeta,
        senderDisplay.isAcceptableOrUnknown(
          data['sender_display']!,
          _senderDisplayMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('added_at_epoch_ms')) {
      context.handle(
        _addedAtEpochMsMeta,
        addedAtEpochMs.isAcceptableOrUnknown(
          data['added_at_epoch_ms']!,
          _addedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addedAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {senderKey};
  @override
  TrackedSenderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedSenderRow(
      senderKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_key'],
      )!,
      senderDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_display'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      addedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at_epoch_ms'],
      )!,
    );
  }

  @override
  $TrackedSendersTable createAlias(String alias) {
    return $TrackedSendersTable(attachedDatabase, alias);
  }
}

class TrackedSenderRow extends DataClass
    implements Insertable<TrackedSenderRow> {
  final String senderKey;
  final String? senderDisplay;
  final bool enabled;
  final int addedAtEpochMs;
  const TrackedSenderRow({
    required this.senderKey,
    this.senderDisplay,
    required this.enabled,
    required this.addedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sender_key'] = Variable<String>(senderKey);
    if (!nullToAbsent || senderDisplay != null) {
      map['sender_display'] = Variable<String>(senderDisplay);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['added_at_epoch_ms'] = Variable<int>(addedAtEpochMs);
    return map;
  }

  TrackedSendersCompanion toCompanion(bool nullToAbsent) {
    return TrackedSendersCompanion(
      senderKey: Value(senderKey),
      senderDisplay: senderDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(senderDisplay),
      enabled: Value(enabled),
      addedAtEpochMs: Value(addedAtEpochMs),
    );
  }

  factory TrackedSenderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedSenderRow(
      senderKey: serializer.fromJson<String>(json['senderKey']),
      senderDisplay: serializer.fromJson<String?>(json['senderDisplay']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      addedAtEpochMs: serializer.fromJson<int>(json['addedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'senderKey': serializer.toJson<String>(senderKey),
      'senderDisplay': serializer.toJson<String?>(senderDisplay),
      'enabled': serializer.toJson<bool>(enabled),
      'addedAtEpochMs': serializer.toJson<int>(addedAtEpochMs),
    };
  }

  TrackedSenderRow copyWith({
    String? senderKey,
    Value<String?> senderDisplay = const Value.absent(),
    bool? enabled,
    int? addedAtEpochMs,
  }) => TrackedSenderRow(
    senderKey: senderKey ?? this.senderKey,
    senderDisplay: senderDisplay.present
        ? senderDisplay.value
        : this.senderDisplay,
    enabled: enabled ?? this.enabled,
    addedAtEpochMs: addedAtEpochMs ?? this.addedAtEpochMs,
  );
  TrackedSenderRow copyWithCompanion(TrackedSendersCompanion data) {
    return TrackedSenderRow(
      senderKey: data.senderKey.present ? data.senderKey.value : this.senderKey,
      senderDisplay: data.senderDisplay.present
          ? data.senderDisplay.value
          : this.senderDisplay,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      addedAtEpochMs: data.addedAtEpochMs.present
          ? data.addedAtEpochMs.value
          : this.addedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedSenderRow(')
          ..write('senderKey: $senderKey, ')
          ..write('senderDisplay: $senderDisplay, ')
          ..write('enabled: $enabled, ')
          ..write('addedAtEpochMs: $addedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(senderKey, senderDisplay, enabled, addedAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedSenderRow &&
          other.senderKey == this.senderKey &&
          other.senderDisplay == this.senderDisplay &&
          other.enabled == this.enabled &&
          other.addedAtEpochMs == this.addedAtEpochMs);
}

class TrackedSendersCompanion extends UpdateCompanion<TrackedSenderRow> {
  final Value<String> senderKey;
  final Value<String?> senderDisplay;
  final Value<bool> enabled;
  final Value<int> addedAtEpochMs;
  final Value<int> rowid;
  const TrackedSendersCompanion({
    this.senderKey = const Value.absent(),
    this.senderDisplay = const Value.absent(),
    this.enabled = const Value.absent(),
    this.addedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackedSendersCompanion.insert({
    required String senderKey,
    this.senderDisplay = const Value.absent(),
    this.enabled = const Value.absent(),
    required int addedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : senderKey = Value(senderKey),
       addedAtEpochMs = Value(addedAtEpochMs);
  static Insertable<TrackedSenderRow> custom({
    Expression<String>? senderKey,
    Expression<String>? senderDisplay,
    Expression<bool>? enabled,
    Expression<int>? addedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (senderKey != null) 'sender_key': senderKey,
      if (senderDisplay != null) 'sender_display': senderDisplay,
      if (enabled != null) 'enabled': enabled,
      if (addedAtEpochMs != null) 'added_at_epoch_ms': addedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackedSendersCompanion copyWith({
    Value<String>? senderKey,
    Value<String?>? senderDisplay,
    Value<bool>? enabled,
    Value<int>? addedAtEpochMs,
    Value<int>? rowid,
  }) {
    return TrackedSendersCompanion(
      senderKey: senderKey ?? this.senderKey,
      senderDisplay: senderDisplay ?? this.senderDisplay,
      enabled: enabled ?? this.enabled,
      addedAtEpochMs: addedAtEpochMs ?? this.addedAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (senderKey.present) {
      map['sender_key'] = Variable<String>(senderKey.value);
    }
    if (senderDisplay.present) {
      map['sender_display'] = Variable<String>(senderDisplay.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (addedAtEpochMs.present) {
      map['added_at_epoch_ms'] = Variable<int>(addedAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedSendersCompanion(')
          ..write('senderKey: $senderKey, ')
          ..write('senderDisplay: $senderDisplay, ')
          ..write('enabled: $enabled, ')
          ..write('addedAtEpochMs: $addedAtEpochMs, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _senderKeyMeta = const VerificationMeta(
    'senderKey',
  );
  @override
  late final GeneratedColumn<String> senderKey = GeneratedColumn<String>(
    'sender_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderDisplayMeta = const VerificationMeta(
    'senderDisplay',
  );
  @override
  late final GeneratedColumn<String> senderDisplay = GeneratedColumn<String>(
    'sender_display',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  late final GeneratedColumnWithTypeConverter<SmsEventStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SmsEventStatus>($SmsEventsTable.$converterstatus);
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
  static const VerificationMeta _providerRowIdMeta = const VerificationMeta(
    'providerRowId',
  );
  @override
  late final GeneratedColumn<int> providerRowId = GeneratedColumn<int>(
    'provider_row_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captureCanonicalizationVersionMeta =
      const VerificationMeta('captureCanonicalizationVersion');
  @override
  late final GeneratedColumn<int> captureCanonicalizationVersion =
      GeneratedColumn<int>(
        'capture_canonicalization_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(2),
      );
  static const VerificationMeta _redactionVersionMeta = const VerificationMeta(
    'redactionVersion',
  );
  @override
  late final GeneratedColumn<int> redactionVersion = GeneratedColumn<int>(
    'redaction_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RawPurgeState, String>
  rawPurgeState = GeneratedColumn<String>(
    'raw_purge_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  ).withConverter<RawPurgeState>($SmsEventsTable.$converterrawPurgeState);
  static const VerificationMeta _contentSha256Meta = const VerificationMeta(
    'contentSha256',
  );
  @override
  late final GeneratedColumn<String> contentSha256 = GeneratedColumn<String>(
    'content_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceKey,
    senderKey,
    senderDisplay,
    encryptedBody,
    redactedBody,
    ingestionSource,
    receivedAtEpochMs,
    expiresAtEpochMs,
    status,
    privacyEpoch,
    providerRowId,
    captureCanonicalizationVersion,
    redactionVersion,
    rawPurgeState,
    contentSha256,
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
    if (data.containsKey('sender_key')) {
      context.handle(
        _senderKeyMeta,
        senderKey.isAcceptableOrUnknown(data['sender_key']!, _senderKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_senderKeyMeta);
    }
    if (data.containsKey('sender_display')) {
      context.handle(
        _senderDisplayMeta,
        senderDisplay.isAcceptableOrUnknown(
          data['sender_display']!,
          _senderDisplayMeta,
        ),
      );
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
    if (data.containsKey('provider_row_id')) {
      context.handle(
        _providerRowIdMeta,
        providerRowId.isAcceptableOrUnknown(
          data['provider_row_id']!,
          _providerRowIdMeta,
        ),
      );
    }
    if (data.containsKey('capture_canonicalization_version')) {
      context.handle(
        _captureCanonicalizationVersionMeta,
        captureCanonicalizationVersion.isAcceptableOrUnknown(
          data['capture_canonicalization_version']!,
          _captureCanonicalizationVersionMeta,
        ),
      );
    }
    if (data.containsKey('redaction_version')) {
      context.handle(
        _redactionVersionMeta,
        redactionVersion.isAcceptableOrUnknown(
          data['redaction_version']!,
          _redactionVersionMeta,
        ),
      );
    }
    if (data.containsKey('content_sha256')) {
      context.handle(
        _contentSha256Meta,
        contentSha256.isAcceptableOrUnknown(
          data['content_sha256']!,
          _contentSha256Meta,
        ),
      );
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
      senderKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_key'],
      )!,
      senderDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_display'],
      ),
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
      status: $SmsEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      privacyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch'],
      )!,
      providerRowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provider_row_id'],
      ),
      captureCanonicalizationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capture_canonicalization_version'],
      )!,
      redactionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redaction_version'],
      )!,
      rawPurgeState: $SmsEventsTable.$converterrawPurgeState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}raw_purge_state'],
        )!,
      ),
      contentSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_sha256'],
      ),
    );
  }

  @override
  $SmsEventsTable createAlias(String alias) {
    return $SmsEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SmsEventStatus, String, String> $converterstatus =
      const EnumNameConverter<SmsEventStatus>(SmsEventStatus.values);
  static JsonTypeConverter2<RawPurgeState, String, String>
  $converterrawPurgeState = const EnumNameConverter<RawPurgeState>(
    RawPurgeState.values,
  );
}

class SmsEvent extends DataClass implements Insertable<SmsEvent> {
  final int id;
  final String sourceKey;

  /// Normalized matching key: trimmed, uppercased, NFC. Not a hash — renamed
  /// from `senderHash`, which never held a hash (M4.14 V6).
  final String senderKey;

  /// Sender exactly as the transport reported it. Display only — never used
  /// for matching (plan/03:46).
  final String? senderDisplay;

  /// Full normalized original message body — the primary review display
  /// source (M4.16). Plaintext inside the SQLCipher-encrypted database;
  /// the column name is historical and predates the at-rest encryption
  /// design. Nullable: filtered OTP/unrelated rows store nothing, and the
  /// retention sweep clears it when raw-copy consent is disabled.
  final String? encryptedBody;

  /// Masked preview (amounts/dates/phone numbers redacted, ≤300 chars).
  /// Fallback display source when [encryptedBody] is absent, and the
  /// source for plan-mandated redacted surfaces (notifications).
  final String? redactedBody;
  final String ingestionSource;
  final int receivedAtEpochMs;
  final int? expiresAtEpochMs;
  final SmsEventStatus status;
  final int privacyEpoch;
  final int? providerRowId;
  final int captureCanonicalizationVersion;
  final int redactionVersion;
  final RawPurgeState rawPurgeState;
  final String? contentSha256;
  const SmsEvent({
    required this.id,
    required this.sourceKey,
    required this.senderKey,
    this.senderDisplay,
    this.encryptedBody,
    this.redactedBody,
    required this.ingestionSource,
    required this.receivedAtEpochMs,
    this.expiresAtEpochMs,
    required this.status,
    required this.privacyEpoch,
    this.providerRowId,
    required this.captureCanonicalizationVersion,
    required this.redactionVersion,
    required this.rawPurgeState,
    this.contentSha256,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_key'] = Variable<String>(sourceKey);
    map['sender_key'] = Variable<String>(senderKey);
    if (!nullToAbsent || senderDisplay != null) {
      map['sender_display'] = Variable<String>(senderDisplay);
    }
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
    {
      map['status'] = Variable<String>(
        $SmsEventsTable.$converterstatus.toSql(status),
      );
    }
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    if (!nullToAbsent || providerRowId != null) {
      map['provider_row_id'] = Variable<int>(providerRowId);
    }
    map['capture_canonicalization_version'] = Variable<int>(
      captureCanonicalizationVersion,
    );
    map['redaction_version'] = Variable<int>(redactionVersion);
    {
      map['raw_purge_state'] = Variable<String>(
        $SmsEventsTable.$converterrawPurgeState.toSql(rawPurgeState),
      );
    }
    if (!nullToAbsent || contentSha256 != null) {
      map['content_sha256'] = Variable<String>(contentSha256);
    }
    return map;
  }

  SmsEventsCompanion toCompanion(bool nullToAbsent) {
    return SmsEventsCompanion(
      id: Value(id),
      sourceKey: Value(sourceKey),
      senderKey: Value(senderKey),
      senderDisplay: senderDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(senderDisplay),
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
      providerRowId: providerRowId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerRowId),
      captureCanonicalizationVersion: Value(captureCanonicalizationVersion),
      redactionVersion: Value(redactionVersion),
      rawPurgeState: Value(rawPurgeState),
      contentSha256: contentSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(contentSha256),
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
      senderKey: serializer.fromJson<String>(json['senderKey']),
      senderDisplay: serializer.fromJson<String?>(json['senderDisplay']),
      encryptedBody: serializer.fromJson<String?>(json['encryptedBody']),
      redactedBody: serializer.fromJson<String?>(json['redactedBody']),
      ingestionSource: serializer.fromJson<String>(json['ingestionSource']),
      receivedAtEpochMs: serializer.fromJson<int>(json['receivedAtEpochMs']),
      expiresAtEpochMs: serializer.fromJson<int?>(json['expiresAtEpochMs']),
      status: $SmsEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      privacyEpoch: serializer.fromJson<int>(json['privacyEpoch']),
      providerRowId: serializer.fromJson<int?>(json['providerRowId']),
      captureCanonicalizationVersion: serializer.fromJson<int>(
        json['captureCanonicalizationVersion'],
      ),
      redactionVersion: serializer.fromJson<int>(json['redactionVersion']),
      rawPurgeState: $SmsEventsTable.$converterrawPurgeState.fromJson(
        serializer.fromJson<String>(json['rawPurgeState']),
      ),
      contentSha256: serializer.fromJson<String?>(json['contentSha256']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'senderKey': serializer.toJson<String>(senderKey),
      'senderDisplay': serializer.toJson<String?>(senderDisplay),
      'encryptedBody': serializer.toJson<String?>(encryptedBody),
      'redactedBody': serializer.toJson<String?>(redactedBody),
      'ingestionSource': serializer.toJson<String>(ingestionSource),
      'receivedAtEpochMs': serializer.toJson<int>(receivedAtEpochMs),
      'expiresAtEpochMs': serializer.toJson<int?>(expiresAtEpochMs),
      'status': serializer.toJson<String>(
        $SmsEventsTable.$converterstatus.toJson(status),
      ),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
      'providerRowId': serializer.toJson<int?>(providerRowId),
      'captureCanonicalizationVersion': serializer.toJson<int>(
        captureCanonicalizationVersion,
      ),
      'redactionVersion': serializer.toJson<int>(redactionVersion),
      'rawPurgeState': serializer.toJson<String>(
        $SmsEventsTable.$converterrawPurgeState.toJson(rawPurgeState),
      ),
      'contentSha256': serializer.toJson<String?>(contentSha256),
    };
  }

  SmsEvent copyWith({
    int? id,
    String? sourceKey,
    String? senderKey,
    Value<String?> senderDisplay = const Value.absent(),
    Value<String?> encryptedBody = const Value.absent(),
    Value<String?> redactedBody = const Value.absent(),
    String? ingestionSource,
    int? receivedAtEpochMs,
    Value<int?> expiresAtEpochMs = const Value.absent(),
    SmsEventStatus? status,
    int? privacyEpoch,
    Value<int?> providerRowId = const Value.absent(),
    int? captureCanonicalizationVersion,
    int? redactionVersion,
    RawPurgeState? rawPurgeState,
    Value<String?> contentSha256 = const Value.absent(),
  }) => SmsEvent(
    id: id ?? this.id,
    sourceKey: sourceKey ?? this.sourceKey,
    senderKey: senderKey ?? this.senderKey,
    senderDisplay: senderDisplay.present
        ? senderDisplay.value
        : this.senderDisplay,
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
    providerRowId: providerRowId.present
        ? providerRowId.value
        : this.providerRowId,
    captureCanonicalizationVersion:
        captureCanonicalizationVersion ?? this.captureCanonicalizationVersion,
    redactionVersion: redactionVersion ?? this.redactionVersion,
    rawPurgeState: rawPurgeState ?? this.rawPurgeState,
    contentSha256: contentSha256.present
        ? contentSha256.value
        : this.contentSha256,
  );
  SmsEvent copyWithCompanion(SmsEventsCompanion data) {
    return SmsEvent(
      id: data.id.present ? data.id.value : this.id,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      senderKey: data.senderKey.present ? data.senderKey.value : this.senderKey,
      senderDisplay: data.senderDisplay.present
          ? data.senderDisplay.value
          : this.senderDisplay,
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
      providerRowId: data.providerRowId.present
          ? data.providerRowId.value
          : this.providerRowId,
      captureCanonicalizationVersion:
          data.captureCanonicalizationVersion.present
          ? data.captureCanonicalizationVersion.value
          : this.captureCanonicalizationVersion,
      redactionVersion: data.redactionVersion.present
          ? data.redactionVersion.value
          : this.redactionVersion,
      rawPurgeState: data.rawPurgeState.present
          ? data.rawPurgeState.value
          : this.rawPurgeState,
      contentSha256: data.contentSha256.present
          ? data.contentSha256.value
          : this.contentSha256,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsEvent(')
          ..write('id: $id, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('senderKey: $senderKey, ')
          ..write('senderDisplay: $senderDisplay, ')
          ..write('encryptedBody: $encryptedBody, ')
          ..write('redactedBody: $redactedBody, ')
          ..write('ingestionSource: $ingestionSource, ')
          ..write('receivedAtEpochMs: $receivedAtEpochMs, ')
          ..write('expiresAtEpochMs: $expiresAtEpochMs, ')
          ..write('status: $status, ')
          ..write('privacyEpoch: $privacyEpoch, ')
          ..write('providerRowId: $providerRowId, ')
          ..write(
            'captureCanonicalizationVersion: $captureCanonicalizationVersion, ',
          )
          ..write('redactionVersion: $redactionVersion, ')
          ..write('rawPurgeState: $rawPurgeState, ')
          ..write('contentSha256: $contentSha256')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceKey,
    senderKey,
    senderDisplay,
    encryptedBody,
    redactedBody,
    ingestionSource,
    receivedAtEpochMs,
    expiresAtEpochMs,
    status,
    privacyEpoch,
    providerRowId,
    captureCanonicalizationVersion,
    redactionVersion,
    rawPurgeState,
    contentSha256,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsEvent &&
          other.id == this.id &&
          other.sourceKey == this.sourceKey &&
          other.senderKey == this.senderKey &&
          other.senderDisplay == this.senderDisplay &&
          other.encryptedBody == this.encryptedBody &&
          other.redactedBody == this.redactedBody &&
          other.ingestionSource == this.ingestionSource &&
          other.receivedAtEpochMs == this.receivedAtEpochMs &&
          other.expiresAtEpochMs == this.expiresAtEpochMs &&
          other.status == this.status &&
          other.privacyEpoch == this.privacyEpoch &&
          other.providerRowId == this.providerRowId &&
          other.captureCanonicalizationVersion ==
              this.captureCanonicalizationVersion &&
          other.redactionVersion == this.redactionVersion &&
          other.rawPurgeState == this.rawPurgeState &&
          other.contentSha256 == this.contentSha256);
}

class SmsEventsCompanion extends UpdateCompanion<SmsEvent> {
  final Value<int> id;
  final Value<String> sourceKey;
  final Value<String> senderKey;
  final Value<String?> senderDisplay;
  final Value<String?> encryptedBody;
  final Value<String?> redactedBody;
  final Value<String> ingestionSource;
  final Value<int> receivedAtEpochMs;
  final Value<int?> expiresAtEpochMs;
  final Value<SmsEventStatus> status;
  final Value<int> privacyEpoch;
  final Value<int?> providerRowId;
  final Value<int> captureCanonicalizationVersion;
  final Value<int> redactionVersion;
  final Value<RawPurgeState> rawPurgeState;
  final Value<String?> contentSha256;
  const SmsEventsCompanion({
    this.id = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.senderKey = const Value.absent(),
    this.senderDisplay = const Value.absent(),
    this.encryptedBody = const Value.absent(),
    this.redactedBody = const Value.absent(),
    this.ingestionSource = const Value.absent(),
    this.receivedAtEpochMs = const Value.absent(),
    this.expiresAtEpochMs = const Value.absent(),
    this.status = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
    this.providerRowId = const Value.absent(),
    this.captureCanonicalizationVersion = const Value.absent(),
    this.redactionVersion = const Value.absent(),
    this.rawPurgeState = const Value.absent(),
    this.contentSha256 = const Value.absent(),
  });
  SmsEventsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceKey,
    required String senderKey,
    this.senderDisplay = const Value.absent(),
    this.encryptedBody = const Value.absent(),
    this.redactedBody = const Value.absent(),
    required String ingestionSource,
    required int receivedAtEpochMs,
    this.expiresAtEpochMs = const Value.absent(),
    required SmsEventStatus status,
    required int privacyEpoch,
    this.providerRowId = const Value.absent(),
    this.captureCanonicalizationVersion = const Value.absent(),
    this.redactionVersion = const Value.absent(),
    this.rawPurgeState = const Value.absent(),
    this.contentSha256 = const Value.absent(),
  }) : sourceKey = Value(sourceKey),
       senderKey = Value(senderKey),
       ingestionSource = Value(ingestionSource),
       receivedAtEpochMs = Value(receivedAtEpochMs),
       status = Value(status),
       privacyEpoch = Value(privacyEpoch);
  static Insertable<SmsEvent> custom({
    Expression<int>? id,
    Expression<String>? sourceKey,
    Expression<String>? senderKey,
    Expression<String>? senderDisplay,
    Expression<String>? encryptedBody,
    Expression<String>? redactedBody,
    Expression<String>? ingestionSource,
    Expression<int>? receivedAtEpochMs,
    Expression<int>? expiresAtEpochMs,
    Expression<String>? status,
    Expression<int>? privacyEpoch,
    Expression<int>? providerRowId,
    Expression<int>? captureCanonicalizationVersion,
    Expression<int>? redactionVersion,
    Expression<String>? rawPurgeState,
    Expression<String>? contentSha256,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceKey != null) 'source_key': sourceKey,
      if (senderKey != null) 'sender_key': senderKey,
      if (senderDisplay != null) 'sender_display': senderDisplay,
      if (encryptedBody != null) 'encrypted_body': encryptedBody,
      if (redactedBody != null) 'redacted_body': redactedBody,
      if (ingestionSource != null) 'ingestion_source': ingestionSource,
      if (receivedAtEpochMs != null) 'received_at_epoch_ms': receivedAtEpochMs,
      if (expiresAtEpochMs != null) 'expires_at_epoch_ms': expiresAtEpochMs,
      if (status != null) 'status': status,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
      if (providerRowId != null) 'provider_row_id': providerRowId,
      if (captureCanonicalizationVersion != null)
        'capture_canonicalization_version': captureCanonicalizationVersion,
      if (redactionVersion != null) 'redaction_version': redactionVersion,
      if (rawPurgeState != null) 'raw_purge_state': rawPurgeState,
      if (contentSha256 != null) 'content_sha256': contentSha256,
    });
  }

  SmsEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceKey,
    Value<String>? senderKey,
    Value<String?>? senderDisplay,
    Value<String?>? encryptedBody,
    Value<String?>? redactedBody,
    Value<String>? ingestionSource,
    Value<int>? receivedAtEpochMs,
    Value<int?>? expiresAtEpochMs,
    Value<SmsEventStatus>? status,
    Value<int>? privacyEpoch,
    Value<int?>? providerRowId,
    Value<int>? captureCanonicalizationVersion,
    Value<int>? redactionVersion,
    Value<RawPurgeState>? rawPurgeState,
    Value<String?>? contentSha256,
  }) {
    return SmsEventsCompanion(
      id: id ?? this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      senderKey: senderKey ?? this.senderKey,
      senderDisplay: senderDisplay ?? this.senderDisplay,
      encryptedBody: encryptedBody ?? this.encryptedBody,
      redactedBody: redactedBody ?? this.redactedBody,
      ingestionSource: ingestionSource ?? this.ingestionSource,
      receivedAtEpochMs: receivedAtEpochMs ?? this.receivedAtEpochMs,
      expiresAtEpochMs: expiresAtEpochMs ?? this.expiresAtEpochMs,
      status: status ?? this.status,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
      providerRowId: providerRowId ?? this.providerRowId,
      captureCanonicalizationVersion:
          captureCanonicalizationVersion ?? this.captureCanonicalizationVersion,
      redactionVersion: redactionVersion ?? this.redactionVersion,
      rawPurgeState: rawPurgeState ?? this.rawPurgeState,
      contentSha256: contentSha256 ?? this.contentSha256,
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
    if (senderKey.present) {
      map['sender_key'] = Variable<String>(senderKey.value);
    }
    if (senderDisplay.present) {
      map['sender_display'] = Variable<String>(senderDisplay.value);
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
      map['status'] = Variable<String>(
        $SmsEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (privacyEpoch.present) {
      map['privacy_epoch'] = Variable<int>(privacyEpoch.value);
    }
    if (providerRowId.present) {
      map['provider_row_id'] = Variable<int>(providerRowId.value);
    }
    if (captureCanonicalizationVersion.present) {
      map['capture_canonicalization_version'] = Variable<int>(
        captureCanonicalizationVersion.value,
      );
    }
    if (redactionVersion.present) {
      map['redaction_version'] = Variable<int>(redactionVersion.value);
    }
    if (rawPurgeState.present) {
      map['raw_purge_state'] = Variable<String>(
        $SmsEventsTable.$converterrawPurgeState.toSql(rawPurgeState.value),
      );
    }
    if (contentSha256.present) {
      map['content_sha256'] = Variable<String>(contentSha256.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsEventsCompanion(')
          ..write('id: $id, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('senderKey: $senderKey, ')
          ..write('senderDisplay: $senderDisplay, ')
          ..write('encryptedBody: $encryptedBody, ')
          ..write('redactedBody: $redactedBody, ')
          ..write('ingestionSource: $ingestionSource, ')
          ..write('receivedAtEpochMs: $receivedAtEpochMs, ')
          ..write('expiresAtEpochMs: $expiresAtEpochMs, ')
          ..write('status: $status, ')
          ..write('privacyEpoch: $privacyEpoch, ')
          ..write('providerRowId: $providerRowId, ')
          ..write(
            'captureCanonicalizationVersion: $captureCanonicalizationVersion, ',
          )
          ..write('redactionVersion: $redactionVersion, ')
          ..write('rawPurgeState: $rawPurgeState, ')
          ..write('contentSha256: $contentSha256')
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
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
    'candidate_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  late final GeneratedColumnWithTypeConverter<TransactionKind?, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TransactionKind?>(
        $TransactionCandidatesTable.$converterkindn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionDirection?, String>
  direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TransactionDirection?>(
        $TransactionCandidatesTable.$converterdirectionn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<FinancialLifecycle?, String>
  lifecycle =
      GeneratedColumn<String>(
        'lifecycle',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<FinancialLifecycle?>(
        $TransactionCandidatesTable.$converterlifecyclen,
      );
  static const VerificationMeta _originalAmountMinorMeta =
      const VerificationMeta('originalAmountMinor');
  @override
  late final GeneratedColumn<int> originalAmountMinor = GeneratedColumn<int>(
    'original_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletAmountMinorMeta = const VerificationMeta(
    'walletAmountMinor',
  );
  @override
  late final GeneratedColumn<int> walletAmountMinor = GeneratedColumn<int>(
    'wallet_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionAtEpochMsMeta =
      const VerificationMeta('transactionAtEpochMs');
  @override
  late final GeneratedColumn<int> transactionAtEpochMs = GeneratedColumn<int>(
    'transaction_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateEvidenceMeta = const VerificationMeta(
    'dateEvidence',
  );
  @override
  late final GeneratedColumn<String> dateEvidence = GeneratedColumn<String>(
    'date_evidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counterpartyRedactedMeta =
      const VerificationMeta('counterpartyRedacted');
  @override
  late final GeneratedColumn<String> counterpartyRedacted =
      GeneratedColumn<String>(
        'counterparty_redacted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _instrumentSuffixHashMeta =
      const VerificationMeta('instrumentSuffixHash');
  @override
  late final GeneratedColumn<String> instrumentSuffixHash =
      GeneratedColumn<String>(
        'instrument_suffix_hash',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _availableBalanceMinorMeta =
      const VerificationMeta('availableBalanceMinor');
  @override
  late final GeneratedColumn<int> availableBalanceMinor = GeneratedColumn<int>(
    'available_balance_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceBasisPointsMeta =
      const VerificationMeta('confidenceBasisPoints');
  @override
  late final GeneratedColumn<int> confidenceBasisPoints = GeneratedColumn<int>(
    'confidence_basis_points',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parserRuleIdMeta = const VerificationMeta(
    'parserRuleId',
  );
  @override
  late final GeneratedColumn<String> parserRuleId = GeneratedColumn<String>(
    'parser_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parserRuleVersionMeta = const VerificationMeta(
    'parserRuleVersion',
  );
  @override
  late final GeneratedColumn<String> parserRuleVersion =
      GeneratedColumn<String>(
        'parser_rule_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rulePackIdMeta = const VerificationMeta(
    'rulePackId',
  );
  @override
  late final GeneratedColumn<String> rulePackId = GeneratedColumn<String>(
    'rule_pack_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rulePackVersionMeta = const VerificationMeta(
    'rulePackVersion',
  );
  @override
  late final GeneratedColumn<String> rulePackVersion = GeneratedColumn<String>(
    'rule_pack_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewReasonsMeta = const VerificationMeta(
    'reviewReasons',
  );
  @override
  late final GeneratedColumn<String> reviewReasons = GeneratedColumn<String>(
    'review_reasons',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionFingerprintMeta =
      const VerificationMeta('transactionFingerprint');
  @override
  late final GeneratedColumn<String> transactionFingerprint =
      GeneratedColumn<String>(
        'transaction_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    candidateId,
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
    kind,
    direction,
    lifecycle,
    originalAmountMinor,
    walletAmountMinor,
    transactionAtEpochMs,
    dateEvidence,
    counterpartyRedacted,
    instrumentSuffixHash,
    availableBalanceMinor,
    paymentType,
    confidenceBasisPoints,
    parserRuleId,
    parserRuleVersion,
    rulePackId,
    rulePackVersion,
    reviewReasons,
    transactionFingerprint,
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
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
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
    if (data.containsKey('original_amount_minor')) {
      context.handle(
        _originalAmountMinorMeta,
        originalAmountMinor.isAcceptableOrUnknown(
          data['original_amount_minor']!,
          _originalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('wallet_amount_minor')) {
      context.handle(
        _walletAmountMinorMeta,
        walletAmountMinor.isAcceptableOrUnknown(
          data['wallet_amount_minor']!,
          _walletAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('transaction_at_epoch_ms')) {
      context.handle(
        _transactionAtEpochMsMeta,
        transactionAtEpochMs.isAcceptableOrUnknown(
          data['transaction_at_epoch_ms']!,
          _transactionAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('date_evidence')) {
      context.handle(
        _dateEvidenceMeta,
        dateEvidence.isAcceptableOrUnknown(
          data['date_evidence']!,
          _dateEvidenceMeta,
        ),
      );
    }
    if (data.containsKey('counterparty_redacted')) {
      context.handle(
        _counterpartyRedactedMeta,
        counterpartyRedacted.isAcceptableOrUnknown(
          data['counterparty_redacted']!,
          _counterpartyRedactedMeta,
        ),
      );
    }
    if (data.containsKey('instrument_suffix_hash')) {
      context.handle(
        _instrumentSuffixHashMeta,
        instrumentSuffixHash.isAcceptableOrUnknown(
          data['instrument_suffix_hash']!,
          _instrumentSuffixHashMeta,
        ),
      );
    }
    if (data.containsKey('available_balance_minor')) {
      context.handle(
        _availableBalanceMinorMeta,
        availableBalanceMinor.isAcceptableOrUnknown(
          data['available_balance_minor']!,
          _availableBalanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    }
    if (data.containsKey('confidence_basis_points')) {
      context.handle(
        _confidenceBasisPointsMeta,
        confidenceBasisPoints.isAcceptableOrUnknown(
          data['confidence_basis_points']!,
          _confidenceBasisPointsMeta,
        ),
      );
    }
    if (data.containsKey('parser_rule_id')) {
      context.handle(
        _parserRuleIdMeta,
        parserRuleId.isAcceptableOrUnknown(
          data['parser_rule_id']!,
          _parserRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('parser_rule_version')) {
      context.handle(
        _parserRuleVersionMeta,
        parserRuleVersion.isAcceptableOrUnknown(
          data['parser_rule_version']!,
          _parserRuleVersionMeta,
        ),
      );
    }
    if (data.containsKey('rule_pack_id')) {
      context.handle(
        _rulePackIdMeta,
        rulePackId.isAcceptableOrUnknown(
          data['rule_pack_id']!,
          _rulePackIdMeta,
        ),
      );
    }
    if (data.containsKey('rule_pack_version')) {
      context.handle(
        _rulePackVersionMeta,
        rulePackVersion.isAcceptableOrUnknown(
          data['rule_pack_version']!,
          _rulePackVersionMeta,
        ),
      );
    }
    if (data.containsKey('review_reasons')) {
      context.handle(
        _reviewReasonsMeta,
        reviewReasons.isAcceptableOrUnknown(
          data['review_reasons']!,
          _reviewReasonsMeta,
        ),
      );
    }
    if (data.containsKey('transaction_fingerprint')) {
      context.handle(
        _transactionFingerprintMeta,
        transactionFingerprint.isAcceptableOrUnknown(
          data['transaction_fingerprint']!,
          _transactionFingerprintMeta,
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
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      ),
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
      kind: $TransactionCandidatesTable.$converterkindn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        ),
      ),
      direction: $TransactionCandidatesTable.$converterdirectionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        ),
      ),
      lifecycle: $TransactionCandidatesTable.$converterlifecyclen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}lifecycle'],
        ),
      ),
      originalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor'],
      ),
      walletAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_amount_minor'],
      ),
      transactionAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_at_epoch_ms'],
      ),
      dateEvidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_evidence'],
      ),
      counterpartyRedacted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_redacted'],
      ),
      instrumentSuffixHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_suffix_hash'],
      ),
      availableBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_balance_minor'],
      ),
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      ),
      confidenceBasisPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence_basis_points'],
      ),
      parserRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_rule_id'],
      ),
      parserRuleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_rule_version'],
      ),
      rulePackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_pack_id'],
      ),
      rulePackVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_pack_version'],
      ),
      reviewReasons: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_reasons'],
      ),
      transactionFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_fingerprint'],
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
  static JsonTypeConverter2<TransactionKind, String, String> $converterkind =
      const EnumNameConverter<TransactionKind>(TransactionKind.values);
  static JsonTypeConverter2<TransactionKind?, String?, String?>
  $converterkindn = JsonTypeConverter2.asNullable($converterkind);
  static JsonTypeConverter2<TransactionDirection, String, String>
  $converterdirection = const EnumNameConverter<TransactionDirection>(
    TransactionDirection.values,
  );
  static JsonTypeConverter2<TransactionDirection?, String?, String?>
  $converterdirectionn = JsonTypeConverter2.asNullable($converterdirection);
  static JsonTypeConverter2<FinancialLifecycle, String, String>
  $converterlifecycle = const EnumNameConverter<FinancialLifecycle>(
    FinancialLifecycle.values,
  );
  static JsonTypeConverter2<FinancialLifecycle?, String?, String?>
  $converterlifecyclen = JsonTypeConverter2.asNullable($converterlifecycle);
}

class TransactionCandidate extends DataClass
    implements Insertable<TransactionCandidate> {
  final int id;

  /// Stable text UUID decoupled from the int auto-increment PK. Autoincrement
  /// ints are unsafe to expose in `create_lineage_key` derivation across
  /// reinstall/restore (M5.1). Nullable: pre-v9 rows predate the column.
  final String? candidateId;
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
  final TransactionKind? kind;
  final TransactionDirection? direction;
  final FinancialLifecycle? lifecycle;
  final int? originalAmountMinor;
  final int? walletAmountMinor;
  final int? transactionAtEpochMs;
  final String? dateEvidence;
  final String? counterpartyRedacted;
  final String? instrumentSuffixHash;
  final int? availableBalanceMinor;
  final String? paymentType;
  final int? confidenceBasisPoints;
  final String? parserRuleId;
  final String? parserRuleVersion;
  final String? rulePackId;
  final String? rulePackVersion;
  final String? reviewReasons;
  final String? transactionFingerprint;
  const TransactionCandidate({
    required this.id,
    this.candidateId,
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
    this.kind,
    this.direction,
    this.lifecycle,
    this.originalAmountMinor,
    this.walletAmountMinor,
    this.transactionAtEpochMs,
    this.dateEvidence,
    this.counterpartyRedacted,
    this.instrumentSuffixHash,
    this.availableBalanceMinor,
    this.paymentType,
    this.confidenceBasisPoints,
    this.parserRuleId,
    this.parserRuleVersion,
    this.rulePackId,
    this.rulePackVersion,
    this.reviewReasons,
    this.transactionFingerprint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || candidateId != null) {
      map['candidate_id'] = Variable<String>(candidateId);
    }
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
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(
        $TransactionCandidatesTable.$converterkindn.toSql(kind),
      );
    }
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(
        $TransactionCandidatesTable.$converterdirectionn.toSql(direction),
      );
    }
    if (!nullToAbsent || lifecycle != null) {
      map['lifecycle'] = Variable<String>(
        $TransactionCandidatesTable.$converterlifecyclen.toSql(lifecycle),
      );
    }
    if (!nullToAbsent || originalAmountMinor != null) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor);
    }
    if (!nullToAbsent || walletAmountMinor != null) {
      map['wallet_amount_minor'] = Variable<int>(walletAmountMinor);
    }
    if (!nullToAbsent || transactionAtEpochMs != null) {
      map['transaction_at_epoch_ms'] = Variable<int>(transactionAtEpochMs);
    }
    if (!nullToAbsent || dateEvidence != null) {
      map['date_evidence'] = Variable<String>(dateEvidence);
    }
    if (!nullToAbsent || counterpartyRedacted != null) {
      map['counterparty_redacted'] = Variable<String>(counterpartyRedacted);
    }
    if (!nullToAbsent || instrumentSuffixHash != null) {
      map['instrument_suffix_hash'] = Variable<String>(instrumentSuffixHash);
    }
    if (!nullToAbsent || availableBalanceMinor != null) {
      map['available_balance_minor'] = Variable<int>(availableBalanceMinor);
    }
    if (!nullToAbsent || paymentType != null) {
      map['payment_type'] = Variable<String>(paymentType);
    }
    if (!nullToAbsent || confidenceBasisPoints != null) {
      map['confidence_basis_points'] = Variable<int>(confidenceBasisPoints);
    }
    if (!nullToAbsent || parserRuleId != null) {
      map['parser_rule_id'] = Variable<String>(parserRuleId);
    }
    if (!nullToAbsent || parserRuleVersion != null) {
      map['parser_rule_version'] = Variable<String>(parserRuleVersion);
    }
    if (!nullToAbsent || rulePackId != null) {
      map['rule_pack_id'] = Variable<String>(rulePackId);
    }
    if (!nullToAbsent || rulePackVersion != null) {
      map['rule_pack_version'] = Variable<String>(rulePackVersion);
    }
    if (!nullToAbsent || reviewReasons != null) {
      map['review_reasons'] = Variable<String>(reviewReasons);
    }
    if (!nullToAbsent || transactionFingerprint != null) {
      map['transaction_fingerprint'] = Variable<String>(transactionFingerprint);
    }
    return map;
  }

  TransactionCandidatesCompanion toCompanion(bool nullToAbsent) {
    return TransactionCandidatesCompanion(
      id: Value(id),
      candidateId: candidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateId),
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
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      lifecycle: lifecycle == null && nullToAbsent
          ? const Value.absent()
          : Value(lifecycle),
      originalAmountMinor: originalAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmountMinor),
      walletAmountMinor: walletAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(walletAmountMinor),
      transactionAtEpochMs: transactionAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionAtEpochMs),
      dateEvidence: dateEvidence == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEvidence),
      counterpartyRedacted: counterpartyRedacted == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartyRedacted),
      instrumentSuffixHash: instrumentSuffixHash == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentSuffixHash),
      availableBalanceMinor: availableBalanceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(availableBalanceMinor),
      paymentType: paymentType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentType),
      confidenceBasisPoints: confidenceBasisPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceBasisPoints),
      parserRuleId: parserRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(parserRuleId),
      parserRuleVersion: parserRuleVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(parserRuleVersion),
      rulePackId: rulePackId == null && nullToAbsent
          ? const Value.absent()
          : Value(rulePackId),
      rulePackVersion: rulePackVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(rulePackVersion),
      reviewReasons: reviewReasons == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewReasons),
      transactionFingerprint: transactionFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionFingerprint),
    );
  }

  factory TransactionCandidate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionCandidate(
      id: serializer.fromJson<int>(json['id']),
      candidateId: serializer.fromJson<String?>(json['candidateId']),
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
      kind: $TransactionCandidatesTable.$converterkindn.fromJson(
        serializer.fromJson<String?>(json['kind']),
      ),
      direction: $TransactionCandidatesTable.$converterdirectionn.fromJson(
        serializer.fromJson<String?>(json['direction']),
      ),
      lifecycle: $TransactionCandidatesTable.$converterlifecyclen.fromJson(
        serializer.fromJson<String?>(json['lifecycle']),
      ),
      originalAmountMinor: serializer.fromJson<int?>(
        json['originalAmountMinor'],
      ),
      walletAmountMinor: serializer.fromJson<int?>(json['walletAmountMinor']),
      transactionAtEpochMs: serializer.fromJson<int?>(
        json['transactionAtEpochMs'],
      ),
      dateEvidence: serializer.fromJson<String?>(json['dateEvidence']),
      counterpartyRedacted: serializer.fromJson<String?>(
        json['counterpartyRedacted'],
      ),
      instrumentSuffixHash: serializer.fromJson<String?>(
        json['instrumentSuffixHash'],
      ),
      availableBalanceMinor: serializer.fromJson<int?>(
        json['availableBalanceMinor'],
      ),
      paymentType: serializer.fromJson<String?>(json['paymentType']),
      confidenceBasisPoints: serializer.fromJson<int?>(
        json['confidenceBasisPoints'],
      ),
      parserRuleId: serializer.fromJson<String?>(json['parserRuleId']),
      parserRuleVersion: serializer.fromJson<String?>(
        json['parserRuleVersion'],
      ),
      rulePackId: serializer.fromJson<String?>(json['rulePackId']),
      rulePackVersion: serializer.fromJson<String?>(json['rulePackVersion']),
      reviewReasons: serializer.fromJson<String?>(json['reviewReasons']),
      transactionFingerprint: serializer.fromJson<String?>(
        json['transactionFingerprint'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'candidateId': serializer.toJson<String?>(candidateId),
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
      'kind': serializer.toJson<String?>(
        $TransactionCandidatesTable.$converterkindn.toJson(kind),
      ),
      'direction': serializer.toJson<String?>(
        $TransactionCandidatesTable.$converterdirectionn.toJson(direction),
      ),
      'lifecycle': serializer.toJson<String?>(
        $TransactionCandidatesTable.$converterlifecyclen.toJson(lifecycle),
      ),
      'originalAmountMinor': serializer.toJson<int?>(originalAmountMinor),
      'walletAmountMinor': serializer.toJson<int?>(walletAmountMinor),
      'transactionAtEpochMs': serializer.toJson<int?>(transactionAtEpochMs),
      'dateEvidence': serializer.toJson<String?>(dateEvidence),
      'counterpartyRedacted': serializer.toJson<String?>(counterpartyRedacted),
      'instrumentSuffixHash': serializer.toJson<String?>(instrumentSuffixHash),
      'availableBalanceMinor': serializer.toJson<int?>(availableBalanceMinor),
      'paymentType': serializer.toJson<String?>(paymentType),
      'confidenceBasisPoints': serializer.toJson<int?>(confidenceBasisPoints),
      'parserRuleId': serializer.toJson<String?>(parserRuleId),
      'parserRuleVersion': serializer.toJson<String?>(parserRuleVersion),
      'rulePackId': serializer.toJson<String?>(rulePackId),
      'rulePackVersion': serializer.toJson<String?>(rulePackVersion),
      'reviewReasons': serializer.toJson<String?>(reviewReasons),
      'transactionFingerprint': serializer.toJson<String?>(
        transactionFingerprint,
      ),
    };
  }

  TransactionCandidate copyWith({
    int? id,
    Value<String?> candidateId = const Value.absent(),
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
    Value<TransactionKind?> kind = const Value.absent(),
    Value<TransactionDirection?> direction = const Value.absent(),
    Value<FinancialLifecycle?> lifecycle = const Value.absent(),
    Value<int?> originalAmountMinor = const Value.absent(),
    Value<int?> walletAmountMinor = const Value.absent(),
    Value<int?> transactionAtEpochMs = const Value.absent(),
    Value<String?> dateEvidence = const Value.absent(),
    Value<String?> counterpartyRedacted = const Value.absent(),
    Value<String?> instrumentSuffixHash = const Value.absent(),
    Value<int?> availableBalanceMinor = const Value.absent(),
    Value<String?> paymentType = const Value.absent(),
    Value<int?> confidenceBasisPoints = const Value.absent(),
    Value<String?> parserRuleId = const Value.absent(),
    Value<String?> parserRuleVersion = const Value.absent(),
    Value<String?> rulePackId = const Value.absent(),
    Value<String?> rulePackVersion = const Value.absent(),
    Value<String?> reviewReasons = const Value.absent(),
    Value<String?> transactionFingerprint = const Value.absent(),
  }) => TransactionCandidate(
    id: id ?? this.id,
    candidateId: candidateId.present ? candidateId.value : this.candidateId,
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
    kind: kind.present ? kind.value : this.kind,
    direction: direction.present ? direction.value : this.direction,
    lifecycle: lifecycle.present ? lifecycle.value : this.lifecycle,
    originalAmountMinor: originalAmountMinor.present
        ? originalAmountMinor.value
        : this.originalAmountMinor,
    walletAmountMinor: walletAmountMinor.present
        ? walletAmountMinor.value
        : this.walletAmountMinor,
    transactionAtEpochMs: transactionAtEpochMs.present
        ? transactionAtEpochMs.value
        : this.transactionAtEpochMs,
    dateEvidence: dateEvidence.present ? dateEvidence.value : this.dateEvidence,
    counterpartyRedacted: counterpartyRedacted.present
        ? counterpartyRedacted.value
        : this.counterpartyRedacted,
    instrumentSuffixHash: instrumentSuffixHash.present
        ? instrumentSuffixHash.value
        : this.instrumentSuffixHash,
    availableBalanceMinor: availableBalanceMinor.present
        ? availableBalanceMinor.value
        : this.availableBalanceMinor,
    paymentType: paymentType.present ? paymentType.value : this.paymentType,
    confidenceBasisPoints: confidenceBasisPoints.present
        ? confidenceBasisPoints.value
        : this.confidenceBasisPoints,
    parserRuleId: parserRuleId.present ? parserRuleId.value : this.parserRuleId,
    parserRuleVersion: parserRuleVersion.present
        ? parserRuleVersion.value
        : this.parserRuleVersion,
    rulePackId: rulePackId.present ? rulePackId.value : this.rulePackId,
    rulePackVersion: rulePackVersion.present
        ? rulePackVersion.value
        : this.rulePackVersion,
    reviewReasons: reviewReasons.present
        ? reviewReasons.value
        : this.reviewReasons,
    transactionFingerprint: transactionFingerprint.present
        ? transactionFingerprint.value
        : this.transactionFingerprint,
  );
  TransactionCandidate copyWithCompanion(TransactionCandidatesCompanion data) {
    return TransactionCandidate(
      id: data.id.present ? data.id.value : this.id,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
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
      kind: data.kind.present ? data.kind.value : this.kind,
      direction: data.direction.present ? data.direction.value : this.direction,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      originalAmountMinor: data.originalAmountMinor.present
          ? data.originalAmountMinor.value
          : this.originalAmountMinor,
      walletAmountMinor: data.walletAmountMinor.present
          ? data.walletAmountMinor.value
          : this.walletAmountMinor,
      transactionAtEpochMs: data.transactionAtEpochMs.present
          ? data.transactionAtEpochMs.value
          : this.transactionAtEpochMs,
      dateEvidence: data.dateEvidence.present
          ? data.dateEvidence.value
          : this.dateEvidence,
      counterpartyRedacted: data.counterpartyRedacted.present
          ? data.counterpartyRedacted.value
          : this.counterpartyRedacted,
      instrumentSuffixHash: data.instrumentSuffixHash.present
          ? data.instrumentSuffixHash.value
          : this.instrumentSuffixHash,
      availableBalanceMinor: data.availableBalanceMinor.present
          ? data.availableBalanceMinor.value
          : this.availableBalanceMinor,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      confidenceBasisPoints: data.confidenceBasisPoints.present
          ? data.confidenceBasisPoints.value
          : this.confidenceBasisPoints,
      parserRuleId: data.parserRuleId.present
          ? data.parserRuleId.value
          : this.parserRuleId,
      parserRuleVersion: data.parserRuleVersion.present
          ? data.parserRuleVersion.value
          : this.parserRuleVersion,
      rulePackId: data.rulePackId.present
          ? data.rulePackId.value
          : this.rulePackId,
      rulePackVersion: data.rulePackVersion.present
          ? data.rulePackVersion.value
          : this.rulePackVersion,
      reviewReasons: data.reviewReasons.present
          ? data.reviewReasons.value
          : this.reviewReasons,
      transactionFingerprint: data.transactionFingerprint.present
          ? data.transactionFingerprint.value
          : this.transactionFingerprint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCandidate(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('smsEventId: $smsEventId, ')
          ..write('state: $state, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('revision: $revision, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('warningCode: $warningCode, ')
          ..write('paymentEvidence: $paymentEvidence, ')
          ..write('instrumentEvidence: $instrumentEvidence, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('walletCurrencyCode: $walletCurrencyCode, ')
          ..write('kind: $kind, ')
          ..write('direction: $direction, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('walletAmountMinor: $walletAmountMinor, ')
          ..write('transactionAtEpochMs: $transactionAtEpochMs, ')
          ..write('dateEvidence: $dateEvidence, ')
          ..write('counterpartyRedacted: $counterpartyRedacted, ')
          ..write('instrumentSuffixHash: $instrumentSuffixHash, ')
          ..write('availableBalanceMinor: $availableBalanceMinor, ')
          ..write('paymentType: $paymentType, ')
          ..write('confidenceBasisPoints: $confidenceBasisPoints, ')
          ..write('parserRuleId: $parserRuleId, ')
          ..write('parserRuleVersion: $parserRuleVersion, ')
          ..write('rulePackId: $rulePackId, ')
          ..write('rulePackVersion: $rulePackVersion, ')
          ..write('reviewReasons: $reviewReasons, ')
          ..write('transactionFingerprint: $transactionFingerprint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    candidateId,
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
    kind,
    direction,
    lifecycle,
    originalAmountMinor,
    walletAmountMinor,
    transactionAtEpochMs,
    dateEvidence,
    counterpartyRedacted,
    instrumentSuffixHash,
    availableBalanceMinor,
    paymentType,
    confidenceBasisPoints,
    parserRuleId,
    parserRuleVersion,
    rulePackId,
    rulePackVersion,
    reviewReasons,
    transactionFingerprint,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionCandidate &&
          other.id == this.id &&
          other.candidateId == this.candidateId &&
          other.smsEventId == this.smsEventId &&
          other.state == this.state &&
          other.encryptedPayload == this.encryptedPayload &&
          other.revision == this.revision &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.warningCode == this.warningCode &&
          other.paymentEvidence == this.paymentEvidence &&
          other.instrumentEvidence == this.instrumentEvidence &&
          other.originalCurrencyCode == this.originalCurrencyCode &&
          other.walletCurrencyCode == this.walletCurrencyCode &&
          other.kind == this.kind &&
          other.direction == this.direction &&
          other.lifecycle == this.lifecycle &&
          other.originalAmountMinor == this.originalAmountMinor &&
          other.walletAmountMinor == this.walletAmountMinor &&
          other.transactionAtEpochMs == this.transactionAtEpochMs &&
          other.dateEvidence == this.dateEvidence &&
          other.counterpartyRedacted == this.counterpartyRedacted &&
          other.instrumentSuffixHash == this.instrumentSuffixHash &&
          other.availableBalanceMinor == this.availableBalanceMinor &&
          other.paymentType == this.paymentType &&
          other.confidenceBasisPoints == this.confidenceBasisPoints &&
          other.parserRuleId == this.parserRuleId &&
          other.parserRuleVersion == this.parserRuleVersion &&
          other.rulePackId == this.rulePackId &&
          other.rulePackVersion == this.rulePackVersion &&
          other.reviewReasons == this.reviewReasons &&
          other.transactionFingerprint == this.transactionFingerprint);
}

class TransactionCandidatesCompanion
    extends UpdateCompanion<TransactionCandidate> {
  final Value<int> id;
  final Value<String?> candidateId;
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
  final Value<TransactionKind?> kind;
  final Value<TransactionDirection?> direction;
  final Value<FinancialLifecycle?> lifecycle;
  final Value<int?> originalAmountMinor;
  final Value<int?> walletAmountMinor;
  final Value<int?> transactionAtEpochMs;
  final Value<String?> dateEvidence;
  final Value<String?> counterpartyRedacted;
  final Value<String?> instrumentSuffixHash;
  final Value<int?> availableBalanceMinor;
  final Value<String?> paymentType;
  final Value<int?> confidenceBasisPoints;
  final Value<String?> parserRuleId;
  final Value<String?> parserRuleVersion;
  final Value<String?> rulePackId;
  final Value<String?> rulePackVersion;
  final Value<String?> reviewReasons;
  final Value<String?> transactionFingerprint;
  const TransactionCandidatesCompanion({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
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
    this.kind = const Value.absent(),
    this.direction = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.walletAmountMinor = const Value.absent(),
    this.transactionAtEpochMs = const Value.absent(),
    this.dateEvidence = const Value.absent(),
    this.counterpartyRedacted = const Value.absent(),
    this.instrumentSuffixHash = const Value.absent(),
    this.availableBalanceMinor = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.confidenceBasisPoints = const Value.absent(),
    this.parserRuleId = const Value.absent(),
    this.parserRuleVersion = const Value.absent(),
    this.rulePackId = const Value.absent(),
    this.rulePackVersion = const Value.absent(),
    this.reviewReasons = const Value.absent(),
    this.transactionFingerprint = const Value.absent(),
  });
  TransactionCandidatesCompanion.insert({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
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
    this.kind = const Value.absent(),
    this.direction = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.walletAmountMinor = const Value.absent(),
    this.transactionAtEpochMs = const Value.absent(),
    this.dateEvidence = const Value.absent(),
    this.counterpartyRedacted = const Value.absent(),
    this.instrumentSuffixHash = const Value.absent(),
    this.availableBalanceMinor = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.confidenceBasisPoints = const Value.absent(),
    this.parserRuleId = const Value.absent(),
    this.parserRuleVersion = const Value.absent(),
    this.rulePackId = const Value.absent(),
    this.rulePackVersion = const Value.absent(),
    this.reviewReasons = const Value.absent(),
    this.transactionFingerprint = const Value.absent(),
  }) : smsEventId = Value(smsEventId),
       state = Value(state),
       encryptedPayload = Value(encryptedPayload),
       revision = Value(revision),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<TransactionCandidate> custom({
    Expression<int>? id,
    Expression<String>? candidateId,
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
    Expression<String>? kind,
    Expression<String>? direction,
    Expression<String>? lifecycle,
    Expression<int>? originalAmountMinor,
    Expression<int>? walletAmountMinor,
    Expression<int>? transactionAtEpochMs,
    Expression<String>? dateEvidence,
    Expression<String>? counterpartyRedacted,
    Expression<String>? instrumentSuffixHash,
    Expression<int>? availableBalanceMinor,
    Expression<String>? paymentType,
    Expression<int>? confidenceBasisPoints,
    Expression<String>? parserRuleId,
    Expression<String>? parserRuleVersion,
    Expression<String>? rulePackId,
    Expression<String>? rulePackVersion,
    Expression<String>? reviewReasons,
    Expression<String>? transactionFingerprint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
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
      if (kind != null) 'kind': kind,
      if (direction != null) 'direction': direction,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (originalAmountMinor != null)
        'original_amount_minor': originalAmountMinor,
      if (walletAmountMinor != null) 'wallet_amount_minor': walletAmountMinor,
      if (transactionAtEpochMs != null)
        'transaction_at_epoch_ms': transactionAtEpochMs,
      if (dateEvidence != null) 'date_evidence': dateEvidence,
      if (counterpartyRedacted != null)
        'counterparty_redacted': counterpartyRedacted,
      if (instrumentSuffixHash != null)
        'instrument_suffix_hash': instrumentSuffixHash,
      if (availableBalanceMinor != null)
        'available_balance_minor': availableBalanceMinor,
      if (paymentType != null) 'payment_type': paymentType,
      if (confidenceBasisPoints != null)
        'confidence_basis_points': confidenceBasisPoints,
      if (parserRuleId != null) 'parser_rule_id': parserRuleId,
      if (parserRuleVersion != null) 'parser_rule_version': parserRuleVersion,
      if (rulePackId != null) 'rule_pack_id': rulePackId,
      if (rulePackVersion != null) 'rule_pack_version': rulePackVersion,
      if (reviewReasons != null) 'review_reasons': reviewReasons,
      if (transactionFingerprint != null)
        'transaction_fingerprint': transactionFingerprint,
    });
  }

  TransactionCandidatesCompanion copyWith({
    Value<int>? id,
    Value<String?>? candidateId,
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
    Value<TransactionKind?>? kind,
    Value<TransactionDirection?>? direction,
    Value<FinancialLifecycle?>? lifecycle,
    Value<int?>? originalAmountMinor,
    Value<int?>? walletAmountMinor,
    Value<int?>? transactionAtEpochMs,
    Value<String?>? dateEvidence,
    Value<String?>? counterpartyRedacted,
    Value<String?>? instrumentSuffixHash,
    Value<int?>? availableBalanceMinor,
    Value<String?>? paymentType,
    Value<int?>? confidenceBasisPoints,
    Value<String?>? parserRuleId,
    Value<String?>? parserRuleVersion,
    Value<String?>? rulePackId,
    Value<String?>? rulePackVersion,
    Value<String?>? reviewReasons,
    Value<String?>? transactionFingerprint,
  }) {
    return TransactionCandidatesCompanion(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
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
      kind: kind ?? this.kind,
      direction: direction ?? this.direction,
      lifecycle: lifecycle ?? this.lifecycle,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      walletAmountMinor: walletAmountMinor ?? this.walletAmountMinor,
      transactionAtEpochMs: transactionAtEpochMs ?? this.transactionAtEpochMs,
      dateEvidence: dateEvidence ?? this.dateEvidence,
      counterpartyRedacted: counterpartyRedacted ?? this.counterpartyRedacted,
      instrumentSuffixHash: instrumentSuffixHash ?? this.instrumentSuffixHash,
      availableBalanceMinor:
          availableBalanceMinor ?? this.availableBalanceMinor,
      paymentType: paymentType ?? this.paymentType,
      confidenceBasisPoints:
          confidenceBasisPoints ?? this.confidenceBasisPoints,
      parserRuleId: parserRuleId ?? this.parserRuleId,
      parserRuleVersion: parserRuleVersion ?? this.parserRuleVersion,
      rulePackId: rulePackId ?? this.rulePackId,
      rulePackVersion: rulePackVersion ?? this.rulePackVersion,
      reviewReasons: reviewReasons ?? this.reviewReasons,
      transactionFingerprint:
          transactionFingerprint ?? this.transactionFingerprint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $TransactionCandidatesTable.$converterkindn.toSql(kind.value),
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $TransactionCandidatesTable.$converterdirectionn.toSql(direction.value),
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(
        $TransactionCandidatesTable.$converterlifecyclen.toSql(lifecycle.value),
      );
    }
    if (originalAmountMinor.present) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor.value);
    }
    if (walletAmountMinor.present) {
      map['wallet_amount_minor'] = Variable<int>(walletAmountMinor.value);
    }
    if (transactionAtEpochMs.present) {
      map['transaction_at_epoch_ms'] = Variable<int>(
        transactionAtEpochMs.value,
      );
    }
    if (dateEvidence.present) {
      map['date_evidence'] = Variable<String>(dateEvidence.value);
    }
    if (counterpartyRedacted.present) {
      map['counterparty_redacted'] = Variable<String>(
        counterpartyRedacted.value,
      );
    }
    if (instrumentSuffixHash.present) {
      map['instrument_suffix_hash'] = Variable<String>(
        instrumentSuffixHash.value,
      );
    }
    if (availableBalanceMinor.present) {
      map['available_balance_minor'] = Variable<int>(
        availableBalanceMinor.value,
      );
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (confidenceBasisPoints.present) {
      map['confidence_basis_points'] = Variable<int>(
        confidenceBasisPoints.value,
      );
    }
    if (parserRuleId.present) {
      map['parser_rule_id'] = Variable<String>(parserRuleId.value);
    }
    if (parserRuleVersion.present) {
      map['parser_rule_version'] = Variable<String>(parserRuleVersion.value);
    }
    if (rulePackId.present) {
      map['rule_pack_id'] = Variable<String>(rulePackId.value);
    }
    if (rulePackVersion.present) {
      map['rule_pack_version'] = Variable<String>(rulePackVersion.value);
    }
    if (reviewReasons.present) {
      map['review_reasons'] = Variable<String>(reviewReasons.value);
    }
    if (transactionFingerprint.present) {
      map['transaction_fingerprint'] = Variable<String>(
        transactionFingerprint.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCandidatesCompanion(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('smsEventId: $smsEventId, ')
          ..write('state: $state, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('revision: $revision, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('warningCode: $warningCode, ')
          ..write('paymentEvidence: $paymentEvidence, ')
          ..write('instrumentEvidence: $instrumentEvidence, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('walletCurrencyCode: $walletCurrencyCode, ')
          ..write('kind: $kind, ')
          ..write('direction: $direction, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('walletAmountMinor: $walletAmountMinor, ')
          ..write('transactionAtEpochMs: $transactionAtEpochMs, ')
          ..write('dateEvidence: $dateEvidence, ')
          ..write('counterpartyRedacted: $counterpartyRedacted, ')
          ..write('instrumentSuffixHash: $instrumentSuffixHash, ')
          ..write('availableBalanceMinor: $availableBalanceMinor, ')
          ..write('paymentType: $paymentType, ')
          ..write('confidenceBasisPoints: $confidenceBasisPoints, ')
          ..write('parserRuleId: $parserRuleId, ')
          ..write('parserRuleVersion: $parserRuleVersion, ')
          ..write('rulePackId: $rulePackId, ')
          ..write('rulePackVersion: $rulePackVersion, ')
          ..write('reviewReasons: $reviewReasons, ')
          ..write('transactionFingerprint: $transactionFingerprint')
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
  static const VerificationMeta _batchCountMeta = const VerificationMeta(
    'batchCount',
  );
  @override
  late final GeneratedColumn<int> batchCount = GeneratedColumn<int>(
    'batch_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailMessageMeta = const VerificationMeta(
    'detailMessage',
  );
  @override
  late final GeneratedColumn<String> detailMessage = GeneratedColumn<String>(
    'detail_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    sanitizedDetail,
    occurredAtEpochMs,
    privacyEpoch,
    batchCount,
    mutationId,
    detailMessage,
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
    if (data.containsKey('batch_count')) {
      context.handle(
        _batchCountMeta,
        batchCount.isAcceptableOrUnknown(data['batch_count']!, _batchCountMeta),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    }
    if (data.containsKey('detail_message')) {
      context.handle(
        _detailMessageMeta,
        detailMessage.isAcceptableOrUnknown(
          data['detail_message']!,
          _detailMessageMeta,
        ),
      );
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
      batchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_count'],
      ),
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      ),
      detailMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_message'],
      ),
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

  /// Optional count for aggregated batch events — e.g. one
  /// `messageImported` row per import batch instead of one per message
  /// (M4.15 WP3). Null = single-item event.
  final int? batchCount;

  /// The outbox mutation this event describes (M5.14). Nullable so the column
  /// is safe for log-derived and pre-v10 rows; recovery actions read it to
  /// dispatch the REAL mutation id instead of a fabricated one.
  final String? mutationId;

  /// Optional human-readable detail for the activity event (M5.15 Bug 8.1).
  /// Nullable so pre-v11 rows stay valid; the UI falls back to the
  /// ActivityStateTransition enum label when null.
  final String? detailMessage;
  const ActivityEvent({
    required this.id,
    required this.eventType,
    required this.sanitizedDetail,
    required this.occurredAtEpochMs,
    required this.privacyEpoch,
    this.batchCount,
    this.mutationId,
    this.detailMessage,
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
    if (!nullToAbsent || batchCount != null) {
      map['batch_count'] = Variable<int>(batchCount);
    }
    if (!nullToAbsent || mutationId != null) {
      map['mutation_id'] = Variable<String>(mutationId);
    }
    if (!nullToAbsent || detailMessage != null) {
      map['detail_message'] = Variable<String>(detailMessage);
    }
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      sanitizedDetail: Value(sanitizedDetail),
      occurredAtEpochMs: Value(occurredAtEpochMs),
      privacyEpoch: Value(privacyEpoch),
      batchCount: batchCount == null && nullToAbsent
          ? const Value.absent()
          : Value(batchCount),
      mutationId: mutationId == null && nullToAbsent
          ? const Value.absent()
          : Value(mutationId),
      detailMessage: detailMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(detailMessage),
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
      batchCount: serializer.fromJson<int?>(json['batchCount']),
      mutationId: serializer.fromJson<String?>(json['mutationId']),
      detailMessage: serializer.fromJson<String?>(json['detailMessage']),
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
      'batchCount': serializer.toJson<int?>(batchCount),
      'mutationId': serializer.toJson<String?>(mutationId),
      'detailMessage': serializer.toJson<String?>(detailMessage),
    };
  }

  ActivityEvent copyWith({
    int? id,
    ActivityEventCode? eventType,
    ActivityStateTransition? sanitizedDetail,
    int? occurredAtEpochMs,
    int? privacyEpoch,
    Value<int?> batchCount = const Value.absent(),
    Value<String?> mutationId = const Value.absent(),
    Value<String?> detailMessage = const Value.absent(),
  }) => ActivityEvent(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    sanitizedDetail: sanitizedDetail ?? this.sanitizedDetail,
    occurredAtEpochMs: occurredAtEpochMs ?? this.occurredAtEpochMs,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    batchCount: batchCount.present ? batchCount.value : this.batchCount,
    mutationId: mutationId.present ? mutationId.value : this.mutationId,
    detailMessage: detailMessage.present
        ? detailMessage.value
        : this.detailMessage,
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
      batchCount: data.batchCount.present
          ? data.batchCount.value
          : this.batchCount,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      detailMessage: data.detailMessage.present
          ? data.detailMessage.value
          : this.detailMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('sanitizedDetail: $sanitizedDetail, ')
          ..write('occurredAtEpochMs: $occurredAtEpochMs, ')
          ..write('privacyEpoch: $privacyEpoch, ')
          ..write('batchCount: $batchCount, ')
          ..write('mutationId: $mutationId, ')
          ..write('detailMessage: $detailMessage')
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
    batchCount,
    mutationId,
    detailMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.sanitizedDetail == this.sanitizedDetail &&
          other.occurredAtEpochMs == this.occurredAtEpochMs &&
          other.privacyEpoch == this.privacyEpoch &&
          other.batchCount == this.batchCount &&
          other.mutationId == this.mutationId &&
          other.detailMessage == this.detailMessage);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<int> id;
  final Value<ActivityEventCode> eventType;
  final Value<ActivityStateTransition> sanitizedDetail;
  final Value<int> occurredAtEpochMs;
  final Value<int> privacyEpoch;
  final Value<int?> batchCount;
  final Value<String?> mutationId;
  final Value<String?> detailMessage;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.sanitizedDetail = const Value.absent(),
    this.occurredAtEpochMs = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
    this.batchCount = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.detailMessage = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    this.id = const Value.absent(),
    required ActivityEventCode eventType,
    required ActivityStateTransition sanitizedDetail,
    required int occurredAtEpochMs,
    required int privacyEpoch,
    this.batchCount = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.detailMessage = const Value.absent(),
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
    Expression<int>? batchCount,
    Expression<String>? mutationId,
    Expression<String>? detailMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (sanitizedDetail != null) 'sanitized_detail': sanitizedDetail,
      if (occurredAtEpochMs != null) 'occurred_at_epoch_ms': occurredAtEpochMs,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
      if (batchCount != null) 'batch_count': batchCount,
      if (mutationId != null) 'mutation_id': mutationId,
      if (detailMessage != null) 'detail_message': detailMessage,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<int>? id,
    Value<ActivityEventCode>? eventType,
    Value<ActivityStateTransition>? sanitizedDetail,
    Value<int>? occurredAtEpochMs,
    Value<int>? privacyEpoch,
    Value<int?>? batchCount,
    Value<String?>? mutationId,
    Value<String?>? detailMessage,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      sanitizedDetail: sanitizedDetail ?? this.sanitizedDetail,
      occurredAtEpochMs: occurredAtEpochMs ?? this.occurredAtEpochMs,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
      batchCount: batchCount ?? this.batchCount,
      mutationId: mutationId ?? this.mutationId,
      detailMessage: detailMessage ?? this.detailMessage,
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
    if (batchCount.present) {
      map['batch_count'] = Variable<int>(batchCount.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (detailMessage.present) {
      map['detail_message'] = Variable<String>(detailMessage.value);
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
          ..write('privacyEpoch: $privacyEpoch, ')
          ..write('batchCount: $batchCount, ')
          ..write('mutationId: $mutationId, ')
          ..write('detailMessage: $detailMessage')
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
  late final GeneratedColumnWithTypeConverter<DecisionStage?, String> stage =
      GeneratedColumn<String>(
        'stage',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DecisionStage?>($DecisionTracesTable.$converterstagen);
  static const VerificationMeta _rulePackVersionMeta = const VerificationMeta(
    'rulePackVersion',
  );
  @override
  late final GeneratedColumn<String> rulePackVersion = GeneratedColumn<String>(
    'rule_pack_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeCodeMeta = const VerificationMeta(
    'outcomeCode',
  );
  @override
  late final GeneratedColumn<String> outcomeCode = GeneratedColumn<String>(
    'outcome_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    candidateId,
    traceCode,
    createdAtEpochMs,
    stage,
    rulePackVersion,
    outcomeCode,
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
    if (data.containsKey('rule_pack_version')) {
      context.handle(
        _rulePackVersionMeta,
        rulePackVersion.isAcceptableOrUnknown(
          data['rule_pack_version']!,
          _rulePackVersionMeta,
        ),
      );
    }
    if (data.containsKey('outcome_code')) {
      context.handle(
        _outcomeCodeMeta,
        outcomeCode.isAcceptableOrUnknown(
          data['outcome_code']!,
          _outcomeCodeMeta,
        ),
      );
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
      stage: $DecisionTracesTable.$converterstagen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}stage'],
        ),
      ),
      rulePackVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_pack_version'],
      ),
      outcomeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome_code'],
      ),
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
  static JsonTypeConverter2<DecisionStage, String, String> $converterstage =
      const EnumNameConverter<DecisionStage>(DecisionStage.values);
  static JsonTypeConverter2<DecisionStage?, String?, String?> $converterstagen =
      JsonTypeConverter2.asNullable($converterstage);
}

class DecisionTrace extends DataClass implements Insertable<DecisionTrace> {
  final int id;
  final int? candidateId;
  final DecisionTraceCode traceCode;
  final int createdAtEpochMs;
  final DecisionStage? stage;
  final String? rulePackVersion;
  final String? outcomeCode;
  const DecisionTrace({
    required this.id,
    this.candidateId,
    required this.traceCode,
    required this.createdAtEpochMs,
    this.stage,
    this.rulePackVersion,
    this.outcomeCode,
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
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(
        $DecisionTracesTable.$converterstagen.toSql(stage),
      );
    }
    if (!nullToAbsent || rulePackVersion != null) {
      map['rule_pack_version'] = Variable<String>(rulePackVersion);
    }
    if (!nullToAbsent || outcomeCode != null) {
      map['outcome_code'] = Variable<String>(outcomeCode);
    }
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
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      rulePackVersion: rulePackVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(rulePackVersion),
      outcomeCode: outcomeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(outcomeCode),
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
      stage: $DecisionTracesTable.$converterstagen.fromJson(
        serializer.fromJson<String?>(json['stage']),
      ),
      rulePackVersion: serializer.fromJson<String?>(json['rulePackVersion']),
      outcomeCode: serializer.fromJson<String?>(json['outcomeCode']),
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
      'stage': serializer.toJson<String?>(
        $DecisionTracesTable.$converterstagen.toJson(stage),
      ),
      'rulePackVersion': serializer.toJson<String?>(rulePackVersion),
      'outcomeCode': serializer.toJson<String?>(outcomeCode),
    };
  }

  DecisionTrace copyWith({
    int? id,
    Value<int?> candidateId = const Value.absent(),
    DecisionTraceCode? traceCode,
    int? createdAtEpochMs,
    Value<DecisionStage?> stage = const Value.absent(),
    Value<String?> rulePackVersion = const Value.absent(),
    Value<String?> outcomeCode = const Value.absent(),
  }) => DecisionTrace(
    id: id ?? this.id,
    candidateId: candidateId.present ? candidateId.value : this.candidateId,
    traceCode: traceCode ?? this.traceCode,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    stage: stage.present ? stage.value : this.stage,
    rulePackVersion: rulePackVersion.present
        ? rulePackVersion.value
        : this.rulePackVersion,
    outcomeCode: outcomeCode.present ? outcomeCode.value : this.outcomeCode,
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
      stage: data.stage.present ? data.stage.value : this.stage,
      rulePackVersion: data.rulePackVersion.present
          ? data.rulePackVersion.value
          : this.rulePackVersion,
      outcomeCode: data.outcomeCode.present
          ? data.outcomeCode.value
          : this.outcomeCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DecisionTrace(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('traceCode: $traceCode, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('stage: $stage, ')
          ..write('rulePackVersion: $rulePackVersion, ')
          ..write('outcomeCode: $outcomeCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    candidateId,
    traceCode,
    createdAtEpochMs,
    stage,
    rulePackVersion,
    outcomeCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DecisionTrace &&
          other.id == this.id &&
          other.candidateId == this.candidateId &&
          other.traceCode == this.traceCode &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.stage == this.stage &&
          other.rulePackVersion == this.rulePackVersion &&
          other.outcomeCode == this.outcomeCode);
}

class DecisionTracesCompanion extends UpdateCompanion<DecisionTrace> {
  final Value<int> id;
  final Value<int?> candidateId;
  final Value<DecisionTraceCode> traceCode;
  final Value<int> createdAtEpochMs;
  final Value<DecisionStage?> stage;
  final Value<String?> rulePackVersion;
  final Value<String?> outcomeCode;
  const DecisionTracesCompanion({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.traceCode = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.stage = const Value.absent(),
    this.rulePackVersion = const Value.absent(),
    this.outcomeCode = const Value.absent(),
  });
  DecisionTracesCompanion.insert({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
    required DecisionTraceCode traceCode,
    required int createdAtEpochMs,
    this.stage = const Value.absent(),
    this.rulePackVersion = const Value.absent(),
    this.outcomeCode = const Value.absent(),
  }) : traceCode = Value(traceCode),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<DecisionTrace> custom({
    Expression<int>? id,
    Expression<int>? candidateId,
    Expression<String>? traceCode,
    Expression<int>? createdAtEpochMs,
    Expression<String>? stage,
    Expression<String>? rulePackVersion,
    Expression<String>? outcomeCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      if (traceCode != null) 'trace_code': traceCode,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (stage != null) 'stage': stage,
      if (rulePackVersion != null) 'rule_pack_version': rulePackVersion,
      if (outcomeCode != null) 'outcome_code': outcomeCode,
    });
  }

  DecisionTracesCompanion copyWith({
    Value<int>? id,
    Value<int?>? candidateId,
    Value<DecisionTraceCode>? traceCode,
    Value<int>? createdAtEpochMs,
    Value<DecisionStage?>? stage,
    Value<String?>? rulePackVersion,
    Value<String?>? outcomeCode,
  }) {
    return DecisionTracesCompanion(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      traceCode: traceCode ?? this.traceCode,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      stage: stage ?? this.stage,
      rulePackVersion: rulePackVersion ?? this.rulePackVersion,
      outcomeCode: outcomeCode ?? this.outcomeCode,
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
    if (stage.present) {
      map['stage'] = Variable<String>(
        $DecisionTracesTable.$converterstagen.toSql(stage.value),
      );
    }
    if (rulePackVersion.present) {
      map['rule_pack_version'] = Variable<String>(rulePackVersion.value);
    }
    if (outcomeCode.present) {
      map['outcome_code'] = Variable<String>(outcomeCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionTracesCompanion(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('traceCode: $traceCode, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('stage: $stage, ')
          ..write('rulePackVersion: $rulePackVersion, ')
          ..write('outcomeCode: $outcomeCode')
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
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown'),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemIdMeta = const VerificationMeta(
    'systemId',
  );
  @override
  late final GeneratedColumn<String> systemId = GeneratedColumn<String>(
    'system_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    groupId,
    groupName,
    parentId,
    systemId,
    refreshedAtEpochMs,
  ];
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
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('system_id')) {
      context.handle(
        _systemIdMeta,
        systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta),
      );
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
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      systemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_id'],
      ),
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
  final String groupId;
  final String groupName;
  final String? parentId;

  /// The Wallet registry slug for a base category, e.g.
  /// `food_and_drinks__general` (M5.22 WP-G, schema v15).
  ///
  /// This is what makes "select the whole group" expressible: a group is not
  /// itself an assignable category, but each group owns a general base
  /// category identified by `<groupId>__general`. Null for custom categories,
  /// which have no registry slug.
  final String? systemId;
  final int refreshedAtEpochMs;
  const WalletCategoryCacheData({
    required this.id,
    required this.name,
    required this.groupId,
    required this.groupName,
    this.parentId,
    this.systemId,
    required this.refreshedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['group_id'] = Variable<String>(groupId);
    map['group_name'] = Variable<String>(groupName);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || systemId != null) {
      map['system_id'] = Variable<String>(systemId);
    }
    map['refreshed_at_epoch_ms'] = Variable<int>(refreshedAtEpochMs);
    return map;
  }

  WalletCategoryCacheCompanion toCompanion(bool nullToAbsent) {
    return WalletCategoryCacheCompanion(
      id: Value(id),
      name: Value(name),
      groupId: Value(groupId),
      groupName: Value(groupName),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      systemId: systemId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemId),
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
      groupId: serializer.fromJson<String>(json['groupId']),
      groupName: serializer.fromJson<String>(json['groupName']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      systemId: serializer.fromJson<String?>(json['systemId']),
      refreshedAtEpochMs: serializer.fromJson<int>(json['refreshedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'groupId': serializer.toJson<String>(groupId),
      'groupName': serializer.toJson<String>(groupName),
      'parentId': serializer.toJson<String?>(parentId),
      'systemId': serializer.toJson<String?>(systemId),
      'refreshedAtEpochMs': serializer.toJson<int>(refreshedAtEpochMs),
    };
  }

  WalletCategoryCacheData copyWith({
    String? id,
    String? name,
    String? groupId,
    String? groupName,
    Value<String?> parentId = const Value.absent(),
    Value<String?> systemId = const Value.absent(),
    int? refreshedAtEpochMs,
  }) => WalletCategoryCacheData(
    id: id ?? this.id,
    name: name ?? this.name,
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    parentId: parentId.present ? parentId.value : this.parentId,
    systemId: systemId.present ? systemId.value : this.systemId,
    refreshedAtEpochMs: refreshedAtEpochMs ?? this.refreshedAtEpochMs,
  );
  WalletCategoryCacheData copyWithCompanion(WalletCategoryCacheCompanion data) {
    return WalletCategoryCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      systemId: data.systemId.present ? data.systemId.value : this.systemId,
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
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('parentId: $parentId, ')
          ..write('systemId: $systemId, ')
          ..write('refreshedAtEpochMs: $refreshedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    groupId,
    groupName,
    parentId,
    systemId,
    refreshedAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletCategoryCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.parentId == this.parentId &&
          other.systemId == this.systemId &&
          other.refreshedAtEpochMs == this.refreshedAtEpochMs);
}

class WalletCategoryCacheCompanion
    extends UpdateCompanion<WalletCategoryCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> groupId;
  final Value<String> groupName;
  final Value<String?> parentId;
  final Value<String?> systemId;
  final Value<int> refreshedAtEpochMs;
  final Value<int> rowid;
  const WalletCategoryCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.parentId = const Value.absent(),
    this.systemId = const Value.absent(),
    this.refreshedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletCategoryCacheCompanion.insert({
    required String id,
    required String name,
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.parentId = const Value.absent(),
    this.systemId = const Value.absent(),
    required int refreshedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       refreshedAtEpochMs = Value(refreshedAtEpochMs);
  static Insertable<WalletCategoryCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? groupId,
    Expression<String>? groupName,
    Expression<String>? parentId,
    Expression<String>? systemId,
    Expression<int>? refreshedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (parentId != null) 'parent_id': parentId,
      if (systemId != null) 'system_id': systemId,
      if (refreshedAtEpochMs != null)
        'refreshed_at_epoch_ms': refreshedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletCategoryCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? groupId,
    Value<String>? groupName,
    Value<String?>? parentId,
    Value<String?>? systemId,
    Value<int>? refreshedAtEpochMs,
    Value<int>? rowid,
  }) {
    return WalletCategoryCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      parentId: parentId ?? this.parentId,
      systemId: systemId ?? this.systemId,
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
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<String>(systemId.value);
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
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('parentId: $parentId, ')
          ..write('systemId: $systemId, ')
          ..write('refreshedAtEpochMs: $refreshedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletLabelCacheTable extends WalletLabelCache
    with TableInfo<$WalletLabelCacheTable, WalletLabelCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletLabelCacheTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'wallet_label_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletLabelCacheData> instance, {
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
  WalletLabelCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletLabelCacheData(
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
  $WalletLabelCacheTable createAlias(String alias) {
    return $WalletLabelCacheTable(attachedDatabase, alias);
  }
}

class WalletLabelCacheData extends DataClass
    implements Insertable<WalletLabelCacheData> {
  final String id;
  final String name;
  final int refreshedAtEpochMs;
  const WalletLabelCacheData({
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

  WalletLabelCacheCompanion toCompanion(bool nullToAbsent) {
    return WalletLabelCacheCompanion(
      id: Value(id),
      name: Value(name),
      refreshedAtEpochMs: Value(refreshedAtEpochMs),
    );
  }

  factory WalletLabelCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletLabelCacheData(
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

  WalletLabelCacheData copyWith({
    String? id,
    String? name,
    int? refreshedAtEpochMs,
  }) => WalletLabelCacheData(
    id: id ?? this.id,
    name: name ?? this.name,
    refreshedAtEpochMs: refreshedAtEpochMs ?? this.refreshedAtEpochMs,
  );
  WalletLabelCacheData copyWithCompanion(WalletLabelCacheCompanion data) {
    return WalletLabelCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      refreshedAtEpochMs: data.refreshedAtEpochMs.present
          ? data.refreshedAtEpochMs.value
          : this.refreshedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletLabelCacheData(')
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
      (other is WalletLabelCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.refreshedAtEpochMs == this.refreshedAtEpochMs);
}

class WalletLabelCacheCompanion extends UpdateCompanion<WalletLabelCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> refreshedAtEpochMs;
  final Value<int> rowid;
  const WalletLabelCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.refreshedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletLabelCacheCompanion.insert({
    required String id,
    required String name,
    required int refreshedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       refreshedAtEpochMs = Value(refreshedAtEpochMs);
  static Insertable<WalletLabelCacheData> custom({
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

  WalletLabelCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? refreshedAtEpochMs,
    Value<int>? rowid,
  }) {
    return WalletLabelCacheCompanion(
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
    return (StringBuffer('WalletLabelCacheCompanion(')
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
  @override
  late final GeneratedColumnWithTypeConverter<WalletMutationOperation, String>
  operationKind =
      GeneratedColumn<String>(
        'operation_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WalletMutationOperation>(
        $WalletMutationsTable.$converteroperationKind,
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
  @override
  late final GeneratedColumnWithTypeConverter<WalletMutationState, String>
  state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<WalletMutationState>($WalletMutationsTable.$converterstate);
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
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
    'candidate_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationRevisionMeta = const VerificationMeta(
    'operationRevision',
  );
  @override
  late final GeneratedColumn<int> operationRevision = GeneratedColumn<int>(
    'operation_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineageGenerationMeta = const VerificationMeta(
    'lineageGeneration',
  );
  @override
  late final GeneratedColumn<int> lineageGeneration = GeneratedColumn<int>(
    'lineage_generation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonCiphertextMeta =
      const VerificationMeta('payloadJsonCiphertext');
  @override
  late final GeneratedColumn<String> payloadJsonCiphertext =
      GeneratedColumn<String>(
        'payload_json_ciphertext',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceMarkerMeta = const VerificationMeta(
    'sourceMarker',
  );
  @override
  late final GeneratedColumn<String> sourceMarker = GeneratedColumn<String>(
    'source_marker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtEpochMsMeta =
      const VerificationMeta('nextAttemptAtEpochMs');
  @override
  late final GeneratedColumn<int> nextAttemptAtEpochMs = GeneratedColumn<int>(
    'next_attempt_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseUntilEpochMsMeta = const VerificationMeta(
    'leaseUntilEpochMs',
  );
  @override
  late final GeneratedColumn<int> leaseUntilEpochMs = GeneratedColumn<int>(
    'lease_until_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastHttpStatusMeta = const VerificationMeta(
    'lastHttpStatus',
  );
  @override
  late final GeneratedColumn<int> lastHttpStatus = GeneratedColumn<int>(
    'last_http_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletCorrelationIdMeta =
      const VerificationMeta('walletCorrelationId');
  @override
  late final GeneratedColumn<String> walletCorrelationId =
      GeneratedColumn<String>(
        'wallet_correlation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationKind,
    payload,
    state,
    lineageKey,
    fingerprint,
    createdAtEpochMs,
    updatedAtEpochMs,
    candidateId,
    operationRevision,
    lineageGeneration,
    payloadJsonCiphertext,
    sourceMarker,
    attemptCount,
    nextAttemptAtEpochMs,
    leaseUntilEpochMs,
    lastHttpStatus,
    walletCorrelationId,
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
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
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
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    }
    if (data.containsKey('operation_revision')) {
      context.handle(
        _operationRevisionMeta,
        operationRevision.isAcceptableOrUnknown(
          data['operation_revision']!,
          _operationRevisionMeta,
        ),
      );
    }
    if (data.containsKey('lineage_generation')) {
      context.handle(
        _lineageGenerationMeta,
        lineageGeneration.isAcceptableOrUnknown(
          data['lineage_generation']!,
          _lineageGenerationMeta,
        ),
      );
    }
    if (data.containsKey('payload_json_ciphertext')) {
      context.handle(
        _payloadJsonCiphertextMeta,
        payloadJsonCiphertext.isAcceptableOrUnknown(
          data['payload_json_ciphertext']!,
          _payloadJsonCiphertextMeta,
        ),
      );
    }
    if (data.containsKey('source_marker')) {
      context.handle(
        _sourceMarkerMeta,
        sourceMarker.isAcceptableOrUnknown(
          data['source_marker']!,
          _sourceMarkerMeta,
        ),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at_epoch_ms')) {
      context.handle(
        _nextAttemptAtEpochMsMeta,
        nextAttemptAtEpochMs.isAcceptableOrUnknown(
          data['next_attempt_at_epoch_ms']!,
          _nextAttemptAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('lease_until_epoch_ms')) {
      context.handle(
        _leaseUntilEpochMsMeta,
        leaseUntilEpochMs.isAcceptableOrUnknown(
          data['lease_until_epoch_ms']!,
          _leaseUntilEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('last_http_status')) {
      context.handle(
        _lastHttpStatusMeta,
        lastHttpStatus.isAcceptableOrUnknown(
          data['last_http_status']!,
          _lastHttpStatusMeta,
        ),
      );
    }
    if (data.containsKey('wallet_correlation_id')) {
      context.handle(
        _walletCorrelationIdMeta,
        walletCorrelationId.isAcceptableOrUnknown(
          data['wallet_correlation_id']!,
          _walletCorrelationIdMeta,
        ),
      );
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
      operationKind: $WalletMutationsTable.$converteroperationKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation_kind'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      state: $WalletMutationsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
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
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      ),
      operationRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operation_revision'],
      ),
      lineageGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lineage_generation'],
      ),
      payloadJsonCiphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json_ciphertext'],
      ),
      sourceMarker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_marker'],
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      ),
      nextAttemptAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at_epoch_ms'],
      ),
      leaseUntilEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lease_until_epoch_ms'],
      ),
      lastHttpStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_http_status'],
      ),
      walletCorrelationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_correlation_id'],
      ),
    );
  }

  @override
  $WalletMutationsTable createAlias(String alias) {
    return $WalletMutationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WalletMutationOperation, String, String>
  $converteroperationKind = const EnumNameConverter<WalletMutationOperation>(
    WalletMutationOperation.values,
  );
  static TypeConverter<WalletMutationState, String> $converterstate =
      const WalletMutationStateConverter();
}

class WalletMutation extends DataClass implements Insertable<WalletMutation> {
  final String id;
  final WalletMutationOperation operationKind;
  final String payload;
  final WalletMutationState state;
  final String lineageKey;
  final String fingerprint;
  final int createdAtEpochMs;
  final int updatedAtEpochMs;
  final String? candidateId;
  final int? operationRevision;
  final int? lineageGeneration;
  final String? payloadJsonCiphertext;
  final String? sourceMarker;
  final int? attemptCount;
  final int? nextAttemptAtEpochMs;
  final int? leaseUntilEpochMs;
  final int? lastHttpStatus;
  final String? walletCorrelationId;
  const WalletMutation({
    required this.id,
    required this.operationKind,
    required this.payload,
    required this.state,
    required this.lineageKey,
    required this.fingerprint,
    required this.createdAtEpochMs,
    required this.updatedAtEpochMs,
    this.candidateId,
    this.operationRevision,
    this.lineageGeneration,
    this.payloadJsonCiphertext,
    this.sourceMarker,
    this.attemptCount,
    this.nextAttemptAtEpochMs,
    this.leaseUntilEpochMs,
    this.lastHttpStatus,
    this.walletCorrelationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['operation_kind'] = Variable<String>(
        $WalletMutationsTable.$converteroperationKind.toSql(operationKind),
      );
    }
    map['payload'] = Variable<String>(payload);
    {
      map['state'] = Variable<String>(
        $WalletMutationsTable.$converterstate.toSql(state),
      );
    }
    map['lineage_key'] = Variable<String>(lineageKey);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs);
    if (!nullToAbsent || candidateId != null) {
      map['candidate_id'] = Variable<String>(candidateId);
    }
    if (!nullToAbsent || operationRevision != null) {
      map['operation_revision'] = Variable<int>(operationRevision);
    }
    if (!nullToAbsent || lineageGeneration != null) {
      map['lineage_generation'] = Variable<int>(lineageGeneration);
    }
    if (!nullToAbsent || payloadJsonCiphertext != null) {
      map['payload_json_ciphertext'] = Variable<String>(payloadJsonCiphertext);
    }
    if (!nullToAbsent || sourceMarker != null) {
      map['source_marker'] = Variable<String>(sourceMarker);
    }
    if (!nullToAbsent || attemptCount != null) {
      map['attempt_count'] = Variable<int>(attemptCount);
    }
    if (!nullToAbsent || nextAttemptAtEpochMs != null) {
      map['next_attempt_at_epoch_ms'] = Variable<int>(nextAttemptAtEpochMs);
    }
    if (!nullToAbsent || leaseUntilEpochMs != null) {
      map['lease_until_epoch_ms'] = Variable<int>(leaseUntilEpochMs);
    }
    if (!nullToAbsent || lastHttpStatus != null) {
      map['last_http_status'] = Variable<int>(lastHttpStatus);
    }
    if (!nullToAbsent || walletCorrelationId != null) {
      map['wallet_correlation_id'] = Variable<String>(walletCorrelationId);
    }
    return map;
  }

  WalletMutationsCompanion toCompanion(bool nullToAbsent) {
    return WalletMutationsCompanion(
      id: Value(id),
      operationKind: Value(operationKind),
      payload: Value(payload),
      state: Value(state),
      lineageKey: Value(lineageKey),
      fingerprint: Value(fingerprint),
      createdAtEpochMs: Value(createdAtEpochMs),
      updatedAtEpochMs: Value(updatedAtEpochMs),
      candidateId: candidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateId),
      operationRevision: operationRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(operationRevision),
      lineageGeneration: lineageGeneration == null && nullToAbsent
          ? const Value.absent()
          : Value(lineageGeneration),
      payloadJsonCiphertext: payloadJsonCiphertext == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJsonCiphertext),
      sourceMarker: sourceMarker == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMarker),
      attemptCount: attemptCount == null && nullToAbsent
          ? const Value.absent()
          : Value(attemptCount),
      nextAttemptAtEpochMs: nextAttemptAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAtEpochMs),
      leaseUntilEpochMs: leaseUntilEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseUntilEpochMs),
      lastHttpStatus: lastHttpStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHttpStatus),
      walletCorrelationId: walletCorrelationId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletCorrelationId),
    );
  }

  factory WalletMutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletMutation(
      id: serializer.fromJson<String>(json['id']),
      operationKind: $WalletMutationsTable.$converteroperationKind.fromJson(
        serializer.fromJson<String>(json['operationKind']),
      ),
      payload: serializer.fromJson<String>(json['payload']),
      state: serializer.fromJson<WalletMutationState>(json['state']),
      lineageKey: serializer.fromJson<String>(json['lineageKey']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
      updatedAtEpochMs: serializer.fromJson<int>(json['updatedAtEpochMs']),
      candidateId: serializer.fromJson<String?>(json['candidateId']),
      operationRevision: serializer.fromJson<int?>(json['operationRevision']),
      lineageGeneration: serializer.fromJson<int?>(json['lineageGeneration']),
      payloadJsonCiphertext: serializer.fromJson<String?>(
        json['payloadJsonCiphertext'],
      ),
      sourceMarker: serializer.fromJson<String?>(json['sourceMarker']),
      attemptCount: serializer.fromJson<int?>(json['attemptCount']),
      nextAttemptAtEpochMs: serializer.fromJson<int?>(
        json['nextAttemptAtEpochMs'],
      ),
      leaseUntilEpochMs: serializer.fromJson<int?>(json['leaseUntilEpochMs']),
      lastHttpStatus: serializer.fromJson<int?>(json['lastHttpStatus']),
      walletCorrelationId: serializer.fromJson<String?>(
        json['walletCorrelationId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationKind': serializer.toJson<String>(
        $WalletMutationsTable.$converteroperationKind.toJson(operationKind),
      ),
      'payload': serializer.toJson<String>(payload),
      'state': serializer.toJson<WalletMutationState>(state),
      'lineageKey': serializer.toJson<String>(lineageKey),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
      'updatedAtEpochMs': serializer.toJson<int>(updatedAtEpochMs),
      'candidateId': serializer.toJson<String?>(candidateId),
      'operationRevision': serializer.toJson<int?>(operationRevision),
      'lineageGeneration': serializer.toJson<int?>(lineageGeneration),
      'payloadJsonCiphertext': serializer.toJson<String?>(
        payloadJsonCiphertext,
      ),
      'sourceMarker': serializer.toJson<String?>(sourceMarker),
      'attemptCount': serializer.toJson<int?>(attemptCount),
      'nextAttemptAtEpochMs': serializer.toJson<int?>(nextAttemptAtEpochMs),
      'leaseUntilEpochMs': serializer.toJson<int?>(leaseUntilEpochMs),
      'lastHttpStatus': serializer.toJson<int?>(lastHttpStatus),
      'walletCorrelationId': serializer.toJson<String?>(walletCorrelationId),
    };
  }

  WalletMutation copyWith({
    String? id,
    WalletMutationOperation? operationKind,
    String? payload,
    WalletMutationState? state,
    String? lineageKey,
    String? fingerprint,
    int? createdAtEpochMs,
    int? updatedAtEpochMs,
    Value<String?> candidateId = const Value.absent(),
    Value<int?> operationRevision = const Value.absent(),
    Value<int?> lineageGeneration = const Value.absent(),
    Value<String?> payloadJsonCiphertext = const Value.absent(),
    Value<String?> sourceMarker = const Value.absent(),
    Value<int?> attemptCount = const Value.absent(),
    Value<int?> nextAttemptAtEpochMs = const Value.absent(),
    Value<int?> leaseUntilEpochMs = const Value.absent(),
    Value<int?> lastHttpStatus = const Value.absent(),
    Value<String?> walletCorrelationId = const Value.absent(),
  }) => WalletMutation(
    id: id ?? this.id,
    operationKind: operationKind ?? this.operationKind,
    payload: payload ?? this.payload,
    state: state ?? this.state,
    lineageKey: lineageKey ?? this.lineageKey,
    fingerprint: fingerprint ?? this.fingerprint,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
    candidateId: candidateId.present ? candidateId.value : this.candidateId,
    operationRevision: operationRevision.present
        ? operationRevision.value
        : this.operationRevision,
    lineageGeneration: lineageGeneration.present
        ? lineageGeneration.value
        : this.lineageGeneration,
    payloadJsonCiphertext: payloadJsonCiphertext.present
        ? payloadJsonCiphertext.value
        : this.payloadJsonCiphertext,
    sourceMarker: sourceMarker.present ? sourceMarker.value : this.sourceMarker,
    attemptCount: attemptCount.present ? attemptCount.value : this.attemptCount,
    nextAttemptAtEpochMs: nextAttemptAtEpochMs.present
        ? nextAttemptAtEpochMs.value
        : this.nextAttemptAtEpochMs,
    leaseUntilEpochMs: leaseUntilEpochMs.present
        ? leaseUntilEpochMs.value
        : this.leaseUntilEpochMs,
    lastHttpStatus: lastHttpStatus.present
        ? lastHttpStatus.value
        : this.lastHttpStatus,
    walletCorrelationId: walletCorrelationId.present
        ? walletCorrelationId.value
        : this.walletCorrelationId,
  );
  WalletMutation copyWithCompanion(WalletMutationsCompanion data) {
    return WalletMutation(
      id: data.id.present ? data.id.value : this.id,
      operationKind: data.operationKind.present
          ? data.operationKind.value
          : this.operationKind,
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
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      operationRevision: data.operationRevision.present
          ? data.operationRevision.value
          : this.operationRevision,
      lineageGeneration: data.lineageGeneration.present
          ? data.lineageGeneration.value
          : this.lineageGeneration,
      payloadJsonCiphertext: data.payloadJsonCiphertext.present
          ? data.payloadJsonCiphertext.value
          : this.payloadJsonCiphertext,
      sourceMarker: data.sourceMarker.present
          ? data.sourceMarker.value
          : this.sourceMarker,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAtEpochMs: data.nextAttemptAtEpochMs.present
          ? data.nextAttemptAtEpochMs.value
          : this.nextAttemptAtEpochMs,
      leaseUntilEpochMs: data.leaseUntilEpochMs.present
          ? data.leaseUntilEpochMs.value
          : this.leaseUntilEpochMs,
      lastHttpStatus: data.lastHttpStatus.present
          ? data.lastHttpStatus.value
          : this.lastHttpStatus,
      walletCorrelationId: data.walletCorrelationId.present
          ? data.walletCorrelationId.value
          : this.walletCorrelationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletMutation(')
          ..write('id: $id, ')
          ..write('operationKind: $operationKind, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('lineageKey: $lineageKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('candidateId: $candidateId, ')
          ..write('operationRevision: $operationRevision, ')
          ..write('lineageGeneration: $lineageGeneration, ')
          ..write('payloadJsonCiphertext: $payloadJsonCiphertext, ')
          ..write('sourceMarker: $sourceMarker, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAtEpochMs: $nextAttemptAtEpochMs, ')
          ..write('leaseUntilEpochMs: $leaseUntilEpochMs, ')
          ..write('lastHttpStatus: $lastHttpStatus, ')
          ..write('walletCorrelationId: $walletCorrelationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationKind,
    payload,
    state,
    lineageKey,
    fingerprint,
    createdAtEpochMs,
    updatedAtEpochMs,
    candidateId,
    operationRevision,
    lineageGeneration,
    payloadJsonCiphertext,
    sourceMarker,
    attemptCount,
    nextAttemptAtEpochMs,
    leaseUntilEpochMs,
    lastHttpStatus,
    walletCorrelationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletMutation &&
          other.id == this.id &&
          other.operationKind == this.operationKind &&
          other.payload == this.payload &&
          other.state == this.state &&
          other.lineageKey == this.lineageKey &&
          other.fingerprint == this.fingerprint &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.updatedAtEpochMs == this.updatedAtEpochMs &&
          other.candidateId == this.candidateId &&
          other.operationRevision == this.operationRevision &&
          other.lineageGeneration == this.lineageGeneration &&
          other.payloadJsonCiphertext == this.payloadJsonCiphertext &&
          other.sourceMarker == this.sourceMarker &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAtEpochMs == this.nextAttemptAtEpochMs &&
          other.leaseUntilEpochMs == this.leaseUntilEpochMs &&
          other.lastHttpStatus == this.lastHttpStatus &&
          other.walletCorrelationId == this.walletCorrelationId);
}

class WalletMutationsCompanion extends UpdateCompanion<WalletMutation> {
  final Value<String> id;
  final Value<WalletMutationOperation> operationKind;
  final Value<String> payload;
  final Value<WalletMutationState> state;
  final Value<String> lineageKey;
  final Value<String> fingerprint;
  final Value<int> createdAtEpochMs;
  final Value<int> updatedAtEpochMs;
  final Value<String?> candidateId;
  final Value<int?> operationRevision;
  final Value<int?> lineageGeneration;
  final Value<String?> payloadJsonCiphertext;
  final Value<String?> sourceMarker;
  final Value<int?> attemptCount;
  final Value<int?> nextAttemptAtEpochMs;
  final Value<int?> leaseUntilEpochMs;
  final Value<int?> lastHttpStatus;
  final Value<String?> walletCorrelationId;
  final Value<int> rowid;
  const WalletMutationsCompanion({
    this.id = const Value.absent(),
    this.operationKind = const Value.absent(),
    this.payload = const Value.absent(),
    this.state = const Value.absent(),
    this.lineageKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.operationRevision = const Value.absent(),
    this.lineageGeneration = const Value.absent(),
    this.payloadJsonCiphertext = const Value.absent(),
    this.sourceMarker = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAtEpochMs = const Value.absent(),
    this.leaseUntilEpochMs = const Value.absent(),
    this.lastHttpStatus = const Value.absent(),
    this.walletCorrelationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletMutationsCompanion.insert({
    required String id,
    required WalletMutationOperation operationKind,
    required String payload,
    required WalletMutationState state,
    required String lineageKey,
    required String fingerprint,
    required int createdAtEpochMs,
    required int updatedAtEpochMs,
    this.candidateId = const Value.absent(),
    this.operationRevision = const Value.absent(),
    this.lineageGeneration = const Value.absent(),
    this.payloadJsonCiphertext = const Value.absent(),
    this.sourceMarker = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAtEpochMs = const Value.absent(),
    this.leaseUntilEpochMs = const Value.absent(),
    this.lastHttpStatus = const Value.absent(),
    this.walletCorrelationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationKind = Value(operationKind),
       payload = Value(payload),
       state = Value(state),
       lineageKey = Value(lineageKey),
       fingerprint = Value(fingerprint),
       createdAtEpochMs = Value(createdAtEpochMs),
       updatedAtEpochMs = Value(updatedAtEpochMs);
  static Insertable<WalletMutation> custom({
    Expression<String>? id,
    Expression<String>? operationKind,
    Expression<String>? payload,
    Expression<String>? state,
    Expression<String>? lineageKey,
    Expression<String>? fingerprint,
    Expression<int>? createdAtEpochMs,
    Expression<int>? updatedAtEpochMs,
    Expression<String>? candidateId,
    Expression<int>? operationRevision,
    Expression<int>? lineageGeneration,
    Expression<String>? payloadJsonCiphertext,
    Expression<String>? sourceMarker,
    Expression<int>? attemptCount,
    Expression<int>? nextAttemptAtEpochMs,
    Expression<int>? leaseUntilEpochMs,
    Expression<int>? lastHttpStatus,
    Expression<String>? walletCorrelationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationKind != null) 'operation_kind': operationKind,
      if (payload != null) 'payload': payload,
      if (state != null) 'state': state,
      if (lineageKey != null) 'lineage_key': lineageKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (updatedAtEpochMs != null) 'updated_at_epoch_ms': updatedAtEpochMs,
      if (candidateId != null) 'candidate_id': candidateId,
      if (operationRevision != null) 'operation_revision': operationRevision,
      if (lineageGeneration != null) 'lineage_generation': lineageGeneration,
      if (payloadJsonCiphertext != null)
        'payload_json_ciphertext': payloadJsonCiphertext,
      if (sourceMarker != null) 'source_marker': sourceMarker,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAtEpochMs != null)
        'next_attempt_at_epoch_ms': nextAttemptAtEpochMs,
      if (leaseUntilEpochMs != null) 'lease_until_epoch_ms': leaseUntilEpochMs,
      if (lastHttpStatus != null) 'last_http_status': lastHttpStatus,
      if (walletCorrelationId != null)
        'wallet_correlation_id': walletCorrelationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletMutationsCompanion copyWith({
    Value<String>? id,
    Value<WalletMutationOperation>? operationKind,
    Value<String>? payload,
    Value<WalletMutationState>? state,
    Value<String>? lineageKey,
    Value<String>? fingerprint,
    Value<int>? createdAtEpochMs,
    Value<int>? updatedAtEpochMs,
    Value<String?>? candidateId,
    Value<int?>? operationRevision,
    Value<int?>? lineageGeneration,
    Value<String?>? payloadJsonCiphertext,
    Value<String?>? sourceMarker,
    Value<int?>? attemptCount,
    Value<int?>? nextAttemptAtEpochMs,
    Value<int?>? leaseUntilEpochMs,
    Value<int?>? lastHttpStatus,
    Value<String?>? walletCorrelationId,
    Value<int>? rowid,
  }) {
    return WalletMutationsCompanion(
      id: id ?? this.id,
      operationKind: operationKind ?? this.operationKind,
      payload: payload ?? this.payload,
      state: state ?? this.state,
      lineageKey: lineageKey ?? this.lineageKey,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      candidateId: candidateId ?? this.candidateId,
      operationRevision: operationRevision ?? this.operationRevision,
      lineageGeneration: lineageGeneration ?? this.lineageGeneration,
      payloadJsonCiphertext:
          payloadJsonCiphertext ?? this.payloadJsonCiphertext,
      sourceMarker: sourceMarker ?? this.sourceMarker,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAtEpochMs: nextAttemptAtEpochMs ?? this.nextAttemptAtEpochMs,
      leaseUntilEpochMs: leaseUntilEpochMs ?? this.leaseUntilEpochMs,
      lastHttpStatus: lastHttpStatus ?? this.lastHttpStatus,
      walletCorrelationId: walletCorrelationId ?? this.walletCorrelationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationKind.present) {
      map['operation_kind'] = Variable<String>(
        $WalletMutationsTable.$converteroperationKind.toSql(
          operationKind.value,
        ),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $WalletMutationsTable.$converterstate.toSql(state.value),
      );
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
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (operationRevision.present) {
      map['operation_revision'] = Variable<int>(operationRevision.value);
    }
    if (lineageGeneration.present) {
      map['lineage_generation'] = Variable<int>(lineageGeneration.value);
    }
    if (payloadJsonCiphertext.present) {
      map['payload_json_ciphertext'] = Variable<String>(
        payloadJsonCiphertext.value,
      );
    }
    if (sourceMarker.present) {
      map['source_marker'] = Variable<String>(sourceMarker.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAtEpochMs.present) {
      map['next_attempt_at_epoch_ms'] = Variable<int>(
        nextAttemptAtEpochMs.value,
      );
    }
    if (leaseUntilEpochMs.present) {
      map['lease_until_epoch_ms'] = Variable<int>(leaseUntilEpochMs.value);
    }
    if (lastHttpStatus.present) {
      map['last_http_status'] = Variable<int>(lastHttpStatus.value);
    }
    if (walletCorrelationId.present) {
      map['wallet_correlation_id'] = Variable<String>(
        walletCorrelationId.value,
      );
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
          ..write('operationKind: $operationKind, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('lineageKey: $lineageKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('candidateId: $candidateId, ')
          ..write('operationRevision: $operationRevision, ')
          ..write('lineageGeneration: $lineageGeneration, ')
          ..write('payloadJsonCiphertext: $payloadJsonCiphertext, ')
          ..write('sourceMarker: $sourceMarker, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAtEpochMs: $nextAttemptAtEpochMs, ')
          ..write('leaseUntilEpochMs: $leaseUntilEpochMs, ')
          ..write('lastHttpStatus: $lastHttpStatus, ')
          ..write('walletCorrelationId: $walletCorrelationId, ')
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
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
    'candidate_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WalletItemLegRole?, String>
  legRole =
      GeneratedColumn<String>(
        'leg_role',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<WalletItemLegRole?>(
        $WalletRecordLinksTable.$converterlegRolen,
      );
  static const VerificationMeta _pairGroupIdMeta = const VerificationMeta(
    'pairGroupId',
  );
  @override
  late final GeneratedColumn<String> pairGroupId = GeneratedColumn<String>(
    'pair_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastKnownRevisionMeta = const VerificationMeta(
    'lastKnownRevision',
  );
  @override
  late final GeneratedColumn<int> lastKnownRevision = GeneratedColumn<int>(
    'last_known_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastKnownStateMeta = const VerificationMeta(
    'lastKnownState',
  );
  @override
  late final GeneratedColumn<String> lastKnownState = GeneratedColumn<String>(
    'last_known_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtEpochMsMeta = const VerificationMeta(
    'updatedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtEpochMs = GeneratedColumn<int>(
    'updated_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtEpochMsMeta = const VerificationMeta(
    'deletedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtEpochMs = GeneratedColumn<int>(
    'deleted_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteDeletedTombstoneMeta =
      const VerificationMeta('remoteDeletedTombstone');
  @override
  late final GeneratedColumn<bool> remoteDeletedTombstone =
      GeneratedColumn<bool>(
        'remote_deleted_tombstone',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("remote_deleted_tombstone" IN (0, 1))',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appId,
    remoteId,
    createdAtEpochMs,
    candidateId,
    legRole,
    pairGroupId,
    lastKnownRevision,
    lastKnownState,
    updatedAtEpochMs,
    deletedAtEpochMs,
    remoteDeletedTombstone,
  ];
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
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    }
    if (data.containsKey('pair_group_id')) {
      context.handle(
        _pairGroupIdMeta,
        pairGroupId.isAcceptableOrUnknown(
          data['pair_group_id']!,
          _pairGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('last_known_revision')) {
      context.handle(
        _lastKnownRevisionMeta,
        lastKnownRevision.isAcceptableOrUnknown(
          data['last_known_revision']!,
          _lastKnownRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_known_state')) {
      context.handle(
        _lastKnownStateMeta,
        lastKnownState.isAcceptableOrUnknown(
          data['last_known_state']!,
          _lastKnownStateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_epoch_ms')) {
      context.handle(
        _updatedAtEpochMsMeta,
        updatedAtEpochMs.isAcceptableOrUnknown(
          data['updated_at_epoch_ms']!,
          _updatedAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_epoch_ms')) {
      context.handle(
        _deletedAtEpochMsMeta,
        deletedAtEpochMs.isAcceptableOrUnknown(
          data['deleted_at_epoch_ms']!,
          _deletedAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('remote_deleted_tombstone')) {
      context.handle(
        _remoteDeletedTombstoneMeta,
        remoteDeletedTombstone.isAcceptableOrUnknown(
          data['remote_deleted_tombstone']!,
          _remoteDeletedTombstoneMeta,
        ),
      );
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
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      ),
      legRole: $WalletRecordLinksTable.$converterlegRolen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}leg_role'],
        ),
      ),
      pairGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pair_group_id'],
      ),
      lastKnownRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_known_revision'],
      ),
      lastKnownState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_known_state'],
      ),
      updatedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_epoch_ms'],
      ),
      deletedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_epoch_ms'],
      ),
      remoteDeletedTombstone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remote_deleted_tombstone'],
      ),
    );
  }

  @override
  $WalletRecordLinksTable createAlias(String alias) {
    return $WalletRecordLinksTable(attachedDatabase, alias);
  }

  static TypeConverter<WalletItemLegRole, String> $converterlegRole =
      const WalletItemLegRoleConverter();
  static TypeConverter<WalletItemLegRole?, String?> $converterlegRolen =
      NullAwareTypeConverter.wrap($converterlegRole);
}

class WalletRecordLink extends DataClass
    implements Insertable<WalletRecordLink> {
  final String id;
  final String appId;
  final String? remoteId;
  final int createdAtEpochMs;
  final String? candidateId;
  final WalletItemLegRole? legRole;
  final String? pairGroupId;
  final int? lastKnownRevision;
  final String? lastKnownState;
  final int? updatedAtEpochMs;
  final int? deletedAtEpochMs;
  final bool? remoteDeletedTombstone;
  const WalletRecordLink({
    required this.id,
    required this.appId,
    this.remoteId,
    required this.createdAtEpochMs,
    this.candidateId,
    this.legRole,
    this.pairGroupId,
    this.lastKnownRevision,
    this.lastKnownState,
    this.updatedAtEpochMs,
    this.deletedAtEpochMs,
    this.remoteDeletedTombstone,
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
    if (!nullToAbsent || candidateId != null) {
      map['candidate_id'] = Variable<String>(candidateId);
    }
    if (!nullToAbsent || legRole != null) {
      map['leg_role'] = Variable<String>(
        $WalletRecordLinksTable.$converterlegRolen.toSql(legRole),
      );
    }
    if (!nullToAbsent || pairGroupId != null) {
      map['pair_group_id'] = Variable<String>(pairGroupId);
    }
    if (!nullToAbsent || lastKnownRevision != null) {
      map['last_known_revision'] = Variable<int>(lastKnownRevision);
    }
    if (!nullToAbsent || lastKnownState != null) {
      map['last_known_state'] = Variable<String>(lastKnownState);
    }
    if (!nullToAbsent || updatedAtEpochMs != null) {
      map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs);
    }
    if (!nullToAbsent || deletedAtEpochMs != null) {
      map['deleted_at_epoch_ms'] = Variable<int>(deletedAtEpochMs);
    }
    if (!nullToAbsent || remoteDeletedTombstone != null) {
      map['remote_deleted_tombstone'] = Variable<bool>(remoteDeletedTombstone);
    }
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
      candidateId: candidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateId),
      legRole: legRole == null && nullToAbsent
          ? const Value.absent()
          : Value(legRole),
      pairGroupId: pairGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairGroupId),
      lastKnownRevision: lastKnownRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKnownRevision),
      lastKnownState: lastKnownState == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKnownState),
      updatedAtEpochMs: updatedAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtEpochMs),
      deletedAtEpochMs: deletedAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtEpochMs),
      remoteDeletedTombstone: remoteDeletedTombstone == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteDeletedTombstone),
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
      candidateId: serializer.fromJson<String?>(json['candidateId']),
      legRole: serializer.fromJson<WalletItemLegRole?>(json['legRole']),
      pairGroupId: serializer.fromJson<String?>(json['pairGroupId']),
      lastKnownRevision: serializer.fromJson<int?>(json['lastKnownRevision']),
      lastKnownState: serializer.fromJson<String?>(json['lastKnownState']),
      updatedAtEpochMs: serializer.fromJson<int?>(json['updatedAtEpochMs']),
      deletedAtEpochMs: serializer.fromJson<int?>(json['deletedAtEpochMs']),
      remoteDeletedTombstone: serializer.fromJson<bool?>(
        json['remoteDeletedTombstone'],
      ),
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
      'candidateId': serializer.toJson<String?>(candidateId),
      'legRole': serializer.toJson<WalletItemLegRole?>(legRole),
      'pairGroupId': serializer.toJson<String?>(pairGroupId),
      'lastKnownRevision': serializer.toJson<int?>(lastKnownRevision),
      'lastKnownState': serializer.toJson<String?>(lastKnownState),
      'updatedAtEpochMs': serializer.toJson<int?>(updatedAtEpochMs),
      'deletedAtEpochMs': serializer.toJson<int?>(deletedAtEpochMs),
      'remoteDeletedTombstone': serializer.toJson<bool?>(
        remoteDeletedTombstone,
      ),
    };
  }

  WalletRecordLink copyWith({
    String? id,
    String? appId,
    Value<String?> remoteId = const Value.absent(),
    int? createdAtEpochMs,
    Value<String?> candidateId = const Value.absent(),
    Value<WalletItemLegRole?> legRole = const Value.absent(),
    Value<String?> pairGroupId = const Value.absent(),
    Value<int?> lastKnownRevision = const Value.absent(),
    Value<String?> lastKnownState = const Value.absent(),
    Value<int?> updatedAtEpochMs = const Value.absent(),
    Value<int?> deletedAtEpochMs = const Value.absent(),
    Value<bool?> remoteDeletedTombstone = const Value.absent(),
  }) => WalletRecordLink(
    id: id ?? this.id,
    appId: appId ?? this.appId,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    candidateId: candidateId.present ? candidateId.value : this.candidateId,
    legRole: legRole.present ? legRole.value : this.legRole,
    pairGroupId: pairGroupId.present ? pairGroupId.value : this.pairGroupId,
    lastKnownRevision: lastKnownRevision.present
        ? lastKnownRevision.value
        : this.lastKnownRevision,
    lastKnownState: lastKnownState.present
        ? lastKnownState.value
        : this.lastKnownState,
    updatedAtEpochMs: updatedAtEpochMs.present
        ? updatedAtEpochMs.value
        : this.updatedAtEpochMs,
    deletedAtEpochMs: deletedAtEpochMs.present
        ? deletedAtEpochMs.value
        : this.deletedAtEpochMs,
    remoteDeletedTombstone: remoteDeletedTombstone.present
        ? remoteDeletedTombstone.value
        : this.remoteDeletedTombstone,
  );
  WalletRecordLink copyWithCompanion(WalletRecordLinksCompanion data) {
    return WalletRecordLink(
      id: data.id.present ? data.id.value : this.id,
      appId: data.appId.present ? data.appId.value : this.appId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      legRole: data.legRole.present ? data.legRole.value : this.legRole,
      pairGroupId: data.pairGroupId.present
          ? data.pairGroupId.value
          : this.pairGroupId,
      lastKnownRevision: data.lastKnownRevision.present
          ? data.lastKnownRevision.value
          : this.lastKnownRevision,
      lastKnownState: data.lastKnownState.present
          ? data.lastKnownState.value
          : this.lastKnownState,
      updatedAtEpochMs: data.updatedAtEpochMs.present
          ? data.updatedAtEpochMs.value
          : this.updatedAtEpochMs,
      deletedAtEpochMs: data.deletedAtEpochMs.present
          ? data.deletedAtEpochMs.value
          : this.deletedAtEpochMs,
      remoteDeletedTombstone: data.remoteDeletedTombstone.present
          ? data.remoteDeletedTombstone.value
          : this.remoteDeletedTombstone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletRecordLink(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('candidateId: $candidateId, ')
          ..write('legRole: $legRole, ')
          ..write('pairGroupId: $pairGroupId, ')
          ..write('lastKnownRevision: $lastKnownRevision, ')
          ..write('lastKnownState: $lastKnownState, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('deletedAtEpochMs: $deletedAtEpochMs, ')
          ..write('remoteDeletedTombstone: $remoteDeletedTombstone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    appId,
    remoteId,
    createdAtEpochMs,
    candidateId,
    legRole,
    pairGroupId,
    lastKnownRevision,
    lastKnownState,
    updatedAtEpochMs,
    deletedAtEpochMs,
    remoteDeletedTombstone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletRecordLink &&
          other.id == this.id &&
          other.appId == this.appId &&
          other.remoteId == this.remoteId &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.candidateId == this.candidateId &&
          other.legRole == this.legRole &&
          other.pairGroupId == this.pairGroupId &&
          other.lastKnownRevision == this.lastKnownRevision &&
          other.lastKnownState == this.lastKnownState &&
          other.updatedAtEpochMs == this.updatedAtEpochMs &&
          other.deletedAtEpochMs == this.deletedAtEpochMs &&
          other.remoteDeletedTombstone == this.remoteDeletedTombstone);
}

class WalletRecordLinksCompanion extends UpdateCompanion<WalletRecordLink> {
  final Value<String> id;
  final Value<String> appId;
  final Value<String?> remoteId;
  final Value<int> createdAtEpochMs;
  final Value<String?> candidateId;
  final Value<WalletItemLegRole?> legRole;
  final Value<String?> pairGroupId;
  final Value<int?> lastKnownRevision;
  final Value<String?> lastKnownState;
  final Value<int?> updatedAtEpochMs;
  final Value<int?> deletedAtEpochMs;
  final Value<bool?> remoteDeletedTombstone;
  final Value<int> rowid;
  const WalletRecordLinksCompanion({
    this.id = const Value.absent(),
    this.appId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.legRole = const Value.absent(),
    this.pairGroupId = const Value.absent(),
    this.lastKnownRevision = const Value.absent(),
    this.lastKnownState = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.deletedAtEpochMs = const Value.absent(),
    this.remoteDeletedTombstone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletRecordLinksCompanion.insert({
    required String id,
    required String appId,
    this.remoteId = const Value.absent(),
    required int createdAtEpochMs,
    this.candidateId = const Value.absent(),
    this.legRole = const Value.absent(),
    this.pairGroupId = const Value.absent(),
    this.lastKnownRevision = const Value.absent(),
    this.lastKnownState = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.deletedAtEpochMs = const Value.absent(),
    this.remoteDeletedTombstone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       appId = Value(appId),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<WalletRecordLink> custom({
    Expression<String>? id,
    Expression<String>? appId,
    Expression<String>? remoteId,
    Expression<int>? createdAtEpochMs,
    Expression<String>? candidateId,
    Expression<String>? legRole,
    Expression<String>? pairGroupId,
    Expression<int>? lastKnownRevision,
    Expression<String>? lastKnownState,
    Expression<int>? updatedAtEpochMs,
    Expression<int>? deletedAtEpochMs,
    Expression<bool>? remoteDeletedTombstone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (remoteId != null) 'remote_id': remoteId,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (candidateId != null) 'candidate_id': candidateId,
      if (legRole != null) 'leg_role': legRole,
      if (pairGroupId != null) 'pair_group_id': pairGroupId,
      if (lastKnownRevision != null) 'last_known_revision': lastKnownRevision,
      if (lastKnownState != null) 'last_known_state': lastKnownState,
      if (updatedAtEpochMs != null) 'updated_at_epoch_ms': updatedAtEpochMs,
      if (deletedAtEpochMs != null) 'deleted_at_epoch_ms': deletedAtEpochMs,
      if (remoteDeletedTombstone != null)
        'remote_deleted_tombstone': remoteDeletedTombstone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletRecordLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? appId,
    Value<String?>? remoteId,
    Value<int>? createdAtEpochMs,
    Value<String?>? candidateId,
    Value<WalletItemLegRole?>? legRole,
    Value<String?>? pairGroupId,
    Value<int?>? lastKnownRevision,
    Value<String?>? lastKnownState,
    Value<int?>? updatedAtEpochMs,
    Value<int?>? deletedAtEpochMs,
    Value<bool?>? remoteDeletedTombstone,
    Value<int>? rowid,
  }) {
    return WalletRecordLinksCompanion(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      remoteId: remoteId ?? this.remoteId,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      candidateId: candidateId ?? this.candidateId,
      legRole: legRole ?? this.legRole,
      pairGroupId: pairGroupId ?? this.pairGroupId,
      lastKnownRevision: lastKnownRevision ?? this.lastKnownRevision,
      lastKnownState: lastKnownState ?? this.lastKnownState,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      deletedAtEpochMs: deletedAtEpochMs ?? this.deletedAtEpochMs,
      remoteDeletedTombstone:
          remoteDeletedTombstone ?? this.remoteDeletedTombstone,
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
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (legRole.present) {
      map['leg_role'] = Variable<String>(
        $WalletRecordLinksTable.$converterlegRolen.toSql(legRole.value),
      );
    }
    if (pairGroupId.present) {
      map['pair_group_id'] = Variable<String>(pairGroupId.value);
    }
    if (lastKnownRevision.present) {
      map['last_known_revision'] = Variable<int>(lastKnownRevision.value);
    }
    if (lastKnownState.present) {
      map['last_known_state'] = Variable<String>(lastKnownState.value);
    }
    if (updatedAtEpochMs.present) {
      map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs.value);
    }
    if (deletedAtEpochMs.present) {
      map['deleted_at_epoch_ms'] = Variable<int>(deletedAtEpochMs.value);
    }
    if (remoteDeletedTombstone.present) {
      map['remote_deleted_tombstone'] = Variable<bool>(
        remoteDeletedTombstone.value,
      );
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
          ..write('candidateId: $candidateId, ')
          ..write('legRole: $legRole, ')
          ..write('pairGroupId: $pairGroupId, ')
          ..write('lastKnownRevision: $lastKnownRevision, ')
          ..write('lastKnownState: $lastKnownState, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('deletedAtEpochMs: $deletedAtEpochMs, ')
          ..write('remoteDeletedTombstone: $remoteDeletedTombstone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MappingRulesTable extends MappingRules
    with TableInfo<$MappingRulesTable, MappingRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MappingRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _senderMatcherMeta = const VerificationMeta(
    'senderMatcher',
  );
  @override
  late final GeneratedColumn<String> senderMatcher = GeneratedColumn<String>(
    'sender_matcher',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parserFamilyMeta = const VerificationMeta(
    'parserFamily',
  );
  @override
  late final GeneratedColumn<String> parserFamily = GeneratedColumn<String>(
    'parser_family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instrumentSuffixHashMeta =
      const VerificationMeta('instrumentSuffixHash');
  @override
  late final GeneratedColumn<String> instrumentSuffixHash =
      GeneratedColumn<String>(
        'instrument_suffix_hash',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionDirection?, String>
  direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TransactionDirection?>(
        $MappingRulesTable.$converterdirectionn,
      );
  static const VerificationMeta _merchantMatcherMeta = const VerificationMeta(
    'merchantMatcher',
  );
  @override
  late final GeneratedColumn<String> merchantMatcher = GeneratedColumn<String>(
    'merchant_matcher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletAccountIdMeta = const VerificationMeta(
    'walletAccountId',
  );
  @override
  late final GeneratedColumn<String> walletAccountId = GeneratedColumn<String>(
    'wallet_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletCategoryIdMeta = const VerificationMeta(
    'walletCategoryId',
  );
  @override
  late final GeneratedColumn<String> walletCategoryId = GeneratedColumn<String>(
    'wallet_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MappingSyncMode, String>
  syncMode = GeneratedColumn<String>(
    'sync_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MappingSyncMode>($MappingRulesTable.$convertersyncMode);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minConfidenceBasisPointsMeta =
      const VerificationMeta('minConfidenceBasisPoints');
  @override
  late final GeneratedColumn<int> minConfidenceBasisPoints =
      GeneratedColumn<int>(
        'min_confidence_basis_points',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<int> ruleVersion = GeneratedColumn<int>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersededByRuleIdMeta =
      const VerificationMeta('supersededByRuleId');
  @override
  late final GeneratedColumn<String> supersededByRuleId =
      GeneratedColumn<String>(
        'superseded_by_rule_id',
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
    name,
    enabled,
    senderMatcher,
    parserFamily,
    instrumentSuffixHash,
    direction,
    merchantMatcher,
    walletAccountId,
    walletCategoryId,
    paymentType,
    syncMode,
    priority,
    minConfidenceBasisPoints,
    ruleVersion,
    supersededByRuleId,
    createdAtEpochMs,
    updatedAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mapping_rule';
  @override
  VerificationContext validateIntegrity(
    Insertable<MappingRuleRow> instance, {
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
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('sender_matcher')) {
      context.handle(
        _senderMatcherMeta,
        senderMatcher.isAcceptableOrUnknown(
          data['sender_matcher']!,
          _senderMatcherMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderMatcherMeta);
    }
    if (data.containsKey('parser_family')) {
      context.handle(
        _parserFamilyMeta,
        parserFamily.isAcceptableOrUnknown(
          data['parser_family']!,
          _parserFamilyMeta,
        ),
      );
    }
    if (data.containsKey('instrument_suffix_hash')) {
      context.handle(
        _instrumentSuffixHashMeta,
        instrumentSuffixHash.isAcceptableOrUnknown(
          data['instrument_suffix_hash']!,
          _instrumentSuffixHashMeta,
        ),
      );
    }
    if (data.containsKey('merchant_matcher')) {
      context.handle(
        _merchantMatcherMeta,
        merchantMatcher.isAcceptableOrUnknown(
          data['merchant_matcher']!,
          _merchantMatcherMeta,
        ),
      );
    }
    if (data.containsKey('wallet_account_id')) {
      context.handle(
        _walletAccountIdMeta,
        walletAccountId.isAcceptableOrUnknown(
          data['wallet_account_id']!,
          _walletAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_walletAccountIdMeta);
    }
    if (data.containsKey('wallet_category_id')) {
      context.handle(
        _walletCategoryIdMeta,
        walletCategoryId.isAcceptableOrUnknown(
          data['wallet_category_id']!,
          _walletCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('min_confidence_basis_points')) {
      context.handle(
        _minConfidenceBasisPointsMeta,
        minConfidenceBasisPoints.isAcceptableOrUnknown(
          data['min_confidence_basis_points']!,
          _minConfidenceBasisPointsMeta,
        ),
      );
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('superseded_by_rule_id')) {
      context.handle(
        _supersededByRuleIdMeta,
        supersededByRuleId.isAcceptableOrUnknown(
          data['superseded_by_rule_id']!,
          _supersededByRuleIdMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id, ruleVersion};
  @override
  MappingRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MappingRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      senderMatcher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_matcher'],
      )!,
      parserFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_family'],
      ),
      instrumentSuffixHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_suffix_hash'],
      ),
      direction: $MappingRulesTable.$converterdirectionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        ),
      ),
      merchantMatcher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_matcher'],
      ),
      walletAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_account_id'],
      )!,
      walletCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_category_id'],
      ),
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      )!,
      syncMode: $MappingRulesTable.$convertersyncMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_mode'],
        )!,
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      minConfidenceBasisPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_confidence_basis_points'],
      ),
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
      supersededByRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superseded_by_rule_id'],
      ),
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
  $MappingRulesTable createAlias(String alias) {
    return $MappingRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionDirection, String, String>
  $converterdirection = const EnumNameConverter<TransactionDirection>(
    TransactionDirection.values,
  );
  static JsonTypeConverter2<TransactionDirection?, String?, String?>
  $converterdirectionn = JsonTypeConverter2.asNullable($converterdirection);
  static JsonTypeConverter2<MappingSyncMode, String, String>
  $convertersyncMode = const EnumNameConverter<MappingSyncMode>(
    MappingSyncMode.values,
  );
}

class MappingRuleRow extends DataClass implements Insertable<MappingRuleRow> {
  final String id;
  final String name;
  final bool enabled;
  final String senderMatcher;
  final String? parserFamily;
  final String? instrumentSuffixHash;
  final TransactionDirection? direction;
  final String? merchantMatcher;
  final String walletAccountId;
  final String? walletCategoryId;
  final String paymentType;
  final MappingSyncMode syncMode;
  final int priority;
  final int? minConfidenceBasisPoints;
  final int ruleVersion;
  final String? supersededByRuleId;
  final int createdAtEpochMs;
  final int updatedAtEpochMs;
  const MappingRuleRow({
    required this.id,
    required this.name,
    required this.enabled,
    required this.senderMatcher,
    this.parserFamily,
    this.instrumentSuffixHash,
    this.direction,
    this.merchantMatcher,
    required this.walletAccountId,
    this.walletCategoryId,
    required this.paymentType,
    required this.syncMode,
    required this.priority,
    this.minConfidenceBasisPoints,
    required this.ruleVersion,
    this.supersededByRuleId,
    required this.createdAtEpochMs,
    required this.updatedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['enabled'] = Variable<bool>(enabled);
    map['sender_matcher'] = Variable<String>(senderMatcher);
    if (!nullToAbsent || parserFamily != null) {
      map['parser_family'] = Variable<String>(parserFamily);
    }
    if (!nullToAbsent || instrumentSuffixHash != null) {
      map['instrument_suffix_hash'] = Variable<String>(instrumentSuffixHash);
    }
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(
        $MappingRulesTable.$converterdirectionn.toSql(direction),
      );
    }
    if (!nullToAbsent || merchantMatcher != null) {
      map['merchant_matcher'] = Variable<String>(merchantMatcher);
    }
    map['wallet_account_id'] = Variable<String>(walletAccountId);
    if (!nullToAbsent || walletCategoryId != null) {
      map['wallet_category_id'] = Variable<String>(walletCategoryId);
    }
    map['payment_type'] = Variable<String>(paymentType);
    {
      map['sync_mode'] = Variable<String>(
        $MappingRulesTable.$convertersyncMode.toSql(syncMode),
      );
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || minConfidenceBasisPoints != null) {
      map['min_confidence_basis_points'] = Variable<int>(
        minConfidenceBasisPoints,
      );
    }
    map['rule_version'] = Variable<int>(ruleVersion);
    if (!nullToAbsent || supersededByRuleId != null) {
      map['superseded_by_rule_id'] = Variable<String>(supersededByRuleId);
    }
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs);
    return map;
  }

  MappingRulesCompanion toCompanion(bool nullToAbsent) {
    return MappingRulesCompanion(
      id: Value(id),
      name: Value(name),
      enabled: Value(enabled),
      senderMatcher: Value(senderMatcher),
      parserFamily: parserFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(parserFamily),
      instrumentSuffixHash: instrumentSuffixHash == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentSuffixHash),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      merchantMatcher: merchantMatcher == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantMatcher),
      walletAccountId: Value(walletAccountId),
      walletCategoryId: walletCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletCategoryId),
      paymentType: Value(paymentType),
      syncMode: Value(syncMode),
      priority: Value(priority),
      minConfidenceBasisPoints: minConfidenceBasisPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(minConfidenceBasisPoints),
      ruleVersion: Value(ruleVersion),
      supersededByRuleId: supersededByRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededByRuleId),
      createdAtEpochMs: Value(createdAtEpochMs),
      updatedAtEpochMs: Value(updatedAtEpochMs),
    );
  }

  factory MappingRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MappingRuleRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      senderMatcher: serializer.fromJson<String>(json['senderMatcher']),
      parserFamily: serializer.fromJson<String?>(json['parserFamily']),
      instrumentSuffixHash: serializer.fromJson<String?>(
        json['instrumentSuffixHash'],
      ),
      direction: $MappingRulesTable.$converterdirectionn.fromJson(
        serializer.fromJson<String?>(json['direction']),
      ),
      merchantMatcher: serializer.fromJson<String?>(json['merchantMatcher']),
      walletAccountId: serializer.fromJson<String>(json['walletAccountId']),
      walletCategoryId: serializer.fromJson<String?>(json['walletCategoryId']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      syncMode: $MappingRulesTable.$convertersyncMode.fromJson(
        serializer.fromJson<String>(json['syncMode']),
      ),
      priority: serializer.fromJson<int>(json['priority']),
      minConfidenceBasisPoints: serializer.fromJson<int?>(
        json['minConfidenceBasisPoints'],
      ),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
      supersededByRuleId: serializer.fromJson<String?>(
        json['supersededByRuleId'],
      ),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
      updatedAtEpochMs: serializer.fromJson<int>(json['updatedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'enabled': serializer.toJson<bool>(enabled),
      'senderMatcher': serializer.toJson<String>(senderMatcher),
      'parserFamily': serializer.toJson<String?>(parserFamily),
      'instrumentSuffixHash': serializer.toJson<String?>(instrumentSuffixHash),
      'direction': serializer.toJson<String?>(
        $MappingRulesTable.$converterdirectionn.toJson(direction),
      ),
      'merchantMatcher': serializer.toJson<String?>(merchantMatcher),
      'walletAccountId': serializer.toJson<String>(walletAccountId),
      'walletCategoryId': serializer.toJson<String?>(walletCategoryId),
      'paymentType': serializer.toJson<String>(paymentType),
      'syncMode': serializer.toJson<String>(
        $MappingRulesTable.$convertersyncMode.toJson(syncMode),
      ),
      'priority': serializer.toJson<int>(priority),
      'minConfidenceBasisPoints': serializer.toJson<int?>(
        minConfidenceBasisPoints,
      ),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
      'supersededByRuleId': serializer.toJson<String?>(supersededByRuleId),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
      'updatedAtEpochMs': serializer.toJson<int>(updatedAtEpochMs),
    };
  }

  MappingRuleRow copyWith({
    String? id,
    String? name,
    bool? enabled,
    String? senderMatcher,
    Value<String?> parserFamily = const Value.absent(),
    Value<String?> instrumentSuffixHash = const Value.absent(),
    Value<TransactionDirection?> direction = const Value.absent(),
    Value<String?> merchantMatcher = const Value.absent(),
    String? walletAccountId,
    Value<String?> walletCategoryId = const Value.absent(),
    String? paymentType,
    MappingSyncMode? syncMode,
    int? priority,
    Value<int?> minConfidenceBasisPoints = const Value.absent(),
    int? ruleVersion,
    Value<String?> supersededByRuleId = const Value.absent(),
    int? createdAtEpochMs,
    int? updatedAtEpochMs,
  }) => MappingRuleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    enabled: enabled ?? this.enabled,
    senderMatcher: senderMatcher ?? this.senderMatcher,
    parserFamily: parserFamily.present ? parserFamily.value : this.parserFamily,
    instrumentSuffixHash: instrumentSuffixHash.present
        ? instrumentSuffixHash.value
        : this.instrumentSuffixHash,
    direction: direction.present ? direction.value : this.direction,
    merchantMatcher: merchantMatcher.present
        ? merchantMatcher.value
        : this.merchantMatcher,
    walletAccountId: walletAccountId ?? this.walletAccountId,
    walletCategoryId: walletCategoryId.present
        ? walletCategoryId.value
        : this.walletCategoryId,
    paymentType: paymentType ?? this.paymentType,
    syncMode: syncMode ?? this.syncMode,
    priority: priority ?? this.priority,
    minConfidenceBasisPoints: minConfidenceBasisPoints.present
        ? minConfidenceBasisPoints.value
        : this.minConfidenceBasisPoints,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    supersededByRuleId: supersededByRuleId.present
        ? supersededByRuleId.value
        : this.supersededByRuleId,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
  );
  MappingRuleRow copyWithCompanion(MappingRulesCompanion data) {
    return MappingRuleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      senderMatcher: data.senderMatcher.present
          ? data.senderMatcher.value
          : this.senderMatcher,
      parserFamily: data.parserFamily.present
          ? data.parserFamily.value
          : this.parserFamily,
      instrumentSuffixHash: data.instrumentSuffixHash.present
          ? data.instrumentSuffixHash.value
          : this.instrumentSuffixHash,
      direction: data.direction.present ? data.direction.value : this.direction,
      merchantMatcher: data.merchantMatcher.present
          ? data.merchantMatcher.value
          : this.merchantMatcher,
      walletAccountId: data.walletAccountId.present
          ? data.walletAccountId.value
          : this.walletAccountId,
      walletCategoryId: data.walletCategoryId.present
          ? data.walletCategoryId.value
          : this.walletCategoryId,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      syncMode: data.syncMode.present ? data.syncMode.value : this.syncMode,
      priority: data.priority.present ? data.priority.value : this.priority,
      minConfidenceBasisPoints: data.minConfidenceBasisPoints.present
          ? data.minConfidenceBasisPoints.value
          : this.minConfidenceBasisPoints,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      supersededByRuleId: data.supersededByRuleId.present
          ? data.supersededByRuleId.value
          : this.supersededByRuleId,
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
    return (StringBuffer('MappingRuleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('senderMatcher: $senderMatcher, ')
          ..write('parserFamily: $parserFamily, ')
          ..write('instrumentSuffixHash: $instrumentSuffixHash, ')
          ..write('direction: $direction, ')
          ..write('merchantMatcher: $merchantMatcher, ')
          ..write('walletAccountId: $walletAccountId, ')
          ..write('walletCategoryId: $walletCategoryId, ')
          ..write('paymentType: $paymentType, ')
          ..write('syncMode: $syncMode, ')
          ..write('priority: $priority, ')
          ..write('minConfidenceBasisPoints: $minConfidenceBasisPoints, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('supersededByRuleId: $supersededByRuleId, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    enabled,
    senderMatcher,
    parserFamily,
    instrumentSuffixHash,
    direction,
    merchantMatcher,
    walletAccountId,
    walletCategoryId,
    paymentType,
    syncMode,
    priority,
    minConfidenceBasisPoints,
    ruleVersion,
    supersededByRuleId,
    createdAtEpochMs,
    updatedAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MappingRuleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.enabled == this.enabled &&
          other.senderMatcher == this.senderMatcher &&
          other.parserFamily == this.parserFamily &&
          other.instrumentSuffixHash == this.instrumentSuffixHash &&
          other.direction == this.direction &&
          other.merchantMatcher == this.merchantMatcher &&
          other.walletAccountId == this.walletAccountId &&
          other.walletCategoryId == this.walletCategoryId &&
          other.paymentType == this.paymentType &&
          other.syncMode == this.syncMode &&
          other.priority == this.priority &&
          other.minConfidenceBasisPoints == this.minConfidenceBasisPoints &&
          other.ruleVersion == this.ruleVersion &&
          other.supersededByRuleId == this.supersededByRuleId &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.updatedAtEpochMs == this.updatedAtEpochMs);
}

class MappingRulesCompanion extends UpdateCompanion<MappingRuleRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> enabled;
  final Value<String> senderMatcher;
  final Value<String?> parserFamily;
  final Value<String?> instrumentSuffixHash;
  final Value<TransactionDirection?> direction;
  final Value<String?> merchantMatcher;
  final Value<String> walletAccountId;
  final Value<String?> walletCategoryId;
  final Value<String> paymentType;
  final Value<MappingSyncMode> syncMode;
  final Value<int> priority;
  final Value<int?> minConfidenceBasisPoints;
  final Value<int> ruleVersion;
  final Value<String?> supersededByRuleId;
  final Value<int> createdAtEpochMs;
  final Value<int> updatedAtEpochMs;
  final Value<int> rowid;
  const MappingRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.enabled = const Value.absent(),
    this.senderMatcher = const Value.absent(),
    this.parserFamily = const Value.absent(),
    this.instrumentSuffixHash = const Value.absent(),
    this.direction = const Value.absent(),
    this.merchantMatcher = const Value.absent(),
    this.walletAccountId = const Value.absent(),
    this.walletCategoryId = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.syncMode = const Value.absent(),
    this.priority = const Value.absent(),
    this.minConfidenceBasisPoints = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.supersededByRuleId = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MappingRulesCompanion.insert({
    required String id,
    required String name,
    required bool enabled,
    required String senderMatcher,
    this.parserFamily = const Value.absent(),
    this.instrumentSuffixHash = const Value.absent(),
    this.direction = const Value.absent(),
    this.merchantMatcher = const Value.absent(),
    required String walletAccountId,
    this.walletCategoryId = const Value.absent(),
    required String paymentType,
    required MappingSyncMode syncMode,
    required int priority,
    this.minConfidenceBasisPoints = const Value.absent(),
    required int ruleVersion,
    this.supersededByRuleId = const Value.absent(),
    required int createdAtEpochMs,
    required int updatedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       enabled = Value(enabled),
       senderMatcher = Value(senderMatcher),
       walletAccountId = Value(walletAccountId),
       paymentType = Value(paymentType),
       syncMode = Value(syncMode),
       priority = Value(priority),
       ruleVersion = Value(ruleVersion),
       createdAtEpochMs = Value(createdAtEpochMs),
       updatedAtEpochMs = Value(updatedAtEpochMs);
  static Insertable<MappingRuleRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? enabled,
    Expression<String>? senderMatcher,
    Expression<String>? parserFamily,
    Expression<String>? instrumentSuffixHash,
    Expression<String>? direction,
    Expression<String>? merchantMatcher,
    Expression<String>? walletAccountId,
    Expression<String>? walletCategoryId,
    Expression<String>? paymentType,
    Expression<String>? syncMode,
    Expression<int>? priority,
    Expression<int>? minConfidenceBasisPoints,
    Expression<int>? ruleVersion,
    Expression<String>? supersededByRuleId,
    Expression<int>? createdAtEpochMs,
    Expression<int>? updatedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (enabled != null) 'enabled': enabled,
      if (senderMatcher != null) 'sender_matcher': senderMatcher,
      if (parserFamily != null) 'parser_family': parserFamily,
      if (instrumentSuffixHash != null)
        'instrument_suffix_hash': instrumentSuffixHash,
      if (direction != null) 'direction': direction,
      if (merchantMatcher != null) 'merchant_matcher': merchantMatcher,
      if (walletAccountId != null) 'wallet_account_id': walletAccountId,
      if (walletCategoryId != null) 'wallet_category_id': walletCategoryId,
      if (paymentType != null) 'payment_type': paymentType,
      if (syncMode != null) 'sync_mode': syncMode,
      if (priority != null) 'priority': priority,
      if (minConfidenceBasisPoints != null)
        'min_confidence_basis_points': minConfidenceBasisPoints,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (supersededByRuleId != null)
        'superseded_by_rule_id': supersededByRuleId,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (updatedAtEpochMs != null) 'updated_at_epoch_ms': updatedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MappingRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? enabled,
    Value<String>? senderMatcher,
    Value<String?>? parserFamily,
    Value<String?>? instrumentSuffixHash,
    Value<TransactionDirection?>? direction,
    Value<String?>? merchantMatcher,
    Value<String>? walletAccountId,
    Value<String?>? walletCategoryId,
    Value<String>? paymentType,
    Value<MappingSyncMode>? syncMode,
    Value<int>? priority,
    Value<int?>? minConfidenceBasisPoints,
    Value<int>? ruleVersion,
    Value<String?>? supersededByRuleId,
    Value<int>? createdAtEpochMs,
    Value<int>? updatedAtEpochMs,
    Value<int>? rowid,
  }) {
    return MappingRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      senderMatcher: senderMatcher ?? this.senderMatcher,
      parserFamily: parserFamily ?? this.parserFamily,
      instrumentSuffixHash: instrumentSuffixHash ?? this.instrumentSuffixHash,
      direction: direction ?? this.direction,
      merchantMatcher: merchantMatcher ?? this.merchantMatcher,
      walletAccountId: walletAccountId ?? this.walletAccountId,
      walletCategoryId: walletCategoryId ?? this.walletCategoryId,
      paymentType: paymentType ?? this.paymentType,
      syncMode: syncMode ?? this.syncMode,
      priority: priority ?? this.priority,
      minConfidenceBasisPoints:
          minConfidenceBasisPoints ?? this.minConfidenceBasisPoints,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      supersededByRuleId: supersededByRuleId ?? this.supersededByRuleId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (senderMatcher.present) {
      map['sender_matcher'] = Variable<String>(senderMatcher.value);
    }
    if (parserFamily.present) {
      map['parser_family'] = Variable<String>(parserFamily.value);
    }
    if (instrumentSuffixHash.present) {
      map['instrument_suffix_hash'] = Variable<String>(
        instrumentSuffixHash.value,
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $MappingRulesTable.$converterdirectionn.toSql(direction.value),
      );
    }
    if (merchantMatcher.present) {
      map['merchant_matcher'] = Variable<String>(merchantMatcher.value);
    }
    if (walletAccountId.present) {
      map['wallet_account_id'] = Variable<String>(walletAccountId.value);
    }
    if (walletCategoryId.present) {
      map['wallet_category_id'] = Variable<String>(walletCategoryId.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (syncMode.present) {
      map['sync_mode'] = Variable<String>(
        $MappingRulesTable.$convertersyncMode.toSql(syncMode.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (minConfidenceBasisPoints.present) {
      map['min_confidence_basis_points'] = Variable<int>(
        minConfidenceBasisPoints.value,
      );
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (supersededByRuleId.present) {
      map['superseded_by_rule_id'] = Variable<String>(supersededByRuleId.value);
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
    return (StringBuffer('MappingRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('senderMatcher: $senderMatcher, ')
          ..write('parserFamily: $parserFamily, ')
          ..write('instrumentSuffixHash: $instrumentSuffixHash, ')
          ..write('direction: $direction, ')
          ..write('merchantMatcher: $merchantMatcher, ')
          ..write('walletAccountId: $walletAccountId, ')
          ..write('walletCategoryId: $walletCategoryId, ')
          ..write('paymentType: $paymentType, ')
          ..write('syncMode: $syncMode, ')
          ..write('priority: $priority, ')
          ..write('minConfidenceBasisPoints: $minConfidenceBasisPoints, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('supersededByRuleId: $supersededByRuleId, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletMutationItemsTable extends WalletMutationItems
    with TableInfo<$WalletMutationItemsTable, WalletMutationItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletMutationItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _walletMutationIdMeta = const VerificationMeta(
    'walletMutationId',
  );
  @override
  late final GeneratedColumn<String> walletMutationId = GeneratedColumn<String>(
    'wallet_mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallet_mutations (id)',
    ),
  );
  static const VerificationMeta _itemIndexMeta = const VerificationMeta(
    'itemIndex',
  );
  @override
  late final GeneratedColumn<int> itemIndex = GeneratedColumn<int>(
    'item_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WalletItemLegRole, String>
  legRole =
      GeneratedColumn<String>(
        'leg_role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WalletItemLegRole>(
        $WalletMutationItemsTable.$converterlegRole,
      );
  static const VerificationMeta _walletRecordIdMeta = const VerificationMeta(
    'walletRecordId',
  );
  @override
  late final GeneratedColumn<String> walletRecordId = GeneratedColumn<String>(
    'wallet_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedRemoteRevisionMeta =
      const VerificationMeta('expectedRemoteRevision');
  @override
  late final GeneratedColumn<int> expectedRemoteRevision = GeneratedColumn<int>(
    'expected_remote_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadCiphertextMeta = const VerificationMeta(
    'payloadCiphertext',
  );
  @override
  late final GeneratedColumn<String> payloadCiphertext =
      GeneratedColumn<String>(
        'payload_ciphertext',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<WalletMutationState, String>
  state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WalletMutationState>(
        $WalletMutationItemsTable.$converterstate,
      );
  static const VerificationMeta _safeErrorCodeMeta = const VerificationMeta(
    'safeErrorCode',
  );
  @override
  late final GeneratedColumn<String> safeErrorCode = GeneratedColumn<String>(
    'safe_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    walletMutationId,
    itemIndex,
    legRole,
    walletRecordId,
    expectedRemoteRevision,
    payloadCiphertext,
    state,
    safeErrorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_mutation_item';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletMutationItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wallet_mutation_id')) {
      context.handle(
        _walletMutationIdMeta,
        walletMutationId.isAcceptableOrUnknown(
          data['wallet_mutation_id']!,
          _walletMutationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_walletMutationIdMeta);
    }
    if (data.containsKey('item_index')) {
      context.handle(
        _itemIndexMeta,
        itemIndex.isAcceptableOrUnknown(data['item_index']!, _itemIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIndexMeta);
    }
    if (data.containsKey('wallet_record_id')) {
      context.handle(
        _walletRecordIdMeta,
        walletRecordId.isAcceptableOrUnknown(
          data['wallet_record_id']!,
          _walletRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('expected_remote_revision')) {
      context.handle(
        _expectedRemoteRevisionMeta,
        expectedRemoteRevision.isAcceptableOrUnknown(
          data['expected_remote_revision']!,
          _expectedRemoteRevisionMeta,
        ),
      );
    }
    if (data.containsKey('payload_ciphertext')) {
      context.handle(
        _payloadCiphertextMeta,
        payloadCiphertext.isAcceptableOrUnknown(
          data['payload_ciphertext']!,
          _payloadCiphertextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadCiphertextMeta);
    }
    if (data.containsKey('safe_error_code')) {
      context.handle(
        _safeErrorCodeMeta,
        safeErrorCode.isAcceptableOrUnknown(
          data['safe_error_code']!,
          _safeErrorCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {walletMutationId, itemIndex},
  ];
  @override
  WalletMutationItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletMutationItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      walletMutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_mutation_id'],
      )!,
      itemIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_index'],
      )!,
      legRole: $WalletMutationItemsTable.$converterlegRole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}leg_role'],
        )!,
      ),
      walletRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_record_id'],
      ),
      expectedRemoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_remote_revision'],
      ),
      payloadCiphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_ciphertext'],
      )!,
      state: $WalletMutationItemsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      safeErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safe_error_code'],
      ),
    );
  }

  @override
  $WalletMutationItemsTable createAlias(String alias) {
    return $WalletMutationItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<WalletItemLegRole, String> $converterlegRole =
      const WalletItemLegRoleConverter();
  static TypeConverter<WalletMutationState, String> $converterstate =
      const WalletMutationStateConverter();
}

class WalletMutationItem extends DataClass
    implements Insertable<WalletMutationItem> {
  final int id;
  final String walletMutationId;
  final int itemIndex;
  final WalletItemLegRole legRole;
  final String? walletRecordId;
  final int? expectedRemoteRevision;
  final String payloadCiphertext;
  final WalletMutationState state;
  final String? safeErrorCode;
  const WalletMutationItem({
    required this.id,
    required this.walletMutationId,
    required this.itemIndex,
    required this.legRole,
    this.walletRecordId,
    this.expectedRemoteRevision,
    required this.payloadCiphertext,
    required this.state,
    this.safeErrorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wallet_mutation_id'] = Variable<String>(walletMutationId);
    map['item_index'] = Variable<int>(itemIndex);
    {
      map['leg_role'] = Variable<String>(
        $WalletMutationItemsTable.$converterlegRole.toSql(legRole),
      );
    }
    if (!nullToAbsent || walletRecordId != null) {
      map['wallet_record_id'] = Variable<String>(walletRecordId);
    }
    if (!nullToAbsent || expectedRemoteRevision != null) {
      map['expected_remote_revision'] = Variable<int>(expectedRemoteRevision);
    }
    map['payload_ciphertext'] = Variable<String>(payloadCiphertext);
    {
      map['state'] = Variable<String>(
        $WalletMutationItemsTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || safeErrorCode != null) {
      map['safe_error_code'] = Variable<String>(safeErrorCode);
    }
    return map;
  }

  WalletMutationItemsCompanion toCompanion(bool nullToAbsent) {
    return WalletMutationItemsCompanion(
      id: Value(id),
      walletMutationId: Value(walletMutationId),
      itemIndex: Value(itemIndex),
      legRole: Value(legRole),
      walletRecordId: walletRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletRecordId),
      expectedRemoteRevision: expectedRemoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedRemoteRevision),
      payloadCiphertext: Value(payloadCiphertext),
      state: Value(state),
      safeErrorCode: safeErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(safeErrorCode),
    );
  }

  factory WalletMutationItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletMutationItem(
      id: serializer.fromJson<int>(json['id']),
      walletMutationId: serializer.fromJson<String>(json['walletMutationId']),
      itemIndex: serializer.fromJson<int>(json['itemIndex']),
      legRole: serializer.fromJson<WalletItemLegRole>(json['legRole']),
      walletRecordId: serializer.fromJson<String?>(json['walletRecordId']),
      expectedRemoteRevision: serializer.fromJson<int?>(
        json['expectedRemoteRevision'],
      ),
      payloadCiphertext: serializer.fromJson<String>(json['payloadCiphertext']),
      state: serializer.fromJson<WalletMutationState>(json['state']),
      safeErrorCode: serializer.fromJson<String?>(json['safeErrorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'walletMutationId': serializer.toJson<String>(walletMutationId),
      'itemIndex': serializer.toJson<int>(itemIndex),
      'legRole': serializer.toJson<WalletItemLegRole>(legRole),
      'walletRecordId': serializer.toJson<String?>(walletRecordId),
      'expectedRemoteRevision': serializer.toJson<int?>(expectedRemoteRevision),
      'payloadCiphertext': serializer.toJson<String>(payloadCiphertext),
      'state': serializer.toJson<WalletMutationState>(state),
      'safeErrorCode': serializer.toJson<String?>(safeErrorCode),
    };
  }

  WalletMutationItem copyWith({
    int? id,
    String? walletMutationId,
    int? itemIndex,
    WalletItemLegRole? legRole,
    Value<String?> walletRecordId = const Value.absent(),
    Value<int?> expectedRemoteRevision = const Value.absent(),
    String? payloadCiphertext,
    WalletMutationState? state,
    Value<String?> safeErrorCode = const Value.absent(),
  }) => WalletMutationItem(
    id: id ?? this.id,
    walletMutationId: walletMutationId ?? this.walletMutationId,
    itemIndex: itemIndex ?? this.itemIndex,
    legRole: legRole ?? this.legRole,
    walletRecordId: walletRecordId.present
        ? walletRecordId.value
        : this.walletRecordId,
    expectedRemoteRevision: expectedRemoteRevision.present
        ? expectedRemoteRevision.value
        : this.expectedRemoteRevision,
    payloadCiphertext: payloadCiphertext ?? this.payloadCiphertext,
    state: state ?? this.state,
    safeErrorCode: safeErrorCode.present
        ? safeErrorCode.value
        : this.safeErrorCode,
  );
  WalletMutationItem copyWithCompanion(WalletMutationItemsCompanion data) {
    return WalletMutationItem(
      id: data.id.present ? data.id.value : this.id,
      walletMutationId: data.walletMutationId.present
          ? data.walletMutationId.value
          : this.walletMutationId,
      itemIndex: data.itemIndex.present ? data.itemIndex.value : this.itemIndex,
      legRole: data.legRole.present ? data.legRole.value : this.legRole,
      walletRecordId: data.walletRecordId.present
          ? data.walletRecordId.value
          : this.walletRecordId,
      expectedRemoteRevision: data.expectedRemoteRevision.present
          ? data.expectedRemoteRevision.value
          : this.expectedRemoteRevision,
      payloadCiphertext: data.payloadCiphertext.present
          ? data.payloadCiphertext.value
          : this.payloadCiphertext,
      state: data.state.present ? data.state.value : this.state,
      safeErrorCode: data.safeErrorCode.present
          ? data.safeErrorCode.value
          : this.safeErrorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletMutationItem(')
          ..write('id: $id, ')
          ..write('walletMutationId: $walletMutationId, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('legRole: $legRole, ')
          ..write('walletRecordId: $walletRecordId, ')
          ..write('expectedRemoteRevision: $expectedRemoteRevision, ')
          ..write('payloadCiphertext: $payloadCiphertext, ')
          ..write('state: $state, ')
          ..write('safeErrorCode: $safeErrorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    walletMutationId,
    itemIndex,
    legRole,
    walletRecordId,
    expectedRemoteRevision,
    payloadCiphertext,
    state,
    safeErrorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletMutationItem &&
          other.id == this.id &&
          other.walletMutationId == this.walletMutationId &&
          other.itemIndex == this.itemIndex &&
          other.legRole == this.legRole &&
          other.walletRecordId == this.walletRecordId &&
          other.expectedRemoteRevision == this.expectedRemoteRevision &&
          other.payloadCiphertext == this.payloadCiphertext &&
          other.state == this.state &&
          other.safeErrorCode == this.safeErrorCode);
}

class WalletMutationItemsCompanion extends UpdateCompanion<WalletMutationItem> {
  final Value<int> id;
  final Value<String> walletMutationId;
  final Value<int> itemIndex;
  final Value<WalletItemLegRole> legRole;
  final Value<String?> walletRecordId;
  final Value<int?> expectedRemoteRevision;
  final Value<String> payloadCiphertext;
  final Value<WalletMutationState> state;
  final Value<String?> safeErrorCode;
  const WalletMutationItemsCompanion({
    this.id = const Value.absent(),
    this.walletMutationId = const Value.absent(),
    this.itemIndex = const Value.absent(),
    this.legRole = const Value.absent(),
    this.walletRecordId = const Value.absent(),
    this.expectedRemoteRevision = const Value.absent(),
    this.payloadCiphertext = const Value.absent(),
    this.state = const Value.absent(),
    this.safeErrorCode = const Value.absent(),
  });
  WalletMutationItemsCompanion.insert({
    this.id = const Value.absent(),
    required String walletMutationId,
    required int itemIndex,
    required WalletItemLegRole legRole,
    this.walletRecordId = const Value.absent(),
    this.expectedRemoteRevision = const Value.absent(),
    required String payloadCiphertext,
    required WalletMutationState state,
    this.safeErrorCode = const Value.absent(),
  }) : walletMutationId = Value(walletMutationId),
       itemIndex = Value(itemIndex),
       legRole = Value(legRole),
       payloadCiphertext = Value(payloadCiphertext),
       state = Value(state);
  static Insertable<WalletMutationItem> custom({
    Expression<int>? id,
    Expression<String>? walletMutationId,
    Expression<int>? itemIndex,
    Expression<String>? legRole,
    Expression<String>? walletRecordId,
    Expression<int>? expectedRemoteRevision,
    Expression<String>? payloadCiphertext,
    Expression<String>? state,
    Expression<String>? safeErrorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletMutationId != null) 'wallet_mutation_id': walletMutationId,
      if (itemIndex != null) 'item_index': itemIndex,
      if (legRole != null) 'leg_role': legRole,
      if (walletRecordId != null) 'wallet_record_id': walletRecordId,
      if (expectedRemoteRevision != null)
        'expected_remote_revision': expectedRemoteRevision,
      if (payloadCiphertext != null) 'payload_ciphertext': payloadCiphertext,
      if (state != null) 'state': state,
      if (safeErrorCode != null) 'safe_error_code': safeErrorCode,
    });
  }

  WalletMutationItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? walletMutationId,
    Value<int>? itemIndex,
    Value<WalletItemLegRole>? legRole,
    Value<String?>? walletRecordId,
    Value<int?>? expectedRemoteRevision,
    Value<String>? payloadCiphertext,
    Value<WalletMutationState>? state,
    Value<String?>? safeErrorCode,
  }) {
    return WalletMutationItemsCompanion(
      id: id ?? this.id,
      walletMutationId: walletMutationId ?? this.walletMutationId,
      itemIndex: itemIndex ?? this.itemIndex,
      legRole: legRole ?? this.legRole,
      walletRecordId: walletRecordId ?? this.walletRecordId,
      expectedRemoteRevision:
          expectedRemoteRevision ?? this.expectedRemoteRevision,
      payloadCiphertext: payloadCiphertext ?? this.payloadCiphertext,
      state: state ?? this.state,
      safeErrorCode: safeErrorCode ?? this.safeErrorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (walletMutationId.present) {
      map['wallet_mutation_id'] = Variable<String>(walletMutationId.value);
    }
    if (itemIndex.present) {
      map['item_index'] = Variable<int>(itemIndex.value);
    }
    if (legRole.present) {
      map['leg_role'] = Variable<String>(
        $WalletMutationItemsTable.$converterlegRole.toSql(legRole.value),
      );
    }
    if (walletRecordId.present) {
      map['wallet_record_id'] = Variable<String>(walletRecordId.value);
    }
    if (expectedRemoteRevision.present) {
      map['expected_remote_revision'] = Variable<int>(
        expectedRemoteRevision.value,
      );
    }
    if (payloadCiphertext.present) {
      map['payload_ciphertext'] = Variable<String>(payloadCiphertext.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $WalletMutationItemsTable.$converterstate.toSql(state.value),
      );
    }
    if (safeErrorCode.present) {
      map['safe_error_code'] = Variable<String>(safeErrorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletMutationItemsCompanion(')
          ..write('id: $id, ')
          ..write('walletMutationId: $walletMutationId, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('legRole: $legRole, ')
          ..write('walletRecordId: $walletRecordId, ')
          ..write('expectedRemoteRevision: $expectedRemoteRevision, ')
          ..write('payloadCiphertext: $payloadCiphertext, ')
          ..write('state: $state, ')
          ..write('safeErrorCode: $safeErrorCode')
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

class $RulePacksTable extends RulePacks
    with TableInfo<$RulePacksTable, RulePack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulePacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _installedAtEpochMsMeta =
      const VerificationMeta('installedAtEpochMs');
  @override
  late final GeneratedColumn<int> installedAtEpochMs = GeneratedColumn<int>(
    'installed_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    checksum,
    market,
    enabled,
    installedAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RulePack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('installed_at_epoch_ms')) {
      context.handle(
        _installedAtEpochMsMeta,
        installedAtEpochMs.isAcceptableOrUnknown(
          data['installed_at_epoch_ms']!,
          _installedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, version};
  @override
  RulePack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RulePack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      installedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installed_at_epoch_ms'],
      )!,
    );
  }

  @override
  $RulePacksTable createAlias(String alias) {
    return $RulePacksTable(attachedDatabase, alias);
  }
}

class RulePack extends DataClass implements Insertable<RulePack> {
  final String id;
  final String version;
  final String checksum;
  final String market;
  final bool enabled;
  final int installedAtEpochMs;
  const RulePack({
    required this.id,
    required this.version,
    required this.checksum,
    required this.market,
    required this.enabled,
    required this.installedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<String>(version);
    map['checksum'] = Variable<String>(checksum);
    map['market'] = Variable<String>(market);
    map['enabled'] = Variable<bool>(enabled);
    map['installed_at_epoch_ms'] = Variable<int>(installedAtEpochMs);
    return map;
  }

  RulePacksCompanion toCompanion(bool nullToAbsent) {
    return RulePacksCompanion(
      id: Value(id),
      version: Value(version),
      checksum: Value(checksum),
      market: Value(market),
      enabled: Value(enabled),
      installedAtEpochMs: Value(installedAtEpochMs),
    );
  }

  factory RulePack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RulePack(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<String>(json['version']),
      checksum: serializer.fromJson<String>(json['checksum']),
      market: serializer.fromJson<String>(json['market']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      installedAtEpochMs: serializer.fromJson<int>(json['installedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<String>(version),
      'checksum': serializer.toJson<String>(checksum),
      'market': serializer.toJson<String>(market),
      'enabled': serializer.toJson<bool>(enabled),
      'installedAtEpochMs': serializer.toJson<int>(installedAtEpochMs),
    };
  }

  RulePack copyWith({
    String? id,
    String? version,
    String? checksum,
    String? market,
    bool? enabled,
    int? installedAtEpochMs,
  }) => RulePack(
    id: id ?? this.id,
    version: version ?? this.version,
    checksum: checksum ?? this.checksum,
    market: market ?? this.market,
    enabled: enabled ?? this.enabled,
    installedAtEpochMs: installedAtEpochMs ?? this.installedAtEpochMs,
  );
  RulePack copyWithCompanion(RulePacksCompanion data) {
    return RulePack(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      market: data.market.present ? data.market.value : this.market,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      installedAtEpochMs: data.installedAtEpochMs.present
          ? data.installedAtEpochMs.value
          : this.installedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RulePack(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('checksum: $checksum, ')
          ..write('market: $market, ')
          ..write('enabled: $enabled, ')
          ..write('installedAtEpochMs: $installedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, version, checksum, market, enabled, installedAtEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RulePack &&
          other.id == this.id &&
          other.version == this.version &&
          other.checksum == this.checksum &&
          other.market == this.market &&
          other.enabled == this.enabled &&
          other.installedAtEpochMs == this.installedAtEpochMs);
}

class RulePacksCompanion extends UpdateCompanion<RulePack> {
  final Value<String> id;
  final Value<String> version;
  final Value<String> checksum;
  final Value<String> market;
  final Value<bool> enabled;
  final Value<int> installedAtEpochMs;
  final Value<int> rowid;
  const RulePacksCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.checksum = const Value.absent(),
    this.market = const Value.absent(),
    this.enabled = const Value.absent(),
    this.installedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RulePacksCompanion.insert({
    required String id,
    required String version,
    required String checksum,
    required String market,
    this.enabled = const Value.absent(),
    required int installedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       version = Value(version),
       checksum = Value(checksum),
       market = Value(market),
       installedAtEpochMs = Value(installedAtEpochMs);
  static Insertable<RulePack> custom({
    Expression<String>? id,
    Expression<String>? version,
    Expression<String>? checksum,
    Expression<String>? market,
    Expression<bool>? enabled,
    Expression<int>? installedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (checksum != null) 'checksum': checksum,
      if (market != null) 'market': market,
      if (enabled != null) 'enabled': enabled,
      if (installedAtEpochMs != null)
        'installed_at_epoch_ms': installedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RulePacksCompanion copyWith({
    Value<String>? id,
    Value<String>? version,
    Value<String>? checksum,
    Value<String>? market,
    Value<bool>? enabled,
    Value<int>? installedAtEpochMs,
    Value<int>? rowid,
  }) {
    return RulePacksCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      checksum: checksum ?? this.checksum,
      market: market ?? this.market,
      enabled: enabled ?? this.enabled,
      installedAtEpochMs: installedAtEpochMs ?? this.installedAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (installedAtEpochMs.present) {
      map['installed_at_epoch_ms'] = Variable<int>(installedAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulePacksCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('checksum: $checksum, ')
          ..write('market: $market, ')
          ..write('enabled: $enabled, ')
          ..write('installedAtEpochMs: $installedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngestionCheckpointsTable extends IngestionCheckpoints
    with TableInfo<$IngestionCheckpointsTable, IngestionCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngestionCheckpointsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _selectedFromEpochMsMeta =
      const VerificationMeta('selectedFromEpochMs');
  @override
  late final GeneratedColumn<int> selectedFromEpochMs = GeneratedColumn<int>(
    'selected_from_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedUntilEpochMsMeta =
      const VerificationMeta('selectedUntilEpochMs');
  @override
  late final GeneratedColumn<int> selectedUntilEpochMs = GeneratedColumn<int>(
    'selected_until_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedRangeDaysMeta = const VerificationMeta(
    'selectedRangeDays',
  );
  @override
  late final GeneratedColumn<int> selectedRangeDays = GeneratedColumn<int>(
    'selected_range_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderCursorHashMeta = const VerificationMeta(
    'senderCursorHash',
  );
  @override
  late final GeneratedColumn<String> senderCursorHash = GeneratedColumn<String>(
    'sender_cursor_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCursorEpochMsMeta = const VerificationMeta(
    'dateCursorEpochMs',
  );
  @override
  late final GeneratedColumn<int> dateCursorEpochMs = GeneratedColumn<int>(
    'date_cursor_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configuredCapMeta = const VerificationMeta(
    'configuredCap',
  );
  @override
  late final GeneratedColumn<int> configuredCap = GeneratedColumn<int>(
    'configured_cap',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processedCountMeta = const VerificationMeta(
    'processedCount',
  );
  @override
  late final GeneratedColumn<int> processedCount = GeneratedColumn<int>(
    'processed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _acceptedCountMeta = const VerificationMeta(
    'acceptedCount',
  );
  @override
  late final GeneratedColumn<int> acceptedCount = GeneratedColumn<int>(
    'accepted_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _filteredCountMeta = const VerificationMeta(
    'filteredCount',
  );
  @override
  late final GeneratedColumn<int> filteredCount = GeneratedColumn<int>(
    'filtered_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _duplicateCountMeta = const VerificationMeta(
    'duplicateCount',
  );
  @override
  late final GeneratedColumn<int> duplicateCount = GeneratedColumn<int>(
    'duplicate_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngestionOutcome?, String>
  outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<IngestionOutcome?>(
        $IngestionCheckpointsTable.$converteroutcomen,
      );
  static const VerificationMeta _startedAtEpochMsMeta = const VerificationMeta(
    'startedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> startedAtEpochMs = GeneratedColumn<int>(
    'started_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtEpochMsMeta =
      const VerificationMeta('completedAtEpochMs');
  @override
  late final GeneratedColumn<int> completedAtEpochMs = GeneratedColumn<int>(
    'completed_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    ingestionSource,
    selectedFromEpochMs,
    selectedUntilEpochMs,
    selectedRangeDays,
    senderCursorHash,
    dateCursorEpochMs,
    configuredCap,
    processedCount,
    acceptedCount,
    filteredCount,
    duplicateCount,
    outcome,
    startedAtEpochMs,
    completedAtEpochMs,
    privacyEpoch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingestion_checkpoint';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngestionCheckpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('selected_from_epoch_ms')) {
      context.handle(
        _selectedFromEpochMsMeta,
        selectedFromEpochMs.isAcceptableOrUnknown(
          data['selected_from_epoch_ms']!,
          _selectedFromEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('selected_until_epoch_ms')) {
      context.handle(
        _selectedUntilEpochMsMeta,
        selectedUntilEpochMs.isAcceptableOrUnknown(
          data['selected_until_epoch_ms']!,
          _selectedUntilEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('selected_range_days')) {
      context.handle(
        _selectedRangeDaysMeta,
        selectedRangeDays.isAcceptableOrUnknown(
          data['selected_range_days']!,
          _selectedRangeDaysMeta,
        ),
      );
    }
    if (data.containsKey('sender_cursor_hash')) {
      context.handle(
        _senderCursorHashMeta,
        senderCursorHash.isAcceptableOrUnknown(
          data['sender_cursor_hash']!,
          _senderCursorHashMeta,
        ),
      );
    }
    if (data.containsKey('date_cursor_epoch_ms')) {
      context.handle(
        _dateCursorEpochMsMeta,
        dateCursorEpochMs.isAcceptableOrUnknown(
          data['date_cursor_epoch_ms']!,
          _dateCursorEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('configured_cap')) {
      context.handle(
        _configuredCapMeta,
        configuredCap.isAcceptableOrUnknown(
          data['configured_cap']!,
          _configuredCapMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configuredCapMeta);
    }
    if (data.containsKey('processed_count')) {
      context.handle(
        _processedCountMeta,
        processedCount.isAcceptableOrUnknown(
          data['processed_count']!,
          _processedCountMeta,
        ),
      );
    }
    if (data.containsKey('accepted_count')) {
      context.handle(
        _acceptedCountMeta,
        acceptedCount.isAcceptableOrUnknown(
          data['accepted_count']!,
          _acceptedCountMeta,
        ),
      );
    }
    if (data.containsKey('filtered_count')) {
      context.handle(
        _filteredCountMeta,
        filteredCount.isAcceptableOrUnknown(
          data['filtered_count']!,
          _filteredCountMeta,
        ),
      );
    }
    if (data.containsKey('duplicate_count')) {
      context.handle(
        _duplicateCountMeta,
        duplicateCount.isAcceptableOrUnknown(
          data['duplicate_count']!,
          _duplicateCountMeta,
        ),
      );
    }
    if (data.containsKey('started_at_epoch_ms')) {
      context.handle(
        _startedAtEpochMsMeta,
        startedAtEpochMs.isAcceptableOrUnknown(
          data['started_at_epoch_ms']!,
          _startedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtEpochMsMeta);
    }
    if (data.containsKey('completed_at_epoch_ms')) {
      context.handle(
        _completedAtEpochMsMeta,
        completedAtEpochMs.isAcceptableOrUnknown(
          data['completed_at_epoch_ms']!,
          _completedAtEpochMsMeta,
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
    } else if (isInserting) {
      context.missing(_privacyEpochMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngestionCheckpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngestionCheckpoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ingestionSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingestion_source'],
      )!,
      selectedFromEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_from_epoch_ms'],
      ),
      selectedUntilEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_until_epoch_ms'],
      ),
      selectedRangeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_range_days'],
      ),
      senderCursorHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_cursor_hash'],
      ),
      dateCursorEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_cursor_epoch_ms'],
      ),
      configuredCap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}configured_cap'],
      )!,
      processedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processed_count'],
      )!,
      acceptedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accepted_count'],
      )!,
      filteredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}filtered_count'],
      )!,
      duplicateCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duplicate_count'],
      )!,
      outcome: $IngestionCheckpointsTable.$converteroutcomen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        ),
      ),
      startedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_epoch_ms'],
      )!,
      completedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_epoch_ms'],
      ),
      privacyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch'],
      )!,
    );
  }

  @override
  $IngestionCheckpointsTable createAlias(String alias) {
    return $IngestionCheckpointsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IngestionOutcome, String, String>
  $converteroutcome = const EnumNameConverter<IngestionOutcome>(
    IngestionOutcome.values,
  );
  static JsonTypeConverter2<IngestionOutcome?, String?, String?>
  $converteroutcomen = JsonTypeConverter2.asNullable($converteroutcome);
}

class IngestionCheckpoint extends DataClass
    implements Insertable<IngestionCheckpoint> {
  final int id;
  final String ingestionSource;
  final int? selectedFromEpochMs;
  final int? selectedUntilEpochMs;
  final int? selectedRangeDays;
  final String? senderCursorHash;
  final int? dateCursorEpochMs;
  final int configuredCap;
  final int processedCount;
  final int acceptedCount;
  final int filteredCount;
  final int duplicateCount;
  final IngestionOutcome? outcome;
  final int startedAtEpochMs;
  final int? completedAtEpochMs;
  final int privacyEpoch;
  const IngestionCheckpoint({
    required this.id,
    required this.ingestionSource,
    this.selectedFromEpochMs,
    this.selectedUntilEpochMs,
    this.selectedRangeDays,
    this.senderCursorHash,
    this.dateCursorEpochMs,
    required this.configuredCap,
    required this.processedCount,
    required this.acceptedCount,
    required this.filteredCount,
    required this.duplicateCount,
    this.outcome,
    required this.startedAtEpochMs,
    this.completedAtEpochMs,
    required this.privacyEpoch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingestion_source'] = Variable<String>(ingestionSource);
    if (!nullToAbsent || selectedFromEpochMs != null) {
      map['selected_from_epoch_ms'] = Variable<int>(selectedFromEpochMs);
    }
    if (!nullToAbsent || selectedUntilEpochMs != null) {
      map['selected_until_epoch_ms'] = Variable<int>(selectedUntilEpochMs);
    }
    if (!nullToAbsent || selectedRangeDays != null) {
      map['selected_range_days'] = Variable<int>(selectedRangeDays);
    }
    if (!nullToAbsent || senderCursorHash != null) {
      map['sender_cursor_hash'] = Variable<String>(senderCursorHash);
    }
    if (!nullToAbsent || dateCursorEpochMs != null) {
      map['date_cursor_epoch_ms'] = Variable<int>(dateCursorEpochMs);
    }
    map['configured_cap'] = Variable<int>(configuredCap);
    map['processed_count'] = Variable<int>(processedCount);
    map['accepted_count'] = Variable<int>(acceptedCount);
    map['filtered_count'] = Variable<int>(filteredCount);
    map['duplicate_count'] = Variable<int>(duplicateCount);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(
        $IngestionCheckpointsTable.$converteroutcomen.toSql(outcome),
      );
    }
    map['started_at_epoch_ms'] = Variable<int>(startedAtEpochMs);
    if (!nullToAbsent || completedAtEpochMs != null) {
      map['completed_at_epoch_ms'] = Variable<int>(completedAtEpochMs);
    }
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    return map;
  }

  IngestionCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return IngestionCheckpointsCompanion(
      id: Value(id),
      ingestionSource: Value(ingestionSource),
      selectedFromEpochMs: selectedFromEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedFromEpochMs),
      selectedUntilEpochMs: selectedUntilEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedUntilEpochMs),
      selectedRangeDays: selectedRangeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedRangeDays),
      senderCursorHash: senderCursorHash == null && nullToAbsent
          ? const Value.absent()
          : Value(senderCursorHash),
      dateCursorEpochMs: dateCursorEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCursorEpochMs),
      configuredCap: Value(configuredCap),
      processedCount: Value(processedCount),
      acceptedCount: Value(acceptedCount),
      filteredCount: Value(filteredCount),
      duplicateCount: Value(duplicateCount),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      startedAtEpochMs: Value(startedAtEpochMs),
      completedAtEpochMs: completedAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtEpochMs),
      privacyEpoch: Value(privacyEpoch),
    );
  }

  factory IngestionCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngestionCheckpoint(
      id: serializer.fromJson<int>(json['id']),
      ingestionSource: serializer.fromJson<String>(json['ingestionSource']),
      selectedFromEpochMs: serializer.fromJson<int?>(
        json['selectedFromEpochMs'],
      ),
      selectedUntilEpochMs: serializer.fromJson<int?>(
        json['selectedUntilEpochMs'],
      ),
      selectedRangeDays: serializer.fromJson<int?>(json['selectedRangeDays']),
      senderCursorHash: serializer.fromJson<String?>(json['senderCursorHash']),
      dateCursorEpochMs: serializer.fromJson<int?>(json['dateCursorEpochMs']),
      configuredCap: serializer.fromJson<int>(json['configuredCap']),
      processedCount: serializer.fromJson<int>(json['processedCount']),
      acceptedCount: serializer.fromJson<int>(json['acceptedCount']),
      filteredCount: serializer.fromJson<int>(json['filteredCount']),
      duplicateCount: serializer.fromJson<int>(json['duplicateCount']),
      outcome: $IngestionCheckpointsTable.$converteroutcomen.fromJson(
        serializer.fromJson<String?>(json['outcome']),
      ),
      startedAtEpochMs: serializer.fromJson<int>(json['startedAtEpochMs']),
      completedAtEpochMs: serializer.fromJson<int?>(json['completedAtEpochMs']),
      privacyEpoch: serializer.fromJson<int>(json['privacyEpoch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingestionSource': serializer.toJson<String>(ingestionSource),
      'selectedFromEpochMs': serializer.toJson<int?>(selectedFromEpochMs),
      'selectedUntilEpochMs': serializer.toJson<int?>(selectedUntilEpochMs),
      'selectedRangeDays': serializer.toJson<int?>(selectedRangeDays),
      'senderCursorHash': serializer.toJson<String?>(senderCursorHash),
      'dateCursorEpochMs': serializer.toJson<int?>(dateCursorEpochMs),
      'configuredCap': serializer.toJson<int>(configuredCap),
      'processedCount': serializer.toJson<int>(processedCount),
      'acceptedCount': serializer.toJson<int>(acceptedCount),
      'filteredCount': serializer.toJson<int>(filteredCount),
      'duplicateCount': serializer.toJson<int>(duplicateCount),
      'outcome': serializer.toJson<String?>(
        $IngestionCheckpointsTable.$converteroutcomen.toJson(outcome),
      ),
      'startedAtEpochMs': serializer.toJson<int>(startedAtEpochMs),
      'completedAtEpochMs': serializer.toJson<int?>(completedAtEpochMs),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
    };
  }

  IngestionCheckpoint copyWith({
    int? id,
    String? ingestionSource,
    Value<int?> selectedFromEpochMs = const Value.absent(),
    Value<int?> selectedUntilEpochMs = const Value.absent(),
    Value<int?> selectedRangeDays = const Value.absent(),
    Value<String?> senderCursorHash = const Value.absent(),
    Value<int?> dateCursorEpochMs = const Value.absent(),
    int? configuredCap,
    int? processedCount,
    int? acceptedCount,
    int? filteredCount,
    int? duplicateCount,
    Value<IngestionOutcome?> outcome = const Value.absent(),
    int? startedAtEpochMs,
    Value<int?> completedAtEpochMs = const Value.absent(),
    int? privacyEpoch,
  }) => IngestionCheckpoint(
    id: id ?? this.id,
    ingestionSource: ingestionSource ?? this.ingestionSource,
    selectedFromEpochMs: selectedFromEpochMs.present
        ? selectedFromEpochMs.value
        : this.selectedFromEpochMs,
    selectedUntilEpochMs: selectedUntilEpochMs.present
        ? selectedUntilEpochMs.value
        : this.selectedUntilEpochMs,
    selectedRangeDays: selectedRangeDays.present
        ? selectedRangeDays.value
        : this.selectedRangeDays,
    senderCursorHash: senderCursorHash.present
        ? senderCursorHash.value
        : this.senderCursorHash,
    dateCursorEpochMs: dateCursorEpochMs.present
        ? dateCursorEpochMs.value
        : this.dateCursorEpochMs,
    configuredCap: configuredCap ?? this.configuredCap,
    processedCount: processedCount ?? this.processedCount,
    acceptedCount: acceptedCount ?? this.acceptedCount,
    filteredCount: filteredCount ?? this.filteredCount,
    duplicateCount: duplicateCount ?? this.duplicateCount,
    outcome: outcome.present ? outcome.value : this.outcome,
    startedAtEpochMs: startedAtEpochMs ?? this.startedAtEpochMs,
    completedAtEpochMs: completedAtEpochMs.present
        ? completedAtEpochMs.value
        : this.completedAtEpochMs,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
  );
  IngestionCheckpoint copyWithCompanion(IngestionCheckpointsCompanion data) {
    return IngestionCheckpoint(
      id: data.id.present ? data.id.value : this.id,
      ingestionSource: data.ingestionSource.present
          ? data.ingestionSource.value
          : this.ingestionSource,
      selectedFromEpochMs: data.selectedFromEpochMs.present
          ? data.selectedFromEpochMs.value
          : this.selectedFromEpochMs,
      selectedUntilEpochMs: data.selectedUntilEpochMs.present
          ? data.selectedUntilEpochMs.value
          : this.selectedUntilEpochMs,
      selectedRangeDays: data.selectedRangeDays.present
          ? data.selectedRangeDays.value
          : this.selectedRangeDays,
      senderCursorHash: data.senderCursorHash.present
          ? data.senderCursorHash.value
          : this.senderCursorHash,
      dateCursorEpochMs: data.dateCursorEpochMs.present
          ? data.dateCursorEpochMs.value
          : this.dateCursorEpochMs,
      configuredCap: data.configuredCap.present
          ? data.configuredCap.value
          : this.configuredCap,
      processedCount: data.processedCount.present
          ? data.processedCount.value
          : this.processedCount,
      acceptedCount: data.acceptedCount.present
          ? data.acceptedCount.value
          : this.acceptedCount,
      filteredCount: data.filteredCount.present
          ? data.filteredCount.value
          : this.filteredCount,
      duplicateCount: data.duplicateCount.present
          ? data.duplicateCount.value
          : this.duplicateCount,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      startedAtEpochMs: data.startedAtEpochMs.present
          ? data.startedAtEpochMs.value
          : this.startedAtEpochMs,
      completedAtEpochMs: data.completedAtEpochMs.present
          ? data.completedAtEpochMs.value
          : this.completedAtEpochMs,
      privacyEpoch: data.privacyEpoch.present
          ? data.privacyEpoch.value
          : this.privacyEpoch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngestionCheckpoint(')
          ..write('id: $id, ')
          ..write('ingestionSource: $ingestionSource, ')
          ..write('selectedFromEpochMs: $selectedFromEpochMs, ')
          ..write('selectedUntilEpochMs: $selectedUntilEpochMs, ')
          ..write('selectedRangeDays: $selectedRangeDays, ')
          ..write('senderCursorHash: $senderCursorHash, ')
          ..write('dateCursorEpochMs: $dateCursorEpochMs, ')
          ..write('configuredCap: $configuredCap, ')
          ..write('processedCount: $processedCount, ')
          ..write('acceptedCount: $acceptedCount, ')
          ..write('filteredCount: $filteredCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('outcome: $outcome, ')
          ..write('startedAtEpochMs: $startedAtEpochMs, ')
          ..write('completedAtEpochMs: $completedAtEpochMs, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ingestionSource,
    selectedFromEpochMs,
    selectedUntilEpochMs,
    selectedRangeDays,
    senderCursorHash,
    dateCursorEpochMs,
    configuredCap,
    processedCount,
    acceptedCount,
    filteredCount,
    duplicateCount,
    outcome,
    startedAtEpochMs,
    completedAtEpochMs,
    privacyEpoch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngestionCheckpoint &&
          other.id == this.id &&
          other.ingestionSource == this.ingestionSource &&
          other.selectedFromEpochMs == this.selectedFromEpochMs &&
          other.selectedUntilEpochMs == this.selectedUntilEpochMs &&
          other.selectedRangeDays == this.selectedRangeDays &&
          other.senderCursorHash == this.senderCursorHash &&
          other.dateCursorEpochMs == this.dateCursorEpochMs &&
          other.configuredCap == this.configuredCap &&
          other.processedCount == this.processedCount &&
          other.acceptedCount == this.acceptedCount &&
          other.filteredCount == this.filteredCount &&
          other.duplicateCount == this.duplicateCount &&
          other.outcome == this.outcome &&
          other.startedAtEpochMs == this.startedAtEpochMs &&
          other.completedAtEpochMs == this.completedAtEpochMs &&
          other.privacyEpoch == this.privacyEpoch);
}

class IngestionCheckpointsCompanion
    extends UpdateCompanion<IngestionCheckpoint> {
  final Value<int> id;
  final Value<String> ingestionSource;
  final Value<int?> selectedFromEpochMs;
  final Value<int?> selectedUntilEpochMs;
  final Value<int?> selectedRangeDays;
  final Value<String?> senderCursorHash;
  final Value<int?> dateCursorEpochMs;
  final Value<int> configuredCap;
  final Value<int> processedCount;
  final Value<int> acceptedCount;
  final Value<int> filteredCount;
  final Value<int> duplicateCount;
  final Value<IngestionOutcome?> outcome;
  final Value<int> startedAtEpochMs;
  final Value<int?> completedAtEpochMs;
  final Value<int> privacyEpoch;
  const IngestionCheckpointsCompanion({
    this.id = const Value.absent(),
    this.ingestionSource = const Value.absent(),
    this.selectedFromEpochMs = const Value.absent(),
    this.selectedUntilEpochMs = const Value.absent(),
    this.selectedRangeDays = const Value.absent(),
    this.senderCursorHash = const Value.absent(),
    this.dateCursorEpochMs = const Value.absent(),
    this.configuredCap = const Value.absent(),
    this.processedCount = const Value.absent(),
    this.acceptedCount = const Value.absent(),
    this.filteredCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.outcome = const Value.absent(),
    this.startedAtEpochMs = const Value.absent(),
    this.completedAtEpochMs = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  IngestionCheckpointsCompanion.insert({
    this.id = const Value.absent(),
    required String ingestionSource,
    this.selectedFromEpochMs = const Value.absent(),
    this.selectedUntilEpochMs = const Value.absent(),
    this.selectedRangeDays = const Value.absent(),
    this.senderCursorHash = const Value.absent(),
    this.dateCursorEpochMs = const Value.absent(),
    required int configuredCap,
    this.processedCount = const Value.absent(),
    this.acceptedCount = const Value.absent(),
    this.filteredCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.outcome = const Value.absent(),
    required int startedAtEpochMs,
    this.completedAtEpochMs = const Value.absent(),
    required int privacyEpoch,
  }) : ingestionSource = Value(ingestionSource),
       configuredCap = Value(configuredCap),
       startedAtEpochMs = Value(startedAtEpochMs),
       privacyEpoch = Value(privacyEpoch);
  static Insertable<IngestionCheckpoint> custom({
    Expression<int>? id,
    Expression<String>? ingestionSource,
    Expression<int>? selectedFromEpochMs,
    Expression<int>? selectedUntilEpochMs,
    Expression<int>? selectedRangeDays,
    Expression<String>? senderCursorHash,
    Expression<int>? dateCursorEpochMs,
    Expression<int>? configuredCap,
    Expression<int>? processedCount,
    Expression<int>? acceptedCount,
    Expression<int>? filteredCount,
    Expression<int>? duplicateCount,
    Expression<String>? outcome,
    Expression<int>? startedAtEpochMs,
    Expression<int>? completedAtEpochMs,
    Expression<int>? privacyEpoch,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingestionSource != null) 'ingestion_source': ingestionSource,
      if (selectedFromEpochMs != null)
        'selected_from_epoch_ms': selectedFromEpochMs,
      if (selectedUntilEpochMs != null)
        'selected_until_epoch_ms': selectedUntilEpochMs,
      if (selectedRangeDays != null) 'selected_range_days': selectedRangeDays,
      if (senderCursorHash != null) 'sender_cursor_hash': senderCursorHash,
      if (dateCursorEpochMs != null) 'date_cursor_epoch_ms': dateCursorEpochMs,
      if (configuredCap != null) 'configured_cap': configuredCap,
      if (processedCount != null) 'processed_count': processedCount,
      if (acceptedCount != null) 'accepted_count': acceptedCount,
      if (filteredCount != null) 'filtered_count': filteredCount,
      if (duplicateCount != null) 'duplicate_count': duplicateCount,
      if (outcome != null) 'outcome': outcome,
      if (startedAtEpochMs != null) 'started_at_epoch_ms': startedAtEpochMs,
      if (completedAtEpochMs != null)
        'completed_at_epoch_ms': completedAtEpochMs,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
    });
  }

  IngestionCheckpointsCompanion copyWith({
    Value<int>? id,
    Value<String>? ingestionSource,
    Value<int?>? selectedFromEpochMs,
    Value<int?>? selectedUntilEpochMs,
    Value<int?>? selectedRangeDays,
    Value<String?>? senderCursorHash,
    Value<int?>? dateCursorEpochMs,
    Value<int>? configuredCap,
    Value<int>? processedCount,
    Value<int>? acceptedCount,
    Value<int>? filteredCount,
    Value<int>? duplicateCount,
    Value<IngestionOutcome?>? outcome,
    Value<int>? startedAtEpochMs,
    Value<int?>? completedAtEpochMs,
    Value<int>? privacyEpoch,
  }) {
    return IngestionCheckpointsCompanion(
      id: id ?? this.id,
      ingestionSource: ingestionSource ?? this.ingestionSource,
      selectedFromEpochMs: selectedFromEpochMs ?? this.selectedFromEpochMs,
      selectedUntilEpochMs: selectedUntilEpochMs ?? this.selectedUntilEpochMs,
      selectedRangeDays: selectedRangeDays ?? this.selectedRangeDays,
      senderCursorHash: senderCursorHash ?? this.senderCursorHash,
      dateCursorEpochMs: dateCursorEpochMs ?? this.dateCursorEpochMs,
      configuredCap: configuredCap ?? this.configuredCap,
      processedCount: processedCount ?? this.processedCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      filteredCount: filteredCount ?? this.filteredCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      outcome: outcome ?? this.outcome,
      startedAtEpochMs: startedAtEpochMs ?? this.startedAtEpochMs,
      completedAtEpochMs: completedAtEpochMs ?? this.completedAtEpochMs,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingestionSource.present) {
      map['ingestion_source'] = Variable<String>(ingestionSource.value);
    }
    if (selectedFromEpochMs.present) {
      map['selected_from_epoch_ms'] = Variable<int>(selectedFromEpochMs.value);
    }
    if (selectedUntilEpochMs.present) {
      map['selected_until_epoch_ms'] = Variable<int>(
        selectedUntilEpochMs.value,
      );
    }
    if (selectedRangeDays.present) {
      map['selected_range_days'] = Variable<int>(selectedRangeDays.value);
    }
    if (senderCursorHash.present) {
      map['sender_cursor_hash'] = Variable<String>(senderCursorHash.value);
    }
    if (dateCursorEpochMs.present) {
      map['date_cursor_epoch_ms'] = Variable<int>(dateCursorEpochMs.value);
    }
    if (configuredCap.present) {
      map['configured_cap'] = Variable<int>(configuredCap.value);
    }
    if (processedCount.present) {
      map['processed_count'] = Variable<int>(processedCount.value);
    }
    if (acceptedCount.present) {
      map['accepted_count'] = Variable<int>(acceptedCount.value);
    }
    if (filteredCount.present) {
      map['filtered_count'] = Variable<int>(filteredCount.value);
    }
    if (duplicateCount.present) {
      map['duplicate_count'] = Variable<int>(duplicateCount.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $IngestionCheckpointsTable.$converteroutcomen.toSql(outcome.value),
      );
    }
    if (startedAtEpochMs.present) {
      map['started_at_epoch_ms'] = Variable<int>(startedAtEpochMs.value);
    }
    if (completedAtEpochMs.present) {
      map['completed_at_epoch_ms'] = Variable<int>(completedAtEpochMs.value);
    }
    if (privacyEpoch.present) {
      map['privacy_epoch'] = Variable<int>(privacyEpoch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngestionCheckpointsCompanion(')
          ..write('id: $id, ')
          ..write('ingestionSource: $ingestionSource, ')
          ..write('selectedFromEpochMs: $selectedFromEpochMs, ')
          ..write('selectedUntilEpochMs: $selectedUntilEpochMs, ')
          ..write('selectedRangeDays: $selectedRangeDays, ')
          ..write('senderCursorHash: $senderCursorHash, ')
          ..write('dateCursorEpochMs: $dateCursorEpochMs, ')
          ..write('configuredCap: $configuredCap, ')
          ..write('processedCount: $processedCount, ')
          ..write('acceptedCount: $acceptedCount, ')
          ..write('filteredCount: $filteredCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('outcome: $outcome, ')
          ..write('startedAtEpochMs: $startedAtEpochMs, ')
          ..write('completedAtEpochMs: $completedAtEpochMs, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }
}

class $TrackingStateTable extends TrackingState
    with TableInfo<$TrackingStateTable, TrackingStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastScanAtEpochMsMeta = const VerificationMeta(
    'lastScanAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> lastScanAtEpochMs = GeneratedColumn<int>(
    'last_scan_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastScanOutcomeMeta = const VerificationMeta(
    'lastScanOutcome',
  );
  @override
  late final GeneratedColumn<String> lastScanOutcome = GeneratedColumn<String>(
    'last_scan_outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSafeErrorCodeMeta = const VerificationMeta(
    'lastSafeErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastSafeErrorCode =
      GeneratedColumn<String>(
        'last_safe_error_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    lastScanAtEpochMs,
    lastScanOutcome,
    lastSafeErrorCode,
    privacyEpoch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackingStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_scan_at_epoch_ms')) {
      context.handle(
        _lastScanAtEpochMsMeta,
        lastScanAtEpochMs.isAcceptableOrUnknown(
          data['last_scan_at_epoch_ms']!,
          _lastScanAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('last_scan_outcome')) {
      context.handle(
        _lastScanOutcomeMeta,
        lastScanOutcome.isAcceptableOrUnknown(
          data['last_scan_outcome']!,
          _lastScanOutcomeMeta,
        ),
      );
    }
    if (data.containsKey('last_safe_error_code')) {
      context.handle(
        _lastSafeErrorCodeMeta,
        lastSafeErrorCode.isAcceptableOrUnknown(
          data['last_safe_error_code']!,
          _lastSafeErrorCodeMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackingStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastScanAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scan_at_epoch_ms'],
      ),
      lastScanOutcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_scan_outcome'],
      ),
      lastSafeErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_safe_error_code'],
      ),
      privacyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}privacy_epoch'],
      )!,
    );
  }

  @override
  $TrackingStateTable createAlias(String alias) {
    return $TrackingStateTable(attachedDatabase, alias);
  }
}

class TrackingStateData extends DataClass
    implements Insertable<TrackingStateData> {
  final int id;
  final int? lastScanAtEpochMs;
  final String? lastScanOutcome;
  final String? lastSafeErrorCode;
  final int privacyEpoch;
  const TrackingStateData({
    required this.id,
    this.lastScanAtEpochMs,
    this.lastScanOutcome,
    this.lastSafeErrorCode,
    required this.privacyEpoch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastScanAtEpochMs != null) {
      map['last_scan_at_epoch_ms'] = Variable<int>(lastScanAtEpochMs);
    }
    if (!nullToAbsent || lastScanOutcome != null) {
      map['last_scan_outcome'] = Variable<String>(lastScanOutcome);
    }
    if (!nullToAbsent || lastSafeErrorCode != null) {
      map['last_safe_error_code'] = Variable<String>(lastSafeErrorCode);
    }
    map['privacy_epoch'] = Variable<int>(privacyEpoch);
    return map;
  }

  TrackingStateCompanion toCompanion(bool nullToAbsent) {
    return TrackingStateCompanion(
      id: Value(id),
      lastScanAtEpochMs: lastScanAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanAtEpochMs),
      lastScanOutcome: lastScanOutcome == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanOutcome),
      lastSafeErrorCode: lastSafeErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSafeErrorCode),
      privacyEpoch: Value(privacyEpoch),
    );
  }

  factory TrackingStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingStateData(
      id: serializer.fromJson<int>(json['id']),
      lastScanAtEpochMs: serializer.fromJson<int?>(json['lastScanAtEpochMs']),
      lastScanOutcome: serializer.fromJson<String?>(json['lastScanOutcome']),
      lastSafeErrorCode: serializer.fromJson<String?>(
        json['lastSafeErrorCode'],
      ),
      privacyEpoch: serializer.fromJson<int>(json['privacyEpoch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastScanAtEpochMs': serializer.toJson<int?>(lastScanAtEpochMs),
      'lastScanOutcome': serializer.toJson<String?>(lastScanOutcome),
      'lastSafeErrorCode': serializer.toJson<String?>(lastSafeErrorCode),
      'privacyEpoch': serializer.toJson<int>(privacyEpoch),
    };
  }

  TrackingStateData copyWith({
    int? id,
    Value<int?> lastScanAtEpochMs = const Value.absent(),
    Value<String?> lastScanOutcome = const Value.absent(),
    Value<String?> lastSafeErrorCode = const Value.absent(),
    int? privacyEpoch,
  }) => TrackingStateData(
    id: id ?? this.id,
    lastScanAtEpochMs: lastScanAtEpochMs.present
        ? lastScanAtEpochMs.value
        : this.lastScanAtEpochMs,
    lastScanOutcome: lastScanOutcome.present
        ? lastScanOutcome.value
        : this.lastScanOutcome,
    lastSafeErrorCode: lastSafeErrorCode.present
        ? lastSafeErrorCode.value
        : this.lastSafeErrorCode,
    privacyEpoch: privacyEpoch ?? this.privacyEpoch,
  );
  TrackingStateData copyWithCompanion(TrackingStateCompanion data) {
    return TrackingStateData(
      id: data.id.present ? data.id.value : this.id,
      lastScanAtEpochMs: data.lastScanAtEpochMs.present
          ? data.lastScanAtEpochMs.value
          : this.lastScanAtEpochMs,
      lastScanOutcome: data.lastScanOutcome.present
          ? data.lastScanOutcome.value
          : this.lastScanOutcome,
      lastSafeErrorCode: data.lastSafeErrorCode.present
          ? data.lastSafeErrorCode.value
          : this.lastSafeErrorCode,
      privacyEpoch: data.privacyEpoch.present
          ? data.privacyEpoch.value
          : this.privacyEpoch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingStateData(')
          ..write('id: $id, ')
          ..write('lastScanAtEpochMs: $lastScanAtEpochMs, ')
          ..write('lastScanOutcome: $lastScanOutcome, ')
          ..write('lastSafeErrorCode: $lastSafeErrorCode, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastScanAtEpochMs,
    lastScanOutcome,
    lastSafeErrorCode,
    privacyEpoch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingStateData &&
          other.id == this.id &&
          other.lastScanAtEpochMs == this.lastScanAtEpochMs &&
          other.lastScanOutcome == this.lastScanOutcome &&
          other.lastSafeErrorCode == this.lastSafeErrorCode &&
          other.privacyEpoch == this.privacyEpoch);
}

class TrackingStateCompanion extends UpdateCompanion<TrackingStateData> {
  final Value<int> id;
  final Value<int?> lastScanAtEpochMs;
  final Value<String?> lastScanOutcome;
  final Value<String?> lastSafeErrorCode;
  final Value<int> privacyEpoch;
  const TrackingStateCompanion({
    this.id = const Value.absent(),
    this.lastScanAtEpochMs = const Value.absent(),
    this.lastScanOutcome = const Value.absent(),
    this.lastSafeErrorCode = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  TrackingStateCompanion.insert({
    this.id = const Value.absent(),
    this.lastScanAtEpochMs = const Value.absent(),
    this.lastScanOutcome = const Value.absent(),
    this.lastSafeErrorCode = const Value.absent(),
    this.privacyEpoch = const Value.absent(),
  });
  static Insertable<TrackingStateData> custom({
    Expression<int>? id,
    Expression<int>? lastScanAtEpochMs,
    Expression<String>? lastScanOutcome,
    Expression<String>? lastSafeErrorCode,
    Expression<int>? privacyEpoch,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastScanAtEpochMs != null) 'last_scan_at_epoch_ms': lastScanAtEpochMs,
      if (lastScanOutcome != null) 'last_scan_outcome': lastScanOutcome,
      if (lastSafeErrorCode != null) 'last_safe_error_code': lastSafeErrorCode,
      if (privacyEpoch != null) 'privacy_epoch': privacyEpoch,
    });
  }

  TrackingStateCompanion copyWith({
    Value<int>? id,
    Value<int?>? lastScanAtEpochMs,
    Value<String?>? lastScanOutcome,
    Value<String?>? lastSafeErrorCode,
    Value<int>? privacyEpoch,
  }) {
    return TrackingStateCompanion(
      id: id ?? this.id,
      lastScanAtEpochMs: lastScanAtEpochMs ?? this.lastScanAtEpochMs,
      lastScanOutcome: lastScanOutcome ?? this.lastScanOutcome,
      lastSafeErrorCode: lastSafeErrorCode ?? this.lastSafeErrorCode,
      privacyEpoch: privacyEpoch ?? this.privacyEpoch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastScanAtEpochMs.present) {
      map['last_scan_at_epoch_ms'] = Variable<int>(lastScanAtEpochMs.value);
    }
    if (lastScanOutcome.present) {
      map['last_scan_outcome'] = Variable<String>(lastScanOutcome.value);
    }
    if (lastSafeErrorCode.present) {
      map['last_safe_error_code'] = Variable<String>(lastSafeErrorCode.value);
    }
    if (privacyEpoch.present) {
      map['privacy_epoch'] = Variable<int>(privacyEpoch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackingStateCompanion(')
          ..write('id: $id, ')
          ..write('lastScanAtEpochMs: $lastScanAtEpochMs, ')
          ..write('lastScanOutcome: $lastScanOutcome, ')
          ..write('lastSafeErrorCode: $lastSafeErrorCode, ')
          ..write('privacyEpoch: $privacyEpoch')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SenderRulesTable senderRules = $SenderRulesTable(this);
  late final $TrackedSendersTable trackedSenders = $TrackedSendersTable(this);
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
  late final $WalletLabelCacheTable walletLabelCache = $WalletLabelCacheTable(
    this,
  );
  late final $WalletConnectionStatusTable walletConnectionStatus =
      $WalletConnectionStatusTable(this);
  late final $WalletMutationsTable walletMutations = $WalletMutationsTable(
    this,
  );
  late final $WalletRecordLinksTable walletRecordLinks =
      $WalletRecordLinksTable(this);
  late final $MappingRulesTable mappingRules = $MappingRulesTable(this);
  late final $WalletMutationItemsTable walletMutationItems =
      $WalletMutationItemsTable(this);
  late final $CapabilityLedgerTable capabilityLedger = $CapabilityLedgerTable(
    this,
  );
  late final $RulePacksTable rulePacks = $RulePacksTable(this);
  late final $IngestionCheckpointsTable ingestionCheckpoints =
      $IngestionCheckpointsTable(this);
  late final $TrackingStateTable trackingState = $TrackingStateTable(this);
  late final Index idxParserRulesSenderFamily = Index(
    'idx_parser_rules_sender_family',
    'CREATE UNIQUE INDEX idx_parser_rules_sender_family ON parser_rules (sender_hash, parser_family)',
  );
  late final Index idxSmsEventsReceivedDesc = Index(
    'idx_sms_events_received_desc',
    'CREATE INDEX idx_sms_events_received_desc ON sms_events (received_at_epoch_ms, id)',
  );
  late final Index idxSmsEventsSenderReceived = Index(
    'idx_sms_events_sender_received',
    'CREATE INDEX idx_sms_events_sender_received ON sms_events (sender_key, received_at_epoch_ms, id)',
  );
  late final Index idxMappingRulesLookup = Index(
    'idx_mapping_rules_lookup',
    'CREATE INDEX idx_mapping_rules_lookup ON mapping_rule (sender_matcher, parser_family, instrument_suffix_hash, enabled)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    senderRules,
    trackedSenders,
    smsEvents,
    transactionCandidates,
    activityEvents,
    decisionTraces,
    databaseMetadata,
    appLockState,
    deletionAuditEvents,
    walletAccountCache,
    walletCategoryCache,
    walletLabelCache,
    walletConnectionStatus,
    walletMutations,
    walletRecordLinks,
    mappingRules,
    walletMutationItems,
    capabilityLedger,
    rulePacks,
    ingestionCheckpoints,
    trackingState,
    idxParserRulesSenderFamily,
    idxSmsEventsReceivedDesc,
    idxSmsEventsSenderReceived,
    idxMappingRulesLookup,
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
      Value<int?> smsDisclosureRevision,
      Value<bool> historySmsEnabled,
      Value<int> historyWindowDays,
      Value<int> historyMessageCap,
      Value<bool> autoImportEnabled,
      Value<bool> autoCreateEnabled,
      Value<int> autoImportIntervalMinutes,
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
      Value<int?> smsDisclosureRevision,
      Value<bool> historySmsEnabled,
      Value<int> historyWindowDays,
      Value<int> historyMessageCap,
      Value<bool> autoImportEnabled,
      Value<bool> autoCreateEnabled,
      Value<int> autoImportIntervalMinutes,
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

  ColumnFilters<int> get smsDisclosureRevision => $composableBuilder(
    column: $table.smsDisclosureRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get historySmsEnabled => $composableBuilder(
    column: $table.historySmsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyWindowDays => $composableBuilder(
    column: $table.historyWindowDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyMessageCap => $composableBuilder(
    column: $table.historyMessageCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoImportEnabled => $composableBuilder(
    column: $table.autoImportEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoCreateEnabled => $composableBuilder(
    column: $table.autoCreateEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoImportIntervalMinutes => $composableBuilder(
    column: $table.autoImportIntervalMinutes,
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

  ColumnOrderings<int> get smsDisclosureRevision => $composableBuilder(
    column: $table.smsDisclosureRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get historySmsEnabled => $composableBuilder(
    column: $table.historySmsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyWindowDays => $composableBuilder(
    column: $table.historyWindowDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyMessageCap => $composableBuilder(
    column: $table.historyMessageCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoImportEnabled => $composableBuilder(
    column: $table.autoImportEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoCreateEnabled => $composableBuilder(
    column: $table.autoCreateEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoImportIntervalMinutes => $composableBuilder(
    column: $table.autoImportIntervalMinutes,
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

  GeneratedColumn<int> get smsDisclosureRevision => $composableBuilder(
    column: $table.smsDisclosureRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get historySmsEnabled => $composableBuilder(
    column: $table.historySmsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get historyWindowDays => $composableBuilder(
    column: $table.historyWindowDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get historyMessageCap => $composableBuilder(
    column: $table.historyMessageCap,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoImportEnabled => $composableBuilder(
    column: $table.autoImportEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoCreateEnabled => $composableBuilder(
    column: $table.autoCreateEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoImportIntervalMinutes => $composableBuilder(
    column: $table.autoImportIntervalMinutes,
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
                Value<int?> smsDisclosureRevision = const Value.absent(),
                Value<bool> historySmsEnabled = const Value.absent(),
                Value<int> historyWindowDays = const Value.absent(),
                Value<int> historyMessageCap = const Value.absent(),
                Value<bool> autoImportEnabled = const Value.absent(),
                Value<bool> autoCreateEnabled = const Value.absent(),
                Value<int> autoImportIntervalMinutes = const Value.absent(),
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
                smsDisclosureRevision: smsDisclosureRevision,
                historySmsEnabled: historySmsEnabled,
                historyWindowDays: historyWindowDays,
                historyMessageCap: historyMessageCap,
                autoImportEnabled: autoImportEnabled,
                autoCreateEnabled: autoCreateEnabled,
                autoImportIntervalMinutes: autoImportIntervalMinutes,
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
                Value<int?> smsDisclosureRevision = const Value.absent(),
                Value<bool> historySmsEnabled = const Value.absent(),
                Value<int> historyWindowDays = const Value.absent(),
                Value<int> historyMessageCap = const Value.absent(),
                Value<bool> autoImportEnabled = const Value.absent(),
                Value<bool> autoCreateEnabled = const Value.absent(),
                Value<int> autoImportIntervalMinutes = const Value.absent(),
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
                smsDisclosureRevision: smsDisclosureRevision,
                historySmsEnabled: historySmsEnabled,
                historyWindowDays: historyWindowDays,
                historyMessageCap: historyMessageCap,
                autoImportEnabled: autoImportEnabled,
                autoCreateEnabled: autoCreateEnabled,
                autoImportIntervalMinutes: autoImportIntervalMinutes,
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
      Value<int> priority,
      Value<String?> parserVersion,
      Value<String?> parserChecksum,
    });
typedef $$SenderRulesTableUpdateCompanionBuilder =
    SenderRulesCompanion Function({
      Value<int> id,
      Value<String> senderHash,
      Value<String> parserFamily,
      Value<int> createdAtEpochMs,
      Value<int> priority,
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

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
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

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
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

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

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
                Value<int> priority = const Value.absent(),
                Value<String?> parserVersion = const Value.absent(),
                Value<String?> parserChecksum = const Value.absent(),
              }) => SenderRulesCompanion(
                id: id,
                senderHash: senderHash,
                parserFamily: parserFamily,
                createdAtEpochMs: createdAtEpochMs,
                priority: priority,
                parserVersion: parserVersion,
                parserChecksum: parserChecksum,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String senderHash,
                required String parserFamily,
                required int createdAtEpochMs,
                Value<int> priority = const Value.absent(),
                Value<String?> parserVersion = const Value.absent(),
                Value<String?> parserChecksum = const Value.absent(),
              }) => SenderRulesCompanion.insert(
                id: id,
                senderHash: senderHash,
                parserFamily: parserFamily,
                createdAtEpochMs: createdAtEpochMs,
                priority: priority,
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
typedef $$TrackedSendersTableCreateCompanionBuilder =
    TrackedSendersCompanion Function({
      required String senderKey,
      Value<String?> senderDisplay,
      Value<bool> enabled,
      required int addedAtEpochMs,
      Value<int> rowid,
    });
typedef $$TrackedSendersTableUpdateCompanionBuilder =
    TrackedSendersCompanion Function({
      Value<String> senderKey,
      Value<String?> senderDisplay,
      Value<bool> enabled,
      Value<int> addedAtEpochMs,
      Value<int> rowid,
    });

class $$TrackedSendersTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedSendersTable> {
  $$TrackedSendersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get senderKey => $composableBuilder(
    column: $table.senderKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderDisplay => $composableBuilder(
    column: $table.senderDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAtEpochMs => $composableBuilder(
    column: $table.addedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackedSendersTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedSendersTable> {
  $$TrackedSendersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get senderKey => $composableBuilder(
    column: $table.senderKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderDisplay => $composableBuilder(
    column: $table.senderDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAtEpochMs => $composableBuilder(
    column: $table.addedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackedSendersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedSendersTable> {
  $$TrackedSendersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get senderKey =>
      $composableBuilder(column: $table.senderKey, builder: (column) => column);

  GeneratedColumn<String> get senderDisplay => $composableBuilder(
    column: $table.senderDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get addedAtEpochMs => $composableBuilder(
    column: $table.addedAtEpochMs,
    builder: (column) => column,
  );
}

class $$TrackedSendersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackedSendersTable,
          TrackedSenderRow,
          $$TrackedSendersTableFilterComposer,
          $$TrackedSendersTableOrderingComposer,
          $$TrackedSendersTableAnnotationComposer,
          $$TrackedSendersTableCreateCompanionBuilder,
          $$TrackedSendersTableUpdateCompanionBuilder,
          (
            TrackedSenderRow,
            BaseReferences<
              _$AppDatabase,
              $TrackedSendersTable,
              TrackedSenderRow
            >,
          ),
          TrackedSenderRow,
          PrefetchHooks Function()
        > {
  $$TrackedSendersTableTableManager(
    _$AppDatabase db,
    $TrackedSendersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedSendersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedSendersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedSendersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> senderKey = const Value.absent(),
                Value<String?> senderDisplay = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> addedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedSendersCompanion(
                senderKey: senderKey,
                senderDisplay: senderDisplay,
                enabled: enabled,
                addedAtEpochMs: addedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String senderKey,
                Value<String?> senderDisplay = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                required int addedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => TrackedSendersCompanion.insert(
                senderKey: senderKey,
                senderDisplay: senderDisplay,
                enabled: enabled,
                addedAtEpochMs: addedAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackedSendersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackedSendersTable,
      TrackedSenderRow,
      $$TrackedSendersTableFilterComposer,
      $$TrackedSendersTableOrderingComposer,
      $$TrackedSendersTableAnnotationComposer,
      $$TrackedSendersTableCreateCompanionBuilder,
      $$TrackedSendersTableUpdateCompanionBuilder,
      (
        TrackedSenderRow,
        BaseReferences<_$AppDatabase, $TrackedSendersTable, TrackedSenderRow>,
      ),
      TrackedSenderRow,
      PrefetchHooks Function()
    >;
typedef $$SmsEventsTableCreateCompanionBuilder =
    SmsEventsCompanion Function({
      Value<int> id,
      required String sourceKey,
      required String senderKey,
      Value<String?> senderDisplay,
      Value<String?> encryptedBody,
      Value<String?> redactedBody,
      required String ingestionSource,
      required int receivedAtEpochMs,
      Value<int?> expiresAtEpochMs,
      required SmsEventStatus status,
      required int privacyEpoch,
      Value<int?> providerRowId,
      Value<int> captureCanonicalizationVersion,
      Value<int> redactionVersion,
      Value<RawPurgeState> rawPurgeState,
      Value<String?> contentSha256,
    });
typedef $$SmsEventsTableUpdateCompanionBuilder =
    SmsEventsCompanion Function({
      Value<int> id,
      Value<String> sourceKey,
      Value<String> senderKey,
      Value<String?> senderDisplay,
      Value<String?> encryptedBody,
      Value<String?> redactedBody,
      Value<String> ingestionSource,
      Value<int> receivedAtEpochMs,
      Value<int?> expiresAtEpochMs,
      Value<SmsEventStatus> status,
      Value<int> privacyEpoch,
      Value<int?> providerRowId,
      Value<int> captureCanonicalizationVersion,
      Value<int> redactionVersion,
      Value<RawPurgeState> rawPurgeState,
      Value<String?> contentSha256,
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

  ColumnFilters<String> get senderKey => $composableBuilder(
    column: $table.senderKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderDisplay => $composableBuilder(
    column: $table.senderDisplay,
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

  ColumnWithTypeConverterFilters<SmsEventStatus, SmsEventStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get providerRowId => $composableBuilder(
    column: $table.providerRowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get captureCanonicalizationVersion => $composableBuilder(
    column: $table.captureCanonicalizationVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redactionVersion => $composableBuilder(
    column: $table.redactionVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RawPurgeState, RawPurgeState, String>
  get rawPurgeState => $composableBuilder(
    column: $table.rawPurgeState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
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

  ColumnOrderings<String> get senderKey => $composableBuilder(
    column: $table.senderKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderDisplay => $composableBuilder(
    column: $table.senderDisplay,
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

  ColumnOrderings<int> get providerRowId => $composableBuilder(
    column: $table.providerRowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get captureCanonicalizationVersion => $composableBuilder(
    column: $table.captureCanonicalizationVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redactionVersion => $composableBuilder(
    column: $table.redactionVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawPurgeState => $composableBuilder(
    column: $table.rawPurgeState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
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

  GeneratedColumn<String> get senderKey =>
      $composableBuilder(column: $table.senderKey, builder: (column) => column);

  GeneratedColumn<String> get senderDisplay => $composableBuilder(
    column: $table.senderDisplay,
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

  GeneratedColumnWithTypeConverter<SmsEventStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get providerRowId => $composableBuilder(
    column: $table.providerRowId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get captureCanonicalizationVersion => $composableBuilder(
    column: $table.captureCanonicalizationVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redactionVersion => $composableBuilder(
    column: $table.redactionVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RawPurgeState, String> get rawPurgeState =>
      $composableBuilder(
        column: $table.rawPurgeState,
        builder: (column) => column,
      );

  GeneratedColumn<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
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
                Value<String> senderKey = const Value.absent(),
                Value<String?> senderDisplay = const Value.absent(),
                Value<String?> encryptedBody = const Value.absent(),
                Value<String?> redactedBody = const Value.absent(),
                Value<String> ingestionSource = const Value.absent(),
                Value<int> receivedAtEpochMs = const Value.absent(),
                Value<int?> expiresAtEpochMs = const Value.absent(),
                Value<SmsEventStatus> status = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
                Value<int?> providerRowId = const Value.absent(),
                Value<int> captureCanonicalizationVersion =
                    const Value.absent(),
                Value<int> redactionVersion = const Value.absent(),
                Value<RawPurgeState> rawPurgeState = const Value.absent(),
                Value<String?> contentSha256 = const Value.absent(),
              }) => SmsEventsCompanion(
                id: id,
                sourceKey: sourceKey,
                senderKey: senderKey,
                senderDisplay: senderDisplay,
                encryptedBody: encryptedBody,
                redactedBody: redactedBody,
                ingestionSource: ingestionSource,
                receivedAtEpochMs: receivedAtEpochMs,
                expiresAtEpochMs: expiresAtEpochMs,
                status: status,
                privacyEpoch: privacyEpoch,
                providerRowId: providerRowId,
                captureCanonicalizationVersion: captureCanonicalizationVersion,
                redactionVersion: redactionVersion,
                rawPurgeState: rawPurgeState,
                contentSha256: contentSha256,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceKey,
                required String senderKey,
                Value<String?> senderDisplay = const Value.absent(),
                Value<String?> encryptedBody = const Value.absent(),
                Value<String?> redactedBody = const Value.absent(),
                required String ingestionSource,
                required int receivedAtEpochMs,
                Value<int?> expiresAtEpochMs = const Value.absent(),
                required SmsEventStatus status,
                required int privacyEpoch,
                Value<int?> providerRowId = const Value.absent(),
                Value<int> captureCanonicalizationVersion =
                    const Value.absent(),
                Value<int> redactionVersion = const Value.absent(),
                Value<RawPurgeState> rawPurgeState = const Value.absent(),
                Value<String?> contentSha256 = const Value.absent(),
              }) => SmsEventsCompanion.insert(
                id: id,
                sourceKey: sourceKey,
                senderKey: senderKey,
                senderDisplay: senderDisplay,
                encryptedBody: encryptedBody,
                redactedBody: redactedBody,
                ingestionSource: ingestionSource,
                receivedAtEpochMs: receivedAtEpochMs,
                expiresAtEpochMs: expiresAtEpochMs,
                status: status,
                privacyEpoch: privacyEpoch,
                providerRowId: providerRowId,
                captureCanonicalizationVersion: captureCanonicalizationVersion,
                redactionVersion: redactionVersion,
                rawPurgeState: rawPurgeState,
                contentSha256: contentSha256,
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
      Value<String?> candidateId,
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
      Value<TransactionKind?> kind,
      Value<TransactionDirection?> direction,
      Value<FinancialLifecycle?> lifecycle,
      Value<int?> originalAmountMinor,
      Value<int?> walletAmountMinor,
      Value<int?> transactionAtEpochMs,
      Value<String?> dateEvidence,
      Value<String?> counterpartyRedacted,
      Value<String?> instrumentSuffixHash,
      Value<int?> availableBalanceMinor,
      Value<String?> paymentType,
      Value<int?> confidenceBasisPoints,
      Value<String?> parserRuleId,
      Value<String?> parserRuleVersion,
      Value<String?> rulePackId,
      Value<String?> rulePackVersion,
      Value<String?> reviewReasons,
      Value<String?> transactionFingerprint,
    });
typedef $$TransactionCandidatesTableUpdateCompanionBuilder =
    TransactionCandidatesCompanion Function({
      Value<int> id,
      Value<String?> candidateId,
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
      Value<TransactionKind?> kind,
      Value<TransactionDirection?> direction,
      Value<FinancialLifecycle?> lifecycle,
      Value<int?> originalAmountMinor,
      Value<int?> walletAmountMinor,
      Value<int?> transactionAtEpochMs,
      Value<String?> dateEvidence,
      Value<String?> counterpartyRedacted,
      Value<String?> instrumentSuffixHash,
      Value<int?> availableBalanceMinor,
      Value<String?> paymentType,
      Value<int?> confidenceBasisPoints,
      Value<String?> parserRuleId,
      Value<String?> parserRuleVersion,
      Value<String?> rulePackId,
      Value<String?> rulePackVersion,
      Value<String?> reviewReasons,
      Value<String?> transactionFingerprint,
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

  ColumnFilters<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
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

  ColumnWithTypeConverterFilters<TransactionKind?, TransactionKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TransactionDirection?,
    TransactionDirection,
    String
  >
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    FinancialLifecycle?,
    FinancialLifecycle,
    String
  >
  get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walletAmountMinor => $composableBuilder(
    column: $table.walletAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionAtEpochMs => $composableBuilder(
    column: $table.transactionAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateEvidence => $composableBuilder(
    column: $table.dateEvidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartyRedacted => $composableBuilder(
    column: $table.counterpartyRedacted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentSuffixHash => $composableBuilder(
    column: $table.instrumentSuffixHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableBalanceMinor => $composableBuilder(
    column: $table.availableBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidenceBasisPoints => $composableBuilder(
    column: $table.confidenceBasisPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserRuleId => $composableBuilder(
    column: $table.parserRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserRuleVersion => $composableBuilder(
    column: $table.parserRuleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulePackId => $composableBuilder(
    column: $table.rulePackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulePackVersion => $composableBuilder(
    column: $table.rulePackVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewReasons => $composableBuilder(
    column: $table.reviewReasons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionFingerprint => $composableBuilder(
    column: $table.transactionFingerprint,
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

  ColumnOrderings<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walletAmountMinor => $composableBuilder(
    column: $table.walletAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionAtEpochMs => $composableBuilder(
    column: $table.transactionAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateEvidence => $composableBuilder(
    column: $table.dateEvidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartyRedacted => $composableBuilder(
    column: $table.counterpartyRedacted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentSuffixHash => $composableBuilder(
    column: $table.instrumentSuffixHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableBalanceMinor => $composableBuilder(
    column: $table.availableBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidenceBasisPoints => $composableBuilder(
    column: $table.confidenceBasisPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserRuleId => $composableBuilder(
    column: $table.parserRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserRuleVersion => $composableBuilder(
    column: $table.parserRuleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulePackId => $composableBuilder(
    column: $table.rulePackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulePackVersion => $composableBuilder(
    column: $table.rulePackVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewReasons => $composableBuilder(
    column: $table.reviewReasons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionFingerprint => $composableBuilder(
    column: $table.transactionFingerprint,
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

  GeneratedColumn<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => column,
  );

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

  GeneratedColumnWithTypeConverter<TransactionKind?, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionDirection?, String>
  get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FinancialLifecycle?, String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get walletAmountMinor => $composableBuilder(
    column: $table.walletAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionAtEpochMs => $composableBuilder(
    column: $table.transactionAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateEvidence => $composableBuilder(
    column: $table.dateEvidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counterpartyRedacted => $composableBuilder(
    column: $table.counterpartyRedacted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instrumentSuffixHash => $composableBuilder(
    column: $table.instrumentSuffixHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availableBalanceMinor => $composableBuilder(
    column: $table.availableBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidenceBasisPoints => $composableBuilder(
    column: $table.confidenceBasisPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserRuleId => $composableBuilder(
    column: $table.parserRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserRuleVersion => $composableBuilder(
    column: $table.parserRuleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rulePackId => $composableBuilder(
    column: $table.rulePackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rulePackVersion => $composableBuilder(
    column: $table.rulePackVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewReasons => $composableBuilder(
    column: $table.reviewReasons,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionFingerprint => $composableBuilder(
    column: $table.transactionFingerprint,
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
                Value<String?> candidateId = const Value.absent(),
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
                Value<TransactionKind?> kind = const Value.absent(),
                Value<TransactionDirection?> direction = const Value.absent(),
                Value<FinancialLifecycle?> lifecycle = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<int?> walletAmountMinor = const Value.absent(),
                Value<int?> transactionAtEpochMs = const Value.absent(),
                Value<String?> dateEvidence = const Value.absent(),
                Value<String?> counterpartyRedacted = const Value.absent(),
                Value<String?> instrumentSuffixHash = const Value.absent(),
                Value<int?> availableBalanceMinor = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                Value<int?> confidenceBasisPoints = const Value.absent(),
                Value<String?> parserRuleId = const Value.absent(),
                Value<String?> parserRuleVersion = const Value.absent(),
                Value<String?> rulePackId = const Value.absent(),
                Value<String?> rulePackVersion = const Value.absent(),
                Value<String?> reviewReasons = const Value.absent(),
                Value<String?> transactionFingerprint = const Value.absent(),
              }) => TransactionCandidatesCompanion(
                id: id,
                candidateId: candidateId,
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
                kind: kind,
                direction: direction,
                lifecycle: lifecycle,
                originalAmountMinor: originalAmountMinor,
                walletAmountMinor: walletAmountMinor,
                transactionAtEpochMs: transactionAtEpochMs,
                dateEvidence: dateEvidence,
                counterpartyRedacted: counterpartyRedacted,
                instrumentSuffixHash: instrumentSuffixHash,
                availableBalanceMinor: availableBalanceMinor,
                paymentType: paymentType,
                confidenceBasisPoints: confidenceBasisPoints,
                parserRuleId: parserRuleId,
                parserRuleVersion: parserRuleVersion,
                rulePackId: rulePackId,
                rulePackVersion: rulePackVersion,
                reviewReasons: reviewReasons,
                transactionFingerprint: transactionFingerprint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> candidateId = const Value.absent(),
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
                Value<TransactionKind?> kind = const Value.absent(),
                Value<TransactionDirection?> direction = const Value.absent(),
                Value<FinancialLifecycle?> lifecycle = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<int?> walletAmountMinor = const Value.absent(),
                Value<int?> transactionAtEpochMs = const Value.absent(),
                Value<String?> dateEvidence = const Value.absent(),
                Value<String?> counterpartyRedacted = const Value.absent(),
                Value<String?> instrumentSuffixHash = const Value.absent(),
                Value<int?> availableBalanceMinor = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                Value<int?> confidenceBasisPoints = const Value.absent(),
                Value<String?> parserRuleId = const Value.absent(),
                Value<String?> parserRuleVersion = const Value.absent(),
                Value<String?> rulePackId = const Value.absent(),
                Value<String?> rulePackVersion = const Value.absent(),
                Value<String?> reviewReasons = const Value.absent(),
                Value<String?> transactionFingerprint = const Value.absent(),
              }) => TransactionCandidatesCompanion.insert(
                id: id,
                candidateId: candidateId,
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
                kind: kind,
                direction: direction,
                lifecycle: lifecycle,
                originalAmountMinor: originalAmountMinor,
                walletAmountMinor: walletAmountMinor,
                transactionAtEpochMs: transactionAtEpochMs,
                dateEvidence: dateEvidence,
                counterpartyRedacted: counterpartyRedacted,
                instrumentSuffixHash: instrumentSuffixHash,
                availableBalanceMinor: availableBalanceMinor,
                paymentType: paymentType,
                confidenceBasisPoints: confidenceBasisPoints,
                parserRuleId: parserRuleId,
                parserRuleVersion: parserRuleVersion,
                rulePackId: rulePackId,
                rulePackVersion: rulePackVersion,
                reviewReasons: reviewReasons,
                transactionFingerprint: transactionFingerprint,
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
      Value<int?> batchCount,
      Value<String?> mutationId,
      Value<String?> detailMessage,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<int> id,
      Value<ActivityEventCode> eventType,
      Value<ActivityStateTransition> sanitizedDetail,
      Value<int> occurredAtEpochMs,
      Value<int> privacyEpoch,
      Value<int?> batchCount,
      Value<String?> mutationId,
      Value<String?> detailMessage,
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

  ColumnFilters<int> get batchCount => $composableBuilder(
    column: $table.batchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailMessage => $composableBuilder(
    column: $table.detailMessage,
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

  ColumnOrderings<int> get batchCount => $composableBuilder(
    column: $table.batchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailMessage => $composableBuilder(
    column: $table.detailMessage,
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

  GeneratedColumn<int> get batchCount => $composableBuilder(
    column: $table.batchCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailMessage => $composableBuilder(
    column: $table.detailMessage,
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
                Value<int?> batchCount = const Value.absent(),
                Value<String?> mutationId = const Value.absent(),
                Value<String?> detailMessage = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                eventType: eventType,
                sanitizedDetail: sanitizedDetail,
                occurredAtEpochMs: occurredAtEpochMs,
                privacyEpoch: privacyEpoch,
                batchCount: batchCount,
                mutationId: mutationId,
                detailMessage: detailMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ActivityEventCode eventType,
                required ActivityStateTransition sanitizedDetail,
                required int occurredAtEpochMs,
                required int privacyEpoch,
                Value<int?> batchCount = const Value.absent(),
                Value<String?> mutationId = const Value.absent(),
                Value<String?> detailMessage = const Value.absent(),
              }) => ActivityEventsCompanion.insert(
                id: id,
                eventType: eventType,
                sanitizedDetail: sanitizedDetail,
                occurredAtEpochMs: occurredAtEpochMs,
                privacyEpoch: privacyEpoch,
                batchCount: batchCount,
                mutationId: mutationId,
                detailMessage: detailMessage,
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
      Value<DecisionStage?> stage,
      Value<String?> rulePackVersion,
      Value<String?> outcomeCode,
    });
typedef $$DecisionTracesTableUpdateCompanionBuilder =
    DecisionTracesCompanion Function({
      Value<int> id,
      Value<int?> candidateId,
      Value<DecisionTraceCode> traceCode,
      Value<int> createdAtEpochMs,
      Value<DecisionStage?> stage,
      Value<String?> rulePackVersion,
      Value<String?> outcomeCode,
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

  ColumnWithTypeConverterFilters<DecisionStage?, DecisionStage, String>
  get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rulePackVersion => $composableBuilder(
    column: $table.rulePackVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcomeCode => $composableBuilder(
    column: $table.outcomeCode,
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

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulePackVersion => $composableBuilder(
    column: $table.rulePackVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcomeCode => $composableBuilder(
    column: $table.outcomeCode,
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

  GeneratedColumnWithTypeConverter<DecisionStage?, String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get rulePackVersion => $composableBuilder(
    column: $table.rulePackVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcomeCode => $composableBuilder(
    column: $table.outcomeCode,
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
                Value<DecisionStage?> stage = const Value.absent(),
                Value<String?> rulePackVersion = const Value.absent(),
                Value<String?> outcomeCode = const Value.absent(),
              }) => DecisionTracesCompanion(
                id: id,
                candidateId: candidateId,
                traceCode: traceCode,
                createdAtEpochMs: createdAtEpochMs,
                stage: stage,
                rulePackVersion: rulePackVersion,
                outcomeCode: outcomeCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> candidateId = const Value.absent(),
                required DecisionTraceCode traceCode,
                required int createdAtEpochMs,
                Value<DecisionStage?> stage = const Value.absent(),
                Value<String?> rulePackVersion = const Value.absent(),
                Value<String?> outcomeCode = const Value.absent(),
              }) => DecisionTracesCompanion.insert(
                id: id,
                candidateId: candidateId,
                traceCode: traceCode,
                createdAtEpochMs: createdAtEpochMs,
                stage: stage,
                rulePackVersion: rulePackVersion,
                outcomeCode: outcomeCode,
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
      Value<String> groupId,
      Value<String> groupName,
      Value<String?> parentId,
      Value<String?> systemId,
      required int refreshedAtEpochMs,
      Value<int> rowid,
    });
typedef $$WalletCategoryCacheTableUpdateCompanionBuilder =
    WalletCategoryCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> groupId,
      Value<String> groupName,
      Value<String?> parentId,
      Value<String?> systemId,
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

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemId => $composableBuilder(
    column: $table.systemId,
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

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemId => $composableBuilder(
    column: $table.systemId,
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

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get systemId =>
      $composableBuilder(column: $table.systemId, builder: (column) => column);

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
                Value<String> groupId = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> systemId = const Value.absent(),
                Value<int> refreshedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletCategoryCacheCompanion(
                id: id,
                name: name,
                groupId: groupId,
                groupName: groupName,
                parentId: parentId,
                systemId: systemId,
                refreshedAtEpochMs: refreshedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> groupId = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> systemId = const Value.absent(),
                required int refreshedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => WalletCategoryCacheCompanion.insert(
                id: id,
                name: name,
                groupId: groupId,
                groupName: groupName,
                parentId: parentId,
                systemId: systemId,
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
typedef $$WalletLabelCacheTableCreateCompanionBuilder =
    WalletLabelCacheCompanion Function({
      required String id,
      required String name,
      required int refreshedAtEpochMs,
      Value<int> rowid,
    });
typedef $$WalletLabelCacheTableUpdateCompanionBuilder =
    WalletLabelCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> refreshedAtEpochMs,
      Value<int> rowid,
    });

class $$WalletLabelCacheTableFilterComposer
    extends Composer<_$AppDatabase, $WalletLabelCacheTable> {
  $$WalletLabelCacheTableFilterComposer({
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

class $$WalletLabelCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletLabelCacheTable> {
  $$WalletLabelCacheTableOrderingComposer({
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

class $$WalletLabelCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletLabelCacheTable> {
  $$WalletLabelCacheTableAnnotationComposer({
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

class $$WalletLabelCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletLabelCacheTable,
          WalletLabelCacheData,
          $$WalletLabelCacheTableFilterComposer,
          $$WalletLabelCacheTableOrderingComposer,
          $$WalletLabelCacheTableAnnotationComposer,
          $$WalletLabelCacheTableCreateCompanionBuilder,
          $$WalletLabelCacheTableUpdateCompanionBuilder,
          (
            WalletLabelCacheData,
            BaseReferences<
              _$AppDatabase,
              $WalletLabelCacheTable,
              WalletLabelCacheData
            >,
          ),
          WalletLabelCacheData,
          PrefetchHooks Function()
        > {
  $$WalletLabelCacheTableTableManager(
    _$AppDatabase db,
    $WalletLabelCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletLabelCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletLabelCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletLabelCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> refreshedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletLabelCacheCompanion(
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
              }) => WalletLabelCacheCompanion.insert(
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

typedef $$WalletLabelCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletLabelCacheTable,
      WalletLabelCacheData,
      $$WalletLabelCacheTableFilterComposer,
      $$WalletLabelCacheTableOrderingComposer,
      $$WalletLabelCacheTableAnnotationComposer,
      $$WalletLabelCacheTableCreateCompanionBuilder,
      $$WalletLabelCacheTableUpdateCompanionBuilder,
      (
        WalletLabelCacheData,
        BaseReferences<
          _$AppDatabase,
          $WalletLabelCacheTable,
          WalletLabelCacheData
        >,
      ),
      WalletLabelCacheData,
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
      required WalletMutationOperation operationKind,
      required String payload,
      required WalletMutationState state,
      required String lineageKey,
      required String fingerprint,
      required int createdAtEpochMs,
      required int updatedAtEpochMs,
      Value<String?> candidateId,
      Value<int?> operationRevision,
      Value<int?> lineageGeneration,
      Value<String?> payloadJsonCiphertext,
      Value<String?> sourceMarker,
      Value<int?> attemptCount,
      Value<int?> nextAttemptAtEpochMs,
      Value<int?> leaseUntilEpochMs,
      Value<int?> lastHttpStatus,
      Value<String?> walletCorrelationId,
      Value<int> rowid,
    });
typedef $$WalletMutationsTableUpdateCompanionBuilder =
    WalletMutationsCompanion Function({
      Value<String> id,
      Value<WalletMutationOperation> operationKind,
      Value<String> payload,
      Value<WalletMutationState> state,
      Value<String> lineageKey,
      Value<String> fingerprint,
      Value<int> createdAtEpochMs,
      Value<int> updatedAtEpochMs,
      Value<String?> candidateId,
      Value<int?> operationRevision,
      Value<int?> lineageGeneration,
      Value<String?> payloadJsonCiphertext,
      Value<String?> sourceMarker,
      Value<int?> attemptCount,
      Value<int?> nextAttemptAtEpochMs,
      Value<int?> leaseUntilEpochMs,
      Value<int?> lastHttpStatus,
      Value<String?> walletCorrelationId,
      Value<int> rowid,
    });

final class $$WalletMutationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WalletMutationsTable, WalletMutation> {
  $$WalletMutationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $WalletMutationItemsTable,
    List<WalletMutationItem>
  >
  _walletMutationItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.walletMutationItems,
        aliasName:
            'wallet_mutations__id__wallet_mutation_item__wallet_mutation_id',
      );

  $$WalletMutationItemsTableProcessedTableManager get walletMutationItemsRefs {
    final manager =
        $$WalletMutationItemsTableTableManager(
          $_db,
          $_db.walletMutationItems,
        ).filter(
          (f) => f.walletMutationId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _walletMutationItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnWithTypeConverterFilters<
    WalletMutationOperation,
    WalletMutationOperation,
    String
  >
  get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    WalletMutationState,
    WalletMutationState,
    String
  >
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnFilters<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operationRevision => $composableBuilder(
    column: $table.operationRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineageGeneration => $composableBuilder(
    column: $table.lineageGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJsonCiphertext => $composableBuilder(
    column: $table.payloadJsonCiphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceMarker => $composableBuilder(
    column: $table.sourceMarker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAtEpochMs => $composableBuilder(
    column: $table.nextAttemptAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leaseUntilEpochMs => $composableBuilder(
    column: $table.leaseUntilEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastHttpStatus => $composableBuilder(
    column: $table.lastHttpStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletCorrelationId => $composableBuilder(
    column: $table.walletCorrelationId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> walletMutationItemsRefs(
    Expression<bool> Function($$WalletMutationItemsTableFilterComposer f) f,
  ) {
    final $$WalletMutationItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.walletMutationItems,
      getReferencedColumn: (t) => t.walletMutationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletMutationItemsTableFilterComposer(
            $db: $db,
            $table: $db.walletMutationItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
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

  ColumnOrderings<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operationRevision => $composableBuilder(
    column: $table.operationRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineageGeneration => $composableBuilder(
    column: $table.lineageGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJsonCiphertext => $composableBuilder(
    column: $table.payloadJsonCiphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMarker => $composableBuilder(
    column: $table.sourceMarker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAtEpochMs => $composableBuilder(
    column: $table.nextAttemptAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leaseUntilEpochMs => $composableBuilder(
    column: $table.leaseUntilEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastHttpStatus => $composableBuilder(
    column: $table.lastHttpStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletCorrelationId => $composableBuilder(
    column: $table.walletCorrelationId,
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

  GeneratedColumnWithTypeConverter<WalletMutationOperation, String>
  get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WalletMutationState, String> get state =>
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

  GeneratedColumn<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get operationRevision => $composableBuilder(
    column: $table.operationRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineageGeneration => $composableBuilder(
    column: $table.lineageGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJsonCiphertext => $composableBuilder(
    column: $table.payloadJsonCiphertext,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceMarker => $composableBuilder(
    column: $table.sourceMarker,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextAttemptAtEpochMs => $composableBuilder(
    column: $table.nextAttemptAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get leaseUntilEpochMs => $composableBuilder(
    column: $table.leaseUntilEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastHttpStatus => $composableBuilder(
    column: $table.lastHttpStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walletCorrelationId => $composableBuilder(
    column: $table.walletCorrelationId,
    builder: (column) => column,
  );

  Expression<T> walletMutationItemsRefs<T extends Object>(
    Expression<T> Function($$WalletMutationItemsTableAnnotationComposer a) f,
  ) {
    final $$WalletMutationItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.walletMutationItems,
          getReferencedColumn: (t) => t.walletMutationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WalletMutationItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.walletMutationItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (WalletMutation, $$WalletMutationsTableReferences),
          WalletMutation,
          PrefetchHooks Function({bool walletMutationItemsRefs})
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
                Value<WalletMutationOperation> operationKind =
                    const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<WalletMutationState> state = const Value.absent(),
                Value<String> lineageKey = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
                Value<int> updatedAtEpochMs = const Value.absent(),
                Value<String?> candidateId = const Value.absent(),
                Value<int?> operationRevision = const Value.absent(),
                Value<int?> lineageGeneration = const Value.absent(),
                Value<String?> payloadJsonCiphertext = const Value.absent(),
                Value<String?> sourceMarker = const Value.absent(),
                Value<int?> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAtEpochMs = const Value.absent(),
                Value<int?> leaseUntilEpochMs = const Value.absent(),
                Value<int?> lastHttpStatus = const Value.absent(),
                Value<String?> walletCorrelationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletMutationsCompanion(
                id: id,
                operationKind: operationKind,
                payload: payload,
                state: state,
                lineageKey: lineageKey,
                fingerprint: fingerprint,
                createdAtEpochMs: createdAtEpochMs,
                updatedAtEpochMs: updatedAtEpochMs,
                candidateId: candidateId,
                operationRevision: operationRevision,
                lineageGeneration: lineageGeneration,
                payloadJsonCiphertext: payloadJsonCiphertext,
                sourceMarker: sourceMarker,
                attemptCount: attemptCount,
                nextAttemptAtEpochMs: nextAttemptAtEpochMs,
                leaseUntilEpochMs: leaseUntilEpochMs,
                lastHttpStatus: lastHttpStatus,
                walletCorrelationId: walletCorrelationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required WalletMutationOperation operationKind,
                required String payload,
                required WalletMutationState state,
                required String lineageKey,
                required String fingerprint,
                required int createdAtEpochMs,
                required int updatedAtEpochMs,
                Value<String?> candidateId = const Value.absent(),
                Value<int?> operationRevision = const Value.absent(),
                Value<int?> lineageGeneration = const Value.absent(),
                Value<String?> payloadJsonCiphertext = const Value.absent(),
                Value<String?> sourceMarker = const Value.absent(),
                Value<int?> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAtEpochMs = const Value.absent(),
                Value<int?> leaseUntilEpochMs = const Value.absent(),
                Value<int?> lastHttpStatus = const Value.absent(),
                Value<String?> walletCorrelationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletMutationsCompanion.insert(
                id: id,
                operationKind: operationKind,
                payload: payload,
                state: state,
                lineageKey: lineageKey,
                fingerprint: fingerprint,
                createdAtEpochMs: createdAtEpochMs,
                updatedAtEpochMs: updatedAtEpochMs,
                candidateId: candidateId,
                operationRevision: operationRevision,
                lineageGeneration: lineageGeneration,
                payloadJsonCiphertext: payloadJsonCiphertext,
                sourceMarker: sourceMarker,
                attemptCount: attemptCount,
                nextAttemptAtEpochMs: nextAttemptAtEpochMs,
                leaseUntilEpochMs: leaseUntilEpochMs,
                lastHttpStatus: lastHttpStatus,
                walletCorrelationId: walletCorrelationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WalletMutationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({walletMutationItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (walletMutationItemsRefs) db.walletMutationItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (walletMutationItemsRefs)
                    await $_getPrefetchedData<
                      WalletMutation,
                      $WalletMutationsTable,
                      WalletMutationItem
                    >(
                      currentTable: table,
                      referencedTable: $$WalletMutationsTableReferences
                          ._walletMutationItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WalletMutationsTableReferences(
                            db,
                            table,
                            p0,
                          ).walletMutationItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.walletMutationId == item.id,
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
      (WalletMutation, $$WalletMutationsTableReferences),
      WalletMutation,
      PrefetchHooks Function({bool walletMutationItemsRefs})
    >;
typedef $$WalletRecordLinksTableCreateCompanionBuilder =
    WalletRecordLinksCompanion Function({
      required String id,
      required String appId,
      Value<String?> remoteId,
      required int createdAtEpochMs,
      Value<String?> candidateId,
      Value<WalletItemLegRole?> legRole,
      Value<String?> pairGroupId,
      Value<int?> lastKnownRevision,
      Value<String?> lastKnownState,
      Value<int?> updatedAtEpochMs,
      Value<int?> deletedAtEpochMs,
      Value<bool?> remoteDeletedTombstone,
      Value<int> rowid,
    });
typedef $$WalletRecordLinksTableUpdateCompanionBuilder =
    WalletRecordLinksCompanion Function({
      Value<String> id,
      Value<String> appId,
      Value<String?> remoteId,
      Value<int> createdAtEpochMs,
      Value<String?> candidateId,
      Value<WalletItemLegRole?> legRole,
      Value<String?> pairGroupId,
      Value<int?> lastKnownRevision,
      Value<String?> lastKnownState,
      Value<int?> updatedAtEpochMs,
      Value<int?> deletedAtEpochMs,
      Value<bool?> remoteDeletedTombstone,
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

  ColumnFilters<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WalletItemLegRole?, WalletItemLegRole, String>
  get legRole => $composableBuilder(
    column: $table.legRole,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get pairGroupId => $composableBuilder(
    column: $table.pairGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastKnownRevision => $composableBuilder(
    column: $table.lastKnownRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastKnownState => $composableBuilder(
    column: $table.lastKnownState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtEpochMs => $composableBuilder(
    column: $table.deletedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remoteDeletedTombstone => $composableBuilder(
    column: $table.remoteDeletedTombstone,
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

  ColumnOrderings<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legRole => $composableBuilder(
    column: $table.legRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pairGroupId => $composableBuilder(
    column: $table.pairGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastKnownRevision => $composableBuilder(
    column: $table.lastKnownRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastKnownState => $composableBuilder(
    column: $table.lastKnownState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtEpochMs => $composableBuilder(
    column: $table.deletedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remoteDeletedTombstone => $composableBuilder(
    column: $table.remoteDeletedTombstone,
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

  GeneratedColumn<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WalletItemLegRole?, String> get legRole =>
      $composableBuilder(column: $table.legRole, builder: (column) => column);

  GeneratedColumn<String> get pairGroupId => $composableBuilder(
    column: $table.pairGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastKnownRevision => $composableBuilder(
    column: $table.lastKnownRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastKnownState => $composableBuilder(
    column: $table.lastKnownState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtEpochMs => $composableBuilder(
    column: $table.deletedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remoteDeletedTombstone => $composableBuilder(
    column: $table.remoteDeletedTombstone,
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
                Value<String?> candidateId = const Value.absent(),
                Value<WalletItemLegRole?> legRole = const Value.absent(),
                Value<String?> pairGroupId = const Value.absent(),
                Value<int?> lastKnownRevision = const Value.absent(),
                Value<String?> lastKnownState = const Value.absent(),
                Value<int?> updatedAtEpochMs = const Value.absent(),
                Value<int?> deletedAtEpochMs = const Value.absent(),
                Value<bool?> remoteDeletedTombstone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletRecordLinksCompanion(
                id: id,
                appId: appId,
                remoteId: remoteId,
                createdAtEpochMs: createdAtEpochMs,
                candidateId: candidateId,
                legRole: legRole,
                pairGroupId: pairGroupId,
                lastKnownRevision: lastKnownRevision,
                lastKnownState: lastKnownState,
                updatedAtEpochMs: updatedAtEpochMs,
                deletedAtEpochMs: deletedAtEpochMs,
                remoteDeletedTombstone: remoteDeletedTombstone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String appId,
                Value<String?> remoteId = const Value.absent(),
                required int createdAtEpochMs,
                Value<String?> candidateId = const Value.absent(),
                Value<WalletItemLegRole?> legRole = const Value.absent(),
                Value<String?> pairGroupId = const Value.absent(),
                Value<int?> lastKnownRevision = const Value.absent(),
                Value<String?> lastKnownState = const Value.absent(),
                Value<int?> updatedAtEpochMs = const Value.absent(),
                Value<int?> deletedAtEpochMs = const Value.absent(),
                Value<bool?> remoteDeletedTombstone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletRecordLinksCompanion.insert(
                id: id,
                appId: appId,
                remoteId: remoteId,
                createdAtEpochMs: createdAtEpochMs,
                candidateId: candidateId,
                legRole: legRole,
                pairGroupId: pairGroupId,
                lastKnownRevision: lastKnownRevision,
                lastKnownState: lastKnownState,
                updatedAtEpochMs: updatedAtEpochMs,
                deletedAtEpochMs: deletedAtEpochMs,
                remoteDeletedTombstone: remoteDeletedTombstone,
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
typedef $$MappingRulesTableCreateCompanionBuilder =
    MappingRulesCompanion Function({
      required String id,
      required String name,
      required bool enabled,
      required String senderMatcher,
      Value<String?> parserFamily,
      Value<String?> instrumentSuffixHash,
      Value<TransactionDirection?> direction,
      Value<String?> merchantMatcher,
      required String walletAccountId,
      Value<String?> walletCategoryId,
      required String paymentType,
      required MappingSyncMode syncMode,
      required int priority,
      Value<int?> minConfidenceBasisPoints,
      required int ruleVersion,
      Value<String?> supersededByRuleId,
      required int createdAtEpochMs,
      required int updatedAtEpochMs,
      Value<int> rowid,
    });
typedef $$MappingRulesTableUpdateCompanionBuilder =
    MappingRulesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> enabled,
      Value<String> senderMatcher,
      Value<String?> parserFamily,
      Value<String?> instrumentSuffixHash,
      Value<TransactionDirection?> direction,
      Value<String?> merchantMatcher,
      Value<String> walletAccountId,
      Value<String?> walletCategoryId,
      Value<String> paymentType,
      Value<MappingSyncMode> syncMode,
      Value<int> priority,
      Value<int?> minConfidenceBasisPoints,
      Value<int> ruleVersion,
      Value<String?> supersededByRuleId,
      Value<int> createdAtEpochMs,
      Value<int> updatedAtEpochMs,
      Value<int> rowid,
    });

class $$MappingRulesTableFilterComposer
    extends Composer<_$AppDatabase, $MappingRulesTable> {
  $$MappingRulesTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderMatcher => $composableBuilder(
    column: $table.senderMatcher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserFamily => $composableBuilder(
    column: $table.parserFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentSuffixHash => $composableBuilder(
    column: $table.instrumentSuffixHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TransactionDirection?,
    TransactionDirection,
    String
  >
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get merchantMatcher => $composableBuilder(
    column: $table.merchantMatcher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAccountId => $composableBuilder(
    column: $table.walletAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletCategoryId => $composableBuilder(
    column: $table.walletCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MappingSyncMode, MappingSyncMode, String>
  get syncMode => $composableBuilder(
    column: $table.syncMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minConfidenceBasisPoints => $composableBuilder(
    column: $table.minConfidenceBasisPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersededByRuleId => $composableBuilder(
    column: $table.supersededByRuleId,
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

class $$MappingRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MappingRulesTable> {
  $$MappingRulesTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderMatcher => $composableBuilder(
    column: $table.senderMatcher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserFamily => $composableBuilder(
    column: $table.parserFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentSuffixHash => $composableBuilder(
    column: $table.instrumentSuffixHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantMatcher => $composableBuilder(
    column: $table.merchantMatcher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAccountId => $composableBuilder(
    column: $table.walletAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletCategoryId => $composableBuilder(
    column: $table.walletCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncMode => $composableBuilder(
    column: $table.syncMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minConfidenceBasisPoints => $composableBuilder(
    column: $table.minConfidenceBasisPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersededByRuleId => $composableBuilder(
    column: $table.supersededByRuleId,
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

class $$MappingRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MappingRulesTable> {
  $$MappingRulesTableAnnotationComposer({
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

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get senderMatcher => $composableBuilder(
    column: $table.senderMatcher,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserFamily => $composableBuilder(
    column: $table.parserFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instrumentSuffixHash => $composableBuilder(
    column: $table.instrumentSuffixHash,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TransactionDirection?, String>
  get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get merchantMatcher => $composableBuilder(
    column: $table.merchantMatcher,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walletAccountId => $composableBuilder(
    column: $table.walletAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walletCategoryId => $composableBuilder(
    column: $table.walletCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MappingSyncMode, String> get syncMode =>
      $composableBuilder(column: $table.syncMode, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get minConfidenceBasisPoints => $composableBuilder(
    column: $table.minConfidenceBasisPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supersededByRuleId => $composableBuilder(
    column: $table.supersededByRuleId,
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

class $$MappingRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MappingRulesTable,
          MappingRuleRow,
          $$MappingRulesTableFilterComposer,
          $$MappingRulesTableOrderingComposer,
          $$MappingRulesTableAnnotationComposer,
          $$MappingRulesTableCreateCompanionBuilder,
          $$MappingRulesTableUpdateCompanionBuilder,
          (
            MappingRuleRow,
            BaseReferences<_$AppDatabase, $MappingRulesTable, MappingRuleRow>,
          ),
          MappingRuleRow,
          PrefetchHooks Function()
        > {
  $$MappingRulesTableTableManager(_$AppDatabase db, $MappingRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MappingRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MappingRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MappingRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> senderMatcher = const Value.absent(),
                Value<String?> parserFamily = const Value.absent(),
                Value<String?> instrumentSuffixHash = const Value.absent(),
                Value<TransactionDirection?> direction = const Value.absent(),
                Value<String?> merchantMatcher = const Value.absent(),
                Value<String> walletAccountId = const Value.absent(),
                Value<String?> walletCategoryId = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<MappingSyncMode> syncMode = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int?> minConfidenceBasisPoints = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<String?> supersededByRuleId = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
                Value<int> updatedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MappingRulesCompanion(
                id: id,
                name: name,
                enabled: enabled,
                senderMatcher: senderMatcher,
                parserFamily: parserFamily,
                instrumentSuffixHash: instrumentSuffixHash,
                direction: direction,
                merchantMatcher: merchantMatcher,
                walletAccountId: walletAccountId,
                walletCategoryId: walletCategoryId,
                paymentType: paymentType,
                syncMode: syncMode,
                priority: priority,
                minConfidenceBasisPoints: minConfidenceBasisPoints,
                ruleVersion: ruleVersion,
                supersededByRuleId: supersededByRuleId,
                createdAtEpochMs: createdAtEpochMs,
                updatedAtEpochMs: updatedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required bool enabled,
                required String senderMatcher,
                Value<String?> parserFamily = const Value.absent(),
                Value<String?> instrumentSuffixHash = const Value.absent(),
                Value<TransactionDirection?> direction = const Value.absent(),
                Value<String?> merchantMatcher = const Value.absent(),
                required String walletAccountId,
                Value<String?> walletCategoryId = const Value.absent(),
                required String paymentType,
                required MappingSyncMode syncMode,
                required int priority,
                Value<int?> minConfidenceBasisPoints = const Value.absent(),
                required int ruleVersion,
                Value<String?> supersededByRuleId = const Value.absent(),
                required int createdAtEpochMs,
                required int updatedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => MappingRulesCompanion.insert(
                id: id,
                name: name,
                enabled: enabled,
                senderMatcher: senderMatcher,
                parserFamily: parserFamily,
                instrumentSuffixHash: instrumentSuffixHash,
                direction: direction,
                merchantMatcher: merchantMatcher,
                walletAccountId: walletAccountId,
                walletCategoryId: walletCategoryId,
                paymentType: paymentType,
                syncMode: syncMode,
                priority: priority,
                minConfidenceBasisPoints: minConfidenceBasisPoints,
                ruleVersion: ruleVersion,
                supersededByRuleId: supersededByRuleId,
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

typedef $$MappingRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MappingRulesTable,
      MappingRuleRow,
      $$MappingRulesTableFilterComposer,
      $$MappingRulesTableOrderingComposer,
      $$MappingRulesTableAnnotationComposer,
      $$MappingRulesTableCreateCompanionBuilder,
      $$MappingRulesTableUpdateCompanionBuilder,
      (
        MappingRuleRow,
        BaseReferences<_$AppDatabase, $MappingRulesTable, MappingRuleRow>,
      ),
      MappingRuleRow,
      PrefetchHooks Function()
    >;
typedef $$WalletMutationItemsTableCreateCompanionBuilder =
    WalletMutationItemsCompanion Function({
      Value<int> id,
      required String walletMutationId,
      required int itemIndex,
      required WalletItemLegRole legRole,
      Value<String?> walletRecordId,
      Value<int?> expectedRemoteRevision,
      required String payloadCiphertext,
      required WalletMutationState state,
      Value<String?> safeErrorCode,
    });
typedef $$WalletMutationItemsTableUpdateCompanionBuilder =
    WalletMutationItemsCompanion Function({
      Value<int> id,
      Value<String> walletMutationId,
      Value<int> itemIndex,
      Value<WalletItemLegRole> legRole,
      Value<String?> walletRecordId,
      Value<int?> expectedRemoteRevision,
      Value<String> payloadCiphertext,
      Value<WalletMutationState> state,
      Value<String?> safeErrorCode,
    });

final class $$WalletMutationItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WalletMutationItemsTable,
          WalletMutationItem
        > {
  $$WalletMutationItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletMutationsTable _walletMutationIdTable(_$AppDatabase db) =>
      db.walletMutations.createAlias(
        'wallet_mutation_item__wallet_mutation_id__wallet_mutations__id',
      );

  $$WalletMutationsTableProcessedTableManager get walletMutationId {
    final $_column = $_itemColumn<String>('wallet_mutation_id')!;

    final manager = $$WalletMutationsTableTableManager(
      $_db,
      $_db.walletMutations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletMutationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WalletMutationItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletMutationItemsTable> {
  $$WalletMutationItemsTableFilterComposer({
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

  ColumnFilters<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WalletItemLegRole, WalletItemLegRole, String>
  get legRole => $composableBuilder(
    column: $table.legRole,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get walletRecordId => $composableBuilder(
    column: $table.walletRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedRemoteRevision => $composableBuilder(
    column: $table.expectedRemoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    WalletMutationState,
    WalletMutationState,
    String
  >
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get safeErrorCode => $composableBuilder(
    column: $table.safeErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletMutationsTableFilterComposer get walletMutationId {
    final $$WalletMutationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletMutationId,
      referencedTable: $db.walletMutations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletMutationsTableFilterComposer(
            $db: $db,
            $table: $db.walletMutations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletMutationItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletMutationItemsTable> {
  $$WalletMutationItemsTableOrderingComposer({
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

  ColumnOrderings<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legRole => $composableBuilder(
    column: $table.legRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletRecordId => $composableBuilder(
    column: $table.walletRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedRemoteRevision => $composableBuilder(
    column: $table.expectedRemoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safeErrorCode => $composableBuilder(
    column: $table.safeErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletMutationsTableOrderingComposer get walletMutationId {
    final $$WalletMutationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletMutationId,
      referencedTable: $db.walletMutations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletMutationsTableOrderingComposer(
            $db: $db,
            $table: $db.walletMutations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletMutationItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletMutationItemsTable> {
  $$WalletMutationItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemIndex =>
      $composableBuilder(column: $table.itemIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WalletItemLegRole, String> get legRole =>
      $composableBuilder(column: $table.legRole, builder: (column) => column);

  GeneratedColumn<String> get walletRecordId => $composableBuilder(
    column: $table.walletRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedRemoteRevision => $composableBuilder(
    column: $table.expectedRemoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WalletMutationState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get safeErrorCode => $composableBuilder(
    column: $table.safeErrorCode,
    builder: (column) => column,
  );

  $$WalletMutationsTableAnnotationComposer get walletMutationId {
    final $$WalletMutationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletMutationId,
      referencedTable: $db.walletMutations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletMutationsTableAnnotationComposer(
            $db: $db,
            $table: $db.walletMutations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletMutationItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletMutationItemsTable,
          WalletMutationItem,
          $$WalletMutationItemsTableFilterComposer,
          $$WalletMutationItemsTableOrderingComposer,
          $$WalletMutationItemsTableAnnotationComposer,
          $$WalletMutationItemsTableCreateCompanionBuilder,
          $$WalletMutationItemsTableUpdateCompanionBuilder,
          (WalletMutationItem, $$WalletMutationItemsTableReferences),
          WalletMutationItem,
          PrefetchHooks Function({bool walletMutationId})
        > {
  $$WalletMutationItemsTableTableManager(
    _$AppDatabase db,
    $WalletMutationItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletMutationItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletMutationItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WalletMutationItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> walletMutationId = const Value.absent(),
                Value<int> itemIndex = const Value.absent(),
                Value<WalletItemLegRole> legRole = const Value.absent(),
                Value<String?> walletRecordId = const Value.absent(),
                Value<int?> expectedRemoteRevision = const Value.absent(),
                Value<String> payloadCiphertext = const Value.absent(),
                Value<WalletMutationState> state = const Value.absent(),
                Value<String?> safeErrorCode = const Value.absent(),
              }) => WalletMutationItemsCompanion(
                id: id,
                walletMutationId: walletMutationId,
                itemIndex: itemIndex,
                legRole: legRole,
                walletRecordId: walletRecordId,
                expectedRemoteRevision: expectedRemoteRevision,
                payloadCiphertext: payloadCiphertext,
                state: state,
                safeErrorCode: safeErrorCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String walletMutationId,
                required int itemIndex,
                required WalletItemLegRole legRole,
                Value<String?> walletRecordId = const Value.absent(),
                Value<int?> expectedRemoteRevision = const Value.absent(),
                required String payloadCiphertext,
                required WalletMutationState state,
                Value<String?> safeErrorCode = const Value.absent(),
              }) => WalletMutationItemsCompanion.insert(
                id: id,
                walletMutationId: walletMutationId,
                itemIndex: itemIndex,
                legRole: legRole,
                walletRecordId: walletRecordId,
                expectedRemoteRevision: expectedRemoteRevision,
                payloadCiphertext: payloadCiphertext,
                state: state,
                safeErrorCode: safeErrorCode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WalletMutationItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({walletMutationId = false}) {
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
                    if (walletMutationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.walletMutationId,
                                referencedTable:
                                    $$WalletMutationItemsTableReferences
                                        ._walletMutationIdTable(db),
                                referencedColumn:
                                    $$WalletMutationItemsTableReferences
                                        ._walletMutationIdTable(db)
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

typedef $$WalletMutationItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletMutationItemsTable,
      WalletMutationItem,
      $$WalletMutationItemsTableFilterComposer,
      $$WalletMutationItemsTableOrderingComposer,
      $$WalletMutationItemsTableAnnotationComposer,
      $$WalletMutationItemsTableCreateCompanionBuilder,
      $$WalletMutationItemsTableUpdateCompanionBuilder,
      (WalletMutationItem, $$WalletMutationItemsTableReferences),
      WalletMutationItem,
      PrefetchHooks Function({bool walletMutationId})
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
typedef $$RulePacksTableCreateCompanionBuilder =
    RulePacksCompanion Function({
      required String id,
      required String version,
      required String checksum,
      required String market,
      Value<bool> enabled,
      required int installedAtEpochMs,
      Value<int> rowid,
    });
typedef $$RulePacksTableUpdateCompanionBuilder =
    RulePacksCompanion Function({
      Value<String> id,
      Value<String> version,
      Value<String> checksum,
      Value<String> market,
      Value<bool> enabled,
      Value<int> installedAtEpochMs,
      Value<int> rowid,
    });

class $$RulePacksTableFilterComposer
    extends Composer<_$AppDatabase, $RulePacksTable> {
  $$RulePacksTableFilterComposer({
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

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installedAtEpochMs => $composableBuilder(
    column: $table.installedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RulePacksTableOrderingComposer
    extends Composer<_$AppDatabase, $RulePacksTable> {
  $$RulePacksTableOrderingComposer({
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

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installedAtEpochMs => $composableBuilder(
    column: $table.installedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulePacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RulePacksTable> {
  $$RulePacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get installedAtEpochMs => $composableBuilder(
    column: $table.installedAtEpochMs,
    builder: (column) => column,
  );
}

class $$RulePacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RulePacksTable,
          RulePack,
          $$RulePacksTableFilterComposer,
          $$RulePacksTableOrderingComposer,
          $$RulePacksTableAnnotationComposer,
          $$RulePacksTableCreateCompanionBuilder,
          $$RulePacksTableUpdateCompanionBuilder,
          (RulePack, BaseReferences<_$AppDatabase, $RulePacksTable, RulePack>),
          RulePack,
          PrefetchHooks Function()
        > {
  $$RulePacksTableTableManager(_$AppDatabase db, $RulePacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulePacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulePacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulePacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> installedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RulePacksCompanion(
                id: id,
                version: version,
                checksum: checksum,
                market: market,
                enabled: enabled,
                installedAtEpochMs: installedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String version,
                required String checksum,
                required String market,
                Value<bool> enabled = const Value.absent(),
                required int installedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => RulePacksCompanion.insert(
                id: id,
                version: version,
                checksum: checksum,
                market: market,
                enabled: enabled,
                installedAtEpochMs: installedAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RulePacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RulePacksTable,
      RulePack,
      $$RulePacksTableFilterComposer,
      $$RulePacksTableOrderingComposer,
      $$RulePacksTableAnnotationComposer,
      $$RulePacksTableCreateCompanionBuilder,
      $$RulePacksTableUpdateCompanionBuilder,
      (RulePack, BaseReferences<_$AppDatabase, $RulePacksTable, RulePack>),
      RulePack,
      PrefetchHooks Function()
    >;
typedef $$IngestionCheckpointsTableCreateCompanionBuilder =
    IngestionCheckpointsCompanion Function({
      Value<int> id,
      required String ingestionSource,
      Value<int?> selectedFromEpochMs,
      Value<int?> selectedUntilEpochMs,
      Value<int?> selectedRangeDays,
      Value<String?> senderCursorHash,
      Value<int?> dateCursorEpochMs,
      required int configuredCap,
      Value<int> processedCount,
      Value<int> acceptedCount,
      Value<int> filteredCount,
      Value<int> duplicateCount,
      Value<IngestionOutcome?> outcome,
      required int startedAtEpochMs,
      Value<int?> completedAtEpochMs,
      required int privacyEpoch,
    });
typedef $$IngestionCheckpointsTableUpdateCompanionBuilder =
    IngestionCheckpointsCompanion Function({
      Value<int> id,
      Value<String> ingestionSource,
      Value<int?> selectedFromEpochMs,
      Value<int?> selectedUntilEpochMs,
      Value<int?> selectedRangeDays,
      Value<String?> senderCursorHash,
      Value<int?> dateCursorEpochMs,
      Value<int> configuredCap,
      Value<int> processedCount,
      Value<int> acceptedCount,
      Value<int> filteredCount,
      Value<int> duplicateCount,
      Value<IngestionOutcome?> outcome,
      Value<int> startedAtEpochMs,
      Value<int?> completedAtEpochMs,
      Value<int> privacyEpoch,
    });

class $$IngestionCheckpointsTableFilterComposer
    extends Composer<_$AppDatabase, $IngestionCheckpointsTable> {
  $$IngestionCheckpointsTableFilterComposer({
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

  ColumnFilters<String> get ingestionSource => $composableBuilder(
    column: $table.ingestionSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedFromEpochMs => $composableBuilder(
    column: $table.selectedFromEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedUntilEpochMs => $composableBuilder(
    column: $table.selectedUntilEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedRangeDays => $composableBuilder(
    column: $table.selectedRangeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderCursorHash => $composableBuilder(
    column: $table.senderCursorHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateCursorEpochMs => $composableBuilder(
    column: $table.dateCursorEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configuredCap => $composableBuilder(
    column: $table.configuredCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processedCount => $composableBuilder(
    column: $table.processedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acceptedCount => $composableBuilder(
    column: $table.acceptedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get filteredCount => $composableBuilder(
    column: $table.filteredCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngestionOutcome?, IngestionOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get startedAtEpochMs => $composableBuilder(
    column: $table.startedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtEpochMs => $composableBuilder(
    column: $table.completedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngestionCheckpointsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngestionCheckpointsTable> {
  $$IngestionCheckpointsTableOrderingComposer({
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

  ColumnOrderings<String> get ingestionSource => $composableBuilder(
    column: $table.ingestionSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedFromEpochMs => $composableBuilder(
    column: $table.selectedFromEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedUntilEpochMs => $composableBuilder(
    column: $table.selectedUntilEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedRangeDays => $composableBuilder(
    column: $table.selectedRangeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderCursorHash => $composableBuilder(
    column: $table.senderCursorHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateCursorEpochMs => $composableBuilder(
    column: $table.dateCursorEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configuredCap => $composableBuilder(
    column: $table.configuredCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processedCount => $composableBuilder(
    column: $table.processedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acceptedCount => $composableBuilder(
    column: $table.acceptedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get filteredCount => $composableBuilder(
    column: $table.filteredCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtEpochMs => $composableBuilder(
    column: $table.startedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtEpochMs => $composableBuilder(
    column: $table.completedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngestionCheckpointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngestionCheckpointsTable> {
  $$IngestionCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ingestionSource => $composableBuilder(
    column: $table.ingestionSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedFromEpochMs => $composableBuilder(
    column: $table.selectedFromEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedUntilEpochMs => $composableBuilder(
    column: $table.selectedUntilEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedRangeDays => $composableBuilder(
    column: $table.selectedRangeDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderCursorHash => $composableBuilder(
    column: $table.senderCursorHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateCursorEpochMs => $composableBuilder(
    column: $table.dateCursorEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get configuredCap => $composableBuilder(
    column: $table.configuredCap,
    builder: (column) => column,
  );

  GeneratedColumn<int> get processedCount => $composableBuilder(
    column: $table.processedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acceptedCount => $composableBuilder(
    column: $table.acceptedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get filteredCount => $composableBuilder(
    column: $table.filteredCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IngestionOutcome?, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get startedAtEpochMs => $composableBuilder(
    column: $table.startedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtEpochMs => $composableBuilder(
    column: $table.completedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => column,
  );
}

class $$IngestionCheckpointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngestionCheckpointsTable,
          IngestionCheckpoint,
          $$IngestionCheckpointsTableFilterComposer,
          $$IngestionCheckpointsTableOrderingComposer,
          $$IngestionCheckpointsTableAnnotationComposer,
          $$IngestionCheckpointsTableCreateCompanionBuilder,
          $$IngestionCheckpointsTableUpdateCompanionBuilder,
          (
            IngestionCheckpoint,
            BaseReferences<
              _$AppDatabase,
              $IngestionCheckpointsTable,
              IngestionCheckpoint
            >,
          ),
          IngestionCheckpoint,
          PrefetchHooks Function()
        > {
  $$IngestionCheckpointsTableTableManager(
    _$AppDatabase db,
    $IngestionCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngestionCheckpointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngestionCheckpointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngestionCheckpointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ingestionSource = const Value.absent(),
                Value<int?> selectedFromEpochMs = const Value.absent(),
                Value<int?> selectedUntilEpochMs = const Value.absent(),
                Value<int?> selectedRangeDays = const Value.absent(),
                Value<String?> senderCursorHash = const Value.absent(),
                Value<int?> dateCursorEpochMs = const Value.absent(),
                Value<int> configuredCap = const Value.absent(),
                Value<int> processedCount = const Value.absent(),
                Value<int> acceptedCount = const Value.absent(),
                Value<int> filteredCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<IngestionOutcome?> outcome = const Value.absent(),
                Value<int> startedAtEpochMs = const Value.absent(),
                Value<int?> completedAtEpochMs = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => IngestionCheckpointsCompanion(
                id: id,
                ingestionSource: ingestionSource,
                selectedFromEpochMs: selectedFromEpochMs,
                selectedUntilEpochMs: selectedUntilEpochMs,
                selectedRangeDays: selectedRangeDays,
                senderCursorHash: senderCursorHash,
                dateCursorEpochMs: dateCursorEpochMs,
                configuredCap: configuredCap,
                processedCount: processedCount,
                acceptedCount: acceptedCount,
                filteredCount: filteredCount,
                duplicateCount: duplicateCount,
                outcome: outcome,
                startedAtEpochMs: startedAtEpochMs,
                completedAtEpochMs: completedAtEpochMs,
                privacyEpoch: privacyEpoch,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ingestionSource,
                Value<int?> selectedFromEpochMs = const Value.absent(),
                Value<int?> selectedUntilEpochMs = const Value.absent(),
                Value<int?> selectedRangeDays = const Value.absent(),
                Value<String?> senderCursorHash = const Value.absent(),
                Value<int?> dateCursorEpochMs = const Value.absent(),
                required int configuredCap,
                Value<int> processedCount = const Value.absent(),
                Value<int> acceptedCount = const Value.absent(),
                Value<int> filteredCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<IngestionOutcome?> outcome = const Value.absent(),
                required int startedAtEpochMs,
                Value<int?> completedAtEpochMs = const Value.absent(),
                required int privacyEpoch,
              }) => IngestionCheckpointsCompanion.insert(
                id: id,
                ingestionSource: ingestionSource,
                selectedFromEpochMs: selectedFromEpochMs,
                selectedUntilEpochMs: selectedUntilEpochMs,
                selectedRangeDays: selectedRangeDays,
                senderCursorHash: senderCursorHash,
                dateCursorEpochMs: dateCursorEpochMs,
                configuredCap: configuredCap,
                processedCount: processedCount,
                acceptedCount: acceptedCount,
                filteredCount: filteredCount,
                duplicateCount: duplicateCount,
                outcome: outcome,
                startedAtEpochMs: startedAtEpochMs,
                completedAtEpochMs: completedAtEpochMs,
                privacyEpoch: privacyEpoch,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngestionCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngestionCheckpointsTable,
      IngestionCheckpoint,
      $$IngestionCheckpointsTableFilterComposer,
      $$IngestionCheckpointsTableOrderingComposer,
      $$IngestionCheckpointsTableAnnotationComposer,
      $$IngestionCheckpointsTableCreateCompanionBuilder,
      $$IngestionCheckpointsTableUpdateCompanionBuilder,
      (
        IngestionCheckpoint,
        BaseReferences<
          _$AppDatabase,
          $IngestionCheckpointsTable,
          IngestionCheckpoint
        >,
      ),
      IngestionCheckpoint,
      PrefetchHooks Function()
    >;
typedef $$TrackingStateTableCreateCompanionBuilder =
    TrackingStateCompanion Function({
      Value<int> id,
      Value<int?> lastScanAtEpochMs,
      Value<String?> lastScanOutcome,
      Value<String?> lastSafeErrorCode,
      Value<int> privacyEpoch,
    });
typedef $$TrackingStateTableUpdateCompanionBuilder =
    TrackingStateCompanion Function({
      Value<int> id,
      Value<int?> lastScanAtEpochMs,
      Value<String?> lastScanOutcome,
      Value<String?> lastSafeErrorCode,
      Value<int> privacyEpoch,
    });

class $$TrackingStateTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingStateTable> {
  $$TrackingStateTableFilterComposer({
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

  ColumnFilters<int> get lastScanAtEpochMs => $composableBuilder(
    column: $table.lastScanAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastScanOutcome => $composableBuilder(
    column: $table.lastScanOutcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSafeErrorCode => $composableBuilder(
    column: $table.lastSafeErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackingStateTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingStateTable> {
  $$TrackingStateTableOrderingComposer({
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

  ColumnOrderings<int> get lastScanAtEpochMs => $composableBuilder(
    column: $table.lastScanAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastScanOutcome => $composableBuilder(
    column: $table.lastScanOutcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSafeErrorCode => $composableBuilder(
    column: $table.lastSafeErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackingStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingStateTable> {
  $$TrackingStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastScanAtEpochMs => $composableBuilder(
    column: $table.lastScanAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastScanOutcome => $composableBuilder(
    column: $table.lastScanOutcome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSafeErrorCode => $composableBuilder(
    column: $table.lastSafeErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get privacyEpoch => $composableBuilder(
    column: $table.privacyEpoch,
    builder: (column) => column,
  );
}

class $$TrackingStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackingStateTable,
          TrackingStateData,
          $$TrackingStateTableFilterComposer,
          $$TrackingStateTableOrderingComposer,
          $$TrackingStateTableAnnotationComposer,
          $$TrackingStateTableCreateCompanionBuilder,
          $$TrackingStateTableUpdateCompanionBuilder,
          (
            TrackingStateData,
            BaseReferences<
              _$AppDatabase,
              $TrackingStateTable,
              TrackingStateData
            >,
          ),
          TrackingStateData,
          PrefetchHooks Function()
        > {
  $$TrackingStateTableTableManager(_$AppDatabase db, $TrackingStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastScanAtEpochMs = const Value.absent(),
                Value<String?> lastScanOutcome = const Value.absent(),
                Value<String?> lastSafeErrorCode = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => TrackingStateCompanion(
                id: id,
                lastScanAtEpochMs: lastScanAtEpochMs,
                lastScanOutcome: lastScanOutcome,
                lastSafeErrorCode: lastSafeErrorCode,
                privacyEpoch: privacyEpoch,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastScanAtEpochMs = const Value.absent(),
                Value<String?> lastScanOutcome = const Value.absent(),
                Value<String?> lastSafeErrorCode = const Value.absent(),
                Value<int> privacyEpoch = const Value.absent(),
              }) => TrackingStateCompanion.insert(
                id: id,
                lastScanAtEpochMs: lastScanAtEpochMs,
                lastScanOutcome: lastScanOutcome,
                lastSafeErrorCode: lastSafeErrorCode,
                privacyEpoch: privacyEpoch,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackingStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackingStateTable,
      TrackingStateData,
      $$TrackingStateTableFilterComposer,
      $$TrackingStateTableOrderingComposer,
      $$TrackingStateTableAnnotationComposer,
      $$TrackingStateTableCreateCompanionBuilder,
      $$TrackingStateTableUpdateCompanionBuilder,
      (
        TrackingStateData,
        BaseReferences<_$AppDatabase, $TrackingStateTable, TrackingStateData>,
      ),
      TrackingStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SenderRulesTableTableManager get senderRules =>
      $$SenderRulesTableTableManager(_db, _db.senderRules);
  $$TrackedSendersTableTableManager get trackedSenders =>
      $$TrackedSendersTableTableManager(_db, _db.trackedSenders);
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
  $$WalletLabelCacheTableTableManager get walletLabelCache =>
      $$WalletLabelCacheTableTableManager(_db, _db.walletLabelCache);
  $$WalletConnectionStatusTableTableManager get walletConnectionStatus =>
      $$WalletConnectionStatusTableTableManager(
        _db,
        _db.walletConnectionStatus,
      );
  $$WalletMutationsTableTableManager get walletMutations =>
      $$WalletMutationsTableTableManager(_db, _db.walletMutations);
  $$WalletRecordLinksTableTableManager get walletRecordLinks =>
      $$WalletRecordLinksTableTableManager(_db, _db.walletRecordLinks);
  $$MappingRulesTableTableManager get mappingRules =>
      $$MappingRulesTableTableManager(_db, _db.mappingRules);
  $$WalletMutationItemsTableTableManager get walletMutationItems =>
      $$WalletMutationItemsTableTableManager(_db, _db.walletMutationItems);
  $$CapabilityLedgerTableTableManager get capabilityLedger =>
      $$CapabilityLedgerTableTableManager(_db, _db.capabilityLedger);
  $$RulePacksTableTableManager get rulePacks =>
      $$RulePacksTableTableManager(_db, _db.rulePacks);
  $$IngestionCheckpointsTableTableManager get ingestionCheckpoints =>
      $$IngestionCheckpointsTableTableManager(_db, _db.ingestionCheckpoints);
  $$TrackingStateTableTableManager get trackingState =>
      $$TrackingStateTableTableManager(_db, _db.trackingState);
}
