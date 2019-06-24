//
//  Stash.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/12.
//  Copyright © 2018 ain. All rights reserved.
//

import Foundation

extension Result where Failure == Swift.Error {

    public func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            do {
                let transformed = try transform(success)
                return .success(transformed)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
