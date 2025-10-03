import SwiftUI

@main
struct TodoListApp: App {
    @State private var hasCompletedWelcome = false
    
    // ✅ เพิ่มตรงนี้
@StateObject private var viewModel = TodoViewModel()

    var body: some Scene {
        WindowGroup {
            if hasCompletedWelcome {
                MainTabView()
                    // ✅ Inject เข้าไปที่นี่
                    .environmentObject(viewModel)
            } else {
                WelcomeView(hasCompletedWelcome: $hasCompletedWelcome)
                    // ✅ Inject ตรงนี้ด้วย ถ้าใน WelcomeView
                    // จะมีการเรียกใช้ ProjectManager ภายหลัง
                    .environmentObject(viewModel)
            }
        }
    }
}
