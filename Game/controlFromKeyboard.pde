// Handle key presses
void keyPressed () {
  if (key == 'w' || key == 'W') {
      wPressed = true;
    }
    
    if (key == 's' || key == 'S') {
      sPressed = true;
    }
}

// Handle key releases
void keyReleased () {
  if (key == 'w' || key == 'W') {
      wPressed = false;
    }
    
    if (key == 's' || key == 'S') {
      sPressed = false;
    }
}

// This will later be controlled by data read from the serial port, for now, control via keyboard
void controlFromKeyboard () {
  if (wPressed) {
      p1.pos.y -= paddleSpeed;
    }
    
    if (sPressed) {
      p1.pos.y += paddleSpeed;
    }
}
