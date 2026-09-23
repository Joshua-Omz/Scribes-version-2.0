// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $DraftsTable extends Drafts with TableInfo<$DraftsTable, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sermonSourceMeta = const VerificationMeta(
    'sermonSource',
  );
  @override
  late final GeneratedColumn<String> sermonSource = GeneratedColumn<String>(
    'sermon_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scriptureTagsMeta = const VerificationMeta(
    'scriptureTags',
  );
  @override
  late final GeneratedColumn<String> scriptureTags = GeneratedColumn<String>(
    'scripture_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _serverSequenceMeta = const VerificationMeta(
    'serverSequence',
  );
  @override
  late final GeneratedColumn<int> serverSequence = GeneratedColumn<int>(
    'server_sequence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localOnlyMeta = const VerificationMeta(
    'localOnly',
  );
  @override
  late final GeneratedColumn<bool> localOnly = GeneratedColumn<bool>(
    'local_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    authorId,
    content,
    caption,
    sermonSource,
    scriptureTags,
    isSynced,
    serverSequence,
    localOnly,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Draft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('sermon_source')) {
      context.handle(
        _sermonSourceMeta,
        sermonSource.isAcceptableOrUnknown(
          data['sermon_source']!,
          _sermonSourceMeta,
        ),
      );
    }
    if (data.containsKey('scripture_tags')) {
      context.handle(
        _scriptureTagsMeta,
        scriptureTags.isAcceptableOrUnknown(
          data['scripture_tags']!,
          _scriptureTagsMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('server_sequence')) {
      context.handle(
        _serverSequenceMeta,
        serverSequence.isAcceptableOrUnknown(
          data['server_sequence']!,
          _serverSequenceMeta,
        ),
      );
    }
    if (data.containsKey('local_only')) {
      context.handle(
        _localOnlyMeta,
        localOnly.isAcceptableOrUnknown(data['local_only']!, _localOnlyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      sermonSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sermon_source'],
      ),
      scriptureTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scripture_tags'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      serverSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_sequence'],
      ),
      localOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_only'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class Draft extends DataClass implements Insertable<Draft> {
  final String id;
  final String authorId;
  final String content;
  final String? caption;
  final String? sermonSource;
  final String? scriptureTags;
  final bool isSynced;
  final int? serverSequence;
  final bool localOnly;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Draft({
    required this.id,
    required this.authorId,
    required this.content,
    this.caption,
    this.sermonSource,
    this.scriptureTags,
    required this.isSynced,
    this.serverSequence,
    required this.localOnly,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['author_id'] = Variable<String>(authorId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    if (!nullToAbsent || sermonSource != null) {
      map['sermon_source'] = Variable<String>(sermonSource);
    }
    if (!nullToAbsent || scriptureTags != null) {
      map['scripture_tags'] = Variable<String>(scriptureTags);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || serverSequence != null) {
      map['server_sequence'] = Variable<int>(serverSequence);
    }
    map['local_only'] = Variable<bool>(localOnly);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      authorId: Value(authorId),
      content: Value(content),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      sermonSource: sermonSource == null && nullToAbsent
          ? const Value.absent()
          : Value(sermonSource),
      scriptureTags: scriptureTags == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptureTags),
      isSynced: Value(isSynced),
      serverSequence: serverSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSequence),
      localOnly: Value(localOnly),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Draft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      id: serializer.fromJson<String>(json['id']),
      authorId: serializer.fromJson<String>(json['authorId']),
      content: serializer.fromJson<String>(json['content']),
      caption: serializer.fromJson<String?>(json['caption']),
      sermonSource: serializer.fromJson<String?>(json['sermonSource']),
      scriptureTags: serializer.fromJson<String?>(json['scriptureTags']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      serverSequence: serializer.fromJson<int?>(json['serverSequence']),
      localOnly: serializer.fromJson<bool>(json['localOnly']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'authorId': serializer.toJson<String>(authorId),
      'content': serializer.toJson<String>(content),
      'caption': serializer.toJson<String?>(caption),
      'sermonSource': serializer.toJson<String?>(sermonSource),
      'scriptureTags': serializer.toJson<String?>(scriptureTags),
      'isSynced': serializer.toJson<bool>(isSynced),
      'serverSequence': serializer.toJson<int?>(serverSequence),
      'localOnly': serializer.toJson<bool>(localOnly),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Draft copyWith({
    String? id,
    String? authorId,
    String? content,
    Value<String?> caption = const Value.absent(),
    Value<String?> sermonSource = const Value.absent(),
    Value<String?> scriptureTags = const Value.absent(),
    bool? isSynced,
    Value<int?> serverSequence = const Value.absent(),
    bool? localOnly,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Draft(
    id: id ?? this.id,
    authorId: authorId ?? this.authorId,
    content: content ?? this.content,
    caption: caption.present ? caption.value : this.caption,
    sermonSource: sermonSource.present ? sermonSource.value : this.sermonSource,
    scriptureTags: scriptureTags.present
        ? scriptureTags.value
        : this.scriptureTags,
    isSynced: isSynced ?? this.isSynced,
    serverSequence: serverSequence.present
        ? serverSequence.value
        : this.serverSequence,
    localOnly: localOnly ?? this.localOnly,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      id: data.id.present ? data.id.value : this.id,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      content: data.content.present ? data.content.value : this.content,
      caption: data.caption.present ? data.caption.value : this.caption,
      sermonSource: data.sermonSource.present
          ? data.sermonSource.value
          : this.sermonSource,
      scriptureTags: data.scriptureTags.present
          ? data.scriptureTags.value
          : this.scriptureTags,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      serverSequence: data.serverSequence.present
          ? data.serverSequence.value
          : this.serverSequence,
      localOnly: data.localOnly.present ? data.localOnly.value : this.localOnly,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('caption: $caption, ')
          ..write('sermonSource: $sermonSource, ')
          ..write('scriptureTags: $scriptureTags, ')
          ..write('isSynced: $isSynced, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('localOnly: $localOnly, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    content,
    caption,
    sermonSource,
    scriptureTags,
    isSynced,
    serverSequence,
    localOnly,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.id == this.id &&
          other.authorId == this.authorId &&
          other.content == this.content &&
          other.caption == this.caption &&
          other.sermonSource == this.sermonSource &&
          other.scriptureTags == this.scriptureTags &&
          other.isSynced == this.isSynced &&
          other.serverSequence == this.serverSequence &&
          other.localOnly == this.localOnly &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<String> id;
  final Value<String> authorId;
  final Value<String> content;
  final Value<String?> caption;
  final Value<String?> sermonSource;
  final Value<String?> scriptureTags;
  final Value<bool> isSynced;
  final Value<int?> serverSequence;
  final Value<bool> localOnly;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.authorId = const Value.absent(),
    this.content = const Value.absent(),
    this.caption = const Value.absent(),
    this.sermonSource = const Value.absent(),
    this.scriptureTags = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.serverSequence = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String id,
    required String authorId,
    required String content,
    this.caption = const Value.absent(),
    this.sermonSource = const Value.absent(),
    this.scriptureTags = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.serverSequence = const Value.absent(),
    this.localOnly = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       authorId = Value(authorId),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Draft> custom({
    Expression<String>? id,
    Expression<String>? authorId,
    Expression<String>? content,
    Expression<String>? caption,
    Expression<String>? sermonSource,
    Expression<String>? scriptureTags,
    Expression<bool>? isSynced,
    Expression<int>? serverSequence,
    Expression<bool>? localOnly,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (authorId != null) 'author_id': authorId,
      if (content != null) 'content': content,
      if (caption != null) 'caption': caption,
      if (sermonSource != null) 'sermon_source': sermonSource,
      if (scriptureTags != null) 'scripture_tags': scriptureTags,
      if (isSynced != null) 'is_synced': isSynced,
      if (serverSequence != null) 'server_sequence': serverSequence,
      if (localOnly != null) 'local_only': localOnly,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? authorId,
    Value<String>? content,
    Value<String?>? caption,
    Value<String?>? sermonSource,
    Value<String?>? scriptureTags,
    Value<bool>? isSynced,
    Value<int?>? serverSequence,
    Value<bool>? localOnly,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      caption: caption ?? this.caption,
      sermonSource: sermonSource ?? this.sermonSource,
      scriptureTags: scriptureTags ?? this.scriptureTags,
      isSynced: isSynced ?? this.isSynced,
      serverSequence: serverSequence ?? this.serverSequence,
      localOnly: localOnly ?? this.localOnly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (sermonSource.present) {
      map['sermon_source'] = Variable<String>(sermonSource.value);
    }
    if (scriptureTags.present) {
      map['scripture_tags'] = Variable<String>(scriptureTags.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (serverSequence.present) {
      map['server_sequence'] = Variable<int>(serverSequence.value);
    }
    if (localOnly.present) {
      map['local_only'] = Variable<bool>(localOnly.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('caption: $caption, ')
          ..write('sermonSource: $sermonSource, ')
          ..write('scriptureTags: $scriptureTags, ')
          ..write('isSynced: $isSynced, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('localOnly: $localOnly, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, Post> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorHandleMeta = const VerificationMeta(
    'authorHandle',
  );
  @override
  late final GeneratedColumn<String> authorHandle = GeneratedColumn<String>(
    'author_handle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentVersionMeta = const VerificationMeta(
    'currentVersion',
  );
  @override
  late final GeneratedColumn<int> currentVersion = GeneratedColumn<int>(
    'current_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectionMeta = const VerificationMeta(
    'isCorrection',
  );
  @override
  late final GeneratedColumn<bool> isCorrection = GeneratedColumn<bool>(
    'is_correction',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correction" IN (0, 1))',
    ),
  );
  static const VerificationMeta _correctsPostIdMeta = const VerificationMeta(
    'correctsPostId',
  );
  @override
  late final GeneratedColumn<String> correctsPostId = GeneratedColumn<String>(
    'corrects_post_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sermonSourceMeta = const VerificationMeta(
    'sermonSource',
  );
  @override
  late final GeneratedColumn<String> sermonSource = GeneratedColumn<String>(
    'sermon_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scriptureTagsMeta = const VerificationMeta(
    'scriptureTags',
  );
  @override
  late final GeneratedColumn<String> scriptureTags = GeneratedColumn<String>(
    'scripture_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _serverSequenceMeta = const VerificationMeta(
    'serverSequence',
  );
  @override
  late final GeneratedColumn<int> serverSequence = GeneratedColumn<int>(
    'server_sequence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverImageUrlMeta = const VerificationMeta(
    'coverImageUrl',
  );
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
    'cover_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postTypeMeta = const VerificationMeta(
    'postType',
  );
  @override
  late final GeneratedColumn<String> postType = GeneratedColumn<String>(
    'post_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    authorId,
    authorHandle,
    authorName,
    content,
    caption,
    visibility,
    currentVersion,
    isCorrection,
    correctsPostId,
    sermonSource,
    scriptureTags,
    isDeleted,
    serverSequence,
    coverImageUrl,
    postType,
    publishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Post> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('author_handle')) {
      context.handle(
        _authorHandleMeta,
        authorHandle.isAcceptableOrUnknown(
          data['author_handle']!,
          _authorHandleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorHandleMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    } else if (isInserting) {
      context.missing(_visibilityMeta);
    }
    if (data.containsKey('current_version')) {
      context.handle(
        _currentVersionMeta,
        currentVersion.isAcceptableOrUnknown(
          data['current_version']!,
          _currentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentVersionMeta);
    }
    if (data.containsKey('is_correction')) {
      context.handle(
        _isCorrectionMeta,
        isCorrection.isAcceptableOrUnknown(
          data['is_correction']!,
          _isCorrectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCorrectionMeta);
    }
    if (data.containsKey('corrects_post_id')) {
      context.handle(
        _correctsPostIdMeta,
        correctsPostId.isAcceptableOrUnknown(
          data['corrects_post_id']!,
          _correctsPostIdMeta,
        ),
      );
    }
    if (data.containsKey('sermon_source')) {
      context.handle(
        _sermonSourceMeta,
        sermonSource.isAcceptableOrUnknown(
          data['sermon_source']!,
          _sermonSourceMeta,
        ),
      );
    }
    if (data.containsKey('scripture_tags')) {
      context.handle(
        _scriptureTagsMeta,
        scriptureTags.isAcceptableOrUnknown(
          data['scripture_tags']!,
          _scriptureTagsMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    } else if (isInserting) {
      context.missing(_isDeletedMeta);
    }
    if (data.containsKey('server_sequence')) {
      context.handle(
        _serverSequenceMeta,
        serverSequence.isAcceptableOrUnknown(
          data['server_sequence']!,
          _serverSequenceMeta,
        ),
      );
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
        _coverImageUrlMeta,
        coverImageUrl.isAcceptableOrUnknown(
          data['cover_image_url']!,
          _coverImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('post_type')) {
      context.handle(
        _postTypeMeta,
        postType.isAcceptableOrUnknown(data['post_type']!, _postTypeMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Post map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Post(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      authorHandle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_handle'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      currentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_version'],
      )!,
      isCorrection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correction'],
      )!,
      correctsPostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrects_post_id'],
      ),
      sermonSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sermon_source'],
      ),
      scriptureTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scripture_tags'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      serverSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_sequence'],
      ),
      coverImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_url'],
      ),
      postType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_type'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
  final String id;
  final String authorId;
  final String authorHandle;
  final String authorName;
  final String content;
  final String? caption;
  final String visibility;
  final int currentVersion;
  final bool isCorrection;
  final String? correctsPostId;
  final String? sermonSource;
  final String? scriptureTags;
  final bool isDeleted;
  final int? serverSequence;
  final String? coverImageUrl;
  final String postType;
  final DateTime publishedAt;
  const Post({
    required this.id,
    required this.authorId,
    required this.authorHandle,
    required this.authorName,
    required this.content,
    this.caption,
    required this.visibility,
    required this.currentVersion,
    required this.isCorrection,
    this.correctsPostId,
    this.sermonSource,
    this.scriptureTags,
    required this.isDeleted,
    this.serverSequence,
    this.coverImageUrl,
    required this.postType,
    required this.publishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['author_id'] = Variable<String>(authorId);
    map['author_handle'] = Variable<String>(authorHandle);
    map['author_name'] = Variable<String>(authorName);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['visibility'] = Variable<String>(visibility);
    map['current_version'] = Variable<int>(currentVersion);
    map['is_correction'] = Variable<bool>(isCorrection);
    if (!nullToAbsent || correctsPostId != null) {
      map['corrects_post_id'] = Variable<String>(correctsPostId);
    }
    if (!nullToAbsent || sermonSource != null) {
      map['sermon_source'] = Variable<String>(sermonSource);
    }
    if (!nullToAbsent || scriptureTags != null) {
      map['scripture_tags'] = Variable<String>(scriptureTags);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || serverSequence != null) {
      map['server_sequence'] = Variable<int>(serverSequence);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['post_type'] = Variable<String>(postType);
    map['published_at'] = Variable<DateTime>(publishedAt);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      authorId: Value(authorId),
      authorHandle: Value(authorHandle),
      authorName: Value(authorName),
      content: Value(content),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      visibility: Value(visibility),
      currentVersion: Value(currentVersion),
      isCorrection: Value(isCorrection),
      correctsPostId: correctsPostId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctsPostId),
      sermonSource: sermonSource == null && nullToAbsent
          ? const Value.absent()
          : Value(sermonSource),
      scriptureTags: scriptureTags == null && nullToAbsent
          ? const Value.absent()
          : Value(scriptureTags),
      isDeleted: Value(isDeleted),
      serverSequence: serverSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSequence),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      postType: Value(postType),
      publishedAt: Value(publishedAt),
    );
  }

  factory Post.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
      id: serializer.fromJson<String>(json['id']),
      authorId: serializer.fromJson<String>(json['authorId']),
      authorHandle: serializer.fromJson<String>(json['authorHandle']),
      authorName: serializer.fromJson<String>(json['authorName']),
      content: serializer.fromJson<String>(json['content']),
      caption: serializer.fromJson<String?>(json['caption']),
      visibility: serializer.fromJson<String>(json['visibility']),
      currentVersion: serializer.fromJson<int>(json['currentVersion']),
      isCorrection: serializer.fromJson<bool>(json['isCorrection']),
      correctsPostId: serializer.fromJson<String?>(json['correctsPostId']),
      sermonSource: serializer.fromJson<String?>(json['sermonSource']),
      scriptureTags: serializer.fromJson<String?>(json['scriptureTags']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      serverSequence: serializer.fromJson<int?>(json['serverSequence']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      postType: serializer.fromJson<String>(json['postType']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'authorId': serializer.toJson<String>(authorId),
      'authorHandle': serializer.toJson<String>(authorHandle),
      'authorName': serializer.toJson<String>(authorName),
      'content': serializer.toJson<String>(content),
      'caption': serializer.toJson<String?>(caption),
      'visibility': serializer.toJson<String>(visibility),
      'currentVersion': serializer.toJson<int>(currentVersion),
      'isCorrection': serializer.toJson<bool>(isCorrection),
      'correctsPostId': serializer.toJson<String?>(correctsPostId),
      'sermonSource': serializer.toJson<String?>(sermonSource),
      'scriptureTags': serializer.toJson<String?>(scriptureTags),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'serverSequence': serializer.toJson<int?>(serverSequence),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'postType': serializer.toJson<String>(postType),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
    };
  }

  Post copyWith({
    String? id,
    String? authorId,
    String? authorHandle,
    String? authorName,
    String? content,
    Value<String?> caption = const Value.absent(),
    String? visibility,
    int? currentVersion,
    bool? isCorrection,
    Value<String?> correctsPostId = const Value.absent(),
    Value<String?> sermonSource = const Value.absent(),
    Value<String?> scriptureTags = const Value.absent(),
    bool? isDeleted,
    Value<int?> serverSequence = const Value.absent(),
    Value<String?> coverImageUrl = const Value.absent(),
    String? postType,
    DateTime? publishedAt,
  }) => Post(
    id: id ?? this.id,
    authorId: authorId ?? this.authorId,
    authorHandle: authorHandle ?? this.authorHandle,
    authorName: authorName ?? this.authorName,
    content: content ?? this.content,
    caption: caption.present ? caption.value : this.caption,
    visibility: visibility ?? this.visibility,
    currentVersion: currentVersion ?? this.currentVersion,
    isCorrection: isCorrection ?? this.isCorrection,
    correctsPostId: correctsPostId.present
        ? correctsPostId.value
        : this.correctsPostId,
    sermonSource: sermonSource.present ? sermonSource.value : this.sermonSource,
    scriptureTags: scriptureTags.present
        ? scriptureTags.value
        : this.scriptureTags,
    isDeleted: isDeleted ?? this.isDeleted,
    serverSequence: serverSequence.present
        ? serverSequence.value
        : this.serverSequence,
    coverImageUrl: coverImageUrl.present
        ? coverImageUrl.value
        : this.coverImageUrl,
    postType: postType ?? this.postType,
    publishedAt: publishedAt ?? this.publishedAt,
  );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      id: data.id.present ? data.id.value : this.id,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      authorHandle: data.authorHandle.present
          ? data.authorHandle.value
          : this.authorHandle,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      content: data.content.present ? data.content.value : this.content,
      caption: data.caption.present ? data.caption.value : this.caption,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      currentVersion: data.currentVersion.present
          ? data.currentVersion.value
          : this.currentVersion,
      isCorrection: data.isCorrection.present
          ? data.isCorrection.value
          : this.isCorrection,
      correctsPostId: data.correctsPostId.present
          ? data.correctsPostId.value
          : this.correctsPostId,
      sermonSource: data.sermonSource.present
          ? data.sermonSource.value
          : this.sermonSource,
      scriptureTags: data.scriptureTags.present
          ? data.scriptureTags.value
          : this.scriptureTags,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      serverSequence: data.serverSequence.present
          ? data.serverSequence.value
          : this.serverSequence,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      postType: data.postType.present ? data.postType.value : this.postType,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('authorHandle: $authorHandle, ')
          ..write('authorName: $authorName, ')
          ..write('content: $content, ')
          ..write('caption: $caption, ')
          ..write('visibility: $visibility, ')
          ..write('currentVersion: $currentVersion, ')
          ..write('isCorrection: $isCorrection, ')
          ..write('correctsPostId: $correctsPostId, ')
          ..write('sermonSource: $sermonSource, ')
          ..write('scriptureTags: $scriptureTags, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('postType: $postType, ')
          ..write('publishedAt: $publishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    authorHandle,
    authorName,
    content,
    caption,
    visibility,
    currentVersion,
    isCorrection,
    correctsPostId,
    sermonSource,
    scriptureTags,
    isDeleted,
    serverSequence,
    coverImageUrl,
    postType,
    publishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          other.id == this.id &&
          other.authorId == this.authorId &&
          other.authorHandle == this.authorHandle &&
          other.authorName == this.authorName &&
          other.content == this.content &&
          other.caption == this.caption &&
          other.visibility == this.visibility &&
          other.currentVersion == this.currentVersion &&
          other.isCorrection == this.isCorrection &&
          other.correctsPostId == this.correctsPostId &&
          other.sermonSource == this.sermonSource &&
          other.scriptureTags == this.scriptureTags &&
          other.isDeleted == this.isDeleted &&
          other.serverSequence == this.serverSequence &&
          other.coverImageUrl == this.coverImageUrl &&
          other.postType == this.postType &&
          other.publishedAt == this.publishedAt);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<String> id;
  final Value<String> authorId;
  final Value<String> authorHandle;
  final Value<String> authorName;
  final Value<String> content;
  final Value<String?> caption;
  final Value<String> visibility;
  final Value<int> currentVersion;
  final Value<bool> isCorrection;
  final Value<String?> correctsPostId;
  final Value<String?> sermonSource;
  final Value<String?> scriptureTags;
  final Value<bool> isDeleted;
  final Value<int?> serverSequence;
  final Value<String?> coverImageUrl;
  final Value<String> postType;
  final Value<DateTime> publishedAt;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorHandle = const Value.absent(),
    this.authorName = const Value.absent(),
    this.content = const Value.absent(),
    this.caption = const Value.absent(),
    this.visibility = const Value.absent(),
    this.currentVersion = const Value.absent(),
    this.isCorrection = const Value.absent(),
    this.correctsPostId = const Value.absent(),
    this.sermonSource = const Value.absent(),
    this.scriptureTags = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.serverSequence = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.postType = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    required String authorId,
    required String authorHandle,
    required String authorName,
    required String content,
    this.caption = const Value.absent(),
    required String visibility,
    required int currentVersion,
    required bool isCorrection,
    this.correctsPostId = const Value.absent(),
    this.sermonSource = const Value.absent(),
    this.scriptureTags = const Value.absent(),
    required bool isDeleted,
    this.serverSequence = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.postType = const Value.absent(),
    required DateTime publishedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       authorId = Value(authorId),
       authorHandle = Value(authorHandle),
       authorName = Value(authorName),
       content = Value(content),
       visibility = Value(visibility),
       currentVersion = Value(currentVersion),
       isCorrection = Value(isCorrection),
       isDeleted = Value(isDeleted),
       publishedAt = Value(publishedAt);
  static Insertable<Post> custom({
    Expression<String>? id,
    Expression<String>? authorId,
    Expression<String>? authorHandle,
    Expression<String>? authorName,
    Expression<String>? content,
    Expression<String>? caption,
    Expression<String>? visibility,
    Expression<int>? currentVersion,
    Expression<bool>? isCorrection,
    Expression<String>? correctsPostId,
    Expression<String>? sermonSource,
    Expression<String>? scriptureTags,
    Expression<bool>? isDeleted,
    Expression<int>? serverSequence,
    Expression<String>? coverImageUrl,
    Expression<String>? postType,
    Expression<DateTime>? publishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (authorId != null) 'author_id': authorId,
      if (authorHandle != null) 'author_handle': authorHandle,
      if (authorName != null) 'author_name': authorName,
      if (content != null) 'content': content,
      if (caption != null) 'caption': caption,
      if (visibility != null) 'visibility': visibility,
      if (currentVersion != null) 'current_version': currentVersion,
      if (isCorrection != null) 'is_correction': isCorrection,
      if (correctsPostId != null) 'corrects_post_id': correctsPostId,
      if (sermonSource != null) 'sermon_source': sermonSource,
      if (scriptureTags != null) 'scripture_tags': scriptureTags,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (serverSequence != null) 'server_sequence': serverSequence,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (postType != null) 'post_type': postType,
      if (publishedAt != null) 'published_at': publishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? id,
    Value<String>? authorId,
    Value<String>? authorHandle,
    Value<String>? authorName,
    Value<String>? content,
    Value<String?>? caption,
    Value<String>? visibility,
    Value<int>? currentVersion,
    Value<bool>? isCorrection,
    Value<String?>? correctsPostId,
    Value<String?>? sermonSource,
    Value<String?>? scriptureTags,
    Value<bool>? isDeleted,
    Value<int?>? serverSequence,
    Value<String?>? coverImageUrl,
    Value<String>? postType,
    Value<DateTime>? publishedAt,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorHandle: authorHandle ?? this.authorHandle,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      caption: caption ?? this.caption,
      visibility: visibility ?? this.visibility,
      currentVersion: currentVersion ?? this.currentVersion,
      isCorrection: isCorrection ?? this.isCorrection,
      correctsPostId: correctsPostId ?? this.correctsPostId,
      sermonSource: sermonSource ?? this.sermonSource,
      scriptureTags: scriptureTags ?? this.scriptureTags,
      isDeleted: isDeleted ?? this.isDeleted,
      serverSequence: serverSequence ?? this.serverSequence,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      postType: postType ?? this.postType,
      publishedAt: publishedAt ?? this.publishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (authorHandle.present) {
      map['author_handle'] = Variable<String>(authorHandle.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (currentVersion.present) {
      map['current_version'] = Variable<int>(currentVersion.value);
    }
    if (isCorrection.present) {
      map['is_correction'] = Variable<bool>(isCorrection.value);
    }
    if (correctsPostId.present) {
      map['corrects_post_id'] = Variable<String>(correctsPostId.value);
    }
    if (sermonSource.present) {
      map['sermon_source'] = Variable<String>(sermonSource.value);
    }
    if (scriptureTags.present) {
      map['scripture_tags'] = Variable<String>(scriptureTags.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (serverSequence.present) {
      map['server_sequence'] = Variable<int>(serverSequence.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (postType.present) {
      map['post_type'] = Variable<String>(postType.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('authorHandle: $authorHandle, ')
          ..write('authorName: $authorName, ')
          ..write('content: $content, ')
          ..write('caption: $caption, ')
          ..write('visibility: $visibility, ')
          ..write('currentVersion: $currentVersion, ')
          ..write('isCorrection: $isCorrection, ')
          ..write('correctsPostId: $correctsPostId, ')
          ..write('sermonSource: $sermonSource, ')
          ..write('scriptureTags: $scriptureTags, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('postType: $postType, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
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
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
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
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String key;
  final String value;
  const SyncMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
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

  SyncMetadataData copyWith({String? key, String? value}) =>
      SyncMetadataData(key: key ?? this.key, value: value ?? this.value);
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
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
      (other is SyncMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetadataData> custom({
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

  SyncMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
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
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerId, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }
}

class Notebook extends DataClass implements Insertable<Notebook> {
  final String id;
  final String ownerId;
  final String name;
  final DateTime createdAt;
  const Notebook({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Notebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notebook copyWith({
    String? id,
    String? ownerId,
    String? name,
    DateTime? createdAt,
  }) => Notebook(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebooksCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Notebook> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebooksCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NotebooksCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
    'notebook_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverSequenceMeta = const VerificationMeta(
    'serverSequence',
  );
  @override
  late final GeneratedColumn<int> serverSequence = GeneratedColumn<int>(
    'server_sequence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localOnlyMeta = const VerificationMeta(
    'localOnly',
  );
  @override
  late final GeneratedColumn<bool> localOnly = GeneratedColumn<bool>(
    'local_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    authorId,
    content,
    title,
    notebookId,
    isSynced,
    serverSequence,
    localOnly,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('server_sequence')) {
      context.handle(
        _serverSequenceMeta,
        serverSequence.isAcceptableOrUnknown(
          data['server_sequence']!,
          _serverSequenceMeta,
        ),
      );
    }
    if (data.containsKey('local_only')) {
      context.handle(
        _localOnlyMeta,
        localOnly.isAcceptableOrUnknown(data['local_only']!, _localOnlyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notebook_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      serverSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_sequence'],
      ),
      localOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_only'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String authorId;
  final String content;
  final String? title;
  final String? notebookId;
  final bool isSynced;
  final int? serverSequence;
  final bool localOnly;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.authorId,
    required this.content,
    this.title,
    this.notebookId,
    required this.isSynced,
    this.serverSequence,
    required this.localOnly,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['author_id'] = Variable<String>(authorId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || notebookId != null) {
      map['notebook_id'] = Variable<String>(notebookId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || serverSequence != null) {
      map['server_sequence'] = Variable<int>(serverSequence);
    }
    map['local_only'] = Variable<bool>(localOnly);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      authorId: Value(authorId),
      content: Value(content),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      notebookId: notebookId == null && nullToAbsent
          ? const Value.absent()
          : Value(notebookId),
      isSynced: Value(isSynced),
      serverSequence: serverSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSequence),
      localOnly: Value(localOnly),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      authorId: serializer.fromJson<String>(json['authorId']),
      content: serializer.fromJson<String>(json['content']),
      title: serializer.fromJson<String?>(json['title']),
      notebookId: serializer.fromJson<String?>(json['notebookId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      serverSequence: serializer.fromJson<int?>(json['serverSequence']),
      localOnly: serializer.fromJson<bool>(json['localOnly']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'authorId': serializer.toJson<String>(authorId),
      'content': serializer.toJson<String>(content),
      'title': serializer.toJson<String?>(title),
      'notebookId': serializer.toJson<String?>(notebookId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'serverSequence': serializer.toJson<int?>(serverSequence),
      'localOnly': serializer.toJson<bool>(localOnly),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    String? id,
    String? authorId,
    String? content,
    Value<String?> title = const Value.absent(),
    Value<String?> notebookId = const Value.absent(),
    bool? isSynced,
    Value<int?> serverSequence = const Value.absent(),
    bool? localOnly,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    authorId: authorId ?? this.authorId,
    content: content ?? this.content,
    title: title.present ? title.value : this.title,
    notebookId: notebookId.present ? notebookId.value : this.notebookId,
    isSynced: isSynced ?? this.isSynced,
    serverSequence: serverSequence.present
        ? serverSequence.value
        : this.serverSequence,
    localOnly: localOnly ?? this.localOnly,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      content: data.content.present ? data.content.value : this.content,
      title: data.title.present ? data.title.value : this.title,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      serverSequence: data.serverSequence.present
          ? data.serverSequence.value
          : this.serverSequence,
      localOnly: data.localOnly.present ? data.localOnly.value : this.localOnly,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('notebookId: $notebookId, ')
          ..write('isSynced: $isSynced, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('localOnly: $localOnly, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    content,
    title,
    notebookId,
    isSynced,
    serverSequence,
    localOnly,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.authorId == this.authorId &&
          other.content == this.content &&
          other.title == this.title &&
          other.notebookId == this.notebookId &&
          other.isSynced == this.isSynced &&
          other.serverSequence == this.serverSequence &&
          other.localOnly == this.localOnly &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> authorId;
  final Value<String> content;
  final Value<String?> title;
  final Value<String?> notebookId;
  final Value<bool> isSynced;
  final Value<int?> serverSequence;
  final Value<bool> localOnly;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.authorId = const Value.absent(),
    this.content = const Value.absent(),
    this.title = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.serverSequence = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String authorId,
    required String content,
    this.title = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.serverSequence = const Value.absent(),
    this.localOnly = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       authorId = Value(authorId),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? authorId,
    Expression<String>? content,
    Expression<String>? title,
    Expression<String>? notebookId,
    Expression<bool>? isSynced,
    Expression<int>? serverSequence,
    Expression<bool>? localOnly,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (authorId != null) 'author_id': authorId,
      if (content != null) 'content': content,
      if (title != null) 'title': title,
      if (notebookId != null) 'notebook_id': notebookId,
      if (isSynced != null) 'is_synced': isSynced,
      if (serverSequence != null) 'server_sequence': serverSequence,
      if (localOnly != null) 'local_only': localOnly,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? authorId,
    Value<String>? content,
    Value<String?>? title,
    Value<String?>? notebookId,
    Value<bool>? isSynced,
    Value<int?>? serverSequence,
    Value<bool>? localOnly,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      title: title ?? this.title,
      notebookId: notebookId ?? this.notebookId,
      isSynced: isSynced ?? this.isSynced,
      serverSequence: serverSequence ?? this.serverSequence,
      localOnly: localOnly ?? this.localOnly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (serverSequence.present) {
      map['server_sequence'] = Variable<int>(serverSequence.value);
    }
    if (localOnly.present) {
      map['local_only'] = Variable<bool>(localOnly.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('notebookId: $notebookId, ')
          ..write('isSynced: $isSynced, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('localOnly: $localOnly, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BibleReadingPositionsTable extends BibleReadingPositions
    with TableInfo<$BibleReadingPositionsTable, BibleReadingPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleReadingPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookCodeMeta = const VerificationMeta(
    'bookCode',
  );
  @override
  late final GeneratedColumn<String> bookCode = GeneratedColumn<String>(
    'book_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _preferredTranslationMeta =
      const VerificationMeta('preferredTranslation');
  @override
  late final GeneratedColumn<String> preferredTranslation =
      GeneratedColumn<String>(
        'preferred_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('BSB'),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    bookCode,
    chapter,
    verse,
    preferredTranslation,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_reading_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleReadingPosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('book_code')) {
      context.handle(
        _bookCodeMeta,
        bookCode.isAcceptableOrUnknown(data['book_code']!, _bookCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bookCodeMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    }
    if (data.containsKey('preferred_translation')) {
      context.handle(
        _preferredTranslationMeta,
        preferredTranslation.isAcceptableOrUnknown(
          data['preferred_translation']!,
          _preferredTranslationMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  BibleReadingPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleReadingPosition(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bookCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_code'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      preferredTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_translation'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $BibleReadingPositionsTable createAlias(String alias) {
    return $BibleReadingPositionsTable(attachedDatabase, alias);
  }
}

class BibleReadingPosition extends DataClass
    implements Insertable<BibleReadingPosition> {
  final String userId;
  final String bookCode;
  final int chapter;
  final int verse;
  final String preferredTranslation;
  final DateTime updatedAt;
  final bool isSynced;
  const BibleReadingPosition({
    required this.userId,
    required this.bookCode,
    required this.chapter,
    required this.verse,
    required this.preferredTranslation,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['book_code'] = Variable<String>(bookCode);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['preferred_translation'] = Variable<String>(preferredTranslation);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  BibleReadingPositionsCompanion toCompanion(bool nullToAbsent) {
    return BibleReadingPositionsCompanion(
      userId: Value(userId),
      bookCode: Value(bookCode),
      chapter: Value(chapter),
      verse: Value(verse),
      preferredTranslation: Value(preferredTranslation),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory BibleReadingPosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleReadingPosition(
      userId: serializer.fromJson<String>(json['userId']),
      bookCode: serializer.fromJson<String>(json['bookCode']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      preferredTranslation: serializer.fromJson<String>(
        json['preferredTranslation'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'bookCode': serializer.toJson<String>(bookCode),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'preferredTranslation': serializer.toJson<String>(preferredTranslation),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  BibleReadingPosition copyWith({
    String? userId,
    String? bookCode,
    int? chapter,
    int? verse,
    String? preferredTranslation,
    DateTime? updatedAt,
    bool? isSynced,
  }) => BibleReadingPosition(
    userId: userId ?? this.userId,
    bookCode: bookCode ?? this.bookCode,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    preferredTranslation: preferredTranslation ?? this.preferredTranslation,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  BibleReadingPosition copyWithCompanion(BibleReadingPositionsCompanion data) {
    return BibleReadingPosition(
      userId: data.userId.present ? data.userId.value : this.userId,
      bookCode: data.bookCode.present ? data.bookCode.value : this.bookCode,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      preferredTranslation: data.preferredTranslation.present
          ? data.preferredTranslation.value
          : this.preferredTranslation,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleReadingPosition(')
          ..write('userId: $userId, ')
          ..write('bookCode: $bookCode, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('preferredTranslation: $preferredTranslation, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    bookCode,
    chapter,
    verse,
    preferredTranslation,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleReadingPosition &&
          other.userId == this.userId &&
          other.bookCode == this.bookCode &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.preferredTranslation == this.preferredTranslation &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class BibleReadingPositionsCompanion
    extends UpdateCompanion<BibleReadingPosition> {
  final Value<String> userId;
  final Value<String> bookCode;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> preferredTranslation;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const BibleReadingPositionsCompanion({
    this.userId = const Value.absent(),
    this.bookCode = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.preferredTranslation = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleReadingPositionsCompanion.insert({
    required String userId,
    required String bookCode,
    required int chapter,
    this.verse = const Value.absent(),
    this.preferredTranslation = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       bookCode = Value(bookCode),
       chapter = Value(chapter),
       updatedAt = Value(updatedAt);
  static Insertable<BibleReadingPosition> custom({
    Expression<String>? userId,
    Expression<String>? bookCode,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? preferredTranslation,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (bookCode != null) 'book_code': bookCode,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (preferredTranslation != null)
        'preferred_translation': preferredTranslation,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleReadingPositionsCompanion copyWith({
    Value<String>? userId,
    Value<String>? bookCode,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? preferredTranslation,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return BibleReadingPositionsCompanion(
      userId: userId ?? this.userId,
      bookCode: bookCode ?? this.bookCode,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      preferredTranslation: preferredTranslation ?? this.preferredTranslation,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bookCode.present) {
      map['book_code'] = Variable<String>(bookCode.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (preferredTranslation.present) {
      map['preferred_translation'] = Variable<String>(
        preferredTranslation.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleReadingPositionsCompanion(')
          ..write('userId: $userId, ')
          ..write('bookCode: $bookCode, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('preferredTranslation: $preferredTranslation, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BibleHighlightsTable extends BibleHighlights
    with TableInfo<$BibleHighlightsTable, BibleHighlight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleHighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookCodeMeta = const VerificationMeta(
    'bookCode',
  );
  @override
  late final GeneratedColumn<String> bookCode = GeneratedColumn<String>(
    'book_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    verseId,
    bookCode,
    chapter,
    verse,
    colorHex,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_highlights';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleHighlight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('book_code')) {
      context.handle(
        _bookCodeMeta,
        bookCode.isAcceptableOrUnknown(data['book_code']!, _bookCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bookCodeMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BibleHighlight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleHighlight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      )!,
      bookCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_code'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $BibleHighlightsTable createAlias(String alias) {
    return $BibleHighlightsTable(attachedDatabase, alias);
  }
}

class BibleHighlight extends DataClass implements Insertable<BibleHighlight> {
  final String id;
  final String userId;
  final int verseId;
  final String bookCode;
  final int chapter;
  final int verse;
  final String colorHex;
  final DateTime createdAt;
  final bool isSynced;
  const BibleHighlight({
    required this.id,
    required this.userId,
    required this.verseId,
    required this.bookCode,
    required this.chapter,
    required this.verse,
    required this.colorHex,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['verse_id'] = Variable<int>(verseId);
    map['book_code'] = Variable<String>(bookCode);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['color_hex'] = Variable<String>(colorHex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  BibleHighlightsCompanion toCompanion(bool nullToAbsent) {
    return BibleHighlightsCompanion(
      id: Value(id),
      userId: Value(userId),
      verseId: Value(verseId),
      bookCode: Value(bookCode),
      chapter: Value(chapter),
      verse: Value(verse),
      colorHex: Value(colorHex),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory BibleHighlight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleHighlight(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      verseId: serializer.fromJson<int>(json['verseId']),
      bookCode: serializer.fromJson<String>(json['bookCode']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'verseId': serializer.toJson<int>(verseId),
      'bookCode': serializer.toJson<String>(bookCode),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'colorHex': serializer.toJson<String>(colorHex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  BibleHighlight copyWith({
    String? id,
    String? userId,
    int? verseId,
    String? bookCode,
    int? chapter,
    int? verse,
    String? colorHex,
    DateTime? createdAt,
    bool? isSynced,
  }) => BibleHighlight(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    verseId: verseId ?? this.verseId,
    bookCode: bookCode ?? this.bookCode,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    colorHex: colorHex ?? this.colorHex,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  BibleHighlight copyWithCompanion(BibleHighlightsCompanion data) {
    return BibleHighlight(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      bookCode: data.bookCode.present ? data.bookCode.value : this.bookCode,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleHighlight(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('verseId: $verseId, ')
          ..write('bookCode: $bookCode, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    verseId,
    bookCode,
    chapter,
    verse,
    colorHex,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleHighlight &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.verseId == this.verseId &&
          other.bookCode == this.bookCode &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.colorHex == this.colorHex &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class BibleHighlightsCompanion extends UpdateCompanion<BibleHighlight> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> verseId;
  final Value<String> bookCode;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> colorHex;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const BibleHighlightsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.verseId = const Value.absent(),
    this.bookCode = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleHighlightsCompanion.insert({
    required String id,
    required String userId,
    required int verseId,
    required String bookCode,
    required int chapter,
    required int verse,
    required String colorHex,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       verseId = Value(verseId),
       bookCode = Value(bookCode),
       chapter = Value(chapter),
       verse = Value(verse),
       colorHex = Value(colorHex),
       createdAt = Value(createdAt);
  static Insertable<BibleHighlight> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? verseId,
    Expression<String>? bookCode,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? colorHex,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (verseId != null) 'verse_id': verseId,
      if (bookCode != null) 'book_code': bookCode,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleHighlightsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? verseId,
    Value<String>? bookCode,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? colorHex,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return BibleHighlightsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      verseId: verseId ?? this.verseId,
      bookCode: bookCode ?? this.bookCode,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (bookCode.present) {
      map['book_code'] = Variable<String>(bookCode.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleHighlightsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('verseId: $verseId, ')
          ..write('bookCode: $bookCode, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BibleDownloadedTranslationsTable extends BibleDownloadedTranslations
    with
        TableInfo<
          $BibleDownloadedTranslationsTable,
          BibleDownloadedTranslation
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleDownloadedTranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    localPath,
    version,
    sizeBytes,
    isDefault,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_downloaded_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleDownloadedTranslation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  BibleDownloadedTranslation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleDownloadedTranslation(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $BibleDownloadedTranslationsTable createAlias(String alias) {
    return $BibleDownloadedTranslationsTable(attachedDatabase, alias);
  }
}

class BibleDownloadedTranslation extends DataClass
    implements Insertable<BibleDownloadedTranslation> {
  final String code;
  final String name;
  final String localPath;
  final int version;
  final int sizeBytes;
  final bool isDefault;
  final DateTime installedAt;
  const BibleDownloadedTranslation({
    required this.code,
    required this.name,
    required this.localPath,
    required this.version,
    required this.sizeBytes,
    required this.isDefault,
    required this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['local_path'] = Variable<String>(localPath);
    map['version'] = Variable<int>(version);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['is_default'] = Variable<bool>(isDefault);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  BibleDownloadedTranslationsCompanion toCompanion(bool nullToAbsent) {
    return BibleDownloadedTranslationsCompanion(
      code: Value(code),
      name: Value(name),
      localPath: Value(localPath),
      version: Value(version),
      sizeBytes: Value(sizeBytes),
      isDefault: Value(isDefault),
      installedAt: Value(installedAt),
    );
  }

  factory BibleDownloadedTranslation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleDownloadedTranslation(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      localPath: serializer.fromJson<String>(json['localPath']),
      version: serializer.fromJson<int>(json['version']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'localPath': serializer.toJson<String>(localPath),
      'version': serializer.toJson<int>(version),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'isDefault': serializer.toJson<bool>(isDefault),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  BibleDownloadedTranslation copyWith({
    String? code,
    String? name,
    String? localPath,
    int? version,
    int? sizeBytes,
    bool? isDefault,
    DateTime? installedAt,
  }) => BibleDownloadedTranslation(
    code: code ?? this.code,
    name: name ?? this.name,
    localPath: localPath ?? this.localPath,
    version: version ?? this.version,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    isDefault: isDefault ?? this.isDefault,
    installedAt: installedAt ?? this.installedAt,
  );
  BibleDownloadedTranslation copyWithCompanion(
    BibleDownloadedTranslationsCompanion data,
  ) {
    return BibleDownloadedTranslation(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      version: data.version.present ? data.version.value : this.version,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleDownloadedTranslation(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('localPath: $localPath, ')
          ..write('version: $version, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isDefault: $isDefault, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    name,
    localPath,
    version,
    sizeBytes,
    isDefault,
    installedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleDownloadedTranslation &&
          other.code == this.code &&
          other.name == this.name &&
          other.localPath == this.localPath &&
          other.version == this.version &&
          other.sizeBytes == this.sizeBytes &&
          other.isDefault == this.isDefault &&
          other.installedAt == this.installedAt);
}

class BibleDownloadedTranslationsCompanion
    extends UpdateCompanion<BibleDownloadedTranslation> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> localPath;
  final Value<int> version;
  final Value<int> sizeBytes;
  final Value<bool> isDefault;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const BibleDownloadedTranslationsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.localPath = const Value.absent(),
    this.version = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleDownloadedTranslationsCompanion.insert({
    required String code,
    required String name,
    required String localPath,
    required int version,
    required int sizeBytes,
    this.isDefault = const Value.absent(),
    required DateTime installedAt,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       localPath = Value(localPath),
       version = Value(version),
       sizeBytes = Value(sizeBytes),
       installedAt = Value(installedAt);
  static Insertable<BibleDownloadedTranslation> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? localPath,
    Expression<int>? version,
    Expression<int>? sizeBytes,
    Expression<bool>? isDefault,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (localPath != null) 'local_path': localPath,
      if (version != null) 'version': version,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (isDefault != null) 'is_default': isDefault,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleDownloadedTranslationsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? localPath,
    Value<int>? version,
    Value<int>? sizeBytes,
    Value<bool>? isDefault,
    Value<DateTime>? installedAt,
    Value<int>? rowid,
  }) {
    return BibleDownloadedTranslationsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      localPath: localPath ?? this.localPath,
      version: version ?? this.version,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isDefault: isDefault ?? this.isDefault,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleDownloadedTranslationsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('localPath: $localPath, ')
          ..write('version: $version, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isDefault: $isDefault, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ScribesDatabase extends GeneratedDatabase {
  _$ScribesDatabase(QueryExecutor e) : super(e);
  $ScribesDatabaseManager get managers => $ScribesDatabaseManager(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $BibleReadingPositionsTable bibleReadingPositions =
      $BibleReadingPositionsTable(this);
  late final $BibleHighlightsTable bibleHighlights = $BibleHighlightsTable(
    this,
  );
  late final $BibleDownloadedTranslationsTable bibleDownloadedTranslations =
      $BibleDownloadedTranslationsTable(this);
  late final NotesDao notesDao = NotesDao(this as ScribesDatabase);
  late final DraftsDao draftsDao = DraftsDao(this as ScribesDatabase);
  late final PostsDao postsDao = PostsDao(this as ScribesDatabase);
  late final BibleDao bibleDao = BibleDao(this as ScribesDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    drafts,
    posts,
    syncMetadata,
    notebooks,
    notes,
    bibleReadingPositions,
    bibleHighlights,
    bibleDownloadedTranslations,
  ];
}

typedef $$DraftsTableCreateCompanionBuilder =
    DraftsCompanion Function({
      required String id,
      required String authorId,
      required String content,
      Value<String?> caption,
      Value<String?> sermonSource,
      Value<String?> scriptureTags,
      Value<bool> isSynced,
      Value<int?> serverSequence,
      Value<bool> localOnly,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DraftsTableUpdateCompanionBuilder =
    DraftsCompanion Function({
      Value<String> id,
      Value<String> authorId,
      Value<String> content,
      Value<String?> caption,
      Value<String?> sermonSource,
      Value<String?> scriptureTags,
      Value<bool> isSynced,
      Value<int?> serverSequence,
      Value<bool> localOnly,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DraftsTableFilterComposer
    extends Composer<_$ScribesDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
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

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sermonSource => $composableBuilder(
    column: $table.sermonSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scriptureTags => $composableBuilder(
    column: $table.scriptureTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$ScribesDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
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

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sermonSource => $composableBuilder(
    column: $table.sermonSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scriptureTags => $composableBuilder(
    column: $table.scriptureTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get sermonSource => $composableBuilder(
    column: $table.sermonSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scriptureTags => $composableBuilder(
    column: $table.scriptureTags,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localOnly =>
      $composableBuilder(column: $table.localOnly, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $DraftsTable,
          Draft,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (Draft, BaseReferences<_$ScribesDatabase, $DraftsTable, Draft>),
          Draft,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$ScribesDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String?> sermonSource = const Value.absent(),
                Value<String?> scriptureTags = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                authorId: authorId,
                content: content,
                caption: caption,
                sermonSource: sermonSource,
                scriptureTags: scriptureTags,
                isSynced: isSynced,
                serverSequence: serverSequence,
                localOnly: localOnly,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String authorId,
                required String content,
                Value<String?> caption = const Value.absent(),
                Value<String?> sermonSource = const Value.absent(),
                Value<String?> scriptureTags = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                id: id,
                authorId: authorId,
                content: content,
                caption: caption,
                sermonSource: sermonSource,
                scriptureTags: scriptureTags,
                isSynced: isSynced,
                serverSequence: serverSequence,
                localOnly: localOnly,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $DraftsTable,
      Draft,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (Draft, BaseReferences<_$ScribesDatabase, $DraftsTable, Draft>),
      Draft,
      PrefetchHooks Function()
    >;
typedef $$PostsTableCreateCompanionBuilder =
    PostsCompanion Function({
      required String id,
      required String authorId,
      required String authorHandle,
      required String authorName,
      required String content,
      Value<String?> caption,
      required String visibility,
      required int currentVersion,
      required bool isCorrection,
      Value<String?> correctsPostId,
      Value<String?> sermonSource,
      Value<String?> scriptureTags,
      required bool isDeleted,
      Value<int?> serverSequence,
      Value<String?> coverImageUrl,
      Value<String> postType,
      required DateTime publishedAt,
      Value<int> rowid,
    });
typedef $$PostsTableUpdateCompanionBuilder =
    PostsCompanion Function({
      Value<String> id,
      Value<String> authorId,
      Value<String> authorHandle,
      Value<String> authorName,
      Value<String> content,
      Value<String?> caption,
      Value<String> visibility,
      Value<int> currentVersion,
      Value<bool> isCorrection,
      Value<String?> correctsPostId,
      Value<String?> sermonSource,
      Value<String?> scriptureTags,
      Value<bool> isDeleted,
      Value<int?> serverSequence,
      Value<String?> coverImageUrl,
      Value<String> postType,
      Value<DateTime> publishedAt,
      Value<int> rowid,
    });

class $$PostsTableFilterComposer
    extends Composer<_$ScribesDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
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

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorHandle => $composableBuilder(
    column: $table.authorHandle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentVersion => $composableBuilder(
    column: $table.currentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrection => $composableBuilder(
    column: $table.isCorrection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctsPostId => $composableBuilder(
    column: $table.correctsPostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sermonSource => $composableBuilder(
    column: $table.sermonSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scriptureTags => $composableBuilder(
    column: $table.scriptureTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postType => $composableBuilder(
    column: $table.postType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostsTableOrderingComposer
    extends Composer<_$ScribesDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
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

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorHandle => $composableBuilder(
    column: $table.authorHandle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentVersion => $composableBuilder(
    column: $table.currentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrection => $composableBuilder(
    column: $table.isCorrection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctsPostId => $composableBuilder(
    column: $table.correctsPostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sermonSource => $composableBuilder(
    column: $table.sermonSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scriptureTags => $composableBuilder(
    column: $table.scriptureTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postType => $composableBuilder(
    column: $table.postType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostsTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get authorHandle => $composableBuilder(
    column: $table.authorHandle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentVersion => $composableBuilder(
    column: $table.currentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrection => $composableBuilder(
    column: $table.isCorrection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctsPostId => $composableBuilder(
    column: $table.correctsPostId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sermonSource => $composableBuilder(
    column: $table.sermonSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scriptureTags => $composableBuilder(
    column: $table.scriptureTags,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postType =>
      $composableBuilder(column: $table.postType, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $PostsTable,
          Post,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (Post, BaseReferences<_$ScribesDatabase, $PostsTable, Post>),
          Post,
          PrefetchHooks Function()
        > {
  $$PostsTableTableManager(_$ScribesDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> authorHandle = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<int> currentVersion = const Value.absent(),
                Value<bool> isCorrection = const Value.absent(),
                Value<String?> correctsPostId = const Value.absent(),
                Value<String?> sermonSource = const Value.absent(),
                Value<String?> scriptureTags = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                Value<String> postType = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                id: id,
                authorId: authorId,
                authorHandle: authorHandle,
                authorName: authorName,
                content: content,
                caption: caption,
                visibility: visibility,
                currentVersion: currentVersion,
                isCorrection: isCorrection,
                correctsPostId: correctsPostId,
                sermonSource: sermonSource,
                scriptureTags: scriptureTags,
                isDeleted: isDeleted,
                serverSequence: serverSequence,
                coverImageUrl: coverImageUrl,
                postType: postType,
                publishedAt: publishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String authorId,
                required String authorHandle,
                required String authorName,
                required String content,
                Value<String?> caption = const Value.absent(),
                required String visibility,
                required int currentVersion,
                required bool isCorrection,
                Value<String?> correctsPostId = const Value.absent(),
                Value<String?> sermonSource = const Value.absent(),
                Value<String?> scriptureTags = const Value.absent(),
                required bool isDeleted,
                Value<int?> serverSequence = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                Value<String> postType = const Value.absent(),
                required DateTime publishedAt,
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                id: id,
                authorId: authorId,
                authorHandle: authorHandle,
                authorName: authorName,
                content: content,
                caption: caption,
                visibility: visibility,
                currentVersion: currentVersion,
                isCorrection: isCorrection,
                correctsPostId: correctsPostId,
                sermonSource: sermonSource,
                scriptureTags: scriptureTags,
                isDeleted: isDeleted,
                serverSequence: serverSequence,
                coverImageUrl: coverImageUrl,
                postType: postType,
                publishedAt: publishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $PostsTable,
      Post,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (Post, BaseReferences<_$ScribesDatabase, $PostsTable, Post>),
      Post,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$ScribesDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
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

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$ScribesDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
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

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
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

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<
              _$ScribesDatabase,
              $SyncMetadataTable,
              SyncMetadataData
            >,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(
    _$ScribesDatabase db,
    $SyncMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
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

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$ScribesDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$NotebooksTableCreateCompanionBuilder =
    NotebooksCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NotebooksTableUpdateCompanionBuilder =
    NotebooksCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$NotebooksTableFilterComposer
    extends Composer<_$ScribesDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$ScribesDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotebooksTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $NotebooksTable,
          Notebook,
          $$NotebooksTableFilterComposer,
          $$NotebooksTableOrderingComposer,
          $$NotebooksTableAnnotationComposer,
          $$NotebooksTableCreateCompanionBuilder,
          $$NotebooksTableUpdateCompanionBuilder,
          (
            Notebook,
            BaseReferences<_$ScribesDatabase, $NotebooksTable, Notebook>,
          ),
          Notebook,
          PrefetchHooks Function()
        > {
  $$NotebooksTableTableManager(_$ScribesDatabase db, $NotebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $NotebooksTable,
      Notebook,
      $$NotebooksTableFilterComposer,
      $$NotebooksTableOrderingComposer,
      $$NotebooksTableAnnotationComposer,
      $$NotebooksTableCreateCompanionBuilder,
      $$NotebooksTableUpdateCompanionBuilder,
      (Notebook, BaseReferences<_$ScribesDatabase, $NotebooksTable, Notebook>),
      Notebook,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String authorId,
      required String content,
      Value<String?> title,
      Value<String?> notebookId,
      Value<bool> isSynced,
      Value<int?> serverSequence,
      Value<bool> localOnly,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> authorId,
      Value<String> content,
      Value<String?> title,
      Value<String?> notebookId,
      Value<bool> isSynced,
      Value<int?> serverSequence,
      Value<bool> localOnly,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NotesTableFilterComposer
    extends Composer<_$ScribesDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$ScribesDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localOnly =>
      $composableBuilder(column: $table.localOnly, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$ScribesDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$ScribesDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notebookId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                authorId: authorId,
                content: content,
                title: title,
                notebookId: notebookId,
                isSynced: isSynced,
                serverSequence: serverSequence,
                localOnly: localOnly,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String authorId,
                required String content,
                Value<String?> title = const Value.absent(),
                Value<String?> notebookId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                authorId: authorId,
                content: content,
                title: title,
                notebookId: notebookId,
                isSynced: isSynced,
                serverSequence: serverSequence,
                localOnly: localOnly,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$ScribesDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;
typedef $$BibleReadingPositionsTableCreateCompanionBuilder =
    BibleReadingPositionsCompanion Function({
      required String userId,
      required String bookCode,
      required int chapter,
      Value<int> verse,
      Value<String> preferredTranslation,
      required DateTime updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$BibleReadingPositionsTableUpdateCompanionBuilder =
    BibleReadingPositionsCompanion Function({
      Value<String> userId,
      Value<String> bookCode,
      Value<int> chapter,
      Value<int> verse,
      Value<String> preferredTranslation,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$BibleReadingPositionsTableFilterComposer
    extends Composer<_$ScribesDatabase, $BibleReadingPositionsTable> {
  $$BibleReadingPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookCode => $composableBuilder(
    column: $table.bookCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTranslation => $composableBuilder(
    column: $table.preferredTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleReadingPositionsTableOrderingComposer
    extends Composer<_$ScribesDatabase, $BibleReadingPositionsTable> {
  $$BibleReadingPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookCode => $composableBuilder(
    column: $table.bookCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTranslation => $composableBuilder(
    column: $table.preferredTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleReadingPositionsTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $BibleReadingPositionsTable> {
  $$BibleReadingPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get bookCode =>
      $composableBuilder(column: $table.bookCode, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get preferredTranslation => $composableBuilder(
    column: $table.preferredTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$BibleReadingPositionsTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $BibleReadingPositionsTable,
          BibleReadingPosition,
          $$BibleReadingPositionsTableFilterComposer,
          $$BibleReadingPositionsTableOrderingComposer,
          $$BibleReadingPositionsTableAnnotationComposer,
          $$BibleReadingPositionsTableCreateCompanionBuilder,
          $$BibleReadingPositionsTableUpdateCompanionBuilder,
          (
            BibleReadingPosition,
            BaseReferences<
              _$ScribesDatabase,
              $BibleReadingPositionsTable,
              BibleReadingPosition
            >,
          ),
          BibleReadingPosition,
          PrefetchHooks Function()
        > {
  $$BibleReadingPositionsTableTableManager(
    _$ScribesDatabase db,
    $BibleReadingPositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleReadingPositionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BibleReadingPositionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BibleReadingPositionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> bookCode = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> preferredTranslation = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleReadingPositionsCompanion(
                userId: userId,
                bookCode: bookCode,
                chapter: chapter,
                verse: verse,
                preferredTranslation: preferredTranslation,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String bookCode,
                required int chapter,
                Value<int> verse = const Value.absent(),
                Value<String> preferredTranslation = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleReadingPositionsCompanion.insert(
                userId: userId,
                bookCode: bookCode,
                chapter: chapter,
                verse: verse,
                preferredTranslation: preferredTranslation,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleReadingPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $BibleReadingPositionsTable,
      BibleReadingPosition,
      $$BibleReadingPositionsTableFilterComposer,
      $$BibleReadingPositionsTableOrderingComposer,
      $$BibleReadingPositionsTableAnnotationComposer,
      $$BibleReadingPositionsTableCreateCompanionBuilder,
      $$BibleReadingPositionsTableUpdateCompanionBuilder,
      (
        BibleReadingPosition,
        BaseReferences<
          _$ScribesDatabase,
          $BibleReadingPositionsTable,
          BibleReadingPosition
        >,
      ),
      BibleReadingPosition,
      PrefetchHooks Function()
    >;
typedef $$BibleHighlightsTableCreateCompanionBuilder =
    BibleHighlightsCompanion Function({
      required String id,
      required String userId,
      required int verseId,
      required String bookCode,
      required int chapter,
      required int verse,
      required String colorHex,
      required DateTime createdAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$BibleHighlightsTableUpdateCompanionBuilder =
    BibleHighlightsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> verseId,
      Value<String> bookCode,
      Value<int> chapter,
      Value<int> verse,
      Value<String> colorHex,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$BibleHighlightsTableFilterComposer
    extends Composer<_$ScribesDatabase, $BibleHighlightsTable> {
  $$BibleHighlightsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookCode => $composableBuilder(
    column: $table.bookCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleHighlightsTableOrderingComposer
    extends Composer<_$ScribesDatabase, $BibleHighlightsTable> {
  $$BibleHighlightsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookCode => $composableBuilder(
    column: $table.bookCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleHighlightsTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $BibleHighlightsTable> {
  $$BibleHighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<String> get bookCode =>
      $composableBuilder(column: $table.bookCode, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$BibleHighlightsTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $BibleHighlightsTable,
          BibleHighlight,
          $$BibleHighlightsTableFilterComposer,
          $$BibleHighlightsTableOrderingComposer,
          $$BibleHighlightsTableAnnotationComposer,
          $$BibleHighlightsTableCreateCompanionBuilder,
          $$BibleHighlightsTableUpdateCompanionBuilder,
          (
            BibleHighlight,
            BaseReferences<
              _$ScribesDatabase,
              $BibleHighlightsTable,
              BibleHighlight
            >,
          ),
          BibleHighlight,
          PrefetchHooks Function()
        > {
  $$BibleHighlightsTableTableManager(
    _$ScribesDatabase db,
    $BibleHighlightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleHighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BibleHighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BibleHighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> verseId = const Value.absent(),
                Value<String> bookCode = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleHighlightsCompanion(
                id: id,
                userId: userId,
                verseId: verseId,
                bookCode: bookCode,
                chapter: chapter,
                verse: verse,
                colorHex: colorHex,
                createdAt: createdAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required int verseId,
                required String bookCode,
                required int chapter,
                required int verse,
                required String colorHex,
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleHighlightsCompanion.insert(
                id: id,
                userId: userId,
                verseId: verseId,
                bookCode: bookCode,
                chapter: chapter,
                verse: verse,
                colorHex: colorHex,
                createdAt: createdAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleHighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $BibleHighlightsTable,
      BibleHighlight,
      $$BibleHighlightsTableFilterComposer,
      $$BibleHighlightsTableOrderingComposer,
      $$BibleHighlightsTableAnnotationComposer,
      $$BibleHighlightsTableCreateCompanionBuilder,
      $$BibleHighlightsTableUpdateCompanionBuilder,
      (
        BibleHighlight,
        BaseReferences<
          _$ScribesDatabase,
          $BibleHighlightsTable,
          BibleHighlight
        >,
      ),
      BibleHighlight,
      PrefetchHooks Function()
    >;
typedef $$BibleDownloadedTranslationsTableCreateCompanionBuilder =
    BibleDownloadedTranslationsCompanion Function({
      required String code,
      required String name,
      required String localPath,
      required int version,
      required int sizeBytes,
      Value<bool> isDefault,
      required DateTime installedAt,
      Value<int> rowid,
    });
typedef $$BibleDownloadedTranslationsTableUpdateCompanionBuilder =
    BibleDownloadedTranslationsCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> localPath,
      Value<int> version,
      Value<int> sizeBytes,
      Value<bool> isDefault,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });

class $$BibleDownloadedTranslationsTableFilterComposer
    extends Composer<_$ScribesDatabase, $BibleDownloadedTranslationsTable> {
  $$BibleDownloadedTranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleDownloadedTranslationsTableOrderingComposer
    extends Composer<_$ScribesDatabase, $BibleDownloadedTranslationsTable> {
  $$BibleDownloadedTranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleDownloadedTranslationsTableAnnotationComposer
    extends Composer<_$ScribesDatabase, $BibleDownloadedTranslationsTable> {
  $$BibleDownloadedTranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$BibleDownloadedTranslationsTableTableManager
    extends
        RootTableManager<
          _$ScribesDatabase,
          $BibleDownloadedTranslationsTable,
          BibleDownloadedTranslation,
          $$BibleDownloadedTranslationsTableFilterComposer,
          $$BibleDownloadedTranslationsTableOrderingComposer,
          $$BibleDownloadedTranslationsTableAnnotationComposer,
          $$BibleDownloadedTranslationsTableCreateCompanionBuilder,
          $$BibleDownloadedTranslationsTableUpdateCompanionBuilder,
          (
            BibleDownloadedTranslation,
            BaseReferences<
              _$ScribesDatabase,
              $BibleDownloadedTranslationsTable,
              BibleDownloadedTranslation
            >,
          ),
          BibleDownloadedTranslation,
          PrefetchHooks Function()
        > {
  $$BibleDownloadedTranslationsTableTableManager(
    _$ScribesDatabase db,
    $BibleDownloadedTranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleDownloadedTranslationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BibleDownloadedTranslationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BibleDownloadedTranslationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleDownloadedTranslationsCompanion(
                code: code,
                name: name,
                localPath: localPath,
                version: version,
                sizeBytes: sizeBytes,
                isDefault: isDefault,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String localPath,
                required int version,
                required int sizeBytes,
                Value<bool> isDefault = const Value.absent(),
                required DateTime installedAt,
                Value<int> rowid = const Value.absent(),
              }) => BibleDownloadedTranslationsCompanion.insert(
                code: code,
                name: name,
                localPath: localPath,
                version: version,
                sizeBytes: sizeBytes,
                isDefault: isDefault,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleDownloadedTranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScribesDatabase,
      $BibleDownloadedTranslationsTable,
      BibleDownloadedTranslation,
      $$BibleDownloadedTranslationsTableFilterComposer,
      $$BibleDownloadedTranslationsTableOrderingComposer,
      $$BibleDownloadedTranslationsTableAnnotationComposer,
      $$BibleDownloadedTranslationsTableCreateCompanionBuilder,
      $$BibleDownloadedTranslationsTableUpdateCompanionBuilder,
      (
        BibleDownloadedTranslation,
        BaseReferences<
          _$ScribesDatabase,
          $BibleDownloadedTranslationsTable,
          BibleDownloadedTranslation
        >,
      ),
      BibleDownloadedTranslation,
      PrefetchHooks Function()
    >;

class $ScribesDatabaseManager {
  final _$ScribesDatabase _db;
  $ScribesDatabaseManager(this._db);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$BibleReadingPositionsTableTableManager get bibleReadingPositions =>
      $$BibleReadingPositionsTableTableManager(_db, _db.bibleReadingPositions);
  $$BibleHighlightsTableTableManager get bibleHighlights =>
      $$BibleHighlightsTableTableManager(_db, _db.bibleHighlights);
  $$BibleDownloadedTranslationsTableTableManager
  get bibleDownloadedTranslations =>
      $$BibleDownloadedTranslationsTableTableManager(
        _db,
        _db.bibleDownloadedTranslations,
      );
}
