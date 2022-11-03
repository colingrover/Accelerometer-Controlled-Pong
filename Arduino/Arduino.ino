#include <Adafruit_MPU6050.h> // Accelerometer
#include <Adafruit_Sensor.h> // Accelerometer
#include <Wire.h> // For I2C

Adafruit_MPU6050 mpu; // Accelerometer

void printDataToSerial(sensors_event_t a, sensors_event_t t);

void setup() {
  Serial.begin(9600);

  while (!Serial){}

  Serial.println("Serial connection established.");
  Serial.println("Connecting to accelerometer.");

    // Try to initialize mpu6050
  if (!mpu.begin()) {
    while (1) {Serial.print('.');}
  }

  Serial.println("Accelerometer connected.");

  // set accelerometer range to +-2G (Options: 2, 4, 8, 16) 
  mpu.setAccelerometerRange(MPU6050_RANGE_2_G); // !!! FINE TUNE THIS !!!

  // set low pass filter bandwidth to 21 Hz (Options: 5, 10, 21, 44, 94, 184, 260)
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ); // !!! FINE TUNE THIS !!!

  delay(100);
}

// ------------------------- MAIN LOOP ------------------------- //
void loop() {
  /* Get new sensor events with the readings */
  sensors_event_t a, g, t; // Acceleration, gyroscopic reading, temperature (from MPU6050)
  mpu.getEvent(&a, &g, &t);

  printDataToSerial(a, t);
}
// ------------------------ ^MAIN LOOP^ ------------------------ //

void printDataToSerial(sensors_event_t a, sensors_event_t t) {
  float arr [] = {a.acceleration.x, a.acceleration.y, a.acceleration.z};
  for (int i=0; i<sizeof(arr)/sizeof(arr [0]); i++) {
    Serial.print(i);
    Serial.print(":");
    Serial.println(arr[i]);
  }
  //delay(5);
}
