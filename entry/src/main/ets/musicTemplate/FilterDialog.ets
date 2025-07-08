import { AppStorageV2 } from "@kit.ArkUI";
import { ScreenSize } from "common_util";
import { Category, Cell } from "temp_model";
import { MusicTemplateVM } from "../common/model/MusicSameTemplateModel";
import { FilterTabEnum } from "../common/model/MusicSameTemplateViewModel";

@ComponentV2
export struct FilterDialog {
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Local currentY: number | string = "-100%"
  @Local duration: number = 200
  @Local currentFilter: number = -1
  @Local inputText: string = ""
  @Require @Param musicTemplateVM: MusicTemplateVM
  @Require @Param fragmentText: string
  @Require @Param attributeText: string
  @Require @Param sortText: string

  btnBgColorsUn: Array<[Resource, number]> = [[$r('app.color.btn_linear_gradient_color_1'), 0], [$r('app.color.btn_linear_gradient_color_2'), 0.5], [$r('app.color.btn_linear_gradient_color_3'), 1]]

  @Monitor("musicTemplateVM.currentFilter")
  changeCurrentIndex() {
    if (this.musicTemplateVM.currentFilter != -1) {
      this.currentFilter = this.musicTemplateVM.currentFilter
    }
  }

  aboutToAppear(): void {
    this.musicTemplateVM.FilterDialogListener.closeDialog = () => {
      this.onDisAppearAnimation()
    }
  }

  build() {
    if (this.musicTemplateVM.isShowFilterDialog) {
      Stack({ alignContent: Alignment.Top }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.currentFilter == FilterTabEnum.FRAGMENT) {
            this.FragmentBuilder()
          } else if (this.currentFilter == FilterTabEnum.ATTRIBUTE) {
            this.AttributeBuilder()
          } else if (this.currentFilter == FilterTabEnum.SORT) {
            this.SortBuilder()
          }
        }
        .width("100%")
        .translate({ y: this.currentY })
        .onAppear(() => { this.onApperAnimation() })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.Blank_8'))
      .onClick(() => {
        this.onDisAppearAnimation()
      })
    }
  }

  @Builder
  FragmentBuilder() {
    Column() {
      ForEach(this.musicTemplateVM.filterData[FilterTabEnum.FRAGMENT].categories, (item: Category, index: number) => {
        Text(item.categoryTitle)
          .fontSize(13)
          .width('100%')
          .fontColor("#66FFFFFF")
          .margin({ top: 17, bottom: 12 })

        Grid() {
          ForEach(item.cells, (cell: Cell, i: number) => {
            if (cell.editPlaceholder) {
              GridItem() {
                Row() {
                  TextInput({
                    text: this.musicTemplateVM.inputValue || this.inputText, placeholder: "请输入片段数",
                  })
                    .maxLength(3)
                    .padding(0)
                    .borderRadius(0)
                    .layoutWeight(1)
                    .backgroundColor(Color.Transparent)
                    .placeholderColor("#4DFFFFFF")
                    .placeholderFont({ size: 13 })
                    .fontSize(13)
                    .fontWeight(400)
                    .fontColor("#E5FFFFFF")
                    .type(InputType.NUMBER_DECIMAL)
                    .textAlign(TextAlign.Center)
                    .caretStyle({ width: 1.5, color: "#F7365D" })
                    .onChange((value: string) => {
                      let str = value.replace(/\D/g, '');
                      this.inputText = str
                    })
                }
                .width("100%")
                .height(28)
                .borderWidth({ bottom: 2 })
                .borderColor("#14FFFFFF")
                .justifyContent(FlexAlign.Center)
              }
            } else {
              GridItem() {
                Row() {
                  Text(cell.cellContent || this.getTemplateFragmentTime(cell))
                    .fontColor(cell.isFilter ? "#E5FFFFFF" : "#80FFFFFF")
                    .fontSize(13)
                }
                .width("100%")
                .height(28)
                .justifyContent(FlexAlign.Center)
                .borderRadius(28)
                .backgroundColor(cell.isFilter ? "#33FFFFFF" : "#14FFFFFF")
                .onClick(() => {
                  cell.isFilter = !cell.isFilter
                })
              }
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('repeat(auto-fill, 28)')
        .columnsGap(10)
        .rowsGap(10)
        .height(this.getGridHeight(item.cells.length))
      })

      // 按钮区域
      Row() {
        Row() {
          Text("重置")
            .fontSize(13)
            .fontWeight(600)
            .fontColor(Color.White)
        }
        .width(100)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(26)
        .backgroundColor("#14FFFFFF")
        .onClick(() => {
          this.musicTemplateVM.filterData[FilterTabEnum.FRAGMENT].categories.forEach(e => {
            e.cells.forEach(e => {
              e.selected = false
              e.isFilter = false
            })
          })
        })
        Row() {
          Text("确定")
            .fontSize(13)
            .fontWeight(600)
            .fontColor(Color.White)
        }
        .width(231)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(26)
        .linearGradient({
          angle: "135deg",
          colors: this.btnBgColorsUn
        })
        .onClick(() => {
          this.musicTemplateVM.inputValue = this.inputText
          this.onDisAppearAnimation(true)
        })
      }
      .width('100%')
      .margin({ top: 15, bottom: 15 })
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width("100%")
    .padding({ left: 16, right: 16 })
    .backgroundColor("#222222")
  }

  @Builder
  AttributeBuilder() {
    Column() {
      ForEach(this.musicTemplateVM.filterData[FilterTabEnum.ATTRIBUTE].categories, (item: Category, index: number) => {
        Text(item.categoryTitle)
          .fontSize(13)
          .width('100%')
          .fontColor("#66FFFFFF")
          .margin({ top: 17, bottom: 12 })

        Grid() {
          ForEach(item.cells, (cell: Cell, i: number) => {
            GridItem() {
              Row() {
                Text(cell.cellContent || this.getTemplateTime(cell))
                  .fontColor(cell.isFilter ? "#E5FFFFFF" : "#80FFFFFF")
                  .fontSize(13)
              }
              .width("100%")
              .height(28)
              .justifyContent(FlexAlign.Center)
              .borderRadius(28)
              .backgroundColor(cell.isFilter ? "#33FFFFFF" : "#14FFFFFF")
              .onClick(() => {
                cell.isFilter = !cell.isFilter
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('repeat(auto-fill, 28)')
        .columnsGap(10)
        .rowsGap(10)
        .height(this.getGridHeight(item.cells.length))
      })

      // 按钮区域
      Row() {
        Row() {
          Text("重置")
            .fontSize(13)
            .fontWeight(600)
            .fontColor(Color.White)
        }
        .width(100)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(26)
        .backgroundColor("#14FFFFFF")
        .onClick(() => {
          this.musicTemplateVM.filterData[FilterTabEnum.ATTRIBUTE].categories.forEach(e => {
            e.cells.forEach(e => {
              e.selected = false
              e.isFilter = false
            })
          })
        })
        Row() {
          Text("确定")
            .fontSize(13)
            .fontWeight(600)
            .fontColor(Color.White)
        }
        .width(231)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(26)
        .linearGradient({
          angle: "135deg",
          colors: this.btnBgColorsUn
        })
        .onClick(() => {
          this.onDisAppearAnimation(true)
        })
      }
      .width('100%')
      .margin({ top: 15, bottom: 15 })
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width("100%")
    .padding({ left: 16, right: 16 })
    .backgroundColor("#222222")
  }

  @Builder
  SortBuilder() {
    Column() {
      ForEach(this.musicTemplateVM.filterData[FilterTabEnum.SORT].categories[0].cells, (cell: Cell, index: number) => {
        Row() {
          Text(cell.cellContent)
            .fontSize(13)
            .fontColor(cell.selected ? 'rgba(255, 255, 255, 0.9)' : 'rgba(255, 255, 255, 0.5)')

          if (cell.selected) {
            Image($r("app.media.template_full_music_ok"))
              .width(20)
              .aspectRatio(1)
          }
        }
        .height(34)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.musicTemplateVM.filterData[FilterTabEnum.SORT].categories[0].cells.forEach((e) => e.selected = false)
          cell.selected = !cell.selected
          this.onDisAppearAnimation(true)
        })
      })
    }
    .width("100%")
    .padding({ top: 10, bottom: 10, left: 16, right: 16 })
    .backgroundColor("#222222")
  }

  getTemplateTime(cell: Cell) {
    if (cell.cellContentStart < 10) {
      return "<10秒"
    } else if (cell.cellContentStart < 30) {
      return "10-30秒"
    } else {
      return ">30秒"
    }
  }

  getTemplateFragmentTime(cell: Cell) {
    if (cell.cellContentStart < 5) {
      return cell.cellContentStart.toString()
    } else if (cell.cellContentStart == 5) {
      return "5-10"
    } else {
      return ">10"
    }
  }

  getGridHeight(length: number) {
    return Math.ceil(length / 4) * 28 + (Math.ceil(length / 4) - 1) * 10
  }

  onApperAnimation() {
    animateTo({ duration: this.duration }, () => {  this.currentY = 0 } )
  }

  onDisAppearAnimation(isSure: boolean = false) {
    this.musicTemplateVM.currentFilter = -1
    this.inputText = this.musicTemplateVM.inputValue
    if (isSure) {
      // TODO 设置一个留存的状态的数组，如果不为isSure 之前的状态都清空
      this.setSelectStatus(true)
      this.musicTemplateVM.getMusicCollection(false, true)
    } else {
      this.setSelectStatus(false)
    }
    this.musicTemplateVM.changeImageAnimation(this.currentFilter, 0)
    animateTo({ duration: this.duration }, () => {
      this.currentY = "-100%"
    } )
    setTimeout(() => {
      this.musicTemplateVM.isShowFilterDialog = false
    }, this.duration)
  }

  setSelectStatus(isFilter: boolean) {
    this.musicTemplateVM.filterData.forEach(item => {
      item.categories.forEach(ele => {
        ele.cells.forEach(e => {
          if (isFilter) {
            e.selected = e.isFilter!
          } else {
            e.isFilter = e.selected
          }
        })
      })
    })
  }
}
