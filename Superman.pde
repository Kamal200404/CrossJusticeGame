class Superman {
  public int health = 100;

  PImage[] idleFrames, actionFrames, chargeFrames, sprintFrames, deathFrames;
  PImage[] currentFrames;

  int frameIndex = 0;
  int frameDelay = 5;
  int frameCounter = 0;

  public float x, y;
  public float speed = 9;
  float scaleFactor = 2.7;
  final float groundY = 570;

  public float yVelocity = 0;
  float gravity = 1.4;
  public float jumpStrength = -20;
  public boolean grounded = true;

  boolean moveLeft = false;
  boolean moveRight = false;
  public boolean isAction = false;
  public boolean isCharge = false;
  public boolean isSprint = false;
  boolean isDead = false;

  public int lastAttackTime = -1000;
  public int attackCooldown = 1000;

  int actionCooldown = 0;
  int chargeCooldown = 0;
  int sprintCooldown = 0;
  int cooldownDuration = 50;

  int hitEffectTimer = 0;
  int deathDelayCounter = 30;

  PlayerControls controls;
  public boolean facingRight = true;
  boolean hasDealtDamage = false;

  // ✅ Getters for AI use
  float getX() { return x; }
  boolean isGrounded() { return grounded; }
  int getLastAttackTime() { return lastAttackTime; }
  int getAttackCooldown() { return attackCooldown; }

  Superman(float startX, PlayerControls controls) {
    x = startX;
    this.controls = controls;

    idleFrames = loadFrames(new String[]{
      "Superman-1.png", "Superman-2.png", "Superman-3.png", "Superman-4.png", "Superman-6.png"
    });

    chargeFrames = loadFrames(new String[]{
      "Superman-2.1.png", "Superman-2.2.png", "Superman-2.3.png", "Superman-2.4.png", "Superman-2.5.png"
    });

    sprintFrames = loadFrames(new String[]{
      "Superman-3.1.png", "Superman-3.2.png", "Superman-3.3.png", "Superman-3.4.png",
      "Superman-3.5.png", "Superman-3.6.png", "Superman-3.7.png", "Superman-3.8.png"
    });

    actionFrames = loadFrames(new String[]{
      "Superman-4.1.png", "Superman-4.2.png", "Superman-4.3.png", "Superman-4.4.png",
      "Superman-4.5.png", "Superman-4.6.png", "Superman-4.7.png", "Superman-4.8.png"
    });

    deathFrames = loadFrames(new String[]{
      "Superman_death-1.png", "Superman_death-2.png", "Superman_death-3.png",
      "Superman_death-4.png", "Superman_death-5.png", "Superman_death-6.png"
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
      y = groundY - getHeight();
      frameCounter++;
      if (frameCounter >= frameDelay) {
        frameIndex++;
        if (frameIndex >= deathFrames.length) {
          frameIndex = deathFrames.length - 1;
          if (deathDelayCounter > 0) deathDelayCounter--;
          else {
            gameOverScreen.setWinner("Opponent");
            gameState = "gameover";
          }
        }
        frameCounter = 0;
      }
      return;
    }

    if (actionCooldown > 0) actionCooldown--;
    if (chargeCooldown > 0) chargeCooldown--;
    if (sprintCooldown > 0) sprintCooldown--;

    float opponentX = getOpponentX(opponent);
    float opponentW = getOpponentWidth(opponent);

    facingRight = (opponentX > x);

    if (moveLeft && x > 0) x -= speed;
    if (moveRight && x < width - getWidth()) x += speed;

    if (facingRight && x + getWidth() >= opponentX && moveRight) {
      x = opponentX - getWidth();
    } else if (!facingRight && x <= opponentX + opponentW && moveLeft) {
      x = opponentX + opponentW;
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

    if (isAction || isCharge || isSprint || moveLeft || moveRight) {
      frameCounter++;
      if (frameCounter >= frameDelay) {
        frameIndex++;
        if (frameIndex >= currentFrames.length) {
          frameIndex = 0;
          if (isAction || isCharge || isSprint) {
            isAction = false;
            isCharge = false;
            isSprint = false;
            currentFrames = idleFrames;
            hasDealtDamage = false;
          }
        }
        frameCounter = 0;
      }
    } else {
      frameIndex = 0;
    }

    checkCollision(opponent);

    if (hitEffectTimer > 0) hitEffectTimer--;

    if (isAction || isCharge || isSprint) {
      lastAttackTime = millis(); // ✅ AI uses this to time next attack
    }
  }

  void checkCollision(Object opponent) {
    if (opponent == null || hasDealtDamage) return;

    float opponentX = getOpponentX(opponent);
    float opponentW = getOpponentWidth(opponent);
    float extraRange = 10;

    if ((isAction || isCharge || isSprint) && frameIndex >= 2 && frameIndex <= 4) {
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
    if (key == controls.attackKey) activateAction();
    if (key == controls.specialKey) activateCharge();
    if (key == controls.bladeKey) activateSprint();
  }

  void activateAction() {
    if (actionCooldown == 0 && !isAction && !isCharge && !isSprint) {
      isAction = true;
      currentFrames = actionFrames;
      frameIndex = 0;
      actionCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }

  void activateCharge() {
    if (chargeCooldown == 0 && !isAction && !isCharge && !isSprint) {
      isCharge = true;
      currentFrames = chargeFrames;
      frameIndex = 0;
      chargeCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }

  void activateSprint() {
    if (sprintCooldown == 0 && !isAction && !isCharge && !isSprint) {
      isSprint = true;
      currentFrames = sprintFrames;
      frameIndex = 0;
      sprintCooldown = cooldownDuration;
      hasDealtDamage = false;
    }
  }
}
