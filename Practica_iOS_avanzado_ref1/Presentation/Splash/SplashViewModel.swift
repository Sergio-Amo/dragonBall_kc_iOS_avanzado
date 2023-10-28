//
//  SplashViewModel.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation

class SplashViewModel: SplashViewControllerDelegate {
    private let networkApi: NetworkApiProtocol
    private let vaultApi: VaultApiProtocol

    var viewState: ((SplashViewState) -> Void)?

    lazy var loginViewModel: LoginViewControllerDelegate = {
        LoginViewModel(
            networkApi: networkApi,
            vaultApi: vaultApi
        )
    }()

    /*lazy var heroesViewModel: HeroesViewControllerDelegate = {
        HeroesViewModel(
            networkApi: networkApi,
            vaultApi: vaultApi
        )
    }()*/

    private var tokenExists: Bool {
        vaultApi.getToken()?.isEmpty == false
    }


    init(networkApi: NetworkApiProtocol, vaultApi: VaultApiProtocol) {
        self.networkApi = networkApi
        self.vaultApi = vaultApi
    }

    func onViewAppear() {
        viewState?(.loading(true))
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.tokenExists == true ? self?.viewState?(.navigateToHeroes) : self?.viewState?(.navigateToLogin)
        }
    }
}
