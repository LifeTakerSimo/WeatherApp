import SwiftUI

struct MainView: View {
    @State private var cityName: String = ""
    @State private var cities: [City] = []
    @State private var citySuggestions: [City] = []
    private let geocodingService = GeocodingService()
    private let weatherService = WeatherService()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter city name", text: $cityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        .onChange(of: cityName) { newValue in
                            if newValue.isEmpty {
                                citySuggestions = []
                            } else {
                                fetchCitySuggestions(query: newValue)
                            }
                        }

                    Button(action: {
                        if !cityName.isEmpty {
                            addCityWithName(cityName)
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(cityName.isEmpty ? .gray : .blue)
                            .padding(.trailing)
                    }
                    .disabled(cityName.isEmpty)
                }
                

                if !citySuggestions.isEmpty {
                    List(citySuggestions, id: \.self) { city in
                        Button(action: {
                            self.addCityWithName(city.name)
                            self.cityName = ""
                            self.citySuggestions = []
                        }) {
                            Text(city.name)
                        }
                    }
                    .frame(maxHeight: 200)
                }

                List {
                    ForEach(cities, id: \.self) { city in
                        NavigationLink(destination: CityDetailView(city: city)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(city.name)
                                        .font(.headline)
                                    Text("Lat: \(city.latitude, specifier: "%.2f"), Long: \(city.longitude, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if let temperature = city.temperature {
                                    Text("\(Int(temperature))°C")                                        .font(.headline)
                                    Image(systemName: Icon.weatherIconName(from: city.weatherCode))
                                        .foregroundColor(.gray)
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteCity)
                }
                .listStyle(PlainListStyle())

            }
            .navigationTitle("WeatherApp")
            .navigationBarItems(trailing: EditButton())
        }
    }

    func addCityWithName(_ name: String) {
        guard let cityToAdd = citySuggestions.first(where: { $0.name.lowercased() == name.lowercased() }) else { return }
        
        weatherService.fetchWeatherDetails(latitude: cityToAdd.latitude, longitude: cityToAdd.longitude) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherDetails):
                    var newCity = cityToAdd
                    newCity.temperature = weatherDetails.current
                    newCity.weatherCode = weatherDetails.weatherCode
                    self.cities.insert(newCity, at: 0)
                case .failure(let error):
                    print("Error fetching weather details: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchCitySuggestions(query: String) {
        geocodingService.fetchCitySuggestions(name: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let suggestions):
                    self.citySuggestions = suggestions
                case .failure(let error):
                    print("Error fetching suggestions: \(error.localizedDescription)")
                    self.citySuggestions = []
                }
            }
        }
    }

    func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
