//
//  TGJSBridge.js
//  TGJSBridge
//
//  Created by Chao Shen on 12-3-1.
//  Copyright (c) 2012年 Hangzhou Jiuyan Technology Co., Ltd. All rights reserved.
//

(function(context){
    function bridgeCall(src,callback) {
		iframe = document.createElement("iframe");
		iframe.style.display = "none";
		iframe.src = src;
		var cleanFn = function(state){
		   console.log(state) 
		    try {
		        iframe.parentNode.removeChild(iframe);
		    } catch (error) {}
		    if(callback) callback();
		};
        iframe.onload = cleanFn;
		document.documentElement.appendChild(iframe);
	}
	
    function JSBridge()
    {
        this.callbackDict = {};
        this.notificationIdCount = 0;
        this.notificationDict = {};
        
        var that = this;
        context.document.addEventListener('DOMContentLoaded',function(){
            bridgeCall('jsbridge://NotificationReady',that.trigger('jsBridgeReady',{}));
        },false);
    }

    JSBridge.prototype = {
        constructor: JSBridge,
        //send notification to WebView
        postNotification: function(name, userInfo){
            this.notificationIdCount++;
            
            this.notificationDict[this.notificationIdCount] = {name:name, userInfo:userInfo};

            bridgeCall('jsbridge://PostNotificationWithId-' + this.notificationIdCount);
        },
        //pop the notification in the cache
        popNotificationObject: function(notificationId){
            var result = JSON.stringify(this.notificationDict[notificationId]);
            delete this.notificationDict[notificationId];
            return result;
        },
        //trigger the js event
        trigger: function(name, userInfo) {
            if(this.callbackDict[name]){
                var callList = this.callbackDict[name];
                
                for(var i=0,len=callList.length;i<len;i++){
                    callList[i](userInfo);
                }
            }
        },
        //bind js event
        bind: function(name, callback){
            if(!this.callbackDict[name]){
                //create the array
                this.callbackDict[name] = [];
            }
            this.callbackDict[name].push(callback);
        },
        //unbind js event
        unbind: function(name, callback){
            if(arguments.length == 1){
                delete this.callbackDict[name];
            } else if(arguments.length > 1) {
                if(this.callbackDict[name]){
                    var callList = this.callbackDict[name];
                    
                    for(var i=0,len=callList.length;i<len;i++){
                        if(callList[i] == callback){
                            callList.splice(i,1);
                            break;
                        }
                    }
                }
                if(this.callbackDict[name].length == 0){
                    delete this.callbackDict[name];
                }
            }
            
        }
        
    };
     
    context.jsBridge = new JSBridge();
    
})(window);
