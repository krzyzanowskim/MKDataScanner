Pod::Spec.new do |s|
  s.name         = "MKDataScanner"
  s.version      = "0.1"
  s.summary      = "NSScanner for NSData and files."
  s.description  = "MKDataScanner is for raw data, what NSScanner is for NSString."
  s.homepage     = "https://github.com/krzyzanowskim/MKDataScanner"
  s.license	     = { :type => 'BSD', :file => 'LICENSE.txt' }
  s.source       = { :git => "https://github.com/krzyzanowskim/MKDataScanner.git", :tag => "#{s.version}" }

  s.authors       =  {'Marcin Krzyżanowski' => 'marcin.krzyzanowski@hakore.com'}
  s.social_media_url   = "https://twitter.com/krzyzanowskim"

  s.ios.platform          = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.ios.header_dir          = 'MKDataScanner'

  s.osx.platform          = :osx, '10.9'
  s.osx.deployment_target = '10.9'
  s.osx.header_dir          = 'MKDataScanner'

  s.source_files = 'MKDataScanner/*.{h,m}'
  s.public_header_files = 'MKDataScanner/*.h'

  s.requires_arc = true
end
