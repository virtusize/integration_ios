Pod::Spec.new do |s|
  s.name = 'VirtusizeCore'
  s.version = '2.4.3'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Virtusize Core for iOS'
  s.homepage = 'https://www.virtusize.com/'
  s.documentation_url = 'https://github.com/virtusize/integration_ios'
  s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
  s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => "#{s.version}" }

  s.platform = :ios
  s.ios.deployment_target = '10.3'
  s.swift_version = '5'

  s.source_files = ['VirtusizeCore/Sources/*.{swift, h}', 'VirtusizeCore/Sources/**/*.swift']
  s.resource_bundle = { 'VirtusizeCore' => ['VirtusizeCore/Sources/Resources/**/*.lproj'] }
end
