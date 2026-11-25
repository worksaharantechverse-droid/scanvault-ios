import Foundation
import UIKit
import Vision

enum RecognitionError: LocalizedError {
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The selected image could not be read."
        }
    }
}

actor TextRecognizer {
    static let shared = TextRecognizer()

    func recognizeText(in data: Data) async throws -> String {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else {
            throw RecognitionError.invalidImage
        }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        let lines = (request.results ?? []).compactMap { observation in
            observation.topCandidates(1).first?.string
        }
        return DocumentText.normalize(lines.joined(separator: "\n"))
    }
}
