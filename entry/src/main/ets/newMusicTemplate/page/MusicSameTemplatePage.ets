import { Logger, NetworkUtil, ScreenSize } from 'common_util'
import { AppStorageV2 } from '@kit.ArkUI'
import { KPage, UriRequest } from '@kwai/krouter'
import { KyNavigationTop, NoNetwork, RefreshLoading } from 'component_common_widget'
import { QCurrentUser } from 'user_model'
import { USER_LOGIN_EVENT } from 'login_event'
import { KEventBus, KEventData } from '@kwai/eventbus'
import MVList from '../service/mvList'
import { FullMusicDialog } from '../dialogs/FullMusicDialog'
import { CollectionDialog } from '../dialogs/CollectionDialog.ets'
import { MusicInfoView } from '../view/MusicInfoView'
import { TemplateCardView } from '../view/TemplateCardView'
import { ITemplateApiServer, TemplateApi } from '../common/model/TempApiServer'
import { TemplateVM } from '../common/model/TempVM'
import { TempDialogVM } from '../common/model/TempDialogVM'
import { TempMusicVM } from '../common/model/TempMusicVM'
import { TempWaterFlowVM } from '../common/model/TempWaterFlowVM'
import { TempFilterVM } from '../common/model/TempFilterVM'

export const MUSIC_TEMPLATE_TAG = 'MUSIC_TEMPLATE_TAG'
export const Collection_MUSIC_TYPE = 10000

/**
 * 音乐同款模板页面
 **/

@KPage({ paths: ['musicSameTemplatePage'] })
@ComponentV2
export struct MusicSameTemplatePage {
  @Param request: UriRequest = UriRequest.create('kwaiying://musicSameTemplatePage')
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Provider() templateVM: TemplateVM = new TemplateVM() // 音乐模板全局的VM
  @Provider() templateApi: ITemplateApiServer = new TemplateApi() // API

  fullMusicDialog: TempDialogVM = new TempDialogVM() // 完整音乐的弹窗
  collectionMusicDialog: TempDialogVM = new TempDialogVM() // 收藏音乐的弹窗

  tempMusicVM: TempMusicVM = new TempMusicVM()
  fullMusicVM: TempMusicVM = new TempMusicVM()

  tempWaterFlowVM: TempWaterFlowVM = new TempWaterFlowVM() // 音乐模板列表
  recommendWaterFlowVM: MVList = new MVList({ channelId: '' }) // 推荐音乐的懒加载数据
  tempFilterVM: TempFilterVM = new TempFilterVM()

  @Local yOffset: number = 0 // y轴滚动偏移量
  @Local maxScrollHiddenRange: number = 80 // 最大滚动的距离

  backPressedHandel: () => void = () => {}
  loginCallback = (value: KEventData<string>) => {
    this.templateVM.uiState.uid = QCurrentUser.getUid()
    Logger.i(MUSIC_TEMPLATE_TAG, "用户登录成功")
  }

  aboutToAppear(): void {
    this.initData()
  }

  aboutToDisappear(): void {
    KEventBus.unsubscribe<string>(USER_LOGIN_EVENT, this.loginCallback)
  }

  async initData() {
    this.templateVM.uiState.isNetWork = NetworkUtil.getInstance().isNetworkAvailable()
    if (!this.templateVM.uiState.isNetWork) {
      this.templateVM.uiState.requestComplete = true
      return
    }
    KEventBus.subscribe<string>(USER_LOGIN_EVENT, this.loginCallback)
    this.templateVM.uiState.uid = QCurrentUser.getUid()
    if (this.request.hasExtra()) {
      this.templateVM.businessData.templateInfo = this.request.getExtra("templateInfo", null)
      this.templateVM.businessData.tempTable = this.request.getExtra("TempTableItem", null)
      this.recommendWaterFlowVM = new MVList({ channelId: this.templateVM.businessData.tempTable!.id })
      this.templateVM = new TemplateVM(
        this.tempWaterFlowVM,
        this.recommendWaterFlowVM,
        this.tempMusicVM,
        this.fullMusicVM,
        this.collectionMusicDialog,
        this.fullMusicDialog
      )
      this.backPressedHandel = this.request.getExtra("backPressedHandel", () => {})
      this.templateVM.businessData.collectionArr = await this.templateApi.getCollectionMusicArr(this.templateVM.uiState.uid)
      await this.tempMusicVM.setUpMusic(this.templateVM.businessData.templateInfo!.music!, true)
      this.templateVM.businessData.filterData = await this.templateApi.getFilterArr(this.templateVM.businessData.templateInfo!);
    }
  }

  build() {
    NavDestination() {
      if (!this.templateVM.uiState.requestComplete) {
        RefreshLoading()
      } else if (!this.templateVM.uiState.isNetWork) {
        Column() {
          NoNetwork({ buttonCallback: () => {
            this.templateVM.uiState.requestComplete = false
            setTimeout(() => {
              this.initData()
            }, 50)
          } })
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Center)
      } else {
        Stack({ alignContent: Alignment.Top }) {
          // 背景模糊区
          Image(this.templateVM.businessData.templateInfo?.coverUrlBackupUrls[0])
            .width("100%")
            .height(350)
            .foregroundBlurStyle(BlurStyle.Thin, {
              colorMode: ThemeColorMode.DARK,
              adaptiveColor: AdaptiveColor.DEFAULT,
              scale: 0.7
            })

          // 顶部导航区
          KyNavigationTop({
            title: $r('app.string.music_same_template'),
          })
            .zIndex(10)

          // 滚动布局
          Scroll() {
            Column() {
              Blank().width("100%").height(50 + this.screenSize.topAreaHeight)
              // 顶部音乐相关内容
              MusicInfoView({
                musicVM: this.tempMusicVM,
                fullMusicDialog: this.fullMusicDialog,
                targetOpacity: this.targetOpacity,
              })

              // 底部模板卡片显示
              Scroll() {
                TemplateCardView({
                  tempWaterFlowVM: this.tempWaterFlowVM,
                  recommendWaterFlowVM: this.recommendWaterFlowVM,
                  tempFilterVM: this.tempFilterVM
                })
              }
              .width('100%')
              .height(`calc(100% - ${50 + this.screenSize.topAreaHeight}vp)`)
              .clip(true)
              .align(Alignment.TopStart)
              .borderRadius({ topLeft: 12, topRight: 12 })
              .backgroundColor("#222222")
              .edgeEffect(EdgeEffect.None, { alwaysEnabled: false })
              .scrollBar(BarState.Off)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .onWillScroll((xOffset, yOffset) => {
            this.yOffset += yOffset
          })
          .onReachStart(() => {
            this.yOffset = 0
          })

          // 完整音乐的弹窗
          FullMusicDialog({
            dialogVM: this.fullMusicDialog,
            musicVM: this.fullMusicVM
          })
            .zIndex(11)

          // 收藏音乐指引的弹窗
          CollectionDialog({
            dialogVM: this.collectionMusicDialog
          })
            .zIndex(11)
        }
        .width("100%")
        .height("100%")
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      }
    }
    .backgroundColor($r('app.color.tab_main_bgcolor'))
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onHidden(() => {
      this.tempMusicVM.pause()
      this.fullMusicVM.pause()
    })
    .onBackPressed(() => {
      if (this.collectionMusicDialog.isShowDialog) {
        this.collectionMusicDialog.closeDialog()
        return true
      } else if (this.fullMusicDialog.isShowDialog) {
        this.fullMusicDialog.closeDialog()
        return true
      }
      this.backPressedHandel()
      this.tempMusicVM.reset()
      this.fullMusicVM.reset()
      return false
    })
  }

  // 计算透明度
  @Computed
  get targetOpacity() {
    let targetOpacity: number = 1
    if (this.yOffset <= 0) {
      targetOpacity = 1; // 顶部时完全显示
    } else if (this.yOffset >= this.maxScrollHiddenRange) {
      targetOpacity = 0; // 超过阈值时完全隐藏
    } else {
      // 线性计算透明度（0~300之间渐变）
      targetOpacity = 1 - (this.yOffset / this.maxScrollHiddenRange);
    }
    return targetOpacity
  }

  // 获取逻辑列表
  @Monitor("templateVM.uiState.uid")
  async setCollection() {
    this.templateVM.businessData.collectionArr = await this.templateApi.getCollectionMusicArr(this.templateVM.uiState.uid)
    this.templateVM.uiState.isCollection = this.templateVM.businessData.collectionArr.some(e => e.id == this.templateVM.businessData.musicTemplate?.description.encryptMusicId)
    this.templateVM.uiState.fullMusicIsCollection = this.templateVM.businessData.collectionArr.some(e => e.id == this.templateVM.businessData.musicTemplate?.description.completeMusic?.encryptMusicId)
  }

}

