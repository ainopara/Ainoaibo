//
//  WeakArray.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/9/25.
//  Copyright © 2018 ain. All rights reserved.
//

import Foundation

class Weak<T: AnyObject> {
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

class WeakArray<T: AnyObject> {
    var array: [Weak<T>] = []

    init(array: [T]) {
        self.array = array.map(Weak.init)
    }
}

extension WeakArray: RandomAccessCollection {
    public var startIndex: Int {
        return self.array.startIndex
    }

    public var endIndex: Int {
        return self.array.endIndex
    }

    public subscript(index: Int) -> T? {
        return self.array[index].object
    }

    public func index(after i: Int) -> Int {
        return self.array.index(after: i)
    }
}
