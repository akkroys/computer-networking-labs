import 'dart:convert';
import 'dart:io';

void main() async {
  final socket = await Socket.connect('127.0.0.1', 3000);
  print('Connected to server');

  print('Введите свой бюджет:');

  var input = stdin.readLineSync();
  
  if (input != null && input.isNotEmpty) {
    socket.writeln(input);

    socket.listen(
      (data) {
        print('Server: ${utf8.decode(data)}');
      },
      onDone: () {
        print('Server disconnected');
        socket.close();
        exit(0);
      },
      onError: (e) {
        print('Ошибка: $e');
        socket.close();
      },
    );
  } else {
    print('Пустой ввод. Попробуйте снова.');
    socket.close();
  }
}
