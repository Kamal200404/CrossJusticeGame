// Player references
Object player1;
Object player2;

PlayerControls p1Controls;
PlayerControls p2Controls;

HitEffect hitEffect;

StartScreen startScreen;
GameOverScreen gameOverScreen;
HowToPlayScreen howToPlayScreen;
CharacterSelectScreen characterSelectScreen;

String player1Choice = "Batman";
String player2Choice = "Superman";
boolean player2IsBot = false;

String gameState = "start";
PImage backgroundImage;

int gameOverDelay = 60;
int gameOverTimer = 0;
boolean gameOverPending = false;
String winner = "";

// ✅ Timer variables
int timer = 60 * 60;
final int initialTimer = 60 * 60;

void setup() {
  size(1000, 600);
  backgroundImage = loadImage("background3.png");
  backgroundImage.resize(width, height);

  hitEffect = new HitEffect();

  startScreen = new StartScreen();
  gameOverScreen = new GameOverScreen();
  howToPlayScreen = new HowToPlayScreen();
  characterSelectScreen = new CharacterSelectScreen();

  p1Controls = new PlayerControls('a', 'd', ' ', 'e', 's', 'f');
  p2Controls = new PlayerControls('j', 'l', 'i', 'h', 'k', 'u');

  initializePlayers();
}

void initializePlayers() {
  player2IsBot = player2Choice.equals("BOT");

  if (player1Choice.equals("Batman")) player1 = new Batman(200, p1Controls);
  else if (player1Choice.equals("Superman")) player1 = new Superman(200, p1Controls);
  else if (player1Choice.equals("Venom")) player1 = new Venom(200, p1Controls);
  else if (player1Choice.equals("Spiderman")) player1 = new Spiderman(200, p1Controls);

  if (player2IsBot) {
    player2 = new Superman(700, null); // Bot is always Superman for now
  } else {
    if (player2Choice.equals("Batman")) player2 = new Batman(700, p2Controls);
    else if (player2Choice.equals("Superman")) player2 = new Superman(700, p2Controls);
    else if (player2Choice.equals("Venom")) player2 = new Venom(700, p2Controls);
    else if (player2Choice.equals("Spiderman")) player2 = new Spiderman(700, p2Controls);
  }
}

void draw() {
  background(255);

  if (gameState.equals("start")) startScreen.display();
  else if (gameState.equals("characterSelect")) characterSelectScreen.display();
  else if (gameState.equals("play")) playGame();
  else if (gameState.equals("gameover")) gameOverScreen.display();
  else if (gameState.equals("howtoplay")) howToPlayScreen.display();
}

void playGame() {
  image(backgroundImage, 0, 0, width, height);

  updatePlayer(player1, player2);

  if (player2IsBot) {
    updateBot(player2, player1);
  } else {
    updatePlayer(player2, player1);
  }

  displayPlayer(player1);
  displayPlayer(player2);

  drawHealthBar();
  drawTimer();

  hitEffect.update();
  hitEffect.display();

  if (!gameOverPending) {
    checkWinCondition();

    if (timer > 0) {
      timer--;
    } else {
      winner = "Draw!";
      gameOverPending = true;
      gameOverTimer = gameOverDelay;
    }
  } else {
    gameOverTimer--;
    if (gameOverTimer <= 0) {
      gameOverScreen.setWinner(winner);
      gameState = "gameover";
      gameOverPending = false;
    }
  }
}

void updateBot(Object bot, Object target) {
  if (!(bot instanceof Superman)) return;
  Superman ai = (Superman) bot;

  float playerX = 0;
  if (target instanceof Superman) playerX = ((Superman) target).x;
  else if (target instanceof Batman) playerX = ((Batman) target).x;
  else if (target instanceof Venom) playerX = ((Venom) target).x;
  else if (target instanceof Spiderman) playerX = ((Spiderman) target).x;

  ai.facingRight = playerX > ai.x;

  float distance = abs(ai.x - playerX);

  // Movement logic
  if (distance > 180) {
    if (ai.x > playerX) ai.x -= ai.speed;
    else ai.x += ai.speed;
  } else if (distance < 80) {
    if (ai.x < playerX) ai.x -= ai.speed * 0.5;
    else ai.x += ai.speed * 0.5;
  }

  // Random jumping
  if (random(1) < 0.01 && ai.isGrounded()) {
    ai.yVelocity = ai.jumpStrength;
  }

  // ✅ Attack only if cooldown is ready AND no current attack
  boolean readyToAttack = millis() - ai.getLastAttackTime() > ai.getAttackCooldown();
  boolean notDoingAnything = !ai.isAction && !ai.isCharge && !ai.isSprint;

  if (distance < 150 && readyToAttack && notDoingAnything) {
    float r = random(1);
    if (r < 0.33) ai.activateAction();
    else if (r < 0.66) ai.activateCharge();
    else ai.activateSprint();
  }

  ai.update(target); // Continue animations, movement, etc.
}


void updatePlayer(Object player, Object opponent) {
  if (player instanceof Batman) ((Batman) player).update(opponent);
  if (player instanceof Superman) ((Superman) player).update(opponent);
  if (player instanceof Venom) ((Venom) player).update(opponent);
  if (player instanceof Spiderman) ((Spiderman) player).update(opponent);
}

void displayPlayer(Object player) {
  if (player instanceof Batman) ((Batman) player).display();
  if (player instanceof Superman) ((Superman) player).display();
  if (player instanceof Venom) ((Venom) player).display();
  if (player instanceof Spiderman) ((Spiderman) player).display();
}

void drawHealthBar() {
  int player1Health = getPlayerHealth(player1);
  int player2Health = getPlayerHealth(player2);

  drawSingleHealthBar(player1Health, 20, 20, player1Choice, getPlayerColor(player1Choice));
  drawSingleHealthBar(player2Health, width - 220, 20, player2Choice, getPlayerColor(player2Choice));
}

void drawSingleHealthBar(int health, float x, float y, String name, color textColor) {
  float barWidth = 200;
  float barHeight = 25;
  float healthWidth = map(health, 0, 100, 0, barWidth);

  fill(50);
  stroke(255);
  strokeWeight(2);
  rect(x, y, barWidth, barHeight, 10);

  noStroke();
  for (int i = 0; i < healthWidth; i++) {
    float inter = map(i, 0, barWidth, 0, 1);
    stroke(lerpColor(color(0, 255, 0), color(255, 0, 0), inter));
    line(x + i, y, x + i, y + barHeight);
  }

  textAlign(LEFT, TOP);
  textSize(18);
  stroke(0);
  strokeWeight(3);
  fill(textColor);
  text(name.toUpperCase(), x, y + barHeight + 12);
  noStroke();
}

void drawTimer() {
  int seconds = timer / 60;
  String timeText = nf(seconds, 2);

  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255);
  stroke(0);
  strokeWeight(3);
  text(timeText, width / 2, 32);
}

int getPlayerHealth(Object player) {
  if (player instanceof Batman) return ((Batman) player).health;
  if (player instanceof Superman) return ((Superman) player).health;
  if (player instanceof Venom) return ((Venom) player).health;
  if (player instanceof Spiderman) return ((Spiderman) player).health;
  return 100;
}

color getPlayerColor(String playerName) {
  if (playerName.equals("Batman")) return color(0, 191, 255);
  if (playerName.equals("Superman")) return color(255, 69, 0);
  if (playerName.equals("Venom")) return color(128, 0, 128);
  if (playerName.equals("Spiderman")) return color(255, 0, 0);
  return color(255);
}

void checkWinCondition() {
  int player1Health = getPlayerHealth(player1);
  int player2Health = getPlayerHealth(player2);

  if (player1Health <= 0) {
    winner = player2Choice;
    gameOverPending = true;
    gameOverTimer = gameOverDelay;
  } else if (player2Health <= 0) {
    winner = player1Choice;
    gameOverPending = true;
    gameOverTimer = gameOverDelay;
    displaySortedHealth();
  }
}

void displaySortedHealth() {
  Object[] players = { player1, player2 };
  String[] playerNames = { player1Choice, player2Choice };
  int[] healths = { getPlayerHealth(player1), getPlayerHealth(player2) };

  if (healths[0] < healths[1]) {
    int tempHealth = healths[0];
    healths[0] = healths[1];
    healths[1] = tempHealth;

    String tempName = playerNames[0];
    playerNames[0] = playerNames[1];
    playerNames[1] = tempName;
  }

  println("Final Health Ranking:");
  println("1. " + playerNames[0] + " - " + healths[0] + " HP");
  println("2. " + playerNames[1] + " - " + healths[1] + " HP");
}

void preparePlayState() {
  backgroundImage = loadImage("background3.png");
  backgroundImage.resize(width, height);
  initializePlayers();
  timer = initialTimer;
  gameOverPending = false;
  gameOverTimer = 0;
  winner = "";
}

void mousePressed() {
  if (gameState.equals("start")) startScreen.mousePressed();
  else if (gameState.equals("characterSelect")) characterSelectScreen.mousePressed();
  else if (gameState.equals("gameover")) gameOverScreen.mousePressed();
  else if (gameState.equals("howtoplay")) howToPlayScreen.mousePressed();
}

void mouseDragged() {
  if (gameState.equals("howtoplay")) howToPlayScreen.mouseDragged();
}

void mouseReleased() {
  if (gameState.equals("howtoplay")) howToPlayScreen.mouseReleased();
}

void mouseWheel(MouseEvent event) {
  if (gameState.equals("howtoplay")) howToPlayScreen.mouseWheel(event);
}

void keyPressed() {
  if (gameState.equals("play")) {
    p1Controls.keyPressed(player1, key);
    if (!player2IsBot) p2Controls.keyPressed(player2, key);
  }
}

void keyReleased() {
  if (gameState.equals("play")) {
    p1Controls.keyReleased(player1, key);
    if (!player2IsBot) p2Controls.keyReleased(player2, key);
  }
}
