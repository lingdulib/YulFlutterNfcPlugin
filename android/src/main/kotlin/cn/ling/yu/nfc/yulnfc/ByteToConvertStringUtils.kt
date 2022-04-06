package cn.ling.yu.nfc.yulnfc

import android.text.TextUtils
import java.util.*
import kotlin.experimental.and

/**
 * 转字节
 * @author Yu L.
 * @date 2022/3/29
 * @email 237881235@qq.com
 */
object ByteToConvertStringUtils {

    fun bytes2HexString(data: ByteArray?): String? {
        if (data == null) return ""
        val buffer = java.lang.StringBuilder()
        for (b in data) {
            val hex = Integer.toHexString((b.toInt() and 0xff))
            if (hex.length == 1) {
                buffer.append('0')
            }
            buffer.append(hex)
        }
        return buffer.toString()
    }

    fun isHexAnd16Byte(hexString: String): Boolean {
        return hexString.matches("[0-9A-Fa-f]+".toRegex())
    }

    fun hexStringToBytes(hexString: String?): ByteArray? {
       // val hexTempString = hexString
        if (hexString == null || hexString == "") {
            return null
        }
        //hexTempString = hexTempString.uppercase(Locale.getDefault())
        val length = hexString.length / 2
        val hexChars = hexString.toCharArray()
        val d = ByteArray(length)
        for (i in 0 until length) {
            val pos = i * 2
            d[i] =
                (charToByte(hexChars[pos]).toInt() shl 4 or charToByte(hexChars[pos + 1]).toInt()).toByte()
        }

        return d
    }

    fun convertStringTo16Bytes(content: String?): ByteArray? {
        if (TextUtils.isEmpty(content)) {
            return null
        }
        var bytes: ByteArray = hexStringToBytes(content)!!
        if (bytes.size != 16) {
            val temp = ByteArray(16)
            for (i in temp.indices) {
                temp[i] = if (bytes.size > i) bytes[i] else -1
            }
            bytes = temp
        }
        return bytes;
    }

    private fun charToByte(c: Char): Byte {
        return "0123456789ABCDEF".indexOf(c).toByte()
    }

}


