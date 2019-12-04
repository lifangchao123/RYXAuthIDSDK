//
//  CFToolManager.h
//  CFAuthID
//
//  Created by 李方超 on 2019/11/28.
//  Copyright © 2019 dreamchaser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RYXAuthIDState) {
    
    /** 支持人脸 */
    RYXAuthIDStateSupportFaceID = 0,
    
    /** 支持指纹 */
    RYXAuthIDStateSupportTouchID,
    
    /** 不支持指纹和人脸 */
    RYXAuthIDStateNoSupport
};

typedef void(^callBack)(NSInteger clickIndex);

@interface CFToolManager : NSObject

/**
 * 获取KeyWindow
 */
+ (UIWindow *)getKeyWindow;

/**
 * 判断是否是iPhoneX以上版本
 */
+ (BOOL)getIsHighIphoneX;

/**
 * 判断是否是iOS 8.0及以上版本
 */
+ (BOOL)getIsHighiOS8;

/**
 * 判断是否是iOS 9.0及以上版本
 */
+ (BOOL)getIsHighiOS9;

/**
 * 判断是否支持人脸或者指纹
 * RYXAuthIDState  返回支持状态
 */
+ (RYXAuthIDState)ryx_isSupportAuthID;

/**
 * 获取顶部控制器
 */
+ (UIViewController *)topViewController;

/**
 * 获取根控制器
 */
+ (UIViewController *)rootController;

/**
 显示弹框
 
 @param title 标题
 @param msg 消息
 @param cancleTitle 取消按钮
 @param otherTitle 其他按钮
 @param clickIndex 选中回调
 */
+ (void)showAlert:(NSString *)title msg:(NSString *)msg cancleTitle:(NSString * __nullable)cancleTitle otherTitle:(NSString * __nullable)otherTitle finish:(callBack)clickIndex;

@end

NS_ASSUME_NONNULL_END
