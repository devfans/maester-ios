//
//  StoreEntity.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/4.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

public func sha256_str(str: String) -> String {
    let data = Data(str.utf8)
    let hashed = SHA256.hash(data: data)
    return hashed.compactMap { String(format: "%02X", $0)}.joined()
}

enum PageType: String, Codable {
    case Link
    case Note
}

struct Page: Codable {
    var content: String
    var name: String
    var page_type: PageType
    var category: String
    var tags: [String]
    var time: UInt32
    
    public func gen_id() -> String {
        var id = ""
        switch self.page_type {
        case .Link:
            id = sha256_str(str: "Maester|\(self.content)|Link")
        case .Note:
            id = sha256_str(str: "Maester|\(self.name)|Note")
        }
        return id
    }
    
    init(withLink url: String) {
        content = url
        name = ""
        page_type = PageType.Link
        category = ""
        tags = [String]()
        time = 0
    }
    
    public func is_valid() -> Bool {
        switch self.page_type {
        default:
            if self.content.count > 0 && self.category.count > 0 && self.name.count > 0 {
                return true
            }
        }
        return false
    }
}

struct PageIDAction: Codable {
    var id: String
    var page: Page
}

enum PageAction {
    case Put(String, Page)
    case Delete(String)
    case Refresh
}


enum CodingError: Error {
    case Decode(String)
    case Encode(String)
}


extension PageAction: Codable {
    enum CodingKeys: CodingKey {
        case Put
        case Delete
        case Refresh
    }
    
    enum PutCodingKeys: CodingKey {
        case id
        case page
    }
    
    enum DeleteCodingKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .Put(let id, let page):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var sub = container.nestedContainer(keyedBy: PutCodingKeys.self, forKey: CodingKeys.Put)
            try sub.encode(id, forKey: .id)
            try sub.encode(page, forKey: .page)
        case .Delete(let id):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var sub = container.nestedContainer(keyedBy: DeleteCodingKeys.self, forKey: CodingKeys.Delete)
            try sub.encode(id, forKey: .id)
        case .Refresh:
            var sub = encoder.singleValueContainer()
            try sub.encode("Null")
        }
    }
    
    init(from decoder: Decoder) throws {
        if let sub = try? decoder.singleValueContainer() {
            if let value = try? sub.decode(String.self) {
                if value == "Refresh" {
                    self = .Refresh
                    return
                }
            }
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            throw CodingError.Decode("Invalid data for PageAction")
        }
        switch container.allKeys.first {
        case .Put:
            if let sub = try? container.nestedContainer(keyedBy: PutCodingKeys.self, forKey: .Put) {
                self = .Put(
                    try sub.decode(String.self, forKey: .id),
                    try sub.decode(Page.self, forKey: .page)
                )
                return
            }
        case .Delete:
            if let sub = try? container.nestedContainer(keyedBy: DeleteCodingKeys.self, forKey: .Delete) {
                self = .Delete(try sub.decode(String.self, forKey: .id))
                return
            }
        default:
            throw CodingError.Decode("Invalid PageAction Key")
        }
        throw CodingError.Decode("Invalid PageAction Key")

    }
}

struct StoreEntity: Codable {
    var time: UInt32
    var data = [String: Page]()
    init() {
        time = 0
        data = [String: Page]()
    }
    
    init(in_time: UInt32) {
        time = in_time
    }
    
    public func gen_index() -> (tags: [String: Int], categories: [String: Int]) {
        var tags = [String: Int]()
        var cates = [String: Int]()
        for page in data.values {
            for tag in page.tags {
                if tags.keys.contains(tag) {
                    tags[tag]! += 1
                } else {
                    tags[tag] = 1
                }
            }
            if cates.keys.contains(page.category) {
                cates[page.category]! += 1
            } else {
                cates[page.category] =  0
            }
        }
        return (tags, cates)
    }
    
    public mutating func apply_actions(actions: [PageAction]) {
        for action in actions {
            switch action {
            case .Put(let id, let page):
                let page_id = page.gen_id()
                if id.count > 0 && id != page_id {
                    self.data.removeValue(forKey: id)
                }
                self.data[page_id] = page
            case .Delete(let id):
                self.data.removeValue(forKey: id)
            default:
                continue
            }
        }
    }
}

enum Info {
    case Token(String)
    case Login(String, String)
    case Null
}


extension Info: Codable {
    enum CodingKeys: CodingKey {
        case Token
        case Login
        case Null
    }
    
    enum TokenCodingKeys: CodingKey {
        case token
    }
    
    enum LoginCodingKeys: CodingKey  {
        case user
        case pass
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .Token(let token):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var sub = container.nestedContainer(keyedBy: TokenCodingKeys.self, forKey: .Token)
            try sub.encode(token, forKey: .token)
        case .Login(let user, let pass):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var sub = container.nestedContainer(keyedBy: LoginCodingKeys.self, forKey: .Login)
            try sub.encode(user, forKey: .user)
            try sub.encode(pass, forKey: .pass)
        case .Null:
            var sub = encoder.singleValueContainer()
            try sub.encode("Null")
        }
    }
    
    init(from decoder: Decoder) throws {
        if let sub = try? decoder.singleValueContainer() {
            if let value = try? sub.decode(String.self) {
                if value == "Null" {
                    self = .Null
                    return
                }
            }
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            throw CodingError.Decode("Invalid data for Info")
        }
        switch container.allKeys.first {
        case .Token:
            if let sub = try? container.nestedContainer(keyedBy: TokenCodingKeys.self, forKey: .Token) {
                self = .Token(
                    try sub.decode(String.self, forKey: .token)
                )
                return
            }
        case .Login:
            if let sub = try? container.nestedContainer(keyedBy: LoginCodingKeys.self, forKey: .Login) {
                self = .Login(
                    try sub.decode(String.self, forKey: .user),
                    try sub.decode(String.self, forKey: .pass)
                )
                return
            }
        default:
            throw CodingError.Decode("Invalid Info Key")
        }
        throw CodingError.Decode("Invalid Info Key")
        
    }
}

enum StoreData {
    case Data(StoreEntity)
    case Null
}

extension StoreData: Codable {
    enum CodingKeys: CodingKey {
        case Data
        case Null
    }
    
    enum DataCodingKeys: CodingKey {
        case entity
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .Data(let entity):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var sub = container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .Data)
            try sub.encode(entity, forKey: .entity)
        case .Null:
            var sub = encoder.singleValueContainer()
            try sub.encode("Null")
        }
    }
    
    init(from decoder: Decoder) throws {
        if let sub = try? decoder.singleValueContainer() {
            if let value = try? sub.decode(String.self) {
                if value == "Null" {
                    self = .Null
                    return
                }
            }
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            throw CodingError.Decode("Invalid data for StoreData")
        }
        switch container.allKeys.first {
        case .Data:
            if let sub = try? container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .Data) {
                self = .Data(
                    try sub.decode(StoreEntity.self, forKey: .entity)
                )
                return
            }
        default:
            throw CodingError.Decode("Invalid StoreData Key")
        }
        throw CodingError.Decode("Invalid StoreData Key")
    }
}

struct Message: Codable {
    var time: UInt32
    var actions: [PageAction]
    var info: Info
    var body: StoreData
    
    init(in_time: UInt32, in_actions: [PageAction]) {
        time = in_time
        actions = in_actions
        info = Info.Null
        body = StoreData.Null
    }
}

struct JwtToken {
    var token: String
    var user: String = ""
    var id: String = ""
    
    init(in_token: String) {
        token = in_token
        let strs = token.split(separator: ".")
        if (strs.count == 3) {
            let body = String(strs[1])
            let padded_body = body.padding(toLength: ((body.count+3)/4)*4, withPad: "=", startingAt: 0)
            if let data = Data(base64Encoded: padded_body) {
                let obj = try? JSONSerialization.jsonObject(with: data, options: [])
                if let dict = obj as? [String: Any] {
                    if let user_name = dict["usr"] as? String {
                        user = user_name
                        id = sha256_str(str: user)
                    }
                }
            }
        }
        
    }
}
