import Foundation
import Combine
import CoreLocation
// WeatherViewModel.swift
class WeatherViewModel: ObservableObject {
    @Published var weatherInfo: WeatherTimelineResponse?
    @Published var locationString: String = "Fetching location..."
    @Published var getLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var isLocationPermissionDenied: Bool = false

    private let weatherService = WeatherAPIService()
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?

    init() {
        // Subscribe to the weatherService's weatherData changes
        weatherService.$weatherData
                .receive(on: RunLoop.main) // Ensure you receive updates on the main thread
                .assign(to: \WeatherViewModel.weatherInfo, on: self)
                .store(in: &cancellables) // Store the subscription

        // Subscribe to the locationManager's cityName changes
        locationManager.$cityName
                .compactMap { $0 } // Unwrap the optional string
                .receive(on: RunLoop.main)
                .assign(to: \WeatherViewModel.locationString, on: self)
                .store(in: &cancellables)

        // Subscribe to the locationManager's currentLocation changes
        locationManager.$currentLocation
                .compactMap { $0?.coordinate }
                .receive(on: RunLoop.main)
                .assign(to: \WeatherViewModel.getLocation, on: self)
                .store(in: &cancellables)

        locationManager.$locationPermissionDenied
                .receive(on: RunLoop.main)
                .assign(to: \.isLocationPermissionDenied, on: self)
                .store(in: &cancellables)
    }

    func loadWeatherData() {
        // Fetch initial weather data
        fetchWeatherData()

        // Set up a timer to fetch data every 25 minutes
        updateTimer?.invalidate() // Invalidate any existing timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60*25, repeats: true) { [weak self] _ in
            self?.fetchWeatherData()
        }
    }

    private func fetchWeatherData() {
        weatherService.fetchWeatherData(lat: getLocation.latitude, lon: getLocation.longitude)
    }

    deinit {
        // Invalidate the timer and cancel the subscriptions when the view model is deinitialized
        updateTimer?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
}
