//
//  HeroLocationDAO.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 29/10/23.
//

import Foundation
import CoreData

@objc(HeroLocationDAO)
class HeroLocationDAO: NSManagedObject {
    @NSManaged var id: String?
    @NSManaged var latitud: String?
    @NSManaged var longitud: String?
    @NSManaged var dateShow: String?
    @NSManaged var hero: HeroDAO?
}

extension HeroLocationDAO: ModelConvertible {
    /// The managed entity name.
    static var entityName = "HeroLocationDAO"

    // MARK: - ModelConvertible
    /// Converts a HeroDAO instance to a Hero instance.
    ///
    /// - Returns: The converted Hero instance.
    func toModel() -> HeroLocation? {
        return HeroLocation(
            id: id,
            latitud: latitud,
            longitud: longitud,
            dateShow: dateShow,
            hero: hero?.toModel()
        )
    }
}
