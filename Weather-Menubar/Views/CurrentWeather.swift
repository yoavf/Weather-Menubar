import SwiftUI

struct CurrentWeather: View {

    var temperature: Double
    var weatherIcon: String

    var body: some View {
        HStack {
            Text(String(format: "%.0f°", temperature))
                    .font(.system(size: 23, weight: .light, design: .default))
                    .clipped()
            Image(systemName: weatherIcon)
                    .imageScale(.large)
            Spacer()
        }
                .padding(.top, 4)
    }
}


