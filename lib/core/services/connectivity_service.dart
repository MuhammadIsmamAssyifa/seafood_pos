import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (_) {
      isOnline.value = true;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool connected = results.any((result) => result != ConnectivityResult.none);
    isOnline.value = connected;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

