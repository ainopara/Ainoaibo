//
//  QuickSort.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/27.
//  Copyright © 2018 ain. All rights reserved.
//

public enum QuickSortPartition {
    case lomuto
}

extension RandomAccessCollection where Self: MutableCollection, Element: Comparable, Index == Int {
    private mutating func lomutoPartition() -> Index {
        let indexOfLastElement = self.index(before: self.endIndex)
        let pivot = self[indexOfLastElement]

        // Debug
        // print(self, pivot)

        var i = self.startIndex

        for j in self.startIndex..<self.endIndex where self[j] < pivot {
            self.swapAt(i, j)
            i = i.advanced(by: 1)
        }

        self.swapAt(i, indexOfLastElement)

        return i
    }

    public mutating func quickSort(partition: QuickSortPartition = .lomuto) {
        guard self.count > 1 else { return }

        let pivotIndex: Int
        switch partition {
        case .lomuto:
            pivotIndex = self.lomutoPartition()
        }

        self[..<pivotIndex].quickSort()
        self[pivotIndex.advanced(by: 1)...].quickSort()
    }
}
