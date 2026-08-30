import DesignOSApple
import SwiftUI

struct TocChienDictionarySearchStory: View {
  @FocusState private var isSearchFocused: Bool
  @State private var query = ""

  private var entries: [TocChienDictionaryEntry] {
    Self.filteredEntries(TocChienDictionaryFixtures.entries, query: query)
  }

  var body: some View {
    if #available(iOS 18, macOS 15, *) {
      dictionaryList
        .searchable(text: $query, prompt: "Tra từ điển")
        .searchFocused($isSearchFocused)
    } else {
      dictionaryList
        .searchable(text: $query, prompt: "Tra từ điển")
    }
  }

  private var dictionaryList: some View {
    List(entries) { entry in
      DesignOSListRow {
        Text(entry.term)
          .font(.headline)
      } subtitle: {
        Text(entry.description)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityIdentifier("design-os.tocchien.dictionary.description.\(entry.id)")
          .accessibilityLabel("Dictionary description")
          .accessibilityValue(entry.description)
      } trailing: {
        EmptyView()
      }
    }
    .overlay {
      if entries.isEmpty {
        VStack {
          ContentUnavailableView.search(text: query)
          Text("No dictionary matches")
            .accessibilityIdentifier("design-os.tocchien.dictionary.empty")
        }
      }
    }
    .navigationTitle("Từ điển thử nghiệm")
  }

  nonisolated static func filteredEntries(
    _ entries: [TocChienDictionaryEntry], query: String
  ) -> [TocChienDictionaryEntry] {
    guard !query.isEmpty else { return entries }
    return entries.filter {
      $0.term.localizedCaseInsensitiveContains(query)
        || $0.description.localizedCaseInsensitiveContains(query)
    }
  }
}
