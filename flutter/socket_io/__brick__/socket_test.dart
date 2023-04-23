import './socket_test.dart';

void initSocket() {
  Socket socket = SocketUtils('http:localhost:3000').instance;

  socket.connect();
  socket.onConnect((_) {
    // //  way to fight buffering on client side , not send message automatically if the newtwork disconnects and reconnects
    socket.sendBuffer = [];
  });
  socket.onDisconnect((_) {
    debugPrint('Connection Disconnection');
  });
  socket.onError((err) => debugPrint(err));
  socket.onReconnect((_) {
    debugPrint('Reconnected');
  });
  socket.onReconnectAttempt((_) {
    debugPrint('reconnect attempt');
    // handle reconnect attempt
    // clear the messages in the stack and send them again
  });

  socket.onReconnectError((err) {
    debugPrint('reconnect error: $err');
  });
  socket.onConnectError((err) {
    debugPrint('connect error: $err');
  });
  socket.onReconnectFailed((_) {
    debugPrint('reconnect failed');
  });
  socket.onConnectTimeout((_) {
    debugPrint('connect timeout');
  });
  socket.onPing((_) {
    debugPrint('ping');
  });
  socket.onReconnect((_) {
    debugPrint('reconnected');
  });
}
