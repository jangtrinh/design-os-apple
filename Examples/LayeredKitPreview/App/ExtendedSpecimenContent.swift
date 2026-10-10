import DesignOSApple
import SwiftUI

struct ExtendedSpecimenContent: View {
    let specimen: Specimen
    let variant: PreviewState
    let photo: Image?
    @State private var query = ""
    @State private var selection: Int?
    @State private var note = "Bring something you enjoy sharing. This is original fixture text."
    @State private var draft = ""
    @State private var messages = ["Welcome to the local preview.", "These messages never leave this app."]
    @State private var confirmed = false
    @State private var showAlert = false
    @State private var zoom = 1.0

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
                    Text("No account or permission is required in the preview.")
                } action: { localAction }
            case .discovery:
                DesignOSDiscoveryScreen {
                    heading("Find your next gathering")
                } rails: {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(["Food", "Art", "Outdoors"], id: \.self) { category in
                                Button(category) { query = category }.buttonStyle(DesignOSSecondaryButtonStyle())
                            }
                        }
                    }
                } sections: {
                    heading(query.isEmpty ? "Nearby fixtures" : query)
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
                    Text(selection.map { "Selected gathering \($0)" } ?? "Select a gathering")
                        .padding().accessibilityIdentifier("selectionReceipt")
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
                            DesignOSAppSurface { Text(message) }.id(index)
                        }
                    }
                } status: { Text("Local conversation fixture").font(.caption) } composer: {
                    HStack {
                        TextField("Local message", text: $draft, axis: .vertical)
                            .textFieldStyle(.roundedBorder).accessibilityIdentifier("messageDraft")
                        Button("Add locally") { messages.append(draft); draft = "" }
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
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
                } status: { DesignOSAppSurface { Text("Local photo canvas · no camera access") } } controls: {
                    Slider(value: $zoom, in: 1...3) { Text("Photo zoom") }
                        .accessibilityIdentifier("photoZoom")
                }
            case .providerHost:
                DesignOSProviderHostScreen {
                    ShareLink(item: "Original Layered Kit Preview fixture") {
                        Label("Open native share options", systemImage: "square.and.arrow.up")
                    }.buttonStyle(DesignOSSecondaryButtonStyle())
                } disclosure: {
                    heading("Native sharing boundary")
                    Text("The system owns the share surface. No payment, authentication or external service is simulated.")
                } recovery: { Text("Cancel the system sheet to return. Sharing requires your explicit choice.") }
            case .recordDetail:
                DesignOSRecordDetailScreen { heading("Fixture receipt") } credential: {
                    Label("SAMPLE · not a valid ticket", systemImage: "ticket")
                } details: {
                    DesignOSLabeledValueRow("Item", value: { Text("Community lunch") })
                    DesignOSLabeledValueRow("Reference", value: { Text("PREVIEW-001") })
                } actions: { localAction }
            case .nativePresentation:
                DesignOSNativePresentationScreen {
                    Button("Show native alert") { showAlert = true }
                        .buttonStyle(DesignOSPrimaryButtonStyle()).accessibilityIdentifier("showNativeAlert")
                        .alert("Local preview", isPresented: $showAlert) {
                            Button("Close", role: .cancel) { }
                        } message: { Text("This is a real system alert, presented by the host.") }
                } context: { heading("Native presentation"); Text("The platform owns this alert's layout and focus.") }
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
