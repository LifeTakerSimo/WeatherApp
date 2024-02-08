//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import SwiftUI

struct CityDetailView: View {
    var city: City
    @State private var currentTemperature: Double?
    @State private var weatherCode: Int?
    @State private var dailyWeather: [(date: String, max: Double, min: Double, precipitationProbabilityMax: Double)] = []
    @State private var hourlyWeather: [(time: String, temperature: Double, weatherCode: Int)] = []

    private let weatherService = WeatherService()

    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [backgroundForWeather(code: weatherCode).primary, backgroundForWeather(code: weatherCode).secondary]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(city.name)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)

                    if let temperature = currentTemperature, let code = weatherCode {
                        HStack(spacing: 10) {
                            Spacer()
                            Text("\(Int(temperature))°C")
                                .font(.title)
                            Image(systemName: Icon.weatherIconName(from: code))         .renderingMode(.original)
                                .font(.largeTitle)
                            Spacer()
                        }
                    }
                    Text("Hourly Forecast").font(.headline).padding(.top)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 5) {
                                    let currentHourString = getCurrentHourString()
                                    ForEach(filteredHourlyWeather(), id: \.time) { hour in
                                        HourlyWeatherView(hour: HourlyWeather(time: hour.time, temperature: hour.temperature, weatherCode: hour.weatherCode), isCurrentHour: hour.time.contains(currentHourString))
                                            .frame(width: 80, height: 120)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.bottom)
                    
                    // Title with added padding
                    Text("Daily Forecast")
                        .font(.headline)
                        .padding()
                    
                    ForEach(dailyWeather, id: \.date) { day in
                        HStack {
                            Text(formatDate(day.date))
                                .font(.title3)
                                .padding([.leading, .top, .bottom])
                            
                            Spacer()
                            
                            if day.precipitationProbabilityMax > 10 {
                                Text("\(Int(day.precipitationProbabilityMax))%")
                                    .padding([.top, .bottom])
                            }
                            
                            Image(systemName: Icon.weatherIconName(from: weatherCode))
                                .renderingMode(.original)
                                .font(.system(size: 24))
                                .padding([.top, .bottom])
                            
                            Text("\(Int(day.max))°")
                                .padding([.top, .bottom])
                            
                            Image(systemName: "arrow.up")
                                .foregroundColor(.red)
                                .padding([.top, .bottom])
                            
                            Text("\(Int(day.min))°")
                                .padding([.top, .bottom])
                            
                            Image(systemName: "arrow.down")
                                .foregroundColor(.blue)
                                .padding([.top, .bottom, .trailing])
                        }
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.4)))
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .onAppear {
                fetchWeatherDetails()
            }
        }.foregroundColor(.white)
    }
    
    func getCurrentHourString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    private func fetchWeatherDetails() {
        weatherService.fetchWeatherDetails(latitude: city.latitude, longitude: city.longitude) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherDetails):
                    self.currentTemperature = weatherDetails.current
                    self.weatherCode = weatherDetails.weatherCode
                    self.dailyWeather = weatherDetails.daily.map { day in
                        let formattedDate = formatDate(day.date)
                        let precipitationProbabilityMax = day.precipitationProbabilityMax
                        return (date: formattedDate, max: day.max, min: day.min, precipitationProbabilityMax: precipitationProbabilityMax)
                    }
                    self.hourlyWeather = weatherDetails.hourly.map { hour in
                        (time: hour.time, temperature: hour.temperature, weatherCode: hour.weatherCode)
                    }
                case .failure(let error):
                    print("Error fetching weather: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "EEEE"
            return outputFormatter.string(from: date)
        }
    }
    
    private func backgroundForWeather(code: Int?) -> (primary: Color, secondary: Color) {
        guard let code = code else {
            return (Color.clear, Color.clear)
        }
        
        switch code {
        case 0:
            return (Color(hex: "#f7ca19"), Color(hex: "#f2e8b6")) // Sunny
        case 1, 2, 3:
            return (Color(hex: "#b5d4e2"), Color(hex: "#e2e2e2")) // Partly Cloudy
        case 45, 48:
            return (Color(hex: "#d6d6d6"), Color(hex: "#c6c6c6")) // Foggy
        case 51, 53, 55, 56, 57, 61, 63, 65, 80, 81, 82:
            return (Color(hex: "#859fa6"), Color(hex: "#6ba1c4")) // Rainy
        case 66, 67, 71, 73, 75, 85, 86:
            return (Color(hex: "#e0f3ff"), Color(hex: "#ffffff")) // Snowy
        case 77:
            return (Color(hex: "#e0f3ff"), Color(hex: "#ffffff")) // Snowflake, assuming Snowy colors
        case 95, 96, 99:
            return (Color(hex: "#b33a3a"), Color(hex: "#f7ca19")) // Thunderstorm
        default:
            return (Color(hex: "#cacaca"), Color(hex: "#9da2a9")) // Cloudy for any other code
        }
    }
    
    func filteredHourlyWeather() -> [HourlyWeather] {
        let now = Date()
        return hourlyWeather.compactMap { hour -> HourlyWeather? in
            guard let hourDate = parseHourStringToDate(hour.time) else { return nil }
            if hourDate >= now {
                return HourlyWeather(time: hour.time, temperature: hour.temperature, weatherCode: hour.weatherCode)
            } else {
                return nil
            }
        }.prefix(23)
        .map { $0 }
    }

    func parseHourStringToDate(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.date(from: timeString)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
