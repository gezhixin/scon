{
  "targets": [
    {
      "target_name": "bonjour",
      "sources": [
      		"./Bonjour.mm",
			"./BonjourJSBridge.mm",
			"common.h"
      ],
      'include_dirs': [
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
