package cn.ling.yu.nfc.yulnfc.bean

import org.json.JSONObject


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
    override fun toString(): String {
        val jsonObject=JSONObject()
        jsonObject.apply {
            putOpt("uid",uid)
            putOpt("content",content)
            putOpt("code",code)
            putOpt("msg",msg)
        }
        return jsonObject.toString()
    }
}
