//
//  SplashViewModel.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation

final class SplashViewModel: SplashViewControllerDelegate {
    // MARK: - Dependencies -
    private let networkApi: NetworkApiProtocol
    private let vaultApi: VaultApiProtocol

    // MARK: - Properties -
    var viewState: ((SplashViewState) -> Void)?

    lazy var loginViewModel: LoginViewControllerDelegate = {
        LoginViewModel(networkApi: networkApi)
    }()

    lazy var heroesViewModel: HeroesViewControllerDelegate = {
        HeroesViewModel(networkApi: networkApi)
    }()

    private var tokenExists: Bool {
        vaultApi.getToken()?.isEmpty == false
    }

    // MARK: - Initializers -
    init(networkApi: NetworkApiProtocol, vaultApi: VaultApiProtocol) {
        self.networkApi = networkApi
        self.vaultApi = vaultApi
    }
    
    // MARK: - Public functions -
    func onViewAppear() {
        viewState?(.loading(true))
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.tokenExists == true ? self?.viewState?(.navigateToHeroes) : self?.viewState?(.navigateToLogin)
        }
    }
}
