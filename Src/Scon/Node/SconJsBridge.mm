
#include <node.h>
#include <node_api.h>
#include <v8.h>
#include <uv.h>
#import "../Src/Scon.h"
#import "./Bonjour/SCLSocketConnection.h"
#import "./Bonjour/SCRemoteDeviceInfo.h"
#import "./Bonjour/SCLocalSocketService.h"


namespace scon {

using namespace v8;
using v8::Function;
using v8::FunctionCallbackInfo;
using v8::Isolate;
using v8::Local;
using v8::Null;
using v8::Object;
using v8::String;
using v8::Value;

static Local<Function> * g_bonjourCallback = NULL;
static Local<Function> * g_jsMsgListenerCallback = NULL;

static uv_async_t bj_async;
static uv_async_t msg_async;

static void OnBonjourRemoteDeviceChanged(uv_async_t *handle);

static void OnMsgRecived(SconMsg * msg);


void StarBonjour(const FunctionCallbackInfo<Value>& args) 
 	g_bonjourCallback = Local<Function>::Cast(args[0]);
  g_jsMsgListenerCallback = Local<Function>::Cast(args[1]);

  uv_async_init(uv_default_loop(), &bj_async, OnBonjourRemoteDeviceChanged);

	[Scon sharedInstance].msgReciveInterceptor = ^(SconMsg *msg) {
		OnMsgRecived(msg);
		return YES;
  };

  [SCLocalSocketService sharedInstance];
	[[NSNotificationCenter defaultCenter] addObserverForName:KNotificationSConRemoteDeviceListChanged object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
		 uv_async_send(&bj_async);
  }];
}


static void OnBonjourRemoteDeviceChanged(uv_async_t *handle) {
}
/*
	if (g_bonjourCallback != NULL)
	{
    v8::HandleScope handle_scope(isolate);

    NSArray<SCRemoteDeviceInfo*> * devices = [[SCLocalSocketService sharedInstance] getRemoteDevInfoList];

    NSLog(@"device: %@", devices);

    Local<Array> node_devList = Nan::New<v8::Array>();

    for (NSUInteger i = 0; i < devices.count; ++i)
    {
      Nan::HandleScope scope;
      SCRemoteDeviceInfo * devInfo = devices[i];

      Local<v8::Object> node_devInfo = Nan::New<v8::Object>();

      node_devInfo->Set(Nan::New("deviceName").ToLocalChecked(), Nan::New(devInfo.deviceName.UTF8String).ToLocalChecked());
      node_devInfo->Set(Nan::New("deviceSystem").ToLocalChecked(), Nan::New(devInfo.deviceSystem.UTF8String).ToLocalChecked());
      node_devInfo->Set(Nan::New("deviceModel").ToLocalChecked(), Nan::New(devInfo.deviceModel.UTF8String).ToLocalChecked());
      node_devInfo->Set(Nan::New("deviceVersion").ToLocalChecked(), Nan::New(devInfo.deviceVersion.UTF8String).ToLocalChecked());
      node_devInfo->Set(Nan::New("appName").ToLocalChecked(), Nan::New(devInfo.appName.UTF8String).ToLocalChecked());

    node_devList->Set(i, node_devInfo);
    }

    Local<Value> argv[] = { node_devList };
    g_bonjourCallback->Call(1, argv);

	}	
}
*/

static void OnMsgRecived(SconMsg * msg) {
}
/*  
    if (msg == nil)
    {
        return;
    }
    
    NSMutableDictionary * retDic = [NSMutableDictionary dictionary];
    
    switch (msg.type) {
        case SconMsgTypeCmd:
        {
            SconCommondMsg * cmdMsg = (SconCommondMsg *)msg;
            [retDic setObject:@"cmd" forKey:@"type"];
            [retDic setObject:cmdMsg.content forKey:@"content"];
            break;
        }
        case SconMsgTypePlugin:
        {
            [retDic setObject:@"plugin" forKey:@"type"];

            SconPluginMsg * plgMsg = (SconPluginMsg *)msg;
            
            [retDic setObject:plgMsg.identifier forKey:@"identifier"];
            
            NSMutableDictionary * msgDic = [NSMutableDictionary dictionary];
            
            NSError * error = nil;
            NSDictionary * conentDic = [NSJSONSerialization JSONObjectWithData:plgMsg.content options:NSJSONReadingAllowFragments error:&error];
            if (conentDic) {
                [msgDic addEntriesFromDictionary:conentDic];
            } else {
                NSString * contentStr = [[NSString alloc] initWithData:plgMsg.content encoding:NSUTF8StringEncoding];
                if (contentStr.length > 0) {
                    [msgDic setObject:contentStr forKey:@"text"];
                }
            }
            [retDic setObject:msgDic forKey:@"content"];
            break;
        }
        default:
            break;
    }
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:retDic options:0 error:&err];
    if (err != nil)
    {
        return;
    }
    
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"\ndata:\n %@", jsonStr);
    
    unsigned int length = strlen(jsonStr.UTF8String);
    char * utfStr = (char *)malloc(length + 1);
    memset(utfStr, 0, length + 1);
    
    memcpy(utfStr, jsonStr.UTF8String, length);
    utfStr[length] = '\0';
    
    msg_async.data = utfStr;
    
    uv_async_send(&msg_async);
}

static void MsgForward(uv_async_t *handle) {
  if (handle->data == NULL)
  {
    NSLog(@"eeeeeeeeeeeeeeeee");
  }
	if (g_jsMsgListenerCallback != NULL && handle->data != NULL)
	{
		Nan::HandleScope scope;

		const char * data = (char *)handle->data;
		handle->data = NULL;

		Local<Value> argv[] = { Nan::New(data).ToLocalChecked()};
  		g_jsMsgListenerCallback->Call(1, argv);

      if (data != NULL)
      {
        delete data;
        data = NULL;
      }
  		
	}
}

NAN_METHOD(AddMsgListener) {

 	g_jsMsgListenerCallback = new Callback(info[0].As<Function>());

 	uv_async_init(uv_default_loop(), &msg_async, MsgForward);
}


NAN_METHOD(ConnectDevice) {

    v8::String::Utf8Value devName_v8Str(info[0]->ToString());
    std::string devName_stdStr  = std::string(*devName_v8Str);

    NSString * deviceName = [[NSString alloc] initWithUTF8String:devName_stdStr.c_str()];

    NSLog(@"devName : %@", deviceName);
    
    BOOL ret = NO;
    if (deviceName.length > 0)
    {
      [[SCLocalSocketService sharedInstance] setCurrentRemoteDevice:deviceName];
    }

    std::string retStr = "true";
    info.GetReturnValue().Set(Nan::New(retStr).ToLocalChecked());
}
*/

/*
 *	Scon Export
 */
void Init(v8::Local<v8::Object> exports) {

}

NODE_MODULE(hello, Init)

}