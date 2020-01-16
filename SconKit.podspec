Pod::Spec.new do |s|
  s.name                    = "SconKit"
  s.version                 = "1.0.0"
  s.summary                 = "SconKit source code"
  s.ios.deployment_target   = '8.0'
  s.osx.deployment_target   = '10.10'
  s.license                 = 'MIT'
  s.author                  = 'Aaronge'
  s.homepage                = "https://github.com/gezhixin/Scon"
  s.source                  = { :git => "https://github.com/gezhixin/Scon.git" }
  s.requires_arc            = true
  s.source_files            = "Src/SconKit/Src/*.{h,m}"
  s.public_header_files     = "Src/SconKit/Src/*.h"

  s.dependency   "CocoaLumberjack"
  s.dependency   "CocoaAsyncSocket"
  s.dependency   "SocketRocket"
  

  s.subspec 'Bonjour' do |ss|
    ss.source_files         = 'Src/SconKit/Src/Bonjour/*.{h,m}'
    ss.public_header_files  = 'Src/SconKit/Src/Bonjour/*.h'
    ss.resources            = 'Src/SconKit/Src/Bonjour/bonjour.bundle'
  end

  s.subspec 'Plugin' do |ss|
    ss.source_files         = 'Src/SconKit/Src/Plugin/Log/*.{h,m}'
    ss.public_header_files  = 'Src/SconKit/Src/Plugin/Log/*.h'
  end

end
