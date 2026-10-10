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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.designOSAppStyle) private var style
    @Bindable var model: JournalModel
    let journalDay: Date
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var preview: Image?
    @State private var estimate: MealEntry?
    @State private var busy = false
    @State private var progressLabel = "Preparing photo…"
    @State private var error: String?
    @State private var importing = false
    @State private var camera = false
    @State private var discard = false
    @State private var confirmUpload = false
    private let analysisEndpoint = AnalysisConfiguration.endpoint
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
        .preferredColorScheme(.dark)
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
            Text("This sends your selected photo to \(analysisEndpoint?.host ?? "your configured service") and OpenAI to estimate foods and calories. Avoid photos containing people or private information. Review the result before saving. Your journal and notes are not sent.")
        }
        .onDisappear { work?.cancel() }
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
        let photoPickerTitle = imageData == nil ? "Choose photo" : "Replace photo"
        return ScrollView {
            VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
                Label(analysisEndpoint == nil ? "On-device demo" : "Photo meal entry", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(style.palette.secondaryInk.color)

                if let preview {
                    MealPhotoCover(image: preview, label: "Selected meal photo, for your reference only")
                } else {
                    DesignOSAppSurface(tone: .subtle) {
                        VStack(spacing: style.metrics.itemSpacing) {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                                .accessibilityHidden(true)
                            Text("Start with a photo")
                                .font(.title2.weight(.semibold))
                            Text("Capture your meal. Review every estimate.")
                                .font(.subheadline)
                                .foregroundStyle(style.palette.secondaryInk.color)
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                    }
                }

                VStack(spacing: style.metrics.itemSpacing) {
                    #if os(iOS)
                    Button { requestCamera() } label: {
                        Label(imageData == nil ? "Take photo" : "Retake photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DesignOSPrimaryButtonStyle())
                    .disabled(busy)
                    #endif
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(photoPickerTitle, systemImage: "photo")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(DesignOSSecondaryButtonStyle())
                    .disabled(busy)
                    Button { importing = true } label: {
                        Label("Import image file", systemImage: "folder")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(DesignOSSecondaryButtonStyle())
                    .disabled(busy)
                    if imageData != nil {
                        Button("Remove photo", role: .destructive) { imageData = nil; preview = nil }
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .disabled(busy)
                    }
                }

                if busy { ProgressView(progressLabel).accessibilityIdentifier("preparingMeal") }
                if let error {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Couldn’t prepare meal").font(.headline)
                        Text(error)
                        Text("Try another photo or enter your meal manually.")
                    }
                    .foregroundStyle(style.palette.ink.color)
                }

                VStack(spacing: style.metrics.itemSpacing) {
                    if analysisEndpoint != nil {
                        Button("Estimate with AI") { confirmUpload = true }
                            .buttonStyle(DesignOSPrimaryButtonStyle())
                            .disabled(imageData == nil || busy)
                            .accessibilityIdentifier("remoteEstimate")
                    }
                    Button("Enter meal manually") {
                        estimate = MealEntry(date: journalDay, items: [FoodItem(name: "", portion: "", calories: 0)], origin: .manual)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .disabled(busy)
                    .buttonStyle(DesignOSSecondaryButtonStyle())
                    .accessibilityIdentifier("enterManually")
                    if imageData != nil {
                        Button("Try demo estimate") { prepareDemo() }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .disabled(busy)
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .accessibilityIdentifier("demoEstimate")
                    } else {
                        Button("Try sample meal") { prepareSample() }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .disabled(busy)
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                            .accessibilityIdentifier("trySampleMeal")
                    }
                }

                DisclosureGroup("How estimates work") {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Demo estimates use fixed sample foods, not your photo. Edit all values before saving.")
                        Text(analysisEndpoint == nil ? "Photos stay on this device and are not saved in the journal." : "AI estimation sends a photo only after your confirmation. Photos are not saved in the journal.")
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

    private func prepareSample() {
        do {
            guard let data = DemoMealAsset.data else { throw PhotoError.sampleUnavailable }
            try accept(data)
            prepareDemo()
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

    private func prepareRemoteEstimate() {
        guard let imageData, let analysisEndpoint else { return }
        work?.cancel()
        error = nil
        busy = true
        progressLabel = "Estimating meal…"
        let request = UUID()
        requestID = request
        work = Task {
            defer { if requestID == request { busy = false } }
            do {
                let analyzer = try RemoteMealAnalyzer(endpoint: analysisEndpoint, allowLocalhostHTTP: AnalysisConfiguration.allowsLocalHTTP)
                let result = try await analyzer.analyze(imageData: imageData)
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
