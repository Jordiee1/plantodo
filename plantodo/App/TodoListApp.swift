import SwiftUI

@main
struct TodoListApp: App {
    @StateObject var viewModel = TodoViewModel()
    @AppStorage("hasCompletedWelcome") var hasCompletedWelcome: Bool = false
    
    // ✅ กำหนดชื่อฟอนต์หลัก
    let regularFontName = "IBMPlexSansThai-Medium"
    init() {
           // ✅ ใช้ฟอนต์ระบบแทน ไม่ต้องโหลดไฟล์ฟอนต์
           setupAppearance()
       }
    var body: some Scene {
        WindowGroup {
            if hasCompletedWelcome {
                MainTabView()
                    // ✅ กำหนดฟอนต์ก่อนส่ง environmentObject
                    .font(.custom(regularFontName, size: 16))
                    .environmentObject(viewModel)
            } else {
                WelcomeView(viewModel: viewModel)
                    // ✅ กำหนดฟอนต์ก่อนส่ง environmentObject
                    .font(.custom(regularFontName, size: 16))
                    .environmentObject(viewModel)
            }
               
        }
        .environment(\.customBodyFont,
                                     .pdsanThai(style: .body, weight: .regular))
    }
    private func setupAppearance() {
            // ✅ ใช้ San Francisco Font (ฟอนต์ระบบของ iOS)
            // รองรับภาษาไทยได้ดีมาก ไม่ต้องใช้ custom font
            
            // Navigation Bar
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = UIColor.white
            navigationBarAppearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            navigationBarAppearance.largeTitleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            
            // Tab Bar
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.white
            
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.gray
            ]
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor(red: 1.0, green: 0.42, blue: 0.62, alpha: 1.0)
            ]
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

