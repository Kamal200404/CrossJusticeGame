class Batman {
  int health = 100;

  PImage[] walkFrames, actionFrames, specialFrames, bladeThrowFrames, deathFrames;
  PImage bladeImage;
  PImage[] currentFrames;

  int frameIndex = 0;
  int frameDelay = 5;
  int frameCounter = 0;

  float x, y;
  float speed = 9;
  float scaleFactor = 3.2;

  final float groundY = 570;

  float yVelocity = 0;
  float gravity = 1.4;
  float jumpStrength = -20;
  boolean grounded = true;

  boolean moveLeft = false;
  boolean moveRight = false;
  boolean isAction = false;
  boolean isSpecial = false;
  boolean isBladeThrow = false;
  boolean isDead = false;

  int actionCooldown = 0;
  int specialCooldown = 0;
  int bladeCooldown = 0;
  int cooldownDuration = 50;

  float bladeX = -1000;
  float bladeY = -1000;
  float bladeSpeed = 6;
  boolean isBladeFlying = false;

  int hitEffectTimer = 0;

  PlayerControls controls;
  boolean facingRight = true;

  boolean hasDealtDamage = false;

  Batman(float startX, PlayerControls controls) {
    x = startX;
    this.controls = controls;

    walkFrames = loadFrames("Batman-", 5, 10);
    actionFrames = loadFrames("Batman-1.", 1, 9);
    specialFrames = loadFrames("Batman-2.", 1, 7);
    bladeThrowFrames = loadFrames("Batman-3.", 1, 4);

    deathFrames = loadFrames(new String[]{
      "BatmanDeath-1.png",
      "BatmanDeath-2.png",
      "BatmanDeath-3.png"
    });

    bladeImage = loadImage("BatmanBlade.png");
    currentFrames = walkFrames;

    y = groundY - (walkFrames[0].height * scaleFactor) + 50;
  }

  PImage[] loadFrames(String base, int start, int end) {
    PImage[] frames = new PImage[end - start + 1];
    for (int i = 0; i < frames.length; i++) {
      frames[i] = loadImage(base + (i + start) + ".png");
    }
    return frames;
  }

  PImage[] loadFrames(String[] fileNames) {
    PImage[] frames = new PImage[fileNames.length];
    for (int i = 0; i < fileNames.length; i++) {
      frames[i] = loadImage(fileNames[i]);
    }
    return frames;
  }

  void update(Object opponent) {
    if (health <= 0 && !isDead) {
      isDead = true;
      currentFrames = deathFrames;
      frameIndex = 0;
    }

    if (isDead) {
      y += yVelocity;
      yVelocity += gravity;

      if (y >= groundY - getHeight()) {
        y = groundY - getHeight();
        yVelocity = 0;
        grounded = true;
      }

      frameCounter++;
      if (frameCounter >= frameDelay) {
        frameIndex++;
        if (frameIndex >= currentFrames.length) {
          frameIndex = currentFrames.length - 1;
        }
        frameCounter = 0;
      }
      return;
    }

    if (actionCooldown > 0) actionCooldown--;
    if (specialCooldown > 0) specialCooldown--;
    if (bladeCooldown > 0) bladeCooldown--;

    float opponentX = getOpponentX(opponent);
    float opponentW = getOpponentWidth(opponent);

    facingRight = (opponentX > x);

    if (moveLeft && x > 0) x -= speed;
    if (moveRight && x < width - getWidth()) x += speed;

    // ✅ Prevent overlap (now includes Spiderman)
    if (facingRight) {
      if (x + getWidth() >= opponentX && moveRight) {
        x = opponentX - getWidth();
      }
    } else {
      if (x <= opponentX + opponentW && moveLeft) {
        x = opponentX + opponentW;
      }
    }

    x = constrain(x, 0, width - getWidth());

    y += yVelocity;
    yVelocity += gravity;

    if (y >= groundY - getHeight()) {
      y = groundY - getHeight();
      yVelocity = 0;
      grounded = true;
    } else {
      grounded = false;
    }

    if (isBladeFlying) {
      bladeX += (facingRight) ? bladeSpeed : -bladeSpeed;
      if (bladeX > width || bladeX < 0) isBladeFlying = false;
    }

    frameCounter++;
    if (frameCounter >= frameDelay) {
      frameIndex++;
      if (frameIndex >= currentFrames.length) {
        frameIndex = 0;
        if (isAction || isSpecial || isBladeThrow) {
          isAction = false;
          isSpecial = false;
          isBladeThrow = false;
          currentFrames = walkFrames;
          hasDealtDamage = false;
        }
      }
      frameCounter = 0;
    }

    checkCollision(opponent);
    if (hitEffectTimer > 0) hitEffectTimer--;
  }

  void checkCollision(Object opponent) {
    if (opponent == null || hasDealtDamage) return;

    float opponentX = getOpponentX(opponent);
    float opponentW = getOpponentWidth(opponent);

    if (isAction && frameIndex >= 2 && frameIndex <= 4) {
      if (opponent != this && x + getWidth() > opponentX && x < opponentX + opponentW) {
        applyDamage(opponent, 10);
        triggerHitEffect(opponent);
        hasDealtDamage = true;
      }
    }

    if (isSpecial && frameIndex >= 3 && frameIndex <= 5) {
      float extraRange = 20;
      float attackReachX = facingRight ? x + getWidth() + extraRange : x - extraRange;

      boolean inRange = facingRight
        ? attackReachX > opponentX && x < opponentX + opponentW
        : attackReachX < opponentX + opponentW && x > opponentX;

      if (opponent != this && inRange) {
        applyDamage(opponent, 15);
        triggerHitEffect(opponent);
        hasDealtDamage = true;
      }
    }

    if (isBladeFlying) {
      float bladeHeight = bladeImage.height * 2;
      float bladeWidth = bladeImage.width * 2;

      boolean xOverlap = bladeX + bladeWidth > opponentX && bladeX < opponentX + opponentW;
      boolean yOverlap = bladeY + bladeHeight > getOpponentY(opponent) && bladeY < getOpponentY(opponent) + getOpponentHeight(opponent);

      if (xOverlap && yOverlap) {
        applyDamage(opponent, 15);
        isBladeFlying = false;
        triggerHitEffect(opponent);
      }
    }
  }

  void applyDamage(Object opponent, int damage) {
    if (opponent instanceof Superman) ((Superman) opponent).takeDamage(damage);
    if (opponent instanceof Batman) ((Batman) opponent).takeDamage(damage);
    if (opponent instanceof Venom) ((Venom) opponent).takeDamage(damage);
    if (opponent instanceof Spiderman) ((Spiderman) opponent).takeDamage(damage); // ✅ Add Spiderman
  }

  void triggerHitEffect(Object opponent) {
    float x = getOpponentX(opponent) + getOpponentWidth(opponent) / 2;
    float y = getOpponentY(opponent) + getOpponentHeight(opponent) / 2;
    hitEffect.trigger(x, y);
  }

  float getOpponentX(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).x;
    if (opponent instanceof Batman) return ((Batman) opponent).x;
    if (opponent instanceof Venom) return ((Venom) opponent).x;
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).x; // ✅ Add Spiderman
    return 0;
  }

  float getOpponentY(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).y;
    if (opponent instanceof Batman) return ((Batman) opponent).y;
    if (opponent instanceof Venom) return ((Venom) opponent).y;
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).y; // ✅ Add Spiderman
    return 0;
  }

  float getOpponentWidth(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).getWidth();
    if (opponent instanceof Batman) return ((Batman) opponent).getWidth();
    if (opponent instanceof Venom) return ((Venom) opponent).getWidth();
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).getWidth(); // ✅ Add Spiderman
    return 0;
  }

  float getOpponentHeight(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).getHeight();
    if (opponent instanceof Batman) return ((Batman) opponent).getHeight();
    if (opponent instanceof Venom) return ((Venom) opponent).getHeight();
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).getHeight(); // ✅ Add Spiderman
    return 0;
  }

  void display() {
    pushMatrix();
    translate(x, y);

    if (!facingRight) {
      scale(-1, 1);
    }

    if (hitEffectTimer > 0) {
      tint(255, 0, 0);
    } else {
      noTint();
    }

    if (!facingRight) {
      image(currentFrames[frameIndex], -getWidth(), 0, getWidth(), getHeight());
    } else {
      image(currentFrames[frameIndex], 0, 0, getWidth(), getHeight());
    }

    noTint();
    popMatrix();

    if (isBladeFlying) {
      image(bladeImage, bladeX, bladeY, bladeImage.width * 2, bladeImage.height * 2);
    }
  }

  float getWidth() {
    return currentFrames[frameIndex].width * scaleFactor;
  }

  float getHeight() {
    return currentFrames[frameIndex].height * scaleFactor;
  }

  void takeDamage(int damage) {
    if (isDead) return;
    health -= damage;
    health = max(0, health);
    hitEffectTimer = 10;
  }

  void handleInput(char key, boolean isPressed) {
    if (isDead) return;

    if (key == controls.leftKey) moveLeft = isPressed;
    if (key == controls.rightKey) moveRight = isPressed;

    if (!isPressed) return;

    if (key == controls.jumpKey && grounded && yVelocity == 0) {
      yVelocity = jumpStrength;
      grounded = false;
    }

    if (key == controls.specialKey) activateSpecial();
    if (key == controls.attackKey) activateAction();
    if (key == controls.bladeKey) activateBladeThrow();
  }

  void activateAction() {
    if (actionCooldown == 0 && !isAction && !isSpecial && !isBladeThrow) {
      isAction = true;
      currentFrames = actionFrames;
      frameIndex = 0;
      actionCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }

  void activateSpecial() {
    if (specialCooldown == 0 && !isAction && !isSpecial && !isBladeThrow) {
      isSpecial = true;
      currentFrames = specialFrames;
      frameIndex = 0;
      specialCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }

  void activateBladeThrow() {
    if (bladeCooldown == 0 && !isAction && !isSpecial && !isBladeThrow) {
      isBladeThrow = true;
      currentFrames = bladeThrowFrames;
      frameIndex = 0;
      bladeCooldown = cooldownDuration;

      bladeX = facingRight ? x + getWidth() : x - 50;
      bladeY = y + getHeight() - bladeImage.height;
      isBladeFlying = true;
    }
  }
}
