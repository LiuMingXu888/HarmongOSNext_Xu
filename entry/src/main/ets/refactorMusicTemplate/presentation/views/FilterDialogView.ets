/**
 * 筛选对话框视图组件 - 负责筛选功能的UI展示
 * 遵循单一职责原则：只负责筛选对话框的UI展示
 */
import { FilterTag, FilterCategory, FilterCell, FilterTabEnum } from '../../domain/entities/FilterEntity'

@ComponentV2
export struct FilterDialogView {
  @Require @Param isVisible: boolean
  @Require @Param filterTags: FilterTag[]
  @Require @Param currentFilterTab: FilterTabEnum
  @Require @Param inputValue: string
  @Require @Param onClose: () => void
  @Require @Param onApply: () => void
  @Require @Param onReset: () => void
  @Require @Param onInputChange: (value: string) => void
  @Require @Param onCellToggle: (categoryIndex: number, cellIndex: number) => void

  build() {
    if (this.isVisible) {
      Stack({ alignContent: Alignment.Top }) {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.Blank_8'))
          .onClick(() => {
            this.onClose()
          })

        // 筛选内容
        Column() {
          this.buildFilterContent()
        }
        .width("100%")
        .backgroundColor("#222222")
        .borderRadius({ topLeft: 12, topRight: 12 })
        .translate({ y: this.isVisible ? 0 : "-100%" })
        .animation({
          duration: 200,
          curve: Curve.EaseInOut
        })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildFilterContent() {
    Column() {
      // 标题栏
      Row() {
        Text("筛选")
          .fontSize(16)
          .fontWeight(500)
          .fontColor(Color.White)
          .layoutWeight(1)
        
        Image($r('app.media.close'))
          .width(20)
          .height(20)
          .onClick(() => {
            this.onClose()
          })
      }
      .width("100%")
      .padding({ top: 16, bottom: 16, left: 16, right: 16 })
      .borderWidth({ bottom: 1 })
      .borderColor("#33FFFFFF")

      // 筛选内容
      Scroll() {
        Column() {
          this.buildFilterCategories()
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部按钮
      this.buildBottomButtons()
    }
    .width("100%")
    .height("60%")
    .position({ bottom: 0 })
  }

  @Builder
  buildFilterCategories() {
    const currentTag = this.filterTags[this.currentFilterTab]
    if (!currentTag) return

    ForEach(currentTag.categories, (category: FilterCategory, categoryIndex: number) => {
      Column() {
        // 分类标题
        Text(category.title)
          .fontSize(14)
          .fontColor("#66FFFFFF")
          .margin({ top: 16, bottom: 12 })

        // 筛选选项网格
        Grid() {
          ForEach(category.cells, (cell: FilterCell, cellIndex: number) => {
            GridItem() {
              if (cell.supportEdit) {
                this.buildInputCell(cell)
              } else {
                this.buildOptionCell(cell, categoryIndex, cellIndex)
              }
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('repeat(auto-fill, 32)')
        .columnsGap(8)
        .rowsGap(8)
        .height(this.calculateGridHeight(category.cells.length))
      }
    })
  }

  @Builder
  buildInputCell(cell: FilterCell) {
    Row() {
      TextInput({
        text: this.inputValue,
        placeholder: cell.editPlaceholder || "请输入"
      })
        .maxLength(3)
        .padding(0)
        .borderRadius(0)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .placeholderColor("#4DFFFFFF")
        .placeholderFont({ size: 13 })
        .fontSize(13)
        .fontColor("#E5FFFFFF")
        .type(InputType.NUMBER_DECIMAL)
        .textAlign(TextAlign.Center)
        .caretStyle({ width: 1.5, color: "#F7365D" })
        .onChange((value: string) => {
          const numericValue = value.replace(/\D/g, '')
          this.onInputChange(numericValue)
        })
    }
    .width("100%")
    .height(32)
    .borderWidth({ bottom: 2 })
    .borderColor("#14FFFFFF")
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildOptionCell(cell: FilterCell, categoryIndex: number, cellIndex: number) {
    Row() {
      Text(cell.getDisplayText())
        .fontColor(cell.selected ? "#E5FFFFFF" : "#80FFFFFF")
        .fontSize(13)
    }
    .width("100%")
    .height(32)
    .justifyContent(FlexAlign.Center)
    .borderRadius(16)
    .backgroundColor(cell.selected ? "#33FFFFFF" : "#14FFFFFF")
    .onClick(() => {
      this.onCellToggle(categoryIndex, cellIndex)
    })
  }

  @Builder
  buildBottomButtons() {
    Row() {
      // 重置按钮
      Text("重置")
        .fontSize(14)
        .fontWeight(600)
        .fontColor(Color.White)
        .width(100)
        .height(44)
        .textAlign(TextAlign.Center)
        .borderRadius(22)
        .backgroundColor("#14FFFFFF")
        .onClick(() => {
          this.onReset()
        })

      // 确定按钮
      Text("确定")
        .fontSize(14)
        .fontWeight(600)
        .fontColor(Color.White)
        .width(231)
        .height(44)
        .textAlign(TextAlign.Center)
        .borderRadius(22)
        .linearGradient({
          angle: "135deg",
          colors: [
            [$r('app.color.btn_linear_gradient_color_1'), 0],
            [$r('app.color.btn_linear_gradient_color_2'), 0.5],
            [$r('app.color.btn_linear_gradient_color_3'), 1]
          ]
        })
        .onClick(() => {
          this.onApply()
        })
    }
    .width('100%')
    .padding({ top: 16, bottom: 16, left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 计算网格高度
  private calculateGridHeight(cellCount: number): number {
    const rows = Math.ceil(cellCount / 4)
    return rows * 32 + (rows - 1) * 8
  }
} 