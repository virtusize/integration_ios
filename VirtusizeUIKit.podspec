Pod::Spec.new do |s|
	s.name = 'VirtusizeUIKit'
	s.version = '2.5.9'
	s.license = { :type => 'MIT', :file => 'LICENSE' }
	s.summary = 'Virtusize UI toolkit for iOS'
	s.homepage = 'https://www.virtusize.com/'
	s.documentation_url = 'https://github.com/virtusize/integration_ios'
	s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
	s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => s.version }
	
	s.platform = :ios
	s.ios.deployment_target = '13.0'
	s.swift_version = '5'
	
	s.source_files = ['VirtusizeUIKit/Sources/*.{swift, h}', 'VirtusizeUIKit/Sources/**/*.swift']
	s.resources = 'VirtusizeUIKit/Sources/Resources/**/*.otf'
	s.resource_bundle = {
		'VirtusizeUIKit' => ['VirtusizeUIKit/Sources/Resources/VirtusizeAssets.xcassets']
	}
    s.dependency "VirtusizeCore", "<= #{s.version}"
end