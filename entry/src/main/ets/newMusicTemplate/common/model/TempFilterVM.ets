import { TempDialogVM } from "./TempDialogVM"
import { DialogListener, FilterTabEnum } from "./TempModel"

@ObservedV2
export class TempFilterVM extends TempDialogVM {
  @Trace currentFilter: number = -1 // 当前选中的索引
  @Trace fragmentTitle: string = ""
  @Trace attributeTitle: string = ""
  @Trace sortTitle: string = ""
  @Trace fragmentImageAngle: number = 0
  @Trace attributeImageAngle: number = 0
  @Trace sortImageAngle: number = 0
  @Trace inputValue: string = ""
  closeDialog: () => void = () => {}

  constructor() {
    super()
    this.currentY = "-100%"
    this.duration = 200
  }

  // 点击筛选
  openFilterDialog(index: number) {
    // 重置当前的数据，还有筛选的功能
    if (this.currentFilter == index) {
      this.changeImageAnimation(index)
      this.closeDialog()
    } else {
      this.changeImageAnimation(index, 180)
      this.changeImageAnimation(this.currentFilter, 0)
      this.isShowDialog = true
      this.currentFilter = index
    }
  }

  // 改变箭头动画
  changeImageAnimation(index: number, angle: number = 0) {
    if (index == FilterTabEnum.FRAGMENT) {
      animateTo({ duration: 200 }, () => { this.fragmentImageAngle = angle })
    } else if (index == FilterTabEnum.ATTRIBUTE) {
      animateTo({ duration: 200 }, () => { this.attributeImageAngle = angle })
    } else if (index == FilterTabEnum.SORT) {
      animateTo({ duration: 200 }, () => { this.sortImageAngle = angle })
    }
  }
}