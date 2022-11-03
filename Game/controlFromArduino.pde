final int accelerationScaleFactor = 2;

void controlFromArduino () {
  getArduinoData(); // Fetch new acceleration info
  
  if (DEBUG) {
    println(arduinoData);
  }
  
  float tempx = -map(arduinoData.x, -arduinoMaxAcceleration, arduinoMaxAcceleration, -accelerationScaleFactor, accelerationScaleFactor)*paddleSpeed; // Calculate possible change in x position from acceleration
  
  // If proposed movement keeps player within x bounds, allow it
  if (p1.pos.x + paddleWidth/2 + tempx < canvasWidth/2 && p1.pos.x - paddleWidth/2 + tempx > 0) {
    // Ensure player does not go through ball (if ball in front of paddle and moving forwards would put it through/past it)
    if ((p1.pos.x + paddleWidth/2 < ball.pos.x && ball.pos.y < p1.pos.y + paddleLength/2 && ball.pos.y > p1.pos.y - paddleLength/2) && (p1.pos.x + paddleWidth/2 + tempx > ball.pos.x)) {
      ball.pos.x += tempx;
    }
    
    p1.pos.x += tempx;
  }
  
  p1.pos.y += map(arduinoData.y, -arduinoMaxAcceleration, arduinoMaxAcceleration, -accelerationScaleFactor, accelerationScaleFactor)*paddleSpeed; // No bounds in y, this is pong after all :)
}
