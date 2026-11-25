import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/features/network/domain/models/network_data.dart';
import 'package:maak_metro/features/network/domain/network_repository.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';

import '../../../fixtures/fixture_network.dart';

class _NetworkRepository implements NetworkRepository {
  _NetworkRepository(this.load);

  Future<NetworkData> Function() load;

  @override
  Future<NetworkData> loadNetwork() => load();
}

void main() {
  final data = buildFixtureNetwork();

  test('publishes loading then the network and its stations', () async {
    final completer = Completer<NetworkData>();
    final cubit = NetworkCubit(_NetworkRepository(() => completer.future));
    addTearDown(cubit.close);
    final states = <NetworkState>[];
    final subscription = cubit.stream.listen(states.add);
    addTearDown(subscription.cancel);

    final loading = cubit.load();
    expect(cubit.state.loading, isTrue);

    completer.complete(data);
    await loading;

    expect(cubit.state.network, same(data));
    expect(cubit.state.network?.stations, data.stations);
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.error, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(states.map((state) => state.loading), [true, false]);
  });

  test('exposes a load error and loads the network on retry', () async {
    final failure = Exception('seed failed');
    final repository = _NetworkRepository(() async => throw failure);
    final cubit = NetworkCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.error, same(failure));
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.network, isNull);

    repository.load = () async => data;
    await cubit.load();
    expect(cubit.state.error, isNull);
    expect(cubit.state.network, same(data));
  });
}
