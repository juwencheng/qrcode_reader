//
//  CDZQRCodeViewController.m
//  CDZQRCodeDemo
//
//  Created by Nemocdz on 2017/4/20.
//  Copyright © 2017年 Nemocdz. All rights reserved.
//

#import "CDZQRScanViewController.h"
#import "CDZQRScanView.h"
#import <Photos/Photos.h>

@interface CDZQRScanViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CDZQRScanDelegate>
@property (nonatomic ,strong) CDZQRScanView *scanView;
@property (nonatomic ,strong) UIImagePickerController *imagePicker;
@end

@implementation CDZQRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self.scanView startScanning];
}


- (void)setupViews{
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *libaryItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openLibary)];
    self.navigationItem.rightBarButtonItem = libaryItem;
    self.navigationItem.title = @"扫描二维码";
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    self.navigationItem.leftBarButtonItem = closeItem;
    [self.view addSubview:self.scanView];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openLibary{
    if (![self isLibaryAuthStatusCorrect]) {
        if (self.scanResult) {
            self.scanResult([self assmbleFailedMessage:@"需要相册权限"]);
        }
        return;
    }
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


- (NSString *)messageFromQRCodeImage:(UIImage *)image{
    if (!image) {
        return nil;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    if (features.count == 0) {
        return nil;
    }
    CIQRCodeFeature *feature = features.firstObject;
    return feature.messageString;
}


- (BOOL)isLibaryAuthStatusCorrect{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusNotDetermined || authStatus == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}


- (void)showAlert:(NSString *)message action:(void(^)())action{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:action];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - imagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSString *result = [self messageFromQRCodeImage:image];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (result.length == 0) {
            if (self.scanResult) {
                self.scanResult([self assmbleFailedMessage:@"未识别到二维码"]);
            }
            return;
        }
        if (self.scanResult) {
            self.scanResult([self assmbleSuccessResult:result]);
        }
    }];
    
}


#pragma mark - scanViewDelegate
- (void)scanView:(CDZQRScanView *)scanView pickUpMessage:(NSString *)message{
    [scanView stopScanning];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.scanResult) {
        self.scanResult([self assmbleSuccessResult:message]);
    }
}

#pragma mark - Flutter method
- (NSDictionary *)assmbleSuccessResult:(NSString *)message {
    return @{
             @"success": @1,
             @"result": message
             };
}

- (NSDictionary *)assmbleFailedMessage:(NSString *)message {
    return @{
             @"success": @0,
             @"result": message
             };
}


#pragma mark - get

- (CDZQRScanView *)scanView{
    if (!_scanView) {
        _scanView = [[CDZQRScanView alloc]initWithFrame:self.view.bounds];
        _scanView.delegate = self;
        _scanView.showBorderLine = YES;
    }
    return _scanView;
}


- (UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}
@end
