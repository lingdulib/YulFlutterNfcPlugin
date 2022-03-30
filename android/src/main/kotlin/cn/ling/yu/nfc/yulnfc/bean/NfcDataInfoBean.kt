package cn.ling.yu.nfc.yulnfc.bean

import com.google.gson.GsonBuilder


/**
 * @author Yu L.
 * @date 2022/3/28
 * @email 237881235@qq.com
 */
data class NfcDataInfoBean(
    val uid: String? = null,//设备uid
    val content: String? = null,//设备内容
    val code: String? = null,//错误码
    val msg: String? = null//错误信息
) {
    private val mGson = GsonBuilder().disableHtmlEscaping().serializeNulls().create()
    override fun toString(): String {
        return mGson.toJson(this)
    }
}
