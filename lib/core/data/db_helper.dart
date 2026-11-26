import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Name of the SQLite file used by the app.
const String databaseFileName = 'maak_metro.db';

/// Schema version. Bump only with a matching migration.
const int databaseVersion = 2;

/// The schema from `docs/PLAN.md` section 2, copied verbatim.
const List<String> createTableStatements = <String>[
  'CREATE TABLE lines (id INTEGER PRIMARY KEY, name_ar TEXT NOT NULL, name_en TEXT NOT NULL, color_hex TEXT NOT NULL, terminus_a_ar TEXT, terminus_a_en TEXT, terminus_b_ar TEXT, terminus_b_en TEXT)',
  'CREATE TABLE stations (id TEXT PRIMARY KEY, name_ar TEXT NOT NULL, name_en TEXT NOT NULL)',
  'CREATE TABLE line_branches (line_id INTEGER NOT NULL REFERENCES lines(id), branch TEXT NOT NULL, starts_after TEXT NOT NULL REFERENCES stations(id), terminus_ar TEXT, terminus_en TEXT, PRIMARY KEY (line_id, branch))',
  'CREATE TABLE line_stations (line_id INTEGER NOT NULL REFERENCES lines(id), station_id TEXT NOT NULL REFERENCES stations(id), branch TEXT NOT NULL, seq INTEGER NOT NULL, PRIMARY KEY (line_id, branch, seq), UNIQUE (line_id, station_id))',
  'CREATE TABLE fares (max_stations INTEGER PRIMARY KEY, price_egp INTEGER NOT NULL, ticket_color TEXT)',
  'CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id TEXT NOT NULL REFERENCES stations(id), to_id TEXT NOT NULL REFERENCES stations(id), created_at TEXT NOT NULL, UNIQUE (from_id, to_id))',
  'CREATE TABLE history (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id TEXT NOT NULL REFERENCES stations(id), to_id TEXT NOT NULL REFERENCES stations(id), searched_at TEXT NOT NULL)',
];

/// Columns added in schema version 2. Kept nullable so old rows stay readable
/// until the version 2 seed replaces them.
const List<String> migrateTo2Statements = <String>[
  'ALTER TABLE lines ADD COLUMN terminus_a_ar TEXT',
  'ALTER TABLE lines ADD COLUMN terminus_a_en TEXT',
  'ALTER TABLE lines ADD COLUMN terminus_b_ar TEXT',
  'ALTER TABLE lines ADD COLUMN terminus_b_en TEXT',
  'ALTER TABLE line_branches ADD COLUMN terminus_ar TEXT',
  'ALTER TABLE line_branches ADD COLUMN terminus_en TEXT',
  'ALTER TABLE fares ADD COLUMN ticket_color TEXT',
];

/// Opens and owns the app database.
///
/// The database is opened once and reused; call [close] when it is no longer
/// needed. Tests pass [inMemoryDatabasePath] through [path].
class DbHelper {
  DbHelper({this.path});

  /// Overrides the database location. Tests pass [inMemoryDatabasePath].
  final String? path;

  Future<Database>? _database;

  /// The opened database, created on first access.
  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final databasePath =
        path ?? p.join(await getDatabasesPath(), databaseFileName);
    return openDatabase(
      databasePath,
      version: databaseVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        for (final statement in createTableStatements) {
          await db.execute(statement);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion >= 2) return;
        for (final statement in migrateTo2Statements) {
          await db.execute(statement);
        }
      },
    );
  }

  /// Closes the database. Safe to call when it was never opened, and the
  /// helper can be used again afterwards.
  Future<void> close() async {
    final database = _database;
    if (database == null) return;
    _database = null;
    await (await database).close();
  }
}
