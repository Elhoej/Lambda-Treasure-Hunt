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
    private var timer: Timer?
    
    var rooms = [Int: [String: String]]()
    var coords = [Int: [Int]]() {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didRecieveCoordsBundle, object: nil, userInfo: ["coords": self.coords])
            }
        }
    }
    private var currentRoom: Room? {
        didSet {
            guard let currentRoom = currentRoom else { return }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didRecieveRoom, object: nil, userInfo: ["room": currentRoom])
            }
        }
    }
    private var currentRoomId = 0
    private var traversalPath = [String]()
    private var stack = [String]()
    var cooldown = 10
    
    func initialize(completion: @escaping (Room?) -> ()) {
        networkClient.initializePlayer { (response) in
            switch response {
            case .success(let room):
                self.initializeFirstRoom(room: room)
                completion(room)
            case .error(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func initializeFirstRoom(room: Room) {
        if let mapData = UserDefaults.standard.data(forKey: "TreasureMap") {
            let coordsData = UserDefaults.standard.data(forKey: "TreasureCoords")
            let stackData = UserDefaults.standard.data(forKey: "TreasureStack")
            let pathData = UserDefaults.standard.data(forKey: "TreasurePath")
            do {
                let mapDictionary = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: mapData)
                let coordsDictionary = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self], from: coordsData!)
                let stackArray = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: stackData!)
                let path = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: pathData!)
                stack = stackArray as! [String]
                traversalPath = path as! [String]
                rooms = mapDictionary as! [Int: [String: String]]
                coords = coordsDictionary as! [Int: [Int]]
                
            } catch {
                print(error)
            }
        } else {
            guard let roomExits = room.exits else { return }
            var exits = [String: String]()
            for exit in roomExits  {
                exits[exit] = "?"
            }
            rooms[room.roomId] = exits
        }
        currentRoom = room
        currentRoomId = room.roomId
    }
    
    func explore() {
        print(rooms.count)
        print(rooms[currentRoomId])
        if rooms.count >= 500 {
            print("Map fully explored")
            return
        }
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
            print(direction)
            traversalPath.append(direction)
            stack.append(direction)

            var newRoom: Room?

            networkClient.move(in: direction) { (response) in
                switch response {
                case .success(let room):
                    newRoom = room
                    guard let newCoords = Coords(coords: (newRoom?.coordinates)!) else { return }
                    self.coords[newRoom!.roomId] = [newCoords.x, newCoords.y]
                    self.cooldown = room.cooldown!
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
                    self.saveData()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .didReceiveCooldown, object: nil, userInfo: ["cooldown": self.cooldown])
                        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.cooldown) + 0.5, target: self, selector: #selector(self.handleCooldown), userInfo: nil, repeats: false)
                    }
                case .error(let error):
                    print(error)
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
                        DispatchQueue.main.async {
                            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.cooldown), target: self, selector: #selector(self.handleCooldown), userInfo: nil, repeats: false)
                        }
                    case .error(let error):
                        print(error)
                        return
                    }
                }
            }
        }
    }
    
    @objc private func handleCooldown() {
        timer?.invalidate()
        explore()
    }
    
    private func saveData() {
        do {
            let mapData = try NSKeyedArchiver.archivedData(withRootObject: rooms, requiringSecureCoding: false)
            let coordsData = try NSKeyedArchiver.archivedData(withRootObject: coords, requiringSecureCoding: false)
            let stackData = try NSKeyedArchiver.archivedData(withRootObject: stack, requiringSecureCoding: false)
            let pathData = try NSKeyedArchiver.archivedData(withRootObject: traversalPath, requiringSecureCoding: false)
            UserDefaults.standard.set(mapData, forKey: "TreasureMap")
            UserDefaults.standard.set(coordsData, forKey: "TreasureCoords")
            UserDefaults.standard.set(stackData, forKey: "TreasureStack")
            UserDefaults.standard.set(pathData, forKey: "TreasurePath")
        } catch {
            print(error)
            return
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
