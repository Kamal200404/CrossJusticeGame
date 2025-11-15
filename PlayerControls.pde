class PlayerControls {
  char leftKey, rightKey, jumpKey, attackKey, specialKey, bladeKey;

  PlayerControls(char leftKey, char rightKey, char jumpKey, char attackKey, char specialKey, char bladeKey) {
    this.leftKey = leftKey;
    this.rightKey = rightKey;
    this.jumpKey = jumpKey;
    this.attackKey = attackKey;
    this.specialKey = specialKey;
    this.bladeKey = bladeKey;
  }

  boolean isLeftKeyPressed() {
    return keyPressed && key == leftKey;
  }

  boolean isRightKeyPressed() {
    return keyPressed && key == rightKey;
  }

  boolean isJumpKeyPressed() {
    return keyPressed && key == jumpKey;
  }

  boolean isAttackKeyPressed() {
    return keyPressed && key == attackKey;
  }

  boolean isSpecialKeyPressed() {
    return keyPressed && key == specialKey;
  }

  boolean isBladeKeyPressed() {
    return keyPressed && key == bladeKey;
  }

  void keyPressed(Object player, char key) {
  if (player instanceof Batman) ((Batman) player).handleInput(key, true);
  else if (player instanceof Superman) ((Superman) player).handleInput(key, true);
  else if (player instanceof Venom) ((Venom) player).handleInput(key, true);
  
  else if (player instanceof Spiderman) ((Spiderman) player).handleInput(key, true); // ✅ Add this!
}

  void keyReleased(Object player, char key) {
  if (player instanceof Batman) ((Batman) player).handleInput(key, false);
  else if (player instanceof Superman) ((Superman) player).handleInput(key, false);
  else if (player instanceof Venom) ((Venom) player).handleInput(key, false);
  
  else if (player instanceof Spiderman) ((Spiderman) player).handleInput(key, false); // ✅ Add this!
}
}
