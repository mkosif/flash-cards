@Builder
export function RemainingBox(count: number, txt: string, color: Color = Color.White) {
  Column() {
    Text(`${count}`)
      .fontSize(18)
      .fontColor(color)
    Text(txt)
      .fontSize(12)
      .fontColor(color)
  }
  .border({
    width: 3,
    color: color,
    radius: 5
  })
  .padding(4)
  .margin(3)
}
