import { ContentTypeEnum, DataLoadManager, DataLoadStrategy, RequestConfig } from "data_loader"
import { URLConstants } from "network_intf"
import { Music } from "temp_model"
import { CollectionMusicParams, MusicCollectionParams,
  MusicTagsParams,
  ResponseData } from "../model/TempModel"
import { FilterModel } from "../../service/type"

// 收藏音乐功能
export async function fetchAddSaveMusicPost(data?: CollectionMusicParams, resState?: number | string) {
  return DataLoadManager.getInstance()
    .post<ResponseData<Music[]>>(
      URLConstants.URL_MUSIC_ADD_SAVE_MUSIC,
      RequestConfig.create({
        contentType: ContentTypeEnum.JSON,
        data: data,
      })
    )
}

// 取消收藏音乐功能
export async function fetchDelSaveMusicPost(data?: CollectionMusicParams, resState?: number | string) {
  return DataLoadManager.getInstance()
    .post<ResponseData<Music[]>>(
      URLConstants.URL_MUSIC_DEL_SAVE_MUSIC,
      RequestConfig.create({
        contentType: ContentTypeEnum.JSON,
        data: data,
      })
    )
}

// 获取收藏音乐列表
export async function fetchSaveMusicDataGet(params?: ESObject, resState?: number | string) {
  return DataLoadManager.getInstance()
    .get<ResponseData<Music[]>>(
      URLConstants.URL_MUSIC_SAVE_MUSIC,
      RequestConfig.create({
        params: params,
        cacheOptions: {
          strategy: DataLoadStrategy.FIRST_NETWORK
        }
      })
    )
}

// 获取音乐同款模板数据
export function fetchMusicCollectionPost(params?: MusicCollectionParams, filter?: FilterModel[]) {
  return DataLoadManager.getInstance()
    .post<ResponseData<Music[]>>(
      URLConstants.URL_APP_MUSIC_COLLECTION,
      RequestConfig.create({
        contentType: ContentTypeEnum.JSON,
        params: params,
        data: filter
      })
    )
}

// 获取筛选框接口
export function fetchMusicTagsGet(params?: MusicTagsParams, resState?: number | string) {
  return DataLoadManager.getInstance()
    .get<ResponseData<Music[]>>(
      URLConstants.URL_MUSIC_GET_TAG,
      RequestConfig.create({
        contentType: ContentTypeEnum.JSON,
        params: params,
      })
    )
}