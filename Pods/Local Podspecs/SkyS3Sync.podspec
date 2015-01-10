Pod::Spec.new do |s|
  s.name             = "SkyS3Sync"
  s.version          = "0.2"
  s.summary          = "A utility for downsyncing remotely updated versions of local files from S3.  Allows you to remotely modify some application data and make it available to your app without the need to resubmit the app to AppStore or creating a specialized backend and API the app has to talk to"

  s.license          = { :type => "MIT", :file => "LICENSE.txt" }
  s.author           = { "Eugene Dorfman" => "eugene.dorfman@gmail.com" }  
  s.source           = { :git => "git@github.com:justadreamer/SkyS3Sync.git", :commit => "HEAD" }
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.homepage = 'https://github.com/justadreamer/SkyS3Sync'
  s.source_files = ['SkyS3Sync/*.{h,m}']

  s.dependency 'libextobjc', '~> 0.4.1'
  s.dependency 'AFAmazonS3Manager', '~> 3.0.0'
  s.dependency 'AFOnoResponseSerializer', '~> 1.0.0'
  s.dependency 'ObjectiveSugar', '~> 1.1.0'
  s.dependency 'FileMD5Hash', '~> 2.0'

end