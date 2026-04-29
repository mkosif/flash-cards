import { DatabaseManager, DatabaseManagerParam } from '../common/DatabaseManager';
import WordList from '../models/WordList';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()
  ctx: Context | undefined = this.getUIContext().getHostContext()
  wordLists: WordList[] = [
    new WordList('A1 Deutsch', 'A1DeutschWortliste'),
    new WordList('A1 Deutsch Animals', 'A1DeutschTiere'),
    new WordList('A1 Deutsch Verbs', 'A1DeutschVerben'),
    new WordList('A1 English', 'A1English'),
    new WordList('A1 Spanish', 'A1Spanish'),
    new WordList('A1 French', 'A1French'),
    new WordList('A1 Turkish', 'A1Turkish'),
    new WordList('My Custom List', 'MyCustomList')
  ]
  @State selectedIndex: number = -1;

  @Builder
  MyMenu() {
    Menu() {
      ForEach(this.wordLists, (wordList: WordList, index: number) => {
        MenuItem({ content: wordList.name })
          .onChange((selected: boolean) => {
            this.selectedIndex = index
          })
      },
        (wordList: WordList, index: number) => wordList.name)
    }
  }

  build() {
    Navigation(this.pathStack) {
      Scroll() {
        Column() {

          Text('Flash Cards')
            .fontColor(Color.White)
            .fontStyle(FontStyle.Italic)
            .fontSize(28)
            .padding(10)

          Column() {
            Text(this.selectedIndex === -1 ? 'Click to select word list' : this.wordLists[this.selectedIndex].name)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .bindMenu(this.MyMenu)
          .height(30)
          .padding({left: 10, right: 10})
          .backgroundColor('#2D2D44')
          .borderRadius(15)
          .margin({ bottom: 20 })
          .justifyContent(FlexAlign.Center)

          Button('Start Learning')
            .onClick(async () => {
              if (this.selectedIndex === -1) {
                return;
              }
              let databaseManager: DatabaseManager = new DatabaseManager()
              try {
                await databaseManager.createStore(this.ctx, this.wordLists[this.selectedIndex].fileName)
                let param: DatabaseManagerParam = { databaseManager: databaseManager }
                this.pathStack.pushPathByName('FlashCardsPage', param)
              } catch (e) {
                databaseManager.close();
                console.error(`Database error: ${e}`)
              }
            })
            .width('70%')
            .margin({ bottom: 10 })
            .backgroundColor('#FF6B35')

          Button('Quick Quiz')
            .onClick(async () => {
              if (this.selectedIndex === -1) {
                  return;
              }
              let databaseManager: DatabaseManager = new DatabaseManager()
              try {
                await databaseManager.createStore(this.ctx, this.wordLists[this.selectedIndex].fileName)
                let param: DatabaseManagerParam = { databaseManager: databaseManager }
                this.pathStack.pushPathByName('QuizPage', param)
              } catch (e) {
                databaseManager.close();
                console.error(`Database error: ${e}`)
              }
            })
            .width('70%')
            .backgroundColor('#00D4AA')
            .margin({ bottom: 10 })

          Button('Add New Word')
            .onClick(async () => {
                if (this.selectedIndex === -1) {
                  this.selectedIndex = this.wordLists.length - 1;
                }
                let databaseManager: DatabaseManager = new DatabaseManager()
                try {
                  await databaseManager.createStore(this.ctx, this.wordLists[this.selectedIndex].fileName)
                  let param: DatabaseManagerParam = { databaseManager: databaseManager }
                  this.pathStack.pushPathByName('AddWordPage', param)
                } catch (e) {
                  databaseManager.close();
                  console.error(`Database error: ${e}`)
                }
            })
            .width('70%')
            .backgroundColor('#444466')

          Row() {
              Button('Stats')
                  .onClick(() => {
                      this.pathStack.pushPathByName('StatisticsPage', null)
                  })
                  .margin(10)
                  .backgroundColor('#00D4AA')

              Button('Settings')
                  .onClick(() => {
                      this.pathStack.pushPathByName('SettingsPage', null)
                  })
                  .margin(10)
                  .backgroundColor('#444466')
          }
          .margin({top: 20})
        }
        .width('100%')
        .padding({ top: 40, bottom: 40 })
      }
      .scrollBar(BarState.Off)
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .backgroundColor('#1A1A2E')
    .mode(NavigationMode.Stack)
    .parallelGesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart(() => {
          console.info('Consuming horizontal swipe to prevent back navigation')
        })
    )
  }
}
