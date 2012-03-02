//
//  TGJSBridge.m
//  TGJSBridge
//
//  Created by Chao Shen on 12-3-1.
//  Copyright (c) 2012年 Hangzhou Jiuyan Technology Co., Ltd. All rights reserved.
//

#import "TGJSBridge.h"
#import "SBJson.h"

#define kTGJSBridgeProtocolScheme @"jsbridge"
#define kTGJSBridgeNotificationSeparator @"-"
#define kTGJSBridgeNotificationReady @"NotificationReady"
#define kTGJSBridgePostNotificationWithId @"PostNotificationWithId"

@interface TGJSBridge ()
- (BOOL)isReadyForWebView:(UIWebView*)webView;
- (void)dispatchNotification:(NSString*)notificationString 
                 fromWebView:(UIWebView*)webView;
- (NSDictionary*)fetchNotificationWithId:(NSString*)notificationId 
                             fromWebView:(UIWebView*)webView;
- (NSMutableArray*)notificationQueueForWebView:(UIWebView*)webView;
- (void)triggerJSEvent:(NSString *)name
              userInfo:(NSDictionary*)userInfo
             toWebView:(UIWebView *)webView;
@end

@implementation TGJSBridge

@synthesize delegate = _delegate;

+ (id)jsBridgeWithDelegate:(id <TGJSBridgeDelegate>)delegate
{
    TGJSBridge* bridge = [[[TGJSBridge alloc] init] autorelease];
    bridge.delegate = delegate;
    return bridge;
}

- (id)init
{
    if(self = [super init])
    {
        _infoList = [[NSMutableDictionary alloc]init];
    }
    return self;
}


- (void)dealloc
{
    _delegate = nil;
    [_infoList release];
    [super dealloc];
}

- (NSMutableArray*)notificationQueueForWebView:(UIWebView*)webView
{
    NSMutableArray *notificationQueue = [_infoList objectForKey:[NSNumber numberWithUnsignedInt:[webView hash]]];
    if(!notificationQueue)
    {
        notificationQueue = [[[NSMutableArray alloc]init]autorelease];
        [_infoList setObject:notificationQueue forKey:[NSNumber numberWithUnsignedInt:[webView hash]]];
    }
    return notificationQueue;
}

- (BOOL)isReadyForWebView:(UIWebView*)webView
{
    return [[webView stringByEvaluatingJavaScriptFromString:@"window['jsBridge']?'true':'false'"] isEqualToString:@"true"];
}

- (void)postNotificationName:(NSString *)name
                    userInfo:(NSDictionary*)userInfo
                   toWebView:(UIWebView *)webView
{
    
    if([self isReadyForWebView:webView])
    {
        //push notification
        [self triggerJSEvent:name userInfo:userInfo toWebView:webView];
    }
    else
    {
        //add notification to notificationQueue
        NSMutableArray *notificationQueue = [self notificationQueueForWebView:webView];
        [notificationQueue addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",userInfo,@"userInfo", nil]];
    }
}

- (void)triggerJSEvent:(NSString *)name
              userInfo:(NSDictionary*)userInfo
             toWebView:(UIWebView *)webView
{
    if(userInfo)
    {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"jsBridge.trigger('%@',%@)",name,[userInfo JSONRepresentation]]];
    }
    else 
    {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"jsBridge.trigger('%@')",name]];
    }
}

- (void)dispatchNotification:(NSString*)notificationString 
                 fromWebView:(UIWebView*)webView
{
    if ([notificationString isEqualToString:kTGJSBridgeNotificationReady])
    {
        //push notificationQueue to webView
        NSMutableArray *notificationQueue = [self notificationQueueForWebView:webView];
        for(NSDictionary *notification in notificationQueue)
        {
            [self triggerJSEvent:[notification objectForKey:@"name"] userInfo:[notification objectForKey:@"userInfo"] toWebView:webView];
        }
        
    }
    else if([notificationString hasPrefix:kTGJSBridgePostNotificationWithId])
    {
        NSRange range = [notificationString rangeOfString:kTGJSBridgeNotificationSeparator];
		int index = range.location + range.length;
		NSString *notificationId = [notificationString substringFromIndex:index];
        //processNotification
        NSDictionary *responseDict = [self fetchNotificationWithId:notificationId fromWebView:webView];
        if(self.delegate) [self.delegate jsBridge:self 
                      didReceivedNotificationName:[responseDict objectForKey:@"name"] 
                                         userInfo:[responseDict objectForKey:@"userInfo"] 
                                      fromWebView:webView];
    }
    else
    {
        //processError
        NSLog(@"TGJSBridge: WARNING: Received unknown TGJSBridge command %@://%@", kTGJSBridgeProtocolScheme, notificationString);
    }
    
}

- (NSDictionary*)fetchNotificationWithId:(NSString*)notificationId 
                             fromWebView:(UIWebView*)webView

{
    NSString *responseString = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"jsBridge.popNotificationObject(%@)", notificationId]];
    NSDictionary *responseDict = [responseString JSONValue];
    return responseDict;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //forward
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {    
    //forward
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    
    if ([[[url scheme] lowercaseString] isEqualToString:kTGJSBridgeProtocolScheme])
    {
        [self dispatchNotification:[url host] fromWebView:webView];
        return NO;
    }
    else
    {
        //forward
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
        return YES;
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //forward
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}
@end
