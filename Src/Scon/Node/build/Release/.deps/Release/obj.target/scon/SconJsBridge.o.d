cmd_Release/obj.target/scon/SconJsBridge.o := c++ '-DNODE_GYP_MODULE_NAME=scon' '-DUSING_UV_SHARED=1' '-DUSING_V8_SHARED=1' '-DV8_DEPRECATION_WARNINGS=1' '-D_DARWIN_USE_64_BIT_INODE=1' '-D_LARGEFILE_SOURCE' '-D_FILE_OFFSET_BITS=64' '-D__MACOSX_CORE__' '-DBUILDING_NODE_EXTENSION' -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/src -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/deps/openssl/config -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/deps/openssl/openssl/include -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/deps/uv/include -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/deps/zlib -I/Users/aaronge/Library/Caches/node-gyp/10.12.0/deps/v8/include -I../../Src -I../Bonjour -I../Bonjour/CocoaAsyncSocket/source/GCD  -Os -gdwarf-2 -fvisibility=hidden -mmacosx-version-min=10.10 -arch x86_64 -Wall -Wendif-labels -W -Wno-unused-parameter -std=gnu++1y -stdlib=libc++ -fno-rtti -fno-strict-aliasing -fobjc-arc -ObjC++ -std=c++11  -MMD -MF ./Release/.deps/Release/obj.target/scon/SconJsBridge.o.d.raw -c -o Release/obj.target/scon/SconJsBridge.o ../SconJsBridge.mm
Release/obj.target/scon/SconJsBridge.o: ../SconJsBridge.mm \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8-version.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8config.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8-platform.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node_version.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/errno.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/version.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/unix.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/threadpool.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/darwin.h \
  .././node_modules/nan/nan.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node_buffer.h \
  /Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node_object_wrap.h \
  .././node_modules/nan/nan_callbacks.h \
  .././node_modules/nan/nan_callbacks_12_inl.h \
  .././node_modules/nan/nan_maybe_43_inl.h \
  .././node_modules/nan/nan_converters.h \
  .././node_modules/nan/nan_converters_43_inl.h \
  .././node_modules/nan/nan_new.h \
  .././node_modules/nan/nan_implementation_12_inl.h \
  .././node_modules/nan/nan_persistent_12_inl.h \
  .././node_modules/nan/nan_weak.h \
  .././node_modules/nan/nan_object_wrap.h \
  .././node_modules/nan/nan_private.h \
  .././node_modules/nan/nan_typedarray_contents.h \
  .././node_modules/nan/nan_json.h ../../Src/Scon.h \
  ../../Src/SconConnection.h ../../Src/SconMsgHandler.h \
  ../../Src/SconMsg.h ../../Src/SconPluginProtocol.h \
  .././Bonjour/SCLSocketConnection.h \
  ../Bonjour/CocoaAsyncSocket/source/GCD/GCDAsyncSocket.h \
  ../Bonjour/SCRemoteDeviceInfo.h .././Bonjour/SCRemoteDeviceInfo.h \
  .././Bonjour/SCLocalSocketService.h
../SconJsBridge.mm:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8-version.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8config.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/v8-platform.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node_version.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/errno.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/version.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/unix.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/threadpool.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/uv/darwin.h:
.././node_modules/nan/nan.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node_buffer.h:
/Users/aaronge/Library/Caches/node-gyp/10.12.0/include/node/node_object_wrap.h:
.././node_modules/nan/nan_callbacks.h:
.././node_modules/nan/nan_callbacks_12_inl.h:
.././node_modules/nan/nan_maybe_43_inl.h:
.././node_modules/nan/nan_converters.h:
.././node_modules/nan/nan_converters_43_inl.h:
.././node_modules/nan/nan_new.h:
.././node_modules/nan/nan_implementation_12_inl.h:
.././node_modules/nan/nan_persistent_12_inl.h:
.././node_modules/nan/nan_weak.h:
.././node_modules/nan/nan_object_wrap.h:
.././node_modules/nan/nan_private.h:
.././node_modules/nan/nan_typedarray_contents.h:
.././node_modules/nan/nan_json.h:
../../Src/Scon.h:
../../Src/SconConnection.h:
../../Src/SconMsgHandler.h:
../../Src/SconMsg.h:
../../Src/SconPluginProtocol.h:
.././Bonjour/SCLSocketConnection.h:
../Bonjour/CocoaAsyncSocket/source/GCD/GCDAsyncSocket.h:
../Bonjour/SCRemoteDeviceInfo.h:
.././Bonjour/SCRemoteDeviceInfo.h:
.././Bonjour/SCLocalSocketService.h:
