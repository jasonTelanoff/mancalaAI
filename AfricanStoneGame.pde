int[] BOARD = new int[12];

int PLAYER_SCORE = 0;
int ENEMY_SCORE = 0;

boolean PLAYER_TURN = true;

IntList BEST_MOVES = new IntList();
float BEST_SCORE = 0;
boolean FOUND_BEST = false;

float[] yes = {.2, .225, .25, .3, .25, .225, -.175, -.2, -.225, -.25, -.225, -.2};
AI ai = new AI(5, 0.8, 1, yes);

void setup() {
  size(900, 450);
  frameRate(30);

  for (int i = 0; i < 12; i++) {
    BOARD[i] = 4;
  }

  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(height/8);
  noStroke();
}

void draw() {
  background(50);
  if (PLAYER_TURN)fill(0, 255, 0); 
  else fill(255, 0, 0);

  rect(width/40, height/40, width/20, height/20);

  for (int i = 0; i < 6; i++) {
    fill(255, 0, 0);
    if (!PLAYER_TURN)
      for (int _i = 0; _i < BEST_MOVES.size(); _i++) {
        if (BEST_MOVES.get(_i) == 5 - i) {
          fill(0, 0, 255);
          break;
        }
      }
    rect(width/4 + i * width/8, height/4, width/12, height/4);
    fill(255);
    text(BOARD[11 - i], width/4 + i * width/8, height/4);
    text(6 - i, width/4 + i * width/8, height/16);
  }

  for (int i = 0; i < 6; i++) {
    fill(0, 255, 0);
    if (PLAYER_TURN)
      for (int _i = 0; _i < BEST_MOVES.size(); _i++) {
        if (BEST_MOVES.get(_i) == i) {
          fill(0, 0, 255);
          break;
        }
      }
    rect(width/8 + i * width/8, 3*height/4, width/12, height/4);
    fill(255);
    text(BOARD[i], width/8 + i * width/8, 3*height/4);
    text(i + 1, width/8 + i * width/8, 15*height/16);
  }

  fill(255);
  text(ENEMY_SCORE, width/8, height/4);
  text(PLAYER_SCORE, 7*width/8, 3*height/4);

  for (int i = 0; i < BEST_MOVES.size(); i++)
    text(BEST_MOVES.get(i) + 1, i*width/16 + width/16, height/2);
  text(BEST_SCORE, width/2, height/2);

  fill(0, 0, 255);
  rect(width*.9, height/2, width/8, height/6);
}

void mouseClicked() {
  if (!PLAYER_TURN && mouseY > height/8 && mouseY < 3*height/8) {
    for (int i = 0; i < 6; i++) {
      if (mouseX > width/4 + i * width/8 - width/24 &&
        mouseX < width/4 + i * width/8 + width/24) {
        move(11 - i);
        BEST_MOVES.clear();
        BEST_SCORE = 0;
        return;
      }
    }
  } else if (PLAYER_TURN && mouseY > 5*height/8 && mouseY < 7*height/8) {
    for (int i = 0; i < 6; i++) {
      if (mouseX > width/8 + i * width/8 - width/24 &&
        mouseX < width/8 + i * width/8 + width/24) {
        move(i);
        BEST_MOVES.clear();
        BEST_SCORE = 0;
        return;
      }
    }
  } else if (mouseX > width*.9 - width/16 && 
    mouseX < width*.9 + width/16 && 
    mouseY > height/2 - height/12 && 
    mouseY < height/2 + height/12) {
    int startMillis = millis();
    println("Started Caluculating");
    for (int i = 0; i < 6; i++) {
      if (BOARD[PLAYER_TURN?i:i + 6] > 0) {
        float score = ai.move(BOARD.clone(), PLAYER_TURN?i:i + 6, PLAYER_SCORE, ENEMY_SCORE, PLAYER_TURN, 0, PLAYER_TURN);
        println("  Score for " + (i + 1) + " : " + score);

        if (score > BEST_SCORE || !FOUND_BEST) {
          BEST_MOVES.clear();
          BEST_MOVES.append(i);
          BEST_SCORE = score;
          FOUND_BEST = true;
        } else if (score == BEST_SCORE) {
          BEST_MOVES.append(i);
        }
      }
    }

    FOUND_BEST = false;
    println("Finished Calculating in " + (millis() - startMillis) + " Milliseconds");
  }
}

void move(int n) {
  int amount = BOARD[n];
  if (amount > 0) {
    BOARD[n] = 0;

    int c = n;

    boolean moveAgain = false;

    while (amount > 0) {
      c++;

      if (c == 12) {
        if (!PLAYER_TURN)
          if (amount > 0) {
            amount--;
            ENEMY_SCORE++;
            moveAgain = true;
          }
        c = 0;
        if (amount > 0) {
          amount--;
          BOARD[c]++;
          moveAgain = false;
        }
      } else if (c == 6) {
        if (PLAYER_TURN)
          if (amount > 0) {
            amount--;
            PLAYER_SCORE++;
            moveAgain = true;
          }
        if (amount > 0) {
          amount--;
          BOARD[c]++;
          moveAgain = false;
        }
      } else {
        BOARD[c]++;
        moveAgain = false;
      }
      amount--;
    }
    if (!moveAgain) {
      if (BOARD[c] > 1)
        move(c);
      else 
      PLAYER_TURN = !PLAYER_TURN;
    }
  }
}
