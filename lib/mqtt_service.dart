// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';

// class MqttService {
//   final client =
//       MqttServerClient.withPort('test.mosquitto.org', 'flutter_client', 1883);

//   Future<void> connect(Function(String) onMessageReceived) async {
//     client.logging(on: true);
//     client.setProtocolV311();
//     client.keepAlivePeriod = 20;

//     client.onConnected = () => print('Conectado');
//     client.onDisconnected = () => print('Desconectado');
//     client.onSubscribed = (topic) => print('Subscrito em $topic');

//     try {
//       await client.connect();
//     } catch (e) {
//       print('Erro na conexão: $e');
//       client.disconnect();
//       return;
//     }

//     const topic = 'fatec/ppdm/5dsm/codeLand/rfid';
//     client.subscribe(topic, MqttQos.atMostOnce);

//     client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       final recMess = c![0].payload as MqttPublishMessage;
//       final pt =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

//       onMessageReceived(pt);
//     });
//   }

//   void disconnect() {
//     client.disconnect();
//   }
// }

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  late final MqttServerClient client;

  MqttService() {
    // Gerar um ID único para o client
    final uuid = Uuid().v4();
    client = MqttServerClient.withPort('test.mosquitto.org', uuid, 1883);
  }

  Future<void> connect(Function(String) onMessageReceived) async {
    client.logging(on: true); // Ativar logs para debugar
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.onConnected = () => print('Conectado');
    client.onDisconnected = () => print('Desconectado');
    client.onSubscribed = (topic) => print('Subscrito em $topic');

    try {
      await client.connect();
    } catch (e) {
      print('Erro na conexão: $e');
      client.disconnect();
      return;
    }

    const topic = 'fatec/ppdm/5dsm/codeLand/rfid';
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      onMessageReceived(pt);
    });
  }

  void disconnect() {
    client.disconnect();
  }
}
