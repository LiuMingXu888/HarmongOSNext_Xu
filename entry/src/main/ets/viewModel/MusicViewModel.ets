/**
 * 音乐库所有的Tab类型
 * 根据字符的开头区分是否切换页面了， main/hot/key/result/popular
 **/
export enum MusicTabEnum {
  // Tabs主框架
  LIBRARY_RECOMMEND = "main_library_recommend", // 默认
  LIBRARY_LAST_UES = "main_library_last_use",
  LIBRARY_COLLECTION = "main_library_collection",
  KS_COLLECTION = "main_ks_collection",
  IMPORT_EXTRACT = "main_export_extract",
  IMPORT_SRC = "main_export_link_download",
  IMPORT_LOCAL = "main_export_local",

  // 搜索热词页
  HOT_WORDS = "hot_words",

  // 搜索关键字推荐页
  KEY_RECOMMEND = "key_recommend",

  // 搜索结果页
  SEARCH_ALL = "result_all",
  SEARCH_LIBRARY = "result_library",
  SEARCH_IMPORT = "result_import",

  // 热门分类
  POPULAR_TYPE = "popular_type",
  // DEFAULT = "default"
}


// 通过 provider consumer 传递
@ObservedV2
export class MusicMainVM {
  // 主要传递
  @Trace uid: string = ""; // 当前的用户id
  @Trace kwaiuid: string = ""; // 当前的快手的id
  @Trace musicTab: MusicTabEnum = MusicTabEnum.LIBRARY_RECOMMEND;

  // 通用数据相关
  @Trace collectionMusic: BaseDataSource<MusicDetail> = new BaseDataSource<MusicDetail>() // 收藏的音乐
  @Trace allMusicType: AllMusicType | null = null // 所有的音乐类型

  // 更新数据相关
  @Trace waitAddData: MusicDetail | null = null // 新增的数据

  // 搜索相关
  @Trace inputValue: string = '' // 当前输入框的值
  stopEditing: () => void = () => {} // 退出编辑态

  // 动画相关
  @Trace animateItem: AnimationItem | null = null; // 当前的动画实例
  playAddCollectionAnimation: () => void = () => {} // 播放添加收藏加一动画
}

// 通过 params 传递
@ObservedV2
export class MusicListVM {
  public musicTab: MusicTabEnum = MusicTabEnum.LIBRARY_RECOMMEND; // 当前Tab类型
  public waveSubject: BehaviorSubject<AudioRangeWaveInfo| null> = new BehaviorSubject<AudioRangeWaveInfo | null>(null)
  public isSupportSearchColorChange: boolean = false // 是否支持标题和作者更换颜色
  public isSupportCollection: boolean = false // 是否支持收藏
  public isShowNoMoreInfo: boolean = false // 是否显示没有更多了的信息
  public isSupportRefresh: boolean = false // 是否支持刷新数据
  public isRequestingFinish: boolean = false // 是否请求完成数据了
  public isSupportNoDataShow: boolean = false // 是否显示默认的为空模板
  public channelId: number = -1 // 热门分类传递过来的ID
  public channelName: string = "" // 热门分类传递过来的Name

  @Trace currentArrSource: BaseDataSource<MusicDetail> = new BaseDataSource<MusicDetail>() // 子组件展示的数组
  @Trace hasMore: boolean = false // 是否还有更多
  @Trace isRefreshing: boolean = false // 是否下拉刷新ing
  @Trace pendingCollectionMusic: MusicDetail | null = null; // 待收藏的音乐

  // 方法：
  // 下拉刷新
  onRefreshMusic(){}
  // 上拉加载
  onLoadMoreMusic(){}
  // 点击音乐
  onClickMusic(){}
  // 点击播放icon
  onClickPlayIcon(){}
  // 收藏音乐
  favouriteMusic(){}
  // 使用音乐
  useMusic(){}
  // 添加音乐
  addMusic(){}
  // 重命名音乐
  renameMusic(){}
  // 批量删除模式切换
  changeDelMode(){}
  // 删除音乐
  delMusic(){}
  // 批量删除
  private batchDelMusic(){}
  // 单个删除
  private delOneMusic(){}
}

// 通过 provider consumer 传递
@ObservedV2
export class MusicVM {
  waveSubject: BehaviorSubject<AudioRangeWaveInfo| null> = new BehaviorSubject<AudioRangeWaveInfo | null>(null)

  @Trace music: MusicDetail = new MusicDetail()
  @Trace isPlaying: boolean = false // 是否正在播放
  @Trace audioWaveInfo: AudioRangeWaveInfo | null = null
  @Trace musicPlayingProgress: MusicPlayingProgressInfo = new MusicPlayingProgressInfo(0, false) // 播放进度
  @Trace musicSelectStartPoint: number = 0 // 单位s

  // 方法：
  // 生成波形图
  calculateAudioWave(){}
  // 设置播放地址
  setUpAudio(){}
  // 下载音乐
  uploadMusic(){}
  // 播放音乐
  playMusic(){}
  // 暂停音乐
  pauseMusic(){}
  // 重置音乐
  resetMusic(){}
}

@ObservedV2
export class MusicPlayingProgressInfo {
  @Trace progress: number = 0 // 单位ms
  @Trace isFromUser: boolean = false

  constructor(progress: number, isFromUser: boolean) {
    this.progress = progress
    this.isFromUser = isFromUser
  }
}

//
// 1-musicMainVM.musicTab 改变了 去执行 musicVM.onPauseMusic()
// 2-播放和暂停的 状态判断为当地展示的 Tab 和 isMusicPlaying 的判断例子
// get isShowPlayIcon() {
//   return this.musicMainVM.musicTab == this.musicListVM.musicTab && this.musicVM.isPlaying
// }

// 注意点：
// 好多名称都改了，尤其是注意 Monitor 监听的地方都要回测一遍
// 下载完了，波形图生成完了，播放器加载好了 ID才能切换
// 在Main页面和热门分类页面 pageShow 和 pageHide 中去暂停音乐，如果是销毁了就去杀掉音乐，将他置空

// 没有下载完就切换Tab了，判断 musicMainVM.musicTab 是不是和传递进来的Tab一样，如果是就播放，不是就加载播放器了
// if (this.musicMainVM.musicTab != this.musicListVM.musicTab) {
//   return
// }

// 删除之后要将音乐重置掉 resetMusic
// onRefresh 执行之后要 调用这个 this.musicVM.resetMusic()


// 逐步替换原则
// 先替换 MusicVM ，其他的都是次要的

// aboutToAppear(): void {
//   this.onChangeFavIconColor() // 渲染页面就要去改变收藏的状态了
//   this.onAddImportData() // 新增导入 待写入
// }

// 新增导入音乐需要重新写下逻辑，完整代码：
// if (isAddImportData) {
//   // 获取到当前音乐的时间
//   musicObj.duration = parseInt(this.audioPlayerManager!.getAudioDuration().toString().split(".")[0])
//   // 保存导入后的音频
//   if (this.musicTabType == MusicTabAllEnum.MUSIC_IMPORT_EXTRACT) {
//
//   } else if (this.musicTabType == MusicTabAllEnum.MUSIC_IMPORT_SRC) {
//     // 导入解析后的音频
//     MusicPreferenceUtil.addLinkDownload(musicObj)
//   } else if (this.musicTabType == MusicTabAllEnum.MUSIC_IMPORT_LOCAL) {
//     // 导入手机里面的音频
//     MusicPreferenceUtil.addFolderAudio(musicObj)
//   }
// }
//
// Logger.i(MUSIC_TAG, "musicObj.duration" + JSON.stringify(musicObj.duration))

// 当新增导入数据的时候会自动播放 但是也要主要是否开启了批量删除模式
// @Monitor("musicListViewModel.isAddImportData", "musicMainViewModel.isAddImportData")
// onAddImportData() {
//   // 如果是导入新增数据的话 默认播放的功能 同时注意是否开启了批量删除的判断
//   Logger.i(MUSIC_TAG, "当前列表展示类型： " + this.musicTabType)
//   if (
//     !this.musicListViewModel.isEnableBatchDel
//       && this.musicListViewModel.isAddImportData
//       && (this.musicTabType == MusicTabAllEnum.MUSIC_IMPORT_EXTRACT
//       || this.musicTabType == MusicTabAllEnum.MUSIC_IMPORT_SRC
//       || this.musicTabType == MusicTabAllEnum.MUSIC_IMPORT_LOCAL)
//   ) {
//     // TODO 这里需要拿到当前的选中的id然后和当前的
//     if (this.currentArrSource.getInternalDataArray().findIndex((e) => e.id == this.musicListViewModel.musicActiveId) == 0) {
//       this.musicListViewModel.musicActiveId = -1
//     }
//
//     this.onMusicClicked(this.musicListViewModel.addImportData, 0, true)
//     this.musicListViewModel.isAddImportData = false
//     this.musicListViewModel.addImportData = new MusicDetail()
//   }
// }



// 增删改查，初始化页面的跳转，音频的状态留存，链接识别导入数据 本地提取数据

// TODO 下面的内容替换为上面的内容
this.musicMainVM.mainTabSelectIndex = 0
this.musicMainViewModel.musicShowState = MusicCurrentShowContent.MUSIC_MAIN_TAB


this.musicMainVM.mainTabSelectIndex
0 - main
1 - search hot
2 - search recommend
3 - search result


if (this.musicMainViewModel.musicShowState === MusicCurrentShowContent.MUSIC_MAIN_TAB) {
  this.musicMainViewModel.musicShowState = MusicCurrentShowContent.SEARCH_HOT
} else if (this.musicMainViewModel.musicShowState === MusicCurrentShowContent.SEARCH_RESULT) {
  this.musicMainViewModel.musicShowState = MusicCurrentShowContent.SEARCH_RECOMMEND
}


// TODO 将 下面的值 替换为 MusicCurrentShowContent 这个格式
this.musicMainVM.mainTabSelectIndex


  // TODO 滑动音乐库的搜索热词时关闭弹窗
  .onScrollStart(()=>{
    this.musicMainViewModel.isStopEditing =!this.musicMainViewModel.isStopEditing;
  })

// TODO tab跳转

musicMainVM.musicTab 中主框架 根据前缀去跳转
其他的框架根据关键字去跳转


// TODO MusicListViewModel 不删除
// MusicListViewModel 需要向外暴露 外边的话，罗志敏那边用到了

// TODO 搜索结果页 无论如何都是全部Tab
// MusicListViewModel 需要向外暴露 外边的话，罗志敏那边用到了

// TODO 外部新增的可以写着方法里面，onAddMusic
// MusicListViewModel 需要向外暴露 外边的话，罗志敏那边用到了

// TODO 音频--导入--本地音频导入，同一个音频，安卓可多次导入，生成的名称会有不同，鸿蒙导入只有一个记录
// TODO 音频--音乐--导入，提取音频和链接下载，批量删除，选择范围只有前面的小圈，安卓整个列表都可点击
// TODO 音乐库登录后会重复收藏的问题 只要和 exid 判断既可
// TODO 音乐库的音频的状态留存的问题

// TODO 链接识别能，然后添加到对应的列表的功 可能没有做好
// TODO 本地提取音频和解析音频 然后添加到对应的列表的功 可能没有做好
// 参考代码
// @Monitor("musicMainViewModel.isAddImportData")
// outSideDownload() {
//   if (this.isAddImportData) {
//     this.importUrlList.reload([this.musicMainViewModel.addImportData, ...this.importUrlList.getInternalDataArray()])
//     this.musicListViewModel.addImportData = this.musicMainViewModel.addImportData
//     this.musicListViewModel.isAddImportData = true
//     this.musicMainViewModel.isAddImportData = false
//   }
// }

// 注意点：
// 好多名称都改了，尤其是注意 Monitor 监听的地方都要回测一遍
// 下载完了，波形图生成完了，播放器加载好了 ID才能切换
// 在Main页面和热门分类页面 pageShow 和 pageHide 中去暂停音乐，如果是销毁了就去杀掉音乐，将他置空

——————————————————————————————————————————————————————————音乐库待办区域——————————————————————————————————————————————————————————
所有分类列表没有加载出来 V
快手收藏页面没有加载出来 V
推荐音乐不应该显示删除图标 V
搜索输入框切换时左侧图片不对 V
搜索输入框点击历史记录时要去搜索结果页，他还是被闪回了搜索热词推荐页 V
热门分类无数据展示 V
收藏的加一动画没有弹 V
点击音乐无反应 V
最近使用没有存储上 V
推荐音乐列表无法下拉刷新 V
音频先播放的问题，因在波形图加载后在播放音频 V
在Tab切换的时候要去改变 MainVM 中的 musicTab V
快手收藏显示不对 V
点击到导入tab时，无法播放音频 V

---------待开发区域
用两个播放器去优化，切换音源的效果，避免播放卡段问题

音乐库的音频的状态留存的问题：
在点击别的音乐的时候，在id切换之前，不要去更改是否播放的icon状态，还有不要切换音源，请使用 reset之后只切换 url 进行播放，避免在波形图加载完之后音乐无法播放的问题
如果是本列表中切换音源的话，不重置音乐，先加载波形图，加载完后，加载新的音源，
如果监听到切换列表了，只暂停，不重置

音乐的删除 重命名 弹窗 和 收藏的去登录弹窗都写在外面


// TODO 链接识别能，本地提取音频和解析音频 然后添加到对应的列表
// TODO pcursor 和 getDataState  下拉刷新 和 下来刷新 写到 VM当中
// TODO 音乐库登录后会重复收藏的问题 只要和 exid 判断既可
// TODO
未登录状态时，收藏的去登录弹窗出不来， 去登录的弹窗、重名名的弹窗重写
导入-提起音频默认显示播放图标，但是功能可以使用
导入-提起音频默认显示使用，只有点击才可以使用
导入-本地音频一直loading，播放功能有问题
音频--导入--本地音频导入，同一个音频，安卓可多次导入，生成的名称会有不同，鸿蒙导入只有一个记录
音频--音乐--导入，提取音频和链接下载，批量删除，选择范围只有前面的小圈，安卓整个列表都可点击
音乐库登录后会重复收藏的问题（如果该音乐已经被收藏了，那么就不要再收藏了，会重复被添加到音乐列表当中）
音乐库的音频的状态留存的问题

待更改
https://git.corp.kuaishou.com/incubation_app/kuaiying-harmony/-/commit/0a5391263d79d1b1124bcdc99a01b159f13db10a
  https://git.corp.kuaishou.com/incubation_app/kuaiying-harmony/-/commit/8bf99831960c34556807251027e973b8acb8b302



——————————————————————————————————————————————————————————模板音乐待办区域——————————————————————————————————————————————————————————
宁哥的拖拽组件-模板当中

Mr链接
https://git.corp.kuaishou.com/incubation_app/kuaiying-harmony/-/merge_requests/2102/diffs#d226a9cad59d02bfc6ab41d9576d87f2909b883d
  聚合页
有版权的音乐 ##7594299 ##6751826、13081520、7594299
文字硬编码的问题修复，代码的冗余去除和优化，例如，修改了高编的弹窗信息，删除


输入的话，弹出键盘和弹出正常
推荐模板的筛选效果没有过
所有筛选的缩略的文字的  如2和5-10，选中的最小段数项加...缩略显示，文案高亮显示“2段..."


点击去剪辑，先弹出音乐加载弹窗：音乐加载成功进入高级编辑选图页面
加载中点击取消,取消音乐加载，弹窗消失，返回同款音乐页面
首次安装快影，未在别处获取应用权限，点击去剪辑，进入选图页面前会先弹出权限弹脔：同意权限后加载音乐进入选图页面，导入素材后能同步音乐进入高级编辑，已在别处获取权限直接进入选图页面
无网络点击去剪辑，能正常进入选图页面选图后点击选好了，音乐未加载出来：.弹窗:音乐获取失败，请返回重试确定

去剪辑：（暂停开发）
1-返回页面时，要返回到高编内流页 同时将最外层的Tab切换到剪辑Tab (注意不要用Pop，用pop的pathName)
2-将该音乐添加到高编的音乐中
3-将该音乐添加到音乐库的最近使用中




// "trace-context": '{"laneId":"PRT.feat_template_music_fix_lzj_0708"}', // 关键头

硬编码去除，
