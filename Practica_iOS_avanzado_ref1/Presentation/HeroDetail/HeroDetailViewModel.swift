//
//  HeroDetailViewModel.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 29/10/23.
//

import Foundation
import CoreData

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

        guard let id = self.hero.id else { return }
        
        guard let locations = CoreDataStack.shared.getHeroLocations(id:id),
              !locations.isEmpty else {
            print("Getting location from network...")
            self.getHeroLocationRemote(id:id)
            return
        }
        print("Getting location from CoreData...")
        self.getHeroLocationResponse(locations: locations)
    }
    
    // MARK: - Private functions -
    private func getHeroLocationResponse(locations: HeroLocations) {
        manageLocations(locations)
        viewState?(.update(hero: self.hero, locations: self.locations))
        viewState?(.loading(false))
    }
    
    private func getHeroLocationRemote(id: String) {
        self.networkApi.getHeroLocations(id: id) { [weak self] result in
            switch result {
                case let .success(locations):
                    self?.saveLocationsToLocal(locations)
                    self?.getHeroLocationResponse(locations: locations)
                    break
                case let .failure(error):
                    print("Error: \(error)")
                    break
            }
        }
    }
    
    private func saveLocationsToLocal(_ locations: HeroLocations) {
        // Save locations to coreData if there's no data stored
        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        locations.forEach{ $0.toManagedObject(in: managedObjectContext) }
        CoreDataStack.shared.saveContext()
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
    
    private func manageLocations(_ locations: HeroLocations) {
        self.locations = sortHeroLocationsByDate(locations: locations)
            .compactMap{ (heroLocation: HeroLocation) -> HeroAnnotation? in
                guard let latitude = Double(heroLocation.latitud ?? ""),
                      let longitude = Double(heroLocation.longitud ?? "") else {
                    return nil
                }
                
                return HeroAnnotation(
                    title: hero.name ?? "unknown",
                    info: heroLocation.dateShow ?? "Not available",
                    coordinate: .init(latitude: latitude, longitude: longitude)
                )
            }
    }
}
