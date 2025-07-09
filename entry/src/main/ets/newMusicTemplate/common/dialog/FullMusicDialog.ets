import { AppStorageV2 } from "@kit.ArkUI";
import { KEventBus } from "@kwai/eventbus";
import { formatSecondsToMMSS, Logger, ScreenSize } from "common_util";
import { USER_LOGIN_EVENT } from "login_event";
import { QCurrentUser } from "user_model";
import { MUSIC_TEMPLATE_TAG } from "../pages/MusicSameTemplatePage";
import { NoLoginDialogCollect } from "./NoLoginDialog";
import { PaddingCollectionType } from "../common/model/TempModel";
import { TempDialogVM } from "../common/model/TempDialogVM";
import { TempMusicVM } from "../common/model/TempMusicVM";
import { TemplateVM } from "../common/model/TempVM";
import { goToLogin } from "../common/utile/utileFn";

@ComponentV2
export struct FullMusicDialog {
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Consumer() templateVM: TemplateVM = new TemplateVM()
  @Require @Param dialogVM: TempDialogVM = new TempDialogVM() // 完整音乐的弹窗
  @Require @Param musicVM: TempMusicVM = new TempMusicVM()
  @Local currentTime: number = 0

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

  @Monitor("dialogVM.isShowDialog")
  playMusic() {
    if (this.dialogVM.isShowDialog) {
      this.templateVM.tempMusicVM.pause()
      this.musicVM.setUpMusic(this.templateVM.businessData.musicTemplate?.description.completeMusic!, true)
    } else {
      this.musicVM.reset()
      this.templateVM.tempMusicVM.resume()
    }
  }

  build() {
    if (this.dialogVM.isShowDialog) {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          // 背景模糊区
          Image(this.templateVM.businessData.musicTemplate?.description.completeMusic?.coverUrl)
            .width("100%")
            .height("100%")
            .borderRadius({ topLeft: 12, topRight: 12 })
            .foregroundBlurStyle(BlurStyle.Thin, {
              colorMode: ThemeColorMode.DARK,
              adaptiveColor: AdaptiveColor.DEFAULT,
              scale: 0.7
            })

          // 音乐唱片
          Column({ space: 24 }) {
            Stack({ alignContent: Alignment.Center }) {
              Image($r('app.media.template_collection_dialog'))
                .width(148)
                .aspectRatio(1)
              Image(this.templateVM.businessData.musicTemplate?.description.completeMusic?.coverUrl)
                .width(91.8)
                .aspectRatio(1)
                .borderRadius(50)
            }

            Text(this.templateVM.businessData.musicTemplate?.description.completeMusic?.name)
              .fontColor("#E5FFFFFF")
              .fontSize(15)
              .fontWeight(500)
              .height(23)

            this.videoProgressArea()

            // 底部按钮区域
            Row() {
              Row() {
                Text() {
                  ImageSpan(this.templateVM.uiState.fullMusicIsCollection ?  $r("app.media.template_full_collection") : $r("app.media.template_full_music_collection_cancel"))
                    .width(20)
                    .aspectRatio(1)
                    .verticalAlign(ImageSpanAlignment.CENTER)
                    .margin({ right: 6 })
                  Span("收藏")
                    .fontSize(15)
                    .fontWeight(500)
                    .fontColor("#E5FFFFFF")
                }
              }
              .width(158)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .borderRadius(26)
              .backgroundColor("#14FFFFFF") // 透明度降低些
              .onClick(() => {
                if (!this.templateVM.uiState.uid) {
                  // 去登录弹窗
                  this.musicVM.pause()
                  this.templateVM.businessData.paddingCollection = this.templateVM.businessData.musicTemplate?.description.completeMusic
                  this.templateVM.businessData.paddingCollectionType = PaddingCollectionType.FULL_MUSIC
                  this.collectionLoginDialogController.open()
                  Logger.i(MUSIC_TEMPLATE_TAG, "请先登录")
                  return
                }
                this.templateVM.collectionMusic(this.templateVM.businessData.musicTemplate?.description.completeMusic, true)
              })
              Row() {
                Text() {
                  ImageSpan($r("app.media.template_full_music_clip"))
                    .width(20)
                    .aspectRatio(1)
                    .verticalAlign(ImageSpanAlignment.CENTER)
                    .margin({ right: 6 })
                  Span("去剪辑")
                    .fontSize(15)
                    .fontWeight(500)
                    .fontColor("#E5FFFFFF")
                }
              }
              .width(158)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .borderRadius(26)
              .backgroundColor("#14FFFFFF") // 透明度降低些
              .linearGradient({
                angle: "135deg",
                colors: this.dialogVM.btnBgColorsUn
              })
              .onClick(() => {
                this.musicVM.pause()
                this.templateVM.goToClipPage(this.templateVM.businessData.musicTemplate?.description.completeMusic!, this.musicVM.musicDownloadPath)
              })
            }
            .width("100%")
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 20 + 16 - 24 })
          }
          .height(245)
          .padding({ top: 20 + 16, left: 20, right: 20 })

          // 关闭按钮
          Image($r('app.media.close'))
            .width(20)
            .height(20)
            .position({ right: 16, top: 16 })
            .onClick(() => {
              this.dialogVM.closeDialog()
            })
        }
        .width("100%")
        .height(this.dialogVM.maxHeight)
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

  // 底部视频进度区域
  @Builder
  videoProgressArea() {
    Row() {
      Image(this.musicVM.isPlaying ? $r('app.media.template_music_dialog_pause') : $r('app.media.template_music_dialog_play'))
        .width(24).height(24)
        .onClick(() => {
          this.musicVM.togglePlay()
        })
      Text(formatSecondsToMMSS(this.currentTime / 1000))
        .margin({ left: 20, right: 8 })
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(14)
        .fontColor($r("app.color.White_09"))
      // 进度滑动条
      Slider({
        style: SliderStyle.OutSet,
        value: this.currentTime,
        min: 0,
        max: this.templateVM.businessData.musicTemplate?.description.completeMusic?.duration || 0,
        step: 1
      })
        .blockSize({width: 6, height: 6})
        .selectedColor(Color.White)
        .trackThickness(2)
        .trackColor("#5c5c5c")
        .blockStyle({ type: SliderBlockType.DEFAULT })
        .onChange((value: number, mode: SliderChangeMode) => {
          this.onSliderChange(value, mode)
        })
        .layoutWeight(1)
      Text(formatSecondsToMMSS((this.templateVM.businessData.musicTemplate?.description.duration || 0) / 1000))
        .margin({ left: 8 })
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(14)
        .fontColor($r("app.color.White_09"))
    }
    .width("100%")
    .height(24)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  onSliderChange(value: number, mode: SliderChangeMode) {
    let sliderEndPlaying: boolean = false
    this.currentTime = value;
    Logger.i(MUSIC_TEMPLATE_TAG, "音频进度发生改变sss this.currentTime:"+value)
    switch (mode) {
      case 0: // 按到滑块
        sliderEndPlaying = this.musicVM.isPlaying
        this.musicVM.pause()
        break;
      case 1: // 开始滑动
        break;
      case 2: // 结束滑动
        this.musicVM.audioPlayerManager.seek(Number.parseInt(value.toFixed(0)))
        if (sliderEndPlaying) {
          this.musicVM.resume()
        }
        break;
      default:
        break
    }
  }
}