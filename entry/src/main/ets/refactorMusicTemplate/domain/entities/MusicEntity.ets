/**
 * 音乐实体类 - 定义音乐的基本属性和行为
 * 遵循单一职责原则：只负责音乐相关的数据和行为
 */
export class MusicEntity {
  private _id: string
  private _name: string
  private _artist: string
  private _duration: number
  private _musicUrl: string
  private _coverUrl: string
  private _useCount: number
  private _isCollected: boolean = false

  constructor(
    id: string,
    name: string,
    artist: string,
    duration: number,
    musicUrl: string,
    coverUrl: string,
    useCount: number = 0
  ) {
    this._id = id
    this._name = name
    this._artist = artist
    this._duration = duration
    this._musicUrl = musicUrl
    this._coverUrl = coverUrl
    this._useCount = useCount
  }

  // Getters
  get id(): string { return this._id }
  get name(): string { return this._name }
  get artist(): string { return this._artist }
  get duration(): number { return this._duration }
  get musicUrl(): string { return this._musicUrl }
  get coverUrl(): string { return this._coverUrl }
  get useCount(): number { return this._useCount }
  get isCollected(): boolean { return this._isCollected }

  // 业务方法
  toggleCollection(): void {
    this._isCollected = !this._isCollected
  }

  setCollectionStatus(status: boolean): void {
    this._isCollected = status
  }

  updateUseCount(count: number): void {
    this._useCount = count
  }

  // 格式化方法
  getFormattedDuration(): string {
    const minutes = Math.floor(this._duration / 60000)
    const seconds = Math.floor((this._duration % 60000) / 1000)
    return `${minutes}:${seconds.toString().padStart(2, '0')}`
  }

  getFormattedUseCount(): string {
    if (this._useCount >= 10000) {
      return (Math.round(this._useCount / 1000) / 10).toFixed(1) + '万'
    }
    return this._useCount.toString()
  }

  // 验证方法
  isValid(): boolean {
    return !!this._id && !!this._name && !!this._musicUrl
  }
} 