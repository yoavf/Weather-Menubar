import CoreLocation
import Foundation
import SwiftUI

class WeatherAPIService: ObservableObject {
    @Published var weatherData: WeatherTimelineResponse?
    @AppStorage("apiKey") private var apiKey: String = ""

    private let urlCache: URLCache
    private var apiTimer: Timer?

    init() {
        urlCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 5 * 1024 * 1024, diskPath: nil)
        URLCache.shared = urlCache
    }

    func createRequestBody(lat: Double, lon: Double) -> Data? {
        let requestBody: [String: Any] = [
            "location": [lat, lon],
            "fields": ["precipitationIntensity", "temperature", "temperatureApparent", "weatherCode"],
            "units": "metric",
            "timesteps": ["current", "1h"],
            "startTime": iso8601String(from: Date()),
            "endTime": iso8601String(from: Calendar.current.date(byAdding: .hour, value: 6, to: Date())),
            "timezone" : "auto"
        ]

        // Convert the request body to JSON data
        return try? JSONSerialization.data(withJSONObject: requestBody, options: [])
    }

    func iso8601String(from date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Adjust this based on the API requirements
        return formatter.string(from: date)
    }

    func fetchWeatherData(lat: Double, lon: Double) {
        guard let url = URL(string: "https://api.tomorrow.io/v4/timelines") else { return }
        guard let requestBody = createRequestBody(lat: lat, lon: lon) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.cachePolicy = .returnCacheDataElseLoad

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 429 {
                    print("Received status code 429: Too Many Requests")
                    return
                }
            }

            if let safeData = data, let response = response, error == nil {
                let cachedResponse = CachedURLResponse(response: response, data: safeData, userInfo: nil, storagePolicy: .allowed)
                self?.urlCache.storeCachedResponse(cachedResponse, for: request)

                do {
                    let decoder = JSONDecoder()
                    var weatherResponse = try decoder.decode(WeatherTimelineResponse.self, from: safeData)
                    weatherResponse.location = CLLocationCoordinate2D( latitude: lat, longitude: lon)
                    DispatchQueue.main.async {
                        self?.weatherData = weatherResponse
                    }
                } catch {
                    print("Error decoding weather data: \(error)")
                }
            }
        }

        task.resume()
    }
}