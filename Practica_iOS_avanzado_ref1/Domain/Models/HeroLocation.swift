//
//  HeroLocation.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import Foundation

struct HeroLocation: Codable {
    let id: String?,
        latitud: String?,
        longitud: String?,
        dateShow: String?,
        hero: Hero?
}