//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import Combine
import Foundation

class City: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    @Published var name: String
    @Published var latitude: Double
    @Published var longitude: Double
    @Published var temperature: Double?
    @Published var weatherCode: Int?


    init(name: String, latitude: Double, longitude: Double, temperature: Double? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.temperature = temperature // Initialize temperature
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
