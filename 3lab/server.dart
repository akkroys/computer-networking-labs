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
  final server = await ServerSocket.bind('127.0.0.1', 3000);
  print('Server listening on port 3000');

  List<Tour> tours = [
    Tour('Путешествие в Париж', 500.0, 7, 'Поезд'),
    Tour('Отдых на море', 300.0, 5, 'Автобус'),
    Tour('Тур в горы', 700.0, 10, 'Машина'),
    Tour('Экскурсия по городу', 200.0, 3, 'Пешком'),
    Tour('Круиз по реке', 1000.0, 14, 'Корабль'),
  ];

  await for (var socket in server) {
    handleConnection(socket, tours);
  }
}

void handleConnection(Socket socket, List<Tour> tours) {
  print('Client connected: ${socket.remoteAddress}:${socket.remotePort}');

  socket.listen((List<int> data) async {
    var message = utf8.decode(data).trim();
        print('Received: $message');

    try {
      var requestedBudget = double.parse(message);

      var matchingTours = tours.where((tour) => tour.cost <= requestedBudget).toList();
      
      if (matchingTours.isNotEmpty) {
        var response = matchingTours.map((tour) => '${tour.name}, цена: ${tour.cost}').join('\n');
        print('Sending response: $response');
        socket.write(response);
      } else {
        print('Нет туров, подходящих под данный бюджет');
        socket.write('Нет туров, подходящих под данный бюджет.');
      }

      await socket.flush();
    } catch (e) {
      print('Error processing request: $e');
      socket.write('Invalid budget format.\n');
      await socket.flush(); 
    }
  }, onError: (e) {
    print('Ошибка: $e');
    socket.close();
  }, onDone: () {
    print('Client disconnected');
    socket.close();
  });
}
