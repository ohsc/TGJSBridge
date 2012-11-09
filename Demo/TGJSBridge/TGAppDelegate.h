//
//  TGAppDelegate.h
//  TGJSBridge
//
//  Created by Chao Shen on 12-3-1.
//  Copyright (c) 2012年 Hangzhou Jiuyan Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGJSBridge.h"

@class TGViewController;

@interface TGAppDelegate : UIResponder <UIApplicationDelegate, TGJSBridgeDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) UIWebView *webView;
@property (retain, nonatomic) UIButton *btn;
@property (retain, nonatomic) TGJSBridge *jsBridge;

@end
