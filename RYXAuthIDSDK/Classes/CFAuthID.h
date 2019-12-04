//
//  CFAuthID.h
//  CFAuthID
//
//  Created by 李方超 on 2019/11/27.
//  Copyright © 2019 dreamchaser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  TouchID/FaceID 状态
 */
typedef NS_ENUM(NSUInteger, CFAuthIDState){
    
    /**
     *  当前设备不支持TouchID/FaceID
     */
    CFAuthIDStateNotSupport = 0,
    /**
     *  TouchID/FaceID 验证成功
     */
    CFAuthIDStateSuccess = 1,
    
    /**
     *  TouchID/FaceID 验证失败
     */
    CFAuthIDStateFail = 2,
    /**
     *  TouchID/FaceID 被用户手动取消
     */
    CFAuthIDStateUserCancel = 3,
    /**
     *  用户不使用TouchID/FaceID,选择手动输入密码
     */
    CFAuthIDStateInputPassword = 4,
    /**
     *  TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    CFAuthIDStateSystemCancel = 5,
    /**
     *  TouchID/FaceID 无法启动,因为用户没有设置密码
     */
    CFAuthIDStatePasswordNotSet = 6,
    /**
     *  TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID
     */
    CFAuthIDStateTouchIDNotSet = 7,
    /**
     *  TouchID/FaceID 无效
     */
    CFAuthIDStateTouchIDNotAvailable = 8,
    /**
     *  TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)
     */
    CFAuthIDStateTouchIDLockout = 9,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    CFAuthIDStateAppCancel = 10,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    CFAuthIDStateInvalidContext = 11,
    /**
     *  系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)
     */
    CFAuthIDStateVersionNotSupport = 12
};


@interface CFAuthID : LAContext

typedef void (^CFAuthIDStateBlock)(CFAuthIDState state, NSError * __nullable error);

/**
 * 启动TouchID/FaceID进行验证
 * @param describe TouchID/FaceID显示的描述
 * @param block 回调状态的block
 */
+ (void)cf_showAuthIDWithDescribe:(NSString * __nullable)describe block:(CFAuthIDStateBlock)block;

/**
 * 启动TouchID验证
 * @param describe TouchID显示的描述
 * @param block 回调状态的block
 */
+ (void)cf_showTouchIDWithDescribe:(NSString * __nullable)describe block:(CFAuthIDStateBlock)block;

/**
 * 启动FaceID验证
 * @param describe FaceID显示的描述
 * @param block 回调状态的block
 */
+ (void)cf_showFaceIDWithDescribe:(NSString * __nullable)describe block:(CFAuthIDStateBlock)block;

@end

NS_ASSUME_NONNULL_END
