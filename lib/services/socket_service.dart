import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as dev;

class SocketService {
  static const String serverUrl = 'http://localhost:5000';
  late IO.Socket _socket;

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  void init(String userId) {
    _socket = IO.io(serverUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({'userId': userId})
        .enableAutoConnect()
        .build()
    );

    _socket.onConnect((_) {
      dev.log('Connected to socket server');
    });

    _socket.onDisconnect((_) => dev.log('Disconnected from socket server'));
  }

  void onNewAlert(Function(dynamic) callback) {
    _socket.on('new_alert', (data) => callback(data));
  }

  void onNewMessage(Function(dynamic) callback) {
    _socket.on('new_message', (data) => callback(data));
  }

  void disconnect() {
    _socket.disconnect();
  }
}
