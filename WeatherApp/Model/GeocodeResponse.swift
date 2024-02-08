//
//  GeocodeResponse.swift
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import Foundation

struct GeocodeResponse: Codable {
    var results: [CityResult]
    
    struct CityResult: Codable {
        var name: String
        var latitude: Double
        var longitude: Double
    }
}
