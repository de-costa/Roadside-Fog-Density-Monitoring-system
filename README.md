# 🌫️🛣️ FogGuard: Roadside Fog Density Monitoring & Accident Prevention System

## 📌 Overview

FogGuard is an **IoT-based intelligent roadside monitoring system** designed to detect fog density in real time and warn drivers about hazardous road conditions. The system combines **embedded systems, wireless communication (LoRa), cloud integration, and a mobile application** to provide proactive safety alerts and reduce fog-related accidents.

---

## 🚀 Key Features

* 🌫️ **Real-Time Fog Detection** using IR sensors
* 💧 **Humidity Monitoring** with DHT22 sensor
* 📡 **Long-Range Communication** via LoRa (RA-02)
* 📲 **Mobile Application- FogGuard (Flutter)** for remote monitoring
* ☁️ **Cloud Integration (Firebase)** for real-time data updates
* 🚦 **Visual Alerts System** (LCD display & LED indicators for LOW / MEDIUM / HIGH fog)
* ⚡ **Low Power Embedded Design**

---

## 🧠 System Architecture

```
 [ Sensors (IR + DHT22) ]
            ↓
      [ ATmega328P ]
            ↓
   ┌───────────────┐
   │   LoRa TX     │────────────▶ LoRa RX ──▶ [ Receiver Node (LCD + LEDs) ]
   └───────────────┘
            ↓
     [ ESP8266 WiFi ]
            ↓
      [ Firebase DB ]
            ↓
 [ Mobile App (Flutter) ]
```

---

## 🧩 Hardware Components

### 🔹 Transmitter Unit

* ATmega328P Microcontroller
* IR Emitter + Receiver (Fog Detection)
* DHT22 Humidity Sensor
* LoRa RA-02 Module
* ESP8266 WiFi Module
* Custom Designed PCB

### 🔹 Receiver Unit

* ATmega328P Microcontroller
* LoRa RA-02 Module
* I2C LCD Display (16x2)
* LED Indicators (Green, Yellow, Red)
* Custom PCB

---

## 💻 Software Components

| Component         | Technology                 |
| ----------------- | -------------------------- |
| Embedded Firmware | C                          |
| Mobile App        | Flutter                    |
| Cloud Database    | Firebase Realtime Database |
| Version Control   | Git & GitHub               |

---

## 📱 Mobile Application

The FogGuard mobile app provides:

* Route selection interface
* Real-time fog level monitoring
* Node-based on location
* Fog warnings with Node details
---

## ☁️ Firebase Database Structure

```
fog_nodes/
   └── kilinochchi/
         ├── name
         ├── location
         ├── fogLevel
         ├── humidity
         ├── warning
         └── lastUpdated
```

---

## ⚙️ How It Works

1. Sensors detect fog density and humidity levels
2. ATmega processes data and classifies fog level
3. Data is transmitted via LoRa to nearby receiver units
4. ESP8266 sends data to Firebase cloud
5. Mobile app retrieves and displays real-time data
6. Drivers receive alerts and make safer decisions

---

## 🔧 Setup Instructions

### 🔹 Hardware

* Assemble transmitter and receiver circuits
* Verify all SPI and UART connections

### 🔹 Firmware

* Upload transmitter and receiver code
* Upload ESP8266 code separately

### 🔹 Mobile App

```bash
flutter pub get
flutter run
```

### 🔹 Firebase

* Create Realtime Database
* Configure read/write rules
* Update database URL in app

---

## 📊 Project Status

* ✅ Hardware Design & implementation Completed (PCB vFinal)
* ✅ LoRa Communication Working
* ✅ Firebase Integration Completed
* ✅ Mobile App UI Completed

---

## 📜 License

This project is developed for academic and research purposes.

---

## 🌟 Acknowledgment

This project was developed as part of an embedded systems to improve road safety through smart technology.

---

## 📬 Contact

For inquiries or collaboration opportunities, feel free to reach out.

---

> ⚡ *FogGuard – Enhancing Road Safety Through Smart Monitoring*
