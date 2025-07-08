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
import { MusicTemplateVM } from '../common/model/MusicSameTemplateModel'
import { PaddingCollectionType } from '../common/model/MusicSameTemplateViewModel'
import { MusicInfoView } from '../view/MusicInfoView'
import { TemplateCardView } from '../view/TemplateCardView'

export const MUSIC_TEMPLATE_TAG = 'MUSIC_TEMPLATE_TAG'
export const Collection_MUSIC_TYPE = 10000

@KPage({ paths: ['musicSameTemplatePage'] })
@ComponentV2
export struct MusicSameTemplatePage {
  @Param request: UriRequest = UriRequest.create('kwaiying://musicSameTemplatePage')
  @Local screenSize: ScreenSize = AppStorageV2.connect(ScreenSize, () => new ScreenSize())!;
  @Provider() musicTemplateVM: MusicTemplateVM = new MusicTemplateVM()
  @Local yOffset: number = 0 // y轴滚动偏移量
  @Local maxScrollHiddenRange: number = 80 // 最大滚动的距离
  backPressedHandel: () => void = () => {}
  loginCallback = (value: KEventData<string>) => {
    this.musicTemplateVM.uid = QCurrentUser.getUid()
    Logger.i(MUSIC_TEMPLATE_TAG, "用户登录成功")
  }

  aboutToAppear(): void {
    this.initData()
  }

  aboutToDisappear(): void {
    KEventBus.unsubscribe<string>(USER_LOGIN_EVENT, this.loginCallback)
  }

  initData() {
    this.musicTemplateVM.isNetWork = NetworkUtil.getInstance().isNetworkAvailable()
    if (!this.musicTemplateVM.isNetWork) {
      this.musicTemplateVM.isRefreshing = false
      return
    }
    KEventBus.subscribe<string>(USER_LOGIN_EVENT, this.loginCallback)
    this.musicTemplateVM.uid = QCurrentUser.getUid()
    if (this.request.hasExtra()) {
      this.musicTemplateVM.templateInfo = this.request.getExtra("templateInfo", null)
      this.musicTemplateVM.tempTable = this.request.getExtra("TempTableItem", null)
      this.backPressedHandel = this.request.getExtra("backPressedHandel", () => {})
      this.musicTemplateVM.setUpMusic(this.musicTemplateVM.templateInfo!.music!.musicUrl)
      this.musicTemplateVM.getCollectionMusic()
      this.musicTemplateVM.getFilterData()
      this.musicTemplateVM.dataSource = new MVList({ channelId: this.musicTemplateVM.tempTable!.id })
      this.musicTemplateVM.getMusicCollection(true)
    }
  }

  build() {
    NavDestination() {
      if (this.musicTemplateVM.isRefreshing) {
        RefreshLoading()
      } else if (!this.musicTemplateVM.isNetWork) {
        Column() {
          NoNetwork({ buttonCallback: () => {
            this.musicTemplateVM.isRefreshing = true
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
          Image(this.musicTemplateVM.templateInfo?.coverUrlBackupUrls[0])
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

          Scroll() {
            Column() {
              Blank().width("100%").height(50 + this.screenSize.topAreaHeight)
              // 顶部音乐相关内容
              MusicInfoView({ targetOpacity: this.targetOpacity })

              // 底部模板卡片显示
              Scroll() {
                TemplateCardView()
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

          FullMusicDialog({
            musicTemplateVM: this.musicTemplateVM,
            dialogListener: this.musicTemplateVM.MusicDialogListener
          })
            .zIndex(11)
          CollectionDialog({
            canShow: this.musicTemplateVM.isShowCollectionDialog,
            $canShow: (val: boolean) => {
              this.musicTemplateVM.isShowCollectionDialog = val
            },
            dialogListener: this.musicTemplateVM.CollectionDialogListener
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
      this.musicTemplateVM.isPlaying = false
      this.musicTemplateVM.audioPlayerManager?.pauseAudioPlay()
      this.musicTemplateVM.MusicDialogListener.pageHidden?.()
    })
    .onBackPressed(() => {
      if (this.musicTemplateVM.isShowCollectionDialog) {
        this.musicTemplateVM.CollectionDialogListener.closeDialog?.()
        return true
      } else if (this.musicTemplateVM.isShowFullMusicDialog) {
        this.musicTemplateVM.MusicDialogListener.closeDialog?.()
        return true
      }
      this.backPressedHandel()
      this.musicTemplateVM.resetMusic()
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
  @Monitor("musicTemplateVM.uid")
  setCollection() {
    this.musicTemplateVM.getCollectionMusic()
  }

  // 获取逻辑列表
  @Monitor("musicTemplateVM.uid")
  setCollectionState() {
    let isFullMusic = this.musicTemplateVM.paddingCollectionType == PaddingCollectionType.FULL_MUSIC
    this.musicTemplateVM.collectionMusic(undefined, isFullMusic)
  }
}

