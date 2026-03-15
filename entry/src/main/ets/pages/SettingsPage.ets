import { CustomText } from '../components/atoms/CustomText';

@Builder
function settingsPageBuilder() {
  SettingsPage()
}

@Entry
@Component
struct SettingsPage {
  pathStack: NavPathStack = new NavPathStack()
  @StorageLink('hapticEnabled') hapticEnabled: boolean = true;
  @StorageLink('dailyGoal') dailyGoal: number = 10;

  build() {
    NavDestination() {
      Column() {
        Column() {
          CustomText('Settings', 24, Color.Black)
        }
        .margin({ bottom: 20 })

        Column() {
          Row() {
            Text('Haptic Feedback')
              .fontColor(Color.Black)
              .fontSize(16)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.hapticEnabled })
              .onChange((isOn: boolean) => {
                this.hapticEnabled = isOn;
              })
          }
          .width('100%')
          .padding(10)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .margin({ bottom: 10 })
          .border({width: 1, color: Color.Black})

          Row() {
            Text('Daily Goal')
              .fontColor(Color.Black)
              .fontSize(16)
            Blank()
            Counter() {
                Text(this.dailyGoal.toString()).fontColor(Color.Black)
            }
            .onInc(() => { this.dailyGoal++ })
            .onDec(() => { this.dailyGoal = Math.max(1, this.dailyGoal - 1) })
          }
          .width('100%')
          .padding(10)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .border({width: 1, color: Color.Black})
        }
        .width('100%')

        Button('Go Back')
          .onClick(() => {
            this.pathStack.pop()
          })
          .margin({ top: 30 })
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#fffff2ea')
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
}
