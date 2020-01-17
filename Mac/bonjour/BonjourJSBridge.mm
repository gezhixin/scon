//
//  Bonjour.m
//  Sample
//
//  Created by aaronge on 2020/1/16.
//  Copyright © 2020 gezhixin. All rights reserved.
//

#include <node_api.h>
#import "Bonjour.h"
#include "common.h"

namespace bonjour {

    static Bonjour *g_bonjour = nil;

    typedef struct  {
        char name[256];
        char domain[256];
        char type[256];
        int32_t port;
    } BonjourInfo;

    napi_value Publish (napi_env env, napi_callback_info info) {
        size_t argc = 1;
        napi_value args[1];
        NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, NULL, NULL));
        NAPI_ASSERT(env, argc == 1, "Not enough arguments, expected 1.");
        
        BonjourInfo bonjour_info;

        size_t psize = 0;
        napi_value value_0;
        napi_value name_0;
        NAPI_CALL(env, napi_create_string_utf8(env, "name", NAPI_AUTO_LENGTH, &name_0));
        NAPI_CALL(env, napi_get_property(env, args[0], name_0, &value_0));
        NAPI_CALL(env,napi_get_value_string_utf8(env, value_0, bonjour_info.name, 256, &psize));

        napi_value value_1;
        napi_value name_1;
        NAPI_CALL(env, napi_create_string_utf8(env, "domain", NAPI_AUTO_LENGTH, &name_1));
        NAPI_CALL(env, napi_get_property(env, args[0], name_1, &value_1));
        NAPI_CALL(env,napi_get_value_string_utf8(env, value_1, bonjour_info.domain, 256, &psize));

        napi_value value_2;
        napi_value name_2;
        NAPI_CALL(env, napi_create_string_utf8(env, "type", NAPI_AUTO_LENGTH, &name_2));
        NAPI_CALL(env, napi_get_property(env, args[0], name_2, &value_2));
        NAPI_CALL(env,napi_get_value_string_utf8(env, value_2, bonjour_info.type, 256, &psize));

        napi_value value_3;
        napi_value name_3;
        NAPI_CALL(env, napi_create_string_utf8(env, "port", NAPI_AUTO_LENGTH, &name_3));
        NAPI_CALL(env, napi_get_property(env, args[0], name_3, &value_3));
        NAPI_CALL(env, napi_get_value_int32(env, value_3, &bonjour_info.port));
        
        NSString *name = [NSString stringWithUTF8String:bonjour_info.name];
        NSString *domain = [NSString stringWithUTF8String:bonjour_info.domain];
        NSString *type = [NSString stringWithUTF8String:bonjour_info.type];

        if (!g_bonjour) {
            g_bonjour = [[Bonjour alloc] init];
        }

        [g_bonjour publishWithName:name domain:domain type:type port:bonjour_info.port];

        return nullptr;
    }

    napi_value Stop (napi_env env, napi_callback_info info) {
        if (g_bonjour) {
            [g_bonjour stop];
        }
        return nullptr;
    }

    napi_value Brower (napi_env env, napi_callback_info info) {
        size_t argc = 2;
        napi_value args[2];
        NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, NULL, NULL));
        NAPI_ASSERT(env, argc == 2, "Not enough arguments, expected 3.");

        size_t psize = 0;
        char domain[256];
        char type[256];
        napi_value value_1;
        napi_value name_1;
        NAPI_CALL(env, napi_create_string_utf8(env, "domain", NAPI_AUTO_LENGTH, &name_1));
        NAPI_CALL(env, napi_get_property(env, args[0], name_1, &value_1));
        NAPI_CALL(env,napi_get_value_string_utf8(env, value_1, domain, 256, &psize));

        napi_value value_2;
        napi_value name_2;
        NAPI_CALL(env, napi_create_string_utf8(env, "type", NAPI_AUTO_LENGTH, &name_2));
        NAPI_CALL(env, napi_get_property(env, args[0], name_2, &value_2));
        NAPI_CALL(env,napi_get_value_string_utf8(env, value_2, type, 256, &psize));
        
        napi_value func = args[1];
        napi_valuetype func_type;
        NAPI_CALL(env, napi_typeof(env, func, &func_type));
        NAPI_ASSERT(env, func_type == napi_function, "args[1] not function");
        
        
        
        NSString *domainStr = [NSString stringWithUTF8String:domain];
        NSString *typeStr = [NSString stringWithUTF8String:type];
        
        if (g_bonjour) {
            g_bonjour = [[Bonjour alloc] init];
        }
        
        [g_bonjour browerWithType:typeStr inDomain:domainStr listChanged:^(NSArray<ServerInfo *> * _Nonnull servcies) {
            
        }];

        return nullptr;
    }

    napi_value init(napi_env env, napi_value exports) {
        napi_status status;
        napi_value fn;

        status = napi_create_function(env, nullptr, 0, Publish, nullptr, &fn);
        if (status != napi_ok) return nullptr;

        status = napi_set_named_property(env, exports, "publish", fn);
        if (status != napi_ok) return nullptr;

        napi_value stop;
        status = napi_create_function(env, nullptr, 0, Stop, nullptr, &stop);
        if (status != napi_ok) return nullptr;

        status = napi_set_named_property(env, exports, "stop", stop);
        if (status != napi_ok) return nullptr;

        return exports;
    }

    NAPI_MODULE(NODE_GYP_MODULE_NAME, init)
}
