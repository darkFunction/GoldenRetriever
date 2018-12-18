Pod::Spec.new do |spec|
  spec.name         = "GoldenRetriever"
  spec.version      = "0.0.1"
  spec.summary      = "A friendly and light enum-based library to fetch your data from a HTTP/S endpoint."
  spec.homepage     = "https://github.com/darkFunction/GoldenRetriever"
  spec.license 		= { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Sam Taylor" => "sam@darkfunction.com" }
  spec.social_media_url = "https://twitter.com/darkFunction"
  spec.source       = { :git => "https://github.com/darkFunction/GoldenRetriever.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/GoldenRetriever/*.swift"
end
