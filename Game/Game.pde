void setup () {
  size(1024, 512);
  frameRate(fps);
  textAlign(CENTER);
  textSize(0.1*canvasHeight);
  
  if (ARDUINO_ENABLE) {
    arduinoSetup(SERIALPORT, BAUDRATE);
  }
  
  resetBall(ONGOING);
}

void draw () {
  background(0); // Black
  if (RGB_ENABLE) {
    if (hue>255) {hue=0;}
    else {
      colorMode(HSB);
      fill(hue, 255, 255);
      colorMode(RGB);
      hue++;
    }
  } else {
    fill (255); // White
  }
  
   if (!rebooting) {
    // Draw center line
    strokeWeight((1.0/512)*canvasWidth);
    if (RGB_ENABLE) {
      colorMode(HSB);
      stroke(hue, 255, 255);
      colorMode(RGB);
    } else {
      stroke(255);
    }
    strokeWeight(0.005*canvasWidth);
    line(canvasWidth/2, 0, canvasWidth/2, canvasHeight);
    noStroke();

    // Update dynamic aspects of game
    drawBall();
    drawTracker();
    moveAIPlayer();
    drawPlayers();
    scores();
  } else {
    text("Sorry, there's been an error - rebooting Arduino", canvasHeight, canvasHeight/3);
    text((3+(10*(9600/BAUDRATE)))-((int)millis()-rebootTime)/1000, canvasHeight, 2*canvasHeight/3);
  }
}
