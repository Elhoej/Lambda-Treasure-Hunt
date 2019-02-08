//
//  Coords.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation

struct Coords: Codable {
    var x: Int
    var y: Int
    
    init?(coords: String) {
        let trimmedString = coords.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        let components = trimmedString.split(separator: ",")
        guard let x = Int(components[0]), let y = Int(components[1]) else { return nil }
        self.x = x
        self.y = y
    }
}
