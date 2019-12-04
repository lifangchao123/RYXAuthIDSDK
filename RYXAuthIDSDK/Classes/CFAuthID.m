//
//  CFAuthID.m
//  CFAuthID
//
//  Created by 李方超 on 2019/11/27.
//  Copyright © 2019 dreamchaser. All rights reserved.
//

#import "CFAuthID.h"
#import "CommonHeaders.h"

@implementation CFAuthID

/**
 * 判断逻辑：
 * 1、先判断用户是否支持是iOS8.0以上版本，不是的话，直接返回错误。
 * 2、如果是iOS8.0以上版本，再判断是否支持faceID，
 *  2.1、支持，判断是否设置了faceID，
 *   2.1.1、设置了faceID：使用faceID进行认证，成功进行下一步，失败返回错误。
 *   2.1.2、未设置faceID：执行2.2的操作。
 *  2.2、不支持，再判断是否设置了touchID，
 *   2.2.1、设置了touchID：使用touchID进行验证，成功进行下一步，失败返回错误。
 *   2.2.2、未设置touchID：使用短信密码去完成验证
 */
+ (void)cf_showAuthIDWithDescribe:(NSString *)describe block:(CFAuthIDStateBlock)block {
    if(!describe) {
        if ([CFToolManager getIsHighIphoneX]) {
            describe = @"验证已有面容";
        } else {
            describe = @"通过Home键验证已有指纹";
        }
    }
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)");
            block(CFAuthIDStateVersionNotSupport, nil);
        });
        
        return;
    }
    
    LAContext *context = [[LAContext alloc] init];
    
    /**
     * 认证失败提示信息，为 @"" 则不提示
     */
    context.localizedFallbackTitle = @"输入密码";
    
    NSError *error = nil;
    
    /**
     * LAPolicyDeviceOwnerAuthenticationWithBiometrics: 是支持iOS8i以上系统，使用该设备的Touch ID进行验证，当输入Touch ID失败5次后，Touch ID被锁定，只能通过锁屏后解锁设备s时输入正确的解锁密码来解锁Touch ID。
     * LAPolicyDeviceOwnerAuthentication: 是支持iOS9以上系统，使用该设备的Touch ID或密码进行验证，当输入Touch ID失败3次后，会触发设备密码页面进行验证，此时点击取消可以继续进行Touch ID验证，不过此次之后2次验证机会，验证失败后，Touch ID被锁定，触发设备密码界面进行验证。
     * 但是使用LAPolicyDeviceOwnerAuthentication点击手动输入密码按钮也会触发设备密码页面，不会回调evaluatePolicy里面的方法。
     */
    if (@available(iOS 9.0, *)) {
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
                
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"TouchID/FaceID 验证成功");
                        block(CFAuthIDStateSuccess, error);
                    });
                }else if(error){
                    
                    if (@available(iOS 11.0, *)) {
                        switch (error.code) {
                            case LAErrorAuthenticationFailed:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 验证失败");
                                    block(CFAuthIDStateFail, error);
                                });
                                break;
                            }
                            case LAErrorUserCancel:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 被用户手动取消");
                                    block(CFAuthIDStateUserCancel, error);
                                });
                            }
                                break;
                            case LAErrorUserFallback:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"用户不使用TouchID/FaceID,选择手动输入密码");
                                    block(CFAuthIDStateInputPassword, error);
                                });
                            }
                                break;
                            case LAErrorSystemCancel:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                                    block(CFAuthIDStateSystemCancel, error);
                                });
                            }
                                break;
                            case LAErrorPasscodeNotSet:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置密码");
                                    block(CFAuthIDStatePasswordNotSet, error);
                                });
                            }
                                break;
                                //case LAErrorTouchIDNotEnrolled:{
                            case LAErrorBiometryNotEnrolled:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID");
                                    block(CFAuthIDStateTouchIDNotSet, error);
                                });
                            }
                                break;
                                //case LAErrorTouchIDNotAvailable:{
                            case LAErrorBiometryNotAvailable:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 无效");
                                    block(CFAuthIDStateTouchIDNotAvailable, error);
                                });
                            }
                                break;
                                //case LAErrorTouchIDLockout:{
                            case LAErrorBiometryLockout:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
                                    block(CFAuthIDStateTouchIDLockout, error);
                                });
                            }
                                break;
                            case LAErrorAppCancel:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                                    block(CFAuthIDStateAppCancel, error);
                                });
                            }
                                break;
                            case LAErrorInvalidContext:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                                    block(CFAuthIDStateInvalidContext, error);
                                });
                            }
                                break;
                            default:
                                break;
                        }
                    } else {
                        // iOS 11.0以下的版本只有 TouchID 认证
                        switch (error.code) {
                            case LAErrorAuthenticationFailed:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 验证失败");
                                    block(CFAuthIDStateFail, error);
                                });
                                break;
                            }
                            case LAErrorUserCancel:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 被用户手动取消");
                                    block(CFAuthIDStateUserCancel, error);
                                });
                            }
                                break;
                            case LAErrorUserFallback:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"用户不使用TouchID,选择手动输入密码");
                                    block(CFAuthIDStateInputPassword, error);
                                });
                            }
                                break;
                            case LAErrorSystemCancel:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                                    block(CFAuthIDStateSystemCancel, error);
                                });
                            }
                                break;
                            case LAErrorPasscodeNotSet:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 无法启动,因为用户没有设置密码");
                                    block(CFAuthIDStatePasswordNotSet, error);
                                });
                            }
                                break;
                            case LAErrorBiometryNotEnrolled:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                                    block(CFAuthIDStateTouchIDNotSet, error);
                                });
                            }
                                break;
                                //case :{
                            case LAErrorBiometryNotAvailable:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 无效");
                                    block(CFAuthIDStateTouchIDNotAvailable, error);
                                });
                            }
                                break;
                            case LAErrorBiometryLockout:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
                                    block(CFAuthIDStateTouchIDLockout, error);
                                });
                            }
                                break;
                            case LAErrorAppCancel:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                                    block(CFAuthIDStateAppCancel, error);
                                });
                            }
                                break;
                            case LAErrorInvalidContext:{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                                    block(CFAuthIDStateInvalidContext, error);
                                });
                            }
                                break;
                            default:
                                break;
                        }
                    }
                    
                }
            }];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"当前设备不支持TouchID/FaceID");
                block(CFAuthIDStateNotSupport, error);
            });
        }
    } else {
        // Fallback on earlier versions
    }
}

/**
 * touchID验证
 */
+ (void)cf_showTouchIDWithDescribe:(NSString *)describe block:(CFAuthIDStateBlock)block {
    if(describe == nil) {
        describe = @"通过Home键验证手机指纹进行登录";
    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"输入密码";
    if (@available(iOS 9.0, *)) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
            [CFAuthID recognitionSucessState:success errorState:error block:block];
        }];
    } else {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
            [CFAuthID recognitionSucessState:success errorState:error block:block];
        }];
    }
}

/**
 * faceID验证
 */
+ (void)cf_showFaceIDWithDescribe:(NSString *)describe block:(CFAuthIDStateBlock)block {
    if(describe == nil) {
        describe = @"通过摄像头验证面容进行登录";
    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"输入密码";
    if (@available(iOS 9.0, *)) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
            [CFAuthID recognitionSucessState:success errorState:error block:block];
        }];
    } else {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
            [CFAuthID recognitionSucessState:success errorState:error block:block];
        }];
    }
}

/**
 * 判断识别后的状态
 * success ：成功状态
 * error ：失败状态
 */
+ (void)recognitionSucessState:(BOOL)successState errorState:(NSError * _Nullable)errorState block:(CFAuthIDStateBlock)block {
    if (successState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(CFAuthIDStateSuccess, errorState);
        });
    } else if (errorState) {
        switch (errorState.code) {
            case LAErrorAuthenticationFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateFail, errorState);
                });
            }
                break;
            case LAErrorUserCancel:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateUserCancel, errorState);
                });
            }
                break;
            case LAErrorUserFallback:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateInputPassword, errorState);
                });
            }
                break;
            case LAErrorSystemCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateSystemCancel, errorState);
                });
            }
                break;
            case LAErrorPasscodeNotSet:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStatePasswordNotSet, errorState);
                });
            }
                break;
            case LAErrorBiometryNotEnrolled:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateTouchIDNotSet, errorState);
                });
            }
                break;
            case LAErrorBiometryNotAvailable:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateTouchIDNotAvailable, errorState);
                });
            }
                break;
            case LAErrorBiometryLockout:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateTouchIDLockout, errorState);
                });
            }
                break;
            case LAErrorAppCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateAppCancel, errorState);
                });
            }
                break;
            case LAErrorInvalidContext:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(CFAuthIDStateInvalidContext, errorState);
                });
            }
                break;
            default:
                break;
        }
    }
}

@end
