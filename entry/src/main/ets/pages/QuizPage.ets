import { DatabaseManager, DatabaseManagerParam } from '../common/DatabaseManager';
import WordData from '../models/WordData';
import { CustomText } from '../components/atoms/CustomText';

@Builder
function quizPageBuilder() {
  QuizPage()
}

@Entry
@Component
struct QuizPage {
  pathStack: NavPathStack = new NavPathStack()
  @State databaseManager: DatabaseManager = new DatabaseManager();
  @State currentWord: WordData | null = null;
  @State options: string[] = [];
  @State score: number = 0;
  @State totalAnswered: number = 0;
  @State feedback: string = '';
  @State isAnswered: boolean = false;

  async loadQuestion() {
    this.isAnswered = false;
    this.feedback = '';
    const words = await this.databaseManager.getRandomUnlearnedWord(4);
    if (words && words.length >= 4) {
      this.currentWord = words[0];
      let opts = words.map(w => w.meaning);
      // Shuffle options
      this.options = opts.sort(() => Math.random() - 0.5);
    } else {
      this.feedback = 'Not enough words for a quiz!';
    }
  }

  handleAnswer(selected: string) {
    if (this.isAnswered || !this.currentWord) return;

    this.isAnswered = true;
    this.totalAnswered++;
    if (selected === this.currentWord.meaning) {
      this.score++;
      this.feedback = 'Correct! ✅';
    } else {
      this.feedback = `Wrong! It was: ${this.currentWord.meaning} ❌`;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text(`Score: ${this.score}/${this.totalAnswered}`)
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding(10)

        if (this.currentWord) {
          Column() {
            Column() {
                CustomText(this.currentWord.article, 14, Color.White)
            }
            Column() {
                CustomText(this.currentWord.word, 24, Color.White)
            }
            .margin({ bottom: 20 })

            ForEach(this.options, (option: string) => {
              Button(option)
                .onClick(() => this.handleAnswer(option))
                .width('80%')
                .margin({ bottom: 5 })
                .backgroundColor(this.isAnswered ? (option === this.currentWord?.meaning ? Color.Green : Color.Gray) : '#444466')
            }, (option: string) => option)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }

        Text(this.feedback)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin(10)
          .fontColor(Color.White)

        if (this.isAnswered) {
          Button('Next Question')
            .onClick(() => this.loadQuestion())
            .margin({ bottom: 20 })
        } else {
            Button('Go Back')
              .onClick(() => {
                  this.databaseManager.close()
                  this.pathStack.pop()
              })
              .margin({ bottom: 20 })
              .backgroundColor(Color.Transparent)
              .fontColor(Color.Gray)
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#1A1A2E')
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
