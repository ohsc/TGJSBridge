//
//  TGAppDelegate.m
//  TGJSBridge
//
//  Created by Chao Shen on 12-3-1.
//  Copyright (c) 2012年 Hangzhou Jiuyan Technology Co., Ltd. All rights reserved.
//

#import "TGAppDelegate.h"

@implementation TGAppDelegate

@synthesize window = _window;
@synthesize webView = _webView;
@synthesize jsBridge = _jsBridge;
@synthesize btn = _btn;

- (void)dealloc
{
    [_window release];
    [_webView release];
    [_jsBridge release];
    [_btn release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.webView];
    
	self.jsBridge = [TGJSBridge jsBridgeWithDelegate:self];
	self.webView.delegate = self.jsBridge;
	
	self.btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.btn setTitle:@"Hello JS" forState:UIControlStateNormal];
	[self.btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:self.btn aboveSubview:self.webView];
	self.btn.frame = CGRectMake(95, 400, 130, 45);
	
    [self.jsBridge postNotificationName:@"test" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"before load",@"message", nil] toWebView:self.webView];
	
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
	
    [self.jsBridge postNotificationName:@"test" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"after load",@"message", nil] toWebView:self.webView];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)buttonPressed:(id)sender {
    [self.jsBridge postNotificationName:@"test" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"click by uibutton",@"message", nil] toWebView:self.webView];
    
}

- (void)jsBridge:(TGJSBridge *)bridge didReceivedNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo fromWebView:(UIWebView *)webview
{
    [self.btn setTitle:[userInfo objectForKey:@"message"] forState:UIControlStateNormal];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
