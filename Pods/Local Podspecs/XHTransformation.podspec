
Pod::Spec.new do |s|
  s.name             = "XHTransformation"
  s.version          = "0.1"
  s.summary          = "A wrapper over XSLT with a couple useful additions to allow you easily scrape HTML into JSON object"
  s.license          = { :type => "MIT", :file => "LICENSE.txt" }
  s.author           = { "Eugene Dorfman" => "eugene.dorfman@gmail.com" }  
  s.source           = { :git => "git@github.com:justadreamer/iOS-XSLT-HTMLScraper.git", :tag => "0.1" }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true
  s.homepage = 'https://github.com/justadreamer/iOS-XSLT-HTMLScraper'
  
  s.source_files = ['XHTransformation/XHAll.h']

  s.dependency 'XHTransformation/Base'
  s.dependency 'XHTransformation/AFNetworking'
  s.dependency 'XHTransformation/Mantle'

  s.subspec 'Base' do |ss|
    ss.source_files = ['XHTransformation/XHTransformation.{h,m}','XHTransformation/XHModelAdapter.h','XHTransformation/regexp.c','XHTransformation/pcre.h']
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2' }
    ss.libraries = 'xslt', 'exslt', 'xml2'
    ss.preserve_paths = 'XHTransformation/{libxslt,libexslt}'
    ss.private_header_files = ['XHTransformation/libxslt/XHTransformation.h','XHTransformation/libexslt/*.h']
    ss.vendored_library = 'XHTransformation/libpcre.a'
  end

  s.subspec 'AFNetworking' do |ss|
    ss.dependency 'XHTransformation/Base'
    ss.dependency 'AFNetworking'
    ss.source_files = 'XHTransformation/XHTransformationHTMLResponseSerializer.{h,m}'
  end

  s.subspec 'Mantle' do |ss|
    ss.dependency 'XHTransformation/Base'
    ss.dependency 'Mantle'
    ss.source_files = 'XHTransformation/XHMantleModelAdapter.{h,m}'
  end
end
