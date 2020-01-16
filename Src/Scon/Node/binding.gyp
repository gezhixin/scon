{
  "targets": [
    {
      "target_name": "scon",
      "sources": [
      		"../Src/Scon.m", 
      		"../Src/SconConnection.m", 
      		"../Src/SconMsg.m", 
      		"../Src/SconMsgHandler.m", 
      		"./SconJsBridge.mm",
      		'./Bonjour/SCLocalSocketService.m',
      		'./Bonjour/SCLSocketConnection.m',
      		'./Bonjour/SCRemoteDeviceInfo.m',
      		'./Bonjour/CocoaAsyncSocket/source/GCD/GCDAsyncSocket.m'
      ],
      "include_dirs" : [
         "<!(node -e \"require('nan')\")"
      ],
      'include_dirs': [
    	'../Src/',
    	'./Bonjour/',
    	'./Bonjour/CocoaAsyncSocket/source/GCD/',
  	  ],
    
	  "conditions": [
	  	['OS=="mac"', {
	  		'defines': [
                '__MACOSX_CORE__'
            ],
	      	'xcode_settings': {
	        	#'i386', 'x86_64'
	        	'ARCHS': [ 'x86_64' ],
	        	'MACOSX_DEPLOYMENT_TARGET': '10.10',
	        	'CLANG_CXX_LIBRARY': 'libc++',
	        	'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
	        	'GCC_SYMBOLS_PRIVATE_EXTERN': 'YES',
	        	'OTHER_CFLAGS': [
					'-fobjc-arc',
	          		'-ObjC++',
                    '-std=c++11'
	        	],
	      	}, # xcode_settings
	      	'link_settings': {
	        	'libraries': [
	          		'$(SDKROOT)/System/Library/Frameworks/Foundation.framework',
	        	],
	      	},
    	}], # Mac
	  ],
    }
  ]
}
