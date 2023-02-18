import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path_pkg;

import 'daos.dart';
import 'tables.dart';

// auto-generated by drift_dev using
// dart run build_runner build
part 'database.g.dart';

@DriftDatabase(
  tables: [Devices, Users],
  daos: [DeviceDao, UserDao],
)
class Database extends _$Database {
  static const fileName = 'db.sqlite';

  Database(Directory dir) : super(_open(dir));

  static LazyDatabase _open(Directory dir) => LazyDatabase(() async {
        final file = File(path_pkg.join(dir.path, fileName));
        return NativeDatabase.createInBackground(file);
      });

  @override
  int get schemaVersion => 1;
}
