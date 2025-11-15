class Button {
  float x, y, w, h;
  String label;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void display() {
    displayWithGlow();
  }

  void displayWithGlow() {
    boolean hovering = isHovering(mouseX, mouseY);

    // Background rectangle
    if (hovering) {
      // 💙 Hover glow effect
      stroke(0, 191, 255);
      strokeWeight(4);
      fill(40); // darker grey when hover for depth
    } else {
      noStroke();
      fill(60); // normal grey
    }

    rect(x, y, w, h, 10);

    // Text
    textAlign(CENTER, CENTER);
    textSize(18);
    if (hovering) {
      fill(0, 191, 255); // bright blue text
    } else {
      fill(255); // normal white text
    }

    text(label, x + w / 2, y + h / 2);
  }

  boolean isClicked(float mx, float my) {
    return isHovering(mx, my);
  }

  boolean isHovering(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }

  // ✅ Add this method to match CharacterSelectScreen call!
  boolean isHovered(float mx, float my) {
    return isHovering(mx, my);
  }
}
