import { CustomText } from '../atoms/CustomText'
import { Word } from './Word'

@Builder export function CardBack(article: string, word: string, exampleSentence: string, translation: string) {
  Column(){
    CustomText(translation, 16, Color.Black)
    Word(article, word, 12)
    CustomText(exampleSentence, 12, Color.Black)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}
