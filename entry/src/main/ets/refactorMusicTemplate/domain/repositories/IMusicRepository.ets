/**
 * 音乐仓库接口 - 定义数据访问的抽象层
 * 遵循依赖倒置原则：高层模块不依赖低层模块，都依赖抽象
 */
import { MusicEntity } from '../entities/MusicEntity'
import { TemplateEntity } from '../entities/TemplateEntity'
import { FilterTag } from '../entities/FilterEntity'

export interface IMusicRepository {
  // 音乐相关操作
  getMusicCollection(params: MusicCollectionParams): Promise<MusicCollectionResult>
  addMusicToCollection(params: CollectionParams): Promise<void>
  removeMusicFromCollection(params: CollectionParams): Promise<void>
  getCollectedMusicList(userId: string): Promise<MusicEntity[]>
  
  // 模板相关操作
  getMusicTemplates(params: TemplateParams): Promise<TemplateEntity[]>
  
  // 筛选相关操作
  getFilterTags(params: FilterParams): Promise<FilterTag[]>
}

export interface MusicCollectionParams {
  templateId: string
  afId: string | null
  musicId: string
  musicName: string
  photoId: string
  pcursor: number
  filter?: any[]
}

export interface MusicCollectionResult {
  music: MusicEntity
  templates: TemplateEntity[]
}

export interface CollectionParams {
  userId: string
  musicId: string
  musicName: string
  musicUrl: string
  coverUrl: string
  duration: number
  artist: string
}

export interface TemplateParams {
  channelId: string
  pcursor: number
  filter?: any[]
}

export interface FilterParams {
  templateId: string
  afId: string | null
} 