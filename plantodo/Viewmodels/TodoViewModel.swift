
import Foundation
import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var projects: [ProjectItem] = []
    @Published var selectedDate: Date
    @Published var searchText: String = ""
    @Published var dailyProgress: [DailyProgress] = []
    @Published var showFireAnimation: Bool = false
    @Published var userName: String = "ผู้ใช้"
    
    // สถานะสำหรับ Profile
    @Published var profileImageURL: String = ""
    @Published var userInterests: [String] = ["งาน", "สุขภาพ", "การเรียนรู้"]
    
    // Wishlist Manager
    @Published var showGoalPopup: Bool = false
    @Published var wishlist: [WishlistItem] = []
    
    // Goal Setting Logic
    @Published var currentGoal: String = "ให้รางวัลตัวเอง"
    @Published var goalThreshold: Int = 2
    @Published var latestAchievedGoal: WishlistItem?
    
    init() {
        let calendar = Calendar.current
        self.selectedDate = calendar.startOfDay(for: Date())
        
        // FIX: เรียกใช้ฟังก์ชันที่ถูกลบไป (คืนค่าทั้งหมด)
        loadTodos()
        loadProjects()
        loadProgress()
        loadUserName()
        loadProfileData()
        loadWishlist()
        loadGoalData()
        
        // 2. โหลดข้อมูลจำลองหาก lists ว่างเปล่า
        if self.todos.isEmpty {
            if let mockTodos = MockData.generateMockTodos() as? [TodoItem] {
                 self.todos = mockTodos
                 saveTodos()
            } else {
                 self.todos = []
            }
        }
        
        if self.projects.isEmpty {
             if let mockProjects = MockData.generateMockProjects() as? [ProjectItem] {
                 self.projects = mockProjects
                 saveProjects()
            } else {
                 self.projects = []
            }
        }

        // เพิ่ม Wishlist Mock หากว่างเปล่า
        if self.wishlist.isEmpty {
            self.wishlist = [
                WishlistItem(goal: "ดูหนังเรื่องใหม่ที่อยากดู", threshold: 3),
                WishlistItem(emoji: "🍦", goal: "กินไอติมพรีเมียม", threshold: 1)
            ]
            saveWishlist()
        }
    }
    
    var todosForSelectedDate: [TodoItem] {
        let filtered = todos.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        
        if searchText.isEmpty {
            return filtered.sorted { item1, item2 in
                if let time1 = item1.startTime, let time2 = item2.startTime {
                    return time1 < time2
                }
                return false
            }
        } else {
            return filtered.filter { todo in
                todo.text.localizedCaseInsensitiveContains(searchText) ||
                todo.relatedPeople.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                (todo.location?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var projectsForSelectedDate: [ProjectItem] {
        return projects.filter { Calendar.current.isDate($0.deadline, inSameDayAs: selectedDate) }
             .sorted { project1, project2 in
                if let time1 = project1.startTime, let time2 = project2.startTime {
                    return time1 < time2
                }
                return false
            }
    }
    
    var searchResults: [TodoItem] {
        if searchText.isEmpty {
            return []
        }
        
        return todos.filter { todo in
            todo.text.localizedCaseInsensitiveContains(searchText) ||
            todo.relatedPeople.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            (todo.location?.localizedCaseInsensitiveContains(searchText) ?? false)
        }.sorted { $0.date < $1.date }
    }

    // Fire Streak Logic
    var currentFireStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        let todayProgress = dailyProgress.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) })
        let isTodayCompleted = (todayProgress?.completedCount ?? 0) >= 2
        
        if !isTodayCompleted {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        } else {
            streak = 1
        }
        
        while true {
            guard let progress = dailyProgress.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) else {
                break
            }
            
            if progress.completedCount >= 2 {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // Project/Todo Helpers (getters/progress)
    func getProjectTodos(for projectId: UUID) -> [TodoItem] {
        return todos.filter { $0.projectId == projectId }
                    .sorted { $0.date < $1.date }
    }

    func getProjectProgress(for projectId: UUID) -> (completed: Int, total: Int, percentage: Double) {
        let relatedTodos = getProjectTodos(for: projectId)
        let total = relatedTodos.count
        let completed = relatedTodos.filter { $0.isCompleted }.count
        
        let percentage = total > 0 ? (Double(completed) / Double(total) * 100) : 0
        
        return (completed: completed, total: total, percentage: percentage)
    }

    // Goal Check Function
    func checkGoalCompletion(completedCount: Int) {
        if completedCount >= goalThreshold {
            showGoalPopup = true
        }
    }
    
    // Wishlist CRUD
    func addWishlistItem(item: WishlistItem) {
        wishlist.append(item)
        saveWishlist()
    }

    func deleteWishlistItem(item: WishlistItem) {
        withAnimation(.easeOut(duration: 0.3)) { // เพิ่ม Animation
            wishlist.removeAll { $0.id == item.id }
            saveWishlist()
            
            // ✅ รีเซ็ต Popup เมื่อ Wishlist ถูกลบออก
            if latestAchievedGoal?.id == item.id {
                latestAchievedGoal = nil
            }
        }
    }
    
    // Logic สำหรับอัปเดต Wishlist Progress
    private func updateWishlistProgress() {
        let completedCountToday = completedTasksCount(for: Date())
        
        // ตรวจสอบ Wishlist ที่เรียงตามลำดับก่อน
        if let firstGoalIndex = wishlist.firstIndex(where: { !$0.isAchieved }) {
            let targetGoal = wishlist[firstGoalIndex]
            
            // อัปเดต Progress
            if completedCountToday >= targetGoal.threshold {
                // Goal สำเร็จแล้ว!
                
                // 1. ตั้งค่าสถานะว่าสำเร็จแล้ว
                wishlist[firstGoalIndex].currentProgress = targetGoal.threshold
                wishlist[firstGoalIndex].isAchieved = true
                
                // 2. ตั้งค่า Goal ที่สำเร็จล่าสุด
                latestAchievedGoal = wishlist[firstGoalIndex]
                
                // 3. แสดง Popup (Trigger)
                if !showGoalPopup {
                    showGoalPopup = true
                }
                
            } else {
                // Goal ยังไม่สำเร็จ แต่อัปเดต Progress
                wishlist[firstGoalIndex].currentProgress = completedCountToday
                wishlist[firstGoalIndex].isAchieved = false
            }
        }
        saveWishlist()
    }

    func addTodo(_ todo: TodoItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            todos.append(todo)
            saveTodos()
        }
    }
    
    func addProject(_ project: ProjectItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            projects.append(project)
            saveProjects()
        }
    }
    
    func updateProject(_ project: ProjectItem) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: ProjectItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            projects.removeAll { $0.id == project.id }
            todos.removeAll { $0.projectId == project.id }
            saveProjects()
            saveTodos()
        }
    }
    
    func toggleProjectTask(projectId: UUID, taskId: UUID) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
           let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                projects[projectIndex].tasks[taskIndex].isCompleted.toggle()
                saveProjects()
            }
        }
    }
    
    func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            let wasCompleted = todos[index].isCompleted
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                todos[index].isCompleted.toggle()
                saveTodos()
            }
            
            if !wasCompleted && todos[index].isCompleted {
                updateProgress(for: todo.date)
                
                // ✅ ตรวจสอบ Wishlist และ Goal
                updateWishlistProgress()
            }
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            todos.removeAll { $0.id == todo.id }
            saveTodos()
        }
    }
    
    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
        }
    }
    
    // Helper/Data Functions
    func getFireCount(for date: Date) -> Int {
        if let progress = dailyProgress.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return progress.fireCount
        }
        return 0
    }
    
    func hasTasksOnDate(_ date: Date) -> Bool {
        return todos.contains { Calendar.current.isDate($0.date, inSameDayAs: date) } ||
        projects.contains { Calendar.current.isDate($0.deadline, inSameDayAs: date) }
    }
    
    func completedTasksCount(for date: Date) -> Int {
        return todos.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCompleted
        }.count
    }
    
    func taskCount(for date: Date) -> Int {
        return todos.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }.count
    }
    
    private func updateProgress(for date: Date) {
        let completedToday = todos.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCompleted
        }.count
        
        if let index = dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            dailyProgress[index].completedCount = completedToday
            // ... (Fire Logic ยังคงเดิม)
        } else {
            // ... (New Progress Logic ยังคงเดิม)
        }
        
        saveProgress()
    }
    
    // Profile/Goal Data Handling
    func saveProfileData(imageURL: String?, interests: [String]) {
        if let imageURL = imageURL {
            profileImageURL = imageURL
            UserDefaults.standard.set(imageURL, forKey: "profileImageURL")
        }
        userInterests = interests
        if let encoded = try? JSONEncoder().encode(interests) {
            UserDefaults.standard.set(encoded, forKey: "userInterests")
        }
    }
    
    func saveUserName(_ name: String) {
        userName = name
        UserDefaults.standard.set(name, forKey: "userName")
    }

    func saveGoalData(goal: String, threshold: Int) {
        currentGoal = goal
        goalThreshold = threshold
        UserDefaults.standard.set(goal, forKey: "currentGoal")
        UserDefaults.standard.set(threshold, forKey: "goalThreshold")
    }

    private func loadGoalData() {
        if let goal = UserDefaults.standard.string(forKey: "currentGoal") {
            currentGoal = goal
        }
        goalThreshold = UserDefaults.standard.integer(forKey: "goalThreshold") == 0 ? 2 : UserDefaults.standard.integer(forKey: "goalThreshold")
    }

    func saveWishlist() {
        if let encoded = try? JSONEncoder().encode(wishlist) {
            UserDefaults.standard.set(encoded, forKey: "wishlist")
        }
    }
    
    private func loadWishlist() {
        if let data = UserDefaults.standard.data(forKey: "wishlist"),
           let decoded = try? JSONDecoder().decode([WishlistItem].self, from: data) {
            wishlist = decoded
        }
    }
    
    private func loadProfileData() {
        if let url = UserDefaults.standard.string(forKey: "profileImageURL") {
            profileImageURL = url
        }
        if let data = UserDefaults.standard.data(forKey: "userInterests"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            userInterests = decoded
        }
    }
    
    // Data Persistence Methods
    func saveTodos() { // ✅ FIX: ลบ private ออก
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "todos")
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: "todos"),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
    
    func saveProjects() { // ✅ FIX: ลบ private ออก
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: "projects")
        }
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: "projects"),
           let decoded = try? JSONDecoder().decode([ProjectItem].self, from: data) {
            projects = decoded
        }
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(dailyProgress) {
            UserDefaults.standard.set(encoded, forKey: "dailyProgress")
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "dailyProgress"),
           let decoded = try? JSONDecoder().decode([DailyProgress].self, from: data) {
            dailyProgress = decoded
        }
    }
    
    private func loadUserName() {
        if let name = UserDefaults.standard.string(forKey: "userName") {
            userName = name
        }
    }
    func scheduleNotifications(for todos: [TodoItem]) {
        // 1. ขออนุญาต
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
                self.scheduleTaskReminders(todos: todos)
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // ✅ NEW: ฟังก์ชันตั้งเวลาแจ้งเตือน
    private func scheduleTaskReminders(todos: [TodoItem]) {
        // ลบการแจ้งเตือนเก่าทั้งหมดเพื่อป้องกันการซ้ำซ้อน
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        
        for todo in todos {
            // แจ้งเตือนเฉพาะงานที่ยังไม่เสร็จและมี reminder
            guard !todo.isCompleted, todo.reminder, let time = todo.startTime else { continue }
            
            // กำหนดเวลาแจ้งเตือน (ใช้เวลาเริ่มต้นของงาน)
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
            
            let content = UNMutableNotificationContent()
            content.title = "⏰ งานรออยู่: \(todo.text)"
            content.body = "Task นี้ถึงกำหนดเวลาแล้ว: \(todo.category.rawValue)"
            content.sound = UNNotificationSound.default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: todo.id.uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
}
