# ScanVault

A native SwiftUI document vault that imports photos, extracts text on-device with Vision, stores documents in SwiftData and supports search, sharing and deletion.

## Installation

```bash
cd 05-ScanVault
brew install xcodegen
xcodegen generate
open ScanVault.xcodeproj
```

## Build

```bash
xcodebuild -project ScanVault.xcodeproj -scheme ScanVault \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/ScanVaultDerived CODE_SIGNING_ALLOWED=NO build
```

## Architecture

- **Model**: `ScannedDocument` (SwiftData) stores title, creation date, JPEG data and recognized text.
- **Repository**: `DocumentRepository` owns CRUD and querying; supports an in-memory container in tests.
- **Services**: `TextRecognizer` runs `VNRecognizeTextRequest` off the main actor; `CameraPicker` and `ShareSheet` wrap UIKit capabilities for SwiftUI.
- **Views**: `RootView`, `DocumentListView`, `AddDocumentView`, `DocumentDetailView`.
- **Helpers**: `DocumentText` provides pure title generation and normalization.

## Features

- Photo Library import via `PhotosPicker` and camera fallback via `UIImagePickerController`.
- On-device OCR with normalized, searchable recognized text.
- Document list with live search by title or recognized text.
- Detail screen with large image, editable title and full OCR text.
- Delete and system share sheet.
- Demo launch argument `-UITestDemo` seeds two sample documents for screenshots.
- Light and dark appearance.

## Verification

- Build: passed on Xcode 26.0.1, iOS 17.0 deployment target.
- Test targets compile via `build-for-testing`.
- Unit and UI tests authored; execution skipped at the user's request.
- Installed and launched on iPhone 17 (iOS 26.0) with seeded demo documents; genuine light and dark screenshots captured.

## Known limitations

- Camera capture requires a physical device with a camera; the simulator uses the photo library.
- OCR accuracy depends on image quality and device hardware.
- Documents stay in the app sandbox; there is no cloud sync.
