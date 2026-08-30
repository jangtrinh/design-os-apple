import SwiftUI

struct TocChienNavigationTabsStory: View {
  private enum Destination: Hashable {
    case overview
    case activity
  }

  @State private var selection: Destination = .overview

  var body: some View {
    TabView(selection: $selection) {
      overview
        .tabItem { Label("Tổng quan", systemImage: "rectangle.grid.2x2") }
        .tag(Destination.overview)
      activity
        .tabItem { Label("Hoạt động", systemImage: "chart.line.uptrend.xyaxis") }
        .tag(Destination.activity)
    }
  }

  private var overview: some View {
    ContentUnavailableView(
      "Tổng quan thử nghiệm",
      systemImage: "rectangle.grid.2x2",
      description: Text("Đích đến cục bộ dùng để kiểm tra TabView bản địa.")
    )
  }

  private var activity: some View {
    VStack(spacing: 12) {
      ContentUnavailableView(
        "Hoạt động nội bộ",
        systemImage: "chart.line.uptrend.xyaxis",
        description: Text("Nội dung của tab thứ hai được chọn bởi trạng thái bản địa.")
      )
      Text("Second native tab content")
        .accessibilityIdentifier("design-os.tocchien.navigation-tabs.activity.content")
    }
  }
}
