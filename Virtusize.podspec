Pod::Spec.new do |s|
	s.name = 'Virtusize'
	s.version = '2.4.2'
	s.license = { :type => 'MIT', :file => 'LICENSE' }
	s.summary = 'Integrate Virtusize on iOS devices'
	s.homepage = 'https://www.virtusize.com/'
	s.documentation_url = 'https://github.com/virtusize/integration_ios'
	s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
	s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => s.version }
	
	s.platform = :ios
	s.ios.deployment_target = '10.3'
	s.swift_version = '5'
	
	s.source_files = ["Virtusize/Sources/*.{swift, h}", "Virtusize/Sources/**/*.swift"]
	s.resources = "Virtusize/Sources/Resources/**/*.otf"
	s.resource_bundle = { 'Virtusize' => ["Virtusize/Sources/Resources/**/*.lproj", "Virtusize/Sources/VirtusizeAssets.xcassets"] }
	s.dependency 'VirtusizeCore', s.version
end
