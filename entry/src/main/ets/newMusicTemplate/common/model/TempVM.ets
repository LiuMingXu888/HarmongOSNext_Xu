import { FileUtils, Logger, ToastUtils } from 'common_util'
import { MUSIC_TEMPLATE_TAG } from "../../pages/MusicSameTemplatePage"
import { TemplateInfos } from "../../components/temp/TempContentInnerWaterFlow"
import { KRouter, UriRequest } from "@kwai/krouter"
import MVList from "../../service/mvList"
import { CategoryCell, FilterCategory, FilterModel, TempItem } from "../../service/type"
import { MusicDialogManager } from "../utile/MusicDialogManager"
import { BaseDataSource, Constants } from "base_model"
import {
  Description,
  PaddingCollectionType,
  TemplateBusinessData,
  TemplateData,
  TemplateUiState } from "./TempModel"
import { IMusicService, TempMusicVM } from "./TempMusicVM"
import { TempWaterFlowVM } from "./TempWaterFlowVM"
import { AlbumLaunchUtils, createAlbumParam, RESOLUTION_4K } from "component_album"
import { HashMap } from "@kit.ArkTS"
import { EditorActivityLaunchHelper } from "video_editor_api"
import { NewReporter, ReportConstants } from "report"
import { CollectionParams, ITemplateApiServer, TemplateApi } from "./TempApiServer"
import { TempDialogVM } from "./TempDialogVM"
import { BuryingPointManager } from "../utile/BuryingPointManager"
import { checkNetWork } from '../utile/utileFn'

@ObservedV2
export class TemplateVM {
  uiState: TemplateUiState = new TemplateUiState() // UI相关内容
  businessData: TemplateBusinessData = new TemplateBusinessData() // 重要的信息
  templateApi: ITemplateApiServer = new TemplateApi() // 数据请求信息
  tempMusicVM: IMusicService = new TempMusicVM() // 音乐模板播放相关内容
  fullMusicVM: IMusicService = new TempMusicVM() // 完整音乐播放相关内容
  buryingPoint: BuryingPointManager = new BuryingPointManager() // 音乐模板埋点
  tempWaterFlowVM: TempWaterFlowVM = new TempWaterFlowVM() // 音乐模板列表
  recommendWaterFlowVM: MVList = new MVList({ channelId: '' }) // 推荐音乐的懒加载数据
  collectionMusicDialog: TempDialogVM = new TempDialogVM()
  fullMusicDialog: TempDialogVM = new TempDialogVM()

  constructor(
      tempWaterFlowVM: TempWaterFlowVM = new TempWaterFlowVM(),
      recommendWaterFlowVM: MVList = new MVList({ channelId: '' }),
      tempMusicVM: IMusicService = new TempMusicVM(),
      fullMusicVM: IMusicService = new TempMusicVM(),
      collectionMusicDialog: TempDialogVM = new TempDialogVM(),
      fullMusicDialog: TempDialogVM = new TempDialogVM(),
  ) {
    this.tempMusicVM = tempMusicVM
    this.fullMusicVM = fullMusicVM
    this.tempWaterFlowVM = tempWaterFlowVM
    this.recommendWaterFlowVM = recommendWaterFlowVM
    this.collectionMusicDialog = collectionMusicDialog
    this.fullMusicDialog = fullMusicDialog
  }
  // 滑动的时候向下获取数据
  async fetchData(isFirstRequest: boolean = false, isFilter: boolean = false) {
    this.uiState.isNetWork = checkNetWork()
    if (!this.uiState.isNetWork) return

    // 首次请求和筛选数据时，添true
    this.uiState.requestComplete = isFirstRequest
    this.uiState.isMoreDataLoading = true
    try {
      if (this.tempWaterFlowVM.hasMore) {
        let templateData = await this.tempWaterFlowVM.fetchData(this.businessData.templateInfo!,isFirstRequest, isFilter, this.getNeedFilterData())
        if (isFirstRequest) {
          this.businessData.musicTemplate = templateData || null
          this.uiState.isCollection = this.businessData.collectionArr.some((e: Description) => e.id == this.businessData.musicTemplate?.description.encryptMusicId)
          this.uiState.fullMusicIsCollection = this.businessData.collectionArr.some((e: Description) => e.id == this.businessData.musicTemplate?.description.completeMusic?.encryptMusicId)
          await this.tempMusicVM.setUpMusic(this.businessData.musicTemplate!.description, true)
          Logger.i(MUSIC_TEMPLATE_TAG, "musicDownloadPath: "+this.tempMusicVM.musicDownloadPath)
        }
      }
      if (!this.tempWaterFlowVM.hasMore && this.recommendWaterFlowVM.hasMore) {
        await this.recommendWaterFlowVM.fetchData()
      }
    } catch (error) {
      Logger.e(MUSIC_TEMPLATE_TAG, JSON.stringify(error))
    }
    this.uiState.isMoreDataLoading = false
    this.uiState.requestComplete = false
  }

  // 点击模板
  onClickTemplate(item: TemplateInfos, index: number) {
    if (!checkNetWork()) return
    if (this.tempMusicVM.isPlaying) {
      this.tempMusicVM.pause() // 暂定播放
      this.tempMusicVM.changePlayBack(false) // 回来的时候暂定播放
    }
    this.goToVideoStreaming(index) // 去模板内流页
    this.buryingPoint.clickEvent(item) // 上报埋点mv_list_detail_click
  }

  // 收藏音乐功能
  async collectionMusic(operateObj: Description | null | undefined, isFullMusic: boolean = false) {
    if (this.checkAlreadyCollectionMusic()) return

    let realOperateObj = operateObj ? operateObj : this.businessData.paddingCollection
    let isCollection = isFullMusic ? this.uiState.fullMusicIsCollection: !this.uiState.isCollection
    let params: CollectionParams = {
      uid: this.uiState.uid,
      collectionObj: realOperateObj!,
      isCollection: isCollection,
      successCB: () => {
        // 首次收藏成功才会显示该弹窗
        if (isCollection && MusicDialogManager.getFirstCollectionMusic()) {
          this.collectionMusicDialog.isShowDialog = true
          MusicDialogManager.setFirstCollectionMusic()
        }

        if (isFullMusic) {
          this.uiState.fullMusicIsCollection = !this.uiState.fullMusicIsCollection
        } else {
          this.uiState.isCollection = !this.uiState.isCollection
        }
      }
    }

    this.templateApi.collectionMusic(params)
  }

  // 去剪辑页
  goToClipPage(description: Description | undefined, musicDownloadPath: string) {
    let fileExist = FileUtils.isExist(musicDownloadPath)
    if (!fileExist) {
      Logger.i(MUSIC_TEMPLATE_TAG, "下载路径不存在")
      return
    }
    if (!description) {
      Logger.i(MUSIC_TEMPLATE_TAG, "模板参数不存在")
      return
    }

    const albumParams = createAlbumParam()
    let extraMap = new HashMap<string, Object>()
    extraMap.set(Constants.EXTRA_MATERIAL_TYPE, Constants.EXTRA_ACTION_MUSIC)
    extraMap.set(Constants.EXTRA_MATERIAL_NAME, description.name)
    extraMap.set(Constants.EXTRA_MATERIAL_URL, musicDownloadPath)
    extraMap.set(Constants.EXTRA_MATERIAL_ID, description.musicId)
    albumParams.uiParams.selectDescriptionFormat = true
    albumParams.resultParams.maxResolution = RESOLUTION_4K
    albumParams.activityParams.extra = extraMap
    AlbumLaunchUtils.getInstance().openAlbumWithRx(albumParams).subscribe(async (mediaList) => {
      ToastUtils.showLoading($r("app.string.loading"), 10000, {
        uiConfig: undefined,
        dialogOptions: {
          autoCancel: false
        }
      })
      await EditorActivityLaunchHelper.launchWithMediaAsync(mediaList, albumParams.activityParams.extra ?? undefined)
      ToastUtils.close()
    })
    const param = new HashMap<string, string>()
    NewReporter.onClickEvent(ReportConstants.Event.HOME_SENIOR_EDITOR_CLICK, param)
  }

  // 获取选中的筛选数据
  private getNeedFilterData() {
    let filter: FilterModel[] = this.businessData.filterData.map((item) => {
      const categories = item.categories.map((ele: FilterCategory) => {
        let cells = ele.cells.filter(e => e.selected)
        if (this.uiState.filterIpt.trim()) {
          let isHas = cells.find(e => e.cellContentStart.toString() == this.uiState.filterIpt.trim())
          if (!isHas) {
            cells.push({
              "cellContentStart": parseInt(this.uiState.filterIpt),
              "cellContentEnd": parseInt(this.uiState.filterIpt),
              "cellContent": "",
              "supportEdit": false,
              "editPlaceholder": "",
              "editType": 0
            } as CategoryCell)
          }
        }
        cells = cells.map(e => {
          return {
            "cellContentStart": e.cellContentStart,
            "cellContentEnd": e.cellContentEnd,
            "cellContent": e.cellContent,
            "supportEdit": e.supportEdit,
            "editPlaceholder": e.editPlaceholder,
            "editType": e.editType
          } as CategoryCell
        })
        return {
          categoryTitle: ele.categoryTitle,
          categoryType: ele.categoryType,
          columnNumber: ele.columnNumber,
          maxLine: ele.maxLine,
          selectSuffix: ele.selectSuffix,
          cells: cells
        } as FilterCategory
      })
      return new FilterModel(item.title, categories, false)
    })
    return filter
  }

  // 去模板内流
  private goToVideoStreaming(index: number) {
    // 设置内流数据播放的视频信息
    let allShowData = new BaseDataSource<TempItem>()
    allShowData.pushItems([...this.tempWaterFlowVM.array.getInternalDataArray(), ...this.recommendWaterFlowVM.getInternalDataArray()]) // 音乐同款模板的懒加载数据

    let backPressedHelper = () => { // 恢复播放
      this.tempMusicVM.resume()
    }

    let request: UriRequest = UriRequest.create('kwaiying://clipSameInternalFlow')
    request.setExtra('TempTableItem', this.businessData.tempTable)
    request.setExtra('SelectIndex', index)
    request.setExtra('DataSourceMVList', allShowData.getInternalDataArray())
    // request.setExtra('outerLayoutNextPcursor', this.dataSource.nextPcursor)
    request.setExtra('isShowMusicTemplate', false)
    request.setExtra('backPressedHelper', backPressedHelper)
    KRouter.startUriRequest(request)
  }

  // 检查是否已经收藏该音乐
  private checkAlreadyCollectionMusic(): boolean {
    if (this.businessData.paddingCollection) {
      let isAlreadyCollection = this.businessData.collectionArr.findIndex(e => e.id == this.businessData.paddingCollection?.encryptMusicId) != -1
      if (isAlreadyCollection) {
        if (this.businessData.paddingCollectionType == PaddingCollectionType.FULL_MUSIC) {
          this.uiState.isCollection = true
        } else {
          this.uiState.fullMusicIsCollection = true
        }
        this.businessData.paddingCollection = null
        return true
      }
    }
    return false
  }
}



