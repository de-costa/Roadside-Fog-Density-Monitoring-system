#include <SPI.h>
#include <LoRa.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// LCD 
LiquidCrystal_I2C lcd(0x27, 16, 2); 

// LED Pins
#define LED_LOW     5
#define LED_MEDIUM  6
#define LED_HIGH    7

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // LED setup
  pinMode(LED_LOW, OUTPUT);
  pinMode(LED_MEDIUM, OUTPUT);
  pinMode(LED_HIGH, OUTPUT);

  // LCD setup
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("FogGuard System");
  lcd.setCursor(0, 1);
  lcd.print("Waiting data");

  // LoRa setup
  if (!LoRa.begin(433E6)) {
    Serial.println("LoRa init failed!");
    while (1);
  }

  Serial.println("LoRa Receiver Ready");
}

void clearLEDs() {
  digitalWrite(LED_LOW, LOW);
  digitalWrite(LED_MEDIUM, LOW);
  digitalWrite(LED_HIGH, LOW);
}

void loop() {
  int packetSize = LoRa.parsePacket();
  if (packetSize) {

    String received = "";
    while (LoRa.available()) {
      received += (char)LoRa.read();
    }

    Serial.print("Received: ");
    Serial.println(received);

    // Extract fog level
    int fogIndex = received.indexOf("FOG:");
    if (fogIndex == -1) return;

    int fogLevel = received.substring(fogIndex + 4).toInt();

    clearLEDs();
    lcd.clear();

    lcd.setCursor(0, 0);
    lcd.print("Fog Level:");

    if (fogLevel == 1) {
      digitalWrite(LED_LOW, HIGH);
      lcd.setCursor(0, 1);
      lcd.print("LOW - Safe");
    }
    else if (fogLevel == 2) {
      digitalWrite(LED_MEDIUM, HIGH);
      lcd.setCursor(0, 1);
      lcd.print("MEDIUM - Slow");
    }
    else if (fogLevel == 3) {
      digitalWrite(LED_HIGH, HIGH);
      lcd.setCursor(0, 1);
      lcd.print("HIGH - Danger");
    }

    delay(2000);
  }
}