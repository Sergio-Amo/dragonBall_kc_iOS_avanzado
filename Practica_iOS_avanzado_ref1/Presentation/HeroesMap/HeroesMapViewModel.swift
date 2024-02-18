//
//  HeroesMapViewModel.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 18/2/24.
//

import Foundation
import CoreData

class HeroesMapViewModel: HeroesMapViewControllerDelegate {
    // MARK: - Dependencies -
    private let networkApi: NetworkApiProtocol
    
    // MARK: - Properties -
    var viewState: ((HeroesMapViewState) -> Void)?
    
    private var heroes: Heroes = []
    private var locations: [HeroAnnotation] = []
    
    // MARK: - Initializers -
    init(networkApi: NetworkApiProtocol) {
        self.networkApi = networkApi
    }
    
    // MARK: - Public functions -
    func onViewAppear() {
        viewState?(.loading(true))
        // Get Heroes before getting locations
        self.heroes = CoreDataStack.shared.getHeroes() ?? []
        if !self.heroes.isEmpty { print("Getting heroes from CoreData...") }
        self.heroes.isEmpty ? getHeroesRemote() : self.onHeroesReponse(self.heroes)
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
        self.heroes = heroes
        // Now that we have the heroes get the locations
        DispatchQueue.global().async { [weak self] in
            heroes.forEach { hero in
                guard let id = hero.id, let name = hero.name else {return}
                guard let locations = CoreDataStack.shared.getHeroLocations(id:id),
                      !locations.isEmpty else {
                    print("Getting location from network...")
                    self?.getHeroLocationRemote(id: id, name: name)
                    return
                }
                print("Getting location from CoreData...")
                self?.getHeroLocationResponse(locations: locations, name: name)
            }
        }
    }
        
    private func getHeroLocationRemote(id: String, name: String) {
        DispatchQueue.global().async { [weak self] in
            self?.networkApi.getHeroLocations(id: id) { [weak self] result in
                switch result {
                    case let .success(locations):
                        self?.saveLocationsToLocal(locations)
                        self?.getHeroLocationResponse(locations: locations, name: name)
                        break
                    case let .failure(error):
                        print("Error: \(error)")
                        break
                }
            }
        }
    }
    
    private func getHeroLocationResponse(locations: HeroLocations, name: String) {
        manageLocations(locations, name: name)
        viewState?(.update(locations: self.locations))
        viewState?(.loading(false))
    }
    
    private func saveLocationsToLocal(_ locations: HeroLocations) {
        DispatchQueue.main.async {
            // Save locations to coreData if there's no data stored
            let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
            managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            locations.forEach{ $0.toManagedObject(in: managedObjectContext) }
            CoreDataStack.shared.saveContext()
        }
    }
    
    // Sort locations by dateShow
    private func sortHeroLocationsByDate(locations: HeroLocations) -> HeroLocations {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return locations.sorted(by: { first, second in
            if let str1 = first.dateShow, let str2 = second.dateShow,
               let date1 = dateFormatter.date(from: str1),
               let date2 = dateFormatter.date(from: str2) {
                return date1 > date2
            }
            return true
        })
    }
    
    private func manageLocations(_ locations: HeroLocations, name: String) {
        self.locations = sortHeroLocationsByDate(locations: locations)
            .compactMap{ (heroLocation: HeroLocation) -> HeroAnnotation? in
                guard let latitude = Double(heroLocation.latitud ?? ""),
                      let longitude = Double(heroLocation.longitud ?? "") else {
                    return nil
                }
                
                return HeroAnnotation(
                    title: name,
                    info: heroLocation.dateShow ?? "Not available",
                    coordinate: .init(latitude: latitude, longitude: longitude)
                )
            }
    }
}
