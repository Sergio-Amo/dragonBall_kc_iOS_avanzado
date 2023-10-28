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

/*
import Foundation
import CoreData

public typealias Heroes = [Hero]

public struct Hero: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case photo
        case favorite
    }

    public let id: String?
    public let name: String?
    public let description: String?
    public let photo: URL?
    public let favorite: Bool?

    public init(id: String?, name: String?, description: String?, photo: URL?, favorite: Bool?) {
        self.id = id
        self.name = name
        self.description = description
        self.photo = photo
        self.favorite = favorite
    }
}

extension Hero: ManagedObjectConvertible {
    @discardableResult
    func toManagedObject(in context: NSManagedObjectContext) -> HeroDAO? {
        let entityName = HeroDAO.identifier
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            NSLog("Can't create entity \(entityName)")
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

*/
