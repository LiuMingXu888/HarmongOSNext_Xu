import { KEventBus } from "@kwai/eventbus"
import { KRouter, UriRequest } from "@kwai/krouter"
import { Logger, NetworkUtil, ToastUtils } from "common_util"
import { USER_LOGIN_EVENT } from "login_event"
import { MUSIC_TEMPLATE_TAG } from "../../pages/MusicSameTemplatePage"

// 检查是否登录
export function checkUid(uid: string): boolean {
  if (uid) {
    return true
  }
  Logger.i(MUSIC_TEMPLATE_TAG, "UID不存在请先登录")
  return false
}

// 检查是否有网
export function checkNetWork(): boolean {
  if (NetworkUtil.getInstance().isNetworkAvailable()) {
    return true
  }
  ToastUtils.showToast($r('app.string.please_check_network'))
  return false
}

// 去登录
export function goToLogin(loginSuccess: () => void) {
  let request = UriRequest.create('kwaiying://guideLoginPage')
  KRouter.startUriRequest(request);
  KEventBus.subscribe(USER_LOGIN_EVENT, loginSuccess)
}