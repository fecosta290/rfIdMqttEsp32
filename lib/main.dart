import 'package:flutter/material.dart';
import 'mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Viewer',
      theme: ThemeData.dark(),
      home: const MqttScreen(),
    );
  }
}

class MqttScreen extends StatefulWidget {
  const MqttScreen({super.key});

  @override
  State<MqttScreen> createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  final MqttService mqttService = MqttService();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
    mqttService.connect((message) {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagens MQTT')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(messages[index]),
        ),
      ),
    );
  }
}
