//
//  FakeNetworkApi.swift
//  Practica_iOS_avanzado_ref1Tests
//
//  Created by Sergio Amo on 19/2/24.
//

import Foundation
import XCTest

@testable import Practica_iOS_avanzado_ref1

final class FakeNetworkApiSuccess: NetworkApiProtocol {
    
    let mocks = Mocks()
    
    required init(vaultApi: Practica_iOS_avanzado_ref1.VaultApiProtocol){}
    
    func loginWith(user: String, password: String, completion: @escaping (Result<String, Practica_iOS_avanzado_ref1.NetworkApi.NetworkError>) -> Void) {
        completion(.success("TOKEN"))
    }
    
    func getHeroes(_ heroName: String?, completion: @escaping (Result<Practica_iOS_avanzado_ref1.Heroes, Practica_iOS_avanzado_ref1.NetworkApi.NetworkError>) -> Void) {
        completion(.success(mocks.getMockHeroes()))
    }
    
    func getHeroLocations(id: String?, completion: @escaping (Result<Practica_iOS_avanzado_ref1.HeroLocations, Practica_iOS_avanzado_ref1.NetworkApi.NetworkError>) -> Void) {
        completion(.success(mocks.getMockLocations()))
    }
}

final class FakeNetworkApiFailure: NetworkApiProtocol {
    
    let mocks = Mocks()
    
    required init(vaultApi: Practica_iOS_avanzado_ref1.VaultApiProtocol){}
    
    func loginWith(user: String, password: String, completion: @escaping (Result<String, Practica_iOS_avanzado_ref1.NetworkApi.NetworkError>) -> Void) {
        completion(.failure(.statusCode(code: 404)))
    }
    
    func getHeroes(_ heroName: String?, completion: @escaping (Result<Practica_iOS_avanzado_ref1.Heroes, Practica_iOS_avanzado_ref1.NetworkApi.NetworkError>) -> Void) {
        completion(.failure(.statusCode(code: 404)))
    }
    
    func getHeroLocations(id: String?, completion: @escaping (Result<Practica_iOS_avanzado_ref1.HeroLocations, Practica_iOS_avanzado_ref1.NetworkApi.NetworkError>) -> Void) {
        completion(.failure(.statusCode(code: 404)))
    }
}
