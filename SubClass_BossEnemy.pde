class BossEnemy extends character {
  int attack, attackBuffer;
  float speedMultiplier, saveChargeSpeedX, saveChargeSpeedY, saveChargePosY, chargeTime;
  final float mainSpeed = min(level*0.5,15);
  boolean goingLeft;
  ArrayList<Projectile> shots = new ArrayList<Projectile>();
  
  BossEnemy(float x, float y, int w, int h) {
    super(x,y,w,h);
    timer = maxTimer*3;
    outlineColor = color(120);
    innerColor = color(200);
    maxHealth = 500;
    maxGauge = 1500+min(level*5,2000);
    health = maxHealth;
    boolean S = player.currentPowerUp.type==player.currentPowerUp.SPEED;
    speedMultiplier = S ? 0.33 : 1;
    goingLeft = ((int)random(0,2)==1) ? true : false;
  }
  
  
  //////////////////////////////////////////////////////////////
  ////////////////////////////////// BOSS ATTACKS
  void homingFire() {
    attackBuffer = 200;
    int shotSize = height/12;
    shots.add(new Projectile(x,y+h/2, 0,6, shotSize,shotSize,-2));
  }
  void quintFire() {
    int shotSize = height/25;
    for (int i=0; i<5; i++) {
      float dX = 5*(i-2)*speedMultiplier;
      float dY = (12-abs(i-2)*3)*speedMultiplier;
      shots.add(new Projectile(x,y+h/2, dX,dY, shotSize,shotSize,-1));
    }
  }
  void charge() {
    chargeTime++;
    dx = cos(chargeTime*PI/180)*speedMultiplier*saveChargeSpeedX*(attack==1 ? 1 : -1);
    dy = sin(chargeTime*PI/180)*speedMultiplier*saveChargeSpeedY;
    if (y<=saveChargePosY+h && y>=saveChargePosY-h && chargeTime >= 360) {
      dx = mainSpeed;
      y = saveChargePosY;
      attack = 0;
      attackBuffer = 300;
      chargeTime = 0;
    }
  }
  void backSweep() {
    attackBuffer = 100;
    for (float i=0; i<10; i++) {
      int sizeX=(int)random(w/2,w), sizeY=(int)random(h/2,h);
      float dX = cos(PI*i/5)*10*speedMultiplier;
      float dY = -sin(PI*i/5)*speedMultiplier;
      shots.add(new Projectile(x+dX*w/10,y+dY*h, dX,dY, sizeX,sizeY,-3));
    }
  }
  ////////////////////////////////// BOSS ATTACKS
  //////////////////////////////////////////////////////////////
  
  
  void checkProjectiles() {
    for (int i=0; i<shots.size(); i++) {
      Projectile S = shots.get(i);
      if (S.hit(player)) {
         if (S.hitShield(player)) player.health++;
         switch(S.type) {
           case -1 : player.decreaseHealth((int)random(5,10)); break;
           case -2 : player.decreaseHealth((int)random(15,26)); break;
           case -3 : player.decreaseHealth((int)random(30,41)); break;
         }
         shots.remove(i);
      }
    }
  }

  void collidedWithPlayer() {
    if (hitCharacter(player)) {
      if (player.shield > 0 && time % 5 == 0) decreaseHealth(1);
      else if (player.shield <= 0) player.decreaseHealth(5);
    }
  }
  
  void moving() {
    dx = goingLeft ? max(-mainSpeed*speedMultiplier,-15) : min(mainSpeed*speedMultiplier,15);
    if (goingLeft && x-w/2 < 0) goingLeft=false;
    if (!goingLeft && x+w/2 > width) goingLeft=true;
    dy = 0;
    float freq = min(150,level*4+(maxHealth-health)*0.1);
    if (attackBuffer <= 0) {
      if ((int)random(1500) == 0) {
        attack = (int)random(1,3);
        saveChargeSpeedX = random(3,7);
        saveChargeSpeedY = random(3,7);
        saveChargePosY = y;
      }
      if (player.y <= y+h/2) backSweep();
      if ((int)random(300-freq)==0) homingFire();
    }
    if ((int)random(200-freq)==0) quintFire();
  }
  
  void checkWalls() {
    if (stagger) return;
    super.checkWalls();
  }
  
  void update() {
    super.update();
    collidedWithPlayer();
    checkProjectiles();
    for (int i=0; i<shots.size(); i++) shots.get(i).update(shots,i);
    if (health <= 0 || stagger) return;
    shield = gauge >= 500-min(10*level,100) ? 1.6 : 0;
    if (gauge <= 0) gauge=maxGauge;
    attackBuffer--;
    if (attack == 0) moving();
    else charge();
  }


  void drawCharacter() {
    pushMatrix();
    pushStyle();
    translate(x,y);
    stroke(outlineColor);
    
    // Wings
    fill(0,0,100);
    beginShape();
    vertex(0,h/2);
    vertex(w*3/11,h*3/10);
    vertex(w/2,h/6);
    vertex(w/2,-h/3);
    vertex(0,-h*3/7);
    vertex(-w/2,-h/3);
    vertex(-w/2,h/6);
    vertex(-w*3/11,h*3/10);
    vertex(0,h/2);
    endShape();
    
    // Body
    fill(innerColor);
    beginShape();
    vertex(0,h/2);
    vertex(w/4,h/3);
    vertex(w/3,-h*2/5);
    vertex(0,-h/2);
    vertex(-w/3,-h*2/5);
    vertex(-w/4,h/3);
    vertex(0,h/2);
    endShape();
    
    // Window
    fill(0,120);
    quad(0,h*2/5, w/6,h/5, 0,-h/10, -w/6,h/5);
    
    // HP Bar
    strokeWeight(1);
    fill(50);
    rect(-w/2-20,-h/2-25, w+40, 10);
    fill(0,220,0);
    rect(-w/2-20,-h/2-25, health*(w+40)/maxHealth, 10);
    
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
    fill(red(innerColor),green(innerColor),blue(innerColor),timer*255/(maxTimer*3));
    beginShape();
    vertex(0,h/2);
    vertex(w/4,h/3);
    vertex(w/3,-h*2/5);
    vertex(0,-h/2);
    vertex(-w/3,-h*2/5);
    vertex(-w/4,h/3);
    vertex(0,h/2);
    endShape();
    
    // Window
    fill(0,timer*120/(maxTimer*3));
    quad(0,h*2/5, w/6,h/5, 0,-h/10, -w/6,h/5);
    
    // Explosion
    int size = floor((float)((timer > maxTimer*1.5 ? maxTimer*3-timer : timer)*0.1))*8;
    fill(255,220,150,150);
    pushMatrix();
    for (int i=0; i<4; i++) {
      quad(0,-size/2, size,0, 0,size/2, -size,0);
      rotate(PI/4);
    }
    popMatrix();
    fill(255,0,0,100);
    pushMatrix();
    for (int i=0; i<4; i++) {
      quad(0,-size/4, size/2,0, 0,size/4, -size/2,0);
      rotate(PI/4);
    }
    popMatrix();

    // Score Text
    if (maxTimer*3-timer<60) {
      fill(255);
      textFont(createFont("Arial Black",mainFontSize*1.5,true));
      textAlign(CENTER);
      text(level*1000, 0, timer-maxTimer*3);
    }
    
    popStyle();
    popMatrix();
  }
}