#
# Be sure to run `pod lib lint StreamPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AudioPlayer'
  s.version          = '0.1.0'
  s.summary          = 'Simple to use wrapper around AVPlayer to stream music'

  s.description      = <<-DESC
Simple to use wrapper around AVPlayer to stream music. Supports queueing, activating session, MPRemoteCommandCenter, NowPlayingInfo
                       DESC

  s.homepage         = 'https://github.com/rurza/AudioPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adam Różyński' => 'adam@micropixels.pl' }
  s.source           = { :git => 'https://github.com/rurza/AudioPlayer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/rurza'

  s.ios.deployment_target = '10.0'

  s.source_files = 'AudioPlayer/Classes/**/*'
  s.frameworks = 'AVFoundation', 'MediaPlayer'
  
end
