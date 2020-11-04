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

struct LocalLogin: Codable {
    var token: String
}

struct MaesterConstants {
    static let backgroundColor = Color(red: 19.0/255.0, green: 13.0/255.0, blue: 24.0/255.0, opacity: 0.3)
    static let lightBackgroundColor = Color(red: 189.0/255.0, green: 183.0/255.0, blue: 184.0/255.0, opacity: 0.3)
    static let fieldBackground = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    static let lightBlue = Color(red: 19.0/255.0, green: 13.0/255.0, blue: 214.0/255.0, opacity: 0.3)
    static let faceBlue = Color(red: 39.0/255.0, green: 83.0/255.0, blue: 184.0/255.0, opacity: 0.9)
    static let tagBackground = Color(red: 199.0/255.0, green: 213.0/255.0, blue: 244.0/255.0, opacity: 0.3)
    static let tagForeground = Color(red: 39.0/255.0, green: 83.0/255.0, blue: 124.0/255.0, opacity: 0.8)
        
    static let file_start = "maester_data_start.json"
    static let file_end = "maester_data_end.json"
    static let file_actions = "maester_data_actions.json"
    static let app_group = "group.io.devfans.maester"
    static let file_login = "maester_login.json"
    static let local_only = false
    
    static let styles = [
        UIUserInterfaceStyle.light: MaesterStyle (
            fieldColor: Color.black,
            fieldBackgroundColor: MaesterConstants.fieldBackground,
            tintColor: MaesterConstants.faceBlue,
            textColor: Color.black,
            textForegroundColor: Color.white,
            captionColor: Color.gray,
            captionForegroundColor: Color.gray,
            tagBackgroundColor: MaesterConstants.tagBackground,
            tagForegroundColor: MaesterConstants.tagForeground,
            titleColor: MaesterConstants.faceBlue,
            subtitleColor: Color.black,
            launcher: MaesterConstants.faceBlue,
            secondaryButton: Color.black,
            listBackground: Color.white
        ),
        UIUserInterfaceStyle.dark: MaesterStyle (
            fieldColor: Color.white,
            fieldBackgroundColor: Color(red: 29.0/255.0, green: 33.0/255.0, blue: 38.0/255.0, opacity: 0.8),
            tintColor: MaesterConstants.faceBlue,
            textColor: Color.white,
            textForegroundColor: Color.white,
            captionColor: Color.gray,
            captionForegroundColor: Color.gray,
            tagBackgroundColor: Color(red: 60.0/255.0, green: 55.0/255.0, blue: 64.0/255.0, opacity: 0.5),
            tagForegroundColor: Color(red: 109.0/255.0, green: 163.0/255.0, blue: 224.0/255.0, opacity: 1.0),
            titleColor: MaesterConstants.faceBlue,
            subtitleColor: Color.gray,
            launcher: Color(red: 109.0/255.0, green: 163.0/255.0, blue: 224.0/255.0, opacity: 1.0),
            secondaryButton: Color(red: 60.0/255.0, green: 55.0/255.0, blue: 64.0/255.0, opacity: 0.5),
            listBackground: Color.black
        )
    ]
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
    case Login
}

struct Item: Hashable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id: String
    public var page: Page
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(_ id: String, _ page: Page) {
        self.id = id
        self.page = page
    }
}

struct MaesterStyle {
    public let fieldColor: Color
    public let fieldBackgroundColor: Color
    public let tintColor: Color
    public let textColor: Color
    public let textForegroundColor: Color
    public let captionColor: Color
    public let captionForegroundColor: Color
    public let tagBackgroundColor: Color
    public let tagForegroundColor: Color
    public let titleColor: Color
    public let subtitleColor: Color
    public let launcher: Color
    public let secondaryButton: Color
    public let listBackground: Color
}



class MaesterState: ObservableObject {
    @Published var book = MaesterBook.shared
    @Published var entry = MainPage.Main
    @Published var new_page_data = [String: String]()
    @Published var read_page = Page(withLink: "")
    @Published var read_page_id = ""
    @Published var write_page = Page(withLink: "")
    @Published var write_page_type = 0
    @Published var search_type = 3
    @Published var search_keyword = ""
    @Published var search_results = [String]()
    @Published var sync_status = SyncStatus.Login
    @Published var selected_page_id = ""
    @Published var user = "Local"
    @Published var show_new_page = false
    @Published var show_recent_page_detail = false
    @Published var show_search_page_detail = false
    @Published var search_selection: Int? = nil
    
    private var last_style: UIUserInterfaceStyle
    public var style: MaesterStyle
    
    init() {
        last_style = UIScreen.main.traitCollection.userInterfaceStyle
        style = Self.get_style(last_style)
    }
    
    public func update_style () {
        if self.last_style != UIScreen.main.traitCollection.userInterfaceStyle {
            self.last_style = UIScreen.main.traitCollection.userInterfaceStyle
            self.style = Self.get_style(self.last_style)
        }
    }
    
    static func get_style(_ in_style: UIUserInterfaceStyle) -> MaesterStyle {
        if in_style == .light {
            return MaesterConstants.styles[.light]!
        } else {
            return MaesterConstants.styles[.dark]!
        }
    }
    
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
        self.search_results = self.book.search(self.search_keyword, self.search_type)
        self.check_sync()
    }
    
    public func search_for(_ keyword: String) {
        self.search_results = self.book.search(keyword, self.search_type)
        self.search_keyword = keyword
        self.check_sync()
    }
    
    public func login(_ user: String, _ pass: String, handle: @escaping (SyncStatus?) -> Void) {
        self.book.login(user, pass) { res in
            if let status = res, status == .In {
                self.sync_status = .In
            }
            handle(res)
            self.user =  self.book.get_user(user: "Local")
        }
    }
    
    public func logout() {
        self.book.logout()
        self.sync_status = .Login

    }
}

class MaesterBook {
    public static let shared = MaesterBook()
    
    let server = Server.shared
    var entity = StoreEntity()
    var history = [Item]()
    var tags = [String: Int]()
    var categories = [String: Int]()
    var sync_status = SyncStatus.Out
    
    var actions = [PageAction]()
    var actions_cache = [PageAction]()
    
    // var id = [UInt8].init(repeating: 0, count: 32)
    
    var jwt_token: JwtToken? = nil
    private var loaded = false
    
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
    
    public func insert_into_history(id: String, page: Page) {
        self.remove_from_history(id: id)
        self.history.insert(Item(id, page), at: 0)
        
        if self.history.count > 100 {
            _ = self.history.popLast()
        }
    }
    
    public func remove_from_history(id: String) {
        print("Removing from history for \(id)")
        // self.history.removeAll(where: { $0.0 == id })
        self.history.removeAll(where: {$0.id == id })
    }
    
    public func apply_page_index(_ page: Page) {
        if !page.is_valid() {
            return
        }
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
    
    public func apply_action(action: PageAction, queue: Bool = true, cache: Bool = true) -> Bool {
        if case PageAction.Put(let id, let page) = action {
            if !page.is_valid() {
                return false
            }
            
            self.apply_page_index(page)
            
            if queue {
                self.remove_from_history(id: id)
                self.insert_into_history(id: page.gen_id(), page: page)
            }
        } else if case PageAction.Delete(let id) = action {
            self.remove_from_history(id: id)
            
        }
        if queue {
            self.actions.append(action)
            if cache {
                self.actions_cache.append(action)
            }
        }
        self.entity.apply_actions(actions: [action])
        return true
    }
    
    func update_token(_ message: Message) {
        if case Info.Token(let token) = message.info {
            let new_token = JwtToken(in_token: token)
            var switch_profile = false
            if let old_token = self.jwt_token {
                if old_token.id != new_token.id {
                    print("Account changed, archiving profile.")
                    self.save_as_profile(old_token, true)
                    switch_profile = true
                }
            } else {
                print("Adding login token of user \(new_token.user)")
                switch_profile = true
            }
            print("Updating token with data \(token)")
            self.jwt_token = new_token
            
            if switch_profile {
                self.unload()
                print("Loading profile \(new_token.user)")
                let profile = Profile(in_token: new_token)
                self.load_profile(profile)
                profile.save_login()
            }
        }
    }
    
    public func login(_ user: String, _ pass: String, handle: @escaping (SyncStatus?) -> Void) {
        if MaesterConstants.local_only {
            handle(nil)
            return
        }
        var message = Message(in_time: self.entity.time, in_actions: [])
        message.info = Info.Login(user, pass)
        self.server.post(message: message) { res in
            DispatchQueue.main.sync {
                switch res {
                case .success(let resp_message):
                    self.update_token(resp_message)
                    handle(.In)
                case .failure(let error):
                    print("Server post error \(error)")
                    if case Server.ServerError.InvalidCredential = error {
                        handle(.Login)
                    } else {
                        handle(.Out)
                    }
                }
            }
        }
    }
    
    public func logout() {
        print("logging out now")
        if MaesterConstants.local_only {
            return
        }
        
        let current_token = self.jwt_token
        self.jwt_token = nil
        if let token = current_token {
            self.save_as_profile(token)
        }
        
        self.unload()
        self.sync_status = .Login
        let profile = Profile(in_token: nil)
        profile.remove_login()
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
        if let token = self.jwt_token {
            print("Synchronizing...")
            self.last_sync = Date()
            let temp_actions = self.actions
            self.actions.removeAll()
            var message = Message(in_time: self.entity.time, in_actions: temp_actions)
            message.info = Info.Token(token.token)
            self.server.post(message: message) { res in
                DispatchQueue.main.sync {
                switch res {
                    case .success(let resp_message):
                        self.update_token(resp_message)
                        self.apply_update(resp_message, temp_actions)
                        handle(.In)
                    case .failure(let error):
                        self.actions = temp_actions + self.actions
                        print(error)
                        if case Server.ServerError.InvalidCredential = error {
                            handle(.Login)
                        } else {
                            handle(.Out)
                        }
                    }
                }
            }
        } else {
            print("Update canceled for invalid token found!")
            handle(.Login)
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
            /*
            for (id, page)) in self.entity.data {
                self.insert_into_history(id: id, page: page)
            }*/
        } else {
            self.entity.time = message.time
        }
        
        if message.actions.count > 0 {
            self.entity.apply_actions(actions: message.actions)
            for action in message.actions {
                if case PageAction.Put(_, let page) = action {
                    let page_id = page.gen_id()
                    if !self.history.contains(where: {i in i.id == page_id}) {
                        self.insert_into_history(id: page_id, page: page)
                    }
                } else if case PageAction.Delete(let id) = action {
                    self.remove_from_history(id: id)
                }
            }
        }
        /*
        for (k, v) in self.entity.data {
            print("entry: \(k) : \(v.content)")
        }
         */
    }
    
    public func start(_ init_handler: @escaping (SyncStatus) -> Void) {
        if self.loaded {
            return
        } else {
            self.loaded = true
        }
        
        // self.clear_local_data()
        let profile = Profile(in_token: nil)
        profile.prepare()
        
        if profile.load_login() {
            self.jwt_token = profile.jwt_token
            self.load_profile(profile)
            
            init_handler(.On)
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
            
        } else if MaesterConstants.local_only {
            self.jwt_token = nil
            self.load_profile(profile)
        }
    }
    
    public func stop() {
        print("Application is stopping....")
        let group = DispatchGroup()
        group.enter()
        if !MaesterConstants.local_only && self.actions.count > 0 {
            if let token = self.jwt_token {
                print("Synchronizing...")
                self.last_sync = Date()
                let temp_actions = self.actions
                self.actions.removeAll()
                var message = Message(in_time: self.entity.time, in_actions: temp_actions)
                message.info = Info.Token(token.token)
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
                print("Skipped synch on stop for invalid token found!")
                group.leave()
            }
        } else {
            group.leave()
        }
        group.wait()
        self.save_as_profile(self.jwt_token)
    }
    
    private func apply_local_store(store: LocalStore) {
        self.entity = store.entity
        self.history.removeAll()
        for key in store.history {
            if let page = self.entity.data[key] {
                self.insert_into_history(id: key, page: page)
            }
        }
        if store.queue.count > 0 {
            self.entity.apply_actions(actions: store.queue)
            self.actions = store.queue + self.actions
            
        }
    }
    
    private func clear_local_data() {
        let path = self.get_data_root()
        try? FileManager.default.removeItem(atPath: path)
    }
    
    private func get_data_root() -> String {
        let app_dir = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)/data"
        // let app_dir2 = "\(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MaesterConstants.app_group)!.path)/data"
        return app_dir
        
    }
    
    private func unload() {
        print("Clearing current profile")
        self.entity = StoreEntity()
        self.tags = .init()
        self.categories = .init()
        self.actions = []
        self.actions_cache = []
        self.history = []
        self.sync_status = .On
        self.last_sync = Date()
    }
    
    func save_as_profile(_ profile_token: JwtToken?, _ async: Bool = false) {
        let profile = Profile(in_token: profile_token)
        profile.local_store = LocalStore(
            entity: self.entity,
            history: self.history.prefix(50).map {i in i.id}.reversed(),
            queue: self.actions
        )
        
        profile.local_actions = LocalStoreActions(actions: self.actions_cache)
        profile.save()
    }
    
    func load_profile(_ profile: Profile) {
        let res = profile.load_data()
        if res.entity_loaded {
            self.apply_local_store(store: profile.local_store)
            let index = self.entity.gen_index()
            self.tags = index.tags
            self.categories = index.categories
            print("Successfully loaded local entity data")
        } else {
            print("Failed to load local entity")
        }
        
        if res.load_actions {
            if profile.load_actions() {
                for action in profile.local_actions.actions {
                    _ = self.apply_action(action: action, queue: false)
                    if case PageAction.Put(_, let page) = action {
                        self.insert_into_history(id: page.gen_id(), page: page)
                    }
                }
                print("Loaded and applied page actions from local data")
            }
        }
        
        profile.local_store = LocalStore(
            entity: self.entity,
            history: self.history.prefix(50).map { i in i.id }.reversed(),
            queue: self.actions
        )
        
        profile.resave_data()
    }
            
    public func get_user(_ in_token: JwtToken? = nil, user: String = "") -> String {
        if let token = in_token ?? self.jwt_token {
            return token.user
        }
        return user
    }
    
    public func gen_sample() {
        let page = self.gen_sample_page()
        let action = PageAction.Put(page.gen_id(), page)
        _ = self.apply_action(action: action, queue: true, cache: true)
        let page2 = self.gen_sample_page("https://cn.bing.com")
        _ = self.apply_action(action: PageAction.Put(page2.gen_id(), page2), queue: true, cache: true)
    }
    
    public func gen_sample_page(_ link: String = "https://bing.com") -> Page {
        var page = Page(withLink: link)
        page.name = "bing"
        page.category = "search"
        page.tags = ["search"]
        return page
    }
}

class Profile {
    var jwt_token: JwtToken?
    let app_dir: String
    var local_store: LocalStore
    var local_actions: LocalStoreActions
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var login_dir: String {
        get {
            "\(self.app_dir)/\(MaesterConstants.file_login)"
        }
    }
    
    init(in_token: JwtToken?) {
        jwt_token = in_token
        self.app_dir = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)/data"
        local_store = LocalStore ( entity: StoreEntity(), history: [], queue: [] )
        local_actions = LocalStoreActions ( actions: [] )
    }
    
    private func format_file_name(_ file: String, _ in_token: JwtToken? = nil) -> String {
        var user = ""
        let token = in_token == nil ? self.jwt_token : in_token;
        if let login = token, login.id.count > 0 {
            user = "user-\(login.id)."
        }
        return "\(self.app_dir)/\(user)\(file)"
    }
    
    public func save_login() {
        if let token = self.jwt_token {
            let data = try! self.encoder.encode(LocalLogin(
                token: token.token
            ))
            if self.save_file(file: self.login_dir, data: data) {
                print("Successfully saved login for user \(token.user)")
            } else {
                print("Failed to save login locally for user \(token.user)")
            }
        }
    }
    
    public func load_login() -> Bool {
        print("Loading local login")
        if let json_login: LocalLogin = self.load_json(file: self.login_dir) {
            self.jwt_token = JwtToken(in_token: json_login.token)
            print("Successfully loaded local login with account: \(self.jwt_token!.user)")
            return true
        } else {
            print("Didnt find valid local login!")
        }
        return false
    }
    
    public func remove_login() {
        try? FileManager.default.removeItem(atPath: self.login_dir)
    }
    
    public func prepare() {
        self.should_have_dir(dir: self.app_dir)
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
    
    public func save() {
        var user = "Local"
        if let token = self.jwt_token {
            user = token.user
        }
        print("Saving profile for user \(user)")
        self.save_data()
        print("Finished saving profile for user \(user)")
    }
    
    private func save_data() {
        let data = try! self.encoder.encode(self.local_store)
        
        if self.save_file(file: self.format_file_name(MaesterConstants.file_end), data: data) {
            print("Successfully saved end data")
        } else {
            print("Failed to save end data")
        }
        
        self.save_actions()
    }
    
    private func save_actions () {
        let data = try! self.encoder.encode(self.local_actions)
        
        if self.save_file(file: self.format_file_name(MaesterConstants.file_actions), data: data) {
            print("Successfully saved actions data")
        } else {
            print("Failed to save actions data")
        }
    }
    
    public func load_data() -> (entity_loaded: Bool, load_actions: Bool){
        // Cases
        // 1: Load file_end data
        // 2: 1 fail: Load file_start data and try re-apply actions data
        // 3: 1 and 2 fail: try re-apply actions data only
        
        if let json_end: LocalStore = self.load_json(file: self.format_file_name(MaesterConstants.file_end)) {
            self.local_store = json_end
            return (true, false)
        }
        
        if let json_start: LocalStore = self.load_json(file: self.format_file_name(MaesterConstants.file_start)) {
            self.local_store = json_start
            return (true, true)
        }
        
        return (false, true)
    }
    
    public func load_actions() -> Bool {
        if let json_actions: LocalStoreActions = self.load_json(file: self.format_file_name(MaesterConstants.file_actions)) {
            self.local_actions = json_actions
            return true
        }
        return false
    }
    
    public func resave_data() {
        // Re save file_start
        let data = try! self.encoder.encode(self.local_store)
        if self.save_file(file: self.format_file_name(MaesterConstants.file_start), data: data) {
            print("Successfully saved start data")
        } else {
            print("Failed to save start data")
        }
    }
    
    private func load_json<T: Codable>(file: String) -> T? {
        // print("Reading json file \(file)")
        if let data = self.load_file(file: file) {
            if let json = try? self.decoder.decode(T.self, from: data) {
                return json
            }
        }
        return nil
    }
}
