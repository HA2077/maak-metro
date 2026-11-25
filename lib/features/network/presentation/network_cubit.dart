import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/features/network/domain/models/network_data.dart';
import 'package:maak_metro/features/network/domain/network_repository.dart';

class NetworkState {
  const NetworkState({this.network, this.loading = false, this.error});

  final NetworkData? network;
  final bool loading;
  final Object? error;
}

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit(this._repository) : super(const NetworkState());

  final NetworkRepository _repository;

  Future<void> load() async {
    if (state.loading) return;
    emit(NetworkState(network: state.network, loading: true));
    try {
      final network = await _repository.loadNetwork();
      if (!isClosed) emit(NetworkState(network: network));
    } catch (error) {
      if (!isClosed) emit(NetworkState(network: state.network, error: error));
    }
  }
}
