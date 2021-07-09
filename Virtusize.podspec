Pod::Spec.new do |s|
  s.name = 'Virtusize'
  s.version = '2.2.3'
  s.license = { :type => 'Copyright', :text => 'Copyright 2021 Virtusize' }
  s.summary = 'Integrate Virtusize on iOS devices'
  s.homepage = 'https://www.virtusize.com/'
  s.documentation_url = 'https://github.com/virtusize/integration_ios'
  s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
  s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => s.version }

  s.platform = :ios
  s.ios.deployment_target = '10.3'
  s.swift_version = '5'

  s.source_files = ["Source/*.{swift, h}", "Source/**/*.swift"]
	s.resources = "Source/Resources/**/*.otf"
  s.resource_bundle = { 'Virtusize' => ["Source/Resources/**/*.lproj", "Source/VirtusizeAssets.xcassets"] }
end
