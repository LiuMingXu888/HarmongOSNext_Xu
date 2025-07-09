/**
 * 筛选实体类 - 定义筛选相关的数据结构和行为
 * 遵循单一职责原则：只负责筛选相关的数据和行为
 * 使用V2装饰器实现响应式数据绑定
 */

export enum FilterTabEnum {
  FRAGMENT = 0,
  ATTRIBUTE = 1,
  SORT = 2,
}

@ObservedV2
export class FilterCell {
  @Trace contentStart: number = 0
  @Trace contentEnd: number = 0
  @Trace content: string = ''
  @Trace supportEdit: boolean = false
  @Trace editPlaceholder: string = ''
  @Trace editType: number = 0
  @Trace selected: boolean = false
  @Trace isFilter: boolean = false

  constructor(
    contentStart: number = 0,
    contentEnd: number = 0,
    content: string = '',
    supportEdit: boolean = false,
    editPlaceholder: string = '',
    editType: number = 0,
    selected: boolean = false
  ) {
    this.contentStart = contentStart
    this.contentEnd = contentEnd
    this.content = content
    this.supportEdit = supportEdit
    this.editPlaceholder = editPlaceholder
    this.editType = editType
    this.selected = selected
  }

  // 业务方法
  getDisplayText(): string {
    if (this.content) return this.content
    
    if (this.contentEnd > 999) {
      return ">10"
    } else if (this.contentStart !== this.contentEnd) {
      return `${this.contentStart}-${this.contentEnd}`
    } else {
      return this.contentStart.toString()
    }
  }

  toggleSelection(): void {
    this.selected = !this.selected
  }

  reset(): void {
    this.selected = false
    this.isFilter = false
  }

  // 复制方法
  clone(): FilterCell {
    return new FilterCell(
      this.contentStart,
      this.contentEnd,
      this.content,
      this.supportEdit,
      this.editPlaceholder,
      this.editType,
      this.selected
    )
  }
}

@ObservedV2
export class FilterCategory {
  @Trace title: string = ''
  @Trace type: string = ''
  @Trace columnNumber: number = 4
  @Trace maxLine: number = 1
  @Trace selectSuffix: string = ''
  @Trace cells: FilterCell[] = []

  constructor(
    title: string = '',
    type: string = '',
    columnNumber: number = 4,
    maxLine: number = 1,
    selectSuffix: string = '',
    cells: FilterCell[] = []
  ) {
    this.title = title
    this.type = type
    this.columnNumber = columnNumber
    this.maxLine = maxLine
    this.selectSuffix = selectSuffix
    this.cells = cells
  }

  // 业务方法
  getSelectedCells(): FilterCell[] {
    return this.cells.filter(cell => cell.selected)
  }

  resetAllCells(): void {
    this.cells.forEach(cell => cell.reset())
  }

  addCell(cell: FilterCell): void {
    this.cells.push(cell)
  }

  // 复制方法
  clone(): FilterCategory {
    const category = new FilterCategory(
      this.title,
      this.type,
      this.columnNumber,
      this.maxLine,
      this.selectSuffix,
      this.cells.map(cell => cell.clone())
    )
    return category
  }
}

@ObservedV2
export class FilterTag {
  @Trace title: string = ''
  @Trace categories: FilterCategory[] = []

  constructor(title: string = '', categories: FilterCategory[] = []) {
    this.title = title
    this.categories = categories
  }

  // 业务方法
  getSelectedCategories(): FilterCategory[] {
    return this.categories.filter(category => 
      category.getSelectedCells().length > 0
    )
  }

  resetAllCategories(): void {
    this.categories.forEach(category => category.resetAllCells())
  }

  // 复制方法
  clone(): FilterTag {
    return new FilterTag(
      this.title,
      this.categories.map(category => category.clone())
    )
  }
} 