package io.baizi.qrcode_reader;

import android.content.Intent;

import com.yzq.zxinglibrary.android.CaptureActivity;
import com.yzq.zxinglibrary.bean.ZxingConfig;
import com.yzq.zxinglibrary.common.Constant;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.app.Activity.RESULT_OK;

/** QrcodeReaderPlugin */
public class QrcodeReaderPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
  private FlutterActivity activity;
  private static final int REQUEST_CODE_SCAN = 2777;
  private Result pendingResult;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter.baizi.io/qrcode_reader");
    QrcodeReaderPlugin instance = new QrcodeReaderPlugin((FlutterActivity) registrar.activity());
    channel.setMethodCallHandler(instance);
    registrar.addActivityResultListener(instance);
  }

  public QrcodeReaderPlugin(FlutterActivity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("readQrCode")) {
      pendingResult = result;
      Intent intent = new Intent(this.activity, CaptureActivity.class);
      ZxingConfig config = new ZxingConfig();
      config.setPlayBeep(true);//是否播放扫描声音 默认为true
      config.setShake(true);//是否震动  默认为true
      config.setDecodeBarCode(false);//是否扫描条形码 默认为true
//      config.setReactColor(R.color.colorAccent);//设置扫描框四个角的颜色 默认为白色
//      config.setFrameLineColor(R.color.colorAccent);//设置扫描框边框颜色 默认无色
//      config.setScanLineColor(R.color.colorAccent);//设置扫描线的颜色 默认白色
      config.setFullScreenScan(false);//是否全屏扫描  默认为true  设为false则只会在扫描框中扫描
      intent.putExtra(Constant.INTENT_ZXING_CONFIG, config);
      activity.startActivityForResult(intent, REQUEST_CODE_SCAN);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    // 扫描二维码/条码回传
    if (requestCode == REQUEST_CODE_SCAN && resultCode == RESULT_OK) {
      if (data != null) {

        String content = data.getStringExtra(Constant.CODED_CONTENT);
        Map<String, Object> json = new HashMap<>();
        json.put("success", 1);
        json.put("result", content);
        pendingResult.success(json);
        return true;
      }
    }
    return false;
  }
}
