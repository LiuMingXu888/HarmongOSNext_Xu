@Entry
@ComponentV2
struct Index_0707 {
  @Local message: string = "Hello "

  build() {
    Column() {
      Text(this.message)
    }
    .height('100%')
    .width('100%')
  }
}