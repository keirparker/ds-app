import SwiftUI
import SwiftData

@main
struct DSFlashApp: App {
    @State private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appEnvironment)
                .task {
                    await StreakManager.requestPermission()
                }
        }
        .modelContainer(for: Flashcard.self) { result in
            switch result {
            case .success(let container):
                FlashcardStore.seedIfNeeded(context: container.mainContext)
            case .failure(let error):
                print("[DSFlashApp] Failed to create model container: \(error)")
            }
        }
    }
}

// MARK: - ContentView (root)

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}
