//================================================================================================================
//  --- character Superclass ---
//================================================================================================================
class character {
  float x, y, dx, dy, shield;
  int w, h, health, maxHealth, gauge, maxGauge, timer;
  final int maxTimer = 60;
  color outlineColor, innerColor;
  
  character(float x, float y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    maxHealth = 100;
    maxGauge = 1000;
    health = maxHealth;
    gauge = 0;
    timer = maxTimer;
  }
  
  void moveCharacter() {
    x += dx;
    y += dy;
  }
  
  void accelerate(float accX, float accY) {
    dx += accX;
    dy += accY;
  }
  
  void drawCharacter() {}
  
  void drawDefeated() { timer--; }
  
  boolean hitCharacter(character C) {
    return (C.health>0 && x+w/2 >= C.x-C.w/2 && y+h/2 >= C.y-C.h/2 && x-w/2 <= C.x+C.w/2 && y-h/2 <= C.y+C.h/2);
  }
  
  void decreaseHealth(int D) {
    if (shield > 0) return;
    health -= D;
    if (health < 0) health=0;
  }
  
  void recoverHealth(int R) {
    health += R;
    if (health > maxHealth) health=maxHealth;
  }
  
  void checkWalls() {
    if (x-w/2 > width) x=-w/2;
    if (y-h/2 > Height) y=-h/2;
    if (x+w/2 < 0) x=width+w/2;
    if (y+h/2 < 0) y=Height+h/2;
  }
  
  void maintainBars() {
    if (health <= 0) {
      dx=0;
      dy=0;
      health = 0;
    }
    if (gauge > 0) gauge--;
  }
  
  void update() {
    maintainBars();
    moveCharacter();
    checkWalls();
    if (health > 0) drawCharacter();
    else drawDefeated();
  }
}