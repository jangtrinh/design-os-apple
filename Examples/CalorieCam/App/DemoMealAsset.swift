import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// A single explicit bundle loader for the synthetic sample. Raw-resource name lookup
/// differs between UIKit/AppKit; use the same verified bytes as the working sample flow.
@MainActor
enum DemoMealAsset {
    static let data: Data? = {
        guard let url = Bundle.main.url(forResource: "DemoMeal", withExtension: "png") else { return nil }
        return try? Data(contentsOf: url)
    }()

    static let image: Image? = {
        guard let data else { return nil }
        #if os(iOS)
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
        #elseif os(macOS)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image)
        #endif
    }()
}
