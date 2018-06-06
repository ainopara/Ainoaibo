# Ainoaibo

A collection of helper function / class to reuse in different projects while building iOS / macOS application.

Aibo is 相棒 in Japanese which means buddy. Aibo will always company with you, no matter which project you are working on.

## Structure
Ainoaibo is maintained by ainopara and not supposed to fit everyone's need.

Even though this repo is generally a collection of codes which have many third party dependencies, I tried my best to devide them into different components.

## Components
Each component is represented in podspec as subspec. You can import component for your needs.

### LoggingProtocol
A shared defination which is used to help Applications / other frameworks create their own `Logging` helper function to meet the need of `OSLogger`.

### OSLogger
A `CocoaLumberjack` logger which can utilize information extracted from objects conforming to `LoggingProtocol`.

```swift
let dependency = ["Ainoaibo/LoggingProtocol", "CocoaLumberjack"]
```

### Logging
An internal component which offer helper function for logging which is supposed to be used by other components in this repo.

```swift
let dependency = ["Ainoaibo/LoggingProtocol", "CocoaLumberjack"]
```

### DefaultsBasedSettings
A `NSUserDefaults` backed Settings base class which offer methods to bind key stored in `NSUserDefaults` to `MutableProprty`.

```swift
let dependency = ["Ainoaibo/Logging", "ReactiveSwift"]
```

### SwiftExtension
A collection of helper function and extension about types in Swift Standard Library.

```swift
let dependency = []
```

### InMemoryLogger
Save logs in memory and can be accessed inside application.

```swift
let dependency = ["CocoaLumberjack"]
```

### InMemoryLogViewer
Used to inspect logs inside application. It is specially useful when your application encouter a bug that hard to reproduce while debugger is not attaching to the process.

```swift
let dependency = ["Ainoaibo/InMemoryLogger", "SnapKit"]
```

### Formatters

`DateLogFormatter`: Insert timestamp at the beginning of every log message.

`DispatchQueueLogFormatter`: Insert dispatch queue at the beginning of every log message.

`ErrorLevelLogFormatter`: Insert error level of the message at the beginning of every log message.

```swift
let dependency = ["CocoaLumberjack"]
```

## License
BSD