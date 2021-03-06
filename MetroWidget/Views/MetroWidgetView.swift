import WidgetKit
import SwiftUI
import MetroUI

/// The main view of the widget.
struct MetroWidgetView : View {
    var entry: MetroTimelineEntry
    @Environment(\.widgetFamily) var widgetFamily

    // MARK: - Initialization

    init(entry: MetroTimelineEntry) {
        self.entry = entry
    }

    // MARK: - View

    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .center, spacing: widgetFamily.isCompact ? 16 : 0) {
                Spacer()

                Text(verbatim: entry.cardStatus.balance)
                    .font(.cardBalance)
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .enableRedaction(entry.cardStatus.isPlaceholder)

                if !widgetFamily.isCompact {
                    Spacer()
                }

                HStack {
                    Spacer()

                    Image.Assets.singleArrow
                        .padding(.leading, -12)

                    Text(verbatim: entry.cardStatus.remainingRides)
                        .foregroundColor(.white)
                        .font(textStyle: .body, maximumPointSize: 30)
                        .minimumScaleFactor(0.1)

                    Spacer()
                }.padding(.vertical, 12)
                .enableRedaction(entry.cardStatus.isPlaceholder)
                .background(Color.black.padding(.horizontal, -20))
            }

            Spacer()
        }.background(MetroWidgetBackgroundView())
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("MetroCard Balance"))
        .accessibility(value: Text(verbatim: entry.cardStatus.accessibilityValue))
        .accessibility(hidden: entry.cardStatus.isPlaceholder)
    }
}
