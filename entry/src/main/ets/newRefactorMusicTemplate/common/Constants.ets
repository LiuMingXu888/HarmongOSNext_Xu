/**
 * 应用程序常量定义
 * 集中管理所有常量，便于维护和修改
 */

export class Constants {
  // 音乐相关常量
  static readonly MUSIC_TYPE = 10000
  static readonly MUSIC_TEMPLATE_TAG = 'MUSIC_TEMPLATE_TAG'
  
  // 网络相关常量
  static readonly NETWORK_TIMEOUT = 30000
  static readonly RETRY_COUNT = 3
  
  // UI相关常量
  static readonly ANIMATION_DURATION = 300
  static readonly DIALOG_ANIMATION_DURATION = 250
  
  // 颜色常量
  static readonly PRIMARY_COLOR = '#FF6B35'
  static readonly SECONDARY_COLOR = '#FF8C42'
  static readonly BACKGROUND_COLOR = '#222222'
  static readonly TEXT_PRIMARY_COLOR = '#FFFFFF'
  static readonly TEXT_SECONDARY_COLOR = '#CCCCCC'
  static readonly TEXT_TERTIARY_COLOR = '#999999'
  
  // 尺寸常量
  static readonly CARD_RADIUS = 12
  static readonly BUTTON_RADIUS = 20
  static readonly ICON_SIZE = 24
  static readonly SMALL_ICON_SIZE = 16
  
  // 间距常量
  static readonly PADDING_SMALL = 8
  static readonly PADDING_MEDIUM = 16
  static readonly PADDING_LARGE = 24
  static readonly MARGIN_SMALL = 8
  static readonly MARGIN_MEDIUM = 16
  static readonly MARGIN_LARGE = 24
  
  // 字体大小常量
  static readonly FONT_SIZE_SMALL = 12
  static readonly FONT_SIZE_MEDIUM = 14
  static readonly FONT_SIZE_LARGE = 16
  static readonly FONT_SIZE_XLARGE = 18
  
  // 错误消息常量
  static readonly ERROR_NETWORK_UNAVAILABLE = '网络不可用，请检查网络连接'
  static readonly ERROR_LOAD_DATA_FAILED = '加载数据失败，请重试'
  static readonly ERROR_PLAY_MUSIC_FAILED = '播放音乐失败'
  static readonly ERROR_DOWNLOAD_FAILED = '下载失败，请重试'
  static readonly ERROR_COLLECTION_FAILED = '收藏操作失败'
  
  // 成功消息常量
  static readonly SUCCESS_COLLECTION_ADDED = '收藏成功'
  static readonly SUCCESS_COLLECTION_REMOVED = '取消收藏成功'
  static readonly SUCCESS_DOWNLOAD_COMPLETED = '下载完成'
  
  // 提示消息常量
  static readonly TIP_PLEASE_LOGIN = '请先登录'
  static readonly TIP_LOADING = '加载中...'
  static readonly TIP_NO_MORE_DATA = '没有更多数据了'
  
  // 筛选相关常量
  static readonly FILTER_TAB_FRAGMENT = '片段'
  static readonly FILTER_TAB_ATTRIBUTE = '属性'
  static readonly FILTER_TAB_SORT = '排序'
  
  // 模板相关常量
  static readonly TEMPLATE_TYPE_AE = 'ae'
  static readonly TEMPLATE_TYPE_WG = 'wg'
  static readonly TEMPLATE_PREFIX = 'mv_'
  
  // 下载相关常量
  static readonly DOWNLOAD_PROGRESS_UPDATE_INTERVAL = 100
  static readonly DOWNLOAD_DEFAULT_EXTENSION = '.m4a'
  
  // 播放相关常量
  static readonly PLAYBACK_PROGRESS_UPDATE_INTERVAL = 1000
  static readonly PLAYBACK_SEEK_THRESHOLD = 1000
} 