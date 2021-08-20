Pod::Spec.new do |s|
	s.name = 'Virtusize'
	s.version = '2.3.1'
	s.license = { :type => 'MIT', :file => 'LICENSE' }
	s.summary = 'Integrate Virtusize on iOS devices'
	s.homepage = 'https://www.virtusize.com/'
	s.documentation_url = 'https://github.com/virtusize/integration_ios'
	s.authors = { 'Virtusize' => 'client.support@virtusize.com' }
	s.source = { :git => 'https://github.com/virtusize/integration_ios.git', :tag => s.version }
	
	s.platform = :ios
	s.ios.deployment_target = '10.3'
	s.swift_version = '5'
	
	s.source_files = ['Virtusize/Sources/*.{swift, h}', 'Virtusize/Sources/**/*.swift']
	s.resource_bundle = { 'Virtusize' => ['Virtusize/Sources/Resources/**/*.lproj'] }
	
	s.subspec 'VirtusizeUIKit' do |ui_kit|
		ui_kit.source_files  = ['VirtusizeUIKit/Sources/*.{swift, h}', 'VirtusizeUIKit/Sources/**/*.swift']
		ui_kit.resources = 'VirtusizeUIKit/Sources/Resources/**/*.otf'
		ui_kit.resource_bundle = { 'VirtusizeUIKit' => 'VirtusizeUIKit/Sources/VirtusizeAssets.xcassets' }
	end
	# s.dependency = 'VirtusizeUIKit', s.version
	
end
