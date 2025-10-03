//
//  MainTabView.swift
//  plantodo
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = TodoViewModel()  // ✅ เพิ่ม viewModel
    @State private var selectedTab = 0
    @State private var showingAddProject = false  // ✅ เพิ่ม state สำหรับ AddProjectSheet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home/Todo List
            TodoListView(viewModel: viewModel)  // ✅ ส่ง viewModel
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: Calendar
            CalendarView(viewModel: viewModel)  // ✅ ส่ง viewModel
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            // Tab 3: Add (Center Button)
            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            // Tab 4: Projects (ใหม่)
            ProjectListView(viewModel: viewModel)  // ✅ ส่ง viewModel
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }
                .tag(3)
            
            // Tab 5: Profile
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 2 {
                showingAddProject = true
                selectedTab = 0  // กลับไป Tab แรก
            }
        }
        .sheet(isPresented: $showingAddProject) {
            AddProjectSheet(viewModel: viewModel)  // ✅ ส่ง viewModel
        }
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
