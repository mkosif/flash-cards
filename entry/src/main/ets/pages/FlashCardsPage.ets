import { DatabaseManager, DatabaseManagerParam, Remaining } from '../common/DatabaseManager';
import { Cards } from '../components/templates/Cards';
import WordData from '../models/WordData';
import { ArcButton, ArcButtonOptions, ArcButtonPosition, ArcButtonStyleMode } from '@ohos.arkui.advanced.ArcButton';
import { LengthMetrics, LengthMetricsUnit, LengthUnit } from '@kit.ArkUI';
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
    [new WordData(0, 'das', '', '', '', false), new WordData(0, 'das', '', '', '', false),
      new WordData(0, 'das', '', '', '', false),]
  @State databaseManager: DatabaseManager = new DatabaseManager;
  @State dataLoaded: boolean = false;
  @State initalVisibilities: boolean[] = [true, true, true];
  @State remainingCount: Remaining = { learnedCount: 0, unlearnedCount: 0 };

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Text(this.remainingCount.learnedCount + ` cards learned`)
            .fontColor(Color.Black)
            .fontSize(12)
          Text(this.remainingCount.unlearnedCount + ` cards left`)
            .fontColor(Color.Black)
            .fontSize(12)
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 22 })
        .justifyContent(FlexAlign.End)

        Column() {
          ArcButton({
            options: new ArcButtonOptions({
              fontSize: { value: 12, unit: LengthUnit.PX },
              label: 'Go back',
              position: ArcButtonPosition.TOP_EDGE,
              styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
              onClick: (): void => {
                console.info('Go back button pressed')
                this.databaseManager.close()
                this.pathStack.pop()
              }
            })
          })
            .padding(0)
        }
        .height('100%')
        .width('100%')

        if (this.dataLoaded) {
          if (this.remainingCount.unlearnedCount !== 0) {
            Column() {
              Cards({
                wordDataList: this.wordDataList,
                databaseManager: this.databaseManager,
                visibilities: this.initalVisibilities,
                remainingCount: this.remainingCount
              })

            }
            .height('55%')
            .width('55%')
          } else {
            Column() {
              CustomText('Congratulations!\nYou have learned all the words!\n🎉🎉🎉', 16, Color.Black)
              Button('Clear progress')
                .onClick(async () => {
                  await this.databaseManager.setAllUnlearned()
                  this.databaseManager.close()
                  this.pathStack.pop()
                })
                .margin(5)
            }
            .height('55%')
            .width('55%')
            .justifyContent(FlexAlign.Center)

          }

        } else {
          Text('Loading...')
            .fontColor(Color.Black)
            .fontSize(24)
        }
      }
      .height('100%')
      .width('100%')
      .gesture(
          PanGesture({ direction: PanDirection.Horizontal })
              .onActionStart((event: GestureEvent) => {
                  console.info('Horizontal swipe started, consuming event to prevent back navigation')
              })
      )
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
    .backgroundColor('#fffff2ea')
    .onBackPressed(() => {
        return true;
    })
  }
}
