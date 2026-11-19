import 'package:flutter/foundation.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/library_provider.dart';

enum RouteError { sameStation, noRoute }

/// scaffold: placeholder for `findRoute()` (RT-4). Until the router lands no
/// planner is injected, so `calculate()` reports `noRoute`; screens do not care
/// which implementation they get.
typedef RoutePlanner = RouteResult? Function({
  required String fromId,
  required String toId,
  required NetworkData data,
});

/// scaffold: PROV-2 owns this provider. Selected stations, the last result and
/// the errors the Planner screen shows.
class RouteProvider extends ChangeNotifier {
  RouteProvider({
    required this.repository,
    required this.library,
    this.planner,
  });

  final MetroRepository repository;
  final LibraryProvider library;
  final RoutePlanner? planner;

  NetworkData _network = NetworkData.empty;
  bool _loading = false;
  bool _loadFailed = false;
  String? _fromId;
  String? _toId;
  RouteResult? _result;
  RouteError? _error;

  NetworkData get network => _network;
  bool get loading => _loading;
  bool get loadFailed => _loadFailed;
  String? get fromId => _fromId;
  String? get toId => _toId;
  RouteResult? get result => _result;
  RouteError? get error => _error;

  Station? get fromStation {
    final id = _fromId;
    return id == null ? null : _network.stationById(id);
  }

  Station? get toStation {
    final id = _toId;
    return id == null ? null : _network.stationById(id);
  }

  bool get canSearch =>
      _fromId != null && _toId != null && _fromId != _toId && !_loading;

  bool get isCurrentFavorite {
    final from = _fromId;
    final to = _toId;
    return from != null && to != null && library.isFavorite(from, to);
  }

  Future<void> load() async {
    _loading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      _network = await repository.loadNetwork();
    } catch (error) {
      _loadFailed = true;
      debugPrint('loadNetwork failed: $error');
    }
    _loading = false;
    notifyListeners();
  }

  void setFrom(String stationId) {
    _fromId = stationId;
    _clearResult();
  }

  void setTo(String stationId) {
    _toId = stationId;
    _clearResult();
  }

  void swap() {
    final from = _fromId;
    _fromId = _toId;
    _toId = from;
    _clearResult();
  }

  Future<void> calculate({bool saveToHistory = true}) async {
    final from = _fromId;
    final to = _toId;
    if (from == null || to == null) return;
    if (from == to) {
      _result = null;
      _error = RouteError.sameStation;
      notifyListeners();
      return;
    }
    _loading = true;
    _result = null;
    _error = null;
    notifyListeners();

    final result = planner?.call(fromId: from, toId: to, data: _network);
    _result = result;
    _loading = false;
    if (result == null) {
      _error = RouteError.noRoute;
    } else if (saveToHistory) {
      await repository.addHistory(from, to);
      await library.refresh();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    final from = _fromId;
    final to = _toId;
    if (from == null || to == null) return;
    await library.toggleFavorite(from, to);
    notifyListeners();
  }

  void _clearResult() {
    _result = null;
    _error = null;
    notifyListeners();
  }
}
