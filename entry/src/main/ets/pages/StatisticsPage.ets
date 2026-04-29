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
  @State achievements: string[] = [];

  aboutToAppear() {
    this.streak = AppStorage.get<number>('streak') || 0;
    this.totalLearned = AppStorage.get<number>('totalLearned') || 0;
    this.accuracy = AppStorage.get<number>('accuracy') || 0;

    this.achievements = [];
    if (this.totalLearned >= 10) {
      this.achievements.push('🎓 Beginner');
    }
    if (this.totalLearned >= 50) {
      this.achievements.push('📜 Scholar');
    }
    if (this.streak >= 7) {
      this.achievements.push('🔥 Weekly Warrior');
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            CustomText('Learning Statistics', 24, Color.White)
          }
          .margin({ top: 20, bottom: 20 })

          Column() {
            this.StatRow('Current Streak', `${this.streak} days`, '#FF6B35')
            this.StatRow('Total Learned', `${this.totalLearned} words`, '#00D4AA')
            this.StatRow('Success Rate', `${this.accuracy}%`, '#444466')
          }
          .width('100%')

          if (this.achievements.length > 0) {
              Column() {
                  Column() {
                      CustomText('Achievements', 20, Color.White)
                  }
                  .margin({ top: 20, bottom: 10 })

                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
                      ForEach(this.achievements, (achievement: string) => {
                          Text(achievement)
                              .padding(8)
                              .margin(5)
                              .backgroundColor('#2D2D44')
                              .borderRadius(15)
                              .fontSize(14)
                              .fontColor(Color.White)
                              .border({ width: 1, color: '#444466' })
                      }, (achievement: string) => achievement)
                  }
              }
              .width('100%')
          }

          Button('Go Back')
            .onClick(() => {
              this.pathStack.pop()
            })
            .margin({ top: 30, bottom: 20 })
            .backgroundColor('#2D2D44')
        }
        .width('100%')
        .padding({ top: 40, bottom: 80 })
      }
      .scrollBar(BarState.Off)
      .parallelGesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            console.info('Consuming horizontal swipe to prevent back navigation')
          })
      )
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .hideTitleBar(true)
    .backgroundColor('#1A1A2E')
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
