/**
 * 模板列表视图组件 - 负责模板列表的展示和交互
 * 遵循单一职责原则：只负责模板列表的UI展示
 */
import { TemplateEntity } from '../../domain/entities/TemplateEntity'
import { FilterTag, FilterTabEnum } from '../../domain/entities/FilterEntity'
import { RefreshLoading } from 'component_common_widget'

@ComponentV2
export struct TemplateListView {
  @Require @Param templateList: TemplateEntity[]
  @Require @Param filterTags: FilterTag[]
  @Require @Param isLoading: boolean
  @Require @Param isRefreshing: boolean
  @Require @Param hasMoreData: boolean
  @Require @Param currentFilterTab: FilterTabEnum
  @Require @Param onTemplateClick: (template: TemplateEntity, index: number) => void
  @Require @Param onFilterTabClick: (tabIndex: FilterTabEnum) => void
  @Require @Param onLoadMore: () => void
  @Require @Param onReachEnd: () => void
  @Require @Param columnsTemplate: string = '1fr 1fr'
  @Require @Param screenWidth: number

  build() {
    Column() {
      // 筛选标签栏
      this.buildFilterTabs()
      
      // 模板列表
      this.buildTemplateList()
    }
  }

  @Builder
  buildFilterTabs() {
    Row() {
      ForEach(this.filterTags, (tag: FilterTag, index: number) => {
        Text() {
          Span(this.getFilterText(index))
            .fontSize(13)
            .lineHeight(16)
            .fontColor(this.isFilterActive(index) ? Color.White : "#66FFFFFF")
          ImageSpan(this.getFilterIcon(index))
            .width(10)
            .aspectRatio(1)
            .verticalAlign(ImageSpanAlignment.CENTER)
            .margin({ left: 6 })
            .rotate({ angle: this.getFilterIconRotation(index) })
        }
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .height("100%")
        .onClick(() => {
          this.onFilterTabClick(index)
        })
      })
    }
    .width("100%")
    .height(44)
    .borderWidth({ bottom: 1 })
    .borderColor("#66FFFFFF")
    .backgroundColor("#222222")
    .justifyContent(FlexAlign.SpaceEvenly)
    .zIndex(11)
  }

  @Builder
  buildTemplateList() {
    Scroll() {
      Column() {
        if (this.templateList.length > 0) {
          WaterFlow({
            footer: this.buildLoadMoreFooter(),
            layoutMode: WaterFlowLayoutMode.ALWAYS_TOP_DOWN
          }) {
            LazyForEach(this.templateList, (template: TemplateEntity, index: number) => {
              this.buildTemplateItem(template, index)
            }, (template: TemplateEntity) => template.id)
          }
          .rowsGap(8)
          .columnsGap(8)
          .columnsTemplate(this.columnsTemplate)
          .layoutDirection(FlexDirection.Column)
        } else if (!this.isLoading) {
          this.buildEmptyState()
        }
      }
    }
    .width("100%")
    .height(`calc(100% - ${44}vp)`)
    .padding({ left: 16, right: 16, top: 6 })
    .edgeEffect(EdgeEffect.None, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onReachEnd(() => {
      this.onReachEnd()
    })
  }

  @Builder
  buildTemplateItem(template: TemplateEntity, index: number) {
    Column() {
      // 模板封面
      Image(template.coverUrl)
        .width("100%")
        .aspectRatio(template.getAspectRatio())
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      
      // 模板信息
      Row() {
        Text(template.name)
          .fontSize(12)
          .fontColor(Color.White)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        if (template.isVipTemplate()) {
          Image($r("app.media.vip_icon"))
            .width(16)
            .aspectRatio(1)
        }
      }
      .width("100%")
      .padding({ top: 4, bottom: 4 })
    }
    .width("100%")
    .onClick(() => {
      this.onTemplateClick(template, index)
    })
  }

  @Builder
  buildLoadMoreFooter() {
    Column() {
      if (this.isRefreshing && this.hasMoreData) {
        RefreshLoading()
          .width('100%')
          .height(60)
      } else if (!this.hasMoreData) {
        Text("— 已加载全部内容 —")
          .width('100%')
          .fontSize(12)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
          .opacity(0.5)
      }
    }
    .padding({ top: 34, bottom: 20 })
  }

  @Builder
  buildEmptyState() {
    Column() {
      Image($r("app.media.empty_state"))
        .width(120)
        .aspectRatio(1)
        .margin({ bottom: 16 })
      
      Text("暂无相关模板")
        .fontSize(14)
        .fontColor(Color.White)
        .opacity(0.6)
    }
    .width("100%")
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 辅助方法
  private getFilterText(index: number): string {
    const tag = this.filterTags[index]
    if (!tag) return ''
    
    const selectedCategories = tag.getSelectedCategories()
    if (selectedCategories.length === 0) return tag.title
    
    const selectedCells = selectedCategories[0].getSelectedCells()
    if (selectedCells.length === 0) return tag.title
    
    return selectedCells[0].getDisplayText()
  }

  private isFilterActive(index: number): boolean {
    return this.currentFilterTab === index
  }

  private getFilterIcon(index: number): Resource {
    return this.isFilterActive(index) 
      ? $r('app.media.template_result_close_selected') 
      : $r("app.media.template_show_filter")
  }

  private getFilterIconRotation(index: number): number {
    // 根据筛选状态返回旋转角度
    return this.isFilterActive(index) ? 180 : 0
  }

  // 计算模板项高度
  getTemplateItemHeight(template: TemplateEntity): number {
    const itemWidth = (this.screenWidth - 32 - 8) / this.columnsTemplate.split(" ").length
    const aspectRatio = template.getAspectRatio()
    const imageHeight = itemWidth / aspectRatio
    return imageHeight + 40 // 40是文字区域的高度
  }
} 