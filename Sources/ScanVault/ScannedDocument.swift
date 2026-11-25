import Foundation
import SwiftData

@Model
final class ScannedDocument {
    var title: String
    var createdAt: Date
    @Attribute(.externalStorage) var imageData: Data
    var recognizedText: String

    init(title: String, createdAt: Date = Date(), imageData: Data, recognizedText: String) {
        self.title = title
        self.createdAt = createdAt
        self.imageData = imageData
        self.recognizedText = recognizedText
    }
}
