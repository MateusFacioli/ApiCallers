//
//  Services.swift
//  Apis
//
//  Created by Mateus Rodrigues on 13/07/22.
//

import Foundation

struct Address: Codable {
    let zipcode: String
    let address: String
    let city: String
    let uf: String
    let complement: String?
    
    enum CodingKeys: String, CodingKey  {
        case zipcode = "cep"
        case address = "logradouro"
        case city = "localidade"
        case uf
        case complement = "complemento"
    }
}

enum ServiceError: Error {
    case invalidURL
    case invalidCep(String)
    case networkError(Error?)
    case decodeFail(Error?)
}

class Service {
    //MARK: API 1
    private let baseURL = "https://viacep.com.br/ws"
    
    fileprivate func task(_ url: URL, _ callback: @escaping (Result<Any, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                callback(.failure(ServiceError.networkError(error)))
                return
            }
            
            do {
                let JSON = try JSONDecoder().decode(Address.self, from: data)
                callback(.success(JSON))
            } catch  {
                callback(.failure(ServiceError.decodeFail(error)))
            }
            
        }
        task.resume()
    }
    
    func get(cep: String, callback: @escaping (Result<Any, Error>) -> Void) {
        
        if cep.isEmpty || cep.count != 8 {
            callback(.failure(ServiceError.invalidCep("invalido")))
        }
        
        let path = "/\(cep)/json"
        
        guard let url = URL(string: baseURL + path) else {
            callback(.failure(ServiceError.invalidURL))
            return
        }
        
        task(url, callback)
    }
    
    //MARK: API 2
    func makePostRequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        print("Making api call...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable]
        = [
            "userId": 1,
            "title": "heloo",
            "body": "henlo, henlo"
         ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
//                let response = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let response = try  JSONDecoder().decode( Response.self, from: data)
                print("SUCCESS \(response)")
            } catch  {
                print(error)
            }
        }
        task.resume()
    }
    
}

struct Response: Codable {
    let body: String
    let id: Int
    let title: String
    let userId: Int
}

//MARK: generic api call
struct Constants {
    static let usersUrl = URL(string: "https://jsonplaceholder.typicode.com/users")
    static let todoUrl = URL(string: "https://jsonplaceholder.typicode.com/todos")
}

extension URLSession {
    func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        
        let task = dataTask(with: url) { data, _, error in
            
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(ServiceError.networkError(error)))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch  {
                completion(.failure(ServiceError.decodeFail(error)))
            }
            
        }
        task.resume()
    }
}
 
