import { Logger, ScreenSize } from "common_util"
import { RefreshLoading } from "component_common_widget"
import { AllTag } from "temp_model"
import { MusicTemplateVM } from "../common/model/MusicSameTemplateModel"
import { FeedDefault, FeedTemplate } from "../components/temp/TempContentInnerListItem"
import { TemplateInfos } from "../components/temp/TempContentInnerWaterFlow"
import { FilterDialog } from "../dialogs/FilterDialog"
import { MUSIC_TEMPLATE_TAG } from "../pages/MusicSameTemplatePage"
import { TempItem } from "../service/type"
import { AppStorageV2 } from "@kit.ArkUI"
import { FilterTabEnum } from "../common/model/MusicSameTemplateViewModel"


@ComponentV2
export struct TemplateCardView {
  @Consumer() musicTemplateVM: MusicTemplateVM = new MusicTemplateVM()
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Local columnsItem: number = 2 // 当前的列数
  @Local columnsTemplate: string = '1fr 1fr'

  aboutToAppear(): void {
    this.setItemNumber()
  }

  build() {
    Column() {
      Row() {
        ForEach(this.musicTemplateVM.filterData, (item: AllTag, index: number) => {
          Text() {
            Span(
              index == 0 ? (this.fragmentText != "" ? this.fragmentText : item.title)
                : index == 1 ? (this.attributeText != "" ? this.attributeText : item.title)
                : (this.sortText != "" ? this.sortText : item.title)
            )
              .fontSize(13)
              .lineHeight(16)
              .fontColor((this.musicTemplateVM.currentFilter == index
                || (index == 0 && this.fragmentText != "")
                || (index == 1 && this.attributeText != "")
                || (index == 2 && this.sortText != ""))
                ? Color.White : "#66FFFFFF")
            ImageSpan(
              (this.musicTemplateVM.currentFilter == index
                || (index == 0 && this.fragmentText != "")
                || (index == 1 && this.attributeText != "")
                || (index == 2 && this.sortText != ""))
                ? $r('app.media.template_result_close_selected') : $r("app.media.template_show_filter"))
              .width(10)
              .aspectRatio(1)
              .verticalAlign(ImageSpanAlignment.CENTER)
              .margin({ left: 6 })
              .rotate({ angle: index == FilterTabEnum.FRAGMENT
                ? this.musicTemplateVM.fragmentImageAngle
                : index == FilterTabEnum.ATTRIBUTE
                  ? this.musicTemplateVM.attributeImageAngle
                  : this.musicTemplateVM.sortImageAngle
              })
          }
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height("100%")
          .onClick(() => {
            this.musicTemplateVM.openFilterDialog(index)
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

      // 弹窗
      FilterDialog({
        musicTemplateVM: this.musicTemplateVM,
        fragmentText: this.fragmentText,
        attributeText: this.attributeText,
        sortText: this.sortText,
      })
        .position({ top: 44 })
        .zIndex(10)

      Scroll() {
        Column() {
          // 音乐同款
          if (!this.musicTemplateVM.musicSameData.isEmpty) {
            WaterFlow({
              footer: this.customLoadMoreComponent(this.musicTemplateVM.musicSameDataHasMore),
              layoutMode: WaterFlowLayoutMode.ALWAYS_TOP_DOWN
            }) {
              LazyForEach(this.musicTemplateVM.musicSameData, (item: TempItem, index: number) => {
                if (item != null) {
                  FeedTemplate({
                    item: item.templateInfo
                  })
                    .height(this.getItemHeight(item.templateInfo as TemplateInfos))
                    .onClick(() => {
                      this.musicTemplateVM.onClickTemplate(item.templateInfo as TemplateInfos, index)
                    })
                } else {
                  FeedDefault()
                }
              }, (item: TempItem, index: number) => {
                return item.templateInfo?.id ?? ''
              })
            }
            .rowsGap(8)
            .columnsGap(8)
            .columnsTemplate(this.columnsTemplate)
            .layoutDirection(FlexDirection.Column)
          }

          if (!this.musicTemplateVM.musicSameDataHasMore) {
            Text(`—  暂无更多使用相同音乐片段的模板，为你推荐  —`)
              .width("100%")
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .lineHeight(15)
              .fontColor(Color.White)
              .opacity(0.5)
              .margin({ top: 24, bottom: 16 })

            WaterFlow({
              footer: this.customLoadMoreComponent(this.musicTemplateVM.dataSource.hasMore),
              layoutMode: WaterFlowLayoutMode.ALWAYS_TOP_DOWN
            }) {
              LazyForEach(this.musicTemplateVM.dataSource, (item: TempItem, index: number) => {
                if (item.templateInfo != null) {
                  FeedTemplate({
                    item: item.templateInfo
                  })
                    .height(this.getItemHeight(item.templateInfo as TemplateInfos))
                    .onClick(() => {
                      this.musicTemplateVM.onClickTemplate(item.templateInfo as TemplateInfos, index)
                    })
                } else {
                  FeedDefault()
                }
              }, (item: TempItem, index: number) => {
                return item.templateInfo?.id ?? ''
              })
            }
            .rowsGap(8)
            .columnsGap(8)
            .columnsTemplate(this.columnsTemplate)
            .layoutDirection(FlexDirection.Column)
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
        Logger.i(MUSIC_TEMPLATE_TAG, "大列表触底")
        this.musicTemplateVM.getMusicCollection()
      })
    }
  }

  @Builder
  customLoadMoreComponent(isHasMore: boolean) {
    Column() {
      if (isHasMore && this.musicTemplateVM.isMoreDataLoading) {
        RefreshLoading().width('100%').height(60)
      } else if (!this.musicTemplateVM.dataSource.hasMore) {
        Text($r('app.string.end'))
          .width('100%').fontSize(12)
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.White_05'))
      }
    }.padding({
      top: 34,
      bottom: this.screenSize.bottomAreaHeight,
    })
  }

  get fragmentText() {
    let str = ""
    for (let index = 0; index < this.musicTemplateVM.filterData[FilterTabEnum.FRAGMENT].categories.length; index++) {
      for (let i = 0; i < this.musicTemplateVM.filterData[FilterTabEnum.FRAGMENT].categories[index].cells.length; i++) {
        const ele = this.musicTemplateVM.filterData[FilterTabEnum.FRAGMENT].categories[index].cells[i];
        if (ele.selected) {
          if (str != "") {
            str += "段..."
            return str
          }
          let realStr = ""
          if (ele.cellContent != "") {
            realStr = ele.cellContent
          } else if (ele.cellContentEnd > 999) {
            realStr = ">10"
          } else if (ele.cellContentStart != ele.cellContentEnd) {
            realStr = ele.cellContentStart + "-" + ele.cellContentEnd
          } else {
            realStr = ele.cellContentStart.toString()
          }
          str += realStr
        }
      }
    }
    if (str != "") str += "段"
    return str
  }

  get attributeText() {
    let str = ""
    for (let index = 0; index < this.musicTemplateVM.filterData[FilterTabEnum.ATTRIBUTE].categories.length; index++) {
      for (let i = 0; i < this.musicTemplateVM.filterData[FilterTabEnum.ATTRIBUTE].categories[index].cells.length; i++) {
        const ele = this.musicTemplateVM.filterData[FilterTabEnum.ATTRIBUTE].categories[index].cells[i];
        if (ele.selected) {
          if (str != "") {
            str += "..."
            return str
          }
          let realStr = ""
          if (ele.cellContent != "") {
            realStr = ele.cellContent
          } else if (ele.cellContentEnd > 999) {
            realStr = ">30秒"
          } else if (ele.cellContentEnd >= 30) {
            realStr = "10-30秒"
          } else if (ele.cellContentEnd >= 10) {
            realStr = "<10秒"
          } else {
            realStr = ele.cellContentStart.toString()
          }
          str += realStr
        }
      }
    }
    return str
  }

  get sortText() {
    let index = this.musicTemplateVM.filterData[FilterTabEnum.SORT].categories[0].cells.findIndex((e) => e.selected == true)
    if (index != -1 && index != 0) {
      return this.musicTemplateVM.filterData[FilterTabEnum.SORT].categories[0].cells[index].cellContent
    }
    return ""
  }

  @Monitor('screenSize.width')
  setItemNumber() {
    this.columnsItem = Math.floor((this.screenSize.width - 32 + 8) / (168 + 8))
    this.columnsItem = this.columnsItem < 2 ? 2 : this.columnsItem
    this.columnsTemplate = "1fr ".repeat(this.columnsItem).trim();
  }

  // 获取该信息高度
  getItemHeight(items: TemplateInfos) {
    const w = (this.screenSize.width - 32 - 8) / this.columnsTemplate.split(" ").length
    const h = w / (items.templateBean.width / items.templateBean.height)
    if (items.verticalList && items.verticalList.outflowIcon) {
      return h + 91
    }
    return h + 64
  }
}