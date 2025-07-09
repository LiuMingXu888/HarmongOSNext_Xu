import { AppStorageV2 } from "@kit.ArkUI";
import { ScreenSize } from "common_util";
import { TempDialogVM } from "../common/model/TempDialogVM";

@ComponentV2
export struct CollectionDialog {
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Require @Param dialogVM: TempDialogVM = new TempDialogVM() // 完整音乐的弹窗

  build() {
    if (this.dialogVM.isShowDialog) {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          // 文字区域
          Column() {
            Text("收藏的音乐哪里找")
              .fontColor("#E5FFFFFF")
              .fontSize(15)
              .fontWeight(500)
              .lineHeight(23)
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 24 })

            Row({ space: 8 }) {
              Text("音乐")
                .fontColor("#80FFFFFF")
                .fontSize(13)

              Image($r("app.media.template_point_icon"))
                .width(12)
                .aspectRatio(1)

              Text("音乐库")
                .fontColor("#80FFFFFF")
                .fontSize(13)

              Image($r("app.media.template_point_icon"))
                .width(12)
                .aspectRatio(1)

              Text("快影收藏")
                .fontColor("#80FFFFFF")
                .fontSize(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 12 })

            Image($r("app.media.template_music_point"))
              .width(232)
              .height(225)
              .borderColor('#333333')
              .margin({ top: 24 })
              .borderRadius({ topLeft: 20, topRight: 20 })
              .borderWidth({ left: 6, right: 6, top: 6 })

            Row() {
              Row() {
                Text("我知道了")
                  .fontSize(15)
                  .fontWeight(500)
                  .fontColor("#E5FFFFFF")
              }
              .width(158)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .borderRadius(22)
              .linearGradient({
                angle: "135deg",
                colors: this.dialogVM.btnBgColorsUn
              })
              .onClick(() => {
                this.dialogVM.closeDialog()
              })
            }
            .width("100%")
            .padding({ top: 24 })
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.dialog_bg'))
          }
          .alignItems(HorizontalAlign.Center)
          .backgroundColor("#2a2a2a")
          .borderRadius({ topLeft: 16, topRight: 16 })

          // 关闭区域
          Image($r('app.media.close'))
            .width(20)
            .height(20)
            .position({ right: 16, top: 16 })
            .onClick(() => {
              this.dialogVM.closeDialog()
            })
        }
        .backgroundColor($r('app.color.dialog_bg'))
        .width("100%")
        .height(this.dialogVM.maxHeight)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .translate({ y: this.dialogVM.currentY })
        .onAppear(() => {
          this.dialogVM.openDialog()
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.Blank_8'))
    }
  }
}