@Entry
@ComponentV2
struct Index {
  @Local message: string = "Hello World"

  build() {
    Column() {
      Text(this.message)
    }
    .height('100%')
    .width('100%')
  }
}