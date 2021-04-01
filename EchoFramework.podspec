Pod::Spec.new do |spec|
  spec.name = "EchoFramework"
  spec.version = "6.0.0"
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

  spec.module_map = 'EchoFramework/Supports Files/EchoFramework.modulemap'
  spec.pod_target_xcconfig = {  
  'SWIFT_INCLUDE_PATHS' => '${SRCROOT} $(SRCROOT)/EchoFramework/Libraries',
  'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
  'HEADER_SEARCH_PATHS' => '$(SRCROOT)/EchoFramework/Libraries/ed25519/include',
  'LIBRARY_SEARCH_PATHS[sdk=iphoneos*]' => '$(SRCROOT)/EchoFramework/Libraries/ed25519/lib/OSRelease',
  'LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*]' => '$(SRCROOT)/EchoFramework/Libraries/ed25519/lib/SimulatorRelease',
  'ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  spec.preserve_paths = ['Libraries', 'EchoFramework/Supports Files/EchoFramework.modulemap']
  spec.source_files  = 'EchoFramework/**/*.{h,swift,m,a}'
  spec.user_target_xcconfig = { 'ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

  spec.dependency "Starscream", '~> 3.0.2'
  spec.dependency "OpenSSL-Universal", '~> 1.1.1100'
end
