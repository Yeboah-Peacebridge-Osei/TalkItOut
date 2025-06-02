//
//  TalkItOutApp.swift
//  TalkItOut
//
//  Created by Yeboah Peacebridge Osei on 6/1/25.
//

import SwiftUI

@main
struct TalkItOutApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
