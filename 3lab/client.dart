import 'dart:convert';
import 'dart:io';

void main() async {
  var socket = await Socket.connect('localhost', 8888);
  print('Подключено к серверу ${socket.remoteAddress}:${socket.remotePort}');

  stdout.write('Введите ваш бюджет: ');
  String? budgetInput = stdin.readLineSync();
  if (budgetInput != null) {
    var budget = double.tryParse(budgetInput);
    if (budget != null) {
      print('Отправлено: $budget');
      socket.write(budget.toString());
    } else {
      print('Неверный формат бюджета');
      socket.destroy();
      return;
    }
  } else {
    print('Ввод отсутствует');
    socket.destroy();
    return;
  }

socket.listen((List<int> data) {
  String decodedData = utf8.decode(data);
  if (decodedData.startsWith('{') && decodedData.endsWith('}')) {
    List<dynamic> selectedTours = json.decode(decodedData);
    if (selectedTours.isNotEmpty) {
      print('Доступные туры:');
      for (var tour in selectedTours) {
        print('Название: ${tour['name']}, Стоимость: ${tour['cost']}');
      }
    } else {
      print('Нет доступных туров');
    }
  } else {
    print(decodedData);
  }
  }, onDone: () {
    print('Соединение с сервером закрыто.');
    socket.destroy();
  }, onError: (e) {
    print('Ошибка при чтении данных: $e');
    socket.destroy();
  });
}
