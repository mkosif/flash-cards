@Builder export function CustomText(txt: string, size: number, fontColor: Color = Color.White) {
  Text(`${txt}`)
    .fontSize(size)
    .fontColor(fontColor)
    .accessibilityText(txt)
}
