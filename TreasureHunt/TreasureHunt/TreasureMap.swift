//
//  TreasureMap.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation

class TreasureMap {
    
    static let shared = TreasureMap()
    let networkClient = NetworkClient()
    
    var treasureMap = [0: ["n": "?", "s": "?", "e": "?", "w": "?"]]
    private let traversalPath = [String]()
    private let stack = [String]()
    var currentRoom: Room?
    
    func initialize() {
        networkClient.initializePlayer { (response) in
            switch response {
            case .success(let room):
                self.currentRoom = room
            case .error(let error):
                print(error)
            }
        }
    }
    
    func explore() {
        while treasureMap.count < 500 {
            
        }
        
        
        
        networkClient.move(in: "n") { (response) in
            
            switch response {
            case .success(let value):
                print(value)
            case .error(let error):
                print(error)
            }
            
        }
    }
}
