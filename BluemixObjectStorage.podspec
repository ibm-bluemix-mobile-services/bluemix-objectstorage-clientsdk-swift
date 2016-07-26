Pod::Spec.new do |s|

  s.name         = 'BluemixObjectStorage'
  s.version      = '0.0.4'
  s.summary      = 'Bluemix Object Storage SDK'
  s.homepage     = 'https://github.com/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift'
  s.license      = 'Apache License, Version 2.0'
  s.authors      = { 'IBM Bluemix Services Mobile SDK' => 'mobilsdk@us.ibm.com' }
  s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift.git', :tag => s.version }

  s.source_files = 'BluemixObjectStorage/**/*'

  s.exclude_files = 'BluemixObjectStorage/**/*.plist'
  #s.ios.exclude_files = 'Source/**/*watchOS*.swift'
  #s.watchos.exclude_files = 'Source/**/*iOS*.swift'

  s.ios.deployment_target = '8.0'
  #s.watchos.deployment_target = '2.0'

  #s.module_map = 'Source/Resources/module.modulemap'

  s.dependency 'BMSCore', '~> 1.0.3'

  s.requires_arc = true

end
