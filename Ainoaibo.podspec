Pod::Spec.new do |s|

  s.name         = "Ainoaibo"
  s.version      = "0.1.0"
  s.summary      = "A collection of helper function / class to reuse in different projects while building iOS / macOS application."

  s.description  = <<-DESC
                   A collection of helper function / class to reuse in different projects while building iOS / macOS application.
                   Aibo is 相棒 in Japanese which means buddy. Aibo will always company with you, no matter which project you are working on.
                   DESC

  s.homepage     = "https://github.com/ainopara/Ainoaibo"
  s.license      = "BSD"
  s.author       = { "ainopara" => "ainopara@gmail.com" }
  s.platform     = :ios, "9.0"
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

  s.subspec 'SwiftExtension' do |ss|
    ss.source_files = "Ainoaibo/SwiftExtension/*.swift"
  end

  s.subspec 'DefaultsBasedSettings' do |ss|
    ss.source_files = "Ainoaibo/Settings/*.swift"
    ss.dependency "Ainoaibo/Logging"
    ss.dependency "ReactiveSwift"
  end
end
