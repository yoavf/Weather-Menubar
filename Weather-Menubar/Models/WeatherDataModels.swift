import CoreLocation
import Foundation
import Solar

// Define structures that match the JSON response
struct WeatherTimelineResponse: Codable {
    var current: Interval?
    var location: CLLocationCoordinate2D?
    var timeline: [Interval]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        var timelinesArray = try dataContainer.nestedUnkeyedContainer(forKey: .timelines)

        while !timelinesArray.isAtEnd {
            let timeline = try timelinesArray.decode(Timeline.self)
            if timeline.timestep == "current", let currentInterval = timeline.intervals.first {
                current = currentInterval
            } else if timeline.timestep == "1h" {
                self.timeline = timeline.intervals
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data
        case timelines
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dataContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        var timelinesArray = dataContainer.nestedUnkeyedContainer(forKey: .timelines)

        var timeline = Timeline(timestep: "current", intervals: [Interval]())
        if let current = current {
            timeline.intervals.append(current)
        }
        try timelinesArray.encode(timeline)

        timeline = Timeline(timestep: "1h", intervals: timeline.intervals)
        try timelinesArray.encode(timeline)
    }
}

struct Timeline: Codable {
    let timestep: String
    var intervals: [Interval]
}

struct Interval: Codable {
    let startTime: String
    let values: WeatherValues
}

extension Interval {
    func formatStartTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust this based on your actual date format
        guard let date = dateFormatter.date(from: startTime) else {
            return startTime
        }

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: Date())
        let is24Hour = !dateString.contains(dateFormatter.amSymbol) && !dateString.contains(dateFormatter.pmSymbol)

        dateFormatter.dateFormat = is24Hour ? "HH:mm" : "h:mm a"
        return dateFormatter.string(from: date)
    }
}

extension Interval {
    func isDaytime(at location: CLLocationCoordinate2D) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: startTime) else {
            return true // Default to daytime if the date or location is not available
        }

        let solar = Solar(for: date, coordinate: location)
        return solar?.isDaytime ?? true
    }
}

struct WeatherValues: Codable {
    let precipitationIntensity: Double
    let temperature: Double
    let temperatureApparent: Double
    let weatherCode: Int
}

extension WeatherValues {
    func systemImageName(isDaytime: Bool) -> String {
        switch weatherCode {
        case 1000:
            return isDaytime ? "sun.max.fill" : "moon.fill" // Clear, Sunny
        case 1100:
            return isDaytime ? "sun.max" : "moon" // Mostly Clear
        case 1101:
            return isDaytime ? "cloud.sun.fill" : "cloud.moon.fill" // Partly Cloudy
        case 1102:
            return isDaytime ? "cloud.sun" : "cloud.moon" // Mostly Cloudy
        case 1001:
            return "cloud.fill" // Cloudy
        case 2000, 2100:
            return "cloud.fog.fill" // Fog, Light Fog
        case 4000:
            return "cloud.drizzle.fill" // Drizzle
        case 4001:
            return "cloud.rain.fill" // Rain
        case 4200:
            return "cloud.rain" // Light Rain
        case 4201:
            return "cloud.heavyrain.fill" // Heavy Rain
        case 5000, 5100:
            return "snow" // Snow, Light Snow
        case 5101:
            return "snowflake" // Heavy Snow
        case 6000:
            return "cloud.sleet.fill" // Freezing Drizzle
        case 6001:
            return "cloud.sleet" // Freezing Rain
        case 6200, 6201:
            return "cloud.hail" // Light Freezing Rain, Heavy Freezing Rain
        case 7000, 7101, 7102:
            return "cloud.hail" // Ice Pellets, Heavy Ice Pellets, Light Ice Pellets
        case 8000:
            return "cloud.bolt.rain.fill" // Thunderstorm
        default:
            return "questionmark.diamond.fill" // Unknown
        }
    }
}
