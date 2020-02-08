//
//  Maester.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/4.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import Foundation

class MaesterState: ObservableObject {
    @Published var state = Maester.shared
    @Published var new_page = false
    @Published var new_page_data = [String: String]()
}

class Maester {
    public static let shared = Maester()
    
    let server = Server.shared
    var entity = StoreEntity()
    var history: Set<String> = []
    var tags: Set<String> = []
    var categorys: Set<String> = []
    
    var actions = [PageAction]()
    
    var id = [UInt8].init(repeating: 0, count: 32)
    
    public func apply_action(action: PageAction) {
        self.actions.append(action)
        self.entity.apply_actions(actions: [action])
    }
    
    public func update(_ force: Bool = false) {
        if !force && self.actions.count == 0 {
            return
        }
        var message = Message(in_time: self.entity.time, in_actions: self.actions)
        message.info = Info.Token(self.id)
        self.server.post(message: message) { res in
            switch res {
            case .success(let resp_message):
                self.apply_update(resp_message)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func apply_update(_ message: Message) {
        // Update token
        // Check entity
        // Apply actions
        if case let StoreData.Data(entity) = message.body {
            self.entity = entity
        } else {
            self.entity.time = message.time
        }
        
        if message.actions.count > 0 {
            self.entity.apply_actions(actions: message.actions)
        }
        
        for (k, v) in self.entity.data {
            print("entry: \(k) : \(v.content)")
        }
    }
}
