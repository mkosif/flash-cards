import {CustomText} from '../atoms/CustomText'
@Builder export function Word(article: string, word: string, size: number) {
  Row(){
    CustomText(
      article,
      size,
      article === 'der'
        ? Color.Blue
        : (article === 'die' ? Color.Pink : (article === 'das' ? Color.Green : Color.White))
    )
    CustomText(` ${word}`, size, Color.White)
  }
}
