Pod::Spec.new do |spec|
  spec.name = "ECHO"
  spec.version = "3.2.1"
  spec.summary = "Echo iOS Framework"
  spec.homepage = "https://gitlab.pixelplex.by/646_echo_mobile_library/ios"
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors = {
    "Fedorenko Nikita" => '',
    "Sharaev Vladimir" => '',
  }
  spec.source = { :git => 'https://gitlab.pixelplex.by/646_echo_mobile_library/ios.git' }
  spec.requires_arc = true
  spec.platform     = :ios
  spec.ios.deployment_target = "9.0"
  spec.preserve_path = 'ECHO/Supports Files/ECHO.modulemap'
  spec.module_map = 'ECHO/Supports Files/ECHO.modulemap'
  spec.pod_target_xcconfig = {  
	'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/ECHO/Libraries',
	'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
	'HEADER_SEARCH_PATHS' => '$(SRCROOT)/ECHO/Libraries/secp256k1/include $(SRCROOT)/ECHO/Libraries/openssl/include $(SRCROOT)/ECHO/Libraries/ed25519/include',
	'LIBRARY_SEARCH_PATHS[sdk=iphoneos*]' => '$(SRCROOT)/ECHO/Libraries/secp256k1/lib $(SRCROOT)/ECHO/Libraries/openssl/lib $(SRCROOT)/ECHO/Libraries/ed25519/lib/OSRelease',
	'LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*]' => '$(SRCROOT)/ECHO/Libraries/secp256k1/lib $(SRCROOT)/ECHO/Libraries/openssl/lib $(SRCROOT)/ECHO/Libraries/ed25519/lib/SimulatorRelease'}
  spec.preserve_paths = ['Libraries']
  spec.dependency "Starscream", '~> 3.0.2'
  spec.source_files  = 'ECHO/**/*.{h,swift,m}'

end
