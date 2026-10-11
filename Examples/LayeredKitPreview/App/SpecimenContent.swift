import DesignOSApple
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct SpecimenContent: View {
    let specimen: Specimen
    @Binding var variant: PreviewState
    let hideMedia: Bool
    @State private var title = "Community lunch"
    @State private var notifications = true
    @State private var completed = false
    @State private var shell = 0
    @State private var composerAlternateColors = false
    @FocusState private var editingTitle: Bool

    private var photo: Image? { hideMedia ? nil : FixtureMedia.image }

    var body: some View {
        Group {
            switch specimen {
            case .textFields: TextFieldSpecimen()
            case .foundations: foundations
            case .composites: composites
            case .shells: shells
            case .flatCollection:
                DesignOSFlatCollectionScreen(showsStatus: variant != .populated) {
                    Text("This week")
                } rows: {
                    ForEach(0..<4) { index in
                        DesignOSMediaRow { thumbnail } content: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(index == 0 ? "Community lunch" : "Neighborhood gathering \(index + 1)")
                                    .font(.headline)
                                Text("Original sample · Saturday").foregroundStyle(.secondary)
                            }
                        }
                    }
                } status: { feedback }
            case .mediaDetail:
                DesignOSMediaDetailScreen(media: photo) {
                    DesignOSMediaDetailHeader {
                        hero
                    } identity: { EmptyView() } title: {
                        Text("Community lunch").font(.title2).accessibilityAddTraits(.isHeader)
                    } metadata: {
                        Text("Saturday · Original synthetic sample")
                            .accessibilityIdentifier("detailHeaderMetadata")
                    } actions: { EmptyView() }
                } identity: { EmptyView() } content: {
                    Text("An original fixture for checking long-form reading, adaptive layout and native actions. No event registration or purchase is performed.")
                    feedback
                }
            case .mediaComposer:
                DesignOSMediaComposerScreen(media: photo) {
                    DesignOSMediaComposerHeader {
                        composerCover
                    } mediaActions: {
                        EmptyView()
                    } field: { titleField } feedback: {
                        feedback
                        Text("Edit changes the local sample colors. No photo library or upload is used.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                } fields: {
                    DesignOSFieldGroup {
                        Toggle("Send reminders", isOn: $notifications).accessibilityIdentifier("fixtureToggle")
                    }
                } feedback: { EmptyView() }
            case .groupedForm:
                DesignOSGroupedFormScreen {
                    Section("Details") { fields }
                    Section("Status") { feedback }
                } consequential: {
                    Section { Button("Reset fixture", role: .destructive) { title = "Community lunch" } }
                }
            case .focusedTask:
                DesignOSFocusedTaskScreen {
                    Text("Name your gathering").font(.title2).accessibilityAddTraits(.isHeader)
                    Text("A focused task using native text input.")
                } fields: { fields } feedback: { feedback } action: { action }
            default:
                ExtendedSpecimenContent(specimen: specimen, variant: variant, photo: photo)
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .keyboard) {
                if editingTitle {
                    Spacer()
                    Button("Done") { editingTitle = false }.accessibilityIdentifier("finishFixtureEditing")
                }
            }
            #endif
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleField
            Toggle("Send reminders", isOn: $notifications).accessibilityIdentifier("fixtureToggle")
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var titleField: some View {
        Group {
            if specimen == .groupedForm {
                TextField("Gathering name", text: $title).textFieldStyle(.plain)
            } else {
                TextField("Gathering name", text: $title)
                    .modifier(DesignOSAppTextFieldModifier())
            }
        }
            .focused($editingTitle).onSubmit { editingTitle = false }
            .accessibilityIdentifier("fixtureTitle")
    }

    private var action: some View {
        Button(completed ? "Saved locally in fixture" : "Save fixture") { completed = true }
            .buttonStyle(DesignOSPrimaryButtonStyle())
            .disabled(variant == .busy || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("fixtureSave")
    }

    @ViewBuilder private var feedback: some View {
        switch variant {
        case .populated: Text(completed ? "Fixture saved" : "Ready to edit").accessibilityIdentifier("fixtureFeedback")
        case .empty: ContentUnavailableView("Nothing here yet", systemImage: "tray", description: Text("Add a first fixture item."))
        case .error: Label("Fixture error: check the gathering name.", systemImage: "exclamationmark.circle").foregroundStyle(.red)
        case .busy: ProgressView("Fixture loading state")
        }
    }

    private var identity: some View {
        DesignOSIdentityHeader {
            Text("Community lunch").font(.title2).accessibilityAddTraits(.isHeader)
        } metadata: {
            Text("Saturday · Original synthetic sample").foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var hero: some View {
        if let photo {
            DesignOSMediaFrame(aspectRatio: 1.5, cornerRadius: 20) {
                photo.resizable().scaledToFill()
            }.frame(maxWidth: 360)
                .accessibilityLabel("Original synthetic meal photograph")
                .accessibilityIdentifier("fixtureMedia")
        }
    }

    @ViewBuilder private var composerCover: some View {
        if let photo {
            DesignOSMediaFrame(aspectRatio: 1, cornerRadius: 24) {
                photo.resizable().scaledToFill()
                    .hueRotation(.degrees(composerAlternateColors ? 45 : 0))
            }
            .frame(maxWidth: 360)
            .accessibilityLabel("Original synthetic meal photograph")
            .accessibilityIdentifier("fixtureMedia")
            .overlay(alignment: .bottomTrailing) {
                Button { composerAlternateColors.toggle() } label: {
                    Label("Edit local sample", systemImage: "pencil").labelStyle(.iconOnly)
                }
                .buttonStyle(DesignOSSecondaryButtonStyle(size: .compact))
                .accessibilityLabel("Change local sample colors")
                .accessibilityValue(composerAlternateColors ? "Alternate colors" : "Original colors")
                .accessibilityIdentifier("composerMediaAction")
                .padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder private var thumbnail: some View {
        if let photo { photo.resizable().scaledToFill() }
        else { Image(systemName: "photo").frame(maxWidth: .infinity, maxHeight: .infinity) }
    }

    private var foundations: some View {
        DesignOSFocusedTaskShell {
            VStack(alignment: .leading, spacing: 20) {
                Text("Editorial foundations").font(.title2)
                DesignOSAppSectionHeader("Adaptive colors and type")
                DesignOSAppSurface { Text("Semantic surface using the shared style.") }
                DesignOSMediaRow {
                    thumbnail.accessibilityIdentifier("foundationMedia")
                } content: {
                    VStack(alignment: .leading) {
                        Text("Media row").accessibilityIdentifier("foundationMediaTitle")
                        Text("Native text reflow")
                    }
                }
                DesignOSAvatar { Image(systemName: "person.crop.circle.fill").resizable().scaledToFit() }
                    .accessibilityLabel("Fixture identity")
                DesignOSLabeledValueRow("Reminders", value: {
                    Toggle("Reminders", isOn: $notifications).labelsHidden()
                })
                DesignOSStatusMessage("Fixture status", message: "Original local content, no external requests.")
                hero
            }
        } action: { action }
    }

    private var composites: some View {
        DesignOSFocusedTaskShell {
            VStack(alignment: .leading, spacing: 20) {
                identity
                DesignOSFieldGroup {
                    Text("Editable facts").font(.headline).accessibilityAddTraits(.isHeader)
                } content: { fields } footer: { feedback }
            }
        } action: { action }
    }

    private var shells: some View {
        VStack(spacing: 0) {
            Picker("Shell", selection: $shell) {
                Text("List").tag(0); Text("Form").tag(1); Text("Ambient").tag(2); Text("Task").tag(3)
                Text("Flat scroll").tag(4); Text("Conversation").tag(5)
                Text("Native host").tag(6); Text("Utility canvas").tag(7)
            }.pickerStyle(.menu).padding().accessibilityIdentifier("shellPicker")
            switch shell {
            case 0: DesignOSFlatListShell { Text("Native List row"); Text("Second row") }
            case 1: DesignOSGroupedFormShell { Section("Native Form") { fields } }
            case 2: DesignOSAmbientScrollShell(media: photo) { hero; identity }
            case 3: DesignOSFocusedTaskShell { fields } action: { action }
            case 4: DesignOSFlatScrollShell { identity; hero }
            case 5: DesignOSConversationShell { _ in Text("Local history") } composer: { fields }
            case 6: DesignOSNativeHostShell { TextEditor(text: $title).accessibilityLabel("Native editor") }
            default: DesignOSUtilityCanvasShell { hero } overlay: { Text("Original fixture media") } controls: { action }
            }
        }
    }
}

@MainActor
enum FixtureMedia {
    static let image: Image? = {
        guard let url = Bundle.main.url(forResource: "DemoMeal", withExtension: "png"),
              let data = try? Data(contentsOf: url) else { return nil }
        #if os(iOS)
        return UIImage(data: data).map(Image.init(uiImage:))
        #else
        return NSImage(data: data).map(Image.init(nsImage:))
        #endif
    }()
}
