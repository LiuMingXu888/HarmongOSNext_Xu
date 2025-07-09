import { preferences } from "@kit.ArkData";
import { AppEnv } from "env";

export const isFirstCollectionMusic = "isFirstCollectionMusic"

// 管理音乐收藏弹窗的 SP 管理类
export class MusicDialogManager {

  private static sp: preferences.Preferences | null = null;

  private static getSp(): preferences.Preferences {
    if (MusicDialogManager.sp == null) {
      let options: preferences.Options = { name: 'first_music' };
      MusicDialogManager.sp = preferences.getPreferencesSync(AppEnv.getAppContext(), options)
    }
    return MusicDialogManager.sp;
  }

  // 判断是否隐私授权
  static getFirstCollectionMusic(): boolean {
    return MusicDialogManager.getSp().getSync(isFirstCollectionMusic, true) as boolean
  }

  // 允许隐私授权
  static setFirstCollectionMusic() {
    MusicDialogManager.getSp().putSync(isFirstCollectionMusic, false)
    MusicDialogManager.getSp().flush();
  }
}