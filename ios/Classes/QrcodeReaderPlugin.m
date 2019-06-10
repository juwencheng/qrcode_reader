#import "QrcodeReaderPlugin.h"
#import "CDZQRScanViewController.h"
@implementation QrcodeReaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter.baizi.io/qrcode_reader"
            binaryMessenger:[registrar messenger]];
  QrcodeReaderPlugin* instance = [[QrcodeReaderPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"readQrCode" isEqualToString:call.method]) {
      UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
      CDZQRScanViewController *scanViewController = [[CDZQRScanViewController alloc] init];
      scanViewController.scanResult = result;
      UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:scanViewController];
      [rootViewController presentViewController:navi animated:YES completion:nil];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
