import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

struct DogfoodCatalogView: View {
  enum ColumnMode: Equatable {
    case single
    case adaptive
  }

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var query = ""

  nonisolated static var contentPadding: CGFloat { GalleryDesignFloor.compactGutter }

  private var stories: [DesignOSStoryDescriptor] {
    Self.filteredStories(DesignOSReleaseCatalog.stories, query: query)
  }

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
        ForEach(CatalogStorySection.allCases) { section in
          let sectionStories = stories.filter {
            CatalogStorySection.section(for: $0.id) == section
          }
          if !sectionStories.isEmpty {
            Section {
              ForEach(sectionStories, id: \.id) { descriptor in
                NavigationLink(
                  value: DesignOSStorySelection(descriptor: descriptor, profile: .default)
                ) {
                  DogfoodCatalogCard(descriptor: descriptor, presentation: cardPresentation)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(
                  "design-os.gallery.catalog.story.\(descriptor.id.rawValue)"
                )
              }
            } header: {
              Text(section.rawValue)
                .font(DesignOSTypographyRole.title2.emphasized().font)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, section == .foundations ? 0 : 12)
            }
          }
        }
      }
      .frame(maxWidth: contentMaxWidth, alignment: .leading)
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(Self.contentPadding)
    }
    .overlay {
      if stories.isEmpty {
        ContentUnavailableView.search(text: query)
      }
    }
    .navigationTitle("Catalog")
    .searchable(text: $query, prompt: "Search stories and keywords")
    .accessibilityIdentifier("design-os.gallery.catalog.ready")
  }

  private var columns: [GridItem] {
    if cardPresentation == .compactRow {
      return [GridItem(.flexible(), spacing: 16)]
    }
    switch Self.columnMode(for: dynamicTypeSize) {
    case .single:
      return [GridItem(.flexible(), spacing: 16)]
    case .adaptive:
      return [GridItem(.adaptive(minimum: 260, maximum: 360), spacing: 16)]
    }
  }

  private var cardPresentation: DogfoodCatalogCard.Presentation {
    Self.cardPresentation(
      horizontalSizeClass: horizontalSizeClass,
      dynamicTypeSize: dynamicTypeSize,
      isSearching: !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    )
  }

  private var contentMaxWidth: CGFloat {
    cardPresentation == .card
      ? GalleryDesignFloor.catalogMaxWidth
      : GalleryDesignFloor.detailMaxWidth
  }

  nonisolated static func columnMode(for dynamicTypeSize: DynamicTypeSize) -> ColumnMode {
    dynamicTypeSize.isAccessibilitySize ? .single : .adaptive
  }

  nonisolated static func cardPresentation(
    horizontalSizeClass: UserInterfaceSizeClass?,
    dynamicTypeSize: DynamicTypeSize,
    isSearching: Bool
  ) -> DogfoodCatalogCard.Presentation {
    if dynamicTypeSize.isAccessibilitySize {
      return .accessibilityCard
    }
    if isSearching || horizontalSizeClass == .compact {
      return .compactRow
    }
    return .card
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
        || descriptor.discovery.primaryKeyword.localizedCaseInsensitiveContains(needle)
        || descriptor.discovery.aliases.contains {
          $0.localizedCaseInsensitiveContains(needle)
        }
        || descriptor.discovery.intentQueries.contains {
          $0.localizedCaseInsensitiveContains(needle)
        }
    }
  }
}
