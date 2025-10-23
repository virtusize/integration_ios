Pod::Spec.new do |s|
  s.name = 'Virtusize'
  s.version = '2.12.14'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Integrate Virtusize on iOS devices'
  s.homepage = 'https://www.virtusize.com/'
  s.documentation_url = 'https://github.com/virtusize/integration_ios'
  s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
  s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => "#{s.version}" }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5'

  s.static_framework = true
  s.source_files = ["Virtusize/Sources/*.{swift, h}", "Virtusize/Sources/**/*.swift"]
  s.resources = "Virtusize/Sources/Resources/**/*.ttf"
  s.resource_bundle = { 'Virtusize' => ["Virtusize/Sources/Resources/**/*.lproj", "Virtusize/Sources/Resources/PrivacyInfo.xcprivacy"] }

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.subspec 'VirtusizeCore' do |ss|
    ss.dependency 'VirtusizeCore', "#{s.version}"
  end
  s.subspec 'VirtusizeAuth' do |ss|
    ss.dependency 'VirtusizeAuth', "#{s.version}"
  end
end
