import Foundation

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var category: Category = .general
    var reminder: Bool
    var location: String?
    var relatedPeople: [String]
    var notes: String?
    
    init(id: UUID = UUID(), text: String, isCompleted: Bool = false, date: Date = Date(), startTime: Date? = nil, endTime: Date? = nil, category: Category = .general, reminder: Bool = false, location: String? = nil, relatedPeople: [String] = [], notes: String? = nil) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.reminder = reminder
        self.location = location
        self.relatedPeople = relatedPeople
        self.notes = notes
    }
    
}
