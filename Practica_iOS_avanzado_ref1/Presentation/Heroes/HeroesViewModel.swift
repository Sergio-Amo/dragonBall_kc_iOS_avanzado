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
        CoreDataStack.shared.heroDAOCount == 0 ? getHeroesRemote() : getHeroesLocal()
    }

    func heroAt(index: Int) -> Hero? {
        guard index < heroesCount else { return nil }
        return heroes[index]
    }

   /* func heroDetailViewModel(for index: Int) -> HeroDetailViewControllerDelegate? {
        guard let hero = heroBy(index: index) else { return nil }
        return HeroDetailViewModel(apiProvider: apiProvider,
                                   hero: hero)
    }*/

    // MARK: - Private functions -
    private func getHeroesRemote() {
        DispatchQueue.global().async {
            self.networkApi.getHeroes(nil) { heroes in
                self.onHeroesReponse(heroes)
            }
        }
    }
    private func getHeroesLocal() {
        DispatchQueue.main.async {
            guard let heroes = CoreDataStack.shared.getHeroes() else { return }
            self.onHeroesReponse(heroes)
        }
    }
    
    private func onHeroesReponse(_ heroes: Heroes) {
        DispatchQueue.main.async {
            // Save heroes to coreData if there's no data stored
            let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
            if CoreDataStack.shared.heroDAOCount == 0 {
                heroes.forEach { $0.toManagedObject(in: managedObjectContext) }
                try? managedObjectContext.save()
            }
            // Update cell
            self.heroes = heroes
            self.viewState?(.loading(false))
            self.viewState?(.updateData)
        }
    }
}
