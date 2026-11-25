import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:maak_metro/core/data/database_setup.dart';

void main() {
  test('initializes the browser factory only on web', () {
    if (!kIsWeb) {
      databaseFactory = databaseFactorySqflitePlugin;
    }

    initializeDatabaseFactory();

    expect(
      databaseFactory,
      same(kIsWeb ? databaseFactoryFfiWeb : databaseFactorySqflitePlugin),
    );
  });
}
