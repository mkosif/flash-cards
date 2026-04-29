import { DatabaseManager, DatabaseManagerParam, Remaining } from '../common/DatabaseManager';
import { Cards } from '../components/templates/Cards';
import WordData from '../models/WordData';
import { CustomText } from '../components/atoms/CustomText';

@Builder
function flashCardsPageBuilder() {
  FlashCardsPage()
}

@Entry
@Component
struct FlashCardsPage {
  pathStack: NavPathStack = new NavPathStack()
  @State wordDataList: WordData[] =
    [
      new WordData(0, 'das', '', '', '', false),
      new WordData(0, 'das', '', '', '', false),
      new WordData(0, 'das', '', '', '', false)
    ]
  @State databaseManager: DatabaseManager = new DatabaseManager;
  @State dataLoaded: boolean = false;
  @State initalVisibilities: boolean[] = [true, true, true];
  @State remainingCount: Remaining = { learnedCount: 0, unlearnedCount: 0 };

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Text(`${this.remainingCount.learnedCount} cards learned`)
            .fontColor(Color.White)
            .fontSize(12)
          Text(`${this.remainingCount.unlearnedCount} cards left`)
            .fontColor(Color.White)
            .fontSize(12)
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 10 })
        .justifyContent(FlexAlign.End)

        Column() {
          Button('Go back')
            .fontSize(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#444466')
            .onClick(() => {
              console.info('Go back button pressed')
              this.databaseManager.close()
              this.pathStack.pop()
            })
        }

        if (this.dataLoaded) {
          if (this.remainingCount.unlearnedCount !== 0) {
            Column() {
              Cards({
                wordDataList: $wordDataList,
                databaseManager: $databaseManager,
                visibilities: $initalVisibilities,
                remainingCount: $remainingCount
              })
              .width('100%')
              .height('100%')
            }
            .height('52%')
            .width('52%')
            .margin({ top: '22%' })
          } else {
            Column() {
              Column() {
                  CustomText('Congratulations!\nYou have learned all the words!\n🎉🎉🎉', 16, Color.White)
              }
              Button('Clear progress')
                .onClick(async () => {
                  await this.databaseManager.setAllUnlearned()
                  this.databaseManager.close()
                  this.pathStack.pop()
                })
                .backgroundColor('#FF6B35')
                .margin(5)
            }
            .height('55%')
            .width('70%')
            .margin({ top: '22%' })
            .justifyContent(FlexAlign.Center)

          }

        } else {
          Text('Loading...')
            .fontColor(Color.White)
            .fontSize(24)
        }
      }
      .height('100%')
      .width('100%')
    }
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack

      const ids: number[] | undefined = this.pathStack.getIndexByName('FlashCardsPage');
      if (ids !== undefined) {
        console.info(`ids: ${ids}`)
      }
      if (Array.isArray(ids) && ids.length > 0) {
        const idx = ids[ids.length - 1];
        this.databaseManager = (this.pathStack.getParamByIndex(idx) as DatabaseManagerParam).databaseManager;

        let list: WordData[] | null = await this.databaseManager.getRandomUnlearnedWord(3)

        if (list !== null && list.length > 0) {
          this.wordDataList[0] = list[0]
        } else {
          this.initalVisibilities[0] = false
        }

        if (list !== null && list.length > 1) {
          this.wordDataList[1] = list[1]
        } else {
          this.initalVisibilities[1] = false
        }

        if (list !== null && list.length > 2) {
          this.wordDataList[2] = list[2]
        } else {
          this.initalVisibilities[2] = false
        }

        this.dataLoaded = true;
        this.wordDataList.forEach(element => {
          console.info(`element: ${element.toString()}`)
        });

        this.remainingCount = await this.databaseManager.getWordCounts()
      } else {
        console.warn('No index found for FlashCardsPage in NavPathStack');
      }
    })
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .backgroundColor('#1A1A2E')
    .onBackPressed(() => {
        this.databaseManager.close()
        this.pathStack.pop()
        return true;
    })
  }
}
