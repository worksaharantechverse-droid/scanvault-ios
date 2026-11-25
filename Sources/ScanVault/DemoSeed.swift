import SwiftData
import UIKit

enum DemoSeed {
    private static let defaults = UserDefaults(suiteName: "com.portfolio.scanvault.demo")

    @MainActor
    static func seedIfNeeded(in context: ModelContext) {
        guard CommandLine.arguments.contains("-UITestDemo") else { return }
        guard defaults?.bool(forKey: "seeded") != true else { return }
        guard (try? DocumentRepository.fetch(in: context))?.isEmpty == true else { return }

        do {
            try DocumentRepository.create(
                title: "Invoice — Northwind Supply",
                imageData: receiptImageData(),
                recognizedText: """
                NORTHWIND SUPPLY
                INVOICE 2048
                Date: 12 Nov 2026
                Bill to: Portfolio Studio
                Item  Qty  Amount
                Scanner dock  1  129.00
                Shipping  1  12.50
                TOTAL  141.50
                Thank you for your business
                """,
                createdAt: Date(timeIntervalSince1970: 1_764_201_600),
                in: context
            )
            try DocumentRepository.create(
                title: "Meeting Notes — Vision Review",
                imageData: notesImageData(),
                recognizedText: """
                VISION REVIEW
                Thursday 10:30
                Attendees: Mira, Alex, Jordan
                Ship OCR on-device only
                Add text search to the archive
                Follow up: camera fallback on device
                Next review: Monday
                """,
                createdAt: Date(timeIntervalSince1970: 1_763_546_400),
                in: context
            )
            defaults?.set(true, forKey: "seeded")
        } catch {
            defaults?.set(false, forKey: "seeded")
        }
    }

    private static func receiptImageData() -> Data {
        let size = CGSize(width: 800, height: 1100)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            UIColor.white.setFill()
            renderer.fill(CGRect(origin: .zero, size: size))
            UIColor(red: 0.08, green: 0.20, blue: 0.38, alpha: 1).setFill()
            renderer.fill(CGRect(x: 0, y: 0, width: size.width, height: 180))
            draw("NORTHWIND SUPPLY", at: 62, size: 42, bold: true, color: .white)
            draw("INVOICE  2048", at: 124, size: 26, bold: false, color: UIColor.white.withAlphaComponent(0.85))
            draw("Date: 12 Nov 2026", at: 230, size: 28)
            draw("Bill to: Portfolio Studio", at: 274, size: 28)
            UIColor.systemGray3.setFill()
            renderer.fill(CGRect(x: 60, y: 336, width: 680, height: 2))
            draw("Scanner dock", at: 372, size: 30)
            draw("1", at: 372, x: 480, size: 30)
            draw("129.00", at: 372, x: 600, size: 30)
            draw("Shipping", at: 428, size: 30)
            draw("1", at: 428, x: 480, size: 30)
            draw("12.50", at: 428, x: 600, size: 30)
            UIColor.systemGray3.setFill()
            renderer.fill(CGRect(x: 60, y: 490, width: 680, height: 2))
            draw("TOTAL", at: 530, size: 36, bold: true)
            draw("141.50", at: 530, size: 36, bold: true)
            draw("Thank you for your business", at: 660, size: 24, color: .systemGray)
        }
        return image.jpegData(compressionQuality: 0.9) ?? Data()
    }

    private static func notesImageData() -> Data {
        let size = CGSize(width: 800, height: 1100)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            UIColor(red: 0.98, green: 0.96, blue: 0.88, alpha: 1).setFill()
            renderer.fill(CGRect(origin: .zero, size: size))
            UIColor(red: 0.85, green: 0.66, blue: 0.24, alpha: 1).setFill()
            renderer.fill(CGRect(x: 0, y: 0, width: size.width, height: 140))
            draw("VISION REVIEW", at: 44, size: 40, bold: true, color: .white)
            draw("Thursday 10:30", at: 190, size: 30, bold: true)
            draw("Attendees: Mira, Alex, Jordan", at: 240, size: 26)
            draw("Ship OCR on-device only", at: 320, size: 28)
            draw("Add text search to the archive", at: 372, size: 28)
            draw("Camera fallback on device", at: 424, size: 28)
            draw("Next review: Monday", at: 500, size: 28, bold: true)
            UIColor.systemGray3.setFill()
            renderer.fill(CGRect(x: 60, y: 580, width: 680, height: 2))
            draw("Action items", at: 620, size: 30, bold: true)
            draw("1. Verify photo permissions", at: 676, size: 26)
            draw("2. Test with printed receipts", at: 724, size: 26)
            draw("3. Share sheet polish", at: 772, size: 26)
        }
        return image.jpegData(compressionQuality: 0.9) ?? Data()
    }

    private static func draw(
        _ text: String,
        at y: CGFloat,
        x: CGFloat = 60,
        size: CGFloat,
        bold: Bool = false,
        color: UIColor = .label
    ) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
        NSString(string: text).draw(
            at: CGPoint(x: x, y: y),
            withAttributes: [.font: font, .foregroundColor: color]
        )
    }
}
