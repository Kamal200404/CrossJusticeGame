class GameOverScreen {
  String winner = "";

  Button restartButton;
  Button mainMenuButton;
  Button exitButton;

  PImage backgroundImage;

  GameOverScreen() {
    backgroundImage = loadImage("background1.jpg");
    backgroundImage.resize(width, height);

    restartButton = new Button(width / 2 - 75, height / 2 - 20, 150, 40, "Restart");
    mainMenuButton = new Button(width / 2 - 75, height / 2 + 40, 150, 40, "Main Menu");
    exitButton = new Button(width / 2 - 75, height / 2 + 100, 150, 40, "Exit");
  }

  void setWinner(String winPlayer) {
    winner = winPlayer;
  }

  void display() {
    image(backgroundImage, 0, 0, width, height);

    textAlign(CENTER);
    textSize(48);
    fill(#00CFFF); // Same as start screen text color!
    noStroke();
    if (winner.equals("Draw!")) {
      text("DRAW!", width / 2, height / 2 - 100);
    } else {
      text(winner.toUpperCase() + " WINS!", width / 2, height / 2 - 100);
    }

    restartButton.displayWithGlow();
    mainMenuButton.displayWithGlow();
    exitButton.displayWithGlow();
  }

  void mousePressed() {
    if (restartButton.isClicked(mouseX, mouseY)) {
      resetGame();
      gameState = "play";
      loop();
    } else if (mainMenuButton.isClicked(mouseX, mouseY)) {
      resetGame();
      gameState = "start";
      loop();
    } else if (exitButton.isClicked(mouseX, mouseY)) {
      exit();
    }
  }

  void resetGame() {
    // ✅ Reuse existing PlayerControls instead of creating new ones
    if (player1Choice.equals("Batman")) {
      player1 = new Batman(200, p1Controls);
    } else if (player1Choice.equals("Superman")) {
      player1 = new Superman(200, p1Controls);
    } else if (player1Choice.equals("Venom")) {
      player1 = new Venom(200, p1Controls);
    } else if (player1Choice.equals("Spiderman")) { // ✅ Added Spiderman!
      player1 = new Spiderman(200, p1Controls);
    }

    if (player2Choice.equals("Batman")) {
      player2 = new Batman(700, p2Controls);
    } else if (player2Choice.equals("Superman")) {
      player2 = new Superman(700, p2Controls);
    } else if (player2Choice.equals("Venom")) {
      player2 = new Venom(700, p2Controls);
    } else if (player2Choice.equals("Spiderman")) { // ✅ Added Spiderman!
      player2 = new Spiderman(700, p2Controls);
    }

    gameOverPending = false;
    gameOverTimer = 0;
    timer = initialTimer; // ✅ Timer reset
    winner = ""; // ✅ Winner reset!
    hitEffect = new HitEffect(); // ✅ Hit effect reset
  }
}
