import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1 – Topics
            TopicGridView()
                .tabItem {
                    Label("Topics", systemImage: "square.grid.2x2")
                }
                .tag(0)

            // Tab 2 – Progress
            ProgressDashboardView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(1)

            // Tab 3 – Search
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
        }
        .tint(Color.theme.knownGreen)
        .onAppear {
            styleTabBar()
        }
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.theme.surface)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    HomeView()
        .environment(AppEnvironment())
        .modelContainer(for: Flashcard.self, inMemory: true)
}
