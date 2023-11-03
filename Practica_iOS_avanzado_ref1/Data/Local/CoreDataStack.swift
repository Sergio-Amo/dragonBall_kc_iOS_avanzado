//
//  CoreDataStack.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation
import CoreData

/// Protocol to provide functionality for Core Data managed object conversion.
protocol ManagedObjectConvertible {
    associatedtype ManagedObject

    /// Converts a conforming instance to a managed object instance.
    ///
    /// - Parameter context: The managed object context to use.
    /// - Returns: The converted managed object instance.
    @discardableResult
    func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject?
}

/// Protocol to provide functionality for data model conversion.
protocol ModelConvertible {
    associatedtype Model

    /// Converts a conforming instance to a data model instance.
    ///
    /// - Returns: The converted data model instance.
    func toModel() -> Model?
}

class CoreDataStack: NSObject {
    static let shared: CoreDataStack = .init()
    private override init() {}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Practica_iOS_avanzado_ref1")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: catch this properly
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getHeroes() -> Heroes? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<HeroDAO>(entityName: HeroDAO.identifier)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let heroesDAO = try? context.fetch(fetchRequest)
        return heroesDAO?.compactMap { $0.toModel() }
    }
    
    func removeHeroes() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<HeroDAO>(entityName: HeroDAO.identifier)
        guard let heroesDAO = try? context.fetch(fetchRequest) else { return }
        heroesDAO.forEach { context.delete($0) }
        self.saveContext()
    }
    
    func getHeroLocations(id: String) -> HeroLocations? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<HeroLocationDAO>(entityName: HeroLocationDAO.identifier)
        fetchRequest.predicate = NSPredicate(format: "hero.id = %@", id)
        let locations = try? context.fetch(fetchRequest)
        return locations?.compactMap { $0.toModel() }
    }
}

