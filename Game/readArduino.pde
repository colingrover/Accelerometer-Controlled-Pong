import processing.serial.*;

//float arduinoData [] = {0, 0, 0}; // x, y, z
PVector arduinoData = new PVector(0, 0, 0);
float arduinoMaxAcceleration = 0;
Serial serial; // Serial port declaration
int counterForFlushing = 0;

void arduinoSetup (String port, int baudRate) {
  println("Setting up Arduino...");
  
  serial = new Serial(this, port, baudRate); // (Port name, baud rate)
  
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

// Data coming in in the form index:value, read each line and store the given value at the given index of ArduinoData
void getArduinoData () {
  if (serial.available() > 0) {
    // If buffer getting too large, flush it
    if (counterForFlushing > 300) {
      serial.clear();
      counterForFlushing = 0;
      if (DEBUG) println("-------------------- Flushed buffer --------------------");
    }
    
    String incomingData = serial.readStringUntil('\n'); // Read a single line of the string
    if (incomingData != null) {
      String splitData [] = incomingData.split(":"); // Separate line into two element array, with items delimited by colon
      if (int(splitData[0].trim()) < 3) { // If the string with its leading and trailing spaces removed, cast to an integer, is less than the maximum expected value of an index
        if (splitData.length == 2) { // Ensure 2 element array before trying to access second element
          switch (int(splitData[0].trim())) {
            case 0:
              arduinoData.z = -float(splitData[1].trim());//arduinoData.x = float(splitData[1].trim());
              counterForFlushing++;
              break;
            case 1:
              arduinoData.x = -float(splitData[1].trim());//arduinoData.y = float(splitData[1].trim());
              counterForFlushing++;
              break;
            case 2:
              arduinoData.y = -float(splitData[1].trim());//arduinoData.z = float(splitData[1].trim());
              counterForFlushing++;
              break;
          }
          //arduinoData[int(splitData[0].trim())] = float(splitData[1].trim());
        }
      }
    }
  }
}
