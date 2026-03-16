@Builder
export function RectangularText(txt: string, size: number, color: Color = Color.White) {
  Row() {
    Text(txt)
      .fontSize(size)
      .fontColor(color)
      .padding(8)
      .fontWeight(FontWeight.Bold)
  }
  .border({
    width: 3,
    color: color,
    radius: 5
  })
  .accessibilityGroup(true)
  .accessibilityText(txt)
}
