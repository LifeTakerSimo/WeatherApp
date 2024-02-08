//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import Foundation

class WeatherService {
    func fetchWeatherDetails(latitude: Double, longitude: Double, completion: @escaping (Result<(current: Double, weatherCode: Int, daily: [(date: String, max: Double, min: Double, precipitationProbabilityMax: Double)], hourly: [(time: String, temperature: Double, weatherCode: Int, precipitationProbability: Double)]), Error>) -> Void) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&hourly=temperature_2m,weather_code,precipitation_probability&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let currentTemperature = decodedResponse.current.temperature_2m
                let weatherCode = decodedResponse.current.weather_code
                
                let dailyWeather = decodedResponse.daily.time.enumerated().map { index -> (date: String, max: Double, min: Double, precipitationProbabilityMax: Double) in
                    let date = decodedResponse.daily.time[index.offset]
                    let max = decodedResponse.daily.temperature_2m_max[index.offset]
                    let min = decodedResponse.daily.temperature_2m_min[index.offset]
                    let precipitationProbabilityMax = decodedResponse.daily.precipitation_probability_max[index.offset]
                    return (date, max, min, precipitationProbabilityMax)
                }
                
                let hourlyWeather = decodedResponse.hourly.time.enumerated().map { index -> (time: String, temperature: Double, weatherCode: Int, precipitationProbability: Double) in
                    let time = decodedResponse.hourly.time[index.offset]
                    let temperature = decodedResponse.hourly.temperature_2m[index.offset]
                    let weatherCode = decodedResponse.hourly.weather_code[index.offset]
                    let precipitationProbability = decodedResponse.hourly.precipitation_probability[index.offset]
                    return (time, temperature, weatherCode, precipitationProbability)
                }
                
                completion(.success((current: currentTemperature, weatherCode: weatherCode, daily: dailyWeather, hourly: hourlyWeather)))
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
