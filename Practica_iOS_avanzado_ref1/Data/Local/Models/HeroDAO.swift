//
//  HeroDAO.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation
import CoreData

@objc(HeroDAO)
class HeroDAO: NSManagedObject {
    static let identifier = "HeroDAO"
    
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var longDescription: String?
    @NSManaged var photo: String?
    @NSManaged var favorite: Bool
}

/// HeroDAO -> Hero
extension HeroDAO: ModelConvertible {
    // MARK: - ModelConvertible
    /// Converts a HeroDAO instance to a Hero instance.
    ///
    /// - Returns: The converted Hero instance.
    func toModel() -> Hero? {
        return Hero(
            id: id,
            name: name,
            description: longDescription,
            photo: URL(string: photo ?? ""),
            favorite: favorite
        )
    }
}
