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
    
    var rooms = [Int: [String: String]]()
    var currentRoom: Room?
    var currentRoomId = 0
    private var traversalPath = [String]()
    private var stack = [String]()
    
    func initialize() {
        networkClient.initializePlayer { (response) in
            switch response {
            case .success(let room):
                self.initializeFirstRoom(room: room)
            case .error(let error):
                print(error)
            }
        }
    }
    
    func initializeFirstRoom(room: Room) {
        guard let roomExits = room.exits else { return }
        var exits = [String: String]()
        for exit in roomExits  {
            exits[exit] = "?"
        }
        rooms[room.roomId] = exits
        currentRoom = room
        currentRoomId = room.roomId
        print(rooms)
    }
    
    func explore() {
        while rooms.count < 500 {
            print(rooms)
            let current_exits = rooms[currentRoomId]
            
            var newExits = [String]()
            for exit in rooms[currentRoomId]! {
                if current_exits?[exit.key] == "?" {
                    newExits.append(exit.key)
                }
            }
            
            if !newExits.isEmpty {
                let lastRoom = currentRoomId
                let direction = newExits[0]
                traversalPath.append(direction)
                stack.append(direction)

                var newRoom: Room?
                
                networkClient.move(in: direction) { (response) in
                    switch response {
                    case .success(let room):
                        newRoom = room
                        self.currentRoom = room
                        self.currentRoomId = room.roomId
                        let newRoomId = newRoom?.roomId
                        if self.rooms[newRoomId!] == nil {
                            var newRoomExits = [String: String]()
                            for exit in (newRoom?.exits)! {
                                newRoomExits[exit] = "?"
                            }
                            self.rooms[newRoomId!] = newRoomExits
                        }
                        
                        self.rooms[lastRoom]?[direction] = String(newRoomId!)
                        self.rooms[newRoomId!]?[self.oppositeDirection(direction: direction)] = String(lastRoom)
                        sleep(3)
                    case .error(let error):
                        print(error)
                        sleep(3)
                        return
                    }
                }
            } else {
                if !stack.isEmpty {
                    let lastDirection = stack.popLast()
                    let backDirection = oppositeDirection(direction: lastDirection!)
                    networkClient.move(in: backDirection) { (response) in
                        switch response {
                        case .success(let room):
                            self.currentRoom = room
                            self.currentRoomId = room.roomId
                            sleep(3)
                        case .error:
                            sleep(3)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func oppositeDirection(direction: String) -> String {
        switch direction {
        case "n": return "s"
        case "s": return "n"
        case "e": return "w"
        case "w": return "e"
        default: return ""
        }
    }
}
