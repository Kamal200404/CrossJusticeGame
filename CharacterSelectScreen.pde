class CharacterSelectScreen {
  String[] characters = {"Batman", "Superman", "Venom", "Spiderman", "BOT"};

  int player1Selection = 0;
  int player2Selection = 1;

  Button startGameButton;

  PImage batmanImage;
  PImage supermanImage;
  PImage venomImage;
  PImage spidermanImage;
  PImage backgroundImage;

  CharacterSelectScreen() {
    startGameButton = new Button(width / 2 - 75, height - 100, 150, 40, "Start Game");

    backgroundImage = loadImage("background1.jpg");
    backgroundImage.resize(width, height);

    batmanImage = loadImage("Batman-2.3.png");
    supermanImage = loadImage("Superman-1.1.png");
    venomImage = loadImage("Venom-1.png");
    spidermanImage = loadImage("Spiderman-3.png");
  }

  void display() {
    image(backgroundImage, 0, 0, width, height);

    textAlign(CENTER);
    textSize(32);
    fill(255);
    stroke(0);
    strokeWeight(4);
    text("Character Select", width / 2, 40);

    textSize(20);
    noStroke();
    fill(255);
    text("Player 1", width / 4, 100);
    text("Player 2", 3 * width / 4, 100);

    float spacingY = 120;
    float startY = 150;

    for (int i = 0; i < characters.length; i++) {
      float p1X = width / 4;
      float p2X = 3 * width / 4;
      float y = startY + i * spacingY;

      PImage img = getCharacterImage(characters[i]);

      image(img, p1X - 40, y - 40, 80, 80);
      image(img, p2X - 40, y - 40, 80, 80);

      fill(255);
      text(characters[i], p1X, y + 60);
      text(characters[i], p2X, y + 60);

      if (player1Selection == i) {
        noFill();
        stroke(0, 191, 255);
        strokeWeight(3);
        rect(p1X - 50, y - 50, 100, 100, 10);
      }

      if (player2Selection == i) {
        noFill();
        stroke(255, 69, 0);
        strokeWeight(3);
        rect(p2X - 50, y - 50, 100, 100, 10);
      }
    }

    startGameButton.display();
  }

  PImage getCharacterImage(String character) {
    if (character.equals("Batman")) return batmanImage;
    if (character.equals("Superman")) return supermanImage;
    if (character.equals("Venom")) return venomImage;
    if (character.equals("Spiderman")) return spidermanImage;
    if (character.equals("BOT")) return supermanImage; // Reuse Superman image for bot
    return batmanImage;
  }

  void mousePressed() {
    float spacingY = 120;
    float startY = 150;

    for (int i = 0; i < characters.length; i++) {
      float p1X = width / 4;
      float p2X = 3 * width / 4;
      float y = startY + i * spacingY;

      if (overImage(p1X - 40, y - 40, 80, 80)) player1Selection = i;
      if (overImage(p2X - 40, y - 40, 80, 80)) player2Selection = i;
    }

    if (startGameButton.isClicked(mouseX, mouseY)) {
      player1Choice = characters[player1Selection];
      player2Choice = characters[player2Selection];
      player2IsBot = player2Choice.equals("BOT"); // ✅ Set bot flag
      preparePlayState(); // This must be defined in CrossJusticeGame
      gameState = "play";
    }
  }

  boolean overImage(float x, float y, float w, float h) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}
