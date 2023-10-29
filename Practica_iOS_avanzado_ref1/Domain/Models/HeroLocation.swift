//
//  HeroLocation.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation
import CoreData

typealias HeroLocations = [HeroLocation]

struct HeroLocation: Codable, Equatable {
    let id: String?,
        latitud: String?,
        longitud: String?,
        dateShow: String?,
        hero: Hero?
}

extension HeroLocation: ManagedObjectConvertible {
    @discardableResult
    func toManagedObject(in context: NSManagedObjectContext) -> HeroLocationDAO? {
        let entityName = HeroLocationDAO.entityName
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            NSLog("Can't create entity \(entityName)")
            return nil
        }
        
        let object = HeroLocationDAO.init(entity: entityDescription, insertInto: context)
        object.id = id
        object.latitud = longitud
        object.longitud = longitud
        object.dateShow = dateShow
        object.hero = hero?.toManagedObject(in: context)
        
        return object
    }
}
