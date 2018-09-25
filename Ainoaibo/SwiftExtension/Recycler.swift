//
//  Recycler.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/9/25.
//  Copyright © 2018 ain. All rights reserved.
//

import Foundation

protocol Reusable {

}

class Recycler<T: Reusable> {
    var bin: [T] = []

    func add(object: T) {
        bin.append(object)
    }

    func get() -> T? {
        return bin.popLast()
    }
}
