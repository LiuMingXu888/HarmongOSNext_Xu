import { Response } from "data_loader"
import { FileUtils, Logger, NetworkUtil, ToastUtils } from 'common_util'
import { EditorActivityLaunchHelper } from 'video_editor_api'
import { AllTag, Cell, TempInnerTableItem, TemplateInfo, TempTableItem } from 'temp_model'
import { AlbumLaunchUtils, createAlbumParam, RESOLUTION_4K } from 'component_album'
import { NewReporter, ReportConstants } from 'report'
import { HashMap } from '@kit.ArkTS'
import { AudioPlayerManager } from 'audio_manager';
import { Collection_MUSIC_TYPE, MUSIC_TEMPLATE_TAG } from "../../pages/MusicSameTemplatePage"
import { TemplateInfos } from "../../components/temp/TempContentInnerWaterFlow"
import { KRouter, UriRequest } from "@kwai/krouter"
import MVList from "../../service/mvList"
import { CategoryCell, FilterCategory, FilterModel, TempItem, TempRes } from "../../service/type"
import { MusicDialogManager } from "../utile/MusicDialogMananger"
import { USER_LOGIN_EVENT } from "login_event"
import { KEventBus } from "@kwai/eventbus"
import { BaseDataSource, Constants, ResourceFileInfo } from "base_model"
import { MaterialDownloadManager, MaterialType } from "component_material_mgr"
import { ChildDir, ParentDir, PathCreator } from 'file_manager';
import { BizType, Succeeded } from "download"
import {
  CollectionMusicParams,
  Description,
  DialogListener,
  FilterTabEnum,
  PaddingCollectionType, ResponseData, TemplateData } from "./MusicSameTemplateViewModel"
import { fetchAddSaveMusicPost, fetchDelSaveMusicPost,
  fetchMusicCollectionPost,
  fetchMusicTagsGet,
  fetchSaveMusicDataGet } from "../api/MusicSameTemplateApi"


@ObservedV2
export class MusicTemplateVM {
  isNetWork: boolean = true // 是否有网络
  @Trace uid: string = ""
  @Trace tempTable: TempTableItem | TempInnerTableItem | null = null
  @Trace templateInfo: TemplateInfo | null = null
  @Trace musicTemplate: TemplateData | null = null // 音乐同款模板信息
  @Trace musicDownloadPath: string = "" // 音乐下载路径

  @Trace isCollection: boolean = false // 当前模板音乐是否被收藏了
  @Trace fullMusicIsCollection: boolean = false // 完整模板音乐是否被收藏了
  @Trace collectionArr: Description[] = []
  @Trace paddingCollection: Description | undefined | null = undefined
  @Trace paddingCollectionType = PaddingCollectionType.MUSIC_SAME_TEMPLATE

  @Trace dataSource: MVList = new MVList({ channelId: '' }) // 推荐音乐的懒加载数据
  @Trace musicSameData: BaseDataSource<TempItem> = new BaseDataSource<TempItem>() // 音乐同款模板的懒加载数据

  @Trace isRefreshing: boolean = true // 是否正在请求数据中
  @Trace musicSameDataHasMore: boolean = true // 是否还有更多

  @Trace isMoreDataLoading: boolean = false //更多数据是否正在加载中

  @Trace isPlaying: boolean = true // 是否播放当前音乐
  audioPlayerManager: AudioPlayerManager = new AudioPlayerManager() // 播放音频的类

  @Trace isShowFullMusicDialog: boolean = false
  @Trace isShowCollectionDialog: boolean = false
  MusicDialogListener: DialogListener = {}
  CollectionDialogListener: DialogListener = {}

  setUpMusic(url: string) {
    let path = url || this.musicTemplate?.description.musicUrl  || ""
    if (path) {
      Logger.i(MUSIC_TEMPLATE_TAG,"地址不对，播放错误")
    }
    this.audioPlayerManager?.setDataSourceAndPlay(
      {
        path, // 播放路径
        playImmediately: false,
        prepareCbs: () => {
          Logger.i(MUSIC_TEMPLATE_TAG,"资源准备完毕，准备播放")
          if (!this.isRefreshing) {
            this.audioPlayerManager.resumeAudioPlay()
          }
        },
        playingCbs: (isPlaying) => {
          this.isPlaying = true
          Logger.i(MUSIC_TEMPLATE_TAG,"资源准备完毕，开始播放")
        },
        progressCbs: (progress: number) => {
          Logger.i(MUSIC_TEMPLATE_TAG, "音频进度发生改变sss musicPlayingProgress:"+progress)
        },
        completeCbs: () => {
          this.audioPlayerManager?.resumeAudioPlay()
        }, // 播放结束后
      }
    );
  }

  // 下载事件
  async onDownload(templateData: TemplateData) {
    // 定义 ResourceFileInfo 对象
    let lastQuesMarkIndex = templateData.description.musicUrl.lastIndexOf("?") != -1 ? templateData.description.musicUrl.lastIndexOf("?") : undefined
    let suffix = templateData.description.musicUrl.substring(templateData.description.musicUrl.lastIndexOf("."), lastQuesMarkIndex)
    const resourceFileInfo: ResourceFileInfo = {
      url:templateData.description.musicUrl!,
      hash: templateData.description.musicId,
      ext: suffix ?? ".m4a",
      hashType: ""
    };

    // 定义进度回调函数
    const onProgress = (soFarBytes: number, totalBytes: number) => {
      const progress = (soFarBytes / totalBytes) * 100;
      Logger.i(MUSIC_TEMPLATE_TAG, `下载进度: ${progress.toFixed(0)}%, soFarBytes: ${soFarBytes} totalBytes: ${totalBytes}`)
    };

    // 下载音乐
    let future = MaterialDownloadManager.getInstance().materialDownload(
      {
        materialType: MaterialType.MUSIC,
        materialId: templateData.description.musicId.toString(),
        info: resourceFileInfo
      },
      BizType.KY_EDITOR_MATERIAL_DOWNLOAD,
      PathCreator.fetchDirPath(ParentDir.ROOT_DIR, ChildDir.MUSIC),
      true,
      onProgress
    )
    return new Promise<string>(async (resolve, reject) => {
      try {
        let downloadStatus = await future
        if (downloadStatus.isSuccessful()) {
          Logger.i(MUSIC_TEMPLATE_TAG, `音乐下载成功 ${ (downloadStatus as Succeeded).filePath}`)
          resolve((downloadStatus as Succeeded).filePath)
        } else if (downloadStatus.isFailed()) {
          console.error('MUSIC: 音乐下载错误码:', JSON.stringify(downloadStatus));
          reject(downloadStatus.isFailed())
        }
      } catch (e) {
        Logger.i(MUSIC_TEMPLATE_TAG, `音乐下载错误码 ${JSON.stringify(e)}`)
        reject(e)
      }
    })
  }

  // 点击播放icon
  onClickPlayIcon() {
    if (this.isPlaying) {
      this.isPlaying = false
      this.audioPlayerManager?.pauseAudioPlay()

    } else {
      this.isPlaying = true
      this.audioPlayerManager?.resumeAudioPlay()
    }
  }

  // 重置音乐
  resetMusic() {
    this.audioPlayerManager?.resetAudioPlay()
  }

  // 获取收藏的音乐数据
  getCollectionMusic() {
    if (!this.uid) {
      Logger.i(MUSIC_TEMPLATE_TAG, "请先登录")
      return
    }
    fetchSaveMusicDataGet({ kmovieUserId: this.uid })
      .then((res: Response<ResponseData<Description[]>>) => {
        // e.type == 10000 才是音乐的收藏的内容
        this.collectionArr = res.data.data!.filter((e: Description) => e.type == Collection_MUSIC_TYPE)
        this.isCollection = this.collectionArr.some(e => e.id == this.musicTemplate?.description.encryptMusicId)
        this.fullMusicIsCollection = this.collectionArr.some(e => e.id == this.musicTemplate?.description.completeMusic?.encryptMusicId)
      })
  }

  // 收藏音乐功能
  async collectionMusic(operateObj: Description | null | undefined, isFullMusic: boolean = false) {

    // 未收藏的音乐，才会提示
    if (this.paddingCollection) {
      let isAlreadyCollection = this.collectionArr.findIndex(e => e.id == this.paddingCollection?.encryptMusicId) != -1
      if (isAlreadyCollection) {
        if (isFullMusic) {
          this.isCollection = true
        } else {
          this.fullMusicIsCollection = true
        }
        this.paddingCollection = null
        return
      }
    }

    let realOperateObj = operateObj ? operateObj : this.paddingCollection
    realOperateObj!.type = Collection_MUSIC_TYPE
    realOperateObj!.id = realOperateObj?.encryptMusicId || realOperateObj?.musicId || ""

    let reSourceMusicParam: CollectionMusicParams = {
      "kmovieUserId": this.uid,
      "resourceList": [realOperateObj!]
    }

    if (isFullMusic) {
      this.collectionFn(!this.fullMusicIsCollection, reSourceMusicParam, () => {
        this.fullMusicIsCollection = !this.fullMusicIsCollection
      })
    } else {
      this.collectionFn(!this.isCollection, reSourceMusicParam, () => {
        this.isCollection = !this.isCollection
      })
    }
  }

  collectionFn(isCollection: boolean, collectionParams: CollectionMusicParams, successCb: () => void) {
    if (isCollection) { // 开始收藏
      fetchAddSaveMusicPost(collectionParams)
        .then(() => {
          // 首次收藏成功才会显示该弹窗
          if (MusicDialogManager.getFirstCollectionMusic()) {
            this.isShowCollectionDialog = true
            MusicDialogManager.setFirstCollectionMusic()
          }
          successCb()
          ToastUtils.showSuccess($r('app.string.template_collection_music_success'))
        })
        .catch(() => {
          ToastUtils.showFailed($r('app.string.template_collection_music_fail'))
        })

    } else { // 取消收藏
      fetchDelSaveMusicPost(collectionParams)
        .then(() => {
          successCb()
          ToastUtils.showSuccess($r('app.string.template_cancel_collection_music_success'))
        })
        .catch(() => {
          ToastUtils.showFailed($r('app.string.template_cancel_collection_music_fail'))
        })
    }
  }


  // 获取音乐同款模板数据
  getMusicCollection(isFirstQuery: boolean = false, isFilter: boolean = false) {
    this.isNetWork = NetworkUtil.getInstance().isNetworkAvailable()

    if (!this.isNetWork) {
      ToastUtils.showFailed('无网络，请检查网络后重试')
      return
    }

     this.isRefreshing = isFirstQuery

    if (!this.musicSameDataHasMore && !isFilter) {
      this.onLoadMore(isFilter)
      return
    }
    fetchMusicCollectionPost({
      templateId: this.templateInfo?.id || "",
      afId: this.templateInfo?.music?.audioFingerprintId || null,
      musicId: this.templateInfo?.music?.musicId || "",
      musicName: this.templateInfo?.music?.name || "",
      photoId: "",
      pcursor: this.musicSameData.getInternalDataArray().length || 0,
    }, this.getNeedFilterData())
      .then(async (res: Response<ResponseData<TemplateData>>) => {
        if (isFirstQuery) {
          this.musicTemplate = res.data.data as TemplateData
          this.isCollection = this.collectionArr.some((e: Description) => e.id == this.musicTemplate?.description.encryptMusicId)
          this.fullMusicIsCollection = this.collectionArr.some((e: Description) => e.id == this.musicTemplate?.description.completeMusic?.encryptMusicId)
          this.musicDownloadPath = await this.onDownload(this.musicTemplate)
          this.isPlaying = true
          Logger.i(MUSIC_TEMPLATE_TAG, "musicDownloadPath: "+this.musicDownloadPath)
        }
        if (res.data.data!.templates.length == 0) {
          this.musicSameDataHasMore = false
          if (isFilter) {
            this.musicSameData.reload(res.data.data!.templates.map(e => new TempItem("TEMPLATE",e)))
          }
          this.onLoadMore()
        } else {
          if (isFilter) {
            this.musicSameData.reload(res.data.data!.templates.map(e => new TempItem("TEMPLATE",e)))
            return
          }
          this.musicSameData.pushItems(res.data.data!.templates.map(e => new TempItem("TEMPLATE",e)))
        }
      })
      .finally(() => {
        this.isRefreshing = false
        if (isFirstQuery && !this.audioPlayerManager.isAudioPlaying()) {
          this.audioPlayerManager.resumeAudioPlay()
          this.isPlaying = true
        }
      })
  }

  // 预加载
  beforeLoad(lastItemIndex: number) {
    /// 可以用于预加载
    if ((lastItemIndex >= (this.dataSource.totalCount() - 4)) && ((this.dataSource.totalCount() - 4) > 0)) {
      if (!this.dataSource.hasMore || this.isMoreDataLoading) return
      this.onLoadMore()
    }
  }

  // 上拉滚动加载
  async onLoadMore(isFilter: boolean = false) {
    if (!this.dataSource.hasMore || this.isMoreDataLoading) return

    this.isMoreDataLoading = true
    console.log('--> mvwaterfall onLoadMore')
    try {
      await this.dataSource.fetchData(isFilter)
        .then(res => {
          res && this.reportTemplateInfo(res, false)
        })
    } catch (e) {
    }
    this.isMoreDataLoading = false
  }

  // 获取数据
  async fetchData(isFilter: boolean = false) {
    const res = await this.dataSource.fetchData(isFilter)
    if (res) {
      const item = this.reportTemplateInfo(res, false) as TemplateInfos
      if (this.isFirstShow && item) {
        this.pageShow(item)
      }
    }
  }

  // 点击模板
  onClickTemplate(item: TemplateInfos, index: number) {
    if (!NetworkUtil.getInstance().isNetworkAvailable()) {
      ToastUtils.showToast($r('app.string.please_check_network'))
      return
    }
    this.isPlaying = false
    this.audioPlayerManager.pauseAudioPlay()

    let allShowData = new BaseDataSource<TempItem>() // 音乐同款模板的懒加载数据
    allShowData.pushItems(this.musicSameData.getInternalDataArray())
    allShowData.pushItems(this.dataSource.getInternalDataArray())

    let request: UriRequest = UriRequest.create('kwaiying://clipSameInternalFlow')
    request.setExtra('TempTableItem', this.tempTable)
    request.setExtra('SelectIndex', index)
    request.setExtra('DataSourceMVList', allShowData.getInternalDataArray())
    // request.setExtra('outerLayoutNextPcursor', this.dataSource.nextPcursor)
    request.setExtra('isShowMusicTemplate', false)
    let backPressedHelper = () => {
      this.isPlaying = true
      this.audioPlayerManager.resumeAudioPlay()
    }
    request.setExtra('backPressedHelper', backPressedHelper)
    KRouter.startUriRequest(request)
    // 上报埋点mv_list_detail_click
    this.clickEvent(item)
  }

}

@ObservedV2
export class TemplateFilter {
  @Trace filterData: AllTag[] = [] // 筛选框数据模型
  @Trace inputValue: string = "" // 当前的片段数
  @Trace currentFilter: number = -1 // 当前选中的索引
  @Trace fragmentTitle: string = ""
  @Trace attributeTitle: string = ""
  @Trace sortTitle: string = ""
  @Trace fragmentImageAngle: number = 0
  @Trace attributeImageAngle: number = 0
  @Trace sortImageAngle: number = 0
  @Trace isShowFilterDialog: boolean = false
  FilterDialogListener: DialogListener = {}

  // 获取筛选数据
  getFilterData() {
    fetchMusicTagsGet({
      templateId: this.templateInfo?.id || "",
      afId: this.templateInfo?.music?.audioFingerprintId || null,
    })
      .then((res: Response<ResponseData<AllTag[]>>) => {
        this.filterData = res.data.data?.map((e) => {
          e.categories.forEach((e) => {
            e.cells = e.cells.map((e) => {
              return new Cell(e.cellContentStart, e.cellContentEnd,e.cellContent,e.supportEdit,e.editPlaceholder, e.editType, e.selected)
            })
          })
          return new AllTag(e.title, e.categories)
        }) || []
      })
  }

  // 获取选中的筛选数据
  getNeedFilterData() {
    let filter: FilterModel[] = this.filterData.map((item) => {
      const categories = item.categories.map((ele: FilterCategory) => {
        let cells = ele.cells.filter(e => e.selected)
        if (this.inputValue.trim()) {
          let isHas = cells.find(e => e.cellContentStart.toString() == this.inputValue.trim())
          if (!isHas) {
            cells.push({
              "cellContentStart": parseInt(this.inputValue),
              "cellContentEnd": parseInt(this.inputValue),
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

  // 点击筛选
  openFilterDialog(index: number) {
    // 重置当前的数据，还有筛选的功能
    if (this.currentFilter == index) {
      this.changeImageAnimation(index)
      this.FilterDialogListener.closeDialog?.();
    } else {
      this.changeImageAnimation(index, 180)
      this.changeImageAnimation(this.currentFilter, 0)
      this.isShowFilterDialog = true
      this.currentFilter = index
    }
  }

  // 改变箭头动画
  changeImageAnimation(index: number, angle: number = 0) {
    if (index == FilterTabEnum.FRAGMENT) {
      animateTo({ duration: 200 }, () => { this.fragmentImageAngle = angle })
    } else if (index == FilterTabEnum.ATTRIBUTE) {
      animateTo({ duration: 200 }, () => { this.attributeImageAngle = angle })
    } else if (index == FilterTabEnum.SORT) {
      animateTo({ duration: 200 }, () => { this.sortImageAngle = angle })
    }
  }
}


// 埋点工具类
export class MusicSameBuryingPoint {
  private isFirstShow: boolean = false // 只有首次需要进行页面曝光

  // 点击埋点
  clickEvent(items: TemplateInfos) {
    const param = new HashMap<string, string>()
    param.set(ReportConstants.Param.IS_VIP_MV, items.needPay || (items.payType == 2).toString())
    param.set(ReportConstants.Param.MV_CLASS, items.produceType === "AE_TEMPLATE" ? "ae" : "wg")
    param.set(ReportConstants.Param.MV_TYPE, items.type?.replace("mv_", "") || "")
    param.set(ReportConstants.Param.MV_ID, items.id)
    param.set(ReportConstants.Param.TASK_FROM, 'list')
    param.set(ReportConstants.Param.IS_MARKET_MV, items.payType == 2 ? "1" : "0")
    param.set(ReportConstants.Param.QUERY, '')
    param.set(ReportConstants.Param.LLSID, items.requestId || items.sid)
    param.set(ReportConstants.Param.EXP_TAG, items.recoReason.toString())
    NewReporter.onClickEvent(ReportConstants.Event.MV_LIST_DETAIL_CLICK, param)
  }

  // 页面曝光埋点
  pageShow(item: TemplateInfos) {
    if (this.isFirstShow) return
    // 上报埋点 mv_list_page_show
    const param = new HashMap<string, string>()
    param.set(ReportConstants.Param.IS_VIP_MV, item.needPay || (item.payType == 2).toString())
    param.set(ReportConstants.Param.MV_CLASS, item.produceType === "AE_TEMPLATE" ? "ae" : "wg")
    param.set(ReportConstants.Param.MV_TYPE, item.type?.replace("mv_", "") || "")
    param.set(ReportConstants.Param.MV_ID, item.id)
    param.set(ReportConstants.Param.TASK_FROM, 'list')
    param.set(ReportConstants.Param.IS_MARKET_MV, item.payType == 2 ? "1" : "0")
    param.set(ReportConstants.Param.QUERY, '')
    param.set(ReportConstants.Param.LLSID, item.requestId || item.sid)
    param.set(ReportConstants.Param.EXP_TAG, item.recoReason.toString())
    NewReporter.onElementEvent(ReportConstants.Event.MV_LIST_PAGE_SHOW, param)
    this.isFirstShow = false
  }

  // 埋点
  reportTemplateInfo(res: TempRes, pcursor: boolean): TemplateInfo | undefined {
    try {
      if (res?.data.feedItems && res?.data.feedItems.length > 0) {
        const item = res?.data.feedItems[0].templateInfo as TemplateInfo // 多个模版取第一个
        if (item) {
          const param = new HashMap<string, string>()
          param.set(ReportConstants.Param.MV_NAME, item.name)
          param.set(ReportConstants.Param.PREVIOUS_CURSOR, pcursor ? '0' : this.dataSource.nextPcursor ? this.dataSource.nextPcursor.toString() : '0')
          param.set(ReportConstants.Param.MV_CLASS, item.produceType === "AE_TEMPLATE" ? "ae" : "wg")
          param.set(ReportConstants.Param.CATEGORY_ID, this.tempTable?.id)
          param.set(ReportConstants.Param.MV_ID, item.id)
          param.set(ReportConstants.Param.TASK_FROM, 'list')
          param.set(ReportConstants.Param.LLSID, '')
          param.set(ReportConstants.Param.PAGE, 'MV_LIST')
          param.set(ReportConstants.Param.AUTHOR_ID, item.user.userId)
          NewReporter.onElementEvent(ReportConstants.Event.MV_LIST_SERVER_SHOW, param)
          return item
        }
      }
    } catch (e) {
      Logger.e(MUSIC_TEMPLATE_TAG, JSON.stringify(e))
    }
    return undefined
  }
}

// 去登录
export function goToLogin(loginSuccess: () => void) {
  let request = UriRequest.create('kwaiying://guideLoginPage')
  KRouter.startUriRequest(request);
  KEventBus.subscribe(USER_LOGIN_EVENT, loginSuccess)
}

// 去裁剪页
export function goToClipPage(musicTemplate: TemplateData | null, musicDownloadPath: string) {
  let fileExist = FileUtils.isExist(musicDownloadPath)
  if (!fileExist) {
    Logger.i(MUSIC_TEMPLATE_TAG, "下载路径不存在")
    return
  }
  if (!musicTemplate) {
    Logger.i(MUSIC_TEMPLATE_TAG, "模板参数不存在")
    return
  }

  const albumParams = createAlbumParam()
  let extraMap = new HashMap<string, Object>()
  extraMap.set(Constants.EXTRA_MATERIAL_TYPE, Constants.EXTRA_ACTION_MUSIC)
  extraMap.set(Constants.EXTRA_MATERIAL_NAME, musicTemplate?.description.name)
  extraMap.set(Constants.EXTRA_MATERIAL_URL, musicDownloadPath)
  extraMap.set(Constants.EXTRA_MATERIAL_ID, musicTemplate?.description.musicId)
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