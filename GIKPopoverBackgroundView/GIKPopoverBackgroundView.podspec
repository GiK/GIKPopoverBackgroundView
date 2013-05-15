Pod::Spec.new do |s|
  s.name     = 'GIKPopoverBackgroundView'
  s.version  = '1.0.1'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'Custom popover backgrounds. UIKit quality.'
  s.homepage = 'https://github.com/GiK/GIKPopoverBackgroundView.git'
  s.author   = { 'Gordon Hughes' => 'gordon@geeksinkilts.com' }
  s.source   = { :git => 'https://github.com/GiK/GIKPopoverBackgroundView.git', :tag => s.version.to_s }
  s.source_files = 'GIKPopoverBackgroundView.{h,m}'
  s.framework = 'QuartzCore'
  s.requires_arc = true
  
  s.ios.deployment_target = '5.0'
  s.ios.frameworks = 'QuartzCore'