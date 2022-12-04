import processing.serial.*;

String SERIALPORT; // Name of bluetooth serial port that receives data from Arduino

PVector arduinoData = new PVector(0, 0, 0);
float arduinoMaxAcceleration = 1; // Gets updated
Serial serial; // Serial port declaration
int counterForFlushing = 0;
int nullInARow = 0;
final int maxNullInARow = 100*(9600/BAUDRATE);
boolean rebooting = false;
int rebootTime = 0;

void arduinoSetup (int baudRate) {
  println("Setting up Arduino...");
  
  println("Ports detected:");
  printArray(Serial.list());
  println("Checking for active port... ");
  
  boolean doesPortExist = false;
  while (!doesPortExist) {
    String sList [] = Serial.list();
    
    for (int i=0; i<sList.length; i++) {
      serial = new Serial(this, sList[i], 9600); // Open serial port
      delay(10);
      
      if (serial.available() > 0) { // Check if any data is being sent over active port
        doesPortExist = true; // If so, assume it is the one we want to be using
        SERIALPORT = sList[i]; // Assign global
        
        print("Using port: ");
        println(SERIALPORT);
        
        break;
      } else {
        serial.stop(); // Otherwise, close the port and check the next
        delay(10);
      }
    }
    if (!doesPortExist) println("No active ports found, checking again...");
  }
  
  delay(500);
  for (int i=0; i<300; i++) {
    getArduinoData(); // Call to get initial info for vector magnitude (many times and delays to get through initial boot 0s
    delay(5);
  }
  
  arduinoMaxAcceleration = arduinoData.mag(); // Max possible value (ignoring miscalibration and assuming only gravity is being measured) of single axis acceleration
  print("Acceleration vector magnitude: ");
  println(arduinoMaxAcceleration);
  println("Arduino setup complete.");
}

// "Temporary" fix, informs user of error, reboots serial port
void rebootArduino () {
  rebooting = true;
  rebootTime = millis();
  thread("serialRestart"); // Start serial port reset on new thread to allow for rendering of error text on screen during the process
}

// Handles most of work for rebootArduino(), just on separate thread
void serialRestart () {
  println("Rebooting Arduino due to error...");
  serial.stop(); // Close serial port
  delay(10000*(9600/BAUDRATE)); // Halt program for 10 seconds to allow port to fully close
  serial.stop(); // Call this again, not sure why it helps with port busy errors but it does
  arduinoSetup(BAUDRATE); // Reboot serial port
  println("Reboot successful!");
  rebooting = false;
}

// Data coming in in the form index:value, read each line and store the given value at the given axis of ArduinoData
void getArduinoData () {
  if (serial.available() > 0) {
    // Ensure buffer doesn't grow too large
    if (counterForFlushing > 5) {
      serial.clear();
      counterForFlushing = 0;
      if (DEBUG) println("-------------------- Flushed buffer --------------------");
    }
    
    String incomingData = serial.readStringUntil('\n'); // Read a single line of the string
    /*
     * ERROR HERE!!! SOMETIMES THIS ALWAYS EVALUATES TO FALSE (i.e. is null) AFTER A CERTAIN POINT AND NO FURTHER DATA WILL BE READ... NOT SURE WHY.
     * Tried changing baud rates of arduino, sketch, HC-05... didn't help.
     * Temporary solution: force serial reboot when it evaluates false enough times in a row
     * Using PCB instead of breadboard mostly fixed this issue, may have stemmed from poor wiring... leaving this here so I don't have to hunt for the error source if it comes back later
     */
    if (incomingData != null) {
      nullInARow = 0;
      String splitData [] = incomingData.split(":"); // Separate line into two element array, with items delimited by colon
      if (int(splitData[0].trim()) < 3) { // If the string with its leading and trailing spaces removed, cast to an integer, is less than the maximum expected value of an index
        if (splitData.length == 2 && !Float.isNaN(float(splitData[1]))) { // Ensure 2 element array before trying to access second element, ensure second element valid
          switch (int(splitData[0].trim())) {
            case 0:
              // Assign x acceleration to z (to make breadboard mounted accelerometer control game easier)
              arduinoData.z = -float(splitData[1].trim());//arduinoData.x = float(splitData[1].trim());
              counterForFlushing++;
              break;
            case 1:
              // Assign y acceleration to x (to make breadboard mounted accelerometer control game easier) 
              arduinoData.x = -float(splitData[1].trim());//arduinoData.y = float(splitData[1].trim());
              counterForFlushing++;
              break;
            case 2:
              // Assign z acceleration to y (to make breadboard mounted accelerometer control game easier)
              arduinoData.y = -float(splitData[1].trim());//arduinoData.z = float(splitData[1].trim());
              counterForFlushing++;
              break;
          }
        }
      }
    } else {
      nullInARow++;
      if (nullInARow > maxNullInARow) rebootArduino();
    }
  }
}
