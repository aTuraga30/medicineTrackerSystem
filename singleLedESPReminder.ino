#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <FastLED.h>

#define NUM_LEDS 10
#define DATA_PIN 23
#define BUTTON_PIN 22

const char* ssid = "belkin.892";
const char* password = "srimatha@226";
char jsonOutput[128];

CRGB leds[NUM_LEDS];

byte btnValue;
byte oldValue = 0;
byte state = 0;

void setup() {
  Serial.begin(115200);
  Serial.println();

  WiFi.begin(ssid, password);
  Serial.print("Connecting");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  pinMode(DATA_PIN, OUTPUT);
  Serial.println();

  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  FastLED.addLeds<NEOPIXEL, DATA_PIN>(leds, NUM_LEDS);
}

void loop() { 
  if ((WiFi.status() == WL_CONNECTED)) {
    while (true) {
      HTTPClient client;
      HTTPClient client2;
  
      client.begin("https://api.thingspeak.com/channels/1411223/feeds.json?api_key=3KBN6IR60DDOT2YJ&results=1");
      client2.begin("https://api.thingspeak.com/update?api_key=D0U6OPO92UR8NP45&field1=0");
      
      int httpCode = client.GET();
      client2.addHeader("Content-Type", "application/json");

      const size_t CAPACITY = JSON_OBJECT_SIZE(1);
      StaticJsonDocument<CAPACITY> doc;

      JsonObject object = doc.to<JsonObject>();
      object["feeds"][0]["field1"] = "0";

      serializeJson(doc, jsonOutput);
      
      String payload = client.getString();
      //Serial.println("GET JSON: " + payload);  

      StaticJsonDocument<450> document;
      DeserializationError err = deserializeJson(document, payload);

      if (err) {
        Serial.print("ERROR: ");
        Serial.println(err.c_str());
        return;
      }
      
      String value = document["feeds"][0]["field1"];
      Serial.println("Value: " + value);
// -----------------------------------------------------------------
      if (value == "1") {
        for (int i = 0; i < NUM_LEDS; i++) {
          leds[i] = CRGB::Green;
          FastLED.show();
          delay(30);
        }
        digitalWrite(DATA_PIN, HIGH);
        state = 1;
        Serial.println("LED ON");
      }

      else if (value == "0") {
        for (int i = 0; i < NUM_LEDS; i++) {
          leds[i] = CRGB::Black;
          FastLED.show();
          delay(30);
        }
        digitalWrite(DATA_PIN, LOW);
        state = 0;
        Serial.println("LED OFF");
      }

      btnValue = digitalRead(BUTTON_PIN);

      if(btnValue && !oldValue) {
        Serial.println("Button Press");
        
        if(state == 1) {
          Serial.print("Recognized");
          int httpCode = client2.POST(String(jsonOutput));
          Serial.println("Button was pressed!");
          
          if (httpCode > 0) {
            String payload2 = client2.getString();
            Serial.println("POST JSON: " + payload2);
          }
          
          else {
            Serial.println("Error in POST");
          }
        }
        
        else {
          state = 0;
        }
        
        oldValue = 1;
      }
      
      else if(!btnValue && oldValue) {
        oldValue = 0;
      }
    }
  }
  
  else {
    Serial.println("Lost Connection");
  }

  delay(100000);
}
