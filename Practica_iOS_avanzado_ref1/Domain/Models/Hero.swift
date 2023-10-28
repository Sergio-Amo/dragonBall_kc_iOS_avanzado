//
//  Hero.swift
//  Practica_iOSAvanzado
//
//  Created by Sergio Amo on 27/10/23.
//

import Foundation
import CoreData

typealias Heroes = [Hero]

struct Hero: Codable, Equatable {
    let id: String?,
        name: String?,
        description: String?,
        photo: URL?,
        favorite: Bool?
}

extension Hero: ManagedObjectConvertible {
    @discardableResult
    func toManagedObject(in context: NSManagedObjectContext) -> HeroDAO? {
        let identifier = HeroDAO.identifier
        guard let entityDescription = NSEntityDescription.entity(forEntityName: identifier, in: context) else {
            NSLog("Can't create entity \(identifier)")
            return nil
        }
        
        let object = HeroDAO.init(entity: entityDescription, insertInto: context)
        object.id = id
        object.name = name
        object.longDescription = description
        object.photo = photo?.absoluteString ?? nil
        object.favorite = favorite ?? false

        return object
    }
}
