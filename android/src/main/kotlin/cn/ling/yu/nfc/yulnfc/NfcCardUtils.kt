package cn.ling.yu.nfc.yulnfc

import android.content.Intent
import android.nfc.NfcAdapter
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/**
 * @author Yu L.
 * @date 2022/3/28
 * @email 237881235@qq.com
 */
object NfcCardUtils {

    private var mNfcAdapter:NfcAdapter?=null

    /**
     * true : 支持 , false : 不支持
     */
    fun supportNfc():Boolean= mNfcAdapter!=null

    /**
     * 初始化nfc
     */
    fun initNfcService(activityPluginBinding: ActivityPluginBinding){
        mNfcAdapter= NfcAdapter.getDefaultAdapter(activityPluginBinding.activity)
    }

    /**
     * true : 启用 , false : 未启用
     */
    fun enableNfc():Boolean= mNfcAdapter!=null && mNfcAdapter!!.isEnabled
    /**
     * 启动nfc菜单
     */
    fun startNfcSetting(activityPluginBinding: ActivityPluginBinding)= mNfcAdapter?.let {
        activityPluginBinding.activity.startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
    }

    /**
     * 寻卡 仅支持 MifareClassic
     */
    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun startReaderMode(activityPluginBinding: ActivityPluginBinding,callback:NfcAdapter.ReaderCallback?){
        val bundle=Bundle()
        bundle.putInt(NfcAdapter.EXTRA_READER_PRESENCE_CHECK_DELAY,5*1000)
        mNfcAdapter?.enableReaderMode(activityPluginBinding.activity,callback,NfcAdapter.FLAG_READER_NFC_A,bundle)
    }

    /**
     * 停止寻卡
     */
    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun stopReaderMode(activityPluginBinding: ActivityPluginBinding)= mNfcAdapter?.disableReaderMode(activityPluginBinding.activity)

}