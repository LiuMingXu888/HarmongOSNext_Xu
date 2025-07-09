/**
 * 筛选对话框视图组件 - 提供模板筛选功能
 * 遵循单一职责原则：只负责筛选功能的展示和交互
 * 使用V2装饰器实现响应式UI
 */
import { FilterTag, FilterCategory, FilterCell, FilterTabEnum } from '../../domain/entities/Filter'
import { MusicTemplateViewModel } from '../viewmodels/MusicTemplateViewModel'

@ComponentV2
export struct FilterDialogView {
  @Prop viewModel: MusicTemplateViewModel
  @State private currentTab: FilterTabEnum = FilterTabEnum.FRAGMENT
  @State private selectedFilters: any[] = []

  build() {
    Column() {
      // 对话框头部
      Row() {
        Text('筛选')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')

        Blank()

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_close'))
            .width(20)
            .height(20)
        }
        .width(32)
        .height(32)
        .backgroundColor('transparent')
        .onClick(() => {
          this.viewModel.hideFilterDialog()
        })
      }
      .width('100%')
      .padding(16)
      .border({ width: { bottom: 1 }, color: '#333333' })

      // 标签页
      Row() {
        ForEach([FilterTabEnum.FRAGMENT, FilterTabEnum.ATTRIBUTE, FilterTabEnum.SORT], (tab: FilterTabEnum) => {
          Text(this.getTabTitle(tab))
            .fontSize(14)
            .fontColor(this.currentTab === tab ? '#FF6B35' : '#999999')
            .fontWeight(this.currentTab === tab ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor(this.currentTab === tab ? 'rgba(255, 107, 53, 0.1)' : 'transparent')
            .borderRadius(20)
            .onClick(() => {
              this.currentTab = tab
            })
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceAround)

      // 筛选内容
      Scroll() {
        Column() {
          ForEach(this.viewModel.filterTags, (tag: FilterTag) => {
            FilterTagView({
              tag: tag,
              onFilterChange: (filters: any[]) => {
                this.selectedFilters = filters
              }
            })
          })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)

      // 底部操作按钮
      Row() {
        Button() {
          Text('重置')
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .backgroundColor('transparent')
        .border({ width: 1, color: '#FF6B35' })
        .borderRadius(24)
        .padding({ left: 32, right: 32, top: 12, bottom: 12 })
        .onClick(() => {
          this.resetFilters()
        })

        Button() {
          Text('确定')
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .backgroundColor('#FF6B35')
        .borderRadius(24)
        .padding({ left: 32, right: 32, top: 12, bottom: 12 })
        .margin({ left: 16 })
        .onClick(() => {
          this.applyFilters()
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('80%')
    .backgroundColor('#222222')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  private getTabTitle(tab: FilterTabEnum): string {
    switch (tab) {
      case FilterTabEnum.FRAGMENT:
        return '片段'
      case FilterTabEnum.ATTRIBUTE:
        return '属性'
      case FilterTabEnum.SORT:
        return '排序'
      default:
        return ''
    }
  }

  private resetFilters(): void {
    this.selectedFilters = []
    this.viewModel.resetFilter()
  }

  private applyFilters(): void {
    this.viewModel.applyFilter(this.selectedFilters)
    this.viewModel.hideFilterDialog()
  }
}

@ComponentV2
export struct FilterTagView {
  @Prop tag: FilterTag
  @Prop onFilterChange: (filters: any[]) => void

  build() {
    Column() {
      // 标签标题
      Text(this.tag.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .margin({ bottom: 12 })

      // 分类列表
      ForEach(this.tag.categories, (category: FilterCategory) => {
        FilterCategoryView({
          category: category,
          onSelectionChange: (selectedCells: FilterCell[]) => {
            // 处理选择变化
            this.onFilterChange(selectedCells)
          }
        })
      })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }
}

@ComponentV2
export struct FilterCategoryView {
  @Prop category: FilterCategory
  @Prop onSelectionChange: (selectedCells: FilterCell[]) => void

  build() {
    Column() {
      // 分类标题
      Text(this.category.title)
        .fontSize(14)
        .fontColor('#CCCCCC')
        .margin({ bottom: 8 })

      // 选项网格
      Grid() {
        ForEach(this.category.cells, (cell: FilterCell) => {
          FilterCellView({
            cell: cell,
            onToggle: () => {
              cell.toggleSelection()
              this.onSelectionChange(this.category.getSelectedCells())
            }
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}

@ComponentV2
export struct FilterCellView {
  @Prop cell: FilterCell
  @Prop onToggle: () => void

  build() {
    Text(this.cell.getDisplayText())
      .fontSize(12)
      .fontColor(this.cell.selected ? '#FFFFFF' : '#999999')
      .backgroundColor(this.cell.selected ? '#FF6B35' : 'rgba(255, 255, 255, 0.1)')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.onToggle()
      })
  }
} 