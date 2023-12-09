import SwiftUI

@main
struct Weather_Tomorrow_ioApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        }
        label: {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(named: "tm-icon")!)

            Image(nsImage: image)
        }

                .menuBarExtraStyle(.window)
    }
}
