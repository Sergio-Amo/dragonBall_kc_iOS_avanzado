//
//  Mocks.swift
//  Practica_iOS_avanzado_ref1Tests
//
//  Created by Sergio Amo on 19/2/24.
//

import Foundation
@testable import Practica_iOS_avanzado_ref1

class Mocks {
    
    func getMockHeroesAsJson() -> String {
        return """
        [
            {
                "description": "Es un maestro de artes marciales que tiene una escuela, donde entrenará a Goku y Krilin para los Torneos de Artes Marciales. Aún en los primeros episodios había un toque de tradición y disciplina, muy bien representada por el maestro. Pero Muten Roshi es un anciano extremadamente pervertido con las chicas jóvenes, una actitud que se utilizaba en escenas divertidas en los años 80. En su faceta de experto en artes marciales, fue quien le enseñó a Goku técnicas como el Kame Hame Ha",
                "id": "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3",
                "name": "Maestro Roshi",
                "favorite": false,
                "photo": "https://cdn.alfabetajuega.com/alfabetajuega/2020/06/Roshi.jpg?width=300"
            },
            {
                "description": "Mr. Satán es un charlatán fanfarrón, capaz de manipular a las masas. Pero en realidad es cobarde cuando se da cuenta que no puede contra su adversario como ocurrió con Androide 18 o Célula. Siempre habla más de la cuenta, pero en algún momento del combate empieza a suplicar. Androide 18 le ayuda a fingir su victoria a cambio de mucho dinero. Él acepta el trato porque no podría soportar que todo el mundo le diera la espalda por ser un fraude.",
                "id": "1985A353-157F-4C0B-A789-FD5B4F8DABDB",
                "name": "Mr. Satán",
                "favorite": false,
                "photo": "https://cdn.alfabetajuega.com/alfabetajuega/2020/06/dragon-ball-satan.jpg?width=300"
            },
            {
                "description": "Krilin lo tiene todo. Cuando aún no existían los 'memes', Krilin ya los protagonizaba. Junto a Yamcha ha sido objeto de burla por sus desafortunadas batallas en Dragon Ball Z. Inicialmente, Krilin era el mejor amigo de Goku siendo sólo dos niños que querían aprender artes marciales. El Maestro Roshi les entrena para ser dos grandes luchadores, pero la diferencia entre ambos cada vez es más evidente. Krilin era ambicioso y se ablanda con el tiempo. Es un personaje que acepta un papel secundario para apoyar el éxito de su mejor amigo Goku de una forma totalmente altruista.",
                "id": "D88BE50B-913D-4EA8-AC42-04D3AF1434E3",
                "name": "Krilin",
                "favorite": false,
                "photo": "https://cdn.alfabetajuega.com/alfabetajuega/2020/08/Krilin.jpg?width=300"
            }
        ]
        """
    }
    
    func getMockHeroes() -> Heroes {
        let data = try! JSONSerialization.data(withJSONObject: getMockHeroesAsJson())
        return try! JSONDecoder().decode(Heroes.self, from: data)
    }
    
    func getMockLocationsAsJson() -> String {
        return """
        [
            {
                "longitud": "-2.4746262",
                "id": "AB3A873C-37B4-4FDE-A50F-8014D40D94FE",
                "dateShow": "2022-09-11T00:00:00Z",
                "latitud": "36.8415268",
                "hero": {
                    "id": "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
                }
            },
            {
                "longitud": "-3.97",
                "id": "E7D32AAB-8846-40DB-BF08-F4AA82B915C5",
                "dateShow": "2022-09-13T00:00:00Z",
                "latitud": "40.43",
                "hero": {
                    "id": "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
                }
            }
        ]
        """
    }
    
    func getMockLocations() -> HeroLocations {
        let data = try! JSONSerialization.data(withJSONObject: getMockLocationsAsJson())
        return try! JSONDecoder().decode(HeroLocations.self, from: data)
    }
}
