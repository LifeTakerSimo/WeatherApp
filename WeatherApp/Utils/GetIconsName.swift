//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//
import Foundation

class Icon {
    static func weatherIconName(from code: Int?) -> String {
        guard let code = code else {
            return "sunny"
        }
        
        switch code {
        case 0:
            return "sun.max.fill"
        case 1, 2, 3:
            return ["sun.max.fill", "cloud.sun.fill", "cloud.fill"][code - 1]
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 56, 57:
            return "cloud.sleet.fill"
        case 61, 63, 65:
            return "cloud.rain.fill"
        case 66, 67:
            return "cloud.hail.fill"
        case 71, 73, 75:
            return "cloud.snow.fill"
        case 77:
            return "snowflake"
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
        case 85, 86:
            return "cloud.snow.fill"
        case 95:
            return "cloud.bolt.rain.fill"
        case 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.diamond.fill"
        }
    }
}
