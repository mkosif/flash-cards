import WordData from '../models/WordData';

const LEITNER_INTERVALS = [1, 2, 4, 7, 14];

export class LeitnerService {
  static processReview(word: WordData, isCorrect: boolean): WordData {
    const now = new Date();
    word.lastReviewed = now.toISOString().split('T')[0];
    word.reviewCount++;

    if (isCorrect) {
      word.correctCount++;
      if (word.boxLevel < 5) {
        word.boxLevel++;
      }
      word.difficultyScore = Math.max(0, word.difficultyScore - 5);

      if (word.boxLevel === 5) {
          word.learned = true;
      }
    } else {
      word.wrongCount++;
      word.boxLevel = 1;
      word.difficultyScore = Math.min(100, word.difficultyScore + 10);
      word.learned = false;
    }

    const intervalDays = LEITNER_INTERVALS[word.boxLevel - 1];
    const nextDate = new Date();
    nextDate.setDate(now.getDate() + intervalDays);
    word.nextReviewDate = nextDate.toISOString().split('T')[0];

    return word;
  }

  static getBoxInterval(boxLevel: number): number {
    if (boxLevel < 1) {
      return LEITNER_INTERVALS[0];
    }
    if (boxLevel > 5) {
      return LEITNER_INTERVALS[4];
    }
    return LEITNER_INTERVALS[boxLevel - 1];
  }
}
