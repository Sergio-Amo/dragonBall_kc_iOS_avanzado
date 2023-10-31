//
//  HeroesViewModel.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation
import CoreData

class HeroesViewModel: HeroesViewControllerDelegate {
    // MARK: - Dependencies -
    private let networkApi: NetworkApiProtocol

    // MARK: - Properties -
    var viewState: ((HeroesViewState) -> Void)?
    var heroesCount: Int {
        heroes.count
    }

    private var heroes: Heroes = []

    // MARK: - Initializers -
    init(networkApi: NetworkApiProtocol) {
        self.networkApi = networkApi
    }

    // MARK: - Public functions -
    func onViewAppear() {
        viewState?(.loading(true))
        // Load heroes from local if possible
        self.heroes = CoreDataStack.shared.getHeroes() ?? []
        if !self.heroes.isEmpty { print("Getting heroes from CoreData...") }
        self.heroes.isEmpty ? getHeroesRemote() : self.onHeroesReponse(self.heroes)
    }
    
    func onResetPressed() {
        // Clear keychain (vault)
        VaultApi().removeToken()
        // Clear CoreData
        CoreDataStack.shared.removeHeroes()
        // Exit from app
        exit(0)
    }

    func heroAt(index: Int) -> Hero? {
        guard index < heroesCount else { return nil }
        return heroes[index]
    }

    func heroDetailViewModel(for index: Int) -> HeroDetailViewControllerDelegate? {
        guard let hero = heroAt(index: index) else { return nil }
        return HeroDetailViewModel(networkApi: networkApi,
                                   hero: hero)
    }

    // MARK: - Private functions -
    private func getHeroesRemote() {
        DispatchQueue.global().async { [weak self] in
            self?.networkApi.getHeroes(nil) { [weak self] result in
                switch result {
                    case let .success(heroes):
                        // Save heroes to coreData if there's no data stored
                        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
                        heroes.forEach { $0.toManagedObject(in: managedObjectContext) }
                        try? managedObjectContext.save()
                        //Call to the method that updates the view
                        print("Getting heroes from Network...")
                        self?.onHeroesReponse(heroes)
                        break
                    case let .failure(error):
                        print("Error: \(error)")
                        break
                }
            }
        }
    }
    
    private func onHeroesReponse(_ heroes: Heroes) {
        DispatchQueue.main.async { [weak self] in
            // Update cell
            self?.heroes = heroes
            self?.viewState?(.loading(false))
            self?.viewState?(.updateData)
        }
    }
}
