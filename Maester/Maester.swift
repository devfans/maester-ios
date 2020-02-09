//
//  Maester.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/4.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import Foundation

enum MainPage: Int {
    case Main
    case AddPage
    case PageDetail
    case EditPage
}

enum SearchType: String {
    case Category
    case Tag
    case Keyword
}

class MaesterState: ObservableObject {
    @Published var book = MaesterBook.shared
    @Published var entry = MainPage.Main
    @Published var new_page_data = [String: String]()
    @Published var read_page = Page(withLink: "")
    @Published var read_page_id = ""
    @Published var write_page = Page(withLink: "")
    @Published var search_type = SearchType.Keyword
    @Published var search_keyword = ""
}

class MaesterBook {
    public static let shared = MaesterBook()
    
    let server = Server.shared
    var entity = StoreEntity()
    var history = [String]()
    var tags = [String: Int]()
    var categories = [String: Int]()
    
    var actions = [PageAction]()
    
    var id = [UInt8].init(repeating: 0, count: 32)
    
    public func has_page(id: String) -> Bool {
        return self.entity.data.keys.contains(id)
    }
    
    init() {
        self.update(true)
        
    }
    
    public func search(_ keyword: String, _ search_type: SearchType) -> [String] {
        switch search_type {
        case .Category:
            return Array(self.search_by_category(keyword).keys)
        case .Tag:
            return Array(self.search_by_tag(keyword).keys)
        case .Keyword:
            return Array(self.search_by_name(keyword).keys)
        }
    }
    
    public func search_by_tag(_ in_tag: String) -> [String: Page] {
        return self.entity.data.filter { id, page in
            page.tags.contains(in_tag)
        }
    }
    
    public func search_by_category(_ in_category: String) -> [String: Page] {
        return self.entity.data.filter { id, page in
            page.category == in_category
        }
    }
    
    public func search_by_name(_ in_name: String) -> [String: Page] {
        return self.entity.data.filter { id, page in
            page.name.contains(in_name)
        }
    }
    
    public func get_page(id: String) -> Page {
        if let page = self.entity.data[id] {
            return page
        }
        return Page(withLink: "")
    }
    
    public static func suggest(index: [String: Int], value: String) -> [String]  {
        if value.count < 1 {
            return [String]()
        }
        let v = value.lowercased()
        var suggestions = index.keys.filter { key in
            key.lowercased().contains(v)
        }
        suggestions.sort()
        return Array(suggestions.prefix(3))
    }
    
    public func append_history(id: String) {
        if let index = self.history.firstIndex(of: id) {
            self.history.remove(at: index)
        }
        self.history.insert(id, at: 0)
        if self.history.count > 100 {
            _ = self.history.popLast()
        }
    }
    
    public func apply_action(action: PageAction, queue: Bool = true) -> Bool {
        var id: String?
        if case PageAction.Put(_, let page) = action {
            if !page.is_valid() {
                return false
            }
            id = page.gen_id()
            if self.categories.keys.contains(page.category) {
                self.categories[page.category]! += 1
            } else {
                self.categories[page.category] = 1
            }
            
            for tag in page.tags {
                if self.tags.keys.contains(tag)  {
                    self.tags[tag]! += 1
                } else {
                    self.tags[tag] = 1
                }
            }
        }
        if queue {
            self.actions.append(action)
            if let page_id = id {
                self.append_history(id: page_id)
            }
        }
        self.entity.apply_actions(actions: [action])
        return true
    }
    
    public func update(_ force: Bool = false) {
        if !force && self.actions.count == 0 {
            return
        }
        let temp_actions = self.actions
        self.actions.removeAll()
        var message = Message(in_time: self.entity.time, in_actions: temp_actions)
        message.info = Info.Token(self.id)
        self.server.post(message: message) { res in
            switch res {
            case .success(let resp_message):
                self.apply_update(resp_message, temp_actions)
            case .failure(let error):
                self.actions = temp_actions + self.actions
                print(error)
            }
        }
    }
    
    func apply_update(_ message: Message, _ actions: [PageAction]) {
        // Update token
        // Check entity
        // Apply actions
        if case let StoreData.Data(entity) = message.body {
            self.entity = entity
            let index = self.entity.gen_index()
            self.tags = index.tags
            self.categories = index.categories
            for action in actions {
                _ = self.apply_action(action: action, queue: false)
            }
            // For debug
            for id in self.entity.data.keys {
                self.append_history(id: id)
            }
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
