import 'dart:convert';
import 'dart:io';

class Tour {
  String name;
  double cost;
  int duration;
  String transport;

  Tour(this.name, this.cost, this.duration, this.transport);
}

void main() async {
  List<Tour> tours = [
    Tour('Путешествие в Париж', 500.0, 7, 'Поезд'),
    Tour('Отдых на море', 300.0, 5, 'Автобус'),
    Tour('Тур в горы', 700.0, 10, 'Машина'),
    Tour('Экскурсия по городу', 200.0, 3, 'Пешком'),
    Tour('Круиз по реке', 1000.0, 14, 'Корабль'),
  ];

  var serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 8888);
  print(
      'Сервер запущен на адресе ${serverSocket.address} порт ${serverSocket.port}');

  await for (var socket in serverSocket) {
    handleConnection(socket, tours);
  }
}

void handleConnection(Socket socket, List<Tour> tours) {
  print('Новое подключение: ${socket.remoteAddress}:${socket.remotePort}');

  socket.listen((List<int> data) {
    String receivedData = utf8.decode(data);
    double? clientCost = double.tryParse(receivedData);
    if (clientCost != null) {
      List<Map<String, dynamic>> selectedTours = [];
      for (var tour in tours) {
        if (tour.cost <= clientCost) {
          selectedTours.add({'name': tour.name, 'cost': tour.cost});
        }
      }
      String responseData = selectedTours.isNotEmpty
          ? json.encode(selectedTours)
          : 'Нет доступных туров';
      socket.write(responseData);
    } else {
      socket.write('Ошибка: Неверный формат данных');
    }
  }, onError: (e) {
    print('Ошибка при чтении данных: $e');
    socket.close();
  }, onDone: () {
    print('Соединение с ${socket.remoteAddress}:${socket.remotePort} закрыто.');
    socket.close();
  });
}
