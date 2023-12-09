import SwiftUI

struct Settings: View {
    @Binding var showSettings: Bool

    @AppStorage("apiKey") private var apiKey: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Settings").font(.system(.subheadline, weight: .semibold))
                Spacer()
            }
                    .padding(.top)
                    .padding(.bottom, 4)
            TextField("API Key", text: $apiKey, prompt: Text("API Key"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
            Button(action: {
                withAnimation {
                    showSettings.toggle()
                }
            }) {
                Text("Save")
            }
                    .disabled(apiKey.isEmpty)
            HStack {
                let link = "[Click here](https://app.tomorrow.io/development/keys)"
                (Text(.init(link)) + Text(" ")
                        + Text(Image(systemName:"arrowshape.turn.up.right"))
                        + Text( "  to get your Tomorrow.io API key"))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.caption2, weight: .medium))
                        .padding(.top)
                Spacer()
            }
        }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                .frame(width: 270, height: 160)
                .background {
                    LinearGradient(gradient: Gradient(colors: [.blue, .teal]), startPoint: .top, endPoint: .bottom)
                }
                .foregroundColor(.white)

    }

}
