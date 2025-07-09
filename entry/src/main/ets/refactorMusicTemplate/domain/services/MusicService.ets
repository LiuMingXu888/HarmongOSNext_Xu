/**
 * 音乐服务实现类 - 实现具体的业务逻辑
 * 遵循单一职责原则：只负责音乐相关的业务逻辑
 */
import { IMusicService, MusicPlaybackState, CollectionState } from './IMusicService'
import { IMusicRepository } from '../repositories/IMusicRepository'
import { MusicEntity } from '../entities/MusicEntity'
import { TemplateEntity } from '../entities/TemplateEntity'
import { FilterTag } from '../entities/FilterEntity'
import { AudioPlayerManager } from 'audio_manager'
import { MaterialDownloadManager, MaterialType } from 'component_material_mgr'
import { PathCreator, ChildDir, ParentDir } from 'file_manager'
import { BizType, Succeeded } from 'download'
import { Logger, ToastUtils } from 'common_util'
import { ResourceFileInfo } from 'base_model'

export class MusicService implements IMusicService {
  private static instance: MusicService
  private readonly TAG = 'MusicService'
  private audioPlayer: AudioPlayerManager
  private currentMusic: MusicEntity | null = null
  private isPlayingState: boolean = false
  private currentPosition: number = 0
  private duration: number = 0

  private constructor(private repository: IMusicRepository) {
    this.audioPlayer = new AudioPlayerManager()
  }

  static getInstance(repository: IMusicRepository): MusicService {
    if (!MusicService.instance) {
      MusicService.instance = new MusicService(repository)
    }
    return MusicService.instance
  }

  // 音乐播放控制
  async playMusic(music: MusicEntity): Promise<void> {
    if (!this.validateMusicData(music)) {
      throw new Error('音乐数据无效')
    }

    this.currentMusic = music
    this.duration = music.duration

    try {
      this.audioPlayer.setDataSourceAndPlay({
        path: music.musicUrl,
        playImmediately: false,
        prepareCbs: () => {
          Logger.i(this.TAG, '音乐资源准备完毕')
          this.audioPlayer.resumeAudioPlay()
        },
        playingCbs: (isPlaying: boolean) => {
          this.isPlayingState = isPlaying
          Logger.i(this.TAG, '音乐开始播放')
        },
        progressCbs: (progress: number) => {
          this.currentPosition = progress
          Logger.i(this.TAG, `音乐播放进度: ${progress}`)
        },
        completeCbs: () => {
          this.audioPlayer.resumeAudioPlay()
        }
      })
    } catch (error) {
      Logger.e(this.TAG, `播放音乐失败: ${error}`)
      throw error
    }
  }

  pauseMusic(): void {
    this.audioPlayer.pauseAudioPlay()
    this.isPlayingState = false
  }

  resumeMusic(): void {
    this.audioPlayer.resumeAudioPlay()
    this.isPlayingState = true
  }

  stopMusic(): void {
    this.audioPlayer.resetAudioPlay()
    this.isPlayingState = false
    this.currentPosition = 0
  }

  seekTo(position: number): void {
    this.audioPlayer.seek(position)
    this.currentPosition = position
  }

  getCurrentPosition(): number {
    return this.currentPosition
  }

  getDuration(): number {
    return this.duration
  }

  isPlaying(): boolean {
    return this.isPlayingState
  }

  // 音乐收藏管理
  async toggleMusicCollection(music: MusicEntity, userId: string): Promise<boolean> {
    if (!userId) {
      throw new Error('用户未登录')
    }

    try {
      const isCollected = await this.isMusicCollected(music.id, userId)
      
      if (isCollected) {
        await this.repository.removeMusicFromCollection({
          userId,
          musicId: music.id,
          musicName: music.name,
          musicUrl: music.musicUrl,
          coverUrl: music.coverUrl,
          duration: music.duration,
          artist: music.artist
        })
        music.setCollectionStatus(false)
        ToastUtils.showSuccess('取消收藏成功')
        return false
      } else {
        await this.repository.addMusicToCollection({
          userId,
          musicId: music.id,
          musicName: music.name,
          musicUrl: music.musicUrl,
          coverUrl: music.coverUrl,
          duration: music.duration,
          artist: music.artist
        })
        music.setCollectionStatus(true)
        ToastUtils.showSuccess('收藏成功')
        return true
      }
    } catch (error) {
      Logger.e(this.TAG, `切换收藏状态失败: ${error}`)
      ToastUtils.showFailed('操作失败，请重试')
      throw error
    }
  }

  async isMusicCollected(musicId: string, userId: string): Promise<boolean> {
    try {
      const collectedList = await this.getCollectedMusicList(userId)
      return collectedList.some(music => music.id === musicId)
    } catch (error) {
      Logger.e(this.TAG, `检查收藏状态失败: ${error}`)
      return false
    }
  }

  async getCollectedMusicList(userId: string): Promise<MusicEntity[]> {
    return await this.repository.getCollectedMusicList(userId)
  }

  // 模板管理
  async getMusicTemplates(musicId: string, filter?: any[]): Promise<TemplateEntity[]> {
    try {
      const result = await this.repository.getMusicCollection({
        templateId: '',
        afId: null,
        musicId,
        musicName: '',
        photoId: '',
        pcursor: 0,
        filter
      })
      return result.templates
    } catch (error) {
      Logger.e(this.TAG, `获取音乐模板失败: ${error}`)
      throw error
    }
  }

  async loadMoreTemplates(pcursor: number): Promise<TemplateEntity[]> {
    // 实现加载更多模板的逻辑
    return []
  }

  // 筛选管理
  async getFilterOptions(templateId: string, afId?: string): Promise<FilterTag[]> {
    return await this.repository.getFilterTags({ templateId, afId })
  }

  async applyFilter(filterData: any[]): Promise<TemplateEntity[]> {
    // 实现筛选逻辑
    return []
  }

  // 下载管理
  async downloadMusic(music: MusicEntity): Promise<string> {
    try {
      const lastQuesMarkIndex = music.musicUrl.lastIndexOf("?") !== -1 
        ? music.musicUrl.lastIndexOf("?") 
        : undefined
      const suffix = music.musicUrl.substring(
        music.musicUrl.lastIndexOf("."), 
        lastQuesMarkIndex
      )

      const resourceFileInfo: ResourceFileInfo = {
        url: music.musicUrl,
        hash: music.id,
        ext: suffix || ".m4a",
        hashType: ""
      }

      const onProgress = (soFarBytes: number, totalBytes: number) => {
        const progress = (soFarBytes / totalBytes) * 100
        Logger.i(this.TAG, `下载进度: ${progress.toFixed(0)}%`)
      }

      const future = MaterialDownloadManager.getInstance().materialDownload(
        {
          materialType: MaterialType.MUSIC,
          materialId: music.id,
          info: resourceFileInfo
        },
        BizType.KY_EDITOR_MATERIAL_DOWNLOAD,
        PathCreator.fetchDirPath(ParentDir.ROOT_DIR, ChildDir.MUSIC),
        true,
        onProgress
      )

      const downloadStatus = await future
      if (downloadStatus.isSuccessful()) {
        const filePath = (downloadStatus as Succeeded).filePath
        Logger.i(this.TAG, `音乐下载成功: ${filePath}`)
        return filePath
      } else {
        throw new Error('下载失败')
      }
    } catch (error) {
      Logger.e(this.TAG, `下载音乐失败: ${error}`)
      throw error
    }
  }

  // 数据验证
  validateMusicData(music: MusicEntity): boolean {
    return music.isValid()
  }

  validateTemplateData(template: TemplateEntity): boolean {
    return template.isValid()
  }

  // 获取播放状态
  getPlaybackState(): MusicPlaybackState {
    return {
      isPlaying: this.isPlayingState,
      currentPosition: this.currentPosition,
      duration: this.duration,
      musicId: this.currentMusic?.id || ''
    }
  }
} 