/**
 * 模板实体类 - 定义模板的基本属性和行为
 * 遵循单一职责原则：只负责模板相关的数据和行为
 */
export class TemplateEntity {
  private _id: string
  private _name: string
  private _coverUrl: string
  private _width: number
  private _height: number
  private _type: string
  private _needPay: boolean
  private _payType: number
  private _produceType: string
  private _requestId: string
  private _sid: string
  private _recoReason: number

  constructor(
    id: string,
    name: string,
    coverUrl: string,
    width: number,
    height: number,
    type: string,
    needPay: boolean = false,
    payType: number = 0,
    produceType: string = '',
    requestId: string = '',
    sid: string = '',
    recoReason: number = 0
  ) {
    this._id = id
    this._name = name
    this._coverUrl = coverUrl
    this._width = width
    this._height = height
    this._type = type
    this._needPay = needPay
    this._payType = payType
    this._produceType = produceType
    this._requestId = requestId
    this._sid = sid
    this._recoReason = recoReason
  }

  // Getters
  get id(): string { return this._id }
  get name(): string { return this._name }
  get coverUrl(): string { return this._coverUrl }
  get width(): number { return this._width }
  get height(): number { return this._height }
  get type(): string { return this._type }
  get needPay(): boolean { return this._needPay }
  get payType(): number { return this._payType }
  get produceType(): string { return this._produceType }
  get requestId(): string { return this._requestId }
  get sid(): string { return this._sid }
  get recoReason(): number { return this._recoReason }

  // 业务方法
  getAspectRatio(): number {
    return this._width / this._height
  }

  isVipTemplate(): boolean {
    return this._needPay || this._payType === 2
  }

  isMarketTemplate(): boolean {
    return this._payType === 2
  }

  getTemplateClass(): string {
    return this._produceType === "AE_TEMPLATE" ? "ae" : "wg"
  }

  getTemplateType(): string {
    return this._type?.replace("mv_", "") || ""
  }

  // 验证方法
  isValid(): boolean {
    return !!this._id && !!this._name && !!this._coverUrl
  }
} 