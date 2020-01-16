## Scon
这是一个Mac和iPhone基于局域网通讯的开发调试工具。主要设计想法来自于Facebook的Flipper。原本是要使用Flipper的，然而经过一些列的调研，Flipper目前对iPhone真机是不支持的。比如： 1、Flipper Mac客户端发现iPhone和日志功能都是用【xcrun】的命令做的，这些命令支持本机的模拟器。2、iOS通讯地址是写死的localhost，并没没有支持Client和Service交换ip来实现任何两个设备之间的链接。以及，flipper会引入Folly、RSocket等较为复杂的C++库，对于维护和扩展的开发人员要求较高。综上，最后选择了一个基于苹果特有Bonjour服务和简单的socket通讯的简易方案，实现真机的支持。**最后，flipper在iOS和Mac端的插件开发能力确实很强，也有专门的人员维护，后期上面说的问题应该都会得到解决，应持续关注。**

--

### 目录说明
```
DeviceLogView
|_iOS
| |_devSample
|
|_Mac
|   |_EScon. //基于electron的Mac客户端，未完成
|   |_flipper-master  //基于facebook flipper的Mac客户端，添加了bonjour协议和自定义的通讯插件，使用了flipper的UI
|   |_Scon  //swift 编写Mac客户端，未完成，用来 DBUG Bonjour 协议和通许插件
|
|_Src
|   |_Scon
|   |   |_Node  //Bonjour协议和通讯的JS插件，Nodejs 原生模块
|   |   |   |_Bonjour //Service端Bonjour协议和通许插件
|   |   |   |_binding.gyp //编译配置
|   |   |   |_build.sh  //编译脚本
|   |   |   |_SconJsBridge.mm //JS插件接口实现文件
|   |   |_Src  //通讯和插件协议
|   |   
|   |_SconKit
|       |_Src
|           |_Bonjour //Client端Bonjour协议和通许插件实现
|           |_Plugin  //插件 
|
|_Scon.podspec
|_SconKit.podspec
|
```

--

### flipper客户端编译和调试
**[Flipper](https://github.com/facebook/flipper)** 是基于 **[Electron](https://electronjs.org/)** 技术的客户端软件，需要Nodejs环境，使用 **[yarn](https://yarnpkg.com/zh-Hans/)** 作为包管理工具，编译首先要准备环境.  

```
brew install yarn
```

该命令会将 **Nodejs** 一同安装，然后
###### Run frome source
```
cd Mac/fillper-master/
yarn
yarn start
```
###### Building standalone application

```
yarn build --mac --version $buildNumber
```


--
### Scon Nodejs 插件编译
插件是基于 ```Nodejs C++ Addons``` 技术，可以参考 **[C++ Addons | Nodejs](https://nodejs.org/api/addons.html)** ,编译依赖 **[node-gyp]()**

```sh
npm install -g node-gyp
```
```build.sh``` 脚本将编译命令已经写好了，并且会将编译好的module拷贝到flipper对应的目录下

```
cd Src/Scon/Node
sh build.sh
```
在 ```SconJsBridge``` 中添加和修改接口，执行以上脚本，再到flipper目录，重新编译flipper即可生效

--
### 在flipper中做了什么？
* 引入了上面编译好的Bonjour和同学协议的插件 ```Scon```

* 在 ```flipper-master/src/static/index.js``` 中启动了 ```bonjour``` 服务和通讯服务，以及消息监听和转发，搜索 ```Bonjour``` 可以找的相关代码。

* 在```flipper-master/src/dispatcher/iOSDevice.js``` 中将设备发现的代码替换为 ```Scon``` 的服务，见代码：

	```js
	ipcRenderer.on('bonjour-dev-msg', (event, arg:  Array<Object>) => {
		……
	}
	```
	
	
* 在```/Mac/flipper-master/src/devices/IOSDevice.js``` 中将日志消息替换为 ```Scon``` 的服务，见代码
	
	```js
	ipcRenderer.on('plugin-msg-log', (event, arg) => {
	      //{"time":1534929036,"file":"ViewController","flag":"error","msg":"time : 662","fun":"-[ViewController viewDidLoad]_block_invoke","line":29,"identifier":"SCLogPlugin"}
	      var date = new Date(arg.time * 1000);
	      var tag = arg.tag;
	      var type = arg.flag;
	      var msg = '[' + arg.file + ":" + arg.line + '][' + arg.time + '] ' + arg.msg;
	      const logInfo = {
	        date: date,
	        pid: 0,
	        tid: 0,
	        tag: tag,
	        message: msg,
	        type: type,
	      };
	      callback(logInfo);
    });
	```

--

### 后续
……
# scon
