import SwiftData
import SwiftUI

@main
struct ScanVaultApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: ScannedDocument.self)
    }
}
