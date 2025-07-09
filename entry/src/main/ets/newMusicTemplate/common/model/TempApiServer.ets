import { ToastUtils } from "common_util"
import { Response } from "data_loader"
import { AllTag, Cell, TemplateInfo } from "temp_model"
import { Collection_MUSIC_TYPE } from "../../pages/MusicSameTemplatePage"
import { fetchAddSaveMusicPost, fetchDelSaveMusicPost, fetchMusicTagsGet, fetchSaveMusicDataGet } from "../api/TempAPi"
import { checkUid } from "../utile/utileFn"
import { CollectionMusicParams, Description, ResponseData } from "./TempModel"

// 收藏需要传递的参数
export interface CollectionParams {
  uid: string
  collectionObj: Description
  isCollection: boolean
  successCB: () => void
  errorCB?: () => void
}

// 收藏需要传递的参数
export interface ITemplateApiServer {
  getFilterArr: (templateInfo: TemplateInfo) => Promise<AllTag[]>
  getCollectionMusicArr: (uid: string) => Promise<Description[]>
  collectionMusic:(CollectionParams: CollectionParams) => Promise<void>
}

// 音乐同款模板请求类
export class TemplateApi implements ITemplateApiServer {
  // 获取筛选的数据
  async getFilterArr(templateInfo: TemplateInfo) {
    let res: Response<ResponseData<AllTag[]>> = await fetchMusicTagsGet({
      templateId: templateInfo?.id || "",
      afId: templateInfo?.music?.audioFingerprintId || null,
    })
    let filterData = res.data.data?.map((e) => {
      e.categories.forEach((e) => {
        e.cells = e.cells.map((e) => {
          return new Cell(e.cellContentStart, e.cellContentEnd,e.cellContent,e.supportEdit,e.editPlaceholder, e.editType, e.selected)
        })
      })
      return new AllTag(e.title, e.categories)
    })
    return filterData || []
  }

  // 获取收藏的音乐数据
  async getCollectionMusicArr(uid: string) {
    if (checkUid(uid)) return []
    const res: Response<ResponseData<Description[]>> = await fetchSaveMusicDataGet({ kmovieUserId: uid })
    // e.type == 10000 才是音乐的收藏的内容
    let collectionArr = res.data.data!.filter((e: Description) => e.type == Collection_MUSIC_TYPE)
    return collectionArr
  }

  // 收藏音乐
  async collectionMusic(collectionParams: CollectionParams) {
    let fetchParams = this.setCollectionParams(collectionParams)
    try {
      if (collectionParams.isCollection) {
        await fetchAddSaveMusicPost(fetchParams)
      } else {
        await fetchDelSaveMusicPost(fetchParams)
      }
      collectionParams.successCB()
      ToastUtils.showSuccess($r('app.string.template_collection_music_success'))
    } catch (error) {
      collectionParams.errorCB?.()
      ToastUtils.showFailed($r('app.string.template_cancel_collection_music_fail'))
    }
  }

  private setCollectionParams(collectionParams: CollectionParams) {
    collectionParams.collectionObj!.type = Collection_MUSIC_TYPE
    collectionParams.collectionObj!.id = collectionParams.collectionObj?.encryptMusicId || collectionParams.collectionObj?.musicId || ""
    let reSourceMusicParam: CollectionMusicParams = {
      "kmovieUserId": collectionParams.uid,
      "resourceList": [collectionParams.collectionObj!]
    }
    return reSourceMusicParam
  }
}