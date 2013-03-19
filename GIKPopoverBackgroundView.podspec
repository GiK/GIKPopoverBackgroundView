Pod::Spec.new do |s|
  s.name         = 'GIKPopoverBackgroundView'
  s.version      = '0.0.1'
  s.license      = 'MIT'
  s.platform     = :ios, '5.0'

  s.summary      = 'GIKPopoverBackgroundView is a UIPopoverBackgroundView subclass which shows how to customise the background of a UIPopoverController.'
  s.homepage     = 'https://github.com/GiK/GIKPopoverBackgroundView'
  s.author       = { 'Gordon Hughes' => 'gordon@geeksinkilts.com' }
  s.source       = { :git => 'https://github.com/GiK/GIKPopoverBackgroundView.git' }

  s.source_files = 'GIKPopoverBackgroundView/*.{h,m}'

  s.requires_arc = true
end
