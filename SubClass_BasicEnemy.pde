class BasicEnemy extends character {
  int attack, attackBuffer, accumulatedPoints;
  float speedMultiplier, saveChargeSpeedX, saveChargeSpeedY, saveChargePosY, chargeTime;
  final float mainSpeed = min(random(1+level*0.25,1.5+level*0.25),16);
  boolean goingLeft;
  final color defaultInnerColor = color(255,0,0);
  PowerUp currentPowerUp;
  
  BasicEnemy(float x, float y, int w, int h) {
    super(x,y,w,h);
    timer = maxTimer;
    speedMultiplier = 1;
    innerColor = defaultInnerColor;
    goingLeft = ((int)random(0,2)==1) ? true : false;
    currentPowerUp = new PowerUp(0,0,0,0,0);
  }
  
  void collidedWithPlayer() {
    if (hitCharacter(player)) {
      if (player.shield > 0 && time % 5 == 0) decreaseHealth(1);
      else if (currentPowerUp.type==currentPowerUp.WAVE) player.decreaseHealth(3);
      else if (currentPowerUp.type==currentPowerUp.SWEEP) player.decreaseHealth(player.health);
      else if (player.shield <= 0) player.decreaseHealth(1);
    }
  }
  
  void moving() {
    dx = goingLeft ? max(-mainSpeed*speedMultiplier,-16) : min(mainSpeed*speedMultiplier,16);
    if (goingLeft && x-w/2 < 0) goingLeft=false;
    if (!goingLeft && x+w/2 > width) goingLeft=true;
    dy = 0;
    float density = (1-(float)enemies.size()/(float)numberOfEnemies)*700+level*5;
    int chance = (currentPowerUp.type>0) ? 400-(int)density : 1000-(int)density*2;
    if ((int)random(max(chance,0))==0 && attackBuffer<=0) {
      attack = (int)random(1,3);
      saveChargeSpeedX = random(1,4);
      saveChargeSpeedY = random(3,7);
      saveChargePosY = y;
    }
  }
  
  void charge() {
    boolean goingForPlayer = currentPowerUp.type==currentPowerUp.HOMING;
    boolean goingForGauge = currentPowerUp.type==currentPowerUp.GAUGE && powerup!=null && powerup.health>0;
    chargeTime++;
    if (goingForPlayer) {
      dx = (player.x-x)*speedMultiplier*mainSpeed*0.02;
      dy = (player.y-y)*speedMultiplier*mainSpeed*0.02;
    } else if (goingForGauge) {
      dx = (powerup.x-x)*speedMultiplier*mainSpeed*0.1;
      dy = (powerup.y-y)*speedMultiplier*mainSpeed*0.1;
    } else {
      dx = cos(chargeTime*PI/180)*speedMultiplier*saveChargeSpeedX*(attack==1 ? 1 : -1);
      dy = sin(chargeTime*PI/180)*speedMultiplier*saveChargeSpeedY;
    }
    if (y<=saveChargePosY+h && y>=saveChargePosY-h && chargeTime>=360 && !goingForPlayer && !goingForGauge) {
      attackBuffer = (int)((float)enemies.size()*500/(float)numberOfEnemies);
      dx = mainSpeed;
      y = saveChargePosY;
      attack = 0;
      chargeTime = 0;
    }
  }
  
  void obtainPowerUp() {
    powerup.obtain();
    PowerUp prev = currentPowerUp;
    if (!noTimerPowerUp(powerup)) {
      refresh();
      if (currentPowerUp.enhanceNextPowerUp) {
        maxGauge = 2500;
        currentPowerUp.enhanceNextPowerUp = false;
      }
      if (gauge<=0) gauge=maxGauge;
      innerColor = powerup.innerColor;
    }
    currentPowerUp = powerup;
    applyPowerUpEffect(currentPowerUp);
    if (noTimerPowerUp(currentPowerUp)) currentPowerUp=prev;
  }
  
  boolean noTimerPowerUp(PowerUp P) {
    return (P.type==P.HEALTH || P.type==P.PNTS);
  }
  
  void applyPowerUpEffect(PowerUp P) {
    if (P.type==P.SPEED && speedMultiplier<=1) speedMultiplier*=3;
    else if (P.type == P.SHIELD) shield=4;
    else if (P.type == P.PNTS) score-=1000;
    else if (P.type == P.HEALTH) recoverHealth(maxHealth);
    else if (P.type == P.GAUGE) { gauge=0; P.enhanceNextPowerUp=true; }
    if (powerup.type == powerup.WAVE) powerup.name = "Attack Up";
    else if (powerup.type == powerup.PNTS) powerup.name = "-1000 Points";
    if (score < 0) score=0;
  }
  
  void refresh() {
    if (currentPowerUp.type==currentPowerUp.SPEED) speedMultiplier/=3;
    shield = 0;
    if (!currentPowerUp.enhanceNextPowerUp) {
      if (gauge<=0) maxGauge=1000;
      innerColor = defaultInnerColor;
      currentPowerUp = new PowerUp(0,0,0,0,0);
    }
  }
  
  
  void update() {
    super.update();
    if (health <= 0) return;
    collidedWithPlayer();
    attackBuffer--;
    if (currentPowerUp.type > 0 && gauge <= 0) refresh();
    if (attack == 0) moving();
    else charge();
  }
  
  
  void drawCharacter() {
    pushMatrix();
    pushStyle();
    translate(x,y);
    stroke(outlineColor);
    
    // Body
    fill(innerColor);
    beginShape();
    vertex(w*3/7,-h/2);
    vertex(w/2,-h/3);
    vertex(w/2,h/3);
    vertex(w*5/11,h/2);
    vertex(-w*5/11,h/2);
    vertex(-w/2,h/3);
    vertex(-w/2,-h/3);
    vertex(-w*3/7,-h/2);
    vertex(w*3/7,-h/2);
    endShape();
    
    // Eyes
    float A=PI/4, H=(1-(float)health/(float)maxHealth)*0.8;
    fill(255,(maxHealth-health)*255/maxHealth,0);
    arc(dx/2-w/4,dy/2, w/3,h/3, A-H,A+PI-H,CLOSE);
    arc(dx/2.5+w/4,dy/2, w/3,h/3, -A+H,PI-A+H,CLOSE);
    
    // Shield
    noStroke();
    fill(200,0,255,120);
    ellipse(0,0,w*shield,h*shield);
    
    popStyle();
    popMatrix();
  }
  
  
  void drawDefeated() {
    super.drawDefeated();
    if (accumulatedPoints == 0) achievements[6].obtain();
    pushStyle();
    textFont(createFont("Arial",mainFontSize,true));
    textAlign(CENTER);
    text(accumulatedPoints, x, y);
    popStyle();
  }
}