class AI {
  final int maxMoves;
  final boolean player;
  float playerScoreMultiplier;
  float enemyScoreMultiplier;
  float[] boardScoreMultiplier;
  int updatedValue;
  int updatedIndex;
  float amountChanged;

  float pSMM = 0.1;
  float eSMM = 0.1;
  float[] bSMM = new float[12];

  AI(int mM, float pSM, float eSM, float[] bSM, boolean p) {
    maxMoves = mM;
    playerScoreMultiplier = pSM;
    enemyScoreMultiplier = eSM;
    boardScoreMultiplier = bSM.clone();
    player = p;

    for (int i = 0; i < bSMM.length; i++) bSMM[i] = 0.1;
  }

  float move(int[] b, int n, int pS, int eS, boolean pT, int m) {
    int amount = b[n];
    b[n] = 0;

    int c = n;

    boolean moveAgain = false;

    while (amount > 0) {
      c++;

      if (c == 12) {
        if (!pT) {
          if (amount > 0) {
            amount--;
            eS++;
            moveAgain = true;
          }
        }
        c = 0;
      } else if (c == 6) {
        if (pT) {
          if (amount > 0) {
            amount--;
            pS++;
            moveAgain = true;
          }
        }
        if (amount < 0)
          b[c]++;
      } else {
        b[c]++;
        moveAgain = false;
        amount--;
      }
    }
    if (!moveAgain) {
      if (b[c] > 1)
        this.move(b.clone(), c, pS, eS, pT, m);
      else {
        pT = !pT;
      }
    }

    float score = 0;
    if (m < maxMoves) {
      for (int i = 0; i < 6; i++)
        if (b[i] > 0)
          score+= this.move(b.clone(), i, pS, eS, pT, m + 1);
      return score;
    }


    score+= playerScoreMultiplier * eS;
    score-= enemyScoreMultiplier * pS;

    if (player) {
      for (int i = 0; i < 12; i++) {
        score+= boardScoreMultiplier[i] * b[i];
      }
    } else {
      for (int i = 0; i < 12; i++) {
        score+= boardScoreMultiplier[i < 6?i + 6:i - 6] * b[i];
      }
    }

    return score;
  }

  void updateValue() {
    updatedValue = floor(random(3));

    switch(updatedValue) {
    case 0:
      amountChanged = random(-pSMM, pSMM);
      playerScoreMultiplier+= amountChanged;
      if (pSMM > 0.01) pSMM -= 0.001;
      break;
    case 1:
      amountChanged = random(-eSMM, eSMM);
      enemyScoreMultiplier+= amountChanged;
      if (eSMM > 0.01) eSMM -= 0.001;
      break;
    case 2:
      updatedIndex = floor(random(12));
      amountChanged = random(-bSMM[updatedIndex], bSMM[updatedIndex]);
      boardScoreMultiplier[updatedIndex]+= amountChanged;
      if (bSMM[updatedIndex] > 0.01) bSMM[updatedIndex] -= 0.001;
      break;
    }
  }

  void keepUpdate(boolean won) {
    if (!won) {
      switch(updatedValue) {
      case 0:
        playerScoreMultiplier-= amountChanged/2;
        break;
      case 1:
        enemyScoreMultiplier-= amountChanged/2;
        break;
      case 2:
        boardScoreMultiplier[updatedIndex]-= amountChanged/2;
        break;
      }
    }
  }
}
