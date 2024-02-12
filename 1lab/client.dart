import 'dart:convert';
import 'dart:io';

void main() async {
  final socket = await Socket.connect('127.0.0.1', 12345);
  print('Подключен к серверу');

  print('Введите координаты в формате X Y:');

  final input = stdin.transform(utf8.decoder).transform(const LineSplitter());

  input.listen(
    (String line) {
      if (line.toLowerCase() == 'exit') {
        socket.writeln(line);
        socket.close();
        return;
      }
      socket.write(line);
    },
  );
  
  socket.listen(
    (List<int> data) {
      final response = utf8.decode(data);
      print('Ответ сервера: $response');
    },
    onDone: () {
      print('Сервер отключен');
      socket.destroy();
    },
    onError: (error) {
      print(error);
      socket.destroy();
    }
  );
}
