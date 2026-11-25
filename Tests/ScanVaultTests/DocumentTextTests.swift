import XCTest
@testable import ScanVault

final class DocumentTextTests: XCTestCase {
    func testNormalizeCollapsesWhitespaceAndBlankLines() {
        let input = "  Hello   world \r\n\r\n Second\tline  \n"
        XCTAssertEqual(DocumentText.normalize(input), "Hello world\nSecond line")
    }

    func testGenerateTitleUsesFirstRecognizedLine() {
        XCTAssertEqual(DocumentText.generateTitle(from: "  INVOICE  2026\nTotal: 42"), "INVOICE 2026")
    }

    func testGenerateTitleFallsBackWhenTextIsEmpty() {
        XCTAssertEqual(DocumentText.generateTitle(from: "  \n  "), "Untitled Scan")
        XCTAssertEqual(DocumentText.generateTitle(from: "", fallback: "New Scan"), "New Scan")
    }

    func testGenerateTitleTruncatesLongLines() {
        let title = DocumentText.generateTitle(from: String(repeating: "A", count: 80))
        XCTAssertEqual(title.count, 48)
        XCTAssertTrue(title.hasSuffix("…"))
    }

    func testSnippetKeepsShortTextAndTruncatesLongText() {
        XCTAssertEqual(DocumentText.snippet(from: "one\ntwo", limit: 20), "one\ntwo")
        XCTAssertEqual(DocumentText.snippet(from: String(repeating: "x", count: 40), limit: 11).count, 11)
    }

    func testMatchesSearchesTitleAndRecognizedTextCaseInsensitively() {
        XCTAssertTrue(DocumentText.matches(title: "Receipt", recognizedText: "TOTAL 42", query: ""))
        XCTAssertTrue(DocumentText.matches(title: "Receipt", recognizedText: "TOTAL 42", query: "receipt"))
        XCTAssertTrue(DocumentText.matches(title: "Receipt", recognizedText: "TOTAL 42", query: " total "))
        XCTAssertFalse(DocumentText.matches(title: "Receipt", recognizedText: "TOTAL 42", query: "invoice"))
    }
}
