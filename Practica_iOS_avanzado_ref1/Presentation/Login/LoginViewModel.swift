//
//  LoginViewModel.swift
//  Practica_iOSAvanzado
//
//  Created by Sergio Amo on 25/10/23.
//

import Foundation

final class LoginViewModel: LoginViewControllerDelegate {
    // MARK: - Dependencies -
    private let networkApi: NetworkApiProtocol

    // MARK: - Properties -
    var viewState: ((LoginViewState) -> Void)?
    var heroesViewModel: HeroesViewControllerDelegate {
        HeroesViewModel(networkApi: networkApi)
    }

    // MARK: - Initializers -
    init(networkApi: NetworkApiProtocol) {
        self.networkApi = networkApi
    }
    
    // MARK: - Public functions -
    func onLoginPressed(email: String?, password: String?) {
        viewState?(.loading(true))
        
        DispatchQueue.global().async {
            guard let email else { return }
            guard let password else { return }
            var validated = true
            if !self.isValid(email: email) {
                self.viewState?(.loading(false))
                self.viewState?(.showErrorEmail("Introduzca un email válido"))
                validated = false
            }
            if !self.isValid(password: password) {
                self.viewState?(.loading(false))
                self.viewState?(.showErrorPassword("La contraseña no es válida"))
                validated = false
            }
            
            if !validated { return }
            
            self.doLoginWith(
                email: email,
                password: password
            )
        }
    }

    // MARK: - Private functions -
    func isValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    func isValid(password: String) -> Bool {
        password.isEmpty == false && password.count >= 4
    }

    private func doLoginWith(email: String, password: String) {
        networkApi.loginWith(user: email, password: password) { [weak self] result in
            switch result {
                case .success(_):
                    // Login succesful and token saved inside the vault.
                    self?.viewState?(.navigateToNext)
                case let .failure(error):
                    // Remove isLoading
                    self?.viewState?(.loading(false))
                    // Get statusCode
                    guard case let .statusCode(statusCode) = error,
                          let statusCode else {
                        return
                    }
                    // Show toast with error
                    self?.viewState?(.showToast((
                        image: "exclamationmark.circle",
                        text: "Error \(statusCode): No se ha podido completar la operación")
                    ))
                    
                    // TODO: move this to the splash and add popup for errors
                    /* if statusCode == 401 || statusCode == 403 {
                     self?.vaultApi.removeToken()
                     }*/
            }
        }
    }
}
