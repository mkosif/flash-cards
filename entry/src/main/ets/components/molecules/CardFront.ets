import { CustomText } from '../atoms/CustomText'
import {Word} from './Word'

@Builder export function CardFront(article: string, word: string, exampleSentence: string, imageSrc?: string) {
  Column(){
      if (imageSrc) {
        Image(imageSrc)
          .width(40)
          .height(40)
          .margin({ bottom: 10 })
          .objectFit(ImageFit.Contain)
      }
      Word(article, word, 16)
      CustomText(exampleSentence, 12, Color.White)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}
