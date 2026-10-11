import DesignOSApple
import SwiftUI

/// Isolated app-owned fixtures. This route does not alter the public design-system API.
struct ComponentInventoryRecord: Identifiable {
    let id: String
    let symbol: String
    let source: String
    var layer: String { String(id.split(separator: "/")[0]) }
}

struct ComponentInventorySpecimen: View {
    let componentID: String
    @Environment(\.designOSAppStyle) private var style
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var name = "Courtyard reading club"
    @State private var message = "I'll bring the illustrated atlas."
    @State private var amount = 0.6
    @State private var count = 3
    @State private var date = Date(timeIntervalSince1970: 1_797_076_800)
    @State private var accent = Color.indigo
    @State private var category = "Fiction"
    @State private var query = ""
    @State private var expanded = true
    @State private var presentation = false
    @State private var selectedReaders: Set<String> = ["alex", "sam"]
    @State private var reviewSelection = false
    @State private var showCategory = false
    @State private var selected = true
    @State private var saved = false
    @State private var columns = NavigationSplitViewVisibility.all
    private let state = ProcessInfo.processInfo.environment["LAYERED_KIT_COMPONENT_STATE"] ?? "default"
    static let records: [ComponentInventoryRecord] = [
        .init(id: "native/button-and-toolbar-action-recipe", symbol: "NativeButtonAndToolbarActionRecipe", source: "Sources/DesignOSApple/Recipes/NativeButtonAndToolbarActionRecipe.swift"),
        .init(id: "native/content-unavailable-view-recipe", symbol: "NativeContentUnavailableViewRecipe", source: "Sources/DesignOSApple/Recipes/NativeContentUnavailableViewRecipe.swift"),
        .init(id: "native/elevated-background-recipe", symbol: "NativeElevatedBackgroundRecipe", source: "Sources/DesignOSApple/Recipes/NativeElevatedBackgroundRecipe.swift"),
        .init(id: "native/hierarchical-style-recipe", symbol: "NativeHierarchicalStyleRecipe", source: "Sources/DesignOSApple/Recipes/NativeHierarchicalStyleRecipe.swift"),
        .init(id: "native/list-sidebar-and-disclosure-recipe", symbol: "NativeListSidebarAndDisclosureRecipe", source: "Sources/DesignOSApple/Recipes/NativeListSidebarAndDisclosureRecipe.swift"),
        .init(id: "native/material-and-glass-surface-recipe", symbol: "NativeMaterialAndGlassSurfaceRecipe", source: "Sources/DesignOSApple/Recipes/NativeMaterialAndGlassSurfaceRecipe.swift"),
        .init(id: "native/menu-context-and-edit-actions-recipe", symbol: "NativeMenuContextAndEditActionsRecipe", source: "Sources/DesignOSApple/Recipes/NativeMenuContextAndEditActionsRecipe.swift"),
        .init(id: "native/navigation-tabs-and-toolbars-recipe", symbol: "NativeNavigationTabsAndToolbarsRecipe", source: "Sources/DesignOSApple/Recipes/NativeNavigationTabsAndToolbarsRecipe.swift"),
        .init(id: "native/picker-and-date-color-input-recipe", symbol: "NativePickerAndDateColorInputRecipe", source: "Sources/DesignOSApple/Recipes/NativePickerAndDateColorInputRecipe.swift"),
        .init(id: "native/presentation-and-share-recipe", symbol: "NativePresentationAndShareRecipe", source: "Sources/DesignOSApple/Recipes/NativePresentationAndShareRecipe.swift"),
        .init(id: "native/progress-slider-stepper-recipe", symbol: "NativeProgressSliderStepperRecipe", source: "Sources/DesignOSApple/Recipes/NativeProgressSliderStepperRecipe.swift"),
        .init(id: "native/text-search-and-keyboard-input-recipe", symbol: "NativeTextSearchAndKeyboardInputRecipe", source: "Sources/DesignOSApple/Recipes/NativeTextSearchAndKeyboardInputRecipe.swift"),
        .init(id: "composite/sectioned-media-collection", symbol: "Sectioned media collection recipe", source: "docs/native-layout-recipes.md"),
        .init(id: "composite/form-section", symbol: "Native form section recipe", source: "docs/native-layout-recipes.md"),
        .init(id: "composite/confirmation-content", symbol: "Confirmation content recipe", source: "docs/native-layout-recipes.md"),
        .init(id: "composite/status-content", symbol: "Native status content recipe", source: "docs/native-layout-recipes.md"),
        .init(id: "primitive/corner-geometry", symbol: "DesignOSCornerGeometry", source: "Sources/DesignOSApple/AppStyle/DesignOSCornerGeometry.swift"),
        .init(id: "semantic/media-frame", symbol: "DesignOSMediaFrame", source: "Sources/DesignOSApple/Components/Semantic/DesignOSMediaFrame.swift"),
        .init(id: "semantic/avatar", symbol: "DesignOSAvatar", source: "Sources/DesignOSApple/Components/Semantic/DesignOSAvatar.swift"),
        .init(id: "semantic/labeled-value-row", symbol: "DesignOSLabeledValueRow", source: "Sources/DesignOSApple/Components/Semantic/DesignOSLabeledValueRow.swift"),
        .init(id: "semantic/status-message", symbol: "DesignOSStatusMessage", source: "Sources/DesignOSApple/Components/Semantic/DesignOSStatusMessage.swift"),
        .init(id: "semantic/media-row", symbol: "DesignOSMediaRow", source: "Sources/DesignOSApple/Components/DesignOSMediaRow.swift"),
        .init(id: "semantic/section-header", symbol: "DesignOSAppSectionHeader", source: "Sources/DesignOSApple/Components/DesignOSAppSectionHeader.swift"),
        .init(id: "semantic/content-surface", symbol: "DesignOSAppSurface", source: "Sources/DesignOSApple/Components/DesignOSAppSurface.swift"),
        .init(id: "semantic/primary-action", symbol: "DesignOSPrimaryButtonStyle", source: "Sources/DesignOSApple/Components/DesignOSPrimaryButtonStyle.swift"),
        .init(id: "semantic/secondary-action", symbol: "DesignOSSecondaryButtonStyle", source: "Sources/DesignOSApple/Components/DesignOSSecondaryButtonStyle.swift"),
        .init(id: "semantic/media-backdrop", symbol: "DesignOSMediaBackdrop", source: "Sources/DesignOSApple/Components/DesignOSMediaBackdrop.swift"),
        .init(id: "composite/field-group", symbol: "DesignOSFieldGroup", source: "Sources/DesignOSApple/Components/Composite/DesignOSFieldGroup.swift"),
        .init(id: "composite/identity-header", symbol: "DesignOSIdentityHeader", source: "Sources/DesignOSApple/Components/Composite/DesignOSIdentityHeader.swift"),
        .init(id: "composite/media-detail-header", symbol: "DesignOSMediaDetailHeader", source: "Sources/DesignOSApple/Components/Composite/DesignOSMediaDetailHeader.swift"),
        .init(id: "composite/media-composer-header", symbol: "DesignOSMediaComposerHeader", source: "Sources/DesignOSApple/Components/Composite/DesignOSMediaComposerHeader.swift"),
        .init(id: "composite/choice-row", symbol: "DesignOSChoiceRow", source: "Sources/DesignOSApple/Components/Composite/DesignOSChoiceRow.swift"),
        .init(id: "composite/selection-summary", symbol: "DesignOSSelectionSummary", source: "Sources/DesignOSApple/Components/Composite/DesignOSSelectionSummary.swift"),
        .init(id: "composite/category-rail", symbol: "DesignOSCategoryRail", source: "Sources/DesignOSApple/Components/Composite/DesignOSCategoryRail.swift"),
        .init(id: "composite/message-bubble", symbol: "DesignOSMessageBubble", source: "Sources/DesignOSApple/Components/Composite/DesignOSMessageBubble.swift"),
        .init(id: "composite/conversation-composer", symbol: "DesignOSConversationComposer", source: "Sources/DesignOSApple/Components/Composite/DesignOSConversationComposer.swift"),
        .init(id: "composite/record-summary", symbol: "DesignOSRecordSummary", source: "Sources/DesignOSApple/Components/Composite/DesignOSRecordSummary.swift"),
        .init(id: "composite/utility-overlay", symbol: "DesignOSUtilityOverlay", source: "Sources/DesignOSApple/Components/Composite/DesignOSUtilityOverlay.swift"),
        .init(id: "shell/flat-list", symbol: "DesignOSFlatListShell", source: "Sources/DesignOSApple/Shells/DesignOSFlatListShell.swift"),
        .init(id: "shell/flat-scroll", symbol: "DesignOSFlatScrollShell", source: "Sources/DesignOSApple/Shells/DesignOSFlatScrollShell.swift"),
        .init(id: "shell/grouped-form", symbol: "DesignOSGroupedFormShell", source: "Sources/DesignOSApple/Shells/DesignOSGroupedFormShell.swift"),
        .init(id: "shell/ambient-scroll", symbol: "DesignOSAmbientScrollShell", source: "Sources/DesignOSApple/Shells/DesignOSAmbientScrollShell.swift"),
        .init(id: "shell/focused-task", symbol: "DesignOSFocusedTaskShell", source: "Sources/DesignOSApple/Shells/DesignOSFocusedTaskShell.swift"),
        .init(id: "shell/conversation", symbol: "DesignOSConversationShell", source: "Sources/DesignOSApple/Shells/DesignOSConversationShell.swift"),
        .init(id: "shell/utility-canvas", symbol: "DesignOSUtilityCanvasShell", source: "Sources/DesignOSApple/Shells/DesignOSUtilityCanvasShell.swift"),
        .init(id: "shell/adaptive-navigation", symbol: "DesignOSAdaptiveNavigationShell", source: "Sources/DesignOSApple/Shells/DesignOSAdaptiveNavigationShell.swift"),
        .init(id: "shell/native-host", symbol: "DesignOSNativeHostShell", source: "Sources/DesignOSApple/Shells/DesignOSNativeHostShell.swift"),
        .init(id: "semantic/text-field-modifier", symbol: "DesignOSAppTextFieldModifier", source: "Sources/DesignOSApple/Components/DesignOSAppTextFieldModifier.swift"),
        .init(id: "semantic/list-row", symbol: "DesignOSListRow", source: "Sources/DesignOSApple/Components/DesignOSListRow.swift"),
        .init(id: "semantic/sidebar-row", symbol: "DesignOSSidebarRow", source: "Sources/DesignOSApple/Components/DesignOSSidebarRow.swift"),
        .init(id: "foundation/color-role", symbol: "DesignOSColorRole", source: "Sources/DesignOSApple/Tokens/DesignOSColorRole.swift"),
        .init(id: "foundation/typography-role", symbol: "DesignOSTypographyRole", source: "Sources/DesignOSApple/Tokens/DesignOSTypographyRole.swift"),
        .init(id: "foundation/surface-role", symbol: "DesignOSSurfaceRole", source: "Sources/DesignOSApple/Tokens/DesignOSSurfaceRole.swift"),
    ]
    static func supports(_ id: String) -> Bool { records.contains { $0.id == id } }
    private var record: ComponentInventoryRecord { Self.records.first { $0.id == componentID }! }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.symbol).font(.headline).textSelection(.enabled)
                Text(record.layer.capitalized + " · " + state).font(.caption).foregroundStyle(.secondary)
                Text(record.source).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                Text(componentID).font(.caption2).foregroundStyle(.secondary)
                    .accessibilityIdentifier("component-ready-" + componentID)
                if let inputs = backdropPolicyInputs {
                    Text(inputs).font(.caption2)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("component-backdrop-policy-inputs")
                }
            }.padding(16)
            Divider()
            if componentID.hasPrefix("shell/") {
                shellContent
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if componentID.hasPrefix("native/") { nativeContent }
                        else { componentContent }
                    }.frame(maxWidth: 600, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .center).padding(20)
                }
            }
        }
        .background(style.palette.canvas.color)
        .dynamicTypeSize(state == "accessibility" ? .accessibility3 : .large)
        .environment(\.layoutDirection, state == "rtl" ? .rightToLeft : .leftToRight)
        #if os(macOS)
        .frame(minWidth: 680, minHeight: 650)
        #endif
    }

    /// Read-only inputs from the same environment as the public backdrop. A supplied
    /// view/image is not evidence that media rendered; the private policy is not copied.
    private var backdropPolicyInputs: String? {
        let mediaSource: String
        let mediaPresent: Bool
        if componentID == "semantic/media-backdrop" {
            mediaSource = "synthetic-view"
            mediaPresent = true // The nonoptional artwork closure is supplied below.
        } else if componentID == "shell/ambient-scroll" {
            mediaSource = "fixture-image"
            mediaPresent = FixtureMedia.image != nil
        } else {
            return nil
        }
        let scheme: String
        switch colorScheme {
        case .light: scheme = "light"
        case .dark: scheme = "dark"
        @unknown default: scheme = "unknown"
        }
        let contrast: String
        switch colorSchemeContrast {
        case .standard: contrast = "standard"
        case .increased: contrast = "increased"
        @unknown default: contrast = "unknown"
        }
        return "backdrop-inputs/v1; colorScheme=\(scheme); contrast=\(contrast); "
            + "reduceTransparency=\(reduceTransparency); "
            + "profileTranslucency=\(style.profile.accessibility.translucency.rawValue); "
            + "mediaSource=\(mediaSource); mediaPresent=\(mediaPresent)"
    }

    @ViewBuilder private var nativeContent: some View {
        switch componentID {
        case "native/button-and-toolbar-action-recipe":
            NavigationStack {
                VStack(spacing: 20) {
                    Button(saved ? "Saved locally" : "Save reading list") { saved.toggle() }.buttonStyle(.borderedProminent)
                    Button("Cancel") { saved = false }.buttonStyle(.bordered)
                    Button("Unavailable action") {}.disabled(true)
                }.padding().navigationTitle("Native actions")
                    .toolbar { ToolbarItem(placement: .primaryAction) { Button("Add book", systemImage: "plus") { count += 1 } } }
            }.frame(height: 330)
        case "native/content-unavailable-view-recipe":
            ContentUnavailableView("No reading lists", systemImage: "books.vertical", description: Text("Start a collection of books to share."))
        case "native/elevated-background-recipe":
            Form { Section("Reading room") { Text("The native Form owns this elevated background."); Toggle("Quiet hours", isOn: $selected) } }.frame(height: 300)
        case "native/hierarchical-style-recipe":
            VStack(alignment: .leading, spacing: 20) {
                Label("Reading collection", systemImage: "books.vertical").foregroundStyle(.primary)
                Text("Shared by the courtyard club").foregroundStyle(.secondary)
                Text("Updated this morning").foregroundStyle(.tertiary)
                Text("Supplementary annotation").foregroundStyle(.quaternary)
            }
        case "native/list-sidebar-and-disclosure-recipe":
            List { Section("Collection") { Label("The illustrated atlas", systemImage: "book"); DisclosureGroup("Reading notes", isExpanded: $expanded) { Text("Bring a favorite passage."); Text("Meet beside the cedar.") } } }.frame(height: 340)
        case "native/material-and-glass-surface-recipe":
            artwork.frame(height: 300).overlay {
                Label("Native regular material", systemImage: "books.vertical").padding(24).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
            Text("The package-floor material branch is shown. This capture does not claim availability-gated glass behavior.").font(.caption)
        case "native/menu-context-and-edit-actions-recipe":
            Menu("Organize collection") { Button("Add a book") { count += 1 }; Button("Sort by title") { saved.toggle() } }
                .accessibilityIdentifier("inventoryNativeMenu")
            List { Text("The illustrated atlas").contextMenu { Button("Mark as read") { saved.toggle() } }
                .swipeActions { Button("Archive", role: .destructive) { saved.toggle() } }
            }.frame(height: 180)
            Text("Menu, context menu and row actions are system-owned. The resting capture does not prove an open menu or a swipe state.").font(.caption)
        case "native/navigation-tabs-and-toolbars-recipe":
            TabView {
                NavigationStack { Text("Your reading collection").navigationTitle("Library").toolbar { ToolbarItem(placement: .primaryAction) { Button("Add", systemImage: "plus") { count += 1 } } } }.tabItem { Label("Library", systemImage: "books.vertical") }
                Text("Upcoming gatherings").tabItem { Label("Gatherings", systemImage: "calendar") }
            }.frame(height: 380)
        case "native/picker-and-date-color-input-recipe":
            Form {
                Picker("Genre", selection: $category) { Text("Fiction").tag("Fiction"); Text("Nature").tag("Nature"); Text("Art").tag("Art") }
                DatePicker("Reading day", selection: $date, displayedComponents: .date)
                ColorPicker("Collection color", selection: $accent)
            }.frame(height: 300)
        case "native/presentation-and-share-recipe":
            Button("Open reading details") { presentation = true }.accessibilityIdentifier("inventoryOpenSheet")
                .sheet(isPresented: $presentation) {
                    NavigationStack { VStack(alignment: .leading, spacing: 20) { Text("Courtyard reading club").font(.title2); Text("Saturday · 10:30 AM"); Text("Original local fixture. No external sharing occurs.") }.padding().navigationTitle("Reading details").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { presentation = false }.accessibilityIdentifier("inventoryCloseSheet") } } }
                        #if os(macOS)
                        .frame(minWidth: 420, minHeight: 320)
                        #endif
                }
            ShareLink(item: "Courtyard reading club · original local fixture") { Label("Share fixture text", systemImage: "square.and.arrow.up") }
            Text("Native sheet and ShareLink call sites. The resting capture only shows the launch controls.").font(.caption)
        case "native/progress-slider-stepper-recipe":
            VStack(alignment: .leading, spacing: 24) {
                ProgressView("Reading progress", value: amount)
                Slider(value: $amount, in: 0...1) { Text("Reading progress") }
                Stepper("Books to bring: \(count)", value: $count, in: 1...8)
                Toggle("Reading reminders", isOn: $selected)
            }
        case "native/text-search-and-keyboard-input-recipe":
            NavigationStack {
                Form { TextField("Collection name", text: $name); TextField("A reading note", text: $message, axis: .vertical) }.navigationTitle("Reading collection").searchable(text: $query, prompt: "Find a book")
            }.frame(height: 380)
            Text("Native text and search controls; keyboard, focus and editing are not forced for capture.").font(.caption)
        default: EmptyView()
        }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(style.palette.secondaryInk.color)
            .padding(.horizontal, style.metrics.contentInset)
            .accessibilityHidden(true)
    }

    @ViewBuilder private var componentContent: some View {
        switch componentID {
        case "primitive/corner-geometry": cornerGeometry
        case "semantic/media-frame":
            DesignOSMediaFrame(aspectRatio: 1.5, cornerRadius: 24) { artwork }
                .accessibilityLabel("Original synthetic book artwork, clipped to a rounded media frame")
        case "semantic/avatar":
            HStack(spacing: 24) {
                DesignOSAvatar(size: 64) { artwork }
                DesignOSAvatar(size: 64) { Text("AR").font(.title2) }
                DesignOSAvatar(size: 64) { Image(systemName: "person.fill").font(.title) }
            }
            Text("Synthetic artwork, initials and symbol content in the real avatar component.").font(.caption)
        case "semantic/labeled-value-row":
            DesignOSLabeledValueRow("Location") { Text("West courtyard, beside the old cedar") } accessory: { Image(systemName: "location") }
            DesignOSLabeledValueRow("Starts") { Text("Saturday · 10:30 AM") }
        case "semantic/status-message":
            DesignOSStatusMessage(state == "error" ? "Couldn't save this draft" : "Your gathering is ready", message: "This is an original local fixture. No invitation is sent.") {
                Image(systemName: state == "error" ? "exclamationmark.circle" : "checkmark.circle")
            } actions: { Button("Review details") { saved.toggle() } }
        case "semantic/media-row": mediaRow
        case "semantic/section-header":
            DesignOSAppSectionHeader("Upcoming gatherings") { Button("See all") { saved.toggle() } }
        case "semantic/content-surface":
            DesignOSAppSurface { sampleText("Standard surface") }
            DesignOSAppSurface(tone: .subtle) { sampleText("Subtle surface") }
            DesignOSAppSurface(tone: .ambient) { sampleText("Ambient surface over artwork") }
                .padding(style.metrics.contentInset)
                .background { DesignOSMediaBackdrop { artwork } }
                // The backdrop's outer radius includes the real inset around the surface.
                .clipShape(RoundedRectangle(cornerRadius: style.metrics.surfaceRadius + style.metrics.contentInset, style: .continuous))
            Text("The ambient sample uses the real media backdrop with synthetic artwork. Light and accessibility fallback states use an opaque canvas.").font(.caption)
        case "semantic/primary-action":
            Button(saved ? "Saved locally" : "Create gathering") { saved.toggle() }.buttonStyle(DesignOSPrimaryButtonStyle())
            Button("Unavailable action") {}.buttonStyle(DesignOSPrimaryButtonStyle()).disabled(true)
        case "semantic/secondary-action":
            Button(saved ? "Saved locally" : "View gathering") { saved.toggle() }.buttonStyle(DesignOSSecondaryButtonStyle())
            Button("Outlined action") { saved.toggle() }.buttonStyle(DesignOSSecondaryButtonStyle(treatment: .outlined))
            Button("Unavailable action") {}.buttonStyle(DesignOSSecondaryButtonStyle()).disabled(true)
            HStack {
                Button("Fiction", systemImage: "book") { saved.toggle() }
                    .buttonStyle(DesignOSSecondaryButtonStyle(size: .compact))
                Button("Nature", systemImage: "leaf") { saved.toggle() }
                    .buttonStyle(DesignOSSecondaryButtonStyle(size: .compact, treatment: .outlined))
            }
            Button("Unavailable category") {}
                .buttonStyle(DesignOSSecondaryButtonStyle(size: .compact, treatment: .outlined)).disabled(true)
        case "semantic/media-backdrop":
            DesignOSMediaBackdrop { artwork }.frame(height: 330)
                .overlay { Text("Courtyard reading club").font(.title2).padding() }
            Text("The backdrop uses its actual adaptive media policy. Light and high-contrast states may intentionally suppress media.").font(.caption)
        case "semantic/text-field-modifier":
            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                fieldLabel("Gathering name")
                TextField("Gathering name", text: $name).modifier(DesignOSAppTextFieldModifier())
            }
            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                fieldLabel("Optional note")
                TextField("Optional note", text: .constant("")).modifier(DesignOSAppTextFieldModifier())
            }
            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                fieldLabel("Disabled field")
                TextField("Disabled field", text: .constant("Details locked")).modifier(DesignOSAppTextFieldModifier()).disabled(true)
            }
            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                fieldLabel("Long description")
                TextField("Long description", text: .constant("Bring one book with a story behind it. We will read together in the courtyard."), axis: .vertical)
                    .lineLimit(3...6)
                    .modifier(DesignOSAppTextFieldModifier(multiline: true))
            }
        case "semantic/list-row":
            DesignOSListRow { Image(systemName: "book.closed") } title: { Text("The illustrated atlas") } subtitle: { Text("Reading collection · 12 entries") } trailing: { Image(systemName: "chevron.right") }
        case "semantic/sidebar-row":
            DesignOSSidebarRow { Label("Reading club", systemImage: "books.vertical") } accessory: { Text("12").foregroundStyle(.secondary) }
        case "composite/sectioned-media-collection":
            VStack(alignment: .leading, spacing: 24) {
                DesignOSAppSectionHeader("Saturday gatherings")
                mediaRow
                Divider()
                DesignOSAppSectionHeader("Your collection")
                mediaRow
            }
        case "composite/form-section":
            Form { Section { Toggle("Morning sessions", isOn: $selected); TextField("Favorite book", text: $name) } header: { Text("Reading preferences") } footer: { Text("Native Section inside a native Form.") } }.frame(height: 300)
        case "composite/confirmation-content":
            DesignOSStatusMessage("Gathering saved", message: "Your local draft is ready to review.") { Image(systemName: "checkmark.circle").font(.largeTitle) } actions: { action }
        case "composite/status-content":
            ContentUnavailableView("No gatherings yet", systemImage: "books.vertical", description: Text("Create a reading session to begin."))
        case "composite/field-group":
            DesignOSFieldGroup { Text("Gathering details").font(.headline) } content: {
                // The group owns the filled well; its native row must not add a nested capsule.
                DesignOSLabeledValueRow("Name") {
                    TextField("Gathering name", text: $name).textFieldStyle(.plain)
                }
                Divider()
                Toggle("Send a reminder", isOn: $selected)
            } footer: { Text("Only saved on this fixture screen.").font(.caption).foregroundStyle(.secondary) }
        case "composite/identity-header": identity
        case "composite/media-detail-header":
            DesignOSMediaDetailHeader { framedArtwork } identity: {
                DesignOSAvatar(size: 44) { Text("AR") }
            } title: { Text("Courtyard reading club").font(.title2) } metadata: {
                Text("Saturday · West courtyard").foregroundStyle(.secondary)
            } actions: { action }
        case "composite/media-composer-header":
            DesignOSMediaComposerHeader { composerArtwork } mediaActions: {
                EmptyView()
            } field: { TextField("Gathering name", text: $name).modifier(DesignOSAppTextFieldModifier()) } feedback: {
                Text("Edit changes the local artwork colors. No photo library or upload is used.").font(.caption)
            }
        case "composite/choice-row":
            // Caller-owned selection controls, not a settings toggle. Actual reference pixels:
            // mobbin.com/screens/3c445308-cc7d-4692-910a-374022783faf (private research only).
            ForEach(InventoryReader.samples) { reader in
                DesignOSChoiceRow {
                    DesignOSAvatar(size: 44) { Text(reader.initials).font(.headline) }
                } description: {
                    Text(reader.name).font(.headline)
                    Text(reader.detail).foregroundStyle(.secondary)
                } control: {
                    Button {
                        if selectedReaders.contains(reader.id) { selectedReaders.remove(reader.id) }
                        else { selectedReaders.insert(reader.id) }
                    } label: {
                        Image(systemName: selectedReaders.contains(reader.id) ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(style.palette.ink.color)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select " + reader.name)
                    .accessibilityValue(selectedReaders.contains(reader.id) ? "Selected" : "Not selected")
                    .accessibilityAddTraits(selectedReaders.contains(reader.id) ? .isSelected : [])
                    .accessibilityIdentifier("inventorySelectReader-" + reader.id)
                }
            }
        case "composite/selection-summary":
            DesignOSSelectionSummary(sizing: .intrinsic) {
                selectionCountButton
            } actions: { EmptyView() }
            .frame(maxWidth: .infinity, alignment: .center)
            .sheet(isPresented: $reviewSelection) {
                NavigationStack {
                    List(InventoryReader.samples.filter { selectedReaders.contains($0.id) }) { reader in
                        Label(reader.name, systemImage: "person.crop.circle")
                    }
                    .navigationTitle("Selected readers")
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { reviewSelection = false } } }
                }
                #if os(macOS)
                .frame(minWidth: 420, minHeight: 320)
                #endif
            }
        case "composite/category-rail":
            // Compact native actions rather than media cards. The public rail owns one row.
            DesignOSCategoryRail(state == "empty" ? [] : InventoryCategory.samples) {
                DesignOSAppSectionHeader("Browse by category")
            } item: { category in
                Button { self.category = category.title; showCategory = true } label: {
                    Label(category.title, systemImage: category.symbol)
                }
                .buttonStyle(DesignOSSecondaryButtonStyle(size: .compact, treatment: .outlined))
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityIdentifier("inventoryCategory-" + category.id)
            } empty: { ContentUnavailableView("No collections yet", systemImage: "books.vertical") }
            .sheet(isPresented: $showCategory) {
                NavigationStack {
                    List { Label("The illustrated atlas", systemImage: "book"); Label("Notes from the courtyard", systemImage: "book") }
                        .navigationTitle(category)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showCategory = false } } }
                }
                #if os(macOS)
                .frame(minWidth: 420, minHeight: 320)
                #endif
            }
        case "composite/message-bubble":
            DesignOSMessageBubble(isOutgoing: false) { Text("Shall we meet beside the cedar?") } metadata: { Text("Alex · 10:12").font(.caption) }
            DesignOSMessageBubble(isOutgoing: true, outgoingAppearance: .emphasized) { Text("Replying to Alex").font(.caption) } content: { Text("Yes! I'll bring the illustrated atlas.") } metadata: { Text("10:14 · Sent locally").font(.caption) }
        case "composite/conversation-composer": composer
        case "composite/record-summary":
            DesignOSRecordSummary { Text("Reading session #024").font(.headline) } status: { Label("Confirmed", systemImage: "checkmark.circle") } facts: {
                DesignOSLabeledValueRow("Location") { Text("West courtyard") }
                DesignOSLabeledValueRow("Guests") { Text("8 readers") }
            }
        case "composite/utility-overlay":
            DesignOSUtilityOverlay { Label("Map centered on courtyard", systemImage: "location") } actions: { Button("Recenter") { saved.toggle() } }
        case "foundation/color-role": colorRoles
        case "foundation/typography-role": typographyRoles
        case "foundation/surface-role": surfaceRoles
        default: ContentUnavailableView("Unknown fixture", systemImage: "questionmark.square")
        }
    }

    @ViewBuilder private var shellContent: some View {
        switch componentID {
        case "shell/flat-list": DesignOSFlatListShell { ForEach(1..<7) { n in Label("Reading session \(n)", systemImage: "book") } }
        case "shell/flat-scroll": DesignOSFlatScrollShell { shellReadingContent }
        case "shell/grouped-form": DesignOSGroupedFormShell { Section("Gathering") { TextField("Name", text: $name); Toggle("Reminders", isOn: $selected) }; Section("About") { Text("A native grouped form owns its spacing and controls.") } }
        case "shell/ambient-scroll": DesignOSAmbientScrollShell(media: FixtureMedia.image) { shellReadingContent }
        case "shell/focused-task": DesignOSFocusedTaskShell { sampleText("Name your gathering"); TextField("Name", text: $name).modifier(DesignOSAppTextFieldModifier()) } action: { action }
        case "shell/conversation": DesignOSConversationShell { _ in
            VStack(spacing: 20) { ForEach(1..<4) { n in DesignOSMessageBubble(isOutgoing: n == 2, outgoingAppearance: .emphasized) { Text(n == 2 ? "I'll bring the atlas." : "See you in the courtyard.") } metadata: { Text("10:\(10+n)").font(.caption) } } }
        } composer: { composer }
        case "shell/utility-canvas": DesignOSUtilityCanvasShell { artwork } overlay: {
            DesignOSUtilityOverlay { Label("Courtyard plan", systemImage: "map") } actions: { Button("Center") { saved.toggle() } }
        } controls: { Button("Locate reading area") { saved.toggle() }.buttonStyle(DesignOSSecondaryButtonStyle()) }
        case "shell/adaptive-navigation":
            DesignOSAdaptiveNavigationShell(columnVisibility: $columns) {
                List { NavigationLink("Reading collection") { adaptiveReadingDetail } }
                    .navigationTitle("Collections")
                    .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 300)
            } detail: { adaptiveReadingDetail }
        case "shell/native-host": DesignOSNativeHostShell { ContentUnavailableView("Local service preview", systemImage: "square.stack.3d.up", description: Text("Provider-owned content belongs inside this native host boundary.")) }
        default: EmptyView()
        }
    }

    private var selectionCountButton: some View {
        Button { reviewSelection = true } label: {
            HStack(spacing: style.metrics.itemSpacing) {
                Text("\(selectedReaders.count) Selected")
                Image(systemName: "chevron.right").foregroundStyle(style.palette.secondaryInk.color)
            }
        }
        .buttonStyle(DesignOSSecondaryButtonStyle())
        .accessibilityLabel("Review \(selectedReaders.count) selected readers")
        .accessibilityIdentifier("inventoryReviewSelection")
    }

    private var action: some View { Button(saved ? "Saved locally" : "Continue") { saved.toggle() }.buttonStyle(DesignOSPrimaryButtonStyle()) }
    private var identity: some View {
        DesignOSIdentityHeader { DesignOSAvatar(size: 56) { Text("AR").font(.title2) } } title: { Text("Alex Rivera").font(.title2) } metadata: { Text("Hosts the courtyard reading club").foregroundStyle(.secondary) } actions: { Button("View collection") { saved.toggle() }.buttonStyle(DesignOSSecondaryButtonStyle()) }
    }
    private var mediaRow: some View {
        DesignOSMediaRow { artwork } content: { VStack(alignment: .leading, spacing: 6) { Text("Courtyard reading club").font(.headline); Text("Saturday · 8 readers").foregroundStyle(.secondary) } }
    }
    private var composer: some View {
        DesignOSConversationComposer { Button("Attach", systemImage: "paperclip") { saved.toggle() } } input: {
            TextField("Message", text: $message, axis: .vertical).modifier(DesignOSAppTextFieldModifier(multiline: true))
        } actions: { Button("Send") { saved.toggle() }.buttonStyle(DesignOSPrimaryButtonStyle()) } feedback: { Text("Local draft · no message is sent").font(.caption).foregroundStyle(.secondary) }
    }
    private var shellReadingContent: some View { VStack(alignment: .leading, spacing: 24) { identity; framedArtwork; ForEach(1..<4) { n in sampleText("Chapter \(n): a shared reading") } } }
    // Each split-view detail path owns exactly one vertical scroll container.
    private var adaptiveReadingDetail: some View {
        DesignOSFlatScrollShell { shellReadingContent }
            .accessibilityIdentifier("inventoryAdaptiveReadingScroll")
    }
    private func sampleText(_ title: String) -> some View { VStack(alignment: .leading, spacing: 8) { Text(title).font(.headline); Text("Bring a favorite book and a story to share. Original fixture content for checking native layout.").foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading) }
    // Geometric artwork is synthetic specimen content, never a replacement implementation of a DS component.
    private var artwork: some View {
        GeometryReader { geometry in
            // Keep the symbol visible in avatar and row media while preserving the large-media inset.
            let size = geometry.size
            let inset = size.width.isFinite && size.height.isFinite
                ? min(32, max(0, min(size.width, size.height)) * 0.2)
                : 0
            ZStack {
                LinearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "books.vertical.fill").resizable().scaledToFit().padding(inset).foregroundStyle(.white.opacity(0.85))
            }
        }.accessibilityLabel("Original synthetic book artwork")
    }
    private var framedArtwork: some View { DesignOSMediaFrame(aspectRatio: 1.8, cornerRadius: 24) { artwork }.frame(maxWidth: 420) }
    private var composerArtwork: some View {
        // The app-owned media slot supplies the square cover and an explicit native edit action.
        DesignOSMediaFrame(aspectRatio: 1, cornerRadius: 24) {
            artwork.hueRotation(.degrees(saved ? 45 : 0))
        }
        .frame(maxWidth: 360)
        .overlay(alignment: .bottomTrailing) {
            Button { saved.toggle() } label: {
                Label("Edit local artwork", systemImage: "pencil").labelStyle(.iconOnly)
            }
            .buttonStyle(DesignOSSecondaryButtonStyle(size: .compact))
            .accessibilityLabel("Change local artwork colors")
            .accessibilityValue(saved ? "Alternate colors" : "Original colors")
            .accessibilityIdentifier("inventoryEditComposerArtwork")
            .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    private var cornerGeometry: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Geometry helper demonstration").font(.headline)
            Text("Outer radius 32 pt · actual inset 12 pt · derived inner radius 20 pt")
            RoundedRectangle(cornerRadius: 32, style: .continuous).fill(style.palette.subtleSurface.color)
                .overlay { RoundedRectangle(cornerRadius: DesignOSCornerGeometry.innerRadius(outerRadius: 32, inset: 12), style: .continuous).fill(style.palette.surface.color).padding(12) }
                .frame(height: 220)
            Text("This helper returns geometry; the nested shapes above visualize its result. It is not a standalone UI component.").font(.caption)
        }
    }
    private var colorRoles: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
            ForEach(Array(Self.colors.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 6) { RoundedRectangle(cornerRadius: 6).fill(item.1.color).frame(width: 28, height: 28).overlay { RoundedRectangle(cornerRadius: 6).stroke(.secondary, lineWidth: 0.5) }; Text(item.0).font(.caption2).fixedSize(horizontal: false, vertical: true) }
            }
        }
    }
    private static let colors: [(String, DesignOSColorRole)] = [
        ("Primary label", .labelPrimary), ("Secondary label", .labelSecondary), ("Tertiary label", .labelTertiary), ("Quaternary label", .labelQuaternary),
        ("Primary background", .backgroundPrimary), ("Secondary background", .backgroundSecondary), ("Tertiary background", .backgroundTertiary),
        ("Grouped primary", .groupedBackgroundPrimary), ("Grouped secondary", .groupedBackgroundSecondary), ("Grouped tertiary", .groupedBackgroundTertiary),
        ("Primary fill", .fillPrimary), ("Secondary fill", .fillSecondary), ("Tertiary fill", .fillTertiary), ("Quaternary fill", .fillQuaternary), ("Separator", .separator),
        ("Red", .red), ("Orange", .orange), ("Yellow", .yellow), ("Green", .green), ("Mint", .mint), ("Teal", .teal), ("Cyan", .cyan), ("Blue", .blue), ("Indigo", .indigo), ("Purple", .purple), ("Pink", .pink), ("Brown", .brown), ("Gray", .gray)
    ]
    private var typographyRoles: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Large title").font(DesignOSTypographyRole.largeTitle.font(profile: style.profile))
            Text("Title").font(DesignOSTypographyRole.title.font(profile: style.profile))
            Text("Title 2").font(DesignOSTypographyRole.title2.font(profile: style.profile))
            Text("Title 3").font(DesignOSTypographyRole.title3.font(profile: style.profile))
            Text("Headline").font(DesignOSTypographyRole.headline.font(profile: style.profile))
            Text("Subheadline").font(DesignOSTypographyRole.subheadline.font(profile: style.profile))
            Text("Body · reading together").font(DesignOSTypographyRole.body.font(profile: style.profile))
            Text("Callout").font(DesignOSTypographyRole.callout.font(profile: style.profile))
            Text("Footnote").font(DesignOSTypographyRole.footnote.font(profile: style.profile))
            Text("Caption").font(DesignOSTypographyRole.caption.font(profile: style.profile))
            Text("Caption 2").font(DesignOSTypographyRole.caption2.font(profile: style.profile))
            Text("Emphasized body").font(DesignOSTypographyRole.body.emphasized().font(profile: style.profile))
            Text("Italic body").font(DesignOSTypographyRole.body.italic().font(profile: style.profile))
        }
    }
    private var surfaceRoles: some View {
        VStack(spacing: 20) {
            surfaceSample("Content", role: .content)
            surfaceSample("Grouped content", role: .groupedContent)
            surfaceSample("Translucent content", role: .translucentContent)
        }
    }
    private func surfaceSample(_ title: String, role: DesignOSSurfaceRole) -> some View {
        let base = DesignOSProfile.default
        let profile = DesignOSProfile(typography: base.typography, spacing: base.spacing, radius: base.radius, semanticColors: base.semanticColors, surface: DesignOSSurfaceProfile(role: role), accessibility: base.accessibility)
        return Text(title).frame(maxWidth: .infinity, minHeight: 88).designOSCustomSurface().designOSProfile(profile)
    }
}

private struct InventoryCategory: Identifiable {
    let id: String
    let title: String
    let symbol: String
    static let samples = [Self(id: "nature", title: "Nature", symbol: "leaf"), Self(id: "art", title: "Art & design", symbol: "paintpalette"), Self(id: "travel", title: "Travel", symbol: "globe")]
}

private struct InventoryReader: Identifiable {
    let id: String
    let name: String
    let initials: String
    let detail: String
    static let samples = [
        Self(id: "alex", name: "Alex Rivera", initials: "AR", detail: "Available for the morning session"),
        Self(id: "sam", name: "Sam Chen", initials: "SC", detail: "Joined the reading club recently")
    ]
}
