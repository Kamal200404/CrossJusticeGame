class StartScreen {
  Button startButton;
  Button howToPlayButton;
  Button characterSelectButton;

  PImage startBackground;
  float glowPulse = 0;

  StartScreen() {
    startButton = new Button(width/2 - 100, height/2 - 50, 200, 50, "Start Game");
    howToPlayButton = new Button(width/2 - 100, height/2 + 20, 200, 50, "How to Play");
    characterSelectButton = new Button(width/2 - 100, height/2 + 90, 200, 50, "Choose Character");

    startBackground = loadImage("Background1.png");
    startBackground.resize(width, height); 
  }

  void display() {
    // ✅ Static background
    image(startBackground, 0, 0, width, height);

    // Pulse glow calculation
    
    float glow = map(sin(glowPulse), -1, 1, 150, 255);

    textAlign(CENTER);
    textSize(60);
    String title = "CROSS JUSTICE";

    // 🖤 Clean shadow for depth
    fill(0, 150);
    text(title, width / 2 + 3, height / 4 + 3);

    // 🔵 Clean bright main title (blue tone)
    fill(0, 191, 255, glow);
    text(title, width / 2, height / 4);

    // Optional extra: white highlight overlay
    fill(255, glow / 2);
    textSize(62); // slight size up for soft glow effect
    text(title, width / 2, height / 4);

    textSize(60); // reset text size for buttons
    // ✅ Buttons with glow hover
    startButton.displayWithGlow();
    howToPlayButton.displayWithGlow();
    characterSelectButton.displayWithGlow();
  }

  void mousePressed() {
    if (startButton.isClicked(mouseX, mouseY)) {
      gameState = "play";
    } else if (howToPlayButton.isClicked(mouseX, mouseY)) {
      gameState = "howtoplay";
    } else if (characterSelectButton.isClicked(mouseX, mouseY)) {
      gameState = "characterSelect";
    }
  }
}
