THIS PROJECT IS NO LONGER UNDER ACTIVE DEVELOPMENT.

You may consider this project alternativelly, https://github.com/marcuswestin/WebViewJavascriptBridge


TGJSBridge
=============

TGJSBridge is a lightweight javascript bridge to cocoa. 
TGJSBridge is iOS4 and iPad compatible.
Usage in objective-c
----------------------
### Init jsBridge

    TGJSBridge *jsBridge = [TGJSBridge jsBridgeWithDelegate: webViewDelegate];
    webView.delegate = jsBridge;


### Send notification to javascript
`postNotificationName:userInfo:toWebView:`

### Listen notification from javascript

    - (void)jsBridge:(TGJSBridge *)bridge didReceivedNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo fromWebView:(UIWebView *)webview

Usage in webview
----------------------
### Send notification to cocoa

    jsBridge.postNotification(msgName,userInfo);

### Listen notification from cocoa

    jsBridge.bind(msgName, function(userInfo){
        ...
    });

### Cancel listening notification from cocoa

    jsBridge.unbind('test',callbackHandler);

LICENSE
----------------------
Copyright (c) 2012 Chao Shen(Hangzhou Jiuyan Technology Co., Ltd.). This software is licensed under the BSD License.



