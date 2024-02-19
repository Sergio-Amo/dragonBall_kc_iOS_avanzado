//
//  FakeVaultApi.swift
//  Practica_iOS_avanzado_ref1Tests
//
//  Created by Sergio Amo on 19/2/24.
//

import Foundation
@testable import Practica_iOS_avanzado_ref1

final class FakeVaultApi: VaultApiProtocol {
    
    private var token = ""
    
    func saveToken(_ token: String) {
        self.token = token
    }
    
    func getToken() -> String? {
        return self.token
    }
    
    func removeToken() {
        self.token = ""
    }
}
