#
# Be sure to run `pod lib lint ReactiveSprint.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ReactiveSprint"
  s.version          = "0.1.0"
  s.summary          = "ReactiveSprint aims to speed up development by implementing MVVM pattern."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "ReactiveSprint aims to speed up development by implementing MVVM pattern."

  s.homepage         = "https://github.com/ReactiveSprint/CocoaReactiveSprint"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ahmad Baraka" => "ah-baraka@live.com" }
  s.source           = { :git => "https://github.com/ReactiveSprint/CocoaReactiveSprint.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ReactiveSprint' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ReactiveCocoa', '~> 4.1'
end
