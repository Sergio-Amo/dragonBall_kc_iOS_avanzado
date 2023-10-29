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
    private var locations: [HeroAnnotation] = []
    
    // MARK: - Initializers -
    init(networkApi: NetworkApiProtocol, hero: Hero ) {
        self.networkApi = networkApi
        self.hero = hero
    }
    
    // MARK: - Public functions -
    func onViewAppear() {
        viewState?(.loading(true))
        // TODO: GetHeroLocation from getHeroLocationLocal fallback to  getHeroLocationRemote
        guard let id = self.hero.id else { return }
        self.networkApi.getHeroLocations(id: id) { [weak self] result in
            switch result {
                case let .success(locations):
                    self?.manageLocations(locations)
                    self?.viewState?(.update(hero: self?.hero, locations: self?.locations))
                    self?.viewState?(.loading(false))
                    break
                case let .failure(error):
                    print("Error: \(error)")
                    break
            }
        }
    }
    
    // MARK: - Private functions -
    private func getHeroLocationLocal() {
        
    }
    
    private func getHeroLocationRemote() {
        
    }
    
    private func manageLocations(_ locations: HeroLocations) {
        self.locations = locations.compactMap{ (heroLocation: HeroLocation) -> HeroAnnotation? in
            guard let latitude = Double(heroLocation.latitud ?? ""),
                  let longitude = Double(heroLocation.longitud ?? "") else {
                return nil
            }

            return HeroAnnotation(
                title: hero.name ?? "Location",
                info: heroLocation.dateShow ?? "Top Secret",
                coordinate: .init(latitude: latitude,
                                  longitude: longitude)
                
            )
        }
    }
    
}
