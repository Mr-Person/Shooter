int mainFontSize, barSize;
float starsSpeed;
PVector[] stars = new PVector[50];
String mainFont;

//================================================================================================================
//  --- DISPLAY ---
//================================================================================================================
void setupDisplay() {
  mainFontSize = width/40;
  barSize = width/6;
  starsSpeed = 1;
  for (int i=0; i<50; i++) stars[i] = new PVector((int)random(0,width),(int)random(0,height));
  mainFont = "Tahoma";
}

void drawBackground() {
  background(0);
  final int starsR = 3;
  for (int i=0; i<stars.length; i++) {
    stars[i].y+=starsSpeed;
    if (stars[i].y+starsR > height) {
      stars[i].x = (int)random(0,width);
      stars[i].y = -starsR/2;
    }
    ellipse(stars[i].x,stars[i].y,starsR,starsR);
  }
}

void drawStatusBar() {
  pushStyle();
  fill(70,70,150);
  rect(0,Height,width,SHeight);
  popStyle();
  viewStatus();
}

void displayStartText() {
  pushStyle();
  textFont(createFont(mainFont,mainFontSize*2,true));
  textAlign(CENTER);
  text("Shooter Game", width/2, Height/2);
  textFont(createFont(mainFont,mainFontSize,true));
  text("Click to start", width/2, Height/2+20);
  popStyle();
}

void displayPauseScreen() {
  background(0);
  pushStyle();
  textFont(createFont(mainFont,mainFontSize*3,true));
  textAlign(CENTER);
  text("PAUSED", width/2, Height/2);
  textFont(createFont(mainFont,mainFontSize,true));
  text("Click the screen to resume", width/2, Height/2+20);
  popStyle();
}

void displayWinText() {
  pushStyle();
  textFont(createFont(mainFont,mainFontSize*2,true));
  textAlign(CENTER);
  text("You Win!", width/2, Height/2);
  textFont(createFont(mainFont,mainFontSize,true));
  text("Click to to advance to level "+(level+1), width/2, Height/2+20);
  popStyle();
}

void displayLoseText() {
  pushStyle();
  textFont(createFont(mainFont,mainFontSize*2,true));
  textAlign(CENTER);
  text("Game Over\nYour Final Score: "+score, width/2, Height/2);
  textFont(createFont(mainFont,mainFontSize,true));
  text("Click to  play again", width/2, Height/2+80);
  popStyle();
}

void viewStatus() {
  displayScore();
  displayLevel();
  displayHealth();
  displayGauge();
  displayPowerUp();
  displayAchievements();
  displayConsecutiveHits();
}

void displayScore() {
  int X=width*49/50, Y=Height+SHeight*2/5;
  pushStyle();
  textFont(createFont(mainFont,mainFontSize,true));
  textAlign(RIGHT);
  text("Score: "+score, X, Y);
  popStyle();
}

void displayLevel() {
  int X=width*49/50, Y=Height+SHeight*4/5;
  pushStyle();
  textFont(createFont(mainFont,mainFontSize,true));
  textAlign(RIGHT);
  text("Level: "+level, X, Y);
  popStyle();
}

void displayHealth() {
  int X=width/50, Y=Height+SHeight*2/5;
  float M = mainFontSize;
  pushStyle();
  textFont(createFont(mainFont,mainFontSize,true));
  textAlign(LEFT);
  text("Health: ", X, Y);
  fill(50);
  rect(X+M*3.5, Y-M+2, barSize, M);
  fill(0,220,0);
  rect(X+M*3.5, Y-M+2, player.health*barSize/player.maxHealth, M);
  popStyle();
}

void displayGauge() {
  int X=width/50, Y=Height+SHeight*4/5;
  float M = mainFontSize;
  pushStyle();
  textFont(createFont(mainFont,mainFontSize,true));
  textAlign(LEFT);
  text("Gauge: ", X, Y);
  text(player.gauge, X, Y+barSize);
  fill(50);
  rect(X+M*3.5, Y-M+2, barSize, M);
  fill(255,180,0);
  rect(X+M*3.5, Y-M+2, player.gauge*barSize/player.maxGauge, M);
  popStyle();
}

void displayPowerUp() {
  int X=width*5/16, Y=Height+SHeight*3/7;
  pushStyle();
  textFont(createFont(mainFont,mainFontSize,true));
  textAlign(LEFT);
  text("Power-Up", X, Y);
  text(player.currentPowerUp.name, X, Y+mainFontSize*1.4);
  popStyle();
}

void displayAchievements() {
  int total=displayAchievementMessage(), X=width*6/11, Y=Height+SHeight*3/7;
  pushStyle();
  textAlign(LEFT);
  textFont(createFont(mainFont,mainFontSize,true));
  text("Achievements: "+total,X,Y);
  if (total == achievements.length) {
    fill(255,255,255-frameCount*5%155);
    text("CONGRATULATIONS!",X-mainFontSize,Y+mainFontSize*1.4);
    return;
  }
  textFont(createFont("Arial",12,true));
  for (int i=0; i<achievements.length; i++) {
    if (achievements[i].obtained) continue;
    text("Hint: "+achievements[i].hintText,X-mainFontSize,Y+mainFontSize*1.4);
    break;
  }
  popStyle();
}

int displayAchievementMessage() {
  int total = 0;
  ArrayList<Reward> streakBasket = new ArrayList<Reward>();
  for (int i=0; i<achievements.length; i++) {
    if (achievements[i].obtained) {
      achievements[i].timer--;
      total++;
    }
    if (achievements[i].timer > 0) streakBasket.add(achievements[i]);
  }
  pushStyle();
  fill(255,255,255-frameCount*5%155);
  textAlign(CENTER);
  textFont(createFont("Impact",mainFontSize*1.8,true));
  if (streakBasket.size() > 0) text("Achievement Unlocked!",width/2,30);
  textFont(createFont("Arial Black",mainFontSize*1.5,true));
  for (int i=0; i<streakBasket.size(); i++)
    text("#"+streakBasket.get(i).id+": "+streakBasket.get(i).name,width/2,30*(i+2));
  popStyle();
  return total;
}

void displayConsecutiveHits() {
  if (player.consecutiveHits < 5) return;
  int X=width*49/50, Y=Height-SHeight/5;
  pushStyle();
  textFont(createFont(mainFont,mainFontSize*1.5,true));
  textAlign(RIGHT);
  text(player.consecutiveHits+" Hits!", X, Y);
  popStyle();
}


//================================================================================================================
//  --- INPUT ---
//================================================================================================================
boolean up, down, left, right;
void keyPressed() {
  if (player.health<=0 || stagger) return;
  if (key == CODED) {
    if (keyCode == UP) up = true;
    if (keyCode == DOWN) down = true;
    if (keyCode == LEFT) left = true;
    if (keyCode == RIGHT) right = true;
  }

  if (key==' ' && player.health>0) {
    ((Player)player).fire();
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) up = false;
    if (keyCode == DOWN) down = false;
    if (keyCode == LEFT) left = false;
    if (keyCode == RIGHT) right = false;
  }
}

void mousePressed() {
  switch (state) {
    case START :
    case PAUSE :
      state = GAMEPLAY;
      break;
    case GAMEPLAY :
      state = PAUSE;
      break;
    case WIN :
      advanceLevel();
      break;
    case LOSE :
      initialize();
      break;
  }
}