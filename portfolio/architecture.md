# Architecture — ScanVault

## Layers

| Layer | Types | Responsibility |
|-------|-------|----------------|
| Model | `ScannedDocument` | SwiftData record with image data, title and OCR text |
| Repository | `DocumentRepository` | CRUD and query operations, injectable in-memory container |
| Services | `TextRecognizer`, `CameraPicker`, `ShareSheet` | Vision OCR and UIKit capability bridges |
| Helpers | `DocumentText`, `DemoSeed` | Pure text processing and opt-in sample data |
| Views | `RootView`, `DocumentListView`, `AddDocumentView`, `DocumentDetailView` | SwiftUI navigation and presentation |

## OCR flow

An imported `UIImage` is converted to JPEG and passed to `VNRecognizeTextRequest` on a non-main actor. Normalized text is stored with the document, making search a simple SwiftData predicate without recomputing OCR.

## Device bridges

SwiftUI lacks native camera and share APIs, so `CameraPicker` wraps `UIImagePickerController` and `ShareSheet` wraps `UIActivityViewController` behind SwiftUI-compatible interfaces.

## SOLID application

- Single responsibility: OCR, persistence and device capabilities are separate.
- Dependency inversion: views depend on repository and recognizer abstractions.
- Liskov substitution: tests can use an in-memory repository and a stub recognizer.
