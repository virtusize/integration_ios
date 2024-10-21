Pod::Spec.new do |s|
  s.name = 'Virtusize'
  s.version = '2.6.1'
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
  s.resources = "Virtusize/Sources/Resources/**/*.otf"
  s.resource_bundle = { 'Virtusize' => ["Virtusize/Sources/Resources/**/*.lproj", "Virtusize/Sources/Resources/PrivacyInfo.xcprivacy"] }

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.subspec 'VirtusizeCore' do |core|
      core.source_files = ['VirtusizeCore/Sources/*.{swift, h}', 'VirtusizeCore/Sources/**/*.swift']
      core.resource_bundle = { 'Virtusize_VirtusizeCore' => ['VirtusizeCore/Sources/Resources/**/*.lproj', "VirtusizeCore/Sources/Resources/PrivacyInfo.xcprivacy"] }
  end
  s.dependency "VirtusizeAuth", "<= 1.1.5"
end
