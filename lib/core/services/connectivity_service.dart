import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends Cubit<bool> {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription _subscription;

  ConnectivityService() : super(true) {
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        emit(result != ConnectivityResult.none);
      },
    );
  }

  void _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    emit(result != ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}



