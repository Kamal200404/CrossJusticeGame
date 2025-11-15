class HitEffect {
  boolean active = false;
  float x, y;
  int frameCounter = 0;
  int totalFrames = 10;

  HitEffect() {
  }

  void trigger(float hitX, float hitY) {
    x = hitX;
    y = hitY;
    frameCounter = 0;
    active = true;
  }

  void update() {
    if (active) {
      frameCounter++;
      if (frameCounter > totalFrames) {
        active = false;
      }
    }
  }

  void display() {
    if (active) {
      pushMatrix();
      translate(x, y);

      strokeWeight(2);
      int alpha = int(map(frameCounter, 0, totalFrames, 255, 0));
      stroke(255, 255, 0, alpha); // Yellow spark color

      int numLines = 8;
      for (int i = 0; i < numLines; i++) {
        float angle = random(TWO_PI);
        float length = random(10, 30);
        float x2 = cos(angle) * length;
        float y2 = sin(angle) * length;
        line(0, 0, x2, y2);
      }

      popMatrix();
    }
  }
}
