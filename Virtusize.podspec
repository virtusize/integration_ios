Pod::Spec.new do |s|
  s.name = 'Virtusize'
  s.version = '1.2.0'
  s.license = { :type => 'Copyright', :text => 'Copyright 2018 Virtusize' }
  s.summary = 'Integrate Virtusize on iOS devices'
  s.homepage = 'https://www.virtusize.com/'
  s.social_media_url = 'https://twitter.com/virtusize'
  s.documentation_url = 'https://github.com/virtusize/integration_ios'
  s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
  s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => s.version }

  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'Source/*.swift', 'Source/**/*.swift'
  s.resources = ['Source/Resources/Media.xcassets']
end
