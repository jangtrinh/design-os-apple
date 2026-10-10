import SwiftUI
import DesignOSApple

/// Constrain and round the rendered image itself, not an expanding transparent frame.
/// The square crop follows the media reference while original bytes remain unchanged.
struct MealPhotoCover: View {
    @Environment(\.designOSAppStyle) private var style
    let image: Image
    var maximumSize: CGFloat = 240
    let label: String
    var identifier: String = ""

    var body: some View {
        GeometryReader { geometry in
            image.resizable().scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipShape(RoundedRectangle(cornerRadius: style.metrics.surfaceRadius, style: .continuous))
                .accessibilityLabel(label)
                .accessibilityIdentifier(identifier)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: maximumSize)
        .frame(maxWidth: .infinity)
    }
}
