/**
 * 模板列表视图组件 - 显示音乐相关的模板列表
 * 遵循单一职责原则：只负责模板列表的展示和交互
 * 使用V2装饰器实现响应式UI
 */
import { Template } from '../../domain/entities/Template'
import { MusicTemplateViewModel } from '../viewmodels/MusicTemplateViewModel'

@ComponentV2
export struct TemplateListView {
  @Prop viewModel: MusicTemplateViewModel
  @State private selectedTemplate: Template | null = null

  build() {
    Column() {
      // 筛选按钮
      Row() {
        Text('筛选')
          .fontSize(14)
          .fontColor('#FFFFFF')
        
        Image($r('app.media.ic_filter'))
          .width(16)
          .height(16)
          .margin({ left: 4 })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .borderRadius(20)
      .onClick(() => {
        this.viewModel.showFilterDialog()
      })

      // 模板列表
      LazyColumn() {
        ForEach(this.viewModel.templates, (template: Template) => {
          TemplateCardView({
            template: template,
            onTemplateClick: (template: Template) => {
              this.selectedTemplate = template
              // 处理模板点击事件
            }
          })
        })
      }
      .width('100%')
      .height('100%')
      .onReachEnd(() => {
        // 加载更多模板
        this.viewModel.loadMoreTemplates()
      })

      // 加载更多指示器
      if (this.viewModel.isLoadingMore) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
  }
}

@ComponentV2
export struct TemplateCardView {
  @Prop template: Template
  @Prop onTemplateClick: (template: Template) => void

  build() {
    Column() {
      // 模板封面
      Stack() {
        Image(this.template.coverUrl)
          .width('100%')
          .height(200)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        // VIP标识
        if (this.template.isVipTemplate()) {
          Image($r('app.media.ic_vip'))
            .width(24)
            .height(24)
            .position({ x: 8, y: 8 })
        }

        // 播放按钮
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_play'))
            .width(20)
            .height(20)
        }
        .width(40)
        .height(40)
        .backgroundColor('rgba(0, 0, 0, 0.6)')
        .position({ x: '50%', y: '50%' })
        .translate({ x: -20, y: -20 })
        .onClick(() => {
          this.onTemplateClick(this.template)
        })
      }
      .width('100%')
      .height(200)

      // 模板信息
      Column() {
        Text(this.template.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })

        Row() {
          // 模板类型
          Text(this.template.getTemplateType())
            .fontSize(12)
            .fontColor('#999999')
            .backgroundColor('rgba(255, 255, 255, 0.1)')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)

          // 模板尺寸
          Text(`${this.template.width}x${this.template.height}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .margin({ top: 4 })
      }
      .width('100%')
      .padding(8)
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.onTemplateClick(this.template)
    })
  }
} 