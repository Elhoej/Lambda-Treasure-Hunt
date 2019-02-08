//
//  Room.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation

struct Room: Codable {
    var roomId: Int
    var exits: [String]
    var title: String
    var coordinates: String?
    var players: [String]?
    var items: [String]?
    var messages: [String]?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case exits
        case title
        case coordinates
        case players
        case items
        case messages
    }
}
