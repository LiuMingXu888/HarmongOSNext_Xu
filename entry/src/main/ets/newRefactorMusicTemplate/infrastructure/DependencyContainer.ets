/**
 * 依赖注入容器 - 管理应用程序的依赖关系
 * 遵循依赖倒置原则：高层模块不依赖低层模块，都依赖抽象
 */
import { IMusicRepository } from '../domain/repositories/IMusicRepository'
import { IMusicService } from '../domain/services/IMusicService'
import { MusicRepositoryImpl } from '../data/repositories/MusicRepositoryImpl'
import { MusicService } from '../domain/services/MusicService'

export class DependencyContainer {
  private static instance: DependencyContainer
  private services: Map<string, any> = new Map()

  private constructor() {
    this.registerServices()
  }

  static getInstance(): DependencyContainer {
    if (!DependencyContainer.instance) {
      DependencyContainer.instance = new DependencyContainer()
    }
    return DependencyContainer.instance
  }

  private registerServices(): void {
    // 注册仓库
    this.register<IMusicRepository>('IMusicRepository', () => {
      return MusicRepositoryImpl.getInstance()
    })

    // 注册服务
    this.register<IMusicService>('IMusicService', () => {
      const repository = this.resolve<IMusicRepository>('IMusicRepository')
      return MusicService.getInstance(repository)
    })
  }

  register<T>(key: string, factory: () => T): void {
    this.services.set(key, factory)
  }

  resolve<T>(key: string): T {
    const factory = this.services.get(key)
    if (!factory) {
      throw new Error(`Service not found: ${key}`)
    }
    return factory()
  }

  // 获取音乐服务实例
  getMusicService(): IMusicService {
    return this.resolve<IMusicService>('IMusicService')
  }

  // 获取音乐仓库实例
  getMusicRepository(): IMusicRepository {
    return this.resolve<IMusicRepository>('IMusicRepository')
  }
} 