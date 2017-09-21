#
# Be sure to run `pod lib lint GetUpdate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name         = "GetUpdate"
  s.version      = "0.1.0"
  s.summary      = "GetUpdate helps you to manage app updates"
  s.homepage     = "https://github.com/AlecsRosa/GetUpdate"
  s.license      = "MIT"
  s.author       = { 'Alessandro Rosa' => 'alecs.rosa@me.com' }
  s.platform     = :ios, "9.0"
  s.source       = { :git => 'https://github.com/AlecsRosa/GetUpdate.git', :tag => s.version }
  s.source_files = 'GetUpdate/Classes/**/*'
end