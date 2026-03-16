import { DatabaseManager, Remaining } from '../../common/DatabaseManager';
import { LeitnerService } from '../../common/LeitnerService';
import WordData from '../../models/WordData';
import { FlashCard } from '../organisms/FlashCard';

@Component
export struct Cards {
  @Link wordDataList: WordData[];
  @Link databaseManager: DatabaseManager;
  @State data0: WordData = this.wordDataList[0]
  @State isActivate0: boolean = false
  @State @Watch('onSwiped0') swiped0: boolean = false
  @State swipeDirection0: boolean = false;
  @State data1: WordData = this.wordDataList[1]
  @State isActivate1: boolean = false
  @State @Watch('onSwiped1') swiped1: boolean = false
  @State swipeDirection1: boolean = false;
  @State data2: WordData = this.wordDataList[2]
  @State isActivate2: boolean = false
  @State @Watch('onSwiped2') swiped2: boolean = false
  @State swipeDirection2: boolean = false;
  @Link visibilities: boolean[];
  @State order: number[] = [2, 1, 0];
  @Link remainingCount: Remaining;

  async setCardAsLearnedAndGetNewData(index: number, isCorrect: boolean) {
    let word = this.wordDataList[index];
    LeitnerService.processReview(word, isCorrect);
    await this.databaseManager.updateWordProgress(
      word.id,
      word.boxLevel,
      word.nextReviewDate,
      word.reviewCount,
      word.correctCount,
      word.wrongCount,
      word.difficultyScore,
      word.lastReviewed,
      word.learned
    );

    // Update AppStorage Stats
    let totalLearned = AppStorage.get<number>('totalLearned') || 0;
    if (word.learned) {
      AppStorage.setOrCreate('totalLearned', totalLearned + 1);
    }

    let correctTotal = AppStorage.get<number>('correctTotal') || 0;
    let wrongTotal = AppStorage.get<number>('wrongTotal') || 0;
    if (isCorrect) {
      AppStorage.setOrCreate('correctTotal', correctTotal + 1);
    } else {
      AppStorage.setOrCreate('wrongTotal', wrongTotal + 1);
    }
    let accuracy = Math.floor(((correctTotal + (isCorrect ? 1 : 0)) / (correctTotal + wrongTotal + 1)) * 100);
    AppStorage.setOrCreate('accuracy', accuracy);

    // Update Streak
    const today = new Date().toISOString().split('T')[0];
    const lastDate = AppStorage.get<string>('lastStudyDate');
    let streak = AppStorage.get<number>('streak') || 0;

    if (lastDate !== today) {
      if (lastDate) {
        const last = new Date(lastDate);
        const curr = new Date(today);
        const diffDays = Math.floor((curr.getTime() - last.getTime()) / (1000 * 3600 * 24));
        if (diffDays === 1) {
          streak++;
        } else if (diffDays > 1) {
          streak = 1;
        }
      } else {
        streak = 1;
      }
      AppStorage.setOrCreate('streak', streak);
      AppStorage.setOrCreate('lastStudyDate', today);
    }

    this.remainingCount = await this.databaseManager.getWordCounts()
    const processItemAsync = async (): Promise<void> => {

      let list: WordData[] | null =
        await this.databaseManager.getRandomUnlearnedWord(1, [this.data0.id, this.data1.id, this.data2.id])
      if (list === null || list[0] === undefined) {
        console.info(`No new card!`)
        if (isCorrect) {
          this.visibilities[index] = false;
        }
        return;
      }
      console.info(`New card: ${list[0].toString()}`)
      this.wordDataList[index] = list[0]
      if (index === 0) {
        this.data0 = this.wordDataList[0]
      } else if (index === 1) {
        this.data1 = this.wordDataList[1]
      } else {
        this.data2 = this.wordDataList[2]
      }
    };
    await processItemAsync();

    console.info(`Remaining count: ${this.remainingCount.unlearnedCount}`)
  }

  onSwiped0() {
    if (this.swiped0 === true) {
      this.moveFrontCardToEnd()
      this.swiped0 = false
      this.setCardAsLearnedAndGetNewData(0, this.swipeDirection0);
    }
  }

  onSwiped1() {
    if (this.swiped1 === true) {
      this.moveFrontCardToEnd()
      this.swiped1 = false
      this.setCardAsLearnedAndGetNewData(1, this.swipeDirection1);
    }
  }

  onSwiped2() {
    if (this.swiped2 === true) {
      this.moveFrontCardToEnd()
      this.swiped2 = false
      this.setCardAsLearnedAndGetNewData(2, this.swipeDirection2);
    }
  }

  aboutToAppear(): void {
    this.activateCards()
  }

  build() {
    Stack() {
      ForEach(this.order, (index: number) => {
        if (index === 0) {
          FlashCard({
            wordData: this.data0,
            isActive: this.isActivate0,
            swiped: this.swiped0,
            swipeDirection: this.swipeDirection0
          })
            .width('100%')
            .height('100%')
            .visibility(this.visibilities[0] ? Visibility.Visible : Visibility.Hidden)
        } else if (index === 1) {
          FlashCard({
            wordData: this.data1,
            isActive: this.isActivate1,
            swiped: this.swiped1,
            swipeDirection: this.swipeDirection1
          })
            .width('100%')
            .height('100%')
            .visibility(this.visibilities[1] ? Visibility.Visible : Visibility.Hidden)
        } else {
          FlashCard({
            wordData: this.data2,
            isActive: this.isActivate2,
            swiped: this.swiped2,
            swipeDirection: this.swipeDirection2
          })
            .width('100%')
            .height('100%')
            .visibility(this.visibilities[2] ? Visibility.Visible : Visibility.Hidden)
        }
      },
        (index: number) => (this.wordDataList[index]?.id ?? index).toString())

    }
    .width('100%')
    .height('100%')
  }

  moveFrontCardToEnd(): void {
    if (this.visibilities[this.order[2]]) {
      this.order = [this.order[2], this.order[0], this.order[1]]
    }
    else {
      this.order = [this.order[1], this.order[2], this.order[0]]
    }

    this.activateCards()
  }

  activateCards(): void {
    this.isActivate0 = false
    this.isActivate1 = false
    this.isActivate2 = false

    for (let i = 2; i >= 0; i--) {
      const currentCardIndex = this.order[i];

      if (!this.visibilities[currentCardIndex]) {
        continue
      }

      if (currentCardIndex === 0) {
        this.isActivate0 = true
      } else if (currentCardIndex === 1) {
        this.isActivate1 = true
      } else {
        this.isActivate2 = true
      }

      console.info(`i: ${i}, current card index: ${currentCardIndex}`)
      break
    }
  }
}