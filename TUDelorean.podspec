Pod::Spec.new do |s|
  s.name         = 'TUDelorean'
  s.version      = '0.9.0'
  s.homepage     = 'https://github.com/tuenti/TUDelorean'
  s.summary      = 'A DeLorean helps you test your time-dependent code allowing you travel anywhere in time.'
  s.authors      = { 'Tuenti Technologies S.L.' => 'https://twitter.com/TuentiEng' }
  s.source       = { :git => 'https://github.com/tuenti/TUDelorean.git', :tag => s.version.to_s }
  s.source_files = 'Classes/common/*.{h,m}'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.requires_arc = true
end
