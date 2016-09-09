//================================================================================================================
//  --- Projectile Class ---
//================================================================================================================
class Projectile {
  float x, y, dx, dy;
  int w, h, type, shockWave, closestTarget;
  color outlineColor, innerColor;
  
  Projectile(float x, float y, float initX, float initY, int w, int h, int type) {
    this.x = x;
    this.y = y;
    dx = initX;
    dy = initY;
    this.w = w;
    this.h = h;
    this.type = type;
    shockWave = w*w+h*h;
    outlineColor = type>=0 ? color(200) : color(100);
    if (type >= 0) {
      if (type==player.currentPowerUp.SWEEP) innerColor=color(225);
      else if (type==player.currentPowerUp.WAVE) innerColor=color(255,120,0);
      else if (type==player.currentPowerUp.HOMING) innerColor=color(255,255,155);
      else innerColor = color(120,255,0);
    }
    else if (type == -3) innerColor=color(0,255,255);
    else innerColor=color(127,0,0);
  }
  
  void move() {
    x += dx;
    y += dy;
    moveHomingShots();
  }
  
  void moveHomingShots() {
    if (type == -2) dx=(player.x-x)*0.08;
    else if (type == player.currentPowerUp.HOMING) {
      if (boss != null) dx = (boss.x-x)*boss.speedMultiplier*0.1;
      else dx=(closestTarget<enemies.size()) ? (enemies.get(closestTarget).x-x)*0.1 : 0;
    }
  }
  
  boolean checkWalls() {
    return (x-w/2 > width || x+w/2 < 0 || y-h/2 > Height || y+h/2 < 0);
  }
  
  boolean hit(character C) {
    return (C.health>0 && x+w/2 >= C.x-C.w/2 && y+h/2 >= C.y-C.h/2 && x-w/2 <= C.x+C.w/2 && y-h/2 <= C.y+C.h/2);
  }
  
  boolean hitShield(character C) {
    if (C.health<=0 || type==player.currentPowerUp.SWEEP) return false;
    float distX=abs(C.x-x), distY=abs(C.y-y);
    if (distX > w/2 + C.w*C.shield/2 || distY > h/2 + C.h*C.shield/2) return false;
    if (distX <= w/2 || distY <= h/2) return true;
    return (pow(distX-w/2, 2) + pow(distY-h/2, 2) <= pow(C.w*C.shield/2, 2)); 
  }
  boolean hitShockWave(character C) {
    int S = shockWave;
    float distX=abs(C.x-x), distY=abs(C.y-y);
    if (distX > C.w/2 + S/2 || distY > C.h/2 + S/2) return false;
    if (distX <= C.w/2 || distY <= C.h/2) return true;
    return (pow(distX-C.w/2, 2) + pow(distY-C.h/2, 2) <= pow(S/2, 2)); 
  }
  
  void update(ArrayList<Projectile> projList, int i) {
    move();
    drawProjectile();
    if (checkWalls()) {
      if (projList==player.shots && type!=player.currentPowerUp.SWEEP) player.consecutiveHits=0; 
      projList.remove(i);
    }
  }
  
  void drawProjectile() {
    pushMatrix();
    pushStyle();
    translate(x,y);
    stroke(outlineColor);
    fill(innerColor);
    rect(-w/2,-h/2,w,h);
    popStyle();
    popMatrix();
  }
  
  void drawShockWave() {
    pushMatrix();
    pushStyle();
    translate(x,y);
    stroke(255,255,0);
    fill(255,0,0);
    ellipse(0,0,shockWave,shockWave);
    popStyle();
    popMatrix();
  }
}



//================================================================================================================
//  --- PowerUp SubClass ---
//================================================================================================================
class PowerUp extends character {
  int type;
  final int NONE=0, SPEED=1, WAVE=2, HOMING=3, SHIELD=4, PNTS=5, HEALTH=6, GAUGE=7, SWEEP=8;
  float saveAttackPosY;
  String name;
  boolean obtained, enhanceNextPowerUp;
  
  PowerUp(float x, float y, int w, int h, int type) {
    super(x,y,w,h);
    dx = random(-4,4);
    dy = random(-4,4);
    timer = maxTimer;
    this.type = type;
    outlineColor = color(255);
    switch(type) {
      case NONE : name="None"; break;
      case SPEED : name="Super Speed"; innerColor=color(100,100,255); break;
      case WAVE : name="Shockwave"; innerColor=color(255,100,100); break;
      case HOMING : name="Homing Attacks"; innerColor=color(255,255,0); break;
      case SHIELD : name="Shield"; innerColor=color(255,100,255); break;
      case PNTS : name="Extra Points"; innerColor=color(220); break;
      case HEALTH : name="Health Boost"; innerColor=color(155,255,155); break;
      case GAUGE : name="Gauge Boost"; innerColor=color(255,155,55); break;
      case SWEEP : name="Instant Sweep"; innerColor=color(0); break;
    }
  }
  
  void collided() {
    if (hitCharacter(player)) {
      hitPowerUp(player);
      if (health <= 0) {
        player.obtainPowerUp();
        return;
      }
    }
    for (int i=0; i<enemies.size(); i++) {
      BasicEnemy E = enemies.get(i);
      if (hitCharacter(E) && E.health>0) {
        hitPowerUp(E);
        if (health <= 0) E.obtainPowerUp();
      }
    }
  }
  
  void hitPowerUp(character C) {
    dx = C.dx<0 ? min(-2,C.dx*2) : max(2,C.dx*2);
    dy = C.dy<0 ? min(-2,C.dy*2) : max(2,C.dy*2);
    if (C.dx==0) dx*=-1;
    if (C.dy==0) dy*=-1;
    int D = (C instanceof BasicEnemy) ? 2 : 1;
    decreaseHealth((int)max(abs(dx),abs(dy))*D);
  }
  
  void deAccelerate() {
    if (dx < -2) dx+=0.5;
    if (dx > 2) dx-=0.5;
    if (dy < -2) dy+=0.5;
    if (dy > 2) dy-=0.5;
  }

  void obtain() {
    obtained = true;
  }

  void update() {
    super.update();
    if (health <= 0) return;
    collided();
    deAccelerate();
  }


  void drawCharacter() {
    pushMatrix();
    pushStyle();
    translate(x,y);
    
    // Body
    stroke(outlineColor);
    fill(innerColor);
    rect(-w/2,-h/2,w,h);
    
    // Icon
    switch(type) {
      case SPEED :
        fill(255,255,0);
        beginShape();
        vertex(-w/2,h/2);
        vertex(-w/4,0);
        vertex(-w/2,0);
        vertex(-w/8,-h/2);
        vertex(w/2,-h/2);
        vertex(w/8,0);
        vertex(w/2,0);
        vertex(-w/2,h/2);
        endShape();
        break;
      case WAVE :
        fill(255,0,0);
        ellipse(0,0,w*3/4,h*3/4);
        fill(255,120,0);
        ellipse(0,0,w/2,h/2);
        break;
      case HOMING :
        fill(255,120,0);
        triangle(0,-h/2, w*3/7,h/2, -w*3/7,h/2);
        fill(255,0,0);
        triangle(0,-h/2, w*3/7,0, -w*3/7,0);
        break;
      case SHIELD :
        fill(0,0,255);
        arc(0,-h/2, w*4/5,h*2, 0,PI,CLOSE);
        fill(200);
        arc(0,-h*2/5, w*3/5,h*8/5, 0,PI,CLOSE);
        break;
      case PNTS :
        stroke(120);
        strokeWeight(5);
        line(-w/4,-h/4, w/4,h/4);
        line(-w/4,h/4, w/4,-h/4);
        break;
      case HEALTH :
        stroke(0,120,0);
        strokeWeight(5);
        line(0,-h/4, 0,h/4);
        line(-w/4,0, w/4,0);
        break;
      case GAUGE :
        fill(0,0,200);
        quad(-w/2,0, 0,-h/2, w/2,0, 0,h/2);
        break;
      case SWEEP :
        stroke(255);
        strokeWeight(3);
        line(0,-h/2, w/3,h/2);
        line(w/3,h/2, -w/2,-h/6);
        line(-w/2,-h/6, w/2,-h/6);
        line(w/2,-h/6, -w/3,h/2);
        line(-w/3,h/2, 0,-h/2);
        break;
    }
    
    popStyle();
    popMatrix();
  }
  
  
  void drawDefeated() {
    super.drawDefeated();
    pushStyle();
    textFont(createFont("Arial",24,true));
    textAlign(CENTER);
    text(name, x, y);
    popStyle();
  }
}



//================================================================================================================
//  --- Reward Class ---
//================================================================================================================
class Reward {
  int timer, id;
  boolean obtained;
  String hintText, name;
  Reward(int id, String hintText, String name) {
    timer = 0;
    this.id = id;
    obtained = false;
    this.hintText = hintText;
    this.name = name;
  }
  
  void obtain() {
    if (obtained) return;
    score += 1000;
    timer = 800;
    obtained = true;
  }
}