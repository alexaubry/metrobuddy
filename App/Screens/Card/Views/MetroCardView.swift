import SwiftUI

/// A view that mimics the appearance of a Metro Card, and displays its current balance.
struct MetroCardView: View {
    let formattedBalance: String

    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(formattedBalance)
                .font(.cardBalance)
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            Spacer()
            Rectangle()
                .foregroundColor(.black)
                .frame(height: 40)
                .padding(.bottom, 8)

            Image.Assets.metroCardArrows
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 12)
                .padding(.bottom, 8)
        }.background(
            LinearGradient(
                gradient: Gradient(colors: [.metroCardYellow, .metroCardOrange]),
                startPoint: .top,
                endPoint: .bottom
            )
        ).aspectRatio(1.585, contentMode: .fill)
        .fixedSize(horizontal: false, vertical: true)
        .mask(MetroCardShape())
        .accessibilityElement(children: .ignore)
        .accessibility(addTraits: .isButton)
        .accessibility(label: Text("Card Balance"))
        .accessibility(value: Text(formattedBalance))
        .accessibility(addTraits: .isButton)
        .accessibility(identifier: "card")
    }
}
