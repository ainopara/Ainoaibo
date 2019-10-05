//
//  DefaultsBasedSettings.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/4/17.
//  Copyright © 2018 ain. All rights reserved.
//

import Combine

/// Extend this class and add your user defaults keys as static constants
/// so you can use the shortcut dot notation (e.g. `Defaults[.yourKey]`)
public class DefaultsKeys {
    fileprivate init() {}
}

/// Base class for static user defaults keys. Specialize with value type
/// and pass key name to the initializer to create a key.
public class DefaultsKey<ValueType: DefaultsCompatible>: DefaultsKeys {
    public let keyString: String

    public init(_ key: String) {
        self.keyString = key
        super.init()
    }
}

public protocol DefaultsCompatible {}
extension String: DefaultsCompatible {}
extension Int: DefaultsCompatible {}
extension Double: DefaultsCompatible {}
extension Bool: DefaultsCompatible {}
extension Array: DefaultsCompatible where Element: DefaultsCompatible {}
extension Dictionary: DefaultsCompatible where Key == String, Value: DefaultsCompatible {}
extension Data: DefaultsCompatible {}
extension Date: DefaultsCompatible {}
extension URL: DefaultsCompatible {}

extension UserDefaults {
    public subscript<T: DefaultsCompatible>(key: DefaultsKey<T>) -> T? {
        get { return self[key.keyString].flatMap({ $0 as? T }) }
        set { self[key.keyString] = newValue }
    }

    private subscript(key: String) -> Any? {
        get { return object(forKey: key) }
        set {
            guard let newValue = newValue else {
                removeObject(forKey: key)
                return
            }

            switch newValue {
            // This should always be on top of Int because a cast
            // from Double to Int will always succeed.
            case let value as Double:
                self.set(value, forKey: key)
            case let value as Int:
                self.set(value, forKey: key)
            case let value as Bool:
                self.set(value, forKey: key)
            case let value as URL:
                self.set(value, forKey: key)
            default:
                self.set(newValue, forKey: key)
            }
        }
    }
}

private extension CurrentValueSubject where Output: Equatable {
    func aibo_setValueIfDifferent(_ newValue: Output) {
        if self.value != newValue { self.value = newValue }
    }
}

// MARK: -

open class DefaultsBasedSettings: NSObject {
    public let defaults: UserDefaults
    private var observingKeyPathChangeCallbacks: [String: ((Any) -> Void)] = [:]
    private var disposables: [AnyCancellable] = []

    public init(defaults: UserDefaults) {
        self.defaults = defaults
        super.init()
    }

    deinit {
        for (key, _) in observingKeyPathChangeCallbacks {
            defaults.removeObserver(self, forKeyPath: key)
        }

        for disposalbe in disposables {
            disposalbe.cancel()
        }
    }

    public func removeValue<T>(for key: DefaultsKey<T>) {
        defaults.removeObject(forKey: key.keyString)
    }

    public func bind<T>(
        property: CurrentValueSubject<T, Never>,
        to key: DefaultsKey<T>,
        defaultValue: T
    ) where
        T: DefaultsCompatible,
        T: Equatable
    {
        // Initial value set from UserDefaults
        property.value = defaults[key] ?? defaultValue

        // Binding changes in property -> UserDefaults
        let disposable = property.removeDuplicates().dropFirst().sink { [weak self] (value) in
            guard let strongSelf = self else { return }
            guard strongSelf.defaults[key] != value else { return }
            strongSelf.defaults[key] = value
        }
        disposables.append(disposable)

        // Binding changes in UserDefaults -> property
        let keyPath = key.keyString
        LogDebug("Register KVO keypath: \(keyPath)", category: .settings)
        defaults.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
        observingKeyPathChangeCallbacks[keyPath] = { (newValue) in
            if newValue is NSNull {
                property.aibo_setValueIfDifferent(defaultValue)
            } else if let newValue = newValue as? T {
                property.aibo_setValueIfDifferent(newValue)
            } else {
                LogError("Expect newValue \(newValue) has Type \(T.self) or NSNull but got \(type(of: newValue))", category: .settings)
                property.aibo_setValueIfDifferent(defaultValue)
            }
        }
    }

    public func bind<Property, Value>(
        property: CurrentValueSubject<Property, Never>,
        to key: DefaultsKey<Value>,
        defaultValue: Property,
        mapToValue: @escaping (Property) -> Value,
        mapFromValue: @escaping (Value) -> Property
    ) where
        Property: Equatable,
        Value: DefaultsCompatible,
        Value: Equatable
    {
        // Initial value set from UserDefaults
        property.value = defaults[key].map(mapFromValue) ?? defaultValue

        // Binding changes in property -> UserDefaults
        let disposable = property.removeDuplicates().dropFirst().sink { [weak self] (propertyValue) in
            guard let strongSelf = self else { return }
            let defaultsValue = mapToValue(propertyValue)
            guard strongSelf.defaults[key] != defaultsValue else { return }
            strongSelf.defaults[key] = defaultsValue
        }
        disposables.append(disposable)

        // Binding changes in UserDefaults -> property
        let keyPath = key.keyString
        LogDebug("Register KVO keypath: \(keyPath)", category: .settings)
        defaults.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
        observingKeyPathChangeCallbacks[keyPath] = { (newValue) in
            if newValue is NSNull {
                property.aibo_setValueIfDifferent(defaultValue)
            } else if let newValue = newValue as? Value {
                property.aibo_setValueIfDifferent(mapFromValue(newValue))
            } else {
                LogError("Expect newValue \(newValue) has Type \(Value.self) or NSNull but got \(type(of: newValue))", category: .settings)
                property.aibo_setValueIfDifferent(defaultValue)
            }
        }
    }

    public func bind<T>(
        property: CurrentValueSubject<T?, Never>,
        to key: DefaultsKey<T>
    ) where
        T: DefaultsCompatible,
        T: Equatable
    {
        // Initial value set from UserDefaults
        property.value = defaults[key]

        // Binding changes in property -> UserDefaults
        let disposable = property.removeDuplicates().dropFirst().sink { [weak self] (value) in
            guard let strongSelf = self else { return }
            guard strongSelf.defaults[key] != value else { return }
            strongSelf.defaults[key] = value
        }
        disposables.append(disposable)

        // Binding changes in UserDefaults -> property
        let keyPath = "\(key.keyString)"
        LogDebug("Register KVO keypath: \(keyPath)", category: .settings)
        defaults.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
        observingKeyPathChangeCallbacks[keyPath] = { (newValue) in
            if newValue is NSNull {
                property.aibo_setValueIfDifferent(.none)
            } else if let newValue = newValue as? T {
                property.aibo_setValueIfDifferent(.some(newValue))
            } else {
                LogError("Expect newValue \(newValue) has Type \(T.self) or NSNull but got \(type(of: newValue))", category: .settings)
                property.aibo_setValueIfDifferent(.none)
            }
        }
    }

    public func bind<Property, Value>(
        property: CurrentValueSubject<Property, Never>,
        to key: DefaultsKey<Value>,
        mapToValue: @escaping (Property) -> Value?,
        mapFromValue: @escaping (Value?) -> Property
    ) where
        Property: Equatable,
        Value: DefaultsCompatible,
        Value: Equatable
    {
        // Initial value set from UserDefaults
        property.value = mapFromValue(defaults[key])

        // Binding changes in property -> UserDefaults
        let disposable = property.removeDuplicates().dropFirst().sink { [weak self] (propertyValue) in
            guard let strongSelf = self else { return }
            let defaultsValue = mapToValue(propertyValue)
            guard strongSelf.defaults[key] != defaultsValue else { return }
            strongSelf.defaults[key] = defaultsValue
        }
        disposables.append(disposable)

        // Binding changes in UserDefaults -> property
        let keyPath = "\(key.keyString)"
        LogDebug("Register KVO keypath: \(keyPath)", category: .settings)
        defaults.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
        observingKeyPathChangeCallbacks[keyPath] = { (newValue) in
            if newValue is NSNull {
                property.aibo_setValueIfDifferent(mapFromValue(Optional<Value>.none))
            } else if let newValue = newValue as? Value {
                property.aibo_setValueIfDifferent(mapFromValue(Optional<Value>.some(newValue)))
            } else {
                LogError("Expect newValue \(newValue) has Type \(Value.self) or NSNull but got \(type(of: newValue))", category: .settings)
                property.aibo_setValueIfDifferent(mapFromValue(Optional<Value>.none))
            }
        }
    }

    // swiftlint:disable block_based_kvo
    @objc
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let keyPath = keyPath else {
            fatalError("keyPath should not be nil.")
        }

        guard let newValue = change?[.newKey] else {
            fatalError("changes[.newKey] should not be nil.")
        }

        guard let callback = observingKeyPathChangeCallbacks[keyPath] else {
            fatalError("observingKeyPaths should have information about \(keyPath)")
        }

        callback(newValue)
    }
}
