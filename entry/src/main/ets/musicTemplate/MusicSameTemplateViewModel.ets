import { TemplateInfo } from "temp_model"

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
