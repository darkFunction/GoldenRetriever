Pod::Spec.new do |s|
  s.name         = "GoldenRetriever"
  s.version      = "0.0.3"
  s.summary      = "A friendly and light enum-based library to fetch your data from a HTTP/S endpoint."
  s.homepage     = "https://github.com/darkFunction/GoldenRetriever"
  s.license 		= { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Sam Taylor" => "sam@darkfunction.com" }
  s.social_media_url = "https://twitter.com/darkFunction"
  s.source       = { :git => "https://github.com/darkFunction/GoldenRetriever.git", :tag => "#{s.version}" }
  s.source_files = "Sources/GoldenRetriever/*.swift"
  s.swift_version = "4.2"
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
end

