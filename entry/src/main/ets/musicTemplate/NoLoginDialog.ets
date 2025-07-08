
@CustomDialog
export struct NoLoginDialogCollect {
  controller?: CustomDialogController
  cancel: () => void = () => {}
  confirm: () => void = () => {}
  build() {
    Column() {
      Row() {
        Text($r("app.string.music_collect_info"))
          .fontColor($r("app.color.White_09"))
          .fontSize(15)
      }
      .width("100%")
      .height(80)
      .justifyContent(FlexAlign.Center)

      Row(){
        Text($r("app.string.cancel"))
          .fontColor($r("app.color.White_09"))
          .fontSize(15)
          .layoutWeight(1)
          .height("100%")
          .textAlign(TextAlign.Center)
          .onClick(()=>this.cancel())
        Row().height("100%").width(2).backgroundColor("#2f2f2f")
        Text($r("app.string.music_collect_info_login"))
          .fontColor("#e54363")
          .textAlign(TextAlign.Center)
          .fontSize(15)
          .layoutWeight(1)
          .height("100%")
          .onClick(()=>this.onGoToLogin())
      }
      .width("100%")
      .height(50)
      .borderWidth({ top: 2 })
      .borderColor("#353535")
    }
    .width("70%")
    .borderRadius(18)
    .backgroundColor("#272727")
  }
  // 去登录事件
  onGoToLogin() {
    this.confirm()
  }

}