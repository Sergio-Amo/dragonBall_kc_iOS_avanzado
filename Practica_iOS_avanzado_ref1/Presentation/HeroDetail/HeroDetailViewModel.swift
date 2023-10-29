//
//  HeroDetailViewModel.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 29/10/23.
//

import Foundation

class HeroDetailViewModel: HeroDetailViewControllerDelegate {
    // MARK: - Dependencies -
    private let networkApi: NetworkApiProtocol
    
    // MARK: - Properties -
    var viewState: ((HeroDetailViewState) -> Void)?
    
    private var hero: Hero
    
    // MARK: - Initializers -
    init(networkApi: NetworkApiProtocol, hero: Hero ) {
        self.networkApi = networkApi
        self.hero = hero
    }
    
    // MARK: - Public functions -
    func onViewAppear() {
        viewState?(.loading(true))
        
        // TODO: GetHeroLocation from getHeroLocationLocal fallback to  getHeroLocationRemote
        
        self.viewState?(.update(hero: self.hero, locations: []))
        
        viewState?(.loading(false))
    }
    
    // MARK: - Private functions -
    private func getHeroLocationLocal() {
        
    }
    
    private func getHeroLocationRemote() {
        
    }
}
