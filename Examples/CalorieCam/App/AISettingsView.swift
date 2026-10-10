import SwiftUI
import CalorieCamCore
import DesignOSApple

struct AISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings: AISettingsStore
    @State private var appearance: AppAppearance
    @State private var mode: AnalysisMode
    @State private var provider: AIProvider
    @State private var modelDrafts: [AIProvider: String] = [:]
    @State private var keyDrafts: [AIProvider: String] = [:]
    @State private var hasStoredKey = false
    @State private var checkingKey = true
    @State private var error: String?
    @State private var connectionStatus: String?
    @State private var testing = false
    @State private var saving = false
    @State private var task: Task<Void, Never>?
    @State private var requestID = UUID()
    @State private var confirmingRemoval = false

    init(settings: AISettingsStore) {
        self.settings = settings
        _appearance = State(initialValue: settings.appearance)
        _mode = State(initialValue: settings.mode)
        _provider = State(initialValue: settings.provider)
    }

    private var model: Binding<String> {
        let selected = provider
        return Binding(get: { modelDrafts[selected] ?? settings.model(for: selected) }, set: { modelDrafts[selected] = $0; cancelTest() })
    }
    private var key: Binding<String> {
        let selected = provider
        return Binding(get: { keyDrafts[selected] ?? "" }, set: { keyDrafts[selected] = $0; cancelTest() })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppAppearance.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("appearancePicker")
                    Text("Applies to the journal, photos, meal details and settings.").font(.footnote)
                }
                Section("Photo estimation") {
                    Picker("Analysis mode", selection: $mode) {
                        ForEach(AnalysisMode.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("analysisMode")
                    Text("Manual entry and sample values always work without an API key.").font(.footnote)
                }
                if mode == .provider {
                    Section("Provider") {
                        Picker("Provider", selection: $provider) {
                            ForEach(AIProvider.allCases, id: \.self) { Text($0.displayName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("providerPicker")
                        TextField("Model ID", text: model)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("providerModel")
                        Text("Enter an exact model ID from your provider account. Photo estimation requires image input and structured output support.").font(.footnote)
                    }
                    Section("API key") {
                        Text(checkingKey ? "Checking secure storage…" : (hasStoredKey ? "Key saved securely on this device" : "No key saved for this provider"))
                            .accessibilityIdentifier("storedKeyStatus")
                        SecureField(hasStoredKey ? "Replacement API key (optional)" : "API key", text: key)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                            .autocorrectionDisabled()
                            .privacySensitive()
                            .accessibilityIdentifier("providerKey")
                        Text("Existing keys are never displayed. Save stores a new or replacement key only for the selected provider. Keys do not sync to other devices.")
                            .font(.footnote)
                        #if os(macOS)
                        Text("Uses your Mac’s default Keychain and its app-access controls. Keys may migrate with that Keychain; macOS may ask permission after app updates.").font(.footnote)
                        #endif
                        if hasStoredKey {
                            Button("Remove saved key", role: .destructive) { confirmingRemoval = true }
                                .buttonStyle(DesignOSSecondaryButtonStyle())
                                .accessibilityIdentifier("removeProviderKey")
                        }
                    }
                    Section("Connection") {
                        Button("Test connection", action: testConnection)
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .disabled(testing || checkingKey || saving)
                            .accessibilityIdentifier("testProviderConnection")
                        if testing { ProgressView("Checking model access…") }
                        if let connectionStatus { Text(connectionStatus).accessibilityIdentifier("connectionStatus") }
                        Text("Only when tapped: sends this provider’s key and model ID to its official API to check model access. No photo or inference request is sent. This does not save your changes.").font(.footnote)
                        Text("API billing is separate from chat subscriptions. Photo analysis may incur provider charges; check your provider’s terms and limits.").font(.footnote)
                    }
                } else if mode == .backend {
                    Section("Developer backend") {
                        Text(AnalysisConfiguration.endpoint?.host ?? "No backend configured")
                        Text("Configured by the app developer. Photo consent names this service and OpenAI. Your personal provider keys are never sent to this backend; it uses its own server credentials.").font(.footnote)
                    }
                }
                if let error { Section("Couldn’t update settings") { Text(error).accessibilityIdentifier("settingsError") } }
            }
            .formStyle(.grouped)
            .accessibilityIdentifier("aiSettingsForm")
            .disabled(saving)
            .navigationTitle("AI and appearance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { cancelTest(); dismiss() }
                        .accessibilityIdentifier("cancelAISettings")
                        .disabled(saving)
                        #if os(macOS)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        #endif
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(saving)
                        .accessibilityIdentifier("saveAISettings")
                        .keyboardShortcut(.defaultAction)
                        #if os(macOS)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        #endif
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 460, idealWidth: 520, minHeight: 560)
        #endif
        .interactiveDismissDisabled(saving)
        .onAppear(perform: refreshKeyStatus)
        .onChange(of: provider) { _, _ in cancelTest(); error = nil; refreshKeyStatus() }
        .onChange(of: mode) { _, _ in cancelTest(); refreshKeyStatus() }
        .onDisappear { cancelTest(); keyDrafts.removeAll() }
        .confirmationDialog("Remove the saved \(provider.displayName) key?", isPresented: $confirmingRemoval, titleVisibility: .visible) {
            Button("Remove key", role: .destructive) {
                cancelTest()
                let selected = provider
                Task {
                    do { try await settings.removeKey(for: selected); keyDrafts[selected] = nil; refreshKeyStatus() }
                    catch { self.error = error.localizedDescription }
                }
            }
            Button("Keep key", role: .cancel) {}
        } message: { Text("Removal takes effect immediately on this device. Other providers’ keys are unchanged.") }
    }

    private func refreshKeyStatus() {
        guard mode == .provider else { checkingKey = false; return }
        let selected = provider
        checkingKey = true
        hasStoredKey = false
        Task {
            do {
                let found = try await settings.keychain.read(selected) != nil
                guard provider == selected else { return }
                hasStoredKey = found
                checkingKey = false
            } catch {
                guard provider == selected else { return }
                hasStoredKey = false; checkingKey = false; self.error = error.localizedDescription
            }
        }
    }

    private func cancelTest() {
        task?.cancel()
        requestID = UUID()
        testing = false
        connectionStatus = nil
    }

    private func save() {
        cancelTest()
        let selected = provider
        let draft = mode == .provider ? (keyDrafts[selected] ?? "") : ""
        let selectedModel = model.wrappedValue
        let selectedMode = mode
        let selectedAppearance = appearance
        saving = true
        Task {
            defer { saving = false }
            do {
                try await settings.save(appearance: selectedAppearance, mode: selectedMode, provider: selected, model: selectedModel, replacementKey: draft.isEmpty ? nil : draft)
                keyDrafts.removeAll()
                dismiss()
            } catch { self.error = error.localizedDescription }
        }
    }

    private func testConnection() {
        cancelTest()
        error = nil
        do {
            let config = try ProviderConfiguration(provider: provider, modelID: model.wrappedValue)
            let draft = keyDrafts[provider] ?? ""
            let request = requestID
            testing = true
            task = Task {
                do {
                    let credential = draft.isEmpty ? try await settings.key(for: config.provider) : draft
                    let result = try await settings.verify(configuration: config, key: credential)
                    try Task.checkCancellation()
                    guard requestID == request else { return }
                    connectionStatus = result
                    testing = false
                } catch is CancellationError {} catch {
                    guard requestID == request else { return }
                    self.error = error.localizedDescription
                    testing = false
                }
            }
        } catch { self.error = error.localizedDescription }
    }
}
