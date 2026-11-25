import SwiftData
import SwiftUI

struct DocumentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var editedTitle = ""
    @State private var isEditingTitle = false
    @State private var showingShare = false
    @State private var confirmingDelete = false

    let document: ScannedDocument

    private var shareImage: UIImage? {
        UIImage(data: document.imageData)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    if let image = UIImage(data: document.imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 420)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 240)
                    }
                }
                .accessibilityIdentifier("document-detail-image")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recognized Text")
                        .font(.headline)
                    if document.recognizedText.isEmpty {
                        Text("No text was found in this scan.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(document.recognizedText)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("recognized-text")
            }
            .padding()
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editedTitle = document.title
                    isEditingTitle = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityIdentifier("edit-title-button")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    showingShare = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("share-document-button")

                Button(role: .destructive) {
                    confirmingDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("delete-document-button")
            }
            .padding()
            .background(.bar)
        }
        .alert("Edit Title", isPresented: $isEditingTitle) {
            TextField("Title", text: $editedTitle)
                .accessibilityIdentifier("edit-title-field")
            Button("Save") {
                let trimmed = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                try? DocumentRepository.update(document, title: trimmed, in: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete this document?", isPresented: $confirmingDelete) {
            Button("Delete", role: .destructive) {
                try? DocumentRepository.delete(document, in: modelContext)
                dismiss()
            }
        }
        .sheet(isPresented: $showingShare) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }
}
