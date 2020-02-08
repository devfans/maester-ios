//
//  Http.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/4.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import Foundation


class Server {
    public static let shared = Server()
    private let url = URL(string: "http://127.0.0.1:2000")!
    private let id = [UInt8].init(repeating: 0, count: 32)
    
    init() {
    }
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    public enum ServerError: Error {
        case InvalidRequest
        case InvalidCredential
        case InternalServerError
        case NetworkError
        case CodingError
    }
    
    public func post(message: Message, completion: @escaping (Result<Message, ServerError>) -> Void) {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let request_body = try! self.encoder.encode(message)
        print(String.init(data: request_body, encoding: String.Encoding.utf8)!)
        self.session.uploadTask(with: request, from: request_body) { data, response, error in
            if let _ = error {
                completion(.failure(ServerError.NetworkError))
                return
            }
            
            guard let response = response else {
                completion(.failure(ServerError.NetworkError))
                return
            }
            guard let status_code = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(ServerError.NetworkError))
                return
            }
            
            switch status_code {
            case 400:
                completion(.failure(ServerError.InvalidRequest))
                return
            case 403:
                completion(.failure(ServerError.InvalidCredential))
                return
            default:
                if status_code != 200 {
                    completion(.failure(ServerError.InternalServerError))
                    return
                }
            }
            guard let data = data else {
                completion(.failure(ServerError.NetworkError))
                return
            }
            do {
                let resp_message = try self.decoder.decode(Message.self, from: data)
                completion(.success(resp_message))
            } catch {
                print(error)
                completion(.failure(ServerError.CodingError))
            }
        }.resume()
    }
}
