import SwiftData
import XCTest
@testable import ScanVault

@MainActor
final class DocumentRepositoryTests: XCTestCase {
    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: ScannedDocument.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    func testCreateFetchSearchUpdateAndDelete() throws {
        let context = try makeContext()
        XCTAssertTrue(try DocumentRepository.fetch(in: context).isEmpty)

        let document = try DocumentRepository.create(
            title: "Receipt",
            imageData: Data([1, 2, 3]),
            recognizedText: "TOTAL 42",
            createdAt: Date(timeIntervalSince1970: 100),
            in: context
        )
        XCTAssertEqual(document.title, "Receipt")
        XCTAssertEqual(document.imageData, Data([1, 2, 3]))

        let fetched = try DocumentRepository.fetch(in: context)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.recognizedText, "TOTAL 42")
        XCTAssertEqual(try DocumentRepository.fetch(in: context, query: "total").count, 1)
        XCTAssertTrue(try DocumentRepository.fetch(in: context, query: "invoice").isEmpty)

        try DocumentRepository.update(document, title: "Updated", recognizedText: "NEW TEXT", in: context)
        XCTAssertEqual(document.title, "Updated")
        XCTAssertEqual(document.recognizedText, "NEW TEXT")

        try DocumentRepository.delete(document, in: context)
        XCTAssertTrue(try DocumentRepository.fetch(in: context).isEmpty)
    }

    func testFetchSortsNewestFirst() throws {
        let context = try makeContext()
        try DocumentRepository.create(
            title: "Old",
            imageData: Data(),
            recognizedText: "",
            createdAt: Date(timeIntervalSince1970: 10),
            in: context
        )
        try DocumentRepository.create(
            title: "New",
            imageData: Data(),
            recognizedText: "",
            createdAt: Date(timeIntervalSince1970: 20),
            in: context
        )
        XCTAssertEqual(try DocumentRepository.fetch(in: context).map(\.title), ["New", "Old"])
    }
}
