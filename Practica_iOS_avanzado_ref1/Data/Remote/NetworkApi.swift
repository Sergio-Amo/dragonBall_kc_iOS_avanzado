//
//  NetworkApi.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation

protocol NetworkApiProtocol {
    func loginWith(user: String, password: String, completion: @escaping (Result<String, NetworkApi.NetworkError>) -> Void )
    /*func getHeroes()
    func getHeroLocations()
    func getAllHeroLocations()*/
    
}

final class NetworkApi: NetworkApiProtocol {
    // MARK: - Constants -
    enum NetworkError: Error {
        case unknown
        case malformedUrl
        case decodingFailed
        case encodingFailed
        case noData
        case statusCode(code: Int?)
        case noToken
    }
    static private let apiBaseURL = "https://dragonball.keepcoding.education/api"
    private enum Endpoint {
        static let login = "/auth/login"
        static let heroes = "/heros/all"
        static let heroLocations = "/heros/locations"
    }
    
    func loginWith(user: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let url = URL(string: "\(NetworkApi.apiBaseURL)\(Endpoint.login)") else {
            completion(.failure(.malformedUrl))
            return
        }
        guard let loginData = String(format: "%@:%@", user, password).data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.decodingFailed))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Basic \(loginData)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(.unknown))
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(.unknown))
                return
            }
            guard let data else {
                completion(.failure(.noData))
                return
            }
            guard statusCode == 200 else {
                completion(.failure(.statusCode(code: statusCode)))
                return
            }
            guard let token = String(data: data, encoding: .utf8) else {
                completion(.failure(.decodingFailed))
                return
            }
            completion(.success(token))
        }.resume()
    }
}
