import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/planner/domain/domain.dart';

enum RouteError { none, sameStation, noRoute }

class PlannerState {
  const PlannerState({this.from, this.to, this.error = RouteError.none});

  final Station? from;
  final Station? to;
  final RouteError error;

  bool get canSearch {
    final from = this.from;
    final to = this.to;
    return from != null && to != null && from.id != to.id;
  }
}

class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit({this.config = const RoutingConfig()})
    : super(const PlannerState());

  final RoutingConfig config;

  void setFrom(Station? station) => setPair(station, state.to);

  void setTo(Station? station) => setPair(state.from, station);

  void setPair(Station? from, Station? to) =>
      emit(PlannerState(from: from, to: to));

  void swap() => setPair(state.to, state.from);

  RouteResult? calculate(NetworkData? network) {
    final from = state.from;
    final to = state.to;
    RouteResult? result;
    final RouteError error;

    if (network == null || from == null || to == null) {
      error = RouteError.noRoute;
    } else if (from.id == to.id) {
      error = RouteError.sameStation;
    } else {
      result = findRoute(
        fromId: from.id,
        toId: to.id,
        data: network,
        config: config,
      );
      error = result == null ? RouteError.noRoute : RouteError.none;
    }

    emit(PlannerState(from: from, to: to, error: error));
    return result;
  }
}
