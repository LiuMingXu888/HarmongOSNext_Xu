/**
 * 音乐服务接口 - 定义业务逻辑的抽象层
 * 遵循依赖倒置原则：业务逻辑依赖抽象接口
 */
import { Music } from '../entities/Music'
import { Template } from '../entities/Template'
import { FilterTag } from '../entities/Filter'

export interface IMusicService {
  // 音乐播放控制
  playMusic(music: Music): Promise<void>
  pauseMusic(): void
  resumeMusic(): void
  stopMusic(): void
  seekTo(position: number): void
  getCurrentPosition(): number
  getDuration(): number
  isPlaying(): boolean
  
  // 音乐收藏管理
  toggleMusicCollection(music: Music, userId: string): Promise<boolean>
  isMusicCollected(musicId: string, userId: string): Promise<boolean>
  getCollectedMusicList(userId: string): Promise<Music[]>
  
  // 模板管理
  getMusicTemplates(musicId: string, filter?: any[]): Promise<Template[]>
  loadMoreTemplates(pcursor: number): Promise<Template[]>
  
  // 筛选管理
  getFilterOptions(templateId: string, afId?: string): Promise<FilterTag[]>
  applyFilter(filterData: any[]): Promise<Template[]>
  
  // 下载管理
  downloadMusic(music: Music): Promise<string>
  
  // 数据验证
  validateMusicData(music: Music): boolean
  validateTemplateData(template: Template): boolean
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