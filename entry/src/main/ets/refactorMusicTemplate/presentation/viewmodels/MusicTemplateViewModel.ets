/**
 * 音乐模板视图模型 - 管理UI状态和业务逻辑
 * 遵循MVVM模式：Model-View-ViewModel分离
 */
import { IMusicService } from '../../domain/services/IMusicService'
import { MusicEntity } from '../../domain/entities/MusicEntity'
import { TemplateEntity } from '../../domain/entities/TemplateEntity'
import { FilterTag, FilterTabEnum } from '../../domain/entities/FilterEntity'
import { Logger } from 'common_util'
import { NetworkUtil, ToastUtils } from 'common_util'

@ObservedV2
export class MusicTemplateViewModel {
  private readonly TAG = 'MusicTemplateViewModel'
  
  // UI状态
  @Trace isLoading: boolean = false
  @Trace isRefreshing: boolean = false
  @Trace hasMoreData: boolean = true
  @Trace isNetworkAvailable: boolean = true
  
  // 数据状态
  @Trace currentMusic: MusicEntity | null = null
  @Trace templateList: TemplateEntity[] = []
  @Trace filterTags: FilterTag[] = []
  @Trace collectedMusicList: MusicEntity[] = []
  
  // 播放状态
  @Trace isPlaying: boolean = false
  @Trace currentPosition: number = 0
  @Trace duration: number = 0
  
  // 筛选状态
  @Trace currentFilterTab: FilterTabEnum = FilterTabEnum.FRAGMENT
  @Trace selectedFilterData: any[] = []
  @Trace inputValue: string = ''
  
  // 对话框状态
  @Trace isShowFullMusicDialog: boolean = false
  @Trace isShowCollectionDialog: boolean = false
  @Trace isShowFilterDialog: boolean = false
  
  // 用户状态
  @Trace userId: string = ''
  
  constructor(private musicService: IMusicService) {
    this.checkNetworkStatus()
  }

  // 网络状态检查
  private checkNetworkStatus(): void {
    this.isNetworkAvailable = NetworkUtil.getInstance().isNetworkAvailable()
  }

  // 初始化数据
  async initializeData(templateInfo: any): Promise<void> {
    if (!this.isNetworkAvailable) {
      ToastUtils.showFailed('无网络，请检查网络后重试')
      return
    }

    this.isLoading = true
    try {
      // 设置当前音乐
      this.currentMusic = new MusicEntity(
        templateInfo.music.musicId,
        templateInfo.music.name,
        templateInfo.music.artist || '',
        templateInfo.music.duration,
        templateInfo.music.musicUrl,
        templateInfo.coverUrlBackupUrls[0],
        templateInfo.music.useCount || 0
      )

      // 并行加载数据
      await Promise.all([
        this.loadMusicTemplates(),
        this.loadFilterOptions(templateInfo.id, templateInfo.music.audioFingerprintId),
        this.loadCollectedMusicList()
      ])

      // 开始播放音乐
      await this.playCurrentMusic()
      
    } catch (error) {
      Logger.e(this.TAG, `初始化数据失败: ${error}`)
      ToastUtils.showFailed('加载失败，请重试')
    } finally {
      this.isLoading = false
    }
  }

  // 加载音乐模板
  async loadMusicTemplates(): Promise<void> {
    if (!this.currentMusic) return

    try {
      const templates = await this.musicService.getMusicTemplates(
        this.currentMusic.id,
        this.selectedFilterData
      )
      this.templateList = templates
    } catch (error) {
      Logger.e(this.TAG, `加载音乐模板失败: ${error}`)
    }
  }

  // 加载筛选选项
  async loadFilterOptions(templateId: string, afId?: string): Promise<void> {
    try {
      this.filterTags = await this.musicService.getFilterOptions(templateId, afId)
    } catch (error) {
      Logger.e(this.TAG, `加载筛选选项失败: ${error}`)
    }
  }

  // 加载收藏音乐列表
  async loadCollectedMusicList(): Promise<void> {
    if (!this.userId) return

    try {
      this.collectedMusicList = await this.musicService.getCollectedMusicList(this.userId)
      this.updateCollectionStatus()
    } catch (error) {
      Logger.e(this.TAG, `加载收藏音乐列表失败: ${error}`)
    }
  }

  // 更新收藏状态
  private updateCollectionStatus(): void {
    if (!this.currentMusic) return

    const isCollected = this.collectedMusicList.some(
      music => music.id === this.currentMusic!.id
    )
    this.currentMusic.setCollectionStatus(isCollected)
  }

  // 播放当前音乐
  async playCurrentMusic(): Promise<void> {
    if (!this.currentMusic) return

    try {
      await this.musicService.playMusic(this.currentMusic)
      this.isPlaying = true
    } catch (error) {
      Logger.e(this.TAG, `播放音乐失败: ${error}`)
    }
  }

  // 播放控制
  togglePlayPause(): void {
    if (this.isPlaying) {
      this.musicService.pauseMusic()
      this.isPlaying = false
    } else {
      this.musicService.resumeMusic()
      this.isPlaying = true
    }
  }

  // 收藏控制
  async toggleCollection(): Promise<void> {
    if (!this.currentMusic) return

    if (!this.userId) {
      // 触发登录流程
      this.triggerLogin()
      return
    }

    try {
      await this.musicService.toggleMusicCollection(this.currentMusic, this.userId)
      await this.loadCollectedMusicList() // 重新加载收藏列表
    } catch (error) {
      Logger.e(this.TAG, `切换收藏状态失败: ${error}`)
    }
  }

  // 筛选相关
  openFilterDialog(tabIndex: FilterTabEnum): void {
    if (this.currentFilterTab === tabIndex) {
      this.closeFilterDialog()
    } else {
      this.currentFilterTab = tabIndex
      this.isShowFilterDialog = true
    }
  }

  closeFilterDialog(): void {
    this.isShowFilterDialog = false
    this.currentFilterTab = FilterTabEnum.FRAGMENT
  }

  applyFilter(): void {
    this.isRefreshing = true
    this.loadMusicTemplates().finally(() => {
      this.isRefreshing = false
    })
  }

  resetFilter(): void {
    this.selectedFilterData = []
    this.inputValue = ''
    this.filterTags.forEach(tag => tag.resetAllCategories())
  }

  // 对话框控制
  openFullMusicDialog(): void {
    this.isShowFullMusicDialog = true
  }

  closeFullMusicDialog(): void {
    this.isShowFullMusicDialog = false
  }

  openCollectionDialog(): void {
    this.isShowCollectionDialog = true
  }

  closeCollectionDialog(): void {
    this.isShowCollectionDialog = false
  }

  // 用户相关
  setUserId(userId: string): void {
    this.userId = userId
    this.loadCollectedMusicList()
  }

  private triggerLogin(): void {
    // 触发登录流程的具体实现
    Logger.i(this.TAG, '需要登录')
  }

  // 模板点击
  onTemplateClick(template: TemplateEntity, index: number): void {
    // 处理模板点击事件
    Logger.i(this.TAG, `点击模板: ${template.name}, 索引: ${index}`)
  }

  // 加载更多
  async loadMoreTemplates(): Promise<void> {
    if (!this.hasMoreData || this.isRefreshing) return

    try {
      const moreTemplates = await this.musicService.loadMoreTemplates(this.templateList.length)
      if (moreTemplates.length > 0) {
        this.templateList.push(...moreTemplates)
      } else {
        this.hasMoreData = false
      }
    } catch (error) {
      Logger.e(this.TAG, `加载更多模板失败: ${error}`)
    }
  }

  // 获取筛选文本
  getFilterText(tabIndex: FilterTabEnum): string {
    const tag = this.filterTags[tabIndex]
    if (!tag) return ''

    const selectedCategories = tag.getSelectedCategories()
    if (selectedCategories.length === 0) return ''

    const selectedCells = selectedCategories[0].getSelectedCells()
    if (selectedCells.length === 0) return ''

    return selectedCells[0].getDisplayText()
  }

  // 清理资源
  dispose(): void {
    this.musicService.stopMusic()
  }
} 