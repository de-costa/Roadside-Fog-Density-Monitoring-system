#include <SPI.h>
#include <LoRa.h>
#include <DHT.h>
#include <SoftwareSerial.h>

SoftwareSerial ESP(5, 6);

// ---------------- DHT22 ----------------
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

//  IR Sensor 
#define IR_PIN A0

//  LoRa Pins 
#define LORA_SS   10
#define LORA_RST  9
#define LORA_DIO0 2

//  Fog Levels 
#define FOG_LOW     1
#define FOG_MEDIUM  2
#define FOG_HIGH    3

unsigned long lastSendTime = 0;
const unsigned long sendInterval = 5000;  

int getFogLevel(int irValue, float humidity) {
  if (humidity > 95.0 && irValue <4 ) {
    return FOG_HIGH;
  } 
  else if (humidity > 85.0 && irValue <9 ) {
    return FOG_MEDIUM;
  } 
  else {
    return FOG_LOW;
  }
}

String getFogStatus(int fogLevel) {
  if (fogLevel == FOG_LOW) return "Low";
  if (fogLevel == FOG_MEDIUM) return "Moderate";
  if (fogLevel == FOG_HIGH) return "High";
  return "Unknown";
}

String getWarning(int fogLevel) {
  if (fogLevel == FOG_LOW) return "Low fog risk";
  if (fogLevel == FOG_MEDIUM) return "Moderate fog risk";
  if (fogLevel == FOG_HIGH) return "High fog risk";
  return "Unknown";
}

void setup() {
  Serial.begin(9600);
  ESP.begin(9600);

  dht.begin();

  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  if (!LoRa.begin(433E6)) {
    Serial.println("LoRa initialization failed");
    while (1);
  }

  Serial.println("Sensor node ready");
}

void loop() {
  if (millis() - lastSendTime >= sendInterval) {
    lastSendTime = millis();

    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();
    int irValue = analogRead(IR_PIN);

    if (isnan(humidity) || isnan(temperature)) {
      Serial.println("DHT read failed");
      return;
    }

    int fogLevel = getFogLevel(irValue, humidity);
    String fogStatus = getFogStatus(fogLevel);
    String warning = getWarning(fogLevel);

    String data = "IR:" + String(irValue) +
                  ",H:" + String(humidity, 1) +
                  ",T:" + String(temperature, 1) +
                  ",FOG:" + String(fogLevel) +
                  ",STATUS:" + fogStatus +
                  ",WARNING:" + warning;

    // Send to ESP8266 first
    ESP.println(data);
    delay(50);

    // Send through LoRa
    LoRa.beginPacket();
    LoRa.print(data);
    LoRa.endPacket();

    Serial.println("Sent packet");
    Serial.println(data);
    Serial.println("------------------------");
  }
}