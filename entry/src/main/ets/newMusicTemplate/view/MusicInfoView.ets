import { KEventBus } from "@kwai/eventbus"
import { DateUtil, Logger } from "common_util"
import { USER_LOGIN_EVENT } from "login_event"
import { QCurrentUser } from "user_model"
import { TempDialogVM } from "../common/model/TempDialogVM"
import { PaddingCollectionType } from "../common/model/TempModel"
import { TempMusicVM } from "../common/model/TempMusicVM"
import { TemplateVM } from "../common/model/TempVM"
import { goToLogin } from "../common/utile/utileFn"
import { NoLoginDialogCollect } from "../dialogs/NoLoginDialog"
import { MUSIC_TEMPLATE_TAG } from "../pages/MusicSameTemplatePage"


@ComponentV2
export struct MusicInfoView {
  @Consumer() templateVM: TemplateVM = new TemplateVM()
  @Require @Param musicVM: TempMusicVM = new TempMusicVM()
  @Require @Param fullMusicDialog: TempDialogVM = new TempDialogVM() // 完整音乐的弹窗
  @Require @Param targetOpacity: number = 1
  collectionLoginDialogController: CustomDialogController = new CustomDialogController({
    builder: NoLoginDialogCollect(
      {
        cancel: () => {
          this.musicVM.resume()
          this.collectionLoginDialogController?.close()
        },
        confirm: () => {
          this.collectionLoginDialogController?.close()
          let collectLoginCallback = async () => {
            if (QCurrentUser.isLogined()) {
              this.templateVM.uiState.uid = QCurrentUser.getUid()
            }
            KEventBus.unsubscribe(USER_LOGIN_EVENT, collectLoginCallback)
          }
          goToLogin(collectLoginCallback)
        }
      }
    ),
    alignment: DialogAlignment.Center,
    customStyle: true,
    backgroundColor: "#272727"
  })

  build() {
    Column({ space: 12 }) {
      // 音乐展示区
      Row({ space: 12 }) {
        // 左侧图片区域
        Stack({ alignContent: Alignment.Center }) {
          // 底部黑胶图
          Image($r('app.media.record'))
            .width("100%")
            .aspectRatio(1)
            .borderRadius(50)

          // 音乐缩放图
          Image(this.templateVM.businessData.templateInfo?.coverUrlBackupUrls[0])
            .width(56.7)
            .aspectRatio(1)
            .borderRadius(50)

          // 播放和暂定图
          Image(this.musicVM.isPlaying ? $r("app.media.template_play") : $r("app.media.template_pause"))
            .width(29.65)
            .aspectRatio(1)
        }
        .width(84)
        .height("100%")
        .onClick(() => {
          this.musicVM.togglePlay()
        })

        // 右侧信息展示区域
        Column() {
          Row() {
            Text() {
              ImageSpan($r("app.media.template_music_icon"))
                .width(18)
                .aspectRatio(1)
                .verticalAlign(ImageSpanAlignment.CENTER)
              Span(this.templateVM.businessData.templateInfo?.music?.name || "")
                .fontWeight(500)
                .fontSize(17)
                .fontColor(Color.White)
            }
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .layoutWeight(1)

            if (this.templateVM.businessData.musicTemplate?.description.completeMusic) {
              Row() {
                Text() {
                  Span("完整音乐")
                    .fontWeight(500)
                    .fontSize(13)
                    .fontColor(Color.White)
                  ImageSpan($r("app.media.template_open_full_music"))
                    .width(16)
                    .aspectRatio(1)
                    .verticalAlign(ImageSpanAlignment.CENTER)
                }
              }
              .height("100%")
              .onClick(() => {
                this.fullMusicDialog.isShowDialog = true
              })
            }
          }
          .height(20)

          Row() {
            Text("时长").musicInfoStyle().margin({ right: 6 })
            Text(DateUtil.formatSecondsToMMSS((this.templateVM.businessData.templateInfo?.music?.duration || 0) / 1000)).musicInfoStyle()
            Text("|").musicInfoStyle().margin({ left: 6, right: 6 })
            Text(this.useCount).musicInfoStyle()
            Text("人在用").musicInfoStyle()
          }
        }
        .layoutWeight(1)
        .height("100%")
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceEvenly)

      }
      .width("100%")
      .height(84)

      // 按钮区域
      Row({ space: 10 }) {
        Text() {
          ImageSpan($r("app.media.template_clip"))
            .width(16)
            .aspectRatio(1)
            .verticalAlign(ImageSpanAlignment.CENTER)
            .margin({ right: 6 })
          Span("去剪辑")
            .fontColor(Color.White)
            .fontSize(13)
            .fontWeight(500)
        }
        .height("100%")
        .textAlign(TextAlign.Center)
        .borderRadius(8)
        .layoutWeight(1)
        .backgroundColor("#14FFFFFF") // 透明度降低些
        .onClick(() => {
          this.musicVM.pause()
          this.templateVM.goToClipPage(this.templateVM.businessData.musicTemplate?.description!, this.musicVM.musicDownloadPath)
        })

        Text() {
          ImageSpan(this.templateVM.uiState.isCollection ? $r("app.media.template_music_collection") : $r("app.media.template_music_cancel_collection"))
            .width(16)
            .aspectRatio(1)
            .verticalAlign(ImageSpanAlignment.CENTER)
            .margin({ right: 6 })
          Span("收藏")
            .fontColor(Color.White)
            .fontSize(13)
            .fontWeight(500)
        }
        .height("100%")
        .textAlign(TextAlign.Center)
        .borderRadius(8)
        .layoutWeight(1)
        .backgroundColor("#14FFFFFF") // 透明度降低些
        .onClick(() => {
          if (!this.templateVM.uiState.uid) {
            // 去登录弹窗
            this.musicVM.pause()
            this.templateVM.businessData.paddingCollection = this.templateVM.businessData.musicTemplate?.description
            this.templateVM.businessData.paddingCollectionType = PaddingCollectionType.MUSIC_SAME_TEMPLATE
            this.collectionLoginDialogController.open()
            Logger.i(MUSIC_TEMPLATE_TAG, "请先登录")
            return
          }
          this.templateVM.collectionMusic(this.templateVM.businessData.musicTemplate?.description)
        })
      }
      .width("100%")
      .height(44)
    }
    .width("100%")
    .height(140)
    .margin({ bottom: 20 })
    .padding({ left: 16, right: 16 })
    .opacity(this.targetOpacity)
  }

  // 显示使用人数
  @Computed
  get useCount() {
    if ((this.templateVM.businessData.musicTemplate?.description.useCount || 0) >= 10000) {
      return (Math.round((this.templateVM.businessData.musicTemplate?.description.useCount || 0) / 1000) / 10).toFixed(1) + '万'; // 四舍五入保留一位小数
    }
    return (this.templateVM.businessData.musicTemplate?.description.useCount || 0).toString();
  }
}

@Extend(Text)
function musicInfoStyle() {
  .fontSize(12)
  .lineHeight(15)
  .fontColor(Color.White)
  .opacity(0.5)
}
