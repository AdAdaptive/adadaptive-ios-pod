#
# Be sure to run `pod lib lint AdAdaptive.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AdAdaptive'
  s.version          = '0.1.0'
  s.summary          = 'AdAdaptive iOS SDK CocoaPod'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'AdAdaptive is mobile AD management and distribution platform for advertisers and publishers using location-based, contextual intelligence and predictive AI-based targeting technology. The AdAdaptive iOS SDK provides the necessary functionality to access the AdAdaptive API and to integrate the AdAdaptive platform into third party mobile applications'

  s.homepage         = 'https://github.com/AdAdaptive/adadaptive-ios-pod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AdAdaptive' => 'info@adadaptive.com' }
  s.source           = { :git => 'https://github.com/AdAdaptive/adadaptive-ios-pod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'AdAdaptive/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AdAdaptive' => ['AdAdaptive/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Alamofire', '~> 4.3'
  s.dependency 'AlamofireImage', '~> 3.1'
end
