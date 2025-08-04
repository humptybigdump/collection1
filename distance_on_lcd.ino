/*
  Distance from Ultrasonic Sensor (HC-SR04) on LCD (1602)
  Created for HFAD Lecture WS2023/2024
  Exercise 04
  Author: Manuel Bied
*/

// Install library "LiquidCrystal I2C by Frank de Brabander, tested with version 1.1.2
#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27,16,2);  // set the LCD address to 0x27 for a 16 chars and 2 line display

// Set trigger to pin D3 and echo to pin D2
const int trigPin = 3;
const int echoPin = 2;

// Set speed of sound (here for 20ºC) in m/s
const int v = 343;

// Defines variables
long t; 
int d;
int d_old = 0;




void setup() {
  // initialize the lcd 
  lcd.init();                
  lcd.backlight();

  // Set the trigger pin as output
  pinMode(trigPin, OUTPUT); 
  // Sets the echo pin as input
  pinMode(echoPin, INPUT); 

  lcd.setCursor(1,0);
  lcd.print("Distance:");
}
void loop() {
  // Set trigger pin to low to get a clear high signal
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  // Set the trigger pin to HIGH for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Write the travel time [in microseconds] from the echo pin
  t = pulseIn(echoPin, HIGH);
  // Calculate the distance in cm (multiply by 100 for, divide by 10^6 for microseconds => divide by 10000)
  d = t * v  / 10000 / 2;

  // Only write to display if the value changed
  if (d_old != d){
    lcd.setCursor(2,1);
    lcd.print("    ");
    lcd.setCursor(2,1);
    lcd.print(d);
  }

  delay(350);
  d_old = d;
}
