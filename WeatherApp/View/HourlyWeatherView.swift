//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import SwiftUI

struct HourlyWeatherView: View {
    let hour: HourlyWeather
    let isCurrentHour: Bool

    var body: some View {
        VStack {
            Text(formatHour(hour.time))
                .font(.headline)
            Text("\(hour.temperature, specifier: "%.0f")°C")
                .font(.subheadline)
            Image(systemName: Icon.weatherIconName(from: hour.weatherCode))
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.4)))
        .frame(width: 100)
    }
    
    private func formatHour(_ timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone.current
        
        if let date = inputFormatter.date(from: timeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "ha"
            outputFormatter.amSymbol = " AM"
            outputFormatter.pmSymbol = " PM"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            outputFormatter.timeZone = TimeZone.current
            return outputFormatter.string(from: date)
        }
        return timeString
    }
}
