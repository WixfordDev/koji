import 'dart:async';
import 'package:koji/services/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../helpers/prefs_helper.dart';

class SocketServices {
  static final SocketServices _socketApi = SocketServices._internal();
  late IO.Socket socket;
  static String? token;

  factory SocketServices() {
    return _socketApi;
  }

  SocketServices._internal();

  Future<void> init({String? userId, fcmToken}) async {
    // if(socket.connected){
    //   disconnect(isManual: true);
    // }

    socket = IO.io(
      ApiConstants.socketUrl,
      // '${ApiConstants.imageBaseUrl}?token=$token',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .enableForceNew()
          .build(),
    );

    _setupSocketListeners(token.toString());
    socket.onConnect((_) {
      socket.emit("user-connected", {
        "userId": "$userId",
        "fcmToken": "$fcmToken",
      });
    }); // Ensure connection starts
  }

  void _setupSocketListeners(String token) {
    socket.onConnect((_) {
      print('========> Socket connected: ${socket.connected}');
    });

    socket.onConnectError((err) {
      print('========> Socket connect error: $err');
    });

    // socket.onDisconnect((_) {
    //   print('========> Socket disconnected! Attempting to reconnect...');
    //   Future.delayed(Duration(seconds: 2), () {
    //     if (!socket.connected) {
    //       socket.connect(); // Force reconnect if needed
    //     }
    //   });
    // });

    socket.onReconnect((_) {
      print('========> Socket reconnected! $token');
      // init();
    });

    socket.onError((error) {
      print('========> Socket error: $error');
    });
  }

  Future<dynamic> emitWithAck(String event, dynamic body) async {
    Completer<dynamic> completer = Completer<dynamic>();
    socket.emitWithAck(
      event,
      body,
      ack: (data) {
        completer.complete(data ?? 1);
      },
    );
    return completer.future;
  }

  void emit(String event, dynamic body) {
    if (body != null) {
      socket.emit(event, body);
      print('===========> Emit $event \n $body');
    }
  }

  // void disconnect() {
  //   socket.disconnect();
  //   print('========> Socket manually disconnected');
  // }
  void disconnect({bool isManual = false}) {
    if (isManual) {
      socket.clearListeners(); // Remove all existing listeners
      socket.disconnect();
      socket.destroy();
      print('========> Socket manually disconnected');
    } else {
      socket.disconnect();
      print('========> Socket disconnected without destroying');
    }
  }
}
