/**
 * 筛选实体类 - 定义筛选相关的数据结构和行为
 * 遵循单一职责原则：只负责筛选相关的数据和行为
 */
export enum FilterTabEnum {
  FRAGMENT = 0,
  ATTRIBUTE = 1,
  SORT = 2,
}

export class FilterCell {
  private _contentStart: number
  private _contentEnd: number
  private _content: string
  private _supportEdit: boolean
  private _editPlaceholder: string
  private _editType: number
  private _selected: boolean
  private _isFilter: boolean = false

  constructor(
    contentStart: number,
    contentEnd: number,
    content: string = '',
    supportEdit: boolean = false,
    editPlaceholder: string = '',
    editType: number = 0,
    selected: boolean = false
  ) {
    this._contentStart = contentStart
    this._contentEnd = contentEnd
    this._content = content
    this._supportEdit = supportEdit
    this._editPlaceholder = editPlaceholder
    this._editType = editType
    this._selected = selected
  }

  // Getters
  get contentStart(): number { return this._contentStart }
  get contentEnd(): number { return this._contentEnd }
  get content(): string { return this._content }
  get supportEdit(): boolean { return this._supportEdit }
  get editPlaceholder(): string { return this._editPlaceholder }
  get editType(): number { return this._editType }
  get selected(): boolean { return this._selected }
  get isFilter(): boolean { return this._isFilter }

  // Setters
  set selected(value: boolean) { this._selected = value }
  set isFilter(value: boolean) { this._isFilter = value }

  // 业务方法
  getDisplayText(): string {
    if (this._content) return this._content
    
    if (this._contentEnd > 999) {
      return ">10"
    } else if (this._contentStart !== this._contentEnd) {
      return `${this._contentStart}-${this._contentEnd}`
    } else {
      return this._contentStart.toString()
    }
  }

  toggleSelection(): void {
    this._selected = !this._selected
  }

  reset(): void {
    this._selected = false
    this._isFilter = false
  }
}

export class FilterCategory {
  private _title: string
  private _type: string
  private _columnNumber: number
  private _maxLine: number
  private _selectSuffix: string
  private _cells: FilterCell[]

  constructor(
    title: string,
    type: string,
    columnNumber: number,
    maxLine: number,
    selectSuffix: string,
    cells: FilterCell[] = []
  ) {
    this._title = title
    this._type = type
    this._columnNumber = columnNumber
    this._maxLine = maxLine
    this._selectSuffix = selectSuffix
    this._cells = cells
  }

  // Getters
  get title(): string { return this._title }
  get type(): string { return this._type }
  get columnNumber(): number { return this._columnNumber }
  get maxLine(): number { return this._maxLine }
  get selectSuffix(): string { return this._selectSuffix }
  get cells(): FilterCell[] { return this._cells }

  // 业务方法
  getSelectedCells(): FilterCell[] {
    return this._cells.filter(cell => cell.selected)
  }

  resetAllCells(): void {
    this._cells.forEach(cell => cell.reset())
  }

  addCell(cell: FilterCell): void {
    this._cells.push(cell)
  }
}

export class FilterTag {
  private _title: string
  private _categories: FilterCategory[]

  constructor(title: string, categories: FilterCategory[] = []) {
    this._title = title
    this._categories = categories
  }

  // Getters
  get title(): string { return this._title }
  get categories(): FilterCategory[] { return this._categories }

  // 业务方法
  getSelectedCategories(): FilterCategory[] {
    return this._categories.filter(category => 
      category.getSelectedCells().length > 0
    )
  }

  resetAllCategories(): void {
    this._categories.forEach(category => category.resetAllCells())
  }
} 