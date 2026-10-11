import DesignOSApple
import SwiftUI

struct ExtendedSpecimenContent: View {
    let specimen: Specimen
    let variant: PreviewState
    let photo: Image?
    @Environment(\.designOSAppStyle) private var style
    @State private var query = ""
    @State private var selection: Int?
    @State private var note = "Bring something you enjoy sharing. This is original fixture text."
    @State private var draft = ""
    @State private var messages = ["Welcome to the local preview.", "These messages never leave this app."]
    @State private var confirmed = false
    @State private var showAlert = false
    @State private var zoom = 1.0
    @State private var showTips = true

    var body: some View {
        Group {
            switch specimen {
            case .onboarding:
                DesignOSOnboardingScreen {
                    hero
                } introduction: {
                    heading("Welcome to your neighborhood")
                    Text("Discover a friendly gathering using this local fixture.")
                } choices: {
                    DesignOSChoiceRow {
                        Image(systemName: "lightbulb").accessibilityHidden(true)
                    } description: {
                        Text("Optional local tips")
                        Text("No account or permission is required in the preview.")
                    } control: {
                        Toggle("Show tips", isOn: $showTips).accessibilityIdentifier("choiceTips")
                    }
                } action: { localAction }
            case .discovery:
                DesignOSDiscoveryScreen {
                    heading("Find your next gathering")
                } rails: {
                    DesignOSCategoryRail(FixtureCategory.all) {
                        Text("Browse categories").font(.headline).accessibilityAddTraits(.isHeader)
                    } item: { category in
                        Button(category.title) { query = category.title }
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .accessibilityIdentifier("category-\(category.id)")
                    } empty: { Text("No fixture categories") }
                } sections: {
                    heading(query.isEmpty ? "Nearby fixtures" : query).accessibilityIdentifier("selectedCategory")
                    hero
                    Text("Community lunch · Saturday")
                    stateFeedback
                }
            case .profileDetail:
                DesignOSProfileDetailScreen(media: photo) {
                    hero
                } identity: {
                    DesignOSIdentityHeader {
                        DesignOSAvatar { Image(systemName: "person.crop.circle.fill").resizable().scaledToFit() }
                    } title: { heading("Neighborhood studio") }
                    metadata: { Text("Original fictional organization") }
                    actions: { localAction }
                } summary: {
                    DesignOSLabeledValueRow("Gatherings", value: { Text("4 fixture events") })
                } sections: { Text("A shared space for small creative gatherings."); stateFeedback }
            case .heroCollection:
                DesignOSHeroCollectionScreen { hero } introduction: {
                    heading("Good food, good company")
                } rows: {
                    ForEach(1..<4) { number in
                        DesignOSLabeledValueRow("Gathering", value: { Text("Local fixture \(number)") })
                    }
                }
            case .freeformEditor:
                DesignOSFreeformEditorScreen("Gathering description", text: $note) {
                    Text("Local unsaved draft · \(note.count) characters").accessibilityIdentifier("editorCount")
                }
            case .searchSelection:
                DesignOSSearchSelectionScreen(query: $query, selection: $selection,
                    showsStatus: variant != .populated) {
                    ForEach(1..<5) { number in
                        if query.isEmpty || "Gathering \(number)".localizedCaseInsensitiveContains(query) {
                            Text("Gathering \(number)").tag(number).accessibilityIdentifier("choice-\(number)")
                        }
                    }
                } status: { stateFeedback }
                .safeAreaInset(edge: .bottom) {
                    DesignOSSelectionSummary {
                        Text(selection.map { "Selected gathering \($0)" } ?? "Select a gathering")
                            .accessibilityIdentifier("selectionReceipt")
                    } actions: {
                        Button("Clear selection") { selection = nil }
                            .buttonStyle(DesignOSSecondaryButtonStyle()).disabled(selection == nil)
                            .accessibilityIdentifier("clearFixtureSelection")
                    }.padding()
                }
            case .confirmation:
                DesignOSConfirmationScreen {
                    heading("Clear the local draft?")
                    Text("Only this preview's in-memory fixture will be cleared.")
                } details: { Text(confirmed ? "Local draft cleared" : note) } actions: {
                    Button("Clear local draft", role: .destructive) { note = ""; confirmed = true }
                        .buttonStyle(DesignOSSecondaryButtonStyle()).disabled(confirmed)
                }
            case .status:
                DesignOSStatusScreen {
                    Image(systemName: variant == .error ? "exclamationmark.circle" : "checkmark.circle")
                        .font(.largeTitle).accessibilityHidden(true)
                } message: { heading("Preview status") } details: { stateFeedback } actions: { localAction }
            case .messageThread:
                DesignOSMessageThreadScreen { _ in
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            DesignOSMessageBubble(isOutgoing: index > 0, outgoingAppearance: .emphasized) {
                                Text(message)
                            } metadata: {
                                Text(index > 0 ? "Added locally" : "Original local fixture").font(.caption)
                            }.id(index)
                        }
                    }
                } status: { Text("Local conversation fixture").font(.caption) } composer: {
                    DesignOSConversationComposer {
                        EmptyView()
                    } input: {
                        TextField("Local message", text: $draft, axis: .vertical)
                            .lineLimit(1...4)
                            .modifier(DesignOSAppTextFieldModifier(multiline: true))
                            .accessibilityIdentifier("messageDraft")
                    } actions: {
                        Button("Add locally") { messages.append(draft); draft = "" }
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .accessibilityIdentifier("addLocalMessage")
                    } feedback: { Text("No delivery service is connected.").font(.caption) }
                }
            case .utilityCanvas:
                DesignOSUtilityCanvasScreen {
                    GeometryReader { geometry in
                        if let photo {
                            photo.resizable().scaledToFit().scaleEffect(zoom)
                                .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                                .accessibilityLabel("Zoomable original fixture photograph")
                        } else { ContentUnavailableView("No fixture image", systemImage: "photo") }
                    }
                } status: {
                    DesignOSUtilityOverlay {
                        Text("Local photo canvas · no camera access")
                    } actions: {
                        Button("Reset zoom") { zoom = 1 }
                            .buttonStyle(DesignOSSecondaryButtonStyle()).accessibilityIdentifier("resetPhotoZoom")
                    }
                } controls: {
                    Slider(value: $zoom, in: 1...3) { Text("Photo zoom") }
                        .accessibilityIdentifier("photoZoom")
                }
            case .providerHost:
                DesignOSProviderHostScreen {
                    ShareLink(item: "Original Layered Kit Preview fixture") {
                        Label("Open native share options", systemImage: "square.and.arrow.up")
                    }.buttonStyle(DesignOSSecondaryButtonStyle())
                        .padding(.horizontal, style.metrics.pageInset)
                } disclosure: {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        heading("Native sharing boundary")
                        Text("The system owns the share surface. No payment, authentication or external service is simulated.")
                    }.padding([.top, .horizontal], style.metrics.pageInset)
                } recovery: {
                    Text("Cancel the system sheet to return. Sharing requires your explicit choice.")
                        .padding([.horizontal, .bottom], style.metrics.pageInset)
                }
            case .recordDetail:
                DesignOSRecordDetailScreen {
                    DesignOSRecordSummary {
                        heading("Fixture receipt")
                    } status: { Text("Sample only").accessibilityIdentifier("recordSampleStatus") } facts: {
                        DesignOSLabeledValueRow("Reference", value: { Text("PREVIEW-001") })
                    }
                } credential: {
                    Label("SAMPLE · not a valid ticket", systemImage: "ticket")
                } details: {
                    DesignOSLabeledValueRow("Item", value: { Text("Community lunch") })
                } actions: { localAction }
            case .nativePresentation:
                DesignOSNativePresentationScreen {
                    Button("Show native alert") { showAlert = true }
                        .buttonStyle(DesignOSPrimaryButtonStyle()).accessibilityIdentifier("showNativeAlert")
                        .alert("Local preview", isPresented: $showAlert) {
                            Button("Close", role: .cancel) { }
                        } message: { Text("This is a real system alert, presented by the host.") }
                        .padding(.horizontal, style.metrics.pageInset)
                } context: {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        heading("Native presentation")
                        Text("The platform owns this alert's layout and focus.")
                    }.padding([.top, .horizontal], style.metrics.pageInset)
                }
            default: EmptyView()
            }
        }
    }

    private func heading(_ title: String) -> some View {
        Text(title).font(.title2).accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder private var hero: some View {
        if let photo {
            DesignOSMediaFrame(aspectRatio: 1.5, cornerRadius: 20) { photo.resizable().scaledToFill() }
                .frame(maxWidth: 420).accessibilityLabel("Original synthetic meal photograph")
        }
    }

    private var localAction: some View {
        Button(confirmed ? "Fixture complete" : "Continue locally") { confirmed = true }
            .buttonStyle(DesignOSPrimaryButtonStyle()).disabled(variant == .busy || confirmed)
    }

    @ViewBuilder private var stateFeedback: some View {
        switch variant {
        case .populated: Text("Original populated fixture")
        case .empty: DesignOSStatusMessage("No fixture results", message: "Try another local selection.")
        case .error: DesignOSStatusMessage("Fixture could not load", message: "This is a deliberate error state.")
        case .busy: ProgressView("Loading fixture")
        }
    }
}

private struct FixtureCategory: Identifiable, Sendable {
    let id: String
    let title: String
    static let all = [FixtureCategory(id: "food", title: "Food"),
                      FixtureCategory(id: "art", title: "Art"),
                      FixtureCategory(id: "outdoors", title: "Outdoors")]
}
