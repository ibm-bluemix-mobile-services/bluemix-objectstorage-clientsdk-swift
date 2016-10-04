Pod::Spec.new do |s|

  s.name         = 'BluemixObjectStorage'
  s.version      = '1.0.0'
  s.summary      = 'Bluemix Object Storage SDK'
  s.homepage     = 'https://github.com/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift'
  s.license      = 'Apache License, Version 2.0'
  s.authors      = { 'IBM Bluemix Services Mobile SDK' => 'mobilsdk@us.ibm.com' }
  s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift.git', :tag => s.version }

  s.source_files = 'BluemixObjectStorage/**/*'
  s.exclude_files = 'BluemixObjectStorage/**/*.plist'

  s.dependency 'BMSCore', '~> 2.0'

  s.ios.deployment_target = '8.0'

  s.requires_arc = true

end
