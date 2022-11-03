Ball tracker = new Ball();

// Give tracker identical data to actual ball, but a velocity of a magnitude 5 times greater
void updateTrackerData () {
  tracker.pos.set(ball.pos);
  tracker.vel.set(ball.vel);
  tracker.vel.mult(5);
  tracker.vel.y += random(-1, 1) * difficultyMultiplier; // Add noise to y velocity of tracker to adjust difficulty
}

// Find tracker position
void drawTracker() {
  // Handle bounces off of walls
  if (tracker.pos.y + ballRadius + tracker.vel.y > canvasHeight || tracker.pos.y - ballRadius + tracker.vel.y < 0) {
    tracker.vel.y = -tracker.vel.y;
  }
  
  // Make adjustments to position so tracker remains near x position of AI paddle once it gets near (accuracy, like most game aspects, dependent on frame rate)
  if (tracker.pos.x < p2.pos.x) {
    tracker.pos.add(tracker.vel);
  } else if (tracker.pos.x > p2.pos.x + 1) {
    tracker.vel.mult(0.5);
    tracker.pos.x -= tracker.vel.x;
    tracker.pos.y -= tracker.vel.y;
  }
  
  // Draw tracker in new position (for visualizing AI and debugging)
  if (DEBUG) {
    fill (255,0,0);
    circle (tracker.pos.x, tracker.pos.y, ballRadius*2);
    if (RGB_ENABLE) {
      colorMode(HSB);
      fill(hue, 255, 255);
      colorMode(RGB);
    } else {
      fill(255);
    }
  }
}

void moveAIPlayer () {
  if (p2.pos.y < tracker.pos.y) {
    p2.pos.y += paddleSpeed;
  } else if (p2.pos.y > tracker.pos.y) {
    p2.pos.y -= paddleSpeed;
  }
}
