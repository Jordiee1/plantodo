//
//  ProjectCardView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//


import SwiftUI

struct ProjectCardView: View {
    var onTap: () -> Void
    let project: ProjectItem
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(project.category.icon)
                            .font(.system(size: 24))
                        
                        Text(project.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    if let description = project.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 12) {
                        if let startTime = project.startTime, let endTime = project.endTime {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12))
                                Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.white.opacity(0.8))
                        }
                        
                        if let location = project.location, !location.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                Text(location)
                                    .font(.system(size: 12))
                                    .lineLimit(1)
                            }
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    if !project.teamMembers.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                            Text("\(project.teamMembers.count) คน")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(project.completionPercentage))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(project.completedTasksCount)/\(project.totalTasksCount)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * CGFloat(project.completionPercentage / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
        .background(getProjectColor(from: project.color))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .onTapGesture {
            onTap()
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.string(from: date)
    }
    
    private func getProjectColor(from colorName: String) -> Color {
        switch colorName {
        case "blue":
            return Color.blue
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "orange":
            return Color.orange
        case "green":
            return Color.green
        case "red":
            return Color.red
        default:
            return Color.blue
        }
    }
}
