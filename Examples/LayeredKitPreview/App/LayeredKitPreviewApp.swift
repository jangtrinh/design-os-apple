import DesignOSApple
import SwiftUI

@main
struct LayeredKitPreviewApp: App {
    @State private var appearance = ProcessInfo.processInfo.environment["LAYERED_KIT_APPEARANCE"]
        .flatMap(PreviewAppearance.init(rawValue:)) ?? .system
    var body: some Scene {
        WindowGroup {
            Group {
                if let componentID = ProcessInfo.processInfo.environment["LAYERED_KIT_COMPONENT"],
                   ComponentInventorySpecimen.supports(componentID) {
                    ComponentInventorySpecimen(componentID: componentID)
                } else {
                    PreviewNavigation(appearance: $appearance)
                }
            }
                .designOSAppStyle(.editorial)
                .preferredColorScheme(appearance.scheme)
        }
    }
}

struct PreviewNavigation: View {
    @Binding var appearance: PreviewAppearance
    @State private var selected: Specimen?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var variant = PreviewState.populated
    @State private var options = false
    @State private var largeText = false
    @State private var rightToLeft = false
    @State private var hideMedia = false

    init(appearance: Binding<PreviewAppearance>) {
        _appearance = appearance
        // Public fixture deep link for reproducible native captures; no product or secret state.
        _selected = State(initialValue: ProcessInfo.processInfo.environment["LAYERED_KIT_SPECIMEN"]
            .flatMap(Specimen.init(rawValue:)))
    }

    var body: some View {
        DesignOSAdaptiveNavigationShell(columnVisibility: $columnVisibility) {
            List(selection: $selected) {
                Section("Reusable layers") {
                    ForEach([Specimen.foundations, .composites, .shells, .textFields]) { item in row(item) }
                }
                Section("18 screen families") {
                    ForEach(Specimen.screens) { item in row(item) }
                }
            }
            .navigationTitle("Native kit")
            .toolbar { if selected == nil { previewToolbar } }
        } detail: {
            NavigationStack {
                Group {
                    if let selected {
                        SpecimenContent(specimen: selected, variant: $variant, hideMedia: hideMedia)
                            .navigationTitle(selected.title)
                            #if os(iOS)
                            .navigationBarTitleDisplayMode(
                                [Specimen.flatCollection, .groupedForm, .searchSelection].contains(selected) ? .inline : .automatic
                            )
                            #endif
                    } else {
                        ContentUnavailableView("Choose a specimen", systemImage: "square.grid.2x2",
                            description: Text("Native compositions with original fixture content."))
                    }
                }
                .toolbar { if selected != nil { previewToolbar } }
            }
        }
        .environment(\.layoutDirection, rightToLeft ? .rightToLeft : .leftToRight)
        .dynamicTypeSize(largeText ? .accessibility3 : .large)
        .sheet(isPresented: $options) {
            NavigationStack {
                DesignOSGroupedFormShell {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(PreviewAppearance.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented).accessibilityIdentifier("previewAppearance")
                    Picker("State", selection: $variant) {
                        ForEach(PreviewState.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented).accessibilityIdentifier("previewState")
                    Toggle("Accessibility text size", isOn: $largeText).accessibilityIdentifier("previewLargeText")
                    Toggle("Right-to-left layout", isOn: $rightToLeft).accessibilityIdentifier("previewRTL")
                    Toggle("No media", isOn: $hideMedia).accessibilityIdentifier("previewNoMedia")
                    Text("State controls are deterministic fixtures. They do not run network, payment or camera operations.")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("Preview options")
                .toolbar { ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { options = false }.accessibilityIdentifier("closePreviewOptions")
                } }
            }
            #if os(macOS)
            .frame(minWidth: 560, idealWidth: 600, minHeight: 440, idealHeight: 520)
            #endif
        }
    }

    @ToolbarContentBuilder
    private var previewToolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Preview options", systemImage: "slider.horizontal.3") { options = true }
                .accessibilityIdentifier("previewOptions")
        }
    }

    private func row(_ item: Specimen) -> some View {
        NavigationLink(value: item) {
            VStack(alignment: .leading) {
                Text(item.title)
                if !item.available { Text("Planned API").font(.caption).foregroundStyle(.secondary) }
            }
        }.accessibilityIdentifier("route-\(item.id)")
    }
}
