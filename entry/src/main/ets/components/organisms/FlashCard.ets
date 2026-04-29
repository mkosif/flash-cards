import WordData from '../../models/WordData';
import { RectangularText } from '../atoms/RectangularText';
import { CardBack } from '../molecules/CardBack';
import { CardFront } from '../molecules/CardFront'
import { vibrator } from '@kit.SensorServiceKit';

@Component
export struct FlashCard {
  @Link public wordData: WordData;
  @Link public isActive: boolean;
  @Link swiped: boolean;
  @Link swipeDirection: boolean;
  @State private front: boolean = true
  public rotationCount: number = 0
  @State private rotation: number = 0
  private uiCtx: UIContext | null = null;
  startX: number = 0;
  startY: number = 0;
  @State cardRotation: number = 0;
  @State cardTilt: number = 0;
  cardBackRotationSpeed: number = 2;

  @State opacityRight: number = 0;

  @StorageProp('hapticEnabled') hapticEnabled: boolean = true;

  aboutToAppear() {
    this.uiCtx = this.getUIContext();
  }

  private triggerHaptic(duration: number) {
    if (!this.hapticEnabled) {
      return;
    }
    try {
      vibrator.startVibration({
        type: 'time',
        duration: duration
      }, {
        id: 0,
        usage: 'touch'
      }, (error) => {
        if (error) {
          console.error(`Vibration failed: ${JSON.stringify(error)}`);
        }
      });
    } catch (e) {
      console.error(`Haptic feedback error: ${JSON.stringify(e)}`);
    }
  }

  private swipeAndDo(rotation: number, func: () => void): void {
    if (!this.uiCtx) {
      return;
    }
    this.uiCtx.animateTo({
      duration: 250,
      curve: Curve.EaseIn,
      onFinish: () => {
        func()
      }
    }, () => {
      this.cardRotation = rotation
    });
  }

  swipeRight() {
    this.triggerHaptic(50);
    setTimeout(() => {
        this.triggerHaptic(50);
    }, 100);
    this.swipeAndDo(180, () => {
      this.cardRotation = 0
      this.swipeDirection = true
      this.swiped = true
      this.opacityRight = 0
      this.front = true
      this.cardTilt = 0
    });
  }

  swipeLeft() {
    this.triggerHaptic(200);
    this.swipeAndDo(-180, () => {
      this.cardRotation = 0
      this.swipeDirection = false
      this.swiped = true
      this.opacityRight = 0
      this.front = true
      this.cardTilt = 0
    });
  }

  animateBack() {
    this.swipeAndDo(0, () => {
      this.opacityRight = 0
      this.cardTilt = 0
    });
  }

  public rotateCard(): void {
    if (!this.uiCtx) {
      return;
    }
    this.triggerHaptic(50);
    this.uiCtx.animateTo({
      duration: 250,
      curve: Curve.EaseIn,
        onFinish: () => {
          this.front = !this.front;
          this.rotationCount++;
          this.uiCtx?.animateTo(
            {
              duration: 250,
            curve: Curve.EaseOut
          },
          () => {
            this.rotation = 0;
          }
        );
      }
    }, () => {
      this.rotation = 90;
    });
  }

  build() {
    Column() {
      Stack() {

        Column() {
          CardFront(this.wordData.article, this.wordData.word, this.wordData.example, this.wordData.imageSrc)
        }
        .visibility(this.front ? Visibility.Visible : Visibility.Hidden)
        .width('100%')
        .height('100%')

        Column() {
          CardBack(
            this.wordData.article,
            this.wordData.word,
            this.wordData.example,
            this.wordData.meaning,
            this.wordData.imageSrc
          )
        }
        .visibility(!this.front ? Visibility.Visible : Visibility.Hidden)
        .width('100%')
        .height('100%')

        Column() {
          RectangularText(`Got it`, 15, Color.Green)
        }
        .width('100%')
        .height('100%')
        .rotate({
          angle: -40
        })
        .opacity(this.opacityRight > 0 ? this.opacityRight : 0)

        Column() {
          RectangularText(`Study again`, 15, Color.Red)
        }
        .width('100%')
        .height('100%')
        .rotate({
          angle: 40
        })
        .opacity(this.opacityRight < 0 ? -this.opacityRight : 0)
      }
      .onClick((event: ClickEvent) => {
        if (this.isActive) {
          this.rotateCard()
        }
      })
      .rotate({
        y: 1,
        angle: this.rotation,
        perspective: -800
      })
      .backgroundColor('#2D2D44')
      .borderRadius(10)
      .borderColor('#444466')
      .borderWidth(2)
      .shadow({ radius: 10, color: '#000000', offsetX: 5, offsetY: 5 })
      .width('100%')
      .height('100%')
      .accessibilityGroup(true)
      .accessibilityText(`${this.front ? 'Front' : 'Back'} of card: ${this.wordData.word}. Double tap to flip.`)
    }
    .rotate({ angle: this.cardRotation, centerY: 1000 })
    .rotate({ x: 0, y: 1, z: 0, angle: this.cardTilt, perspective: -800 })
    .onTouch((event: TouchEvent) => {
      if (!event || !this.isActive) {
        return;
      }
      const rotationThreshold: number = 5
      switch (event.type) {
        case TouchType.Down:
          this.startX = event.touches[0].displayX;
          this.startY = event.touches[0].displayY;
          break;
        case TouchType.Move:
          if (!this.swiped) {
            const dx = event.touches[0].displayX - this.startX;
            this.cardRotation = dx / 10;
            this.cardTilt = dx / 20;
            this.opacityRight = this.cardRotation / 5;
          }
          break;
        case TouchType.Up:
          if (this.cardRotation > rotationThreshold) {
            this.swipeRight()
          } else if (this.cardRotation < -rotationThreshold) {
            this.swipeLeft()
          } else {
            this.animateBack()
          }
          break;
      }
    })
  }
}
