/**
 * 音乐服务接口 - 定义业务逻辑的抽象层
 * 遵循依赖倒置原则：业务逻辑依赖抽象接口
 */
import { MusicEntity } from '../entities/MusicEntity'
import { TemplateEntity } from '../entities/TemplateEntity'
import { FilterTag } from '../entities/FilterEntity'

export interface IMusicService {
  // 音乐播放控制
  playMusic(music: MusicEntity): Promise<void>
  pauseMusic(): void
  resumeMusic(): void
  stopMusic(): void
  seekTo(position: number): void
  getCurrentPosition(): number
  getDuration(): number
  isPlaying(): boolean
  
  // 音乐收藏管理
  toggleMusicCollection(music: MusicEntity, userId: string): Promise<boolean>
  isMusicCollected(musicId: string, userId: string): Promise<boolean>
  getCollectedMusicList(userId: string): Promise<MusicEntity[]>
  
  // 模板管理
  getMusicTemplates(musicId: string, filter?: any[]): Promise<TemplateEntity[]>
  loadMoreTemplates(pcursor: number): Promise<TemplateEntity[]>
  
  // 筛选管理
  getFilterOptions(templateId: string, afId?: string): Promise<FilterTag[]>
  applyFilter(filterData: any[]): Promise<TemplateEntity[]>
  
  // 下载管理
  downloadMusic(music: MusicEntity): Promise<string>
  
  // 数据验证
  validateMusicData(music: MusicEntity): boolean
  validateTemplateData(template: TemplateEntity): boolean
}

export interface MusicPlaybackState {
  isPlaying: boolean
  currentPosition: number
  duration: number
  musicId: string
}

export interface CollectionState {
  isCollected: boolean
  musicId: string
  userId: string
} 