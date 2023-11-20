import Combine
import CoreLocation
import SwiftUI

struct WeatherView: View {

    @Binding var showSettings: Bool
    @StateObject var viewModel = WeatherViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(viewModel.locationString)
                        .font(.system(.subheadline, weight: .semibold))
                Spacer()
                Button(action: {
                    withAnimation(.interpolatingSpring(mass: 1, stiffness: 10, damping: 10, initialVelocity: 10)) {
                        showSettings.toggle()
                    }
                }) {
                    Image(systemName: "gear")
                            .symbolRenderingMode(.monochrome)
                }
                        .background(.clear)
                        .buttonStyle(PlainButtonStyle())

            }
                    .padding(.top)
            if let weatherData = viewModel.weatherInfo,
               let currentWeather = weatherData.current,
               let weatherTimeline = weatherData.timeline {
                let isDayTime = currentWeather.isDaytime(at: viewModel.getLocation)
                let weatherIcon = currentWeather.values.systemImageName(isDaytime: isDayTime)
                CurrentWeather( temperature: currentWeather.values.temperature, weatherIcon: weatherIcon)
                VStack(spacing: 13) {
                    Rectangle()
                            .frame(height: 1, alignment: .top )
                            .clipped()
                            .opacity(0.1)
                    HStack {
                        ForEach(Array(weatherTimeline.dropFirst().enumerated()), id: \.element.startTime) { index, interval in
                            let isIntervalDayTime = interval.isDaytime(at: viewModel.getLocation)
                            HourlyWeather( interval: interval, isDayTime: isIntervalDayTime )
                            if index < weatherTimeline.dropFirst().count - 1 {
                                Spacer()
                            }
                        }
                    }
                }
                        .padding(.top, 4)
            } else {
                VStack(spacing: 13) {
                    Text("Fetching weather data...")
                    Spacer()
                }
                        .frame(minHeight: 100)
            }
        }
                .padding(.bottom, 14)
                .padding(.horizontal, 16)
                .frame(width: 270, height: 160)
                .background {
                    LinearGradient(gradient: Gradient(colors: [.blue, .teal]), startPoint: .top, endPoint: .bottom)
                }
                .foregroundColor(.white)
                .onAppear {
                    if !showSettings {
                        DispatchQueue.main.async {
                          self.viewModel.loadWeatherData()
                        }
                    }
                }
                .alert(isPresented: $viewModel.isLocationPermissionDenied) {
                    Alert(
                            title: Text("Location Permission Required"),
                            message: Text("Please allow location access for weather updates."),
                            primaryButton: .default(Text("Open System Preferences")) {
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
                                    NSWorkspace.shared.open(url)
                                }
                            },
                            secondaryButton: .cancel()
                    )
                }


    }
}
