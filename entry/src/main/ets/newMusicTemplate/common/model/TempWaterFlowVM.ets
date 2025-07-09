import { BaseDataSource } from "base_model";
import { Logger } from "common_util";
import { Response } from "data_loader";
import { TemplateInfo } from "temp_model";
import { MUSIC_TEMPLATE_TAG } from "../../pages/MusicSameTemplatePage";
import { FilterModel, TempItem } from "../../service/type";
import { fetchMusicCollectionPost } from "../api/TempAPi"
import { MusicCollectionParams, ResponseData, TemplateData } from "./TempModel";

@ObservedV2
export class TempWaterFlowVM {
  @Trace array: BaseDataSource<TempItem> = new BaseDataSource<TempItem>() // 音乐同款模板的懒加载数据
  @Trace isRequestComplete: boolean = true; // 是否请求完成
  @Trace hasMore: boolean = true;
  @Trace pcursor: number = 0;

  // 正常请求数据
  async fetchData(templateInfo: TemplateInfo, isFirstRequest: boolean = false, isFilter: boolean = false, filterData: FilterModel[] = []) {
    if (!this.hasMore && !this.isRequestComplete) return

    if (isFilter || isFirstRequest) {
      this.pcursor = 0
      this.array.reload([])
      this.hasMore = true
    }

    let res: Response<ResponseData<TemplateData>> | null = null
      try {
      this.isRequestComplete = false
      res = await fetchMusicCollectionPost(this.requestParams(templateInfo), filterData)
      this.pcursor += res?.data.data?.templates.length || 0

      if (res?.data.data?.templates.length == 0) {
        this.hasMore = false
        this.pcursor = 0
      }

      if (isFilter || isFirstRequest) {
        this.array.reload(res!.data.data!.templates.map(e => new TempItem("TEMPLATE",e)))
        return
      }
      this.array.pushItems(res!.data.data!.templates.map(e => new TempItem("TEMPLATE",e)))

    } catch (error) {
      Logger.e(MUSIC_TEMPLATE_TAG, JSON.stringify(error))
    }

    this.isRequestComplete = true

    return res!.data.data
  }

  requestParams(templateInfo: TemplateInfo) {
    let params: MusicCollectionParams = {
      templateId: templateInfo?.id || "",
      afId: templateInfo?.music?.audioFingerprintId || null,
      musicId: templateInfo?.music?.musicId || "",
      musicName: templateInfo?.music?.name || "",
      photoId: "",
      pcursor: this.pcursor,
    }
    return params
  }
}