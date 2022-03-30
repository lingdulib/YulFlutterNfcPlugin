package cn.ling.yu.nfc.yulnfc

import android.nfc.tech.MifareClassic
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import cn.ling.yu.nfc.yulnfc.bean.NfcDataInfoBean

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception

/** YulnfcPlugin */
class YulnfcPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var mActivityPluginBinding: ActivityPluginBinding
    private val TAG=YulnfcPlugin::javaClass.name

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "yulnfc")
        channel.setMethodCallHandler(this)
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "nfcSupport" -> {//是否支持nfc
                handler.postDelayed({
                    result.success(
                        NfcCardUtils.supportNfc()
                    )
                }, 500)
            }
            "nfcEnable" -> {//nfc是否可用
                handler.postDelayed(
                    { result.success(NfcCardUtils.enableNfc()) },
                    500
                )
            }
            "openNfcSetting" -> {//打开设置
                NfcCardUtils.startNfcSetting(mActivityPluginBinding)
                handler.postDelayed({ result.success(true) }, 500)
            }
            "readNfcCard" -> {//读取某扇区内容
                val requestParamters = call.arguments as Map<*, *>
                Log.e(TAG,"reqp===>$requestParamters")
                NfcCardUtils.startReaderMode(mActivityPluginBinding) { tag ->
                    val uid = ByteToConvertStringUtils.bytesToHexString(tag.id, tag.id.size)
                    Log.e(TAG,"uid====>$uid")
                    mActivityPluginBinding.activity.runOnUiThread {
                        Toast.makeText(mActivityPluginBinding.activity,"uid====>$uid,size->${tag.techList.size}",Toast.LENGTH_LONG).show()
                    }
                    tag.techList.forEach { tech ->
                        mActivityPluginBinding.activity.runOnUiThread {
                            Toast.makeText(mActivityPluginBinding.activity,"name==>$tech,m1 className===>${MifareClassic::javaClass.name}",Toast.LENGTH_LONG).show()
                        }
                        if (TextUtils.equals(tech, MifareClassic::javaClass.name)) {
                            mActivityPluginBinding.activity.runOnUiThread {
                                Toast.makeText(mActivityPluginBinding.activity,"m1card",Toast.LENGTH_LONG).show()
                            }
                            val mfc = MifareClassic.get(tag)
                            mfc.connect()
                            try {
                                val sectorCount = mfc.sectorCount
                                if (sectorCount > 0) {
                                    if (mfc.authenticateSectorWithKeyA(
                                            requestParamters["sectorIndex"] as Int,
                                            ByteToConvertStringUtils.hexStringToBytes(
                                                requestParamters["sectorPwd"] as String
                                            )
                                        )
                                    ) {
                                        val blockIndex =
                                            mfc.sectorToBlock(requestParamters["blockIndex"] as Int)
                                        if (blockIndex >= 0) {
                                            val blockData = mfc.readBlock(blockIndex)
                                            val blockDataHex =
                                                ByteToConvertStringUtils.bytesToHexString(
                                                    blockData,
                                                    blockData.size
                                                )
                                            mfc.close()
                                            handler.postDelayed({
                                                result.success(
                                                    NfcDataInfoBean(
                                                        code = SUCCESS,
                                                        content = blockDataHex,
                                                        uid = uid
                                                    )
                                                )
                                            }, 500)
                                        } else {
                                            mfc.close()
                                            handler.postDelayed({
                                                result.success(
                                                    NfcDataInfoBean(
                                                        code = FAIL,
                                                        msg = "传入扇区块异常."
                                                    )
                                                )
                                            }, 500)
                                        }
                                    } else {
                                        mfc.close()
                                        handler.postDelayed({
                                            result.success(
                                                NfcDataInfoBean(
                                                    code = FAIL,
                                                    msg = "验证扇区密码错误."
                                                )
                                            )
                                        }, 500)
                                    }
                                }
                            } catch (e: Exception) {
                                mfc.close()
                                handler.postDelayed({
                                    result.success(
                                        NfcDataInfoBean(
                                            code = FAIL,
                                            msg = "读卡器异常,请重试."
                                        )
                                    )
                                }, 500)
                            }
                        }
                    }
                }
            }
            "writeNfcCard" -> {
                val requestParamters = call.arguments as Map<*, *>
                NfcCardUtils.startReaderMode(mActivityPluginBinding) { tag ->
                    val uid = ByteToConvertStringUtils.bytesToHexString(tag.id, tag.id.size)
                    tag.techList.forEach { tech ->
                        if (TextUtils.equals(tech, MifareClassic::javaClass.name)) {
                            val mfc = MifareClassic.get(tag)
                            mfc.connect()
                            try {
                                val sectorCount = mfc.sectorCount
                                if (sectorCount > 0) {
                                    if (mfc.authenticateSectorWithKeyA(
                                            requestParamters["sectorIndex"] as Int,
                                            ByteToConvertStringUtils.hexStringToBytes(
                                                requestParamters["sectorPwd"] as String
                                            )
                                        )
                                    ) {
                                        val blockIndex =
                                            mfc.sectorToBlock(requestParamters["blockIndex"] as Int)
                                        if (blockIndex >= 0) {
                                            mfc.writeBlock(
                                                blockIndex,
                                                ByteToConvertStringUtils.convertStringTo16Bytes(
                                                    requestParamters["writeContent"] as String?
                                                )
                                            )
                                            mfc.close()
                                            handler.postDelayed({
                                                result.success(
                                                    NfcDataInfoBean(
                                                        code = SUCCESS,
                                                        content = requestParamters["writeContent"] as String?,
                                                        uid = uid
                                                    )
                                                )
                                            }, 500)
                                        } else {
                                            mfc.close()
                                            handler.postDelayed({
                                                result.success(
                                                    NfcDataInfoBean(
                                                        code = FAIL,
                                                        msg = "传入扇区块异常."
                                                    )
                                                )
                                            }, 500)
                                        }
                                    } else {
                                        mfc.close()
                                        handler.postDelayed({
                                            result.success(
                                                NfcDataInfoBean(
                                                    code = FAIL,
                                                    msg = "验证扇区密码错误."
                                                )
                                            )
                                        }, 500)
                                    }
                                }
                            } catch (e: Exception) {
                                mfc.close()
                                handler.postDelayed({
                                    result.success(
                                        NfcDataInfoBean(
                                            code = FAIL,
                                            msg = "读卡器异常,请重试."
                                        )
                                    )
                                }, 500)
                            }
                        }
                    }
                }
            }
            "stopNfcCard" -> {
                NfcCardUtils.stopReaderMode(mActivityPluginBinding)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivityPluginBinding = binding
        NfcCardUtils.initNfcService(mActivityPluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivityPluginBinding = binding
    }

    override fun onDetachedFromActivity() {
    }
}
