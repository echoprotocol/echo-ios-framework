Pod::Spec.new do |spec|
  spec.name = "ECHO"
  spec.version = "1.0.0"
  spec.summary = "ECHO Framework"
  spec.homepage = "https://github.com"
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors = {
    "Fedorenko Nikita" => '',
  }
  spec.source = { :path => '.' }
  spec.source_files  ="ECHO/**/*.{h,swift,m}"
  spec.requires_arc = true
  spec.platform     = :ios
  spec.ios.deployment_target = "9.0"
  spec.preserve_path = 'ECHO/Supports Files/ECHO.modulemap'
  spec.module_map = 'ECHO/Supports Files/ECHO.modulemap'
  spec.pod_target_xcconfig = {'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Libraries', 
  'LIBRARY_SEARCH_PATHS' => '$(SRCROOT)/Libraries/openssl/lib $(SRCROOT)/Libraries/secp256k1/lib',
  'HEADER_SEARCH_PATHS' => '$(SRCROOT)/Libraries/secp256k1/include $(SRCROOT)/Libraries/openssl/include'}

  # spec.xcconfig =  {'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Libraries'}
  spec.dependency "Starscream", '~> 3.0.2'

end
