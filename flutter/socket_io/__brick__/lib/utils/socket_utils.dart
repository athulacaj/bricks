import 'package:socket_io_client/socket_io_client.dart';

class SocketUtils {
  late Socket socket;
  final String path;
  static final Map<String, SocketUtils> _instances = {};

  factory SocketUtils(String path) {
    if (_instances.containsKey(path)) {
      return _instances[path]!;
    }
    final newInstance = SocketUtils._internal(path: path);
    _instances[path] = newInstance;
    return newInstance;
  }

  SocketUtils._internal({required this.path}) {
    initSocket(path);
  }

  void initSocket(String path) {
    socket = io(path, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
  }

  // getter for socket
  Socket get instance => socket;

  void dispose() {
    socket.disconnect();
    socket.dispose();
    _instances.remove(path);
  }
}
