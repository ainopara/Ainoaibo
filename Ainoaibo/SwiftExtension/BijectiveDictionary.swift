//
//  BijectiveDictionary.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/8.
//  Copyright © 2018 ain. All rights reserved.
//

#if compiler(>=5.0)

#warning("FIXME: `BijectiveDictionary` is not compatible with Swift 5.0")

#else

public class BijectiveDictionary<Key: Hashable, Value: Hashable>: ExpressibleByDictionaryLiteral {
    private var keyToValue = Dictionary<Key, Value>()
    private var valueToKey = Dictionary<Value, Key>()

    public init() {}

    public required init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, value) in elements {
            self.add(key: key, value: value)
        }
    }
}

// MARK: -

extension BijectiveDictionary {
    public func add(key: Key, value: Value) {
        if keyToValue[key] != Optional<Value>.none {
            print("Warning: Adding (key: \(key), value: \(value)) while key is already mapped to value \(keyToValue[key]!). Old pair is removed.")
            remove(key: key)
        }

        if valueToKey[value] != Optional<Key>.none {
            print("Warning: Adding (key: \(key), value: \(value)) while value is already mapped to key \(valueToKey[value]!). Old pair is removed.")
            remove(value: value)
        }

        keyToValue[key] = value
        valueToKey[value] = key
    }

    public func remove(key: Key) {
        guard let value = keyToValue[key] else {
            return
        }

        keyToValue.removeValue(forKey: key)
        valueToKey.removeValue(forKey: value)
    }

    public func remove(value: Value) {
        guard let key = valueToKey[value] else {
            return
        }

        keyToValue.removeValue(forKey: key)
        valueToKey.removeValue(forKey: value)
    }

    public func value(for key: Key) -> Value? {
        return keyToValue[key]
    }

    public func key(for value: Value) -> Key? {
        return valueToKey[value]
    }

    public subscript(key: Key) -> Value? {
        get {
            return self.value(for: key)
        }

        set {
            if let newValue = newValue {
                self.add(key: key, value: newValue)
            } else {
                self.remove(key: key)
            }
        }
    }

    public subscript(value: Value) -> Key? {
        get {
            return self.key(for: value)
        }

        set {
            if let newKey = newValue {
                self.add(key: newKey, value: value)
            } else {
                self.remove(value: value)
            }
        }
    }
}

// MARK: - Sequence

extension BijectiveDictionary: Sequence {
    public typealias Iterator = DictionaryIterator<Key, Value>

    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return keyToValue.makeIterator()
    }
}

// MARK: - Collection

extension BijectiveDictionary: Collection {
    public typealias Index = Dictionary<Key, Value>.Index

    public var startIndex: Dictionary<Key, Value>.Index {
        return keyToValue.startIndex
    }

    public var endIndex: Dictionary<Key, Value>.Index {
        return keyToValue.endIndex
    }

    public subscript(index: Dictionary<Key, Value>.Index) -> Element {
        return keyToValue[index]
    }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        return keyToValue.index(after: i)
    }
}

#endif
