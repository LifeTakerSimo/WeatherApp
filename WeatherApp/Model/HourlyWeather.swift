//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import Foundation

struct HourlyWeather: Identifiable, Codable {
    let id = UUID()
    let time: String
    let temperature: Double
    let weatherCode: Int
}
