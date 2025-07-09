
// 模板弹窗的类
@ObservedV2
export class TempDialogVM {
  @Trace isShowDialog: boolean = false
  @Trace currentY: number | string = 441

  maxHeight: number = 441
  duration: number = 300
  btnBgColorsUn: Array<[Resource, number]> = [[$r('app.color.btn_linear_gradient_color_1'), 0], [$r('app.color.btn_linear_gradient_color_2'), 0.5], [$r('app.color.btn_linear_gradient_color_3'), 1]]

  // 打开弹窗
  openDialog() {
    animateTo({
      duration: this.duration
    }, () => {
      this.currentY = 0
    })
  }

  // 关闭弹窗
  closeDialog() {
    animateTo({
      duration: this.duration
    }, () => {
      this.currentY = this.maxHeight
    })
    setTimeout(() => {
      this.isShowDialog = false
    }, this.duration)
  }
}
