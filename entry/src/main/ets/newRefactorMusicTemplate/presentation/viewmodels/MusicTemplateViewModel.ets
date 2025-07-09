/**
 * 音乐模板ViewModel - 管理UI状态和业务逻辑
 * 遵循MVVM模式：View和Model之间的桥梁
 * 使用V2装饰器实现响应式数据绑定
 */
import { IMusicService } from '../../domain/services/IMusicService'
import { Music } from '../../domain/entities/Music'
import { Template } from '../../domain/entities/Template'
import { FilterTag } from '../../domain/entities/Filter'
import { NetworkUtil } from 'common_util'

@ObservedV2
export class MusicTemplateViewModel {
  // UI状态
  @Trace isLoading: boolean = false
  @Trace isNetworkAvailable: boolean = true
  @Trace errorMessage: string = ''
  @Trace currentUserId: string = ''

  // 音乐相关状态
  @Trace currentMusic: Music | null = null
  @Trace isMusicPlaying: boolean = false
  @Trace musicProgress: number = 0
  @Trace musicDuration: number = 0

  // 模板相关状态
  @Trace templates: Template[] = []
  @Trace hasMoreTemplates: boolean = true
  @Trace currentPage: number = 0
  @Trace isLoadingMore: boolean = false

  // 筛选相关状态
  @Trace filterTags: FilterTag[] = []
  @Trace selectedFilters: any[] = []
  @Trace isFilterDialogVisible: boolean = false

  // 收藏相关状态
  @Trace collectedMusicList: Music[] = []
  @Trace isCollectionDialogVisible: boolean = false

  // 弹窗状态
  @Trace isFullMusicDialogVisible: boolean = false
  @Trace isNoLoginDialogVisible: boolean = false

  constructor(private musicService: IMusicService) {
    this.checkNetworkStatus()
  }

  // 网络状态检查
  private checkNetworkStatus(): void {
    this.isNetworkAvailable = NetworkUtil.getInstance().isNetworkAvailable()
  }

  // 初始化数据
  async initializeData(templateInfo: any, userId: string): Promise<void> {
    try {
      this.isLoading = true
      this.currentUserId = userId
      this.checkNetworkStatus()

      if (!this.isNetworkAvailable) {
        this.errorMessage = '网络不可用，请检查网络连接'
        return
      }

      // 设置当前音乐
      if (templateInfo?.music) {
        this.currentMusic = Music.fromApiData(templateInfo.music)
      }

      // 加载模板数据
      await this.loadTemplates()

      // 加载筛选选项
      await this.loadFilterOptions(templateInfo?.id || '')

      // 加载收藏列表
      if (userId) {
        await this.loadCollectedMusicList()
      }

    } catch (error) {
      this.errorMessage = '初始化数据失败'
      console.error('初始化数据失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 加载模板数据
  async loadTemplates(): Promise<void> {
    try {
      if (!this.currentMusic) return

      const newTemplates = await this.musicService.getMusicTemplates(
        this.currentMusic.id,
        this.selectedFilters
      )

      if (this.currentPage === 0) {
        this.templates = newTemplates
      } else {
        this.templates = [...this.templates, ...newTemplates]
      }

      this.hasMoreTemplates = newTemplates.length > 0
    } catch (error) {
      this.errorMessage = '加载模板失败'
      console.error('加载模板失败:', error)
    }
  }

  // 加载更多模板
  async loadMoreTemplates(): Promise<void> {
    if (this.isLoadingMore || !this.hasMoreTemplates) return

    try {
      this.isLoadingMore = true
      this.currentPage++

      const moreTemplates = await this.musicService.loadMoreTemplates(this.currentPage)
      this.templates = [...this.templates, ...moreTemplates]
      this.hasMoreTemplates = moreTemplates.length > 0
    } catch (error) {
      this.errorMessage = '加载更多模板失败'
      console.error('加载更多模板失败:', error)
    } finally {
      this.isLoadingMore = false
    }
  }

  // 加载筛选选项
  async loadFilterOptions(templateId: string): Promise<void> {
    try {
      this.filterTags = await this.musicService.getFilterOptions(templateId)
    } catch (error) {
      console.error('加载筛选选项失败:', error)
    }
  }

  // 加载收藏列表
  async loadCollectedMusicList(): Promise<void> {
    try {
      this.collectedMusicList = await this.musicService.getCollectedMusicList(this.currentUserId)
    } catch (error) {
      console.error('加载收藏列表失败:', error)
    }
  }

  // 音乐播放控制
  async playMusic(): Promise<void> {
    if (!this.currentMusic) return

    try {
      await this.musicService.playMusic(this.currentMusic)
      this.isMusicPlaying = true
    } catch (error) {
      this.errorMessage = '播放音乐失败'
      console.error('播放音乐失败:', error)
    }
  }

  pauseMusic(): void {
    this.musicService.pauseMusic()
    this.isMusicPlaying = false
  }

  resumeMusic(): void {
    this.musicService.resumeMusic()
    this.isMusicPlaying = true
  }

  toggleMusicPlayback(): void {
    if (this.isMusicPlaying) {
      this.pauseMusic()
    } else {
      this.resumeMusic()
    }
  }

  // 收藏管理
  async toggleMusicCollection(): Promise<void> {
    if (!this.currentMusic || !this.currentUserId) {
      this.isNoLoginDialogVisible = true
      return
    }

    try {
      const isCollected = await this.musicService.toggleMusicCollection(
        this.currentMusic,
        this.currentUserId
      )
      
      // 更新收藏列表
      await this.loadCollectedMusicList()
    } catch (error) {
      this.errorMessage = '收藏操作失败'
      console.error('收藏操作失败:', error)
    }
  }

  // 下载音乐
  async downloadMusic(): Promise<void> {
    if (!this.currentMusic) return

    try {
      const filePath = await this.musicService.downloadMusic(this.currentMusic)
      console.log('音乐下载成功:', filePath)
    } catch (error) {
      this.errorMessage = '下载音乐失败'
      console.error('下载音乐失败:', error)
    }
  }

  // 筛选管理
  applyFilter(filterData: any[]): void {
    this.selectedFilters = filterData
    this.currentPage = 0
    this.loadTemplates()
  }

  resetFilter(): void {
    this.selectedFilters = []
    this.currentPage = 0
    this.loadTemplates()
  }

  // 弹窗控制
  showFilterDialog(): void {
    this.isFilterDialogVisible = true
  }

  hideFilterDialog(): void {
    this.isFilterDialogVisible = false
  }

  showFullMusicDialog(): void {
    this.isFullMusicDialogVisible = true
  }

  hideFullMusicDialog(): void {
    this.isFullMusicDialogVisible = false
  }

  showCollectionDialog(): void {
    this.isCollectionDialogVisible = true
  }

  hideCollectionDialog(): void {
    this.isCollectionDialogVisible = false
  }

  hideNoLoginDialog(): void {
    this.isNoLoginDialogVisible = false
  }

  // 错误处理
  clearError(): void {
    this.errorMessage = ''
  }

  // 刷新数据
  async refreshData(): Promise<void> {
    this.currentPage = 0
    this.selectedFilters = []
    await this.initializeData(null, this.currentUserId)
  }

  // 检查音乐是否已收藏
  isMusicCollected(musicId: string): boolean {
    return this.collectedMusicList.some(music => music.id === musicId)
  }

  // 获取播放状态
  getPlaybackState() {
    return {
      isPlaying: this.isMusicPlaying,
      currentPosition: this.musicProgress,
      duration: this.musicDuration,
      musicId: this.currentMusic?.id || ''
    }
  }
} 