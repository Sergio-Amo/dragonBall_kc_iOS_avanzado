//
//  VaultApi.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import KeychainSwift

protocol VaultApiProtocol {
    func saveToken(_ token:String) -> Void
    func getToken() -> String?
    func removeToken()
}

class VaultApi: VaultApiProtocol {
    private let keychain = KeychainSwift()
    private let tokenKey = "LOGIN_TOKEN"
    
    func saveToken(_ token: String) {
        keychain.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        keychain.get(tokenKey)
    }
    
    func removeToken() {
        keychain.delete(tokenKey)
    }
}
