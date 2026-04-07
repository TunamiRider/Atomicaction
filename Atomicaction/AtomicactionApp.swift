//
//  AtomicactionApp.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/20/26.
//

import SwiftUI
import SwiftData

@main
struct AtomicactionApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // ContentView()
//            EclipseView(
//                taskTitle: "Design Review",
//                taskDescription: "Go through the latest mockups with the team and collect feedback on the new onboarding flow before Thursday's deadline.",
//                taskCategory: .work
//            )
            
//            TaskListView()
//                .modelContainer(makePreviewContainer())
            
            //TaskListView()
                //.modelContainer(makePreviewContainer())
            MainScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}
