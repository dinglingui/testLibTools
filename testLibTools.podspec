#
# Be sure to run `pod lib lint testLibTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'testLibTools'
  s.version          = '4.0.0'
  s.summary          = 'A short description of testLibTools.'
  s.description      = <<-DESC
  s.homepage         = 'https://github.com/dinglingui/testLibTools.git'
  s.screenshots  = "https://raw.githubusercontent.com/vikmeup/SCPopUpView/master/errorScreenshot.png", "https://raw.githubusercontent.com/vikmeup/SCPopUpView/master/successScreenshot.png"
  s.license      = { :type => "MIT", :file => "LICENCE" }
  s.author           = { 'dinglingui1234' => '731239932@qq.com' }
  s.source           = { :git => 'https://github.com/dinglingui/testLibTools.git', :tag => s.version }
  s.platform     = :ios
  s.ios.deployment_target = '12.0'
  s.swift_versions = '5.0'
  s. summary = 'Fast integration of watermark function.'

  s.source_files = 'testLibTools/Classes/**/*'
end
