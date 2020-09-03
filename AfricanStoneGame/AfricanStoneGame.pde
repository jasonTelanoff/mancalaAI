boolean PLAY = true;

int[] BOARD = new int[12];

int PLAYER_SCORE = 0;
int ENEMY_SCORE = 0;

boolean PLAYER_TURN = true;

IntList BEST_MOVES = new IntList();
float BEST_SCORE = 0;
boolean FOUND_BEST = false;

int PLAYER_WINS = 0;
int ENEMY_WINS = 0;

boolean TIE;

int matchNum = 0;
int maxMatches = 1000;

float[] yes = {0.19020675, 0.34131286, 0.8384659, 0.29192147, 0.07646983, 0.9951341, -0.1844059, -0.48433787, -0.8292726, 0.39140663, -0.6933759, -0.0077023096};
float[] no = {0.19020675, 0.34131286, 0.8384659, 0.29192147, 0.07646983, 0.9951341, -0.1844059, -0.48433787, -0.8292726, 0.39140663, -0.6933759, -0.0077023096};
AI playerAI = new AI(5, 1.4962605, 1.5782617, yes.clone(), true);
AI enemyAI = new AI(5, 1.2261708, 0.76099616, no.clone(), false);

void setup() {
  size(900, 450);
  //frameRate(30);

  for (int i = 0; i < 12; i++) {
    BOARD[i] = 4;
  }

  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(height/8);
  noStroke();
}

void draw() {
  if (PLAY) showBoard();
  else {
    if (matchNum < maxMatches) {
      if (matchNum%50 == 0) {
        if (PLAYER_WINS > ENEMY_WINS + 10) {
          enemyAI.pSMM = playerAI.pSMM;
          enemyAI.eSMM = playerAI.eSMM;
          enemyAI.boardScoreMultiplier = playerAI.boardScoreMultiplier.clone();
        } else if (PLAYER_WINS + 10 < ENEMY_WINS) {
          playerAI.pSMM = enemyAI.pSMM;
          playerAI.eSMM = enemyAI.eSMM;
          playerAI.boardScoreMultiplier = enemyAI.boardScoreMultiplier.clone();
        }
      }
      playerAI.updateValue();
      enemyAI.updateValue();

      boolean pWon = performMatch();

      if (!TIE) {
        if (pWon) PLAYER_WINS++;
        else ENEMY_WINS++;
      }

      playerAI.keepUpdate(TIE?false:pWon);
      enemyAI.keepUpdate(TIE?false:!pWon);

      reset();

      matchNum++;
    } else {
      println("~~~~~~~~~~~~~~~~");
      println("Finished " + maxMatches + " matches in " + (millis()/1000) + " seconds");
      println("  avg millis/match : " + millis()/maxMatches);
      println("----------------\nPlayer\n----------------");
      println("AI amount : " + playerAI.playerScoreMultiplier);
      println("Other AI amount : " + playerAI.enemyScoreMultiplier);
      print("Board amount : ");
      for (float f : playerAI.boardScoreMultiplier) print(f + ", ");

      println();
      println("----------------\nEnemy\n----------------");
      println("AI amount : " + enemyAI.playerScoreMultiplier);
      println("Other AI amount : " + enemyAI.enemyScoreMultiplier);
      print("Board amount : ");
      for (float f : enemyAI.boardScoreMultiplier) print(f + ", ");
      stop();
    }
  }
}

void mouseClicked() {
  if (PLAY) {
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
          float score = PLAYER_TURN?
            playerAI.move(BOARD.clone(), PLAYER_TURN?i:i + 6, PLAYER_SCORE, ENEMY_SCORE, PLAYER_TURN, 0):
            enemyAI.move(BOARD.clone(), PLAYER_TURN?i:i + 6, PLAYER_SCORE, ENEMY_SCORE, PLAYER_TURN, 0);
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
}

boolean performMatch() {
  println("Starting Match " + (matchNum + 1));
  int startMillis = millis();

  boolean playerFirst = random(2) < 1;

  boolean over = false;
  while (!over) {
    performMove(playerFirst);
    over = true;
    for (int i : BOARD)
      if (i != 0)
        over = false;
  }

  println("  Finished Match in " + (millis() - startMillis) + " Milliseconds");
  println("  Winner : " + (PLAYER_SCORE == ENEMY_SCORE?"Tie":PLAYER_SCORE > ENEMY_SCORE?"Player":"Enemy"));
  println("  Player Score : " + PLAYER_SCORE);
  println("  Enemy Score : " + ENEMY_SCORE);

  if (PLAYER_SCORE == ENEMY_SCORE) TIE = true; 
  else TIE = false;
  return PLAYER_SCORE > ENEMY_SCORE;
}

void performMove(boolean playerFirst) {
  if (playerFirst) {
    playerMove();
    enemyMove();
  } else {
    enemyMove();
    playerMove();
  }
}

void playerMove() {
  while (PLAYER_TURN) {
    float bestScore = 0;
    int bestMove = 0;
    boolean foundScore = false;

    for (int i = 0; i < 6; i++) {
      if (BOARD[i] > 0) {
        float score = playerAI.move(BOARD.clone(), i, PLAYER_SCORE, ENEMY_SCORE, PLAYER_TURN, 0);

        if (score > bestScore || !foundScore) {
          bestMove = i;
          bestScore = score;
          foundScore = true;
        }
      }
    }

    if (foundScore)
      move(bestMove);
    else
      PLAYER_TURN = false;
  }
}

void enemyMove() {
  while (!PLAYER_TURN) {
    float bestScore = 0;
    int bestMove = 0;
    boolean foundScore = false;

    for (int i = 0; i < 6; i++) {
      if (BOARD[i + 6] > 0) {
        float score = enemyAI.move(BOARD.clone(), i + 6, PLAYER_SCORE, ENEMY_SCORE, PLAYER_TURN, 0);

        if (score > bestScore || !foundScore) {
          bestMove = i + 6;
          bestScore = score;
          foundScore = true;
        }
      }
    }

    if (foundScore)
      move(bestMove);
    else
      PLAYER_TURN = true;
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
        if (!PLAYER_TURN) {
          if (amount > 0) {
            amount--;
            ENEMY_SCORE++;
            moveAgain = true;
          }
        }
        c = 0;
        if (amount > 0) {
          amount--;
          BOARD[c]++;
          moveAgain = false;
        }
      } else if (c == 6) {
        if (PLAYER_TURN) {
          if (amount > 0) {
            amount--;
            PLAYER_SCORE++;
            moveAgain = true;
          }
        }
        if (amount > 0) {
          amount--;
          BOARD[c]++;
          moveAgain = false;
        }
      } else {
        BOARD[c]++;
        moveAgain = false;
        amount--;
      }
    }
    if (!moveAgain) {
      if (BOARD[c] > 1)
        move(c);
      else {
        PLAYER_TURN = !PLAYER_TURN;
      }
    }
  } else {
    println("whoopsie");
  }
}

void showBoard() {
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

void reset() {
  BOARD = new int[12];

  for (int i = 0; i < 12; i++) {
    BOARD[i] = 4;
  }

  PLAYER_SCORE = 0;
  ENEMY_SCORE = 0;

  PLAYER_TURN = true;
}
