/**
 * 音乐实体类 - 定义音乐的核心属性和行为
 * 遵循单一职责原则：只负责音乐相关的数据和行为
 * 使用V2装饰器实现响应式数据绑定
 */
import { formatSecondsToMMSS } from 'common_util'

@ObservedV2
export class Music {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace artist: string = ''
  @Trace duration: number = 0
  @Trace musicUrl: string = ''
  @Trace coverUrl: string = ''
  @Trace useCount: number = 0
  @Trace isCollected: boolean = false
  @Trace encryptId: string = ''
  @Trace audioFingerprintId: string = ''
  @Trace musicType: number = 0
  @Trace enableLike: boolean = true
  @Trace haveCompleteMusic: boolean = false
  @Trace completeMusic: Music | null = null

  constructor(
    id: string = '',
    name: string = '',
    artist: string = '',
    duration: number = 0,
    musicUrl: string = '',
    coverUrl: string = '',
    useCount: number = 0
  ) {
    this.id = id
    this.name = name
    this.artist = artist
    this.duration = duration
    this.musicUrl = musicUrl
    this.coverUrl = coverUrl
    this.useCount = useCount
  }

  // 业务方法
  toggleCollection(): void {
    this.isCollected = !this.isCollected
  }

  setCollectionStatus(status: boolean): void {
    this.isCollected = status
  }

  updateUseCount(count: number): void {
    this.useCount = count
  }

  // 格式化方法
  getFormattedDuration(): string {
    return formatSecondsToMMSS(this.duration / 1000)
  }

  getFormattedUseCount(): string {
    if (this.useCount >= 10000) {
      return (Math.round(this.useCount / 1000) / 10).toFixed(1) + '万'
    }
    return this.useCount.toString()
  }

  // 验证方法
  isValid(): boolean {
    return !!this.id && !!this.name && !!this.musicUrl
  }

  // 复制方法
  clone(): Music {
    const music = new Music(
      this.id,
      this.name,
      this.artist,
      this.duration,
      this.musicUrl,
      this.coverUrl,
      this.useCount
    )
    music.isCollected = this.isCollected
    music.encryptId = this.encryptId
    music.audioFingerprintId = this.audioFingerprintId
    music.musicType = this.musicType
    music.enableLike = this.enableLike
    music.haveCompleteMusic = this.haveCompleteMusic
    music.completeMusic = this.completeMusic
    return music
  }

  // 从API数据创建Music实例
  static fromApiData(data: any): Music {
    const music = new Music(
      data.musicId || data.id,
      data.name,
      data.artist || '',
      data.duration || 0,
      data.musicUrl,
      data.coverUrl,
      data.useCount || 0
    )
    music.encryptId = data.encryptId || data.encryptMusicId || ''
    music.audioFingerprintId = data.audioFingerprintId || ''
    music.musicType = data.musicType || 0
    music.enableLike = data.enableLike !== false
    music.haveCompleteMusic = data.haveCompleteMusic || false
    if (data.completeMusic) {
      music.completeMusic = Music.fromApiData(data.completeMusic)
    }
    return music
  }
} 