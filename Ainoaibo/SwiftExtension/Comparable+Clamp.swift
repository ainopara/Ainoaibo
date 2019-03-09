//
//  Comparable+clamp.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2019/2/20.
//

import Foundation

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
