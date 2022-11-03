final boolean DEBUG = false; // If true, shows tracker ball used by AI
final boolean ARDUINO_ENABLE = true; // false for keyboard control, true for arduino control
final boolean RGB_ENABLE = true;//random(10)>=9; // 10% Odds of RGB mode

void setup () {
  size(1024, 512);
  frameRate(fps);
  textAlign(CENTER);
  textSize(0.1*canvasHeight);
  
  if (ARDUINO_ENABLE) {
    arduinoSetup("COM6");
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
}

/* NOTES
 *   Add barriers for the paddles once arduino is implemented, as controls will likely be more finicky
 *
 *   Change way data is read so that three items are read at once, then buffer is cleared (if it works ig)
 */
