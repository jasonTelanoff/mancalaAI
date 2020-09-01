class AI {
  final int maxMoves;
  final float playerScoreMultiplier;
  final float enemyScoreMultiplier;
  final float[] boardScoreMultiplier;

  AI(int mM, float pSM, float eSM, float[] bSM) {
    maxMoves = mM;
    playerScoreMultiplier = pSM;
    enemyScoreMultiplier = eSM;
    boardScoreMultiplier = bSM.clone();
  }

  float move(int[] b, int n, int pS, int eS, boolean pT, int m, boolean p) {
    int amount = b[n];
    b[n] = 0;

    int c = n;

    boolean moveAgain = false;

    while (amount > 0) {
      c++;

      if (c == 12) {
        if (!pT)
          if (amount > 0) {
            amount--;
            eS++;
            moveAgain = true;
          }
        c = 0;
      } else if (c == 6) {
        if (pT)
          if (amount > 0) {
            amount--;
            pS++;
            moveAgain = true;
          }
        if (amount < 0)
          b[c]++;
      } else {
        b[c]++;
        moveAgain = false;
      }
      amount--;
    }
    if (!moveAgain) {
      if (b[c] > 1)
        this.move(b.clone(), c, pS, eS, pT, m, p);
      else {
        pT = !pT;
      }
    }

    float score = 0;
    if (m < maxMoves) {
      for (int i = 0; i < 6; i++)
        if (b[i] > 0)
          score+= this.move(b.clone(), i, pS, eS, pT, m + 1, p);
      return score;
    }

    if (p) {
      score+= playerScoreMultiplier * pS;
      score-= enemyScoreMultiplier * eS;
      for (int i = 0; i < 12; i++) {
        if (b[i] > 1) score+= boardScoreMultiplier[i];
      }
    } else {
      score+= playerScoreMultiplier * eS;
      score-= enemyScoreMultiplier * pS;
      for (int i = 0; i < 12; i++) {
        if (b[i] > 1) score+= boardScoreMultiplier[i < 6?i + 6:i - 6];
      }
    }

    return score;
  }
}
