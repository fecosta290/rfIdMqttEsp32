#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <esp_mac.h>
#include "time.h"

// === RFID ===
#define SS_PIN 21   // SDA
#define RST_PIN 22  // RST
MFRC522 mfrc522(SS_PIN, RST_PIN);

// === Wi-Fi e MQTT ===
char *ssid = "nome da sua rede Wi-Fi";
char *pwd = "senha da sua rede Wi-Fi";
char *mqttServer = "test.mosquitto.org";
WiFiClient wclient;
PubSubClient mqttClient(wclient);

// === NTP ===
char *ntpServer = "br.pool.ntp.org";
long gmtOffset = -3 * 3600;
int daylight = 0;
time_t now;
struct tm timeinfo;

// === UID do ESP ===
char uid[13];

// === Variáveis de controle ===
uint32_t hora = 0;
uint32_t ultimaHora = 1;

void connectWiFi() {
  Serial.print("Conectando ao Wi-Fi");
  WiFi.begin(ssid, pwd);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi conectado com IP:");
  Serial.println(WiFi.localIP());
}

void connectMqtt() {
  if (!mqttClient.connected()) {
    if (mqttClient.connect(uid)) {
      Serial.println("Conectado ao broker MQTT");
    } else {
      Serial.println("Falha ao conectar ao broker MQTT");
      delay(1000);
    }
  }
}

void sincronizaTempo() {
  configTime(gmtOffset, daylight, ntpServer);
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao sincronizar com o NTP");
  } else {
    Serial.print("Hora atual (epoch): ");
    now = time(nullptr);
    Serial.println(now);
  }
}

void setup() {
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();

  // UID do dispositivo
  uint8_t mac[6];
  esp_read_mac(mac, ESP_MAC_WIFI_STA);
  snprintf(uid, sizeof(uid), "%02X%02X%02X%02X%02X%02X",
           mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

  Serial.print("Dispositivo UID: ");
  Serial.println(uid);

  connectWiFi();
  sincronizaTempo();
  mqttClient.setServer(mqttServer, 1883);

  Serial.println("Aproxime o cartão do leitor...");
}

void loop() {
  if (!mqttClient.connected()) {
    connectMqtt();
  }

  mqttClient.loop();

  // Atualiza hora atual
  now = time(nullptr);
  hora = now;

  // Checa se há um cartão novo
  if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) {
    return;
  }

  // Monta o UID do cartão
  String cardUID = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) cardUID += "0";
    cardUID += String(mfrc522.uid.uidByte[i], HEX);
  }
  cardUID.toUpperCase();

  Serial.print("Cartão lido: ");
  Serial.println(cardUID);

  // Monta o JSON
  String payload = "{\"uid_esp\":\"" + String(uid) + "\",\"uxt\":" + String(now) + ",\"uid_card\":\"" + cardUID + "\"}";

  // Envia via MQTT
  mqttClient.publish("fatec/ppdm/5dsm/codeLand/rfid", payload.c_str());
  Serial.println("Publicado no MQTT:");
  Serial.println(payload);

  delay(1500);
}
