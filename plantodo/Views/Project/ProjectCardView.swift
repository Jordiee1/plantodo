//
//  ProjectCardView.swift
//  plantodo
//
//  [Dashboard Scroll Card] - Final Stable Structure
//

import SwiftUI

struct ProjectCardView: View {
    let project: ProjectItem
    // ✅ ObservedObject สำหรับเข้าถึง ViewModel
    @ObservedObject var viewModel: TodoViewModel
    let onTap: () -> Void
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    // Computed Property สำหรับสีของการ์ด
    var cardColor: Color {
        return getProjectColor(from: project.color)
    }
    
    var body: some View {
        // ✅ Fix: ใช้ Explicit Type Annotation ใน Local Variable
        let progress: (completed: Int, total: Int, percentage: Double) = viewModel.getProjectProgress(for: project.id)
        let progressPercentage = Int(progress.percentage)
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .top) {
                // Icon / Category
                Text(project.category.icon)
                    .font(.system(size: 30))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(10)
                
                Spacer()
                
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 5)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progress.percentage / 100))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)
                    
                    Text("\(progressPercentage)%")
                        .font(.custom(boldFontName, size: 10))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Title & Description
            VStack(alignment: .leading) {
                Text(project.title)
                    .font(.custom(boldFontName, size: 18))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(project.description ?? "No details available.")
                    .font(.custom(regularFontName, size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                
                Text("\(progress.total) Tasks")
                    .font(.custom(regularFontName, size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .frame(width: 180, height: 200)
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: cardColor.opacity(0.5), radius: 8, x: 0, y: 4)
        .onTapGesture(perform: onTap)
    }
    
    // Helper function for color
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
}
