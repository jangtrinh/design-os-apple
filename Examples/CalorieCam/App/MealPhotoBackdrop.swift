import SwiftUI
import DesignOSApple

/// Only the user's currently selected photo supplies atmosphere. Text-only entries use
/// an honest solid fallback; the kit owns contrast and Reduce Transparency behavior.
struct MealPhotoBackdrop: View {
    @Environment(\.designOSAppStyle) private var style
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let preview: Image?

    private var renderingFacts: String {
        "photo=\(preview != nil) dark=\(colorScheme == .dark) reduceTransparency=\(reduceTransparency) increasedContrast=\(contrast == .increased) opaqueOnly=\(style.profile.accessibility.translucency == .opaqueOnly)"
    }

    var body: some View {
        Group {
            if let preview {
                DesignOSMediaBackdrop {
                    preview.resizable().scaledToFill()
                }
            } else {
                style.palette.canvas.color.ignoresSafeArea()
            }
        }
        .task(id: renderingFacts) {
            #if DEBUG
            // Rendering diagnostics only: no meal data, photo bytes or user identifiers.
            // Record actual CI settings; never override accessibility for a screenshot.
            print("CalorieCamRenderEnvironment \(renderingFacts)")
            #endif
        }
    }
}
