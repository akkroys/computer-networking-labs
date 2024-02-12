import 'dart:convert';
import 'dart:io';

void main() async {
  var server = await ServerSocket.bind(InternetAddress.anyIPv4, 12345);
  print('Сервер запущен и прослушивает порт ${server.port}');

  await for (var socket in server) {
    handleConnection(socket);
  }
}

void handleConnection(Socket socket) {
  print(
      'Новое соединение с клиентом: ${socket.remoteAddress}:${socket.remotePort}');

  socket.listen(
    (List<int> data) {
      var message = utf8.decode(data).trim();
      var response = swapCharacters(message);
      print('Получено сообщение от клиента: $message');
      socket.write(response);
      print('Отправлено обратно: $response');
    },
    onError: (e) {
      print('Ошибка: $e');
      socket.close();
    },
    onDone: () {
      print('Клиент отключен');
      socket.close();
    },
  );
}

String swapCharacters(String input) {
  var characters = input.split('');
  for (var i = 0; i < characters.length - 1; i += 2) {
    var temp = characters[i];
    characters[i] = characters[i + 1];
    characters[i + 1] = temp;
  }
  return characters.join('');
}
