import { KEventBus } from "@kwai/eventbus"
import { DateUtil, Logger } from "common_util"
import { USER_LOGIN_EVENT } from "login_event"
import { QCurrentUser } from "user_model"
import { MusicTemplateVM } from "../common/model/MusicSameTemplateModel"
import { PaddingCollectionType } from "../common/model/MusicSameTemplateViewModel"
import { NoLoginDialogCollect } from "../dialogs/NoLoginDialog"
import { MUSIC_TEMPLATE_TAG } from "../pages/MusicSameTemplatePage"


@ComponentV2
export struct MusicInfoView {
  @Consumer() musicTemplateVM: MusicTemplateVM = new MusicTemplateVM()
  @Require @Param targetOpacity: number = 1
  collectionLoginDialogController: CustomDialogController = new CustomDialogController({
    builder: NoLoginDialogCollect(
      {
        cancel: () => {
          this.musicTemplateVM.isPlaying = true
          this.musicTemplateVM.audioPlayerManager.resumeAudioPlay()
          this.collectionLoginDialogController?.close()
        },
        confirm: () => {
          this.collectionLoginDialogController?.close()
          let collectLoginCallback = async () => {
            if (QCurrentUser.isLogined()) {
              this.musicTemplateVM.uid = QCurrentUser.getUid()
            }
            KEventBus.unsubscribe(USER_LOGIN_EVENT, collectLoginCallback)
          }
          this.musicTemplateVM.goToLogin(collectLoginCallback)
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
          Image(this.musicTemplateVM.templateInfo?.coverUrlBackupUrls[0])
            .width(56.7)
            .aspectRatio(1)
            .borderRadius(50)

          // 播放和暂定图
          Image(this.musicTemplateVM.isPlaying ? $r("app.media.template_play") : $r("app.media.template_pause"))
            .width(29.65)
            .aspectRatio(1)
        }
        .width(84)
        .height("100%")
        .onClick(() => {
          this.musicTemplateVM.onClickPlayIcon()
        })

        // 右侧信息展示区域
        Column() {
          Row() {
            Text() {
              ImageSpan($r("app.media.template_music_icon"))
                .width(18)
                .aspectRatio(1)
                .verticalAlign(ImageSpanAlignment.CENTER)
              Span(this.musicTemplateVM.templateInfo?.music?.name || "")
                .fontWeight(500)
                .fontSize(17)
                .fontColor(Color.White)
            }
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .layoutWeight(1)

            if (this.musicTemplateVM.musicTemplate?.description.completeMusic) {
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
                this.musicTemplateVM.isShowFullMusicDialog = true
              })
            }
          }
          .height(20)

          Row() {
            Text("时长").musicInfoStyle().margin({ right: 6 })
            Text(DateUtil.formatSecondsToMMSS((this.musicTemplateVM.templateInfo?.music?.duration || 0) / 1000)).musicInfoStyle()
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
          this.musicTemplateVM.audioPlayerManager.pauseAudioPlay()
          this.musicTemplateVM.goToClipPage()
        })

        Text() {
          ImageSpan(this.musicTemplateVM.isCollection ? $r("app.media.template_music_collection") : $r("app.media.template_music_cancel_collection"))
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
          if (!this.musicTemplateVM.uid) {
            // 去登录弹窗
            this.musicTemplateVM.isPlaying = false
            this.musicTemplateVM.audioPlayerManager.pauseAudioPlay()
            this.musicTemplateVM.paddingCollection = this.musicTemplateVM.musicTemplate?.description
            this.musicTemplateVM.paddingCollectionType = PaddingCollectionType.MUSIC_SAME_TEMPLATE
            this.collectionLoginDialogController.open()
            Logger.i(MUSIC_TEMPLATE_TAG, "请先登录")
            return
          }
          this.musicTemplateVM.collectionMusic(this.musicTemplateVM.musicTemplate?.description)
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
    if ((this.musicTemplateVM.musicTemplate?.description.useCount || 0) >= 10000) {
      return (Math.round((this.musicTemplateVM.musicTemplate?.description.useCount || 0) / 1000) / 10).toFixed(1) + '万'; // 四舍五入保留一位小数
    }
    return (this.musicTemplateVM.musicTemplate?.description.useCount || 0).toString();
  }
}

@Extend(Text)
function musicInfoStyle() {
  .fontSize(12)
  .lineHeight(15)
  .fontColor(Color.White)
  .opacity(0.5)
}
