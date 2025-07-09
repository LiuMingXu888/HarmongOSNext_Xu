/**
 * 音乐信息视图组件 - 显示音乐的基本信息和播放控制
 * 遵循单一职责原则：只负责音乐信息的展示和交互
 * 使用V2装饰器实现响应式UI
 */
import { Music } from '../../domain/entities/Music'
import { MusicTemplateViewModel } from '../viewmodels/MusicTemplateViewModel'

@ComponentV2
export struct MusicInfoView {
  @Prop viewModel: MusicTemplateViewModel
  @State private showFullMusicDialog: boolean = false

  build() {
    Column() {
      // 音乐封面和基本信息
      Row() {
        // 音乐封面
        Image(this.viewModel.currentMusic?.coverUrl || '')
          .width(80)
          .height(80)
          .borderRadius(8)
          .margin({ right: 12 })

        // 音乐信息
        Column() {
          Text(this.viewModel.currentMusic?.name || '')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.viewModel.currentMusic?.artist || '')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 使用次数
          Row() {
            Text('使用')
              .fontSize(12)
              .fontColor('#999999')
            
            Text(this.viewModel.currentMusic?.getFormattedUseCount() || '0')
              .fontSize(12)
              .fontColor('#FF6B35')
              .fontWeight(FontWeight.Medium)
            
            Text('次')
              .fontSize(12)
              .fontColor('#999999')
          }
          .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)

        // 播放控制按钮
        Column() {
          // 播放/暂停按钮
          Button({ type: ButtonType.Circle }) {
            Image(this.viewModel.isMusicPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
              .width(24)
              .height(24)
          }
          .width(48)
          .height(48)
          .backgroundColor('#FF6B35')
          .onClick(() => {
            this.viewModel.toggleMusicPlayback()
          })

          // 收藏按钮
          Button({ type: ButtonType.Circle }) {
            Image(this.viewModel.isMusicCollected(this.viewModel.currentMusic?.id || '') 
              ? $r('app.media.ic_collected') 
              : $r('app.media.ic_collect'))
              .width(20)
              .height(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .margin({ top: 8 })
          .onClick(() => {
            this.viewModel.toggleMusicCollection()
          })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('rgba(0, 0, 0, 0.3)')
      .borderRadius(12)

      // 音乐时长和进度
      Column() {
        // 进度条
        Row() {
          Text(this.viewModel.currentMusic?.getFormattedDuration() || '00:00')
            .fontSize(12)
            .fontColor('#CCCCCC')

          Slider({
            value: this.viewModel.musicProgress,
            min: 0,
            max: this.viewModel.musicDuration,
            step: 1
          })
            .width('60%')
            .margin({ left: 12, right: 12 })
            .onChange((value: number) => {
              // 这里可以添加进度条拖拽逻辑
            })

          Text(this.viewModel.currentMusic?.getFormattedDuration() || '00:00')
            .fontSize(12)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 12 })

        // 操作按钮
        Row() {
          // 下载按钮
          Button() {
            Row() {
              Image($r('app.media.ic_download'))
                .width(16)
                .height(16)
                .margin({ right: 4 })
              
              Text('下载')
                .fontSize(14)
                .fontColor('#FFFFFF')
            }
          }
          .backgroundColor('transparent')
          .borderRadius(20)
          .border({ width: 1, color: '#FF6B35' })
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.viewModel.downloadMusic()
          })

          // 完整音乐按钮
          Button() {
            Row() {
              Image($r('app.media.ic_full_music'))
                .width(16)
                .height(16)
                .margin({ right: 4 })
              
              Text('完整音乐')
                .fontSize(14)
                .fontColor('#FFFFFF')
            }
          }
          .backgroundColor('#FF6B35')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin({ left: 12 })
          .onClick(() => {
            this.showFullMusicDialog = true
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .padding(16)
  }
} 