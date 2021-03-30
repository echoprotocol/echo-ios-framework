Pod::Spec.new do |spec|
  spec.name = "ECHO"
  spec.version = "6.0.1"
  spec.summary = "Echo iOS Framework"
  spec.homepage = "https://github.com/echoprotocol/echo-ios-framework"
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors = {
    "Fedorenko Nikita" => 'n.fedorenko@pixelplex.io',
    "Sharaev Vladimir" => 'v.sharaev@pixelplex.io',
  }
  spec.swift_version = '5.0'
  spec.source = { :git => 'https://github.com/echoprotocol/echo-ios-framework' }
  spec.requires_arc = true
  spec.platform     = :ios
  spec.ios.deployment_target = "9.0"
  spec.preserve_path = 'ECHO/Supports Files/ECHO.modulemap'
  spec.module_map = 'ECHO/Supports Files/ECHO.modulemap'
  spec.pod_target_xcconfig = {  
	'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/ECHO/Libraries',
	'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
	'HEADER_SEARCH_PATHS' => '$(SRCROOT)/ECHO/Libraries/ed25519/include',
	'LIBRARY_SEARCH_PATHS[sdk=iphoneos*]' => '$(SRCROOT)/ECHO/Libraries/ed25519/lib/OSRelease',
	'LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*]' => '$(SRCROOT)/ECHO/Libraries/ed25519/lib/SimulatorRelease',
  'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)'
  }
  spec.preserve_paths = ['Libraries']
  spec.dependency "Starscream", '~> 3.0.2'
  spec.dependency "OpenSSL-Universal", '~> 1.1.1100'
  spec.source_files  = 'ECHO/**/*.{h,swift,m}'

end
