import 'models/network_data.dart';

abstract interface class NetworkRepository {
  Future<NetworkData> loadNetwork();
}
