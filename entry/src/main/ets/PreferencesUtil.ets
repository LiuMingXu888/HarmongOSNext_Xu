import preferences from '@ohos.data.preferences';

export default class PreferencesUtil {
  private static prefName: string = 'my_prefs';
  private static prefInstance: preferences.Preferences | null = null;

  // 获取 Preferences 实例（单例）
  private static async getInstance(context: any): Promise<preferences.Preferences> {
    if (!this.prefInstance) {
      this.prefInstance = await preferences.getPreferences(context, { name: this.prefName });
    }
    return this.prefInstance;
  }

  /**
   * 设置 key-value
   */
  static async set(context: any, key: string, value: any): Promise<void> {
    const pref = await this.getInstance(context);
    await pref.put(key, value);
    await pref.flush();
  }

  /**
   * 获取 key 的值
   */
  static async get(context: any, key: string, defaultValue?: any): Promise<any> {
    const pref = await this.getInstance(context);
    return await pref.get(key, defaultValue);
  }

  /**
   * 删除指定 key
   */
  static async remove(context: any, key: string): Promise<void> {
    const pref = await this.getInstance(context);
    await pref.delete(key);
    await pref.flush();
  }

  /**
   * 清空所有 key
   */
  static async clear(context: any): Promise<void> {
    const pref = await this.getInstance(context);
    await pref.clear();
    await pref.flush();
  }
} 