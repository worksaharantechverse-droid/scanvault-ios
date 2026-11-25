import SwiftData
import SwiftUI

struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScannedDocument.createdAt, order: .reverse) private var documents: [ScannedDocument]
    @State private var searchText = ""

    private var filteredDocuments: [ScannedDocument] {
        documents.filter {
            DocumentText.matches(title: $0.title, recognizedText: $0.recognizedText, query: searchText)
        }
    }

    var body: some View {
        Group {
            if filteredDocuments.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: documents.isEmpty ? "doc.viewfinder" : "magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    Text(documents.isEmpty ? "No scans yet" : "No matching scans")
                        .font(.headline)
                    Text(documents.isEmpty ? "Import a photo or capture a document to get started." : "Try a different title or text.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .accessibilityIdentifier("documents-empty-state")
            } else {
                List {
                    ForEach(filteredDocuments) { document in
                        NavigationLink {
                            DocumentDetailView(document: document)
                        } label: {
                            DocumentRow(document: document)
                        }
                        .accessibilityIdentifier("document-row-\(document.title)")
                    }
                    .onDelete { offsets in
                        let targets = offsets.compactMap { index in
                            filteredDocuments.indices.contains(index) ? filteredDocuments[index] : nil
                        }
                        for document in targets {
                            try? DocumentRepository.delete(document, in: modelContext)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search title or recognized text")
        .accessibilityIdentifier("document-list")
    }
}

private struct DocumentRow: View {
    let document: ScannedDocument

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let image = UIImage(data: document.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(DocumentText.snippet(from: document.recognizedText, limit: 80))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(document.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
