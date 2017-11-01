Pod::Spec.new do |spec|
  spec.name             = 'EagleBit'
  spec.platform         = :ios, "10.0"
  spec.version          = '1.0.2'
  spec.license          = { :type => 'Apache License, Version 2.0' }
  spec.homepage         = 'https://github.com/mhergon/EagleBit'
  spec.authors          = { 'Marc Hervera' => 'mhergon@gmail.com' }
  spec.summary          = 'EagleBit is the most efficient way to get locations indefinitely without without sacrificing battery life'
  spec.source           = { :git => 'https://github.com/mhergon/EagleBit.git', :tag => 'v1.0.2' }
  spec.source_files     = 'EagleBit.swift'
  spec.ios.frameworks   = 'CoreLocation'
  spec.requires_arc     = true
  spec.module_name      = 'EagleBit'
end
