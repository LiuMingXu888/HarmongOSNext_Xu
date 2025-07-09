import { AudioPlayerManager } from "audio_manager"
import { ResourceFileInfo } from "base_model"
import { Logger } from "common_util"
import { MaterialDownloadManager, MaterialType } from "component_material_mgr"
import { BizType, Succeeded } from "download"
import { ChildDir, ParentDir, PathCreator } from "file_manager"
import { Music } from "temp_model"
import { MUSIC_TEMPLATE_TAG } from "../../pages/MusicSameTemplatePage"
import { Description, TemplateData } from "./TempModel"

export interface IMusicService {
  isPlaying: boolean
  musicDownloadPath: string
  setUpMusic: (music: Description, isImmediatelyPlay: boolean) => Promise<void>
  togglePlay: () => void
  pause: () => void
  resume: () => void
  reset: () => void
  changePlayBack: (isPlaying: boolean) => void
}

// 模板音乐播放器相关
@ObservedV2
export class TempMusicVM implements IMusicService {
  @Trace musicDownloadPath: string = "" // 音乐下载路径
  @Trace currentTime: number = 0
  @Trace private playing: boolean = true // 是否播放当前音乐
  @Trace private playingBack: boolean = true
  audioPlayerManager: AudioPlayerManager = new AudioPlayerManager() // 播放音频的类

  @Computed
  get isPlaying(): boolean {
    return this.playing;
  }

  changePlayBack(isPlaying: boolean) {
    this.playingBack = isPlaying
  }

  /**
   * 播放音源
   * @param url
   * @param isImmediatelyPlay
   * */
  async setUpMusic(music: Description | Music, isImmediatelyPlay: boolean) {
    let path = music.musicUrl || ""
    if (path) {
      Logger.i(MUSIC_TEMPLATE_TAG,"地址不对，播放错误")
    }

    this.audioPlayerManager?.setDataSourceAndPlay(
      {
        path, // 播放路径
        playImmediately: false,
        prepareCbs: () => {
          Logger.i(MUSIC_TEMPLATE_TAG,"资源准备完毕，准备播放")
          if (isImmediatelyPlay) {
            this.resume()
          }
        },
        playingCbs: () => {
          Logger.i(MUSIC_TEMPLATE_TAG,"资源准备完毕，开始播放")
        },
        progressCbs: (progress: number) => {
          this.currentTime = progress
          Logger.i(MUSIC_TEMPLATE_TAG, "音频进度发生改变sss musicPlayingProgress:"+progress)
        },
        completeCbs: () => {
          this.audioPlayerManager?.resumeAudioPlay()
        }, // 播放结束后
      }
    );

    this.musicDownloadPath = await this.onDownload(music)
  }

  togglePlay() {
    this.playing ? this.pause() : this.resume();
    this.playing = !this.playing;
  }

  reset() {
    this.playing = true
    this.audioPlayerManager.resetAudioPlay();
  }

  pause() {
    this.playing = false
    this.audioPlayerManager.pauseAudioPlay();
  }

  resume() {
    // 恢复播放时, 如果上一次没有播放就不会播放了
    if (!this.playingBack) {
      this.playingBack = true
      return
    }
    this.playing = true
    this.audioPlayerManager.resumeAudioPlay();
  }

  // 下载事件
  private async onDownload(music: Description | Music) {
    // 定义 ResourceFileInfo 对象
    let lastQuesMarkIndex = music.musicUrl.lastIndexOf("?") != -1 ? music.musicUrl.lastIndexOf("?") : undefined
    let suffix = music.musicUrl.substring(music.musicUrl.lastIndexOf("."), lastQuesMarkIndex)
    const resourceFileInfo: ResourceFileInfo = {
      url:music.musicUrl!,
      hash: music.musicId,
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
        materialId: music.musicId.toString(),
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
}