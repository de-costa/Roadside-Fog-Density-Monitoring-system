#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// I2C address (most common: 0x27 or 0x3F)
LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {
  lcd.init();          // Initialize LCD
  lcd.backlight();     // Turn ON backlight

  lcd.setCursor(0, 0);
  lcd.print("We are Group 18");

 // lcd.setCursor(0, 1);
  //lcd.print("GROUP 18");
}

void loop() {
  // nothing here
}
