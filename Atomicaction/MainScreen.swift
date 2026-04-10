//
//  MainScreen.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/28/26.
//
import SwiftUI
import SwiftData
struct MainScreen: View {
    @State private var selectedTab: Tab = .home
    @State private var firstTask: Task? = nil
    @State var selectedSlot: TimeSlot? = nil
    @State var selectedDuration: Int = 30
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                tabContent
                bottomTabBar
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(AppConsts.spaceblack)
        //.frame(maxWidth: .infinity, maxHeight: .infinity)

    }
    
    private var tabContent: some View {
        GeometryReader { geometry in  // geometry scoped HERE ↓
            HStack(spacing: 0) {
                EclipseView()
                TaskListView()
                ScheduleTaskSheet(
                    //tasks: mockTasks,
                    selectedSlot: $selectedSlot,
                    selectedDuration: $selectedDuration
                )
            }
            .frame(width: geometry.size.width * 3)
            .offset(x: -CGFloat(selectedTab.rawValue) * geometry.size.width)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onEnded { value in
                        
                        //Option 2
                        let dragThreshold: CGFloat = 10  // Smaller threshold
                        let xMovement = abs(value.translation.width)
                        
                        guard xMovement > dragThreshold else { return }
                        
                        let newIndex: Int
                        if value.translation.width > 0 {
                            // Right swipe → PREVIOUS tab (Home→History works!)
                            newIndex = max(selectedTab.rawValue - 1, 0)
                        } else {
                            // Left swipe → NEXT tab
                            newIndex = min(selectedTab.rawValue + 1, Tab.allCases.count - 1)
                        }
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = Tab.allCases[newIndex]
                        }
                    }
            )
            .contentShape(Rectangle())
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .clipped()

    }

    private var bottomTabBar: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack {
                        Image(systemName: tab.image)
                            .font(.title2)
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                        Text(tab.title)
                            .font(.caption2)
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .gray)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        //.background(AppConstants.spaceblack)
    }
}


#Preview {
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
    MainScreen()
        .modelContainer(makePreviewContainer())
        //.modelContainer(sharedModelContainer)
}
