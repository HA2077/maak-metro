import 'package:flutter/foundation.dart';

import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/domain/metro_repository.dart';

enum RouteError { none, sameStation, noRoute }

class RouteProvider extends ChangeNotifier {
  RouteProvider(
    this._repo, {
    this.config = const RoutingConfig(),
    this.onLibraryChanged,
  });

  final MetroRepository _repo;
  final RoutingConfig config;
  final Future<void> Function()? onLibraryChanged;

  bool _loading = false;
  Object? _initError;
  NetworkData? _network;
  Station? _from;
  Station? _to;
  RouteResult? _result;
  RouteError _error = RouteError.none;

  bool get loading => _loading;

  Object? get initError => _initError;

  NetworkData? get network => _network;

  List<Station> get stations => _network?.stations ?? const <Station>[];

  Station? get from => _from;

  Station? get to => _to;

  RouteResult? get result => _result;

  RouteError get error => _error;

  bool get canSearch {
    final from = _from;
    final to = _to;
    return from != null && to != null && from.id != to.id;
  }

  Future<void> init() async {
    _loading = true;
    _initError = null;
    notifyListeners();
    try {
      _network = await _repo.loadNetwork();
    } catch (error) {
      _initError = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setFrom(Station? station) {
    _from = station;
    _clearRoute();
  }

  void setTo(Station? station) {
    _to = station;
    _clearRoute();
  }

  void swap() {
    final from = _from;
    _from = _to;
    _to = from;
    _clearRoute();
  }

  Future<bool> calculate({bool saveToHistory = true}) async {
    _loading = true;
    notifyListeners();
    try {
      final from = _from;
      final to = _to;
      final network = _network;
      if (network == null || from == null || to == null) {
        _result = null;
        _error = RouteError.noRoute;
        return false;
      }
      if (from.id == to.id) {
        _result = null;
        _error = RouteError.sameStation;
        return false;
      }

      final found = findRoute(
        fromId: from.id,
        toId: to.id,
        data: network,
        config: config,
      );
      if (found == null) {
        _result = null;
        _error = RouteError.noRoute;
        return false;
      }

      _result = found;
      _error = RouteError.none;
      if (saveToHistory) {
        await _repo.addHistory(from.id, to.id);
      }
      await onLibraryChanged?.call();
      return true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> isCurrentFavorite() async {
    final from = _from;
    final to = _to;
    if (from == null || to == null || from.id == to.id) return false;
    return _repo.isFavorite(from.id, to.id);
  }

  Future<void> toggleFavorite() async {
    final from = _from;
    final to = _to;
    if (from == null || to == null || from.id == to.id) return;

    if (await _repo.isFavorite(from.id, to.id)) {
      await _repo.removeFavoriteByPair(from.id, to.id);
    } else {
      await _repo.addFavorite(from.id, to.id);
    }
    await onLibraryChanged?.call();
    notifyListeners();
  }

  void _clearRoute() {
    _result = null;
    _error = RouteError.none;
    notifyListeners();
  }
}
