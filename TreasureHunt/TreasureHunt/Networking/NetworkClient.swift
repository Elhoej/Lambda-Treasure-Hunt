//
//  NetworkClient.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation

class NetworkClient {
    
    let baseUrl = URL(string: "https://lambda-treasure-hunt.herokuapp.com/api/adv")
    
    func initializePlayer(completion: @escaping (Response<Room>) -> ()) {
        let url = baseUrl?.appendingPathComponent("init")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Token a490e6cb232780e0f20b473d08450ed4dbde648f", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, res, error) in
            if let error = error {
                NSLog("there was an error: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            if let httpResponse = res as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    NSLog("An error code was returned from the http request: \(httpResponse.statusCode)")
                    completion(Response.error(NSError()))
                    return
                }
            }
            
            do {
                let room = try JSONDecoder().decode(Room.self, from: data)
                completion(.success(room))
            } catch {
                NSLog("Error decoding data: \(error)")
            }
        }.resume()
    }
    
    
    func move(in direction: String, completion: @escaping (Response<Room>) -> ()) {
        let url = baseUrl?.appendingPathComponent("move")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Token a490e6cb232780e0f20b473d08450ed4dbde648f", forHTTPHeaderField: "Authorization")
        
        let direction = ["direction": direction]
        do {
            urlRequest.httpBody = try JSONEncoder().encode(direction)
        } catch {
            completion(Response.error(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, res, error) in
            
            if let error = error {
                NSLog("there was an error: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            if let httpResponse = res as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    NSLog("An error code was returned from the http request: \(httpResponse.statusCode)")
                    completion(Response.error(NSError()))
                    return
                }
            }
           
            do {
                let room = try JSONDecoder().decode(Room.self, from: data)
                completion(.success(room))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(.error(error))
            }
        }.resume()
        
        
    }
}
