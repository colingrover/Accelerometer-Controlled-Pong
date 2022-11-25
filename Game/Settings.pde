final boolean DEBUG = false; // If true, shows tracker ball used by AI, prints arduino readings
final boolean ARDUINO_ENABLE = true; // false for keyboard control, true for arduino control
final boolean RGB_ENABLE = true; // Rainbow or white colours                  (random(10)>=9; // 10% Odds of RGB mode)
final int BAUDRATE = 9600;
final int canvasHeight = 512; // Game window height
final int canvasWidth = 2*canvasHeight; // Game window width
final float difficultyMultiplier = 0.65; // >=1 for easy, 0.65 for medium, 0.5 for hard, 0 for impossible
