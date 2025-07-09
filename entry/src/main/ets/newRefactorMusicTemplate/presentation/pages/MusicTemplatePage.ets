/**
 * 音乐模板主页面 - 整合所有组件
 * 遵循开闭原则：对扩展开放，对修改关闭
 * 使用V2装饰器实现响应式UI
 */
import { KPage, UriRequest } from '@kwai/krouter'
import { KyNavigationTop, NoNetwork, RefreshLoading } from 'component_common_widget'
import { QCurrentUser } from 'user_model'
import { USER_LOGIN_EVENT } from 'login_event'
import { KEventBus, KEventData } from '@kwai/eventbus'
import { MusicTemplateViewModel } from '../viewmodels/MusicTemplateViewModel'
import { MusicInfoView } from '../views/MusicInfoView'
import { TemplateListView } from '../views/TemplateListView'
import { FilterDialogView } from '../views/FilterDialogView'
import { MusicService } from '../../domain/services/MusicService'
import { MusicRepositoryImpl } from '../../data/repositories/MusicRepositoryImpl'
import { DependencyContainer } from '../../infrastructure/DependencyContainer'

@KPage({ paths: ['musicSameTemplatePage'] })
@ComponentV2
export struct MusicTemplatePage {
  @Param request: UriRequest = UriRequest.create('kwaiying://musicSameTemplatePage')
  @Local screenSize: any = AppStorageV2.connect('screenSize', () => ({}))!
  
  @Provider() viewModel: MusicTemplateViewModel
  @Provider() dependencyContainer: DependencyContainer

  private loginCallback = (value: KEventData<string>) => {
    this.viewModel.currentUserId = QCurrentUser.getUid()
    console.log('用户登录成功')
  }

  aboutToAppear(): void {
    this.initializeDependencies()
    this.initializeData()
    this.setupEventListeners()
  }

  aboutToDisappear(): void {
    KEventBus.unsubscribe<string>(USER_LOGIN_EVENT, this.loginCallback)
  }

  private initializeDependencies(): void {
    // 初始化依赖注入容器
    this.dependencyContainer = new DependencyContainer()
    
    // 注册依赖
    const repository = MusicRepositoryImpl.getInstance()
    const service = MusicService.getInstance(repository)
    this.viewModel = new MusicTemplateViewModel(service)
  }

  private async initializeData(): Promise<void> {
    const templateInfo = this.request.getExtra("templateInfo", null)
    const userId = QCurrentUser.getUid()
    
    await this.viewModel.initializeData(templateInfo, userId)
  }

  private setupEventListeners(): void {
    KEventBus.subscribe<string>(USER_LOGIN_EVENT, this.loginCallback)
  }

  build() {
    NavDestination() {
      if (this.viewModel.isLoading) {
        RefreshLoading()
      } else if (!this.viewModel.isNetworkAvailable) {
        Column() {
          NoNetwork({
            buttonCallback: () => {
              this.viewModel.refreshData()
            }
          })
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Center)
      } else {
        Stack({ alignContent: Alignment.Top }) {
          // 背景模糊区
          if (this.viewModel.currentMusic?.coverUrl) {
            Image(this.viewModel.currentMusic.coverUrl)
              .width("100%")
              .height(350)
              .foregroundBlurStyle(BlurStyle.Thin, {
                colorMode: ThemeColorMode.DARK,
                adaptiveColor: AdaptiveColor.DEFAULT,
                scale: 0.7
              })
          }

          // 顶部导航区
          KyNavigationTop({
            title: $r('app.string.music_same_template'),
          })
            .zIndex(10)

          // 主内容区
          Column() {
            Blank().width("100%").height(50 + this.screenSize.topAreaHeight)
            
            // 音乐信息区域
            MusicInfoView({ viewModel: this.viewModel })

            // 模板列表区域
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
              .margin({ left: 16, right: 16, bottom: 12 })
              .onClick(() => {
                this.viewModel.showFilterDialog()
              })

              // 模板列表
              TemplateListView({ viewModel: this.viewModel })
            }
            .width('100%')
            .height(`calc(100% - ${50 + this.screenSize.topAreaHeight}vp)`)
            .clip(true)
            .borderRadius({ topLeft: 12, topRight: 12 })
            .backgroundColor("#222222")
          }
          .width("100%")
          .height("100%")

          // 筛选对话框
          if (this.viewModel.isFilterDialogVisible) {
            Column() {
              Blank().width("100%").height("20%")
              
              FilterDialogView({ viewModel: this.viewModel })
            }
            .width("100%")
            .height("100%")
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .zIndex(11)
          }

          // 错误提示
          if (this.viewModel.errorMessage) {
            Column() {
              Text(this.viewModel.errorMessage)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('rgba(255, 0, 0, 0.8)')
                .padding(12)
                .borderRadius(8)
                .margin(16)
            }
            .width("100%")
            .position({ x: 0, y: 100 })
            .zIndex(12)
          }
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
      // 页面隐藏时暂停音乐播放
      this.viewModel.pauseMusic()
    })
    .onBackPressed(() => {
      // 处理返回键事件
      if (this.viewModel.isFilterDialogVisible) {
        this.viewModel.hideFilterDialog()
        return true
      }
      return false
    })
  }
} 