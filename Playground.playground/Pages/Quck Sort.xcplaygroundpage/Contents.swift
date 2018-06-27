//: [Previous](@previous)

import Ainoaibo

var randomArray = [1, 8, 2, 4, 5, 6, 9, 0, 3, 7]

extension Array where Element: Comparable {

    func quickSorted() -> [Element] {
        guard self.count > 1 else {
            return self
        }

        let pivot = self[self.count / 2]

        // Debug
        // print(self, pivot)

        let left = self.filter({ $0 < pivot })
        let equal = self.filter({ $0 == pivot })
        let right = self.filter({ $0 > pivot })

        return left.quickSorted() + equal + right.quickSorted()
    }
}

let quickSorted = randomArray.quickSorted()
print(quickSorted)

randomArray.quickSort()
print(randomArray)

//: [Next](@next)
