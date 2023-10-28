//
//  Extension+URL.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 29/10/23.
//

import Foundation
// Upgrades URL Scheme to https
extension URL {
    func upgradeUrlScheme (_ url: URL) -> URL {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.scheme = "https"
        guard let finalUrl = urlComponents?.url else {
            return url
        }
        return finalUrl
    }
}
