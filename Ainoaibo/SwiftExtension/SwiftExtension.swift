//
//  Mutate.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/6.
//  Copyright © 2018 ain. All rights reserved.
//


/// Edit an immutable struct and create a new struct.
///
/// - Sources:
/// [Let's Talk About Let](https://www.youtube.com/watch?v=jzdOkQFekbg)
///
/// - Examples:
/// ```swift
/// let rect = mutate(view.bounds) { (value: inout CGRect) in
///     value.origin.y += 20.0
///     value.size.height -= 20.0
/// }
/// ```
public func mutate<T>(_ value: T, change: (inout T) -> Void) -> T {
    var copy = value
    change(&copy)
    return copy
}

extension Comparable {

    /// Clamp value to specific range.
    ///
    /// - Sources:
    /// [Add clamp(to:) to the stdlib](https://github.com/apple/swift-evolution/blob/master/proposals/0177-add-clamped-to-method.md)
    ///
    /// - Parameter range: range describing upper bound and lower bound of clamped value.
    /// - Returns: Clamped value.
    public func aibo_clamped(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound {
            return range.upperBound
        } else if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }

    public func aibo_clamped(to range: PartialRangeFrom<Self>) -> Self {
        if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }

    public func aibo_clamped(to range: PartialRangeThrough<Self>) -> Self {
        if self > range.upperBound {
            return range.upperBound
        } else {
            return self
        }
    }
}

extension String {
    public init<T>(dumping object: T) {
        self.init()
        dump(object, to: &self)
    }
}
