import { DatabaseManager, DatabaseManagerParam } from '../common/DatabaseManager';
import WordData from '../models/WordData';
import { secureRandomNumber } from '../utils/SecureRandom';

@Builder
function quizPageBuilder() {
  QuizPage()
}

@Entry
@Component
struct QuizPage {
  pathStack: NavPathStack = new NavPathStack()
  private databaseManager: DatabaseManager = new DatabaseManager();
  @State options: string[] = [];
  @State score: number = 0;
  @State totalAnswered: number = 0;
  @State feedback: string = '';
  @State isAnswered: boolean = false;
  @State currentArticle: string = '';
  @State currentWordText: string = '';
  @State correctAnswer: string = '';

  learnedWords: WordData[] = [];

  async loadQuestion() {
    this.isAnswered = false;
    this.feedback = '';
    this.options = [];
    this.currentArticle = '';
    this.currentWordText = '';
    this.correctAnswer = '';

    if (this.learnedWords.length === 0) {
      const all = await this.databaseManager.getAllWords();
      this.learnedWords = all.filter(w => w.learned);
    }

    if (this.learnedWords.length < 3) {
      this.feedback = 'Learn at least 3 words first!';
      return;
    }

    const shuffled = [...this.learnedWords].sort(() => secureRandomNumber() - 0.5);
    const picked = shuffled.slice(0, 3);
    this.currentArticle = picked[0].article;
    this.currentWordText = picked[0].word;
    this.correctAnswer = picked[0].meaning;
    this.options = picked.map(w => w.meaning).sort(() => secureRandomNumber() - 0.5);
  }

  handleAnswer(selected: string) {
    if (this.isAnswered || !this.correctAnswer) {
      return;
    }

    this.isAnswered = true;
    this.totalAnswered++;
    if (selected === this.correctAnswer) {
      this.score++;
      this.feedback = 'Correct! ✅';
    } else {
      this.feedback = `Wrong! It was: ${this.correctAnswer} ❌`;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text(`Score: ${this.score}/${this.totalAnswered}`)
          .fontSize(13)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 8 })

        if (this.currentWordText) {
          Text(this.currentArticle)
            .fontSize(13)
            .fontColor(Color.White)
          Text(this.currentWordText)
            .fontSize(20)
            .fontColor(Color.White)

          if (!this.isAnswered) {
            Column() {
              ForEach(this.options, (option: string) => {
                Button(option)
                  .onClick(() => this.handleAnswer(option))
                  .width('82%')
                  .height(34)
                  .fontSize(12)
                  .margin({ bottom: 5 })
                  .backgroundColor('#444466')
              }, (option: string) => option)
            }
            .margin({ top: 10 })
          } else {
            Text(this.feedback)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.feedback.startsWith('Correct') ? Color.Green : Color.Red)
              .textAlign(TextAlign.Center)
              .margin({ top: 12, bottom: 12 })
              .width('80%')

            Button('Next Question')
              .onClick(() => this.loadQuestion())
              .width('70%')
              .height(34)
              .fontSize(12)
              .backgroundColor('#FF6B35')
          }
        }

        Button('Go Back')
          .onClick(() => {
            this.databaseManager.close()
            this.pathStack.pop()
          })
          .margin({ top: 10 })
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Gray)
          .fontSize(12)
          .height(30)
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 30, bottom: 30, left: 15, right: 15 })
      .backgroundColor('#1A1A2E')
      .parallelGesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            console.info('Consuming horizontal swipe to prevent back navigation')
          })
      )
    }
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      const ids = this.pathStack.getIndexByName('QuizPage');
      if (Array.isArray(ids) && ids.length > 0) {
          const idx = ids[ids.length - 1];
          const param = this.pathStack.getParamByIndex(idx) as DatabaseManagerParam;
          if (param) {
              this.databaseManager = param.databaseManager;
              await this.loadQuestion();
          }
      }
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
        this.databaseManager.close()
        this.pathStack.pop()
        return true
    })
  }
}
