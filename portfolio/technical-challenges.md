# Technical Challenges — ScanVault

## On-device OCR

`VNRecognizeTextRequest` performs text detection entirely on-device, avoiding API keys, network calls and privacy concerns. Recognition runs off the main actor so the UI remains responsive.

## Bridging UIKit into SwiftUI

Camera and share sheet capabilities are wrapped in SwiftUI-readable coordinators, keeping the rest of the app declarative.

## Searchable storage

Image data and OCR text live together in SwiftData. A pure `DocumentText` helper normalizes titles and search text, so queries are fast and testable.

## Simulator determinism

A `-UITestDemo` launch argument seeds two generated-JPEG documents, allowing meaningful screenshots without requiring physical camera hardware.

## Physical-device testing

Camera availability, permission prompts and OCR quality are documented rather than claimed as verified.
