import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct AddDocumentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var imageData: Data?
    @State private var recognizedText = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var cameraUnavailable = false
    @State private var isProcessing = false
    @State private var errorMessage: String?

    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Document") {
                    TextField("Title (optional)", text: $title)
                        .accessibilityIdentifier("document-title-field")

                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 280)
                            .accessibilityIdentifier("document-preview")
                    }

                    HStack(spacing: 16) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Label("Photos", systemImage: "photo")
                        }
                        .accessibilityIdentifier("choose-photo-button")

                        Button {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showingCamera = true
                            } else {
                                cameraUnavailable = true
                            }
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                        .accessibilityIdentifier("camera-button")
                    }
                }

                Section("Recognized Text") {
                    if recognizedText.isEmpty {
                        Text("Text will appear after saving.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(DocumentText.snippet(from: recognizedText, limit: 400))
                            .textSelection(.enabled)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(imageData == nil || isProcessing)
                    .accessibilityIdentifier("save-document-button")
                }
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker { data in
                    imageData = data
                } onCancel: {
                    showingCamera = false
                }
            }
            .alert("Camera unavailable", isPresented: $cameraUnavailable) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Use the photo library to import an image instead.")
            }
        }
    }

    private func save() {
        guard let data = imageData else { return }
        isProcessing = true
        errorMessage = nil
        Task {
            defer { isProcessing = false }
            do {
                let text = try await TextRecognizer.shared.recognizeText(in: data)
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalTitle = trimmedTitle.isEmpty ? DocumentText.generateTitle(from: text) : trimmedTitle
                try DocumentRepository.create(
                    title: finalTitle,
                    imageData: data,
                    recognizedText: text,
                    in: modelContext
                )
                recognizedText = text
                onDismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
