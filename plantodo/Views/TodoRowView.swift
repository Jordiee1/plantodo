//
//  TodoRowView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    @State private var isAppearing = false
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(spacing: 4) {
                Text(todo.category.icon)
                    .font(.system(size: 24))
                
                if let startTime = todo.startTime {
                    Text(timeString(from: startTime))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(todo.isCompleted ? .gray : .black)
                    .strikethrough(todo.isCompleted, color: .gray)
                
                HStack(spacing: 8) {
                    if let startTime = todo.startTime, let endTime = todo.endTime {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.gray)
                    }
                    
                    if todo.reminder {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(todo.isCompleted ? Color(red: 1.0, green: 0.42, blue: 0.62) : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .background(todo.isCompleted ? Color(red: 1.0, green: 0.42, blue: 0.62) : Color.clear)
                            .clipShape(Circle())
                        
                        if todo.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding(18)
        .background(todo.category.color.opacity(0.3))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .scaleEffect(isAppearing ? 1.0 : 0.8)
        .opacity(isAppearing ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAppearing = true
            }
        }
        .onTapGesture {
            onEdit()
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.string(from: date)
    }
}