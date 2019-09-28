//
//  Stash.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/12.
//  Copyright © 2018 ain. All rights reserved.
//

import Foundation

extension Result {

    public func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Swift.Error> {
        switch self {
        case .success(let value):
            do {
                return try .success(transform(value))
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
