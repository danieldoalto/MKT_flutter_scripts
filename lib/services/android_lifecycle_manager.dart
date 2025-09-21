import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartssh2/dartssh2.dart';
import '../services/ssh_logger.dart';

/// Android-specific lifecycle management for SSH connections
/// Handles app backgrounding, network changes, and connection persistence
class AndroidLifecycleManager extends WidgetsBindingObserver {
  SSHClient? _sshClient;
  SSHLogger? _sshLogger;
  String? _lastKnownHost;
  bool _wasConnectedBeforeBackground = false;
  
  // Callback for when connection needs to be restored
  Function()? onReconnectionNeeded;
  
  // Callback for when connection is lost
  Function(String reason)? onConnectionLost;

  AndroidLifecycleManager({
    this.onReconnectionNeeded,
    this.onConnectionLost,
  });

  /// Initialize the lifecycle manager
  void initialize() {
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addObserver(this);
      _setupNetworkListener();
    }
  }

  /// Dispose the lifecycle manager
  void dispose() {
    if (Platform.isAndroid) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  /// Update the current SSH connection reference
  void updateSSHConnection(SSHClient? client, SSHLogger? logger, String? host) {
    _sshClient = client;
    _sshLogger = logger;
    _lastKnownHost = host;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        // App is transitioning between foreground and background
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        break;
    }
  }

  /// Handle app being backgrounded
  void _handleAppPaused() async {
    if (_sshClient != null) {
      _wasConnectedBeforeBackground = true;
      await _sshLogger?.logConnection('LIFECYCLE_PAUSED', 
          'App backgrounded with active SSH connection to $_lastKnownHost');
      
      // On Android, we keep the connection alive but prepare for potential disconnection
      // The connection might be killed by the system after some time
    } else {
      _wasConnectedBeforeBackground = false;
    }
  }

  /// Handle app being resumed
  void _handleAppResumed() async {
    await _sshLogger?.logConnection('LIFECYCLE_RESUMED', 
        'App resumed, checking SSH connection status');
    
    if (_wasConnectedBeforeBackground && _sshClient != null) {
      // Check if the SSH connection is still alive
      final isConnectionAlive = await _checkConnectionHealth();
      
      if (!isConnectionAlive) {
        await _sshLogger?.logConnection('LIFECYCLE_CONNECTION_LOST', 
            'SSH connection lost while app was backgrounded');
        
        // Notify the app that reconnection is needed
        onConnectionLost?.call('Connection lost while app was backgrounded');
        
        // Trigger reconnection if callback is provided
        onReconnectionNeeded?.call();
      } else {
        await _sshLogger?.logConnection('LIFECYCLE_CONNECTION_HEALTHY', 
            'SSH connection survived app backgrounding');
      }
    }
    
    _wasConnectedBeforeBackground = false;
  }

  /// Handle app being terminated
  void _handleAppDetached() async {
    await _sshLogger?.logConnection('LIFECYCLE_DETACHED', 
        'App is being terminated, cleaning up SSH connection');
    
    if (_sshClient != null) {
      try {
        // Attempt graceful disconnection
        _sshClient?.close();
      } catch (e) {
        await _sshLogger?.logError(e.toString(), 'graceful SSH disconnection on app termination');
      }
    }
    
    await _sshLogger?.endSession();
  }

  /// Check if the SSH connection is still healthy
  Future<bool> _checkConnectionHealth() async {
    if (_sshClient == null) return false;
    
    try {
      // Send a simple command to test the connection
      final result = await _sshClient!.run('/');
      return result.isNotEmpty;
    } catch (e) {
      await _sshLogger?.logError(e.toString(), 'SSH connection health check');
      return false;
    }
  }

  /// Set up network connectivity monitoring
  void _setupNetworkListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleNetworkChange([result]);
    });
  }

  /// Handle network connectivity changes
  void _handleNetworkChange(List<ConnectivityResult> results) async {
    final isConnected = results.any((result) => 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
    
    if (isConnected) {
      await _sshLogger?.logConnection('NETWORK_CONNECTED', 
          'Network connectivity restored');
      
      // If we had an SSH connection and network is back, check health
      if (_sshClient != null && _lastKnownHost != null) {
        final isHealthy = await _checkConnectionHealth();
        if (!isHealthy) {
          await _sshLogger?.logConnection('NETWORK_RECONNECTION_NEEDED', 
              'SSH connection needs restoration after network change');
          onReconnectionNeeded?.call();
        }
      }
    } else {
      await _sshLogger?.logConnection('NETWORK_DISCONNECTED', 
          'Network connectivity lost');
      
      if (_sshClient != null) {
        onConnectionLost?.call('Network connectivity lost');
      }
    }
  }

  /// Get current network status
  Future<String> getNetworkStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.wifi) {
      return 'WiFi';
    } else if (connectivityResult == ConnectivityResult.mobile) {
      return 'Mobile Data';
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      return 'Ethernet';
    } else {
      return 'No Connection';
    }
  }

  /// Check if the device has network connectivity
  Future<bool> hasNetworkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi || 
        connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.ethernet;
  }
}