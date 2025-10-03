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
    
    init() {
        let calendar = Calendar.current
        self.selectedDate = calendar.startOfDay(for: Date())
        
        loadTodos()
        loadProjects()
        loadProgress()
        loadUserName()
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
        return projects.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
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
            saveProjects()
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
    
    func getFireCount(for date: Date) -> Int {
        if let progress = dailyProgress.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return progress.fireCount
        }
        return 0
    }
    
    func hasTasksOnDate(_ date: Date) -> Bool {
        return todos.contains { Calendar.current.isDate($0.date, inSameDayAs: date) } ||
               projects.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func completedTasksCount(for date: Date) -> Int {
        return todos.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCompleted
        }.count
    }
    
    private func updateProgress(for date: Date) {
        let completedToday = todos.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCompleted
        }.count
        
        if let index = dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            dailyProgress[index].completedCount = completedToday
            
            if completedToday > 0 && completedToday % 3 == 0 {
                let newFireCount = completedToday / 3
                if dailyProgress[index].fireCount < newFireCount {
                    dailyProgress[index].fireCount = newFireCount
                    showFireAnimation = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showFireAnimation = false
                    }
                }
            }
        } else {
            var newProgress = DailyProgress(date: date, completedCount: completedToday)
            if completedToday >= 3 {
                newProgress.fireCount = completedToday / 3
                showFireAnimation = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showFireAnimation = false
                }
            }
            dailyProgress.append(newProgress)
        }
        
        saveProgress()
    }
    
    func saveUserName(_ name: String) {
        userName = name
        UserDefaults.standard.set(name, forKey: "userName")
    }
    
    private func saveTodos() {
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
    
    private func saveProjects() {
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
}
