//
//  TGJSBridge.h
//  TGJSBridge
//
//  Created by Chao Shen on 12-3-1.
//  Copyright (c) 2012年 Hangzhou Jiuyan Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TGJSBridge;

@protocol TGJSBridgeDelegate <UIWebViewDelegate>

- (void)jsBridge:(TGJSBridge *)bridge 
didReceivedNotificationName:(NSString*)name    
        userInfo:(NSDictionary*)userInfo 
     fromWebView:(UIWebView*)webview;

@end


@interface TGJSBridge : NSObject <UIWebViewDelegate>
{
    NSMutableDictionary *_infoList;
}

@property (nonatomic, assign) IBOutlet id <TGJSBridgeDelegate> delegate;

+ (id)jsBridgeWithDelegate:(id <TGJSBridgeDelegate>)delegate;

- (void)postNotificationName:(NSString *)name
                    userInfo:(NSDictionary*)userInfo
                   toWebView:(UIWebView *)webView;

@end
