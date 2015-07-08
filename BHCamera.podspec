Pod::Spec.new do |s|
  s.name             = "BHCamera"
  s.version          = "0.1.0"
  s.summary          = "React native camera, barcode scanner, utils."
  s.homepage         = "https://github.com/bh5-pods/BHCamera"
  s.license          = 'MIT'
  s.author           = { "Bodhi5 Inc" => "info@bodhi5.com" }
  s.source           = { :git => "https://github.com/bh5-pods/BHCamera.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'BHCamera/*.{h,m,swift}'
  s.dependency 'React'
end
