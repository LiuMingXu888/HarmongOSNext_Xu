import { AppStorageV2 } from "@kit.ArkUI";
import { KEventBus } from "@kwai/eventbus";
import { AudioPlayerManager,  } from "audio_manager";
import { formatSecondsToMMSS, Logger, ScreenSize } from "common_util";
import { USER_LOGIN_EVENT } from "login_event";
import { QCurrentUser } from "user_model";
import { MUSIC_TEMPLATE_TAG } from "../pages/MusicSameTemplatePage";
import { MusicTemplateVM } from "../common/model/MusicSameTemplateModel";
import { NoLoginDialogCollect } from "./NoLoginDialog";
import { DialogListener, PaddingCollectionType } from "../common/model/MusicSameTemplateViewModel";

@ComponentV2
export struct FullMusicDialog {
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Local maxHeight: number = 441
  @Local currentY: number = 441
  @Local duration: number = 300
  @Require @Param musicTemplateVM: MusicTemplateVM
  @Require @Param dialogListener: DialogListener
  confirmTitleResource = $r('app.string.privacy_agreement_dialog_confirm_button')
  cancelTitleResource = $r('app.string.privacy_agreement_dialog_cancel_button')

  @Local currentTime: number = 0
  @Local slidePlaying: boolean = true // 滑动前的播放状态留存
  @Local isPlaying: boolean = true // 是否播放当前音乐
  audioPlayerManager: AudioPlayerManager = new AudioPlayerManager() // 播放音频的类

  btnBgColorsUn: Array<[Resource, number]> = [[$r('app.color.btn_linear_gradient_color_1'), 0], [$r('app.color.btn_linear_gradient_color_2'), 0.5], [$r('app.color.btn_linear_gradient_color_3'), 1]]

  collectionLoginDialogController: CustomDialogController = new CustomDialogController({
    builder: NoLoginDialogCollect(
      {
        cancel: () => {
          this.isPlaying = true
          this.audioPlayerManager.resumeAudioPlay()
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

  aboutToAppear(): void {
    this.dialogListener.closeDialog = () => {
      this.onDisAppearAnimation()
    }

    this.dialogListener.pageHidden = () => {
      this.isPlaying = false
      this.audioPlayerManager?.pauseAudioPlay()
    }
  }

  @Monitor("musicTemplateVM.isShowFullMusicDialog")
  playMusic() {
    if (this.musicTemplateVM.isShowFullMusicDialog) {
      this.musicTemplateVM.audioPlayerManager.pauseAudioPlay()
      this.musicTemplateVM.isPlaying = false
      this.setUpMusic(this.musicTemplateVM.musicTemplate?.description.completeMusic?.musicUrl)
    } else {
      this.audioPlayerManager.resetAudioPlay()
      this.musicTemplateVM.audioPlayerManager.resumeAudioPlay()
      this.musicTemplateVM.isPlaying = true
    }
  }

  build() {
    if (this.musicTemplateVM.isShowFullMusicDialog) {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          // 背景模糊区
          Image(this.musicTemplateVM.musicTemplate?.description.completeMusic?.coverUrl)
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
              Image(this.musicTemplateVM.musicTemplate?.description.completeMusic?.coverUrl)
                .width(91.8)
                .aspectRatio(1)
                .borderRadius(50)
            }

            Text(this.musicTemplateVM.musicTemplate?.description.completeMusic?.name)
              .fontColor("#E5FFFFFF")
              .fontSize(15)
              .fontWeight(500)
              .height(23)

            this.videoProgressArea()

            // 底部按钮区域
            Row() {
              Row() {
                Text() {
                  ImageSpan(this.musicTemplateVM.fullMusicIsCollection ?  $r("app.media.template_full_collection") : $r("app.media.template_full_music_collection_cancel"))
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
                if (!this.musicTemplateVM.uid) {
                  // 去登录弹窗
                  this.isPlaying = false
                  this.audioPlayerManager.pauseAudioPlay()
                  this.musicTemplateVM.paddingCollection = this.musicTemplateVM.musicTemplate?.description.completeMusic
                  this.musicTemplateVM.paddingCollectionType = PaddingCollectionType.FULL_MUSIC
                  this.collectionLoginDialogController.open()
                  Logger.i(MUSIC_TEMPLATE_TAG, "请先登录")
                  return
                }
                this.musicTemplateVM.collectionMusic(this.musicTemplateVM.musicTemplate?.description.completeMusic, true)
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
                colors: this.btnBgColorsUn
              })
              .onClick(() => {
                this.musicTemplateVM.audioPlayerManager.pauseAudioPlay()
                this.musicTemplateVM.goToClipPage()
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
              this.onDisAppearAnimation()
            })
        }
        .width("100%")
        .height(this.maxHeight)
        .translate({ y: this.currentY })
        .onAppear(() => {
          animateTo({ duration: this.duration }, () => {  this.currentY = 0 } )
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
      Image(this.isPlaying ? $r('app.media.template_music_dialog_pause') : $r('app.media.template_music_dialog_play'))
        .width(24).height(24)
        .onClick(() => {
          if (this.isPlaying) {
            this.isPlaying = false
            this.audioPlayerManager.pauseAudioPlay()
          } else {
            this.isPlaying = true
            this.audioPlayerManager.resumeAudioPlay()
          }
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
        max: this.musicTemplateVM.musicTemplate?.description.completeMusic?.duration || 0,
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
      Text(formatSecondsToMMSS((this.musicTemplateVM.musicTemplate?.description.duration || 0) / 1000))
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

  onDisAppearAnimation() {
    animateTo({ duration: this.duration }, () => {  this.currentY = this.maxHeight } )
    setTimeout(() => { this.musicTemplateVM.isShowFullMusicDialog = false }, this.duration)
  }

  setUpMusic(path: string = "") {
    if (path) {
      Logger.i(MUSIC_TEMPLATE_TAG,"地址不对，播放错误")
    }
    this.audioPlayerManager?.setDataSourceAndPlay(
      {
        path, // 播放路径
        playImmediately: false,
        prepareCbs: () => {
          Logger.i(MUSIC_TEMPLATE_TAG,"资源准备完毕，准备播放")
          this.audioPlayerManager.resumeAudioPlay()
        },
        playingCbs: (isPlaying) => {
          this.isPlaying = true
          Logger.i(MUSIC_TEMPLATE_TAG,"资源准备完毕，开始播放")
        },
        progressCbs: (progress: number) => {
          this.currentTime = progress
          Logger.i(MUSIC_TEMPLATE_TAG, "音频进度发生改变sss musicPlayingProgress:"+progress)
        },
        completeCbs: () => {
          this.audioPlayerManager?.resumeAudioPlay()
        }, // 播放结束后
      }
    );
  }

  onSliderChange(value: number, mode: SliderChangeMode) {
    let sliderEndPlaying: boolean = false
    this.currentTime = value;
    Logger.i(MUSIC_TEMPLATE_TAG, "音频进度发生改变sss this.currentTime:"+value)
    switch (mode) {
      case 0: // 按到滑块
        this.audioPlayerManager.pauseAudioPlay()
        sliderEndPlaying = this.isPlaying
        this.isPlaying = false
        break;
      case 1: // 开始滑动
        break;
      case 2: // 结束滑动
        this.audioPlayerManager.seek(Number.parseInt(value.toFixed(0)))
        if (sliderEndPlaying) {
          this.audioPlayerManager.resumeAudioPlay()
        }
        break;
      default:
        break
    }
  }
}