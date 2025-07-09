/**
 * 音乐信息视图组件 - 负责音乐信息的展示
 * 遵循单一职责原则：只负责音乐信息的UI展示
 */
import { MusicEntity } from '../../domain/entities/MusicEntity'

@ComponentV2
export struct MusicInfoView {
  @Require @Param music: MusicEntity
  @Require @Param isPlaying: boolean
  @Require @Param onPlayPauseClick: () => void
  @Require @Param onCollectionClick: () => void
  @Require @Param onEditClick: () => void
  @Require @Param onFullMusicClick: () => void
  @Require @Param hasFullMusic: boolean = false
  @Require @Param targetOpacity: number = 1

  build() {
    Column({ space: 12 }) {
      // 音乐展示区
      Row({ space: 12 }) {
        // 左侧图片区域
        this.buildMusicCover()
        
        // 右侧信息展示区域
        this.buildMusicInfo()
      }
      .width("100%")
      .height(84)

      // 按钮区域
      this.buildActionButtons()
    }
    .width("100%")
    .height(140)
    .margin({ bottom: 20 })
    .padding({ left: 16, right: 16 })
    .opacity(this.targetOpacity)
  }

  @Builder
  buildMusicCover() {
    Stack({ alignContent: Alignment.Center }) {
      // 底部黑胶图
      Image($r('app.media.record'))
        .width("100%")
        .aspectRatio(1)
        .borderRadius(50)

      // 音乐缩放图
      Image(this.music.coverUrl)
        .width(56.7)
        .aspectRatio(1)
        .borderRadius(50)

      // 播放和暂定图
      Image(this.isPlaying ? $r("app.media.template_play") : $r("app.media.template_pause"))
        .width(29.65)
        .aspectRatio(1)
    }
    .width(84)
    .height("100%")
    .onClick(() => {
      this.onPlayPauseClick()
    })
  }

  @Builder
  buildMusicInfo() {
    Column() {
      Row() {
        Text() {
          ImageSpan($r("app.media.template_music_icon"))
            .width(18)
            .aspectRatio(1)
            .verticalAlign(ImageSpanAlignment.CENTER)
          Span(this.music.name)
            .fontWeight(500)
            .fontSize(17)
            .fontColor(Color.White)
        }
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .layoutWeight(1)

        if (this.hasFullMusic) {
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
            this.onFullMusicClick()
          })
        }
      }
      .height(20)

      Row() {
        Text("时长").musicInfoStyle().margin({ right: 6 })
        Text(this.music.getFormattedDuration()).musicInfoStyle()
        Text("|").musicInfoStyle().margin({ left: 6, right: 6 })
        Text(this.music.getFormattedUseCount()).musicInfoStyle()
        Text("人在用").musicInfoStyle()
      }
    }
    .layoutWeight(1)
    .height("100%")
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  buildActionButtons() {
    Row({ space: 10 }) {
      // 去剪辑按钮
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
      .backgroundColor("#14FFFFFF")
      .onClick(() => {
        this.onEditClick()
      })

      // 收藏按钮
      Text() {
        ImageSpan(this.music.isCollected ? $r("app.media.template_music_collection") : $r("app.media.template_music_cancel_collection"))
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
      .backgroundColor("#14FFFFFF")
      .onClick(() => {
        this.onCollectionClick()
      })
    }
    .width("100%")
    .height(44)
  }
}

@Extend(Text)
function musicInfoStyle() {
  .fontSize(12)
  .lineHeight(15)
  .fontColor(Color.White)
  .opacity(0.5)
} 