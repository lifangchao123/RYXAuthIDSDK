//
//  RYXViewController.m
//  RYXAuthIDSDK
//
//  Created by lifangchao123 on 12/03/2019.
//  Copyright (c) 2019 lifangchao123. All rights reserved.
//

#import "RYXViewController.h"
#import "RYXAuthIDSDK/CommonHeaders.h"

@interface RYXViewController ()

@property (nonatomic, strong) UILabel *hintLabel;           // 提示标题
@property (nonatomic, strong) UIImageView *imageView;       // 图标
@property (nonatomic, strong) UIButton *actionBtn;          // 按钮

@property (nonatomic, copy) NSString *authImage;            // 认证图标名
@property (nonatomic, copy) NSString *authName;             // 认证名称

@end

@implementation RYXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initialize];
}

#pragma mark - 初始化方法
- (void)initialize {
    // 设置值
    if ([CFToolManager getIsHighIphoneX]) {
        self.authImage = @"auth_face";
        self.authName = @"面容";
    } else {
        self.authImage = @"auth_finger";
        self.authName = @"指纹";
    }
    
    // 添加组件
    [self.view addSubview:self.hintLabel];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.actionBtn];
    
    // 开始认证
    [self authVerification];
    
    if ([CFToolManager getIsHighIphoneX]) {
        NSLog(@"iPhone以上版本");
    } else {
        NSLog(@"iPhone以下版本");
    }
}

#pragma mark - 懒加载各组件
- (UILabel *)hintLabel {
    if(!_hintLabel){
        _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 60)];
        _hintLabel.font = [UIFont systemFontOfSize:22.f];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.numberOfLines = 0;
        _hintLabel.text = [NSString stringWithFormat:@"YZAuth\n验证%@以进行登录", self.authName];
        _hintLabel.textColor = [UIColor blackColor];
    }
    return _hintLabel;
}

- (UIImageView *)imageView {
    if(!_imageView){
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 35, self.hintLabel.frame.origin.y + 130, 70, 70)];
        _imageView.image = [UIImage imageNamed:self.authImage];
    }
    return _imageView;
}

- (UIButton *)actionBtn {
    if(!_actionBtn){
        _actionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _actionBtn.frame = CGRectMake(60, self.imageView.frame.origin.y + 190, self.view.frame.size.width - 120, 40);
        [_actionBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _actionBtn.titleLabel.font = [UIFont systemFontOfSize:18.f];
        [_actionBtn setTitle:[NSString stringWithFormat:@"点击验证%@", self.authName] forState:UIControlStateNormal];
        [_actionBtn setBackgroundColor:[UIColor colorWithRed:123/255.f green:188/255.f blue:231/255.f alpha:1]];
        _actionBtn.layer.cornerRadius = 5.f;
        _actionBtn.layer.masksToBounds = YES;
        [_actionBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionBtn;
}

#pragma mark - 按钮点击事件
- (void)btnClicked:(UIButton *)sender {
    // 唤起指纹、面容ID验证
    [self authVerification];
}

#pragma mark - 验证TouchID/FaceID
- (void)authVerification {
    
    [CFAuthID cf_showAuthIDWithDescribe:nil block:^(CFAuthIDState state, NSError *error) {
        
        if (state == CFAuthIDStateNotSupport) { // 不支持TouchID/FaceID
            NSLog(@"对不起，当前设备不支持指纹/面容ID");
        } else if(state == CFAuthIDStateFail) { // 认证失败
            NSLog(@"指纹/面容ID不正确，认证失败");
        } else if(state == CFAuthIDStateTouchIDLockout) {   // 多次错误，已被锁定
            NSLog(@"多次错误，指纹/面容ID已被锁定，请到手机解锁界面输入密码");
        } else if (state == CFAuthIDStateSuccess) { // TouchID/FaceID验证成功
            NSLog(@"认证成功！");
        }
        
    }];
}

@end
