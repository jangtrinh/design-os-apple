import SwiftUI
import DesignOSApple

/// Only the user's currently selected photo supplies atmosphere. Text-only entries use
/// an honest solid fallback; the kit owns contrast and Reduce Transparency behavior.
struct MealPhotoBackdrop: View {
    @Environment(\.designOSAppStyle) private var style
    let preview: Image?

    var body: some View {
        if let preview {
            DesignOSMediaBackdrop {
                preview.resizable().scaledToFill()
            }
        } else {
            style.palette.canvas.color.ignoresSafeArea()
        }
    }
}
