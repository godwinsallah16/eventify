import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  late Connectivity _connectivity;
  late InternetConnectionChecker _internetConnectionChecker;

  bool isConnected = false;
  bool hasInternetConnection = false;

  ConnectivityService() {
    _connectivity = Connectivity();
    _internetConnectionChecker = InternetConnectionChecker();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkConnection();
  }

  Future<void> initialize() async {
    await _checkConnection();
    _checkInternetConnection();
  }

  void dispose() {
    // Dispose resources if needed
  }

  bool _updateConnectionStatus(List<ConnectivityResult> results) {
    isConnected = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn ||
        result == ConnectivityResult.bluetooth ||
        result == ConnectivityResult.other);

    if (isConnected) {
      _checkInternetConnection();
      return true;
    } else {
      return false;
    }
  }

  Future<void> _checkConnection() async {
    var connectivityResults = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResults);
  }

  Future<bool> _checkInternetConnection() async {
    hasInternetConnection = await _internetConnectionChecker.hasConnection;
    return hasInternetConnection;
  }
}
