import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddDocument = false

    var body: some View {
        NavigationStack {
            DocumentListView()
                .navigationTitle("ScanVault")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddDocument = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityIdentifier("add-document-button")
                    }
                }
                .sheet(isPresented: $showingAddDocument) {
                    AddDocumentView {
                        showingAddDocument = false
                    }
                }
        }
        .task {
            DemoSeed.seedIfNeeded(in: modelContext)
        }
    }
}
