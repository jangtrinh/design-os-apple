import SwiftUI

struct StreamingLibraryTabBar: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding var selectedTab: StreamingLibraryTab

  var body: some View {
    HStack {
      tab("house.fill", .home)
      Spacer()
      tab("square.stack.3d.up.fill", .newAndHot)
      Spacer()
      tab("person.crop.rectangle.stack.fill", .myLibrary)
    }
    .padding(.horizontal, 38)
    .padding(.top, 7)
    .padding(.bottom, 5)
    .background {
      tabBarBackground
        .ignoresSafeArea(edges: .bottom)
    }
  }

  private var tabBarBackground: some View {
    Rectangle().fill(EntertainmentTheme.panel)
  }

  private func tab(_ symbol: String, _ tab: StreamingLibraryTab) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        selectedTab = tab
      }
    } label: {
      VStack(spacing: 2) {
        Image(systemName: symbol).font(.caption)
        Text(tab.title).font(.caption)
      }
      .frame(minWidth: 72, minHeight: 44)
      .contentShape(Rectangle())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .foregroundStyle(selectedTab == tab ? .white : EntertainmentTheme.subdued)
    .accessibilityValue(selectedTab == tab ? "Selected" : "Not selected")
    .accessibilityIdentifier(
      "design-os.demo.entertainment.streaming-library.tab.\(tab.rawValue)")
  }
}

enum StreamingLibraryTab: String, CaseIterable {
  case home
  case newAndHot
  case myLibrary

  var title: String {
    switch self {
    case .home: "Home"
    case .newAndHot: "New & Hot"
    case .myLibrary: "My Library"
    }
  }

  var navigationTitle: String { self == .home ? "For You" : title }
}
