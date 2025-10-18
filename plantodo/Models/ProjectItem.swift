//
//  ProjectItem.swift
//  plantodo
//
//  Created for Team Project Feature
//

import Foundation

struct ProjectItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var deadline: Date
    var startTime: Date?
    var endTime: Date?
    var location: String?
    var teamMembers: [String]
    var tasks: [ProjectTask]
    var category: Category
    var color: String
    var imageURL: String? // ✅ เพิ่ม Image URL
    
    init(id: UUID = UUID(), title: String, description: String? = nil, deadline: Date = Date(), startTime: Date? = nil, endTime: Date? = nil, location: String? = nil, teamMembers: [String] = [], tasks: [ProjectTask] = [], category: Category = .work, color: String = "blue", imageURL: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.deadline = deadline
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.teamMembers = teamMembers
        self.tasks = tasks
        self.category = category
        self.color = color
        self.imageURL = imageURL // ✅ กำหนดค่า Image URL
    }
    
    var completionPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedTasks = tasks.filter { $0.isCompleted }.count
        return Double(completedTasks) / Double(tasks.count) * 100
    }
    
    var completedTasksCount: Int {
        return tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        return tasks.count
    }
}

// ProjectTask ไม่มีการเปลี่ยนแปลง
struct ProjectTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var assignedTo: String?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, assignedTo: String? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.assignedTo = assignedTo
    }
}
