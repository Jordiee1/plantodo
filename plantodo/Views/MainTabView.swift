//
//  MainTabView.swift
//  plantodo
//
// โค้ดฉบับสมบูรณ์ที่ใช้โทนสีใหม่และปรับลำดับ Tab Bar
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var selectedTab = 0
    @State private var showingAddTodoSheet = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                
                // Tab 0: Home
                TodoListView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                // Tab 1: Projects (แทน Calendar เดิม)
                ProjectListView(viewModel: viewModel)
                    .tabItem {
                        Label("Projects", systemImage: "folder.fill")
                    }
                    .tag(1)
                
                // Tab 2: ปุ่ม Add กลาง (ซ่อนเนื้อหา, ใช้ Tag เพื่อดักจับการกด)
                Color.clear // View ว่าง
                    .tag(2)
                    // ✅ ไม่มี .tabItem() เพื่อให้ไอคอนไม่แสดงผล
                
                // Tab 3: Upload/Backup
                BackupView()
                    .tabItem {
                        Label("Upload", systemImage: "arrow.up.doc.fill")
                    }
                    .tag(3)
                
                // Tab 4: Profile
                ProfileView(viewModel: viewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            // ✅ Logic การเปิด Sheet เมื่อผู้ใช้กด Tab ที่ 2
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == 2 {
                    showingAddTodoSheet = true
                    // กลับไป Tab ล่าสุดที่เลือก
                    selectedTab = oldValue
                }
            }
            .sheet(isPresented: $showingAddTodoSheet) {
                AddTodoSheet(viewModel: viewModel)
            }
            // ✅ ใช้ Accent Color
            .accentColor(.accentColor)
            
            // MARK: - Floating Add Button Overlay (ด้านนอก TabView)
            
            VStack {
                Spacer()
                
                Button(action: {
                    showingAddTodoSheet = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor) // วงกลมพื้นหลัง
                            .frame(width: 58, height: 58)
                            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                // จัดตำแหน่งให้ลอยอยู่เหนือ Tab Bar
                .offset(y: -45)
            }
            .ignoresSafeArea(edges: .bottom) // ให้ปุ่มไม่ถูกตัดขอบ
        }
        .onAppear {
                    // ✅ FIX: เรียกใช้การตั้งเวลาแจ้งเตือนเมื่อแอปเปิด
                    viewModel.scheduleNotifications(for: viewModel.todos)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // ✅ ตั้งค่าใหม่ทุกครั้งที่แอปกลับมาทำงาน
                    viewModel.scheduleNotifications(for: viewModel.todos)
                }
    }
}
