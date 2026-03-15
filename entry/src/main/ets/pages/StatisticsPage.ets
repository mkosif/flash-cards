import { CustomText } from '../components/atoms/CustomText';

@Builder
function statisticsPageBuilder() {
  StatisticsPage()
}

@Entry
@Component
struct StatisticsPage {
  pathStack: NavPathStack = new NavPathStack()
  @State streak: number = 0;
  @State totalLearned: number = 0;
  @State accuracy: number = 0;

  aboutToAppear() {
    this.streak = AppStorage.get<number>('streak') || 0;
    // Mock values for now, would be fetched from DB in a real scenario
    this.totalLearned = 42;
    this.accuracy = 85;
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          CustomText('Learning Statistics', 24, Color.White)
        }
        .margin({ bottom: 20 })

        Column() {
          this.StatRow('Current Streak', `${this.streak} days`, '#FF6B35')
          this.StatRow('Total Learned', `${this.totalLearned} words`, '#00D4AA')
          this.StatRow('Success Rate', `${this.accuracy}%`, '#444466')
        }
        .width('100%')

        Button('Go Back')
          .onClick(() => {
            this.pathStack.pop()
          })
          .margin({ top: 30 })
          .backgroundColor('#2D2D44')
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#1A1A2E')
      .justifyContent(FlexAlign.Center)
      .padding(20)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
        this.pathStack.pop()
        return true
    })
  }

  @Builder
  StatRow(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontColor(Color.White)
        .fontSize(16)
      Blank()
      Text(value)
        .fontColor(color)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding(10)
    .margin({ bottom: 10 })
    .backgroundColor('#2D2D44')
    .borderRadius(10)
  }
}
