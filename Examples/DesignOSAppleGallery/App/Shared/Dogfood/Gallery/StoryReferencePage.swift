import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

struct StoryReferencePage: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let selection: DesignOSStorySelection
  let content: StoryReferenceContent
  let primaryKeyword: String
  let kindLabel: String
  let ownershipLabel: String
  let platformFacts: [StoryReferenceFact]
  let relatedStories: [DesignOSStoryDescriptor]

  private var descriptor: DesignOSStoryDescriptor { selection.descriptor }
  @State private var isInteractivePreviewPresented = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: GalleryDesignFloor.sectionSpacing) {
        header
        liveExample
        applicationGuidance
        codeExample
        contract
        continueLearning
      }
      .padding(.horizontal, GalleryDesignFloor.compactGutter)
      .padding(.vertical, 20)
      .frame(maxWidth: GalleryDesignFloor.detailMaxWidth, alignment: .leading)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .accessibilityIdentifier("design-os.gallery.story.\(descriptor.id.rawValue).ready")
    #if os(iOS)
      .fullScreenCover(isPresented: $isInteractivePreviewPresented) {
        interactivePreviewCanvas
      }
    #else
      .sheet(isPresented: $isInteractivePreviewPresented) {
        interactivePreviewCanvas
      }
    #endif
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 12) {
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 8) { referenceBadges }
        VStack(alignment: .leading, spacing: 8) { referenceBadges }
      }

      Text(descriptor.title)
        .font(DesignOSTypographyRole.largeTitle.emphasized().font)
        .foregroundStyle(DesignOSColorRole.labelPrimary.color)

      Text(content.whatItIs)
        .font(DesignOSTypographyRole.body.font)
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
        .fixedSize(horizontal: false, vertical: true)

      ViewThatFits(in: .horizontal) {
        HStack(alignment: .center, spacing: 12) {
          keywordIdentity
          Spacer(minLength: 4)
          keywordCopyButton
        }
        VStack(alignment: .leading, spacing: 8) {
          keywordIdentity
          keywordCopyButton
        }
      }
      .overlay(alignment: .bottom) { Divider() }
    }
  }

  @ViewBuilder
  private var referenceBadges: some View {
    StoryReferenceBadge(label: kindLabel)
    StoryReferenceBadge(label: ownershipLabel)
  }

  private var keywordIdentity: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("AI keyword")
        .font(DesignOSTypographyRole.caption.emphasized().font)
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
      Text(primaryKeyword)
        .font(.system(.callout, design: .monospaced, weight: .semibold))
        .textSelection(.enabled)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 8)
  }

  private var keywordCopyButton: some View {
    StoryReferenceCopyButton(
      value: primaryKeyword,
      label: "Copy keyword",
      identifier: "design-os.reference.\(descriptor.id.rawValue).copy-keyword"
    )
  }

  private var liveExample: some View {
    StoryReferenceSection("Live example") {
      Group {
        switch content.preview {
        case .intrinsic:
          DogfoodStoryRenderer.render(descriptor: descriptor)
            .frame(maxWidth: .infinity, alignment: .leading)
        case .bounded(let height):
          boundedPreview(height: height.rawValue)
        case .destination:
          Button {
            isInteractivePreviewPresented = true
          } label: {
            VStack(alignment: .leading, spacing: 12) {
              CatalogStoryThumbnail(storyID: descriptor.id)
                .frame(maxHeight: 220)
              Label("Open interactive example", systemImage: "arrow.up.right.square")
                .font(DesignOSTypographyRole.headline.font)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(16)
      .background(DesignOSColorRole.backgroundSecondary.color)
      .clipShape(.rect(cornerRadius: 16))
    }
    .accessibilityIdentifier("design-os.reference.\(descriptor.id.rawValue).preview")
  }

  @ViewBuilder
  private func boundedPreview(height: CGFloat) -> some View {
    if dynamicTypeSize.isAccessibilitySize {
      DogfoodStoryRenderer.render(descriptor: descriptor)
        .scrollDisabled(true)
        .frame(maxWidth: .infinity, minHeight: height)
    } else {
      DogfoodStoryRenderer.render(descriptor: descriptor)
        .scrollDisabled(true)
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .clipped()
    }
  }

  private var applicationGuidance: some View {
    StoryReferenceSection("Apply it") {
      ViewThatFits(in: .horizontal) {
        HStack(alignment: .top, spacing: 24) { guidanceItems }
        VStack(alignment: .leading, spacing: 20) { guidanceItems }
      }
    }
    .accessibilityIdentifier("design-os.reference.\(descriptor.id.rawValue).apply")
  }

  @ViewBuilder
  private var guidanceItems: some View {
    StoryReferenceGuidance(title: "Use when", detail: content.useWhen)
      .frame(maxWidth: .infinity, alignment: .leading)
    StoryReferenceGuidance(title: "Avoid when", detail: content.avoidWhen)
      .frame(maxWidth: .infinity, alignment: .leading)
    StoryReferenceGuidance(title: "Where it belongs", detail: content.placement)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var codeExample: some View {
    StoryReferenceSection("SwiftUI") {
      StoryReferenceCodeBlock(storyID: descriptor.id, code: content.code)
    }
  }

  private var contract: some View {
    StoryReferenceSection("Contract") {
      VStack(spacing: 0) {
        ForEach(content.contract + platformFacts) { fact in
          StoryReferenceFactRow(fact: fact)
            .padding(.vertical, 8)
          if fact.id != (content.contract + platformFacts).last?.id { Divider() }
        }
      }
    }
  }

  private var continueLearning: some View {
    StoryReferenceSection("Continue") {
      VStack(alignment: .leading, spacing: 12) {
        StoryReferenceSourceRow(label: "Story ID", value: descriptor.id.rawValue)
        StoryReferenceSourceRow(label: "Compiled example", value: descriptor.examplePath)
        ForEach(relatedStories, id: \.id) { story in
          NavigationLink(
            value: DesignOSStorySelection(descriptor: story, profile: selection.profile)
          ) {
            Label(story.title, systemImage: "arrow.right.circle")
              .frame(
                maxWidth: .infinity,
                minHeight: GalleryDesignFloor.minimumHitTarget,
                alignment: .leading
              )
              .contentShape(.rect)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private var interactivePreviewCanvas: some View {
    ZStack(alignment: .topTrailing) {
      if descriptor.id == .navigationTabsAndToolbars {
        DogfoodStoryCanvas(descriptor: descriptor)
          .designOSProfile(selection.profile)
      } else {
        NavigationStack {
          DogfoodStoryCanvas(descriptor: descriptor)
            .designOSProfile(selection.profile)
            .navigationTitle(descriptor.title)
        }
      }

      Button {
        isInteractivePreviewPresented = false
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(DesignOSTypographyRole.title2.font)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(DesignOSColorRole.labelSecondary.color)
          .frame(
            minWidth: GalleryDesignFloor.minimumHitTarget,
            minHeight: GalleryDesignFloor.minimumHitTarget
          )
          .contentShape(.rect)
          .padding(16)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Dismiss interactive example")
      .accessibilityIdentifier("design-os.navigation.action.dismiss-preview")
    }
  }
}
