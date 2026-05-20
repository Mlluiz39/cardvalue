import 'dart:async';
import 'dart:io';

class NetworkInfo {
  static bool _isConnected = true;

  static bool get isConnected => _isConnected;

  static Future<void> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      _isConnected = false;
    } on TimeoutException {
      _isConnected = false;
    } catch (_) {
      _isConnected = false;
    }
  }

  static void startMonitoring() {
    Timer.periodic(const Duration(seconds: 30), (_) async {
      await checkConnectivity();
    });
  }
}
