#
# Be sure to run `pod lib lint OABluetooth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OABluetooth'
  s.version          = '1.1.0'
  s.summary          = 'A short description of OABluetooth.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Roen-Ro/OABluetooth'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '罗亮富(Roen)' => 'zxllf23@163.com' }
  s.source           = { :git => 'https://github.com/Roen-Ro/OABluetooth.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '8.0'

s.source_files = 'OABluetooth/Classes/**/*'
s.public_header_files = 'Pod/Classes/Public/*.h'

s.frameworks = 'CoreBluetooth'
s.dependency 'ObjcExtensionProperty'

end
