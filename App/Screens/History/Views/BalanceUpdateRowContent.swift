import MetroKit
import SwiftUI

/// The view displayed inside a row with the contents of a balance update.
struct BalanceUpdateRowContent: View {
    let item: BalanceUpdateListItem

    var body: some View {
        FlexibleStack(hStackAlignment: .center, vStackAlignment: .leading) { axis in
            Image.updateSymbol(for: item.updateType)
                .accentColor(.accentColor)

            VStack(alignment: .leading) {
                Text(item.formattedAmount)
                    .foregroundColor(Color(.label))
                    .fontWeight(.semibold)

                item.updateType
                    .text
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if axis == .horizontal {
                Spacer()
            }

            Text(item.formattedTimestamp)
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: item.updateType.text)
        .accessibility(value: Text("\(item.formattedAmount), \(item.formattedTimestamp)"))
    }
}

// MARK: - Helpers

extension Image {
    static func updateSymbol(for updateType: BalanceUpdate.UpdateType) -> Image {
        let image: Image = {
            switch updateType {
            case .unknown:
                return Image(systemName: "plus.circle.fill")
            case .adjustment:
                return Image(systemName: "plusminus.circle.fill")
            case .reload:
                return Image(systemName: "plus.circle.fill")
            case .swipe:
                return Image(systemName: "tram.fill")
            }
        }()

        return image
    }
}

extension BalanceUpdate.UpdateType {
    var text: Text {
        switch self {
        case .unknown:
            return Text("Update")
        case .adjustment:
            return Text("Adjustment")
        case .reload:
            return Text("Reload")
        case .swipe:
            return Text("Swipe")
        }
    }
}
