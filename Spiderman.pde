class Spiderman {
  int health = 100;

  PImage[] idleFrames, punchFrames, secondAttackFrames, thirdAttackFrames, deathFrames;
  PImage[] currentFrames;

  int frameIndex = 0;
  int frameDelay = 5;
  int frameCounter = 0;

  float x, y;
  float speed = 9;
  float scaleFactor = 4.0;

  final float groundY = 570;

  float yVelocity = 0;
  float gravity = 1.4;
  float jumpStrength = -20;
  boolean grounded = true;

  boolean moveLeft = false;
  boolean moveRight = false;
  boolean isPunch = false;
  boolean isSecondAttack = false;
  boolean isThirdAttack = false;
  boolean isDead = false;

  int attackCooldown = 0;
  int secondAttackCooldown = 0;
  int thirdAttackCooldown = 0;
  int cooldownDuration = 50;

  int hitEffectTimer = 0;
  int deathDelayCounter = 30;

  PlayerControls controls;
  boolean facingRight = true;

  boolean hasDealtDamage = false;

  Spiderman(float startX, PlayerControls controls) {
    x = startX;
    this.controls = controls;

    idleFrames = loadFrames(new String[]{
      "Spiderman-1.png", "Spiderman-2.png", "Spiderman-3.png", "Spiderman-4.png", "Spiderman-5.png"
    });

    punchFrames = loadFrames(new String[]{
      "Spiderman-1.1.png", "Spiderman-1.2.png", "Spiderman-1.3.png", "Spiderman-1.4.png", "Spiderman-1.5.png"
    });

    secondAttackFrames = loadFrames(new String[]{
      "Spiderman-2.1.png", "Spiderman-2.2.png", "Spiderman-2.3.png", "Spiderman-2.4.png"
    });

    thirdAttackFrames = loadFrames(new String[]{
      "Spiderman-3.1.png", "Spiderman-3.2.png", "Spiderman-3.3.png"
    });

    deathFrames = loadFrames(new String[]{
      "SpidermanDeath-1.png", "SpidermanDeath-2.png", "SpidermanDeath-3.png",
      "SpidermanDeath-4.png", "SpidermanDeath-5.png", "SpidermanDeath-6.png"
    });

    currentFrames = idleFrames;
    y = groundY - (idleFrames[0].height * scaleFactor) + 50;
  }

  PImage[] loadFrames(String[] fileNames) {
    PImage[] frames = new PImage[fileNames.length];
    for (int i = 0; i < fileNames.length; i++) {
      frames[i] = loadImage(fileNames[i]);
    }
    return frames;
  }

  void update(Object opponent) {
    if (!(opponent instanceof Superman || opponent instanceof Batman || opponent instanceof Venom || opponent instanceof Spiderman)) return;

    float opponentX = getOpponentX(opponent);
    float opponentW = getOpponentWidth(opponent);

    if (health <= 0 && !isDead) {
      isDead = true;
      currentFrames = deathFrames;
      frameIndex = 0;
      moveLeft = false;
      moveRight = false;
      yVelocity = 0;
      grounded = true;
      x = constrain(x, 0, width - getWidth());
      y = groundY - getHeight();
    }

    if (isDead) {
      y = groundY - getHeight(); // Make sure Spiderman dies on the floor

      frameCounter++;
      if (frameCounter >= frameDelay) {
        frameIndex++;
        if (frameIndex >= currentFrames.length) {
          frameIndex = currentFrames.length - 1;
          if (deathDelayCounter > 0) deathDelayCounter--;
          else {
            gameOverScreen.setWinner(getOpponentName(opponent));
            gameState = "gameover";
          }
        }
        frameCounter = 0;
      }
      return;
    }

    // Cooldowns
    if (attackCooldown > 0) attackCooldown--;
    if (secondAttackCooldown > 0) secondAttackCooldown--;
    if (thirdAttackCooldown > 0) thirdAttackCooldown--;

    facingRight = (opponentX > x);

    if (moveLeft && x > 0) x -= speed;
    if (moveRight && x < width - getWidth()) x += speed;

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

    if (isPunch || isSecondAttack || isThirdAttack || moveLeft || moveRight) {
      frameCounter++;
      if (frameCounter >= frameDelay) {
        frameIndex++;
        if (frameIndex >= currentFrames.length) {
          frameIndex = 0;
          if (isPunch || isSecondAttack || isThirdAttack) {
            isPunch = false;
            isSecondAttack = false;
            isThirdAttack = false;
            currentFrames = idleFrames;
          }
        }
        frameCounter = 0;
      }
    } else {
      frameIndex = 0;
    }

    checkCollision(opponent);
    if (hitEffectTimer > 0) hitEffectTimer--;
  }

  void checkCollision(Object opponent) {
    if (!(opponent instanceof Superman || opponent instanceof Batman || opponent instanceof Venom || opponent instanceof Spiderman) || hasDealtDamage) return;

    float opponentX = getOpponentX(opponent);
    float opponentW = getOpponentWidth(opponent);

    if (isPunch && frameIndex == 2 && frameCounter == 0) {
      if (isInRange(opponentX, opponentW, 10)) registerHit(opponent);
    }

    if (isSecondAttack && frameIndex == 2 && frameCounter == 0) {
      if (isInRange(opponentX, opponentW, 10)) registerHit(opponent);
    }

    if (isThirdAttack && frameIndex == 2 && frameCounter == 0) {
      if (isInRange(opponentX, opponentW, 5)) registerHit(opponent);
    }
  }

  boolean isInRange(float opponentX, float opponentW, float range) {
    return facingRight
      ? (x + getWidth() + range > opponentX && x < opponentX + opponentW)
      : (x - range < opponentX + opponentW && x > opponentX);
  }

  void registerHit(Object opponent) {
    applyDamage(opponent, 10);
    triggerHitEffect(opponent);
    hasDealtDamage = true;
  }

  void applyDamage(Object opponent, int damage) {
    if (opponent instanceof Superman) ((Superman) opponent).takeDamage(damage);
    if (opponent instanceof Batman) ((Batman) opponent).takeDamage(damage);
    if (opponent instanceof Venom) ((Venom) opponent).takeDamage(damage);
    if (opponent instanceof Spiderman) ((Spiderman) opponent).takeDamage(damage);
  }

  void triggerHitEffect(Object opponent) {
    float x = getOpponentX(opponent) + getOpponentWidth(opponent) / 2;
    float y = getOpponentY(opponent) + getOpponentHeight(opponent) / 2;
    hitEffect.trigger(x, y);
  }

  String getOpponentName(Object opponent) {
    if (opponent instanceof Superman) return "Superman";
    if (opponent instanceof Batman) return "Batman";
    if (opponent instanceof Venom) return "Venom";
    if (opponent instanceof Spiderman) return "Spiderman";
    return "Opponent";
  }

  float getOpponentX(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).x;
    if (opponent instanceof Batman) return ((Batman) opponent).x;
    if (opponent instanceof Venom) return ((Venom) opponent).x;
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).x;
    return 0;
  }

  float getOpponentY(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).y;
    if (opponent instanceof Batman) return ((Batman) opponent).y;
    if (opponent instanceof Venom) return ((Venom) opponent).y;
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).y;
    return 0;
  }

  float getOpponentWidth(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).getWidth();
    if (opponent instanceof Batman) return ((Batman) opponent).getWidth();
    if (opponent instanceof Venom) return ((Venom) opponent).getWidth();
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).getWidth();
    return 0;
  }

  float getOpponentHeight(Object opponent) {
    if (opponent instanceof Superman) return ((Superman) opponent).getHeight();
    if (opponent instanceof Batman) return ((Batman) opponent).getHeight();
    if (opponent instanceof Venom) return ((Venom) opponent).getHeight();
    if (opponent instanceof Spiderman) return ((Spiderman) opponent).getHeight();
    return 0;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    if (!facingRight) scale(-1, 1);
    if (hitEffectTimer > 0) tint(255, 0, 0);
    else noTint();
    if (!facingRight) image(currentFrames[frameIndex], -getWidth(), 0, getWidth(), getHeight());
    else image(currentFrames[frameIndex], 0, 0, getWidth(), getHeight());
    noTint();
    popMatrix();
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

    if (key == controls.attackKey) activatePunch();
    if (key == controls.bladeKey) activateSecondAttack();
    if (key == controls.specialKey) activateThirdAttack();
  }

  void activatePunch() {
    if (attackCooldown == 0 && !isPunch && !isSecondAttack && !isThirdAttack) {
      isPunch = true;
      currentFrames = punchFrames;
      frameIndex = 0;
      attackCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }

  void activateSecondAttack() {
    if (secondAttackCooldown == 0 && !isPunch && !isSecondAttack && !isThirdAttack) {
      isSecondAttack = true;
      currentFrames = secondAttackFrames;
      frameIndex = 0;
      secondAttackCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }

  void activateThirdAttack() {
    if (thirdAttackCooldown == 0 && !isPunch && !isSecondAttack && !isThirdAttack) {
      isThirdAttack = true;
      currentFrames = thirdAttackFrames;
      frameIndex = 0;
      thirdAttackCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }
}
