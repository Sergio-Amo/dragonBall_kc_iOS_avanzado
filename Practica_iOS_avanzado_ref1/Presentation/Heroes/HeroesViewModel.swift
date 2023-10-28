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
        
        DispatchQueue.global().async {
            self.networkApi.getHeroes(nil) { heroes in
                self.onHeroesReponse(heroes)
            }
        }
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
    private func onHeroesReponse(_ heroes: Heroes) {
        DispatchQueue.main.async {
            
            // Update Core Data

            let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
            
            let heroesDAO = try? managedObjectContext.fetch(NSFetchRequest<HeroDAO>(entityName: HeroDAO.identifier))
            if heroesDAO?.count == 0 {
                heroes.forEach { $0.toManagedObject(in: managedObjectContext) }
                try? managedObjectContext.save()
            }
            
            heroesDAO?.forEach({ heroDAO in
                print("name: \(String(describing: heroDAO.name))")
            })
            print(heroesDAO?.count as Any)
            
            self.heroes = heroes
            self.viewState?(.loading(false))
            self.viewState?(.updateData)
        }
    }
}
