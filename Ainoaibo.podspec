Pod::Spec.new do |s|

  s.name         = "Ainoaibo"
  s.version      = "0.2.0"
  s.summary      = "A collection of helper function / class to reuse in different projects while building iOS / macOS application."

  s.description  = <<-DESC
                   A collection of helper function / class to reuse in different projects while building iOS / macOS application.
                   Aibo is 相棒 in Japanese which means buddy. Aibo will always company with you, no matter which project you are working on.
                   DESC

  s.homepage     = "https://github.com/ainopara/Ainoaibo"
  s.license      = "BSD"
  s.author       = { "ainopara" => "ainopara@gmail.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/ainopara/Ainoaibo.git", :tag => "#{s.version}" }

  s.swift_version = "4.0"

  s.subspec 'LoggingProtocol' do |ss|
    ss.source_files = "Ainoaibo/LoggingProtocol/*.swift"
  end

  s.subspec 'OSLogger' do |ss|
    ss.source_files = "Ainoaibo/OSLogger/*.swift"
    ss.dependency "CocoaLumberjack"
    ss.dependency "CocoaLumberjack/Swift"
    ss.dependency "Ainoaibo/LoggingProtocol"
  end

  s.subspec 'Logging' do |ss|
    ss.source_files = "Ainoaibo/Logging/*.swift"
    ss.dependency "CocoaLumberjack"
    ss.dependency "CocoaLumberjack/Swift"
    ss.dependency "Ainoaibo/LoggingProtocol"
  end

  s.subspec 'InMemoryLogger' do |ss|
    ss.source_files = "Ainoaibo/InMemoryLogger/*.swift"
    ss.dependency "CocoaLumberjack"
    ss.dependency "CocoaLumberjack/Swift"
    ss.dependency "Ainoaibo/LoggingProtocol"
  end

  s.subspec 'InMemoryLogViewer' do |ss|
    ss.source_files = "Ainoaibo/InMemoryLogViewer/*.{swift}"
    ss.dependency "Ainoaibo/InMemoryLogger"
    ss.dependency "SnapKit"
  end

  s.subspec 'LogFormatters' do |ss|
    ss.source_files = "Ainoaibo/LogFormatters/*.{swift}"
    ss.dependency "CocoaLumberjack"
  end

  s.subspec 'SwiftExtension' do |ss|
    ss.source_files = "Ainoaibo/SwiftExtension/*.swift"
  end

  s.subspec 'DefaultsBasedSettings' do |ss|
    ss.source_files = "Ainoaibo/DefaultsBasedSettings/*.swift"
    ss.platform     = :ios, "13.1"
    ss.dependency "Ainoaibo/Logging"
  end

  s.subspec 'StateTransition' do |ss|
    ss.source_files = "Ainoaibo/StateTransition/*.swift"
  end

  s.subspec 'Alamofire+ResponseDecodable' do |ss|
    ss.source_files = "Ainoaibo/Alamofire+ResponseDecodable/*.swift"
    ss.dependency "Ainoaibo/Logging"
    ss.dependency "Alamofire", '~> 5.0'
  end

  s.subspec 'AuthNetworkManager' do |ss|
    ss.source_files = "Ainoaibo/AuthNetworkManager/*.swift"
    ss.platform     = :ios, "13.0"
    ss.dependency "Alamofire", '~> 5.0'
    ss.dependency "Ainoaibo/Alamofire+ResponseDecodable"
    ss.dependency "Ainoaibo/Logging"
  end

  s.subspec 'Stash' do |ss|
    ss.source_files = "Ainoaibo/Stash/Stash.swift"
  end
end
