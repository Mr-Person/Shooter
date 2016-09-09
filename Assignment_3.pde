//================================================================================================================
//  --- INITIALIZE GLOBAL VARIABLES ---
//================================================================================================================
int Height, SHeight, state, score, level, time, numberOfEnemies;
final int START=0, GAMEPLAY=1, PAUSE=2, WIN=3, LOSE=4, totalAchievements=10;
boolean stagger;
Player player;
BossEnemy boss;
PowerUp powerup;
ArrayList<BasicEnemy> enemies;
Reward[] achievements;


//================================================================================================================
//  --- FUNCTION DECLARATIONS ---
//================================================================================================================
void initialize() {
  Height = height*11/12;
  SHeight = height-Height;
  state = START;
  score = 0;
  level = 1;
  time = 0;
  numberOfEnemies = 4 + 2*level;
  stagger = false;
  player = new Player(width/2, Height*7/8, height/20, height/20);
  boss = null;
  powerup = null;
  setupEnemies();
  setupAchievements();
  setupDisplay();
}

void advanceLevel() {
  state = GAMEPLAY;
  level++;
  time = 0;
  numberOfEnemies += 2;
  player.recoverHealth(player.maxHealth/2);
  int saveHealth=player.health, saveHits=player.consecutiveHits;
  player = new Player(width/2, Height*7/8, height/20, height/20);
  player.health = saveHealth;
  player.consecutiveHits = saveHits;
  powerup = null;
  setupEnemies();
}

void setupEnemies() {
  enemies = new ArrayList<BasicEnemy>();
  for (int i=0; i<numberOfEnemies; i++) {
    float X = (i+1)*width/(numberOfEnemies+1);
    float Y = random(Height/20,Height/5);
    int S = height/20;
    enemies.add(new BasicEnemy(X, Y, S, S));
  }
}

void setupAchievements() {
  achievements = new Reward[totalAchievements];
  achievements[0] = new Reward(1,"Keep hitting, don't miss","Accurate Streak");
  achievements[1] = new Reward(2,"Defeat them all quickly","Speedrunner");
  achievements[2] = new Reward(3,"Finishing hit at the center","Critical Hit");
  achievements[3] = new Reward(4,"Dodge the enemies","Flawless Battle");
  achievements[4] = new Reward(5,"Defeat the boss at low health","Close Call");
  achievements[5] = new Reward(6,"Collect the rare power-up","Instant Sweep");
  achievements[6] = new Reward(7,"Only attack using a shield","Zero Points");
  achievements[7] = new Reward(8,"Idle in the midst of chaos","Break Time");
  achievements[8] = new Reward(9,"Get through 15 levels","Survivor");
  achievements[9] = new Reward(10,"Give it your best","ULTRA-POWER!");
}

void showStartScreen() {
  displayStartText();
}

void gamePlay() {
  time++;
  updateCharacters();
  checkCharacterPresence();
  drawStatusBar();
}

void pause() {
  displayPauseScreen();
}

void showWinScreen() {
  starsSpeed = 1;
  endOfLevelAchievements();
  displayWinText();
}

void showLoseScreen() {
  starsSpeed = 1;
  displayLoseText();
}

void endOfLevelAchievements() {
  Player P = player;
  if (time <= 60*(10+5*level)) achievements[1].obtain();
  if (!P.beenHit && level>=3) achievements[3].obtain();
  if (level >= 15) achievements[8].obtain();
  if (level >= 20 && P.consecutiveHits>=25 && P.health>=P.maxHealth*4/5) achievements[9].obtain();
  displayAchievementMessage();
}

void updateCharacters() {
  player.update();
  if (powerup != null) powerup.update();
  if (boss != null) boss.update();
  for (int i=0; i<enemies.size(); i++) {
    enemies.get(i).update();
    if (enemies.get(i).timer==0) enemies.remove(i);
  }
}

void checkCharacterPresence() {
  if (player.timer == 0) state=LOSE;
  if (enemies.size() == 0) {
    if (level % 3 != 0) state=WIN;
    else if (boss == null) {
      while (player.shots.size() > 0) player.shots.remove(0);
      stagger = true;
      boss = new BossEnemy(width/2,-height/8,height/8,height/8);
    }
    else if (stagger) spawnBoss(Height/7);
    else if (boss.timer == 0) {
      boss = null;
      state = WIN;
    }
  }
  if (powerup == null && time % max(500-level*10,100) == 0) {
    int newType = (random(200)<1) ? 8 : (int)random(1,8);
    powerup = new PowerUp(random(0,width),random(0,Height),height/30,height/30,newType);
  } else if (powerup!=null && powerup.timer<=0) powerup=null;
}

void spawnBoss(float setY) {
  boss.dx = time%2==0 ? -2 : 2;
  boss.dy = 0.5;
  player.dx = 0;
  player.dy = (player.y <= setY+boss.h*2) ? 0.5 : 0;
  if (boss.y > setY) {
    player.dy = 0;
    boss.y = setY;
    boss.gauge = 150;
    boss.attackBuffer = 100;
    stagger=false;
  }
}


//================================================================================================================
//  --- MAIN EXECUTION ---
//================================================================================================================
void setup() {
  frameRate(60);
  size(600,650);
  initialize();
}

void draw() {
  drawBackground();
  switch(state) {
    case START : showStartScreen(); break;
    case GAMEPLAY : gamePlay(); break;
    case PAUSE : pause(); break;
    case WIN : showWinScreen(); break;
    case LOSE : showLoseScreen(); break;
  }
}