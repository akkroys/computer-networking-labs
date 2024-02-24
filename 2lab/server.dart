import 'dart:io';
import 'dart:convert';
import 'package:udp/udp.dart';

void main() async {
  var unicastEndpoint =
      Endpoint.unicast(InternetAddress("127.0.0.1"), port: Port(54321));

  var receiver = await UDP.bind(unicastEndpoint);

  var sender = await UDP.bind(Endpoint.any());

  bool exitRequested = false;

  while (!exitRequested) {
    print('Enter a string to send to the server, or type "exit" to quit:');
    var input = stdin.readLineSync();
    if (input != null) {
      if (input.toLowerCase() == 'exit') {
        exitRequested = true;
        continue;
      }
      print('Sending: $input');
      await sender.send(utf8.encode(input), unicastEndpoint);
      await Future.delayed(Duration(seconds: 1));
    }

    receiver.asStream().listen((datagram) async {
      if (datagram != null) {
        var str = String.fromCharCodes(datagram.data);
        var modifiedString = swapCharacters(str);
        print('Received: $str');
        await Future.delayed(Duration(seconds: 1));
        print('Modified: $modifiedString');
        var clientEndpoint =
            Endpoint.unicast(datagram.address, port: Port(datagram.port));
        receiver.send(utf8.encode(modifiedString), clientEndpoint);
      }
    });

    sender.asStream().listen((event) async {
      if (event != null) {
        var modifiedStr = utf8.decode(event.data);
        print('Response from server: $modifiedStr');
      }
    });

    await Future.delayed(Duration(seconds: 3));
  }

  print('Exiting...');
  sender.close();
  receiver.close();
}

String swapCharacters(String str) {
  var chars = str.split('');
  for (int i = 0; i < chars.length - 1; i += 2) {
    var temp = chars[i];
    chars[i] = chars[i + 1];
    chars[i + 1] = temp;
  }
  return chars.join('');
}
