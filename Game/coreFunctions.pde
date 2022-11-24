final boolean ONGOING = true;
final boolean GAME_OVER = false;
final int fps = 200;
final float paddleWidth = (2.0/512)*canvasWidth;
final float paddleLength = (28.0/256)*canvasHeight;
final float paddleSpeed = (4.0/256)*canvasHeight/(fps/60);
final float ballRadius = (3.0/512)*canvasWidth;
final float maxBallSpeed = ((7.0/512)*canvasWidth)/(fps/30);
final float speedMultiplier = 1.1;
int resetTimer = 0;
int hue = 0;

// Delete these after arduino implementation
boolean wPressed, sPressed;

class Player {
  PVector pos;
  PVector prevPos;
  int score;
  PVector vel;
  
  Player (float x, float y) {
    pos = new PVector(x, y);
    prevPos = new PVector(x, y);
    score = 0;
    vel = new PVector (0, 0);
  }
}

class Ball {
  PVector pos;
  PVector vel;
  
  Ball () {
    pos = new PVector(canvasWidth/2, canvasHeight/2);
    vel = new PVector(0, 0);
  }
}

// Initialize main ball and player objects
Ball ball = new Ball();
Player p1 = new Player(canvasWidth/10, canvasHeight/2);
Player p2 = new Player(9*canvasWidth/10, canvasHeight/2);

// Resets ball to center with random velocity if game not finished, otherwise holds ball in center during game-over events
void resetBall (boolean gameState) {
  if (gameState == ONGOING) {
    ball.pos.x = canvasWidth/2; // Center ball in x-axis
    ball.pos.y = random(ballRadius, canvasHeight-ballRadius); // Give abll random starting y position
    
    do {
      ball.vel.x = random(-maxBallSpeed, maxBallSpeed); // Give ball random x-velocity within threshold
    } while (abs(ball.vel.x) < maxBallSpeed/2);
    
    ball.vel.y = random(-maxBallSpeed, maxBallSpeed); // Give ball a random y-velocity within threshold
  } else if (gameState == GAME_OVER) {
      ball.pos.set(canvasWidth/2, canvasHeight*2); // Center ball
      ball.vel.set(0, 0); // Halt ball's motion
  }
  
  updateTrackerData(); // Update the AI's tracker ball based on the ball's new data
}

void drawPlayers () {
  if (ARDUINO_ENABLE) {
    controlFromArduino(); // Update position data from player accelerometer input
  } else {
    controlFromKeyboard(); // Update position data from player keyboard input
  }
  
  // Calculate player velocities (v=dy/dt)
  p1.vel.set((p1.pos.x-p1.prevPos.x)/frameRate, (p1.pos.y-p1.prevPos.y)/frameRate);
  p2.vel.set((p2.pos.x-p2.prevPos.x)/frameRate, (p2.pos.y-p2.prevPos.y)/frameRate);
  
  // Draw rectangles (x & y coords from obj are for center of rects)
  rectMode(CENTER);
  rect(p1.pos.x, p1.pos.y, paddleWidth, paddleLength);
  rect(p2.pos.x, p2.pos.y, paddleWidth, paddleLength);
  
  // Update prevPos for both players
  p1.prevPos.set(p1.pos);
  p2.prevPos.set(p2.pos);
}

boolean willBallHitAPaddle () {
  // Player 1
  if (ball.pos.x + ballRadius + ball.vel.x > p1.pos.x - (paddleWidth/2) &&
      ball.pos.x - ballRadius + ball.vel.x < p1.pos.x + (paddleWidth/2) &&
      ball.pos.y + ballRadius + ball.vel.y >= p1.pos.y - (paddleLength/2) &&
      ball.pos.y - ballRadius + ball.vel.y <= p1.pos.y + (paddleLength/2)){
        return true;
      }
        
  // Player 2
  if (ball.pos.x + ballRadius + ball.vel.x > p2.pos.x - (paddleWidth/2) &&
      ball.pos.x - ballRadius + ball.vel.x < p2.pos.x + (paddleWidth/2) &&
      ball.pos.y + ballRadius + ball.vel.y >= p2.pos.y - (paddleLength/2) &&
      ball.pos.y - ballRadius + ball.vel.y <= p2.pos.y + (paddleLength/2)){
        return true;
      }
  
  // Neither
  return false;
}

void drawBall () {
  // Handle bounces off of walls
  if (ball.pos.y + ballRadius + ball.vel.y > canvasHeight || ball.pos.y - ballRadius + ball.vel.y < 0) {
    ball.vel.y = -ball.vel.y;
  }
  
  // Handle bounces off of paddles (redirects ball, multiplies x velocity, and paddle imparts some y-velocity onto the ball)
  if (willBallHitAPaddle()) {
    if (ball.pos.x > canvasWidth/2) { // Handle bounces off AI paddle (right side)
      ball.vel.x = -(speedMultiplier*ball.vel.x); // Redirect and increase x velocity by multiplier
      ball.vel.x += 20*p2.vel.x; // Impart some of paddle's x velocity to the ball
      ball.vel.y += 20*p2.vel.y; // Impart some of paddle's y velocity to the ball
      tracker.pos.y = canvasHeight/2; // Reset AI tracker ball to center y
      tracker.vel.y = 0; // Reset AI tracker ball vertical velocity to 0
    } else if (ball.pos.x > p1.pos.x) { // Handle bounces off player's paddle (left side), making sure to check player is approaching from behind ball as we are allowing for x movement with accelerometer controls
      ball.vel.x = -(speedMultiplier*ball.vel.x); // Redirect and increase x velocity by multiplier
      ball.vel.x += 20*p1.vel.x; // Impart some of paddle's x velocity to the ball
      ball.vel.y += 20*p1.vel.y; // Impart some of paddle's y velocity to the ball
      
      // Because of x movement allowance, collision errors may arise from the player moving into the ball after the initial condition, offset the ball's position to account for this
      float offsetAmount = (p1.pos.x + paddleWidth/2) - (ball.pos.x - ballRadius);
      ball.pos.x += offsetAmount>0 ? 2*offsetAmount : 0;
      
      updateTrackerData(); // Tell AI what the player did to the ball
    } else { // If player hits ball from in front of it (thus moving it backwards)
      ball.vel.x += 20*p1.vel.x; // Impart some of paddle's x velocity to the ball
      ball.vel.y += 20*p1.vel.y; // Impart some of paddle's y velocity to the ball
      updateTrackerData(); // Tell AI what the player did to the ball
    }
  }
  
  // Make adjustments to position
  ball.pos.add(ball.vel);
  
  // Draw ball in its new position
  circle(ball.pos.x, ball.pos.y, ballRadius*2);
}

// Handles scoring events and game-over
void scores () {
  // Reset game and adjust score if ball goes past either edge
  if (ball.pos.x + ballRadius >= canvasWidth) {
    p1.score++;
    p1.pos.y = canvasHeight/2;
    p2.pos.y = canvasHeight/2;
    resetBall(ONGOING);
  } else if (ball.pos.x - ballRadius <= 0) {
    p2.score++;
    p1.pos.y = canvasHeight/2;
    p2.pos.y = canvasHeight/2;
    resetBall(ONGOING);
  }
  
  // Update score display
  text(p1.score, canvasWidth/4, canvasHeight/8);
  text(p2.score, 3*canvasWidth/4, canvasHeight/8);
  
  // Reset game when score reaches 21, but first display game-over message for 2 seconds
  if (p1.score == 21 || p2.score == 21) {
    resetBall(GAME_OVER);
    text("Game", canvasWidth/4, canvasHeight/2);
    text("Over", 3*canvasWidth/4, canvasHeight/2);
    
    if (resetTimer == 2*fps) {
      p1.score = 0;
      p2.score = 0;
      p1.pos.y = canvasHeight/2;
      p2.pos.y = canvasHeight/2;
      resetBall(ONGOING);
      resetTimer = 0;
    } else {
    resetTimer++;
    }
  }
}
