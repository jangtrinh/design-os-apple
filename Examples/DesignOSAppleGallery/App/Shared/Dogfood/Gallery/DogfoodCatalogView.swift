import DesignOSAppleCatalog
import SwiftUI

struct DogfoodCatalogView: View {
  @State private var query = ""

  private var stories: [DesignOSStoryDescriptor] {
    Self.filteredStories(DesignOSReleaseCatalog.stories, query: query)
  }

  var body: some View {
    List {
      Section("Admitted stories") {
        ForEach(stories, id: \.id) { descriptor in
          NavigationLink(value: descriptor) {
            DogfoodCatalogRow(descriptor: descriptor)
          }
          .accessibilityIdentifier("design-os.gallery.catalog.story.\(descriptor.id.rawValue)")
        }
      }
    }
    .overlay {
      if stories.isEmpty {
        ContentUnavailableView.search(text: query)
      }
    }
    .navigationTitle("Catalog")
    .searchable(text: $query, prompt: "Search admitted stories")
    .accessibilityIdentifier("design-os.gallery.catalog.ready")
  }

  nonisolated static func filteredStories(
    _ stories: [DesignOSStoryDescriptor],
    query: String
  ) -> [DesignOSStoryDescriptor] {
    let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !needle.isEmpty else { return stories }
    return stories.filter { descriptor in
      descriptor.id.rawValue.localizedCaseInsensitiveContains(needle)
        || descriptor.title.localizedCaseInsensitiveContains(needle)
        || descriptor.summary.localizedCaseInsensitiveContains(needle)
    }
  }
}

private struct DogfoodCatalogRow: View {
  let descriptor: DesignOSStoryDescriptor

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(descriptor.title)
        .font(.headline)
      Text(descriptor.summary)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
      Text(ownerLabel)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(descriptor.id.rawValue)
        .font(.caption.monospaced())
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 2)
  }

  private var ownerLabel: String {
    switch descriptor.owner {
    case .runtimeImplementation: "Runtime implementation"
    case .appSpecific: "App-specific fixture"
    }
  }
}
