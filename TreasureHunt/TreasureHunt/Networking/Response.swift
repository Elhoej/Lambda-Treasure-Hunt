//
//  Response.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation

enum Response<Value> {
    case success(Value)
    case error(Error)
}

extension Response {
    func unwrap() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .error(error):
            throw error
        }
    }
}
