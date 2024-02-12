import 'dart:convert';
import 'dart:io';

void main() async {
  final server = await ServerSocket.bind('127.0.0.1', 12345);
  print('Сервер прослушивается по ${server.address}:${server.port}');

  await for (var socket in server) {
    handleConnection(socket);
  }
}

void handleConnection(Socket socket) {
  print('Клиент подключен из ${socket.remoteAddress}:${socket.remotePort}');

  socket.listen(
    (List<int> data) {
      final receivedString = utf8.decode(data).trim();
      final List<String> coordinates = receivedString.split(' ');

      if (coordinates.length != 2) {
        socket.write(
            'Неверный ввод. Пожалуйста, введите координаты X и Y, разделенные пробелом.');
        return;
      }
      try {
        final x = double.parse(coordinates[0]);
        final y = double.parse(coordinates[1]);

        String quadrant;
        if (x > 0 && y > 0) {
          quadrant = 'Первая четверть';
        } else if (x < 0 && y > 0) {
          quadrant = 'Вторая четверть';
        } else if (x < 0 && y < 0) {
          quadrant = 'Третья четверть';
        } else if (x > 0 && y < 0) {
          quadrant = 'Четвертая четверть';
        } else {
          quadrant = 'На координатных осях или в центре';
        }
        socket.write('Точка ($x, $y) в $quadrant\n');
      } catch (e) {
        socket.write('Неверный ввод. Пожалуйста, введите числовое значение');
      }
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
