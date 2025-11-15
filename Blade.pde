class Blade {
  float x, y;
  float speed = 5;
  PImage img;
  boolean isActive = true;

  Blade(float startX, float startY, PImage img) {
    this.x = startX;
    this.y = startY;
    this.img = img;
  }

  void update() {
    x += speed;
  }

  void display() {
    if (isActive) {
      image(img, x, y, img.width * 2, img.height * 2);
    }
  }

  boolean hits(Superman s) {
    return isActive &&
           x + img.width * 2 > s.x &&
           x < s.x + 50 &&
           y > s.y &&
           y < s.y + 100;
  }
}
