import { CustomText } from '../components/atoms/CustomText';
import { notificationManager } from '@kit.NotificationKit';

@Builder
function settingsPageBuilder() {
  SettingsPage()
}

@Entry
@Component
struct SettingsPage {
  pathStack: NavPathStack = new NavPathStack()
  @StorageLink('hapticEnabled') hapticEnabled: boolean = true;
  @StorageLink('remindersEnabled') remindersEnabled: boolean = false;
  @StorageLink('dailyGoal') dailyGoal: number = 10;

  async toggleReminders(isOn: boolean) {
    this.remindersEnabled = isOn;
    if (isOn) {
      try {
        const request: notificationManager.NotificationRequest = {
          id: 1,
          content: {
            contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
            normal: {
              title: 'Time to study!',
              text: 'Dont forget to review your flash cards today.',
              additionalText: 'Keep your streak alive!'
            }
          },
          deliveryTime: new Date().getTime() + 5000 // Test reminder in 5 seconds
        };
        await notificationManager.publish(request);
        console.info('Notification published');
      } catch (e) {
        console.error('Notification failed: ' + JSON.stringify(e));
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          CustomText('Settings', 24)
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
            Text('Study Reminders')
              .fontColor(Color.Black)
              .fontSize(16)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.remindersEnabled })
              .onChange((isOn: boolean) => {
                this.toggleReminders(isOn);
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
