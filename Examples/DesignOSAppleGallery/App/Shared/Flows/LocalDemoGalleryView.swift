import SwiftUI

struct LocalDemoGalleryView: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        ForEach(LocalDemoSection.allCases, id: \.self) { section in
          demoSection(section)
        }
      }
      .frame(maxWidth: 760)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
    }
    .navigationTitle("Mini Apps")
    .accessibilityIdentifier("design-os.gallery.examples.ready")
  }

  private var columns: [GridItem] {
    let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
    return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: count)
  }

  private func demoSection(_ section: LocalDemoSection) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(section.rawValue)
        .font(.title2.bold())
        .accessibilityAddTraits(.isHeader)

      LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
        ForEach(LocalDemoDefinition.demos(in: section)) { demo in
          NavigationLink(value: demo.entryDestination) {
            LocalDemoCard(demo: demo)
          }
          .buttonStyle(.plain)
          .localDemoTransitionSource(demo.entryDestination)
          .accessibilityIdentifier("design-os.gallery.\(demo.id)")
          .accessibilityLabel("\(demo.title). \(demo.flowLabel).")
        }
      }
    }
  }
}

private struct LocalDemoCard: View {
  let demo: LocalDemoDefinition

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      thumbnail

      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(demo.title)
          .font(.headline)
          .foregroundStyle(.primary)
          .lineLimit(1)
        Spacer(minLength: 2)
        Image(systemName: "chevron.right")
          .font(.caption.bold())
          .foregroundStyle(tint)
      }

      Text(demo.flowLabel)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
    .padding(10)
    .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
    .contentShape(RoundedRectangle(cornerRadius: 16))
  }

  private var thumbnail: some View {
    Image(demo.imageAssetName)
      .resizable()
      .scaledToFill()
      .aspectRatio(4 / 3, contentMode: .fit)
      .frame(maxWidth: .infinity)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.primary.opacity(0.08), lineWidth: 1)
      }
      .accessibilityHidden(true)
  }

  private var tint: Color {
    switch demo.tint {
    case .amber: Color(red: 0.80, green: 0.36, blue: 0.10)
    case .spectral: Color(red: 0.34, green: 0.38, blue: 0.94)
    case .flightBlue: Color(red: 0.12, green: 0.43, blue: 0.95)
    case .cityGreen: Color(red: 0.00, green: 0.65, blue: 0.39)
    case .cinemaRed: Color(red: 0.82, green: 0.08, blue: 0.12)
    case .electricBlue: Color(red: 0.00, green: 0.48, blue: 1.00)
    }
  }
}
