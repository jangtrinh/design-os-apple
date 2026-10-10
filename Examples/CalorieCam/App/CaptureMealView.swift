import SwiftUI
import PhotosUI
import ImageIO
import UniformTypeIdentifiers
import DesignOSApple
import CalorieCamCore
#if os(iOS)
import UIKit
import AVFoundation
#elseif os(macOS)
import AppKit
#endif

struct CaptureMealView: View {
    @Environment(AISettingsStore.self) private var aiSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.designOSAppStyle) private var style
    @Bindable var model: JournalModel
    let journalDay: Date
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var preview: Image?
    @State private var choosingReplacement = false
    @State private var isSamplePhoto = false
    @State private var estimate: MealEntry?
    @State private var busy = false
    @State private var progressLabel = "Preparing photo…"
    @State private var error: String?
    @State private var importing = false
    @State private var camera = false
    @State private var discard = false
    @State private var confirmUpload = false
    @State private var pendingRoute: AnalysisRoute?
    private var hasAnalysisRoute: Bool { aiSettings.mode != .offline }
    @State private var work: Task<Void, Never>?
    @State private var requestID = UUID()

    var body: some View {
        NavigationStack {
            Group {
                if let entry = estimate {
                    MealReviewView(entry: entry, model: model, preview: preview) { dismiss() }
                } else {
                    captureForm
                        .navigationTitle("Add meal")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if imageData != nil || estimate != nil { discard = true }
                        else { dismiss() }
                    }
                    .accessibilityIdentifier("cancelMeal")
                    #if os(macOS)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    #endif
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, idealWidth: 560, minHeight: 560)
        #endif
        .interactiveDismissDisabled(imageData != nil || estimate != nil || busy)
        .confirmationDialog("Discard this meal?", isPresented: $discard, titleVisibility: .visible) {
            Button("Discard meal", role: .destructive) { work?.cancel(); dismiss() }
            Button("Keep editing", role: .cancel) {}
        } message: { Text("Your unsaved photo and meal changes will be discarded.") }
        .confirmationDialog("Send photo for estimation?", isPresented: $confirmUpload, titleVisibility: .visible) {
            Button("Send photo and estimate") { prepareRemoteEstimate() }
            Button("Keep photo on device", role: .cancel) {}
        } message: {
            Text("This sends your selected photo to \(pendingRoute?.recipient ?? "the selected recipient") to estimate foods and calories. Provider charges may apply. Avoid photos containing people or private information. Review the result before saving. Your journal and notes are not sent.")
        }
        .onDisappear { work?.cancel() }
        .onChange(of: aiSettings.revision) { _, _ in
            work?.cancel(); requestID = UUID(); busy = false
            confirmUpload = false; pendingRoute = nil
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            work?.cancel()
            busy = true
            progressLabel = "Preparing photo…"
            error = nil
            let request = UUID()
            requestID = request
            work = Task {
                defer { if requestID == request { busy = false; photoItem = nil } }
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        throw PhotoError.unreadable
                    }
                    try Task.checkCancellation()
                    guard requestID == request else { return }
                    try accept(data)
                } catch is CancellationError {} catch {
                    if requestID == request && !Task.isCancelled { self.error = error.localizedDescription }
                }
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.image]) { result in
            do {
                let url = try result.get()
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size <= 15_000_000 else { throw PhotoError.tooLarge }
                try accept(Data(contentsOf: url))
            } catch let failure as CocoaError where failure.code == .userCancelled {
                // Cancelling the system picker is an ordinary exit.
            } catch { self.error = error.localizedDescription }
        }
        #if os(iOS)
        .sheet(isPresented: $camera) {
            CameraPicker { result in
                camera = false
                switch result {
                case .success(let data): do { try accept(data) } catch { self.error = error.localizedDescription }
                case .failure(let error): self.error = error.localizedDescription
                }
            }
            .ignoresSafeArea()
        }
        #endif
    }

    private var captureForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
                Label(!hasAnalysisRoute ? "On-device demo" : "Photo meal entry", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(style.palette.secondaryInk.color)

                if let preview {
                    MealPhotoCover(image: preview, label: isSamplePhoto ? "Sample meal illustration" : "Selected meal photo, for your reference only", identifier: "selectedMealPhoto")
                    if isSamplePhoto {
                        Text("Sample illustration · fixed demo values")
                            .font(.caption)
                            .foregroundStyle(style.palette.secondaryInk.color)
                    }
                } else {
                    DesignOSAppSurface(tone: .subtle) {
                        VStack(spacing: style.metrics.itemSpacing) {
                            Image(systemName: "camera").font(.largeTitle).accessibilityHidden(true)
                            Text("Start with a photo").font(.title2.weight(.semibold))
                            Text("Capture your meal. Review every estimate.")
                                .font(.subheadline)
                                .foregroundStyle(style.palette.secondaryInk.color)
                        }
                        .frame(maxWidth: .infinity, minHeight: 160)
                    }
                }

                if imageData == nil || choosingReplacement {
                    sourceActions
                } else {
                    selectedPhotoActions
                }

                if busy { ProgressView(progressLabel).accessibilityIdentifier("preparingMeal") }
                if let error {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Couldn’t prepare meal").font(.headline).accessibilityAddTraits(.isHeader)
                        Text(error)
                        Text("Try another photo or enter your meal manually.")
                    }
                    .foregroundStyle(style.palette.ink.color)
                }

                DisclosureGroup("How estimates work") {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Demo estimates use fixed sample foods, not your photo. Edit all values before saving.")
                        Text(!hasAnalysisRoute ? "Photos stay on this device and are not saved in the journal." : "AI estimation sends a photo only after your confirmation. Photos are not saved in the journal.")
                    }
                    .padding(.top, style.metrics.itemSpacing)
                }
                .font(.footnote)
                .foregroundStyle(style.palette.secondaryInk.color)
            }
            .padding(style.metrics.pageInset)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background { MealPhotoBackdrop(preview: preview) }
        .accessibilityIdentifier("mealCaptureScroll")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var sourceActions: some View {
        VStack(spacing: style.metrics.itemSpacing) {
            #if os(iOS)
            Button { requestCamera() } label: {
                Label("Take photo", systemImage: "camera").frame(maxWidth: .infinity)
            }
            .buttonStyle(DesignOSPrimaryButtonStyle())
            .accessibilityIdentifier("takePhoto")
            #endif
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Choose photo", systemImage: "photo").frame(maxWidth: .infinity)
            }
            #if os(macOS)
            .buttonStyle(DesignOSPrimaryButtonStyle())
            #else
            .buttonStyle(DesignOSSecondaryButtonStyle())
            #endif
            .accessibilityIdentifier("choosePhoto")
            Menu {
                Button("Import image file", systemImage: "folder") { importing = true }
                Button("Try sample meal", systemImage: "testtube.2") { prepareSample() }
                    .accessibilityIdentifier("trySampleMeal")
            } label: {
                Label("More photo options", systemImage: "ellipsis").frame(maxWidth: .infinity)
            }
            .buttonStyle(DesignOSSecondaryButtonStyle())
            .accessibilityIdentifier("sourceOptions")
            if imageData != nil {
                Button("Keep current photo") { choosingReplacement = false }
                    .buttonStyle(DesignOSSecondaryButtonStyle())
                    .accessibilityIdentifier("keepCurrentPhoto")
            } else {
                Button("Enter meal manually", action: enterManually)
                    .buttonStyle(DesignOSSecondaryButtonStyle())
                    .accessibilityIdentifier("enterManually")
            }
        }
        .disabled(busy)
    }

    private var selectedPhotoActions: some View {
        VStack(spacing: style.metrics.itemSpacing) {
            if isSamplePhoto {
                Button("Review sample values") { prepareDemo() }
                    .buttonStyle(DesignOSPrimaryButtonStyle())
                    .accessibilityIdentifier("demoEstimate")
            } else if hasAnalysisRoute {
                Button("Estimate with AI") { prepareConsent() }
                    .buttonStyle(DesignOSPrimaryButtonStyle())
                    .accessibilityIdentifier("remoteEstimate")
            } else {
                Button("Enter meal details", action: enterManually)
                    .buttonStyle(DesignOSPrimaryButtonStyle())
                    .accessibilityIdentifier("enterManually")
            }
            Button("Change photo") { choosingReplacement = true }
                .buttonStyle(DesignOSSecondaryButtonStyle())
                .accessibilityIdentifier("changePhoto")
            Menu {
                if isSamplePhoto || hasAnalysisRoute {
                    Button("Enter meal manually", action: enterManually)
                        .accessibilityIdentifier("enterManually")
                }
                if !isSamplePhoto {
                    Button("Try fixed demo values") { prepareDemo() }
                        .accessibilityIdentifier("demoEstimate")
                }
                Button("Remove photo", role: .destructive) {
                    imageData = nil; preview = nil; isSamplePhoto = false; error = nil
                }
                .accessibilityIdentifier("removePhoto")
            } label: {
                Label("Other actions", systemImage: "ellipsis").frame(maxWidth: .infinity)
            }
            .buttonStyle(DesignOSSecondaryButtonStyle())
            .accessibilityIdentifier("selectedPhotoOptions")
        }
        .disabled(busy)
    }

    private func enterManually() {
        estimate = MealEntry(date: journalDay, items: [FoodItem(name: "", portion: "", calories: 0)], origin: .manual)
    }

    private func prepareSample() {
        do {
            guard let data = DemoMealAsset.data else { throw PhotoError.sampleUnavailable }
            try accept(data)
            isSamplePhoto = true
        } catch { self.error = error.localizedDescription }
    }

    private func prepareDemo() {
        guard let imageData else { return }
        error = nil
        busy = true
        progressLabel = "Loading demo values…"
        work = Task {
            defer { busy = false }
            do {
                let result = try await DemoMealAnalyzer().analyze(imageData: imageData)
                try Task.checkCancellation()
                estimate = MealEntry(date: journalDay, items: result.items, note: result.note, origin: result.origin)
            } catch is CancellationError {} catch { self.error = error.localizedDescription }
        }
    }

    private func prepareConsent() {
        do {
            let route = try aiSettings.route()
            work?.cancel()
            let request = UUID()
            requestID = request
            busy = true
            progressLabel = "Checking configuration…"
            work = Task {
                defer { if requestID == request { busy = false } }
                do {
                    if case .provider(let config) = route { _ = try await aiSettings.key(for: config.provider) }
                    try Task.checkCancellation()
                    guard requestID == request else { return }
                    pendingRoute = route
                    confirmUpload = true
                } catch is CancellationError {} catch {
                    if requestID == request { self.error = error.localizedDescription }
                }
            }
        } catch { self.error = error.localizedDescription }
    }

    private func prepareRemoteEstimate() {
        guard let imageData, let route = pendingRoute else { return }
        pendingRoute = nil
        work?.cancel()
        error = nil
        busy = true
        progressLabel = "Estimating meal…"
        let request = UUID()
        requestID = request
        work = Task {
            defer { if requestID == request { busy = false } }
            do {
                if aiSettings.isUITest { throw AISettingsError.testNetworkDisabled }
                let result: MealEstimate
                switch route {
                case .backend(let endpoint):
                    let analyzer = try RemoteMealAnalyzer(endpoint: endpoint, allowLocalhostHTTP: AnalysisConfiguration.allowsLocalHTTP)
                    result = try await analyzer.analyze(imageData: imageData)
                case .provider(let config):
                    let analyzer = try ProviderMealAnalyzer(configuration: config, apiKey: try await aiSettings.key(for: config.provider))
                    result = try await analyzer.analyze(imageData: imageData)
                }
                try Task.checkCancellation()
                guard requestID == request else { return }
                estimate = MealEntry(date: journalDay, items: result.items, note: result.note, origin: result.origin)
            } catch is CancellationError {} catch {
                if requestID == request && !Task.isCancelled { self.error = error.localizedDescription }
            }
        }
    }

    private func accept(_ data: Data) throws {
        guard data.count <= 15_000_000 else { throw PhotoError.tooLarge }
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 1_600
              ] as CFDictionary) else { throw PhotoError.unreadable }
        // Re-encode the downsampled raster: bounded upload and no source EXIF metadata.
        #if os(iOS)
        guard let jpeg = UIImage(cgImage: thumbnail).jpegData(compressionQuality: 0.85) else { throw PhotoError.unreadable }
        #elseif os(macOS)
        guard let jpeg = NSBitmapImageRep(cgImage: thumbnail).representation(using: .jpeg, properties: [.compressionFactor: 0.85]) else { throw PhotoError.unreadable }
        #endif
        guard jpeg.count <= RemoteMealAnalyzer.maximumImageBytes else { throw PhotoError.uploadTooLarge }
        #if os(iOS)
        preview = Image(uiImage: UIImage(cgImage: thumbnail))
        #elseif os(macOS)
        preview = Image(nsImage: NSImage(cgImage: thumbnail, size: .zero))
        #endif
        imageData = jpeg
        choosingReplacement = false
        isSamplePhoto = false
        error = nil
    }

    #if os(iOS)
    private func requestCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            error = "A camera isn’t available here. Choose a photo or import an image file."
            return
        }
        work?.cancel()
        busy = true
        error = nil
        let request = UUID()
        requestID = request
        progressLabel = "Waiting for camera permission…"
        work = Task {
            defer { if requestID == request { busy = false } }
            let allowed = await AVCaptureDevice.requestAccess(for: .video)
            guard !Task.isCancelled, requestID == request else { return }
            if allowed { camera = true }
            else { error = "Camera access is off. You can enable it in Settings, choose a photo, or enter a meal manually." }
        }
    }
    #endif
}

enum PhotoError: LocalizedError {
    case unreadable, tooLarge, uploadTooLarge, sampleUnavailable
    var errorDescription: String? {
        switch self {
        case .sampleUnavailable: "The sample image is unavailable. Choose your own photo or enter a meal manually."
        case .unreadable: "This file couldn’t be opened as a photo. Choose a JPEG, PNG or HEIC image."
        case .tooLarge: "Choose a photo smaller than 15 MB."
        case .uploadTooLarge: "This photo is still too large after resizing. Choose a smaller image."
        }
    }
}
