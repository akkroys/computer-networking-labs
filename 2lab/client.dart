import 'dart:convert';
import 'dart:io';

void main() async {
  var socket = await Socket.connect('127.0.0.1', 12345);
  print('Подключено к серверу');

  print('Введите строку: ');

  var input = stdin.transform(utf8.decoder).transform(const LineSplitter());

  input.listen((String line) {
    socket.write(line);
  });

  socket.listen((List<int> data) {
    var response = utf8.decode(data).trim();
    print('Получен ответ от сервера: $response');
  });

  await socket.done;
  print('Соединение с сервером завершено');
}
