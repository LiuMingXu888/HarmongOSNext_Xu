/**
 * 音乐仓库实现类 - 实现具体的数据访问逻辑
 * 遵循开闭原则：对扩展开放，对修改关闭
 */
import { IMusicRepository, MusicCollectionParams, MusicCollectionResult, CollectionParams, TemplateParams, FilterParams } from '../../domain/repositories/IMusicRepository'
import { MusicEntity } from '../../domain/entities/MusicEntity'
import { TemplateEntity } from '../../domain/entities/TemplateEntity'
import { FilterTag, FilterCategory, FilterCell } from '../../domain/entities/FilterEntity'
import { DataLoadManager, RequestConfig, ContentTypeEnum } from 'data_loader'
import { URLConstants } from 'network_intf'
import { Logger } from 'common_util'

export class MusicRepositoryImpl implements IMusicRepository {
  private static instance: MusicRepositoryImpl
  private readonly TAG = 'MusicRepositoryImpl'

  private constructor() {}

  static getInstance(): MusicRepositoryImpl {
    if (!MusicRepositoryImpl.instance) {
      MusicRepositoryImpl.instance = new MusicRepositoryImpl()
    }
    return MusicRepositoryImpl.instance
  }

  async getMusicCollection(params: MusicCollectionParams): Promise<MusicCollectionResult> {
    try {
      const response = await DataLoadManager.getInstance()
        .post<any>(
          URLConstants.URL_APP_MUSIC_COLLECTION,
          RequestConfig.create({
            contentType: ContentTypeEnum.JSON,
            params: params,
            data: params.filter
          })
        )

      const data = response.data.data
      const music = this.mapToMusicEntity(data.description)
      const templates = data.templates.map((template: any) => this.mapToTemplateEntity(template))

      return { music, templates }
    } catch (error) {
      Logger.e(this.TAG, `获取音乐集合失败: ${error}`)
      throw error
    }
  }

  async addMusicToCollection(params: CollectionParams): Promise<void> {
    try {
      await DataLoadManager.getInstance()
        .post<any>(
          URLConstants.URL_MUSIC_ADD_SAVE_MUSIC,
          RequestConfig.create({
            contentType: ContentTypeEnum.JSON,
            data: {
              kmovieUserId: params.userId,
              resourceList: [{
                id: params.musicId,
                name: params.musicName,
                musicUrl: params.musicUrl,
                coverUrl: params.coverUrl,
                duration: params.duration,
                artist: params.artist,
                type: 10000
              }]
            }
          })
        )
      Logger.i(this.TAG, '添加音乐收藏成功')
    } catch (error) {
      Logger.e(this.TAG, `添加音乐收藏失败: ${error}`)
      throw error
    }
  }

  async removeMusicFromCollection(params: CollectionParams): Promise<void> {
    try {
      await DataLoadManager.getInstance()
        .post<any>(
          URLConstants.URL_MUSIC_DEL_SAVE_MUSIC,
          RequestConfig.create({
            contentType: ContentTypeEnum.JSON,
            data: {
              kmovieUserId: params.userId,
              resourceList: [{
                id: params.musicId,
                name: params.musicName,
                musicUrl: params.musicUrl,
                coverUrl: params.coverUrl,
                duration: params.duration,
                artist: params.artist,
                type: 10000
              }]
            }
          })
        )
      Logger.i(this.TAG, '移除音乐收藏成功')
    } catch (error) {
      Logger.e(this.TAG, `移除音乐收藏失败: ${error}`)
      throw error
    }
  }

  async getCollectedMusicList(userId: string): Promise<MusicEntity[]> {
    try {
      const response = await DataLoadManager.getInstance()
        .get<any>(
          URLConstants.URL_MUSIC_SAVE_MUSIC,
          RequestConfig.create({
            params: { kmovieUserId: userId }
          })
        )

      const musicList = response.data.data
        .filter((item: any) => item.type === 10000)
        .map((item: any) => this.mapToMusicEntity(item))

      return musicList
    } catch (error) {
      Logger.e(this.TAG, `获取收藏音乐列表失败: ${error}`)
      throw error
    }
  }

  async getMusicTemplates(params: TemplateParams): Promise<TemplateEntity[]> {
    try {
      const response = await DataLoadManager.getInstance()
        .get<any>(
          URLConstants.URL_MV_LIST,
          RequestConfig.create({
            params: params
          })
        )

      return response.data.data.feedItems
        .map((item: any) => this.mapToTemplateEntity(item.templateInfo))
    } catch (error) {
      Logger.e(this.TAG, `获取音乐模板失败: ${error}`)
      throw error
    }
  }

  async getFilterTags(params: FilterParams): Promise<FilterTag[]> {
    try {
      const response = await DataLoadManager.getInstance()
        .get<any>(
          URLConstants.URL_MUSIC_GET_TAG,
          RequestConfig.create({
            params: params
          })
        )

      return response.data.data.map((tag: any) => this.mapToFilterTag(tag))
    } catch (error) {
      Logger.e(this.TAG, `获取筛选标签失败: ${error}`)
      throw error
    }
  }

  // 数据映射方法
  private mapToMusicEntity(data: any): MusicEntity {
    return new MusicEntity(
      data.musicId || data.id,
      data.name,
      data.artist || '',
      data.duration || 0,
      data.musicUrl,
      data.coverUrl,
      data.useCount || 0
    )
  }

  private mapToTemplateEntity(data: any): TemplateEntity {
    return new TemplateEntity(
      data.id,
      data.name,
      data.coverUrl,
      data.width || 0,
      data.height || 0,
      data.type || '',
      data.needPay || false,
      data.payType || 0,
      data.produceType || '',
      data.requestId || '',
      data.sid || '',
      data.recoReason || 0
    )
  }

  private mapToFilterTag(data: any): FilterTag {
    const categories = data.categories.map((category: any) => {
      const cells = category.cells.map((cell: any) => {
        return new FilterCell(
          cell.cellContentStart,
          cell.cellContentEnd,
          cell.cellContent,
          cell.supportEdit,
          cell.editPlaceholder,
          cell.editType,
          cell.selected
        )
      })
      return new FilterCategory(
        category.categoryTitle,
        category.categoryType,
        category.columnNumber,
        category.maxLine,
        category.selectSuffix,
        cells
      )
    })
    return new FilterTag(data.title, categories)
  }
} 