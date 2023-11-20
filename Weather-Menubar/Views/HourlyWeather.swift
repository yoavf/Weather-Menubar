import SwiftUI

struct HourlyWeather: View {

    var interval: Interval
    var isDayTime: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(interval.formatStartTime())
                    .font(.system(.caption2, weight: .medium))
                    .opacity(0.8)
            Image(systemName: interval.values.systemImageName(isDaytime: isDayTime))
                    .symbolRenderingMode(.monochrome)
                    .frame(height: 32)
                    .clipped()
            Text(String(format: "%.0f°", interval.values.temperature))
                    .font(.system(.footnote, weight: .medium))
        }
    }
}


