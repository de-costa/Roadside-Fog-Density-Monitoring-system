#include <ESP8266WiFi.h>
#include <WiFiClientSecureBearSSL.h>
#include <time.h>

//  WiFi 
const char* ssid = "M01s";
const char* password = "20020533";

//  Firebase 
const char* host = "fogguard-e083-default-rtdb.asia-southeast1.firebasedatabase.app";
String firebasePath = "/fog_nodes/kilinochchi.json";
String authToken = "";

//  Time 
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 19800;   // Sri Lanka UTC+5:30
const int daylightOffset_sec = 0;

std::unique_ptr<BearSSL::WiFiClientSecure> client;
String incoming = "";

void setup() {
  Serial.begin(9600);
  delay(1000);

  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.println("WiFi connected");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println("Time configured");

  client.reset(new BearSSL::WiFiClientSecure);
  client->setInsecure(); 

  Serial.println("ESP8266 ready to receive sensor data");
}

void loop() {
  while (Serial.available()) {
    char c = Serial.read();

    if (c == '\n') {
      incoming.trim();

      if (incoming.length() > 0) {
        Serial.println("Received packet:");
        Serial.println(incoming);
        processData(incoming);
      }

      incoming = "";
    } 
    else {
      incoming += c;
    }
  }
}

String extractField(String data, String key) {
  int start = data.indexOf(key);
  if (start == -1) return "";

  int end = data.indexOf(",", start);
  if (end == -1) end = data.length();

  return data.substring(start + key.length(), end);
}

String getCurrentTimeISO() {
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);

  if (p_tm == NULL) {
    return "1970-01-01T00:00:00Z";
  }

  char buffer[30];
  sprintf(buffer, "%04d-%02d-%02dT%02d:%02d:%02dZ",
          p_tm->tm_year + 1900,
          p_tm->tm_mon + 1,
          p_tm->tm_mday,
          p_tm->tm_hour,
          p_tm->tm_min,
          p_tm->tm_sec);

  return String(buffer);
}

void processData(String data) {
  String irStr      = extractField(data, "IR:");
  String humStr     = extractField(data, "H:");
  String tempStr    = extractField(data, "T:");
  String fogStr     = extractField(data, "FOG:");
  String statusStr  = extractField(data, "STATUS:");
  String warningStr = extractField(data, "WARNING:");

  if (irStr == "" || humStr == "" || tempStr == "" || fogStr == "") {
    Serial.println("Invalid packet format");
    return;
  }

  String lastUpdated = getCurrentTimeISO();

  String json = "{";
  json += "\"nodeId\":\"FG002\",";
  json += "\"name\":\"Kilinochchi\",";
  json += "\"location\":\"Kilinochchi, Sri Lanka\",";
  json += "\"irValue\":" + irStr + ",";
  json += "\"humidity\":" + humStr + ",";
  json += "\"temperature\":" + tempStr + ",";
  json += "\"fogLevel\":" + fogStr + ",";
  json += "\"fogStatus\":\"" + statusStr + "\",";
  json += "\"warning\":\"" + warningStr + "\",";
  json += "\"deviceStatus\":\"Active\",";
  json += "\"lastUpdated\":\"" + lastUpdated + "\"";
  json += "}";

  sendFirebase(json);
}

void sendFirebase(String json) {
  Serial.println("Preparing HTTPS connection...");

  if (!client->connect(host, 443)) {
    Serial.println("HTTPS connection failed");
    return;
  }

  String url = firebasePath;
  if (authToken.length() > 0) {
    url += "?auth=" + authToken;
  }

  Serial.println("Sending JSON:");
  Serial.println(json);

  client->print(String("PUT ") + url + " HTTP/1.1\r\n" +
                "Host: " + host + "\r\n" +
                "User-Agent: ESP8266\r\n" +
                "Connection: close\r\n" +
                "Content-Type: application/json\r\n" +
                "Content-Length: " + String(json.length()) + "\r\n\r\n" +
                json);

 
  delay(100);  
  client->stop();
  Serial.println("Data sent to Firebase (non-blocking)");
}