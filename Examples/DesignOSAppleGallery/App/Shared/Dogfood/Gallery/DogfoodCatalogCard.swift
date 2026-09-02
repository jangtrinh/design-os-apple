import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

struct DogfoodCatalogCard: View {
  enum Presentation: Equatable {
    case compactRow
    case card
    case accessibilityCard
  }

  let descriptor: DesignOSStoryDescriptor
  let presentation: Presentation

  var body: some View {
    Group {
      switch presentation {
      case .compactRow: compactRow
      case .card: card
      case .accessibilityCard: accessibilityCard
      }
    }
    .frame(minHeight: GalleryDesignFloor.minimumHitTarget)
    .contentShape(.rect(cornerRadius: GalleryDesignFloor.surfaceRadius))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(descriptor.title)
    .accessibilityValue("\(descriptor.summary). Keyword: \(descriptor.discovery.primaryKeyword)")
  }

  private var compactRow: some View {
    HStack(spacing: 12) {
      CatalogStoryThumbnail(storyID: descriptor.id)
        .frame(width: 88, height: 64)

      VStack(alignment: .leading, spacing: 4) {
        Text(descriptor.title)
          .font(DesignOSTypographyRole.headline.font)
          .foregroundStyle(DesignOSColorRole.labelPrimary.color)
        Text(descriptor.summary)
          .font(DesignOSTypographyRole.subheadline.font)
          .foregroundStyle(DesignOSColorRole.labelSecondary.color)
          .fixedSize(horizontal: false, vertical: true)
        keyword
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.tint)
    }
    .padding(12)
    .background(DesignOSColorRole.backgroundPrimary.color)
    .clipShape(.rect(cornerRadius: GalleryDesignFloor.surfaceRadius))
    .overlay { cardBorder }
  }

  private var card: some View {
    verticalCard(thumbnailHeight: 144, showsChevron: true)
  }

  private var accessibilityCard: some View {
    verticalCard(thumbnailHeight: 96, showsChevron: false)
  }

  private func verticalCard(thumbnailHeight: CGFloat, showsChevron: Bool) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      CatalogStoryThumbnail(storyID: descriptor.id)
        .frame(height: thumbnailHeight)
        .padding(4)

      VStack(alignment: .leading, spacing: 8) {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(descriptor.title)
            .font(DesignOSTypographyRole.headline.font)
            .foregroundStyle(DesignOSColorRole.labelPrimary.color)
          if showsChevron {
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
              .font(.caption.weight(.semibold))
              .foregroundStyle(.tint)
          }
        }
        Text(descriptor.summary)
          .font(DesignOSTypographyRole.subheadline.font)
          .foregroundStyle(DesignOSColorRole.labelSecondary.color)
          .fixedSize(horizontal: false, vertical: true)
        keyword
      }
      .padding(.horizontal, 12)
      .padding(.top, 8)
      .padding(.bottom, 12)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(DesignOSColorRole.backgroundPrimary.color)
    .clipShape(.rect(cornerRadius: GalleryDesignFloor.surfaceRadius))
    .overlay { cardBorder }
  }

  private var keyword: some View {
    Text("Ask AI: \(descriptor.discovery.primaryKeyword)")
      .font(.system(.caption, design: .monospaced, weight: .medium))
      .foregroundStyle(DesignOSColorRole.labelSecondary.color)
  }

  private var cardBorder: some View {
    RoundedRectangle(cornerRadius: GalleryDesignFloor.surfaceRadius)
      .stroke(DesignOSColorRole.separator.color)
  }
}
