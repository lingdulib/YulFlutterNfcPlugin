package cn.ling.yu.nfc.yulnfc

import java.util.*
import kotlin.experimental.and

/**
 * 转字节
 * @author Yu L.
 * @date 2022/3/29
 * @email 237881235@qq.com
 */
object ByteToConvertStringUtils {

    fun bytesToHexString(src: ByteArray?, len: Int): String? {
        val stringBuilder = StringBuilder("")
        if (src == null || src.isEmpty()) {
            return null
        }
        if (len <= 0) {
            return ""
        }
        for (i in 0 until len) {
            val v: Int = (src[i] and 0xFF.toByte()).toInt()
            val hv = Integer.toHexString(v)
            if (hv.length < 2) {
                stringBuilder.append(0)
            }
            stringBuilder.append(hv)
        }
        return stringBuilder.toString()
    }

    fun isHexAnd16Byte(hexString: String): Boolean {
        return hexString.matches("[0-9A-Fa-f]+".toRegex())
    }

    fun hexStringToBytes(hexString: String?): ByteArray? {
        var hexTempString = hexString
        if (hexTempString == null || hexTempString == "") {
            return null
        }
        hexTempString = hexTempString.uppercase(Locale.getDefault())
        val length = hexTempString.length / 2
        val hexChars = hexTempString.toCharArray()
        val d = ByteArray(length)
        for (i in 0 until length) {
            val pos = i * 2
            d[i] = (charToByte(hexChars[pos]).toInt() shl 4 or charToByte(hexChars[pos + 1]).toInt()).toByte()
        }

        return d
    }

    private fun charToByte(c: Char): Byte {
        return "0123456789ABCDEF".indexOf(c).toByte()
    }

}


