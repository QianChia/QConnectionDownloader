Pod::Spec.new do |s|
  s.name         = 'QConnectionDownloader'
  s.version      = '1.0.0'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/QianChia/QConnectionDownloader'
  s.authors      = 'QianChia': 'jhqian0228@icloud.com'
  s.summary      = 'A simple encapsulation of NSURLConnection files to download'
  s.source       =  git: 'https://github.com/QianChia/QConnectionDownloader.git', :tag => s.version
  s.source_files = 'QConnectionDownloader'
  s.requires_arc = true
end