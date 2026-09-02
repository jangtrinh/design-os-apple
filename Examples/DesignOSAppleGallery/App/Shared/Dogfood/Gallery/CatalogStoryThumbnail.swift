import DesignOSAppleCatalog
import SwiftUI

struct CatalogStoryThumbnail: View {
  let storyID: DesignOSStoryID

  nonisolated static func assetName(for storyID: DesignOSStoryID) -> String {
    "catalog-\(storyID.rawValue.replacingOccurrences(of: ".", with: "-"))"
  }

  var body: some View {
    GeometryReader { proxy in
      Image(Self.assetName(for: storyID))
        .resizable()
        .interpolation(.high)
        .aspectRatio(4 / 3, contentMode: .fill)
        .frame(width: proxy.size.width, height: proxy.size.height)
        .clipped()
    }
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(.secondary.opacity(0.25), lineWidth: 0.5)
    }
    .clipShape(.rect(cornerRadius: 12))
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
