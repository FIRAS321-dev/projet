import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker();
  
  StreamController<ConnectivityStatus> connectionStatusController = StreamController<ConnectivityStatus>.broadcast();
  
  ConnectivityStatus _lastStatus = ConnectivityStatus.online;
  ConnectivityStatus get lastStatus => _lastStatus;
  
  bool _isInitialized = false;
  
  ConnectivityService() {
    if (!_isInitialized) {
      _init();
      _isInitialized = true;
    }
  }
  
  Future<void> _init() async {
    // Vérifier l'état initial de la connexion
    await _checkConnection();
    
    // Écouter les changements de connectivité
    _connectivity.onConnectivityChanged.listen((_) async {
      await _checkConnection();
    });
    
    // Vérifier périodiquement la connexion Internet
    Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkConnection();
    });
  }
  
  Future<void> _checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      _updateStatus(ConnectivityStatus.offline);
      return;
    }
    
    // Vérifier si l'appareil a une connexion Internet réelle
    final hasConnection = await _connectionChecker.hasConnection;
    
    if (hasConnection) {
      _updateStatus(ConnectivityStatus.online);
    } else {
      _updateStatus(ConnectivityStatus.offline);
    }
  }
  
  void _updateStatus(ConnectivityStatus status) {
    if (status != _lastStatus) {
      _lastStatus = status;
      connectionStatusController.add(status);
      notifyListeners();
    }
  }
  
  Future<bool> isOnline() async {
    return await _connectionChecker.hasConnection;
  }
  
  @override
  void dispose() {
    connectionStatusController.close();
    super.dispose();
  }
}

