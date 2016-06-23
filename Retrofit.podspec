Pod::Spec.new do |s|
    s.name             = "Retrofit"
    s.version          = "0.1.0"
    s.summary          = "Network abstraction layer based on AFNetworking."

    s.description      = <<-DESC
                        Network abstraction layer based on AFNetworking.
                        DESC

    s.homepage         = "https://github.com/Haidora/Retrofit"
    s.license          = 'MIT'
    s.author           = { "mrdaios" => "mrdaios@gmail.com" }
    s.source           = { :git => "https://github.com/Haidora/Retrofit.git", :tag => s.version.to_s }
    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.source_files = 'Retrofit/Classes/**/*'
    s.public_header_files = ['Retrofit/Classes/Public/*.h']
    s.dependency 'AFNetworking', '~> 2.6.3'
end
