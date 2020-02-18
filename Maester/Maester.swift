//
//  Maester.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/4.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import Foundation
import SwiftUI


struct LocalStore: Codable {
    var entity: StoreEntity
    var history: [String]
    var queue: [PageAction]
}

struct LocalStoreActions: Codable {
    var actions: [PageAction]
}

struct MaesterConstants {
    static let backgroundColor = Color(red: 19.0/255.0, green: 13.0/255.0, blue: 24.0/255.0, opacity: 0.3)
    static let lightBackgroundColor = Color(red: 189.0/255.0, green: 183.0/255.0, blue: 184.0/255.0, opacity: 0.3)
        
    static let file_start = "maester_data_start.json"
    static let file_end = "maester_data_end.json"
    static let file_actions = "maester_data_actions.json"
    static let app_group = "group.io.devfans.maester"
    static let local_only = false
}

enum MainPage: Int {
    case Main
    case AddPage
    case PageDetail
    case EditPage
}


enum SearchType: Int {
    case Keyword = 0
    case Category = 1
    case Tag = 2
    case Name = 3
    case Content = 4
}

enum SyncStatus: String {
    case In
    case Out
    case On
}

class MaesterState: ObservableObject {
    @Published var book = MaesterBook.shared
    @Published var entry = MainPage.Main
    @Published var new_page_data = [String: String]()
    @Published var read_page = Page(withLink: "")
    @Published var read_page_id = ""
    @Published var write_page = Page(withLink: "")
    @Published var search_type = 3
    @Published var search_keyword = ""
    @Published var search_ressults = [String]()
    @Published var sync_status = SyncStatus.On
    @Published var selected_page_id = ""
    
    public func sync(force: Bool = false) {
        let before = self.sync_status
        self.sync_status = .On
        self.book.update(force) { status in
            if let after = status {
                self.sync_status = after
            } else {
                self.sync_status = before
            }
            
        }
    }
    
    public func check_sync() {
        if Date().addingTimeInterval(-10) > self.book.last_sync {
            self.sync()
        }
    }
    
    public func search() {
        self.search_ressults = self.book.search(self.search_keyword, self.search_type)
        self.check_sync()
    }
}

class MaesterBook {
    public static let shared = MaesterBook()
    
    let server = Server.shared
    var entity = StoreEntity()
    var history = [String]()
    var tags = [String: Int]()
    var categories = [String: Int]()
    var sync_status = SyncStatus.Out
    
    var actions = [PageAction]()
    var actions_cache = [PageAction]()
    
    var id = [UInt8].init(repeating: 0, count: 32)
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    public var last_sync = Date()
    
    public func has_page(id: String) -> Bool {
        return self.entity.data.keys.contains(id)
    }
    
    init() {
        // self.update(true)
    }
    
    public func search(_ in_keyword: String, _ raw_search_type: Int) -> [String] {
        guard let search_type = SearchType(rawValue: raw_search_type) else {
            return [String]()
        }
        
        let keyword = in_keyword.lowercased()
        switch search_type {
        case .Category:
            return Array(self.entity.data.filter { id, page in page.category.lowercased() == keyword}.keys)
        case .Tag:
            return Array(self.entity.data.filter { id, page in page.tags.map{tag in tag.lowercased()}.contains(keyword)} .keys)
        case .Name:
            return Array(self.entity.data.filter { id, page in page.name.lowercased().contains(keyword)}.keys)
        case .Content:
            return Array(self.entity.data.filter { id, page in page.content.lowercased().contains(keyword)}.keys)
        case .Keyword:
            return Array(self.entity.data.filter { id, page in
                page.category.lowercased().contains(keyword) ||
                    page.content.lowercased().contains(keyword) ||
                    page.name.lowercased().contains(keyword) ||
                    page.tags.map{tag in tag.lowercased()}.contains(keyword) ||
                    page.content.lowercased().contains(keyword)
            }.keys)
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
            return Array(index.keys.prefix(3))
        }
        let v = value.lowercased()
        var suggestions = index.keys.filter { key in
            key.lowercased().contains(v)
        }
        if suggestions.count == 0 {
            suggestions = Array(index.keys.prefix(3))
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
    
    public func apply_action(action: PageAction, queue: Bool = true, cache: Bool = true) -> Bool {
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
            if cache {
                self.actions_cache.append(action)
            }
        }
        self.entity.apply_actions(actions: [action])
        return true
    }
    
    public func update(_ force: Bool = false, handle: @escaping (SyncStatus?) -> Void) {
        if MaesterConstants.local_only {
            handle(nil)
            return
        }
        /*
        if !force && self.actions.count == 0 {
            handle(nil)
            return
        }*/
        print("Synchronizing...")
        self.last_sync = Date()
        let temp_actions = self.actions
        self.actions.removeAll()
        var message = Message(in_time: self.entity.time, in_actions: temp_actions)
        message.info = Info.Token(self.id)
        self.server.post(message: message) { res in
            DispatchQueue.main.sync {
            switch res {
                case .success(let resp_message):
                    self.apply_update(resp_message, temp_actions)
                    handle(.In)
                case .failure(let error):
                    self.actions = temp_actions + self.actions
                    print(error)
                    handle(.Out)
                }
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
                _ = self.apply_action(action: action, queue: false, cache: false)
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
    
    public func start(_ init_handler: @escaping (SyncStatus) -> Void) {
        // self.clear_local_data()
        self.load_data(init_handler)
    }
    
    public func stop() {
        print("Application is stopping....")
        let group = DispatchGroup()
        group.enter()
        if !MaesterConstants.local_only && self.actions.count > 0 {
            print("Synchronizing...")
            self.last_sync = Date()
            let temp_actions = self.actions
            self.actions.removeAll()
            var message = Message(in_time: self.entity.time, in_actions: temp_actions)
            message.info = Info.Token(self.id)
            self.server.post(message: message) { res in
                switch res {
                    case .success(let resp_message):
                        self.apply_update(resp_message, temp_actions)
                        print("Successfully graceful shutdown!")
                    case .failure(let error):
                        self.actions = temp_actions + self.actions
                        print(error)
                        print("Failed graceful shutdown!")
                }
                group.leave()
            }
        } else {
            group.leave()
        }
        group.wait()
        self.save_data()
    }
    
    private func apply_local_store(store: LocalStore) {
        self.entity = store.entity
        self.history = store.history
        if store.queue.count > 0 {
            self.entity.apply_actions(actions: store.queue)
            self.actions = store.queue + self.actions
            
        }
    }
    
    private func load_data(_ init_handler: @escaping (SyncStatus) -> Void) {
        let path = self.get_data_root()
        self.should_have_dir(dir: path)
        // Cases
        // 1: Load file_end data
        // 2: 1 fail: Load file_start data and try re-apply actions data
        // 3: 1 and 2 fail: try re-apply actions data only
        var entity_loaded = false
        var load_actions = false
        if let json_end: LocalStore = self.load_json(file: "\(path)/\(MaesterConstants.file_end)") {
            self.apply_local_store(store: json_end)
            entity_loaded = true
        } else {
            if let json_start: LocalStore = self.load_json(file: "\(path)/\(MaesterConstants.file_start)") {
                self.apply_local_store(store: json_start)
                entity_loaded = true
            }
            load_actions = true
        }
        
        if entity_loaded {
            let index = self.entity.gen_index()
            self.tags = index.tags
            self.categories = index.categories
            print("Successfully loaded local entity data")
        } else {
            print("Failed to load local entity")
        }
        
        if load_actions {
            if let json_actions: LocalStoreActions = self.load_json(file: "\(path)/\(MaesterConstants.file_actions)") {
                for action in json_actions.actions {
                    _ = self.apply_action(action: action, queue: false)
                    if case PageAction.Put(_, let page) = action {
                        self.append_history(id: page.gen_id())
                    }
                }
                print("Loaded and applied page actions from local data")
            }
        }
        
        // Re save file_start
        let data = try! self.encoder.encode(LocalStore(
            entity: self.entity,
            history: Array(self.history.prefix(50)),
            queue: self.actions
        ))
        if self.save_file(file: "\(path)/\(MaesterConstants.file_start)", data: data) {
            print("Successfully saved start data")
        } else {
            print("Failed to save start data")
        }
        
        self.update(true) { res in
            if let status = res, status == .In {
                print("Successfully synced for initial state")
                self.sync_status = .In
            } else {
                print("Failed to sync for initial state")
                self.sync_status = .Out
            }
            init_handler(self.sync_status)
        }
    }
    
    private func load_json<T: Codable>(file: String) -> T? {
        if let data = self.load_file(file: file) {
            if let json = try? self.decoder.decode(T.self, from: data) {
                return json
            }
        }
        return nil
    }
    
    private func save_data() {
        // Save file_end
        let path = self.get_data_root()
        self.should_have_dir(dir: path)
        
        let data = try! self.encoder.encode(LocalStore(
            entity: self.entity,
            history: Array(self.history.prefix(50)),
            queue: self.actions
        ))
        
        if self.save_file(file: "\(path)/\(MaesterConstants.file_end)", data: data) {
            print("Successfully saved end data")
        } else {
            print("Failed to save end data")
        }
        
        self.save_actions()
    }
    
    private func save_actions () {
        let path = self.get_data_root()
        self.should_have_dir(dir: path)
        // Save actions file
        
        let data = try! self.encoder.encode(LocalStoreActions(
            actions: self.actions_cache
        ))
        if self.save_file(file: "\(path)/\(MaesterConstants.file_actions)", data: data) {
            print("Successfully saved actions data")
        } else {
            print("Failed to save actions data")
        }
    }
    
    private func clear_local_data() {
        let path = self.get_data_root()
        try? FileManager.default.removeItem(atPath: path)
    }
    
    private func should_have_dir(dir: String) {
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func load_file(file: String) -> Data? {
        return FileManager.default.contents(atPath: file)
    }
    
    private func delete_file(file: String) {
        try? FileManager.default.removeItem(atPath: file)
    }
    
    private func save_file(file: String, data: Data) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: file))
            return true
        } catch {
            print("Failed to save file with data to path: \(file)")
        }
        return false
    }
    
    private func get_data_root() -> String {
        let app_dir = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)/data"
        // let app_dir2 = "\(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MaesterConstants.app_group)!.path)/data"
        return app_dir
        
    }
}

/*

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
*/
