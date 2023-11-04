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
        filteredHeroes.count
    }

    private var heroes: Heroes = []
    private var filteredHeroes: Heroes = []
    private var lastFilter: String = ""

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
        return filteredHeroes[index]
    }

    func heroDetailViewModel(for index: Int) -> HeroDetailViewControllerDelegate? {
        guard let hero = heroAt(index: index) else { return nil }
        return HeroDetailViewModel(networkApi: networkApi,
                                   hero: hero)
    }
    
    func filterHeroes(currentFilter: String) {
        
        // Update the table and lastFilter value
        defer {
            lastFilter = currentFilter
            viewState?(.updateData)
        }
        // A character was appended to the lastFilter (except is lastFilter is empty)
        // Easy performance optimization use it to filter over the already filtered list instead
        // of filtering over the whole heroes list.
        // In case there was a too big list you can additionally add a currentFilter.count limit of
        // 2-3 characters as to not use a too short filter that may hurt performance
        
        let filter = try? Regex(currentFilter).ignoresCase()
        
        if !lastFilter.isEmpty
            && currentFilter.count > lastFilter.count
            && currentFilter.starts(with: lastFilter)
            , let filter {
            
            // Filter over already filtered list
            filteredHeroes = filteredHeroes.filter{ $0.name?.contains(filter) ?? false }
            
        } else if currentFilter.isEmpty {
            
            // Just go back to the all heroes list
            filteredHeroes = heroes
            
        } else if let filter {
            
            // Filter over all heroes list
            filteredHeroes = heroes.filter{ $0.name?.contains(filter) ?? false }
        }
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
                        CoreDataStack.shared.saveContext()
                        
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
            self?.filteredHeroes = heroes
            self?.heroes = heroes
            self?.viewState?(.loading(false))
            self?.viewState?(.updateData)
        }
    }
    
}
