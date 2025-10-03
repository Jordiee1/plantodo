//
//  TodoCard.swift
//  plantodo
//

import SwiftUI

struct TodoCard: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.text)  // ✅ ใช้ text
                    .font(.body)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                
                Text(todo.date, style: .date)  // ✅ ใช้ date
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// Preview
struct TodoCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            TodoCard(
                todo: TodoItem(text: "Sample Task", date: Date()),
                onToggle: {},
                onDelete: {}
            )
            
            TodoCard(
                todo: TodoItem(text: "Completed Task", isCompleted: true, date: Date()),
                onToggle: {},
                onDelete: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
