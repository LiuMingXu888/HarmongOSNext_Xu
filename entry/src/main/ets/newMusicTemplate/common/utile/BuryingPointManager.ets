import { FileUtils, Logger, ToastUtils } from "common_util";
import { TemplateInfos } from "../../components/temp/TempContentInnerWaterFlow";
import { MUSIC_TEMPLATE_TAG } from "../../pages/MusicSameTemplatePage";
import { HashMap } from "@kit.ArkTS";
import { NewReporter, ReportConstants } from "report";
import { TemplateInfo } from "temp_model";
import { TempRes } from "../../service/type";

// 埋点工具类
export class BuryingPointManager {
  private isFirstShow: boolean = false // 只有首次需要进行页面曝光

  // 点击埋点
  clickEvent(items: TemplateInfos) {
    const param = new HashMap<string, string>()
    param.set(ReportConstants.Param.IS_VIP_MV, items.needPay || (items.payType == 2).toString())
    param.set(ReportConstants.Param.MV_CLASS, items.produceType === "AE_TEMPLATE" ? "ae" : "wg")
    param.set(ReportConstants.Param.MV_TYPE, items.type?.replace("mv_", "") || "")
    param.set(ReportConstants.Param.MV_ID, items.id)
    param.set(ReportConstants.Param.TASK_FROM, 'list')
    param.set(ReportConstants.Param.IS_MARKET_MV, items.payType == 2 ? "1" : "0")
    param.set(ReportConstants.Param.QUERY, '')
    param.set(ReportConstants.Param.LLSID, items.requestId || items.sid)
    param.set(ReportConstants.Param.EXP_TAG, items.recoReason.toString())
    NewReporter.onClickEvent(ReportConstants.Event.MV_LIST_DETAIL_CLICK, param)
  }

  // 页面曝光埋点
  pageShow(item: TemplateInfos) {
    if (this.isFirstShow) return
    // 上报埋点 mv_list_page_show
    const param = new HashMap<string, string>()
    param.set(ReportConstants.Param.IS_VIP_MV, item.needPay || (item.payType == 2).toString())
    param.set(ReportConstants.Param.MV_CLASS, item.produceType === "AE_TEMPLATE" ? "ae" : "wg")
    param.set(ReportConstants.Param.MV_TYPE, item.type?.replace("mv_", "") || "")
    param.set(ReportConstants.Param.MV_ID, item.id)
    param.set(ReportConstants.Param.TASK_FROM, 'list')
    param.set(ReportConstants.Param.IS_MARKET_MV, item.payType == 2 ? "1" : "0")
    param.set(ReportConstants.Param.QUERY, '')
    param.set(ReportConstants.Param.LLSID, item.requestId || item.sid)
    param.set(ReportConstants.Param.EXP_TAG, item.recoReason.toString())
    NewReporter.onElementEvent(ReportConstants.Event.MV_LIST_PAGE_SHOW, param)
    this.isFirstShow = false
  }

  // 埋点
  reportTemplateInfo(res: TempRes, pcursor: boolean): TemplateInfo | undefined {
    try {
      if (res?.data.feedItems && res?.data.feedItems.length > 0) {
        const item = res?.data.feedItems[0].templateInfo as TemplateInfo // 多个模版取第一个
        if (item) {
          const param = new HashMap<string, string>()
          param.set(ReportConstants.Param.MV_NAME, item.name)
          param.set(ReportConstants.Param.PREVIOUS_CURSOR, pcursor ? '0' : res.data.nextCursor ? res.data.nextCursor.toString() : '0')
          param.set(ReportConstants.Param.MV_CLASS, item.produceType === "AE_TEMPLATE" ? "ae" : "wg")
          param.set(ReportConstants.Param.CATEGORY_ID, item?.id)
          param.set(ReportConstants.Param.MV_ID, item.id)
          param.set(ReportConstants.Param.TASK_FROM, 'list')
          param.set(ReportConstants.Param.LLSID, '')
          param.set(ReportConstants.Param.PAGE, 'MV_LIST')
          param.set(ReportConstants.Param.AUTHOR_ID, item.user.userId)
          NewReporter.onElementEvent(ReportConstants.Event.MV_LIST_SERVER_SHOW, param)
          return item
        }
      }
    } catch (e) {
      Logger.e(MUSIC_TEMPLATE_TAG, JSON.stringify(e))
    }
    return undefined
  }
}