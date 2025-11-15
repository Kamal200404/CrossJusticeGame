class HealthBar {
  float x, y;
  color barColor;
  float width = 200;
  float height = 20;

  HealthBar(float x, float y, color barColor) {
    this.x = x;
    this.y = y;
    this.barColor = barColor;
  }

  void display(int health) {
    noStroke();
    fill(100);
    rect(x, y, width, height);
    fill(barColor);
    float currentWidth = map(health, 0, 100, 0, width);
    rect(x, y, currentWidth, height);
  }
}
