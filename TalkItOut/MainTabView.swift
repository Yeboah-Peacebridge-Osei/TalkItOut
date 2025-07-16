import SwiftUI

struct MainTabView: View {
    @StateObject private var journalEntriesModel = JournalEntriesModel()
    @StateObject private var textJournalModel = TextJournalEntriesModel()
    var body: some View {
        TabView {
            // Record Tab (main feature)
            ContentView()
                .tabItem {
                    Image(systemName: "plus.app")
                    Text("Record")
                }
            // Text Entry Tab (middle)
            TextJournalListView()
                .environmentObject(textJournalModel)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Text Entry")
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