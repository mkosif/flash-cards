import { DatabaseManager, DatabaseManagerParam } from '../common/DatabaseManager';
import WordData from '../models/WordData';
import { CustomText } from '../components/atoms/CustomText';

@Builder
function addWordPageBuilder() {
  AddWordPage()
}

@Entry
@Component
struct AddWordPage {
  pathStack: NavPathStack = new NavPathStack()
  @State databaseManager: DatabaseManager = new DatabaseManager();
  @State article: string = '';
  @State word: string = '';
  @State meaning: string = '';
  @State example: string = '';
  @State feedback: string = '';

  async handleSave() {
    if (!this.word || !this.meaning) {
      this.feedback = 'Word and Meaning are required!';
      return;
    }

    const newEntry = new WordData(0, this.article, this.word, this.meaning, this.example, false);
    try {
      await this.databaseManager.insertWord(newEntry);
      this.feedback = 'Word saved successfully! ✅';
      this.article = '';
      this.word = '';
      this.meaning = '';
      this.example = '';
    } catch (e) {
      this.feedback = 'Failed to save word. ❌';
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
              CustomText('Add New Word', 24, Color.White)
          }
          .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: 'Article (der/die/das)', text: this.article })
            .onChange((v) => this.article = v)
            .margin({ bottom: 10 })
            .width('90%')
            .fontColor(Color.White)
            .placeholderColor(Color.Gray)
            .backgroundColor('#2D2D44')

          TextInput({ placeholder: 'Word', text: this.word })
            .onChange((v) => this.word = v)
            .margin({ bottom: 10 })
            .width('90%')
            .fontColor(Color.White)
            .placeholderColor(Color.Gray)
            .backgroundColor('#2D2D44')

          TextInput({ placeholder: 'Meaning', text: this.meaning })
            .onChange((v) => this.meaning = v)
            .margin({ bottom: 10 })
            .width('90%')
            .fontColor(Color.White)
            .placeholderColor(Color.Gray)
            .backgroundColor('#2D2D44')

          TextInput({ placeholder: 'Example Sentence', text: this.example })
            .onChange((v) => this.example = v)
            .margin({ bottom: 20 })
            .width('90%')
            .fontColor(Color.White)
            .placeholderColor(Color.Gray)
            .backgroundColor('#2D2D44')

          Button('Save Word')
            .onClick(() => this.handleSave())
            .width('80%')
            .backgroundColor('#FF6B35')

          Text(this.feedback)
            .margin(10)
            .fontColor(Color.White)

          Button('Go Back')
            .onClick(() => {
                this.databaseManager.close()
                this.pathStack.pop()
            })
            .backgroundColor(Color.Transparent)
            .fontColor(Color.Gray)
            .margin({ top: 10 })
        }
        .width('100%')
        .padding({ top: 40, bottom: 40 })
      }
      .scrollBar(BarState.Off)
      .parallelGesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            console.info('Consuming horizontal swipe to prevent back navigation')
          })
      )
    }
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      const ids = this.pathStack.getIndexByName('AddWordPage');
      if (Array.isArray(ids) && ids.length > 0) {
          const idx = ids[ids.length - 1];
          const param = this.pathStack.getParamByIndex(idx) as DatabaseManagerParam;
          if (param) {
              this.databaseManager = param.databaseManager;
          }
      }
    })
    .hideTitleBar(true)
    .backgroundColor('#1A1A2E')
    .onBackPressed(() => {
        this.databaseManager.close()
        this.pathStack.pop()
        return true
    })
  }
}
