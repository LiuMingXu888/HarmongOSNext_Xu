/**
 * 模板实体类 - 定义模板的核心属性和行为
 * 遵循单一职责原则：只负责模板相关的数据和行为
 * 使用V2装饰器实现响应式数据绑定
 */
import { Music } from './Music'

@ObservedV2
export class Template {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace coverUrl: string = ''
  @Trace width: number = 0
  @Trace height: number = 0
  @Trace type: string = ''
  @Trace needPay: boolean = false
  @Trace payType: number = 0
  @Trace produceType: string = ''
  @Trace requestId: string = ''
  @Trace sid: string = ''
  @Trace recoReason: number = 0
  @Trace music: Music | null = null
  @Trace user: any = null
  @Trace verticalList: any = null

  constructor(
    id: string = '',
    name: string = '',
    coverUrl: string = '',
    width: number = 0,
    height: number = 0,
    type: string = '',
    needPay: boolean = false,
    payType: number = 0,
    produceType: string = '',
    requestId: string = '',
    sid: string = '',
    recoReason: number = 0
  ) {
    this.id = id
    this.name = name
    this.coverUrl = coverUrl
    this.width = width
    this.height = height
    this.type = type
    this.needPay = needPay
    this.payType = payType
    this.produceType = produceType
    this.requestId = requestId
    this.sid = sid
    this.recoReason = recoReason
  }

  // 业务方法
  getAspectRatio(): number {
    return this.width / this.height
  }

  isVipTemplate(): boolean {
    return this.needPay || this.payType === 2
  }

  isMarketTemplate(): boolean {
    return this.payType === 2
  }

  getTemplateClass(): string {
    return this.produceType === "AE_TEMPLATE" ? "ae" : "wg"
  }

  getTemplateType(): string {
    return this.type?.replace("mv_", "") || ""
  }

  // 验证方法
  isValid(): boolean {
    return !!this.id && !!this.name && !!this.coverUrl
  }

  // 复制方法
  clone(): Template {
    const template = new Template(
      this.id,
      this.name,
      this.coverUrl,
      this.width,
      this.height,
      this.type,
      this.needPay,
      this.payType,
      this.produceType,
      this.requestId,
      this.sid,
      this.recoReason
    )
    template.music = this.music?.clone() || null
    template.user = this.user
    template.verticalList = this.verticalList
    return template
  }

  // 从API数据创建Template实例
  static fromApiData(data: any): Template {
    const template = new Template(
      data.id,
      data.name,
      data.coverUrl,
      data.width || 0,
      data.height || 0,
      data.type || '',
      data.needPay || false,
      data.payType || 0,
      data.produceType || '',
      data.requestId || '',
      data.sid || '',
      data.recoReason || 0
    )
    if (data.music) {
      template.music = Music.fromApiData(data.music)
    }
    template.user = data.user
    template.verticalList = data.verticalList
    return template
  }
} 