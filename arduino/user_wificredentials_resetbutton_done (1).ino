#include <Wire.h>
#include "SparkFun_BMA400_Arduino_Library.h"
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <WebSocketsServer.h>
#include <WiFiManager.h>
#include <math.h>

BMA400 accelerometer;

uint8_t i2cAddress = BMA400_I2C_ADDRESS_SECONDARY; // 0x15 for BlueDot sensor
int interruptPin = 14;

WebSocketsServer webSocket(81);
ESP8266WebServer httpServer(80);

// Pin for LED
const int ledPin = 2; // GPIO pin for the built-in LED (D4)

// Static IP configuration
IPAddress local_IP(192, 168, 0, 155);
IPAddress gateway(192, 168, 0, 1);
IPAddress subnet(255, 255, 255, 0);

// Variables for step count, activity, and accelerometer data
uint32_t stepCount = 0;
uint8_t activityType = 0;
BMA400_SensorData sensorData;

unsigned long lastSendTime = 0;
const unsigned long interval = 500; // 0.5 seconds

float rotationX = 0, rotationY = 0, rotationZ = 0;

float lastRotationY = 0;
bool isFluctuating = false;
const float fluctuationThreshold = 15.0; // Threshold for fluctuation detection

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
    // Handle WebSocket events if needed
}

void handleRoot() {
    httpServer.send(200, "text/html", 
    "<!DOCTYPE html>"
    "<html>"
    "<head>"
    "<title>ESP8266 Sensor Data</title>"
    "<script>"
    "var ws = new WebSocket('ws://' + window.location.hostname + ':81/');"
    "ws.onopen = function() { console.log('WebSocket connection established'); };"
    "ws.onmessage = function(event) {"
    "  var data = JSON.parse(event.data);"
    "  document.getElementById('stepCount').innerText = data.stepCount;"
    "  document.getElementById('activity').innerText = data.activity;"
    "  document.getElementById('accelX').innerText = data.accelX.toFixed(2);"
    "  document.getElementById('accelY').innerText = data.accelY.toFixed(2);"
    "  document.getElementById('accelZ').innerText = data.accelZ.toFixed(2);"
    "  document.getElementById('rotationX').innerText = data.rotationX.toFixed(2);"
    "  document.getElementById('rotationY').innerText = data.rotationY.toFixed(2);"
    "  document.getElementById('rotationZ').innerText = data.rotationZ.toFixed(2);"
    "  document.getElementById('fluctuationState').innerText = data.isFluctuating ? 'Fluctuating' : 'Stable';"
    "};"
    "ws.onerror = function(error) { console.error('WebSocket Error: ' + error); };"
    "ws.onclose = function() { console.log('WebSocket connection closed'); };"
    "</script>"
    "</head>"
    "<body>"
    "<h1>Sensor Data</h1>"
    "<p><strong>Step Count:</strong> <span id='stepCount'>0</span></p>"
    "<p><strong>Activity:</strong> <span id='activity'>Unknown</span></p>"
    "<p><strong>Acceleration X:</strong> <span id='accelX'>0.00</span></p>"
    "<p><strong>Acceleration Y:</strong> <span id='accelY'>0.00</span></p>"
    "<p><strong>Acceleration Z:</strong> <span id='accelZ'>0.00</span></p>"
    "<p><strong>Rotation X:</strong> <span id='rotationX'>0.00</span></p>"
    "<p><strong>Rotation Y:</strong> <span id='rotationY'>0.00</span></p>"
    "<p><strong>Rotation Z:</strong> <span id='rotationZ'>0.00</span></p>"
    "<p><strong>Fluctuation State:</strong> <span id='fluctuationState'>Stable</span></p>"
    "</body>"
    "</html>"
    );
}

// Pin for the reset button
const int resetButtonPin = 13; // GPIO13 corresponds to D7

void setup() {
    pinMode(interruptPin, INPUT_PULLUP);
    pinMode(ledPin, OUTPUT); // Set LED pin as output
    pinMode(resetButtonPin, INPUT_PULLUP); // Configure the reset button on D7

    Serial.begin(115200);
    Serial.println("BMA400 Example - Step Counter, Activity Detection");

    // Check if the reset button is pressed at startup
    if (digitalRead(resetButtonPin) == LOW) {
        Serial.println("Reset button pressed! Erasing WiFi credentials...");
        WiFiManager wifiManager;
        wifiManager.resetSettings(); // This will erase saved WiFi credentials
        delay(1000); // Wait a bit to ensure reset
        ESP.restart(); // Restart the ESP8266
    }

    Wire.begin();

    while (accelerometer.beginI2C(i2cAddress) != BMA400_OK) {
        Serial.println("Error: BMA400 not connected, check wiring and I2C address!");
        delay(1000);
    }

    Serial.println("BMA400 connected!");

    accelerometer.setODR(BMA400_ODR_100HZ);
    accelerometer.setRange(BMA400_RANGE_16G);
    accelerometer.setFilter1Bandwidth(BMA400_ACCEL_FILT1_BW_1);

    bma400_step_int_conf stepConfig = {
        .int_chan = BMA400_INT_CHANNEL_1
    };
    accelerometer.setStepCounterInterrupt(&stepConfig);
    accelerometer.setInterruptPinMode(BMA400_INT_CHANNEL_1, BMA400_INT_PUSH_PULL_ACTIVE_1);
    accelerometer.enableInterrupt(BMA400_STEP_COUNTER_INT_EN, true);

    // Set static IP configuration
    if (!WiFi.config(local_IP, gateway, subnet)) {
        Serial.println("Failed to configure Static IP");
    }

    WiFiManager wifiManager;
    wifiManager.autoConnect("ESP8266_BMA400_Config");

    Serial.println("Connected to WiFi");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());

    digitalWrite(ledPin, HIGH); // Turn on the LED when connected

    webSocket.begin();
    webSocket.onEvent(webSocketEvent);
    httpServer.on("/", handleRoot);
    httpServer.begin();
}


void loop() {
    if (millis() - lastSendTime >= interval) {
        lastSendTime = millis();

        if (accelerometer.getStepCount(&stepCount, &activityType) == BMA400_OK) {
            String activityStr;
            switch (activityType) {
                case BMA400_RUN_ACT:
                    activityStr = "Running";
                    break;
                case BMA400_WALK_ACT:
                    activityStr = "Walking";
                    break;
                case BMA400_STILL_ACT:
                    activityStr = "Standing still";
                    break;
                default:
                    activityStr = "Unknown";
                    break;
            }

            if (accelerometer.getSensorData() == BMA400_OK) {
                sensorData = accelerometer.data;

                rotationX = atan2(sensorData.accelY, sensorData.accelZ) * 180 / PI;
                rotationY = atan2(sensorData.accelX, sensorData.accelZ) * 180 / PI;
                rotationZ = atan2(sensorData.accelX, sensorData.accelY) * 180 / PI;

                if (abs(rotationY - lastRotationY) > fluctuationThreshold) {
                    isFluctuating = true;
                } else {
                    if (isFluctuating) {
                        isFluctuating = false;
                    }
                }

                lastRotationY = rotationY;

                String jsonData = "{\"stepCount\":" + String(stepCount) +
                                  ",\"activity\":\"" + activityStr + "\"" +
                                  ",\"accelX\":" + String(sensorData.accelX, 2) +
                                  ",\"accelY\":" + String(sensorData.accelY, 2) +
                                  ",\"accelZ\":" + String(sensorData.accelZ, 2) +
                                  ",\"rotationX\":" + String(rotationX, 2) +
                                  ",\"rotationY\":" + String(rotationY, 2) +
                                  ",\"rotationZ\":" + String(rotationZ, 2) +
                                  ",\"isFluctuating\":" + String(isFluctuating) + "}";

                webSocket.broadcastTXT(jsonData);
            }
        }
    }

    webSocket.loop();
    httpServer.handleClient();
}
