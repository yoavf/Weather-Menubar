import SwiftUI
import Foundation
import Pow

struct ContentView: View {
    @State private var showSettings = false
    @AppStorage("apiKey") private var apiKey: String = ""

    var body: some View {

        ZStack {
            if showSettings {
                Settings(showSettings: $showSettings).transition(.opacity)
            } else {
                WeatherView(showSettings: $showSettings)
            }
        }
                .background(Color.clear)
                .ignoresSafeArea()
                .padding(.horizontal, 16)
                .frame(width: 270, height: 160)
                .onAppear {
                    if apiKey.isEmpty {
                        showSettings = true
                    }
                }


    }

}
