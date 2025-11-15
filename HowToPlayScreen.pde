class HowToPlayScreen {
  float scrollY = 0;
  float contentHeight = 1000;
  float scrollBarY = 0;
  float scrollBarHeight;
  boolean dragging = false;
  float dragOffsetY;

  Button backButton;

  HowToPlayScreen() {
    backButton = new Button(width - 140, height - 70, 100, 40, "Back");
    scrollBarHeight = constrain(height * (height / contentHeight), 50, height);
  }

  void display() {
    background(30);
    fill(255);
    textAlign(LEFT);
    textSize(24);
    pushMatrix();
    translate(40, -scrollY + 80);

    text("How to Play:", 0, 0);
    textSize(18);

    // Player 1 Instructions
    text("- Player 1 (Batman / Venom):", 0, 40);
    text("    Move: A / D", 0, 70);
    text("    Jump: SPACE", 0, 100);
    text("    Basic Attack: E", 0, 130);
    text("    Special / Blade Attack: F (Batman)", 0, 160);
    text("    Special Moves: S (Batman)", 0, 190);

    // Player 2 Instructions
    text("- Player 2 (Superman / Venom):", 0, 240);
    text("    Move: J / L", 0, 270);
    text("    Jump: I", 0, 300);
    text("    Basic Attack: H", 0, 330);
    text("    Special Moves: U / K (Superman)", 0, 360);

    text("- Objective:", 0, 430);
    text("    Deplete your opponent's health bar to win.", 0, 460);

    text("- Tips:", 0, 510);
    text("    Use jumps to dodge attacks.", 0, 540);
    text("    Time your attacks to hit in the correct animation frame!", 0, 570);
    text("    Venom shares controls based on player side.", 0, 600);

    popMatrix();

    // Scrollbar background
    fill(100);
    rect(width - 30, 0, 20, height);

    // Scrollbar handle
    fill(180);
    rect(width - 30, scrollBarY, 20, scrollBarHeight);

    // Back button
    backButton.x = width - 140;
    backButton.y = height - 60;
    backButton.display();
  }

  void mousePressed() {
    if (backButton.isClicked(mouseX, mouseY)) {
      gameState = "start";
    }

    if (mouseX > width - 30 && mouseX < width - 10 &&
        mouseY > scrollBarY && mouseY < scrollBarY + scrollBarHeight) {
      dragging = true;
      dragOffsetY = mouseY - scrollBarY;
    }
  }

  void mouseReleased() {
    dragging = false;
  }

  void mouseDragged() {
    if (dragging) {
      scrollBarY = constrain(mouseY - dragOffsetY, 0, height - scrollBarHeight);
      scrollY = map(scrollBarY, 0, height - scrollBarHeight, 0, contentHeight - height);
    }
  }

  void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    scrollY = constrain(scrollY + e * 40, 0, contentHeight - height);
    scrollBarY = map(scrollY, 0, contentHeight - height, 0, height - scrollBarHeight);
  }
}
