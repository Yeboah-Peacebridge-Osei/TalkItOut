import SwiftUI

struct MainTabView: View {
    @StateObject private var journalEntriesModel = JournalEntriesModel()
    var body: some View {
        TabView {
            // Record Tab (main feature)
            ContentView()
                .tabItem {
                    Image(systemName: "plus.app")
                    Text("Record")
                }
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .environmentObject(journalEntriesModel)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 