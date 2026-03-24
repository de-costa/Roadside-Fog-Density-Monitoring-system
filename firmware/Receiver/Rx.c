#include <SPI.h>
#include <LoRa.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

//  LCD 
LiquidCrystal_I2C lcd(0x27, 16, 2); 

//  LED Pins 
#define LED_LOW     5
#define LED_MEDIUM  6
#define LED_HIGH    7

//  LoRa Pins 
#define LORA_SS   10
#define LORA_RST  9
#define LORA_DIO0 2

String extractField(String data, String key) {
  int start = data.indexOf(key);
  if (start == -1) return "";

  start += key.length();

  int end = data.indexOf(",", start);
  if (end == -1) end = data.length();

  String value = data.substring(start, end);
  value.trim();
  return value;
}

void clearLEDs() {
  digitalWrite(LED_LOW, LOW);
  digitalWrite(LED_MEDIUM, LOW);
  digitalWrite(LED_HIGH, LOW);
}

void showFogOnLCD(int fogLevel, float humidity, float temperature) {
  lcd.clear();

  if (fogLevel == 1) {
    digitalWrite(LED_LOW, HIGH);
    lcd.setCursor(0, 0);
    lcd.print("FOG LEVEL:LOW");
    lcd.setCursor(0, 1);
    lcd.print("DRIVE SAFE...!");
  }
  else if (fogLevel == 2) {
    digitalWrite(LED_MEDIUM, HIGH);
    lcd.setCursor(0, 0);
    lcd.print("FOG LEVEL:MEDIUM");
    lcd.setCursor(0, 1);
    lcd.print("DRIVE SLOW...!");
  }
  else if (fogLevel == 3) {
    digitalWrite(LED_HIGH, HIGH);
    lcd.setCursor(0, 0);
    lcd.print("FOG LEVEL:HIGH");
    lcd.setCursor(0, 1);
    lcd.print("DANGER-CAREFULL!");
  }
  else {
    lcd.setCursor(0, 0);
    lcd.print("Fog Unknown");
  }

  
}

void setup() {
  Serial.begin(9600);

  // LED setup
  pinMode(LED_LOW, OUTPUT);
  pinMode(LED_MEDIUM, OUTPUT);
  pinMode(LED_HIGH, OUTPUT);

  clearLEDs();

  // LCD setup
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("FogGuard System");
  lcd.setCursor(0, 1);
  lcd.print("Waiting data");

  // LoRa setup
  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);

  if (!LoRa.begin(433E6)) {
    Serial.println("LoRa init failed!");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("LoRa Failed!");
    while (1);
  }

  Serial.println("LoRa Receiver Ready");
}

void loop() {
  int packetSize = LoRa.parsePacket();

  if (packetSize) {
    String received = "";

    while (LoRa.available()) {
      received += (char)LoRa.read();
    }

    received.trim();

    Serial.print("Received: ");
    Serial.println(received);

    
    String humStr = extractField(received, "H:");
    String tempStr = extractField(received, "T:");
    String fogStr = extractField(received, "FOG:");

    if (fogStr == "") {
      Serial.println("FOG field not found");
      return;
    }

    int fogLevel = fogStr.toInt();
    float humidity = humStr.toFloat();
    float temperature = tempStr.toFloat();

    Serial.print("Parsed Fog Level: ");
    Serial.println(fogLevel);

    Serial.print("Parsed Humidity: ");
    Serial.println(humidity, 1);

    Serial.print("Parsed Temperature: ");
    Serial.println(temperature, 1);

    clearLEDs();
    showFogOnLCD(fogLevel, humidity, temperature);
  }
}