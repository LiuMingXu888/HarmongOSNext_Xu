import { AllTag, TempInnerTableItem, TemplateInfo, TempTableItem } from "temp_model"

export enum FilterTabEnum {
  FRAGMENT = 0,
  ATTRIBUTE = 1,
  SORT = 2,
}

// 推荐列表返回
export interface ResponseData<T,F = ESObject> {
  result: number
  data?: T
  music?: T
  channel?: F
  host?: T
  pcursor?: number | string
}

// 收藏音乐参数
export interface CollectionMusicParams {
  kmovieUserId: string
  resourceList: Description[]
}

// 获取音乐同款模板筛选接口参数
export interface MusicTagsParams {
  templateId: string
  afId: string | null
}

// 待收藏音乐的类型
export enum PaddingCollectionType {
  MUSIC_SAME_TEMPLATE = 0, // 音乐同款模板
  FULL_MUSIC = 1, // 完整音乐类型
}

// 获取音乐同款模板参数
export interface MusicCollectionParams extends MusicTagsParams {
  musicId: string
  musicName: string
  photoId: string
  pcursor: number
}

export interface Description {
  id: string;
  encryptId: string;
  type: number,
  name: string;
  coverUrl: string;
  musicUrl: string;
  duration: number;
  musicId: string;
  encryptMusicId: string;
  audioFingerprintId: string;
  musicType: number;
  artist: string;
  useCount: number;
  like: boolean;
  enableLike: boolean;
  haveCompleteMusic: boolean;
  completeMusic: Description | null;
}

export interface TemplateData {
  description: Description;
  templates: TemplateInfo[];
}

export interface DialogListener {
  openDialog?: () => void
  closeDialog?: () => void
  pageHidden?: () => void
}


// 模板UI的状态变量相关的内容
@ObservedV2
export class TemplateUiState {
  isNetWork: boolean = true // 是否有网络
  @Trace filterIpt: string = ""
  @Trace uid: string = ""
  @Trace isCollection: boolean = false // 当前模板音乐是否被收藏了
  @Trace fullMusicIsCollection: boolean = false // 完整模板音乐是否被收藏了

  @Trace requestComplete: boolean = false // 是否请求完了
  @Trace musicSameDataHasMore: boolean = true // 是否还有更多

  @Trace isMoreDataLoading: boolean = false //更多数据是否正在加载中
}

// 模板重要的信息
@ObservedV2
export class TemplateBusinessData {
  @Trace tempTable: TempTableItem | TempInnerTableItem | null = null // Tab信息传递给内流的参数(可不传递)
  @Trace templateInfo: TemplateInfo | null = null // 内流传递过来的信息
  @Trace musicTemplate: TemplateData | null = null // 获取的音乐同款模板信息

  // 列表数据
  @Trace collectionArr: Description[] = [] // 收藏的音乐
  @Trace filterData: AllTag[] = [] // 筛选框数据模型

  // 临时数据
  @Trace paddingCollection: Description | undefined | null = undefined
  @Trace paddingCollectionType = PaddingCollectionType.MUSIC_SAME_TEMPLATE
}