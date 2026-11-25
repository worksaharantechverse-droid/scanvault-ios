import Foundation
import SwiftData

enum DocumentRepository {
    @discardableResult
    static func create(
        title: String,
        imageData: Data,
        recognizedText: String,
        createdAt: Date = Date(),
        in context: ModelContext
    ) throws -> ScannedDocument {
        let document = ScannedDocument(
            title: title,
            createdAt: createdAt,
            imageData: imageData,
            recognizedText: recognizedText
        )
        context.insert(document)
        try context.save()
        return document
    }

    static func fetch(in context: ModelContext, query: String = "") throws -> [ScannedDocument] {
        let descriptor = FetchDescriptor<ScannedDocument>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let documents = try context.fetch(descriptor)
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return documents
        }
        return documents.filter {
            DocumentText.matches(title: $0.title, recognizedText: $0.recognizedText, query: query)
        }
    }

    static func update(
        _ document: ScannedDocument,
        title: String,
        recognizedText: String? = nil,
        in context: ModelContext
    ) throws {
        document.title = title
        if let recognizedText {
            document.recognizedText = recognizedText
        }
        try context.save()
    }

    static func delete(_ document: ScannedDocument, in context: ModelContext) throws {
        context.delete(document)
        try context.save()
    }
}
