import { CustomText } from '../atoms/CustomText'
import { Word } from './Word'

@Builder
export function CardBack(
  article: string,
  word: string,
  exampleSentence: string,
  translation: string,
  imageSrc?: string
) {
  Column(){
    if (imageSrc) {
      Image(imageSrc)
        .width(30)
        .height(30)
        .margin({ bottom: 5 })
        .objectFit(ImageFit.Contain)
    }
    CustomText(translation, 16, Color.White)
    Word(article, word, 12)
    CustomText(exampleSentence, 12, Color.White)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}
