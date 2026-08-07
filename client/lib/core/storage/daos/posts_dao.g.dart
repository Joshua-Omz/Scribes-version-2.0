// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_dao.dart';

// ignore_for_file: type=lint
mixin _$PostsDaoMixin on DatabaseAccessor<ScribesDatabase> {
  $PostsTable get posts => attachedDatabase.posts;
  PostsDaoManager get managers => PostsDaoManager(this);
}

class PostsDaoManager {
  final _$PostsDaoMixin _db;
  PostsDaoManager(this._db);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
}
