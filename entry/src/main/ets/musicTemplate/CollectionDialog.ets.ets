import { AppStorageV2 } from "@kit.ArkUI";
import { ScreenSize } from "common_util";
import { DialogListener } from "../common/model/MusicSameTemplateViewModel";

@ComponentV2
export struct CollectionDialog {
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Local maxHeight: number = 441
  @Local currentY: number = 441
  @Local duration: number = 300
  @Require @Param canShow: boolean
  @Event $canShow: (val: boolean) => void = (val: boolean) => {};
  @Require @Param dialogListener: DialogListener
  confirmTitleResource = $r('app.string.privacy_agreement_dialog_confirm_button')
  cancelTitleResource = $r('app.string.privacy_agreement_dialog_cancel_button')

  btnBgColorsUn: Array<[Resource, number]> = [[$r('app.color.btn_linear_gradient_color_1'), 0], [$r('app.color.btn_linear_gradient_color_2'), 0.5], [$r('app.color.btn_linear_gradient_color_3'), 1]]


  aboutToAppear(): void {
    this.dialogListener.closeDialog = () => {
      this.onDisAppearAnimation()
    }
  }

  build() {
    if (this.canShow) {
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
                if (false) {
                  Image($r("app.media.app_icon"))
                    .width(20)
                    .aspectRatio(1)
                    .margin({ right: 6 })
                }
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
                colors: this.btnBgColorsUn
              })
              .onClick(() => {
                this.onDisAppearAnimation()
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
              this.onDisAppearAnimation()
            })
        }
        .backgroundColor($r('app.color.dialog_bg'))
        .width("100%")
        .height(this.maxHeight)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .translate({ y: this.currentY })
        .onAppear(() => { this.onApperAnimation() })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.Blank_8'))
    }
  }
  onApperAnimation() {
    animateTo({ duration: this.duration }, () => {  this.currentY = 0 } )
  }

  onDisAppearAnimation() {
    animateTo({ duration: this.duration }, () => {  this.currentY = this.maxHeight } )
    setTimeout(() => { this.$canShow(false) }, this.duration)
  }

  private privacyTitle(): Resource {
    return $r('app.string.privacy_agreement_dialog_title')
  }
}