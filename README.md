# Projeto MQTT com ESP32 + Mosquitto + Flutter

Este projeto conecta uma **placa ESP32** a um broker **Mosquitto MQTT** via Docker, e exibe as mensagens publicadas em um **aplicativo Flutter**.

---

## 🐳 1. Subir o broker Mosquitto (MQTT) com Docker

### Pré-requisitos:
- Docker instalado (https://www.docker.com)

### Passos:

```bash
docker run -it -p 1883:1883 -p 9001:9001 eclipse-mosquitto
```

Porta 1883: padrão MQTT (TCP)

Porta 9001: MQTT via WebSocket (usado no Flutter se necessário)

O broker estará disponível em: mqtt://localhost:1883

# 📡 2. Subir o ESP32 (com Arduino IDE ou PlatformIO)

### Pré-requisitos:
- ESP32 conectado via USB
- Arduino IDE com biblioteca PubSubClient instalada

### Passos:

Abra a ide

cole o codigo que esta em c/rfid.c
### obs: lembre-se de alterar as configurações de wifi para usar as suas credenciais

compile o codigo com a placa esp32 conectada
### obs: lembre-se de pressionar o botão boot ao aparecer "Connecting...." no terminal da ide

# 📡 📱 3. Rodar o app Flutter

### Pré-requisitos:
- Flutter instalado (https://flutter.dev)
- Arduino IDE com biblioteca PubSubClient instalada

### Passos:

flutter pub get
flutter run