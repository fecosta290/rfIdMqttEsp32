import 'dart:convert';
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
      title: 'MQTT Viewer com Cadastro',
      theme: ThemeData.dark(),
      home: const MqttScreen(),
    );
  }
}

class Message {
  final String uid;
  final String? userName;

  Message({required this.uid, this.userName});
}

class MqttScreen extends StatefulWidget {
  const MqttScreen({super.key});

  @override
  State<MqttScreen> createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  final MqttService mqttService = MqttService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();

  final List<Message> _messages = [];
  final Map<String, String> _userMap = {}; // uid_card -> nome
  String? _latestUid;

  @override
  void initState() {
    super.initState();
    mqttService.connect((message) {
      setState(() {
        try {
          final data = jsonDecode(message);
          final uidCard = data['uid_card'];
          _latestUid = uidCard;
          _uidController.text = uidCard;

          final userName = _userMap[uidCard] ?? 'Desconhecido';

          _messages.insert(0, Message(uid: uidCard, userName: userName));
        } catch (e) {
          print('Erro ao decodificar mensagem: $e');
        }
      });
    });
  }

  void _addUser() {
    final name = _nameController.text.trim();
    final uid = _latestUid;

    if (name.isEmpty || uid == null) return;

    if (_userMap.containsKey(uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este cartão já está cadastrado!')),
      );
      return;
    }

    setState(() {
      _userMap[uid] = name;
      _nameController.clear();
      _uidController.clear();
      _latestUid = null;
    });
  }

  @override
  void dispose() {
    mqttService.disconnect();
    _nameController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro + Mensagens MQTT')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Formulário de cadastro
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do usuário',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      readOnly: true,
                      controller: _uidController,
                      decoration: InputDecoration(
                        labelText: 'UID do Cartão',
                        border: const OutlineInputBorder(),
                        hintText: 'Aproxime o cartão...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Tabela de mensagens recebidas
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text('Nenhuma mensagem recebida ainda.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[800]!),
                        dataRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[900]!),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('UID do Cartão')),
                          DataColumn(label: Text('Usuário')),
                        ],
                        rows: List.generate(_messages.length, (index) {
                          final msg = _messages[index];
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(msg.uid)),
                            DataCell(Text(_userMap[msg.uid] ?? 'Desconhecido')),
                          ]);
                        }),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
