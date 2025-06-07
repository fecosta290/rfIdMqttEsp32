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

class UserCard {
  final String name;
  final String uid;

  UserCard({required this.name, required this.uid});
}

class Message {
  final String uid;
  final String userName;

  Message({required this.uid, required this.userName});
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

  final List<UserCard> _users = [];
  final List<Message> _messages = [];

  String? _latestUid;

  @override
  void initState() {
    super.initState();
    mqttService.connect((message) {
      setState(() {
        _latestUid = message;
        _uidController.text = message;

        final user = _users.firstWhere(
          (u) => u.uid == message,
          orElse: () => UserCard(name: 'Desconhecido', uid: message),
        );

        _messages.insert(0, Message(uid: message, userName: user.name));
      });
    });
  }

  void _addUser() {
    final name = _nameController.text.trim();
    final uid = _latestUid;

    if (name.isEmpty || uid == null) return;

    // Verifica se o UID já está cadastrado
    final exists = _users.any((user) => user.uid == uid);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse cartão já está cadastrado!')),
      );
      return;
    }

    setState(() {
      _users.add(UserCard(name: name, uid: uid));
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
                    width: 200,
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
                    width: 200,
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
                  ? const Center(child: Text('Nenhuma mensagem recebida ainda.'))
                  : SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[800]!),
                          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
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
                              DataCell(Text(msg.userName)),
                            ]);
                          }),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
