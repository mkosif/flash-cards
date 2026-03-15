@Builder export function CustomText(txt: string, size: number, fontColor: Color = Color.Black) {
  Text(`${txt}`)
    .fontSize(size)
    .fontColor(fontColor)
}
