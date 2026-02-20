#include <SPI.h>
#include <LoRa.h>
#include <DHT.h>

// DHT22
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

//IR Sensor
#define IR_PIN A0   // IR amplified output

// Fog Levels
#define FOG_LOW    1
#define FOG_MEDIUM 2
#define FOG_HIGH   3

int counter = 0;

int getFogLevel(int irValue, float humidity) {
  if (humidity > 90 && irValue < 70) {
    return FOG_HIGH;
  }
  else if (humidity > 75 && irValue < 85) {
    return FOG_MEDIUM;
  }
  else {
    return FOG_LOW;
  }
}

void setup() {
  Serial.begin(9600);
  while (!Serial);

  Serial.println("Fog Level LoRa Sender");

  dht.begin();

  if (!LoRa.begin(433E6)) {
    Serial.println("LoRa init failed!");
    while (1);
  }

  LoRa.setTxPower(5); // safe low power
}

void loop() {
  float humidity = dht.readHumidity();
  int irValue = analogRead(IR_PIN);

  if (isnan(humidity)) {
    Serial.println("DHT22 read error");
    delay(2000);
    return;
  }

  int fogLevel = getFogLevel(irValue, humidity);

  Serial.print("IR: ");
  Serial.print(irValue);
  Serial.print(" | Humidity: ");
  Serial.print(humidity);
  Serial.print(" % | Fog Level: ");

  if (fogLevel == FOG_LOW) Serial.println("LOW");
  else if (fogLevel == FOG_MEDIUM) Serial.println("MEDIUM");
  else Serial.println("HIGH");

  // Send packet
  LoRa.beginPacket();
  LoRa.print("IR:");
  LoRa.print(irValue);
  LoRa.print(",H:");
  LoRa.print(humidity);
  LoRa.print(",FOG:");
  LoRa.print(fogLevel);
  LoRa.endPacket();

  counter++;
  delay(1000);
}