Pod::Spec.new do |s|
  s.name = 'Virtusize'
  s.version = '2.5.9'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Integrate Virtusize on iOS devices'
  s.homepage = 'https://www.virtusize.com/'
  s.documentation_url = 'https://github.com/virtusize/integration_ios'
  s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
  s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => "#{s.version}" }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5'
  
  s.source_files = ["Virtusize/Sources/*.{swift, h}", "Virtusize/Sources/**/*.swift"]
  s.resource_bundle = { 'Virtusize' => ["Virtusize/Sources/PrivacyInfo.xcprivacy"] }

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.dependency "VirtusizeCore", "<= #{s.version}"
  s.dependency "VirtusizeAuth", "1.1.0"
  s.subspec 'VirtusizeUIKit' do |ui_kit|
    ui_kit.source_files = ["VirtusizeUIKit/Sources/*.{swift, h}", "VirtusizeUIKit/Sources/**/*.swift"]
    ui_kit.resources = "VirtusizeUIKit/Sources/Resources/**/*.{otf, ttf}"
    ui_kit.resource_bundle = { 'VirtusizeUIKit' => ["VirtusizeUIKit/Sources/Resources/VirtusizeAssets.xcassets"] }
  end
  # s.dependency "VirtusizeUIKit", "<= #{s.version}"
end
