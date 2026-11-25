import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/network/domain/network_repository.dart';

import 'seed_loader.dart';

class SqliteNetworkRepository implements NetworkRepository {
  SqliteNetworkRepository(this._db, this._prefs);

  final Database _db;
  final SharedPreferences _prefs;

  @override
  Future<NetworkData> loadNetwork() async {
    final lineRows = await _db.query('lines', orderBy: 'id');
    final stationRows = await _db.query('stations', orderBy: 'id');
    final branchRows = await _db.query(
      'line_branches',
      orderBy: 'line_id, branch',
    );
    final lineStationRows = await _db.query(
      'line_stations',
      orderBy: 'line_id, branch, seq',
    );
    final fareRows = await _db.query('fares', orderBy: 'max_stations');

    return NetworkData(
      lines: lineRows.map(Line.fromJson).toList(),
      stations: stationRows.map(Station.fromJson).toList(),
      branches: branchRows.map(LineBranch.fromJson).toList(),
      lineStations: lineStationRows.map(LineStation.fromJson).toList(),
      fares: fareRows.map(FareBracket.fromJson).toList(),
      snapshotDate: _prefs.getString(seedSnapshotDateKey) ?? '',
    );
  }
}
