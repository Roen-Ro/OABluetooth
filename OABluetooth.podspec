#
# Be sure to run `pod lib lint OABluetooth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OABluetooth'
  s.version          = '1.2.0'
  s.summary          = 'Bluetooth low energy(BLE) service for ios and OSX based on CoreBluetooth'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  OABluetooth is a lightweight framework based on Apple's CoreBluetooth that can be applied both on ios and OSX, It can manage different kind of peripherals independently, peripheral auto reconnection on disconnected. support block call backs for envents and communitations.
  OABluetooth map all type of services,characteristics and descriptors(which are represented by CBService,CBCharateristic and CBDescriptor) in to a OABTPort, you will have no more headaches to maintain these things. Comapared to connection->discover services->discover charateristics->[discover descriptores]->data transfer communication establish process based on CoreBluetooth， OABluetooth simplify it to connection->data transfer, all else will be done automatically. more features are listed here.
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
