//
//  CFToolManager.m
//  CFAuthID
//
//  Created by 李方超 on 2019/11/28.
//  Copyright © 2019 dreamchaser. All rights reserved.
//

#import "CFToolManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation CFToolManager

/**
 * 获取KeyWindow
 */
+ (UIWindow *)getKeyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowSence in [UIApplication sharedApplication].connectedScenes) {
            window = windowSence.windows.firstObject;
            break;
        }
    } else {
        window = [UIApplication sharedApplication].delegate.window;
    }
    return window;
}

/**
 * 判断是否是iPhoneX以上版本
 */
+ (BOOL)getIsHighIphoneX {
    BOOL tmp = NO;
    if (@available(iOS 11.0, *)) {
        if ([self getKeyWindow].safeAreaInsets.bottom > 0) {
            tmp = YES;
        } else {
            tmp = NO;
        }
    } else {
        tmp = NO;
    }
    return tmp;
}

/**
 * 判断是否是iOS 8.0及以上版本
 */
+ (BOOL)getIsHighiOS8 {
    return NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0;
}

/**
 * 判断是否是iOS 9.0及以上版本
 */
+ (BOOL)getIsHighiOS9 {
    return NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0;
}

/**
 * 判断是否支持人脸或者指纹
 * RYXAuthIDState  返回支持状态
 */
+ (RYXAuthIDState)ryx_isSupportAuthID {
    if (![CFToolManager getIsHighiOS8]) {
        return RYXAuthIDStateNoSupport;
    } else {
        LAContext *context = [[LAContext alloc] init];
        context.localizedFallbackTitle = @"手动输入密码";
        if (@available(iOS 10.0, *)) {
            context.localizedCancelTitle = @"取消";
        } else {
            // Fallback on earlier versions
        }
        NSError *error = nil;
        if (@available(iOS 9.0, *)) {
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
                if ([CFToolManager getIsHighIphoneX]) {
                    return RYXAuthIDStateSupportFaceID;
                } else {
                    return RYXAuthIDStateSupportTouchID;
                }
            } else {
                return RYXAuthIDStateNoSupport;
            }
        } else {
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                if ([CFToolManager getIsHighIphoneX]) {
                    return RYXAuthIDStateSupportFaceID;
                } else {
                    return RYXAuthIDStateSupportTouchID;
                }
            } else {
                return RYXAuthIDStateNoSupport;
            }
        }
    }
}

/**
 * 获取顶部控制器
 */
+ (UIViewController *)topViewController {
    UIViewController *rootCtrl = [CFToolManager rootController];
    if ([rootCtrl isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)rootCtrl topViewController];
    } else if ([rootCtrl isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectCtrl = [(UITabBarController *)rootCtrl selectedViewController];
        if ([selectCtrl isKindOfClass:[UINavigationController class]]) {
            return [(UINavigationController *)selectCtrl topViewController];
        } else {
            return selectCtrl;
        }
    } else {
        if (rootCtrl.presentedViewController) {
            return rootCtrl.presentedViewController;
        } else {
            return rootCtrl;
        }
    }
}

/**
 * 获取根控制器
 */
+ (UIViewController *)rootController {
    return [CFToolManager getKeyWindow].rootViewController;
}

/**
 显示弹框
 
 @param title 标题
 @param msg 消息
 @param cancleTitle 取消按钮
 @param otherTitle 其他按钮
 @param clickIndex 选中回调
 */
+ (void)showAlert:(NSString *)title msg:(NSString *)msg cancleTitle:(NSString *)cancleTitle otherTitle:(NSString *)otherTitle finish:(callBack)clickIndex {
    
    UIAlertController *ctrl = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (cancleTitle && ![cancleTitle isEqualToString:@""]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancleTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            clickIndex(0);
        }];
        [ctrl addAction:action];
    }
    if (otherTitle && ![otherTitle isEqualToString:@""]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            clickIndex(1);
        }];
        [ctrl addAction:action];
    }
    
    [[CFToolManager topViewController] presentViewController:ctrl animated:YES completion:nil];
}

@end
