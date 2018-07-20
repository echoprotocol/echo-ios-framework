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
  spec.source_files  ="ECHO/**/*.{h,swift}"
  spec.requires_arc = true
  spec.platform     = :ios
  spec.ios.deployment_target = "9.0"

  spec.dependency "Starscream", '~> 3.0.2'

end
