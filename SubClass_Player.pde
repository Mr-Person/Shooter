class Player extends character {
  int idleTime, fireBufferTime, consecutiveHits;
  float speed, maxAccel, scoreMultiplier;
  boolean beenHit, hitTarget;
  final color defaultInnerColor = color(0,0,255);
  ArrayList<Projectile> shots = new ArrayList<Projectile>();
  PowerUp currentPowerUp;
  
  Player(float x, float y, int w, int h) {
    super(x,y,w,h);
    timer = maxTimer*2;
    speed = 1;
    maxAccel = 8;
    scoreMultiplier = 1;
    outlineColor = color(255);
    innerColor = defaultInnerColor;
    currentPowerUp = new PowerUp(0,0,0,0,0);
  }
  
  void idle() {
    if (up || down ||left || right || stagger) {
      idleTime = 0;
      return;
    }
    if (dx < 0) dx++;
    if (dy < 0) dy++;
    if (dx > 0) dx--;
    if (dy > 0) dy--;
    idleTime++;
    if (idleTime >= 60*60*3) achievements[7].obtain();
  }
  void moveCharacter() {
    if (up) accelerate(0,-speed);
    if (down) accelerate(0,speed);
    if (left) accelerate(-speed,0);
    if (right) accelerate(speed,0);
    idle();
    if (abs(dx) > maxAccel) dx = dx<0 ? -maxAccel : maxAccel;
    if (abs(dy) > maxAccel) dy = dy<0 ? -maxAccel : maxAccel;
    super.moveCharacter();
  }
  
  void fire() {
    if (fireBufferTime > 0) return;
    int shotWidth=height/70, shotHeight=height/50;
    shots.add(new Projectile(x,y-shotHeight, 0,-15, shotWidth,shotHeight, currentPowerUp.type));
    fireBufferTime = 20;
    if (currentPowerUp.type==currentPowerUp.HOMING) {
      Projectile S = shots.get(shots.size()-1);
      for (int i=1; i<enemies.size(); i++) {
        boolean closerThanClosest = abs(enemies.get(i).x-x) < abs(enemies.get(S.closestTarget).x-x);
        if (closerThanClosest && enemies.get(i).health>0) S.closestTarget=i;
      }
    }
  }

  void EnemyHit(BasicEnemy E, Projectile S) {
    hitTarget = true;
    int damage = max((int)(E.w*1.8-abs(S.x-E.x)),0);
    E.accumulatedPoints += damage*0.5*scoreMultiplier+10*player.consecutiveHits;
    E.decreaseHealth(damage);
    if (E.health<=0) {
      score+=E.accumulatedPoints;
      if (abs(S.x-E.x)<=1) achievements[2].obtain();
    }
  }
  void BossHit(BossEnemy B, Projectile S) {
    hitTarget = true;
    int damage = max((int)(B.w-abs(S.x-B.x)),0);
    score += damage*0.25*scoreMultiplier+5*player.consecutiveHits;
    B.decreaseHealth(damage);
    if (B.health <= 0) {
      if (abs(S.x-B.x)<=1) achievements[2].obtain();
      if (player.health <= player.maxHealth/10) achievements[4].obtain();
      score += level*1000;
    }
  }
  void PowerUpHit(PowerUp P, Projectile S) {
    hitTarget = true;
    if (P.obtained) return;
    P.decreaseHealth((int)(max(P.w*1.5-abs(S.x-P.x),0)));
    P.dx = (powerup.x - S.x)*0.1;
    P.dy = (powerup.y - S.y)*0.3;
    if (P.health <= 0) obtainPowerUp();
  }

  void deflectShot(character C, Projectile S) {
    S.type = -1;
    S.innerColor = color(255,0,0);
    S.dy *= -1.5;
    S.dx = (S.x-C.x)*0.3;
  }
  
  void checkProjectiles() {
    hitTarget = false;
    for (int i=0; i<shots.size(); i++) {
      Projectile S = shots.get(i);
      for (int j=0; j<enemies.size(); j++)  {
        BasicEnemy E = enemies.get(j);
        if (S.hit(E)) EnemyHit(E,S);
        else if (S.hitShield(E)) deflectShot(E,S);
      }
      if (boss != null && S.hit(boss)) BossHit(boss,S);
      else if (boss != null && S.hitShield(boss)) deflectShot(boss,S);
      if (powerup != null && S.hit(powerup)) PowerUpHit(powerup,S);
      if (hitTarget && S.type!=currentPowerUp.SWEEP) {
        consecutiveHits++;
        if (consecutiveHits >= 15) achievements[0].obtain();
      }
      if (S.type==-1 && S.hit(player) && player.shield<=0) player.decreaseHealth(30);
      if (hitTarget && S.type != currentPowerUp.SWEEP) {
        if (currentPowerUp.type == currentPowerUp.WAVE) {
          for (int j=0; j<enemies.size(); j++) if (S.hitShockWave(enemies.get(j))) EnemyHit(enemies.get(j),S);
          if (boss!=null && S.hitShockWave(boss)) BossHit(boss,S);
          if (powerup!=null && S.hitShockWave(powerup)) PowerUpHit(powerup,S);
          S.drawShockWave();
        }
        shots.remove(i);
      }
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
    return (P.type==P.HEALTH || P.type==P.SWEEP);
  }
  
  void applyPowerUpEffect(PowerUp P) {
    if (P.type == P.SPEED) {
      for (int i=0; i<enemies.size(); i++)
        if (enemies.get(i).speedMultiplier>=1) enemies.get(i).speedMultiplier/=3;
      if (boss!=null && boss.speedMultiplier>=1) boss.speedMultiplier/=3;
      starsSpeed /= 3;
    }
    else if (P.type == P.SHIELD) shield=2;
    else if (P.type == P.PNTS) scoreMultiplier=2.5;
    else if (P.type == P.HEALTH) recoverHealth(maxHealth);
    else if (P.type == P.GAUGE) { gauge=0; P.enhanceNextPowerUp=true; }
    else if (P.type == P.SWEEP) {
      achievements[5].obtain();
      for (int i=0; i<360; i++)
        shots.add(new Projectile(x,y, cos(i*PI/180),sin(i*PI/180), width/8,Height/8,P.type));
    }
  }
  
  void refresh() {
    if (currentPowerUp.type==currentPowerUp.SPEED) {
      for (int i=0; i<enemies.size(); i++) enemies.get(i).speedMultiplier*=3;
      if (boss!=null) boss.speedMultiplier*=3;
      starsSpeed *= 3;
    }
    shield = 0;
    scoreMultiplier = 1;
    if (!currentPowerUp.enhanceNextPowerUp) {
      if (gauge<=0) maxGauge=1000;
      innerColor = defaultInnerColor;
      currentPowerUp = new PowerUp(0,0,0,0,0);
    }
  }
  
  void decreaseHealth(int D) {
    super.decreaseHealth(D);
    beenHit = true;
  }
  
  void update() {
    super.update();
    fireBufferTime--;
    checkProjectiles();
    if (currentPowerUp.type > 0 && gauge <= 0) refresh();
    for (int i=0; i<shots.size(); i++) shots.get(i).update(shots,i);
  }
  
  
  void drawCharacter() {
    pushMatrix();
    pushStyle();
    translate(x,y);
    stroke(outlineColor);
    
    // Wings
    fill(0,0,100);
    beginShape();
    vertex(0,-h/2);
    vertex(w/3,-h*3/7);
    vertex(w/2,h/6);
    vertex(0,h/2);
    vertex(-w/2,h/6);
    vertex(-w/3,-h*3/7);
    vertex(0,-h/2);
    endShape();
    
    // Body
    fill(innerColor);
    beginShape();
    vertex(0,-h/2);
    vertex(w/3,-h*3/7);
    vertex(w*4/9,h/2);
    vertex(0,h*3/7);
    vertex(-w*4/9,h/2);
    vertex(-w/3,-h*3/7);
    vertex(0,-h/2);
    endShape();
    
    // Window
    fill(120,120);
    ellipse(0,-h/10,w/3,-h/2);
    
    // Shield
    noStroke();
    fill(200,0,255,120);
    ellipse(0,0,w*shield,h*shield);
    
    popStyle();
    popMatrix();
  }
  
  void drawDefeated() {
    super.drawDefeated();
    pushMatrix();
    pushStyle();
    translate(x,y);
    noStroke();
    
    // Body
    int size = floor((float)((timer > maxTimer ? maxTimer*2-timer : timer)*0.1))*8;
    fill(255,220,150);
    pushMatrix();
    for (int i=0; i<4; i++) {
      quad(0,-size/2, size,0, 0,size/2, -size,0);
      rotate(PI/4);
    }
    popMatrix();
    fill(255,0,0);
    pushMatrix();
    for (int i=0; i<4; i++) {
      quad(0,-size/4, size/2,0, 0,size/4, -size/2,0);
      rotate(PI/4);
    }
    popMatrix();
    
    // Text
    stroke(0);
    strokeWeight(2);
    fill(255);
    textFont(createFont("Arial Black",mainFontSize*1.5,true));
    textAlign(CENTER);
    text("BOOM", 0, 0);
    
    popStyle();
    popMatrix();
  }
}