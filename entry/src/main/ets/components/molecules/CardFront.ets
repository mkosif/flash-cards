import { CustomText } from '../atoms/CustomText'
import {Word} from './Word'

@Builder export function CardFront(article: string, word: string, exampleSentence: string) {
  Column(){
      Word(article, word, 16)
      CustomText(exampleSentence, 12, Color.Black)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}
