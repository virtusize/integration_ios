Pod::Spec.new do |s|
  s.name = 'VirtusizeAuth'
  s.version = '2.7.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Virtusize Auth for iOS'
  s.homepage = 'https://www.virtusize.com/'
  s.documentation_url = 'https://github.com/virtusize/integration_ios'
  s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
  s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => "#{s.version}" }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5'

  s.source_files = ['VirtusizeAuth/Sources/*.{swift, h}', 'VirtusizeAuth/Sources/**/*.swift']
  s.resource_bundle = { 'VirtusizeAuth' => ['VirtusizeAuth/Sources/Resources/**/*.lproj', 'VirtusizeAuth/Sources/Resources/PrivacyInfo.xcprivacy'] }

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.subspec 'VirtusizeCore' do |ss|
    ss.dependency 'VirtusizeCore', "#{s.version}"
  end
end