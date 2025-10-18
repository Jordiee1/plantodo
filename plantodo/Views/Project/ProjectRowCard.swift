//
//  ProjectRowCard.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 17/10/2568 BE.
//


import SwiftUI

struct ProjectRowCard: View {
    @Environment(\.customBodyFont) var bodyFont
    let project: ProjectItem
    @ObservedObject var viewModel: TodoViewModel
    let onAddSubtask: () -> Void
    
    var projectProgress: (completed: Int, total: Int, percentage: Double) {
        viewModel.getProjectProgress(for: project.id)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Left: Icon and Title/Description
            VStack(alignment: .leading, spacing: 8) {
                // Title and Subtask Button
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(project.title)
                            .font(.headline.bold()).font(bodyFont)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Text(project.description ?? "No description")
                            .font(.subheadline).font(bodyFont)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Button + (Add Subtask)
                    Button(action: onAddSubtask) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(getProjectColor(from: project.color))
                            .clipShape(Circle())
                    }
                }
                
                // Team Members (ซ้ายล่าง)
                HStack(spacing: -5) {
                    ForEach(project.teamMembers.prefix(3), id: \.self) { _ in
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(getProjectColor(from: project.color))
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    if project.teamMembers.count > 3 {
                        Text("+\(project.teamMembers.count - 3)")
                            .font(.caption2).font(bodyFont)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 5)
                
                // Project Deadline/Time (แสดงเวลาหากมี)
                if let startTime = project.startTime, let endTime = project.endTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                    }
                    .font(.caption).font(bodyFont)
                    .foregroundColor(.gray)
                }
            }
            
            // Right: Progress Bar
            VStack(alignment: .trailing) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(projectProgress.percentage / 100))
                        .stroke(getProjectColor(from: project.color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 40, height: 40)
                    
                    Text("\(Int(projectProgress.percentage))%")
                        .font(.caption2.bold()).font(bodyFont)
                        .foregroundColor(getProjectColor(from: project.color))
                }
                
                Spacer()
                
                // Days Remaining
                Text("\(daysRemaining) days left")
                    .font(.caption2).font(bodyFont)
                    .foregroundColor(.red)
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // Helper Functions
    private func getProjectColor(from colorName: String) -> Color {
        switch colorName {
        case "blue": return Color.blue
        case "purple": return Color.purple
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "green": return Color.green
        case "red": return Color.red
        default: return Color.gray
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: project.deadline))
        return components.day ?? 0
    }
}
