//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import Foundation

struct WeatherResponse: Codable {
    var current: CurrentWeather
    var daily: DailyWeather
    var hourly: HourlyWeather

    struct CurrentWeather: Codable {
        var temperature_2m: Double
        var weather_code: Int
    }

    struct DailyWeather: Codable {
        var time: [String]
        var temperature_2m_max: [Double]
        var temperature_2m_min: [Double]
        var precipitation_probability_max: [Double]
    }

    struct HourlyWeather: Codable {
        var time: [String]
        var temperature_2m: [Double]
        var weather_code: [Int]
        var precipitation_probability: [Double]
    }
}


