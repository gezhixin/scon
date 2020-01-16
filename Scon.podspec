Pod::Spec.new do |s|
  s.name                    = "Scon"
  s.version                 = "1.0.0"
  s.summary                 = "Scon source code"
  s.ios.deployment_target   = '8.0'
  s.osx.deployment_target   = '10.10'
  s.license                 = 'MIT'
  s.author                  = 'Aaronge'
  s.homepage                = "http://git.code.oa.com/kuaibao/DeviceLogViewer"
  s.source                  = { :git => "http://git.code.oa.com/kuaibao/DeviceLogViewer.git"}
  s.requires_arc            = true
  s.source_files            = "Src/Scon/Src/*.{h,m}"
  s.public_header_files     = "Src/Scon/Src/*.h"
end

