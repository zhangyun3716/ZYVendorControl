

//  AppDelegate.m
//  FlexCar
//  Created by flexium on 2016/9/19.
//  Copyright © 2016年 flexium. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackBlock)(NSString *str);

@interface ZYScannerView : UIView

@property (nonatomic, copy) BackBlock back;

+ (ZYScannerView *)sharedScannerView;

- (void)showOnView:(UIView *)view block:(BackBlock)block;

- (void)dismiss;

@end
