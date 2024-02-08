//
//
//  WeatherAPP
//
//  Created by Mohamed Kabbou, Oueslati Mohamed-Amine, Salhani Mohamed.
//

import Foundation

class GeocodingService {
    func fetchCitySuggestions(name: String, completion: @escaping (Result<[City], Error>) -> Void) {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(encodedName)&count=3&language=en&format=json"
        
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
                let decodedResponse = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                let cities = decodedResponse.results.map { City(name: $0.name, latitude: $0.latitude, longitude: $0.longitude) }
                completion(.success(cities))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
