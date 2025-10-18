//
//  ProjectDetailView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//


import SwiftUI

struct ProjectDetailView: View {
    let project: ProjectItem
    @ObservedObject var viewModel: TodoViewModel
    let onEdit: () -> Void
    @Environment(\.dismiss) var dismiss
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    var projectProgress: (completed: Int, total: Int, percentage: Double) {
        viewModel.getProjectProgress(for: project.id)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Image Preview (ถ้ามี)
                        if let imageURL = project.imageURL, !imageURL.isEmpty {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(20)
                                .padding(.horizontal, 20)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }

                        projectInfoSection
                        
                        if let description = project.description, !description.isEmpty {
                            projectDescriptionSection
                        }
                        
                        projectMetaSection
                        
                        if projectProgress.total > 0 {
                            projectTaskSection
                        }
                        
                        actionButtons
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("รายละเอียดโปรเจกต์")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("ปิด") {
                        dismiss()
                    }
                }
            }
            .font(.custom(regularFontName, size: 16)) // กำหนด Font พื้นฐาน
        }
    }
    
    // MARK: - 1. Project Info and Progress Section
    private var projectInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(project.category.icon)
                    .font(.system(size: 50))
                    .padding()
                    .background(getProjectColor(from: project.color).opacity(0.3))
                    .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.title)
                        .font(.custom(boldFontName, size: 24)) // ✅ Custom Font
                        .foregroundColor(.black)
                    
                    Text(project.category.rawValue)
                        .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("ความคืบหน้า")
                        .font(.custom(boldFontName, size: 16)) // ✅ Custom Font
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(Int(projectProgress.percentage))%")
                        .font(.custom(boldFontName, size: 24)) // ✅ Custom Font
                        .foregroundColor(getProjectColor(from: project.color))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(getProjectColor(from: project.color))
                            .frame(width: geometry.size.width * CGFloat(projectProgress.percentage / 100), height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("\(projectProgress.completed) จาก \(projectProgress.total) งาน")
                        .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color.secondaryBackground) // ✅ สี Card
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - 2. Description Section
    private var projectDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16))
                    .foregroundColor(getProjectColor(from: project.color))
                    .frame(width: 30)
                
                Text("รายละเอียด")
                    .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                    .foregroundColor(.gray)
            }
            
            Text(project.description ?? "")
                .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                .foregroundColor(.black)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.secondaryBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 3. Metadata Section (Date, Time, Location, Team)
    private var projectMetaSection: some View {
        VStack(spacing: 12) {
            // Deadline
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(getProjectColor(from: project.color))
                        .frame(width: 30)
                    
                    Text("วันที่")
                        .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                        .foregroundColor(.gray)
                }
                Text(dateString(from: project.deadline))
                    .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.secondaryBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            
            // Time
            if let startTime = project.startTime, let endTime = project.endTime {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 16))
                            .foregroundColor(getProjectColor(from: project.color))
                            .frame(width: 30)
                        
                        Text("เวลา")
                            .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                            .foregroundColor(.gray)
                    }
                    Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                        .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.secondaryBackground)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            
            // Location
            if let location = project.location, !location.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(getProjectColor(from: project.color))
                            .frame(width: 30)
                        
                        Text("สถานที่")
                            .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                            .foregroundColor(.gray)
                    }
                    Text(location)
                        .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.secondaryBackground)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            
            // Team Members Section (แสดงผล)
            if !project.teamMembers.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(getProjectColor(from: project.color))
                            .frame(width: 30)
                        
                        Text("ทีมงาน (\(project.teamMembers.count) คน)")
                            .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(project.teamMembers, id: \.self) { member in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(getProjectColor(from: project.color))
                                
                                Text(member)
                                    .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.primaryBackground) // ✅ สีพื้นหลังหลัก
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(20)
                .background(Color.secondaryBackground)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - 4. Project Tasks Section (แสดง TodoItem)
    private var projectTaskSection: some View {
        let projectTodos = viewModel.getProjectTodos(for: project.id)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 16))
                    .foregroundColor(getProjectColor(from: project.color))
                    .frame(width: 30)
                
                Text("รายการงาน (\(projectProgress.completed)/\(projectProgress.total))")
                    .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(projectTodos) { todo in
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.toggleTodo(todo)
                        }) {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24))
                                .foregroundColor(todo.isCompleted ? .green : .gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(todo.text)
                                .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                                .foregroundColor(.black)
                                .strikethrough(todo.isCompleted)
                            
                            if let notes = todo.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.custom(regularFontName, size: 12)) // ✅ Custom Font
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.primaryBackground) // ✅ สีพื้นหลังหลัก
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color.secondaryBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                dismiss()
                onEdit()
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                    
                    Text("แก้ไข")
                        .font(.custom(boldFontName, size: 16)) // ✅ Custom Font
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
            }
            
            Button(action: {
                viewModel.deleteProject(project)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    
                    Text("ลบโปรเจกต์")
                        .font(.custom(boldFontName, size: 16)) // ✅ Custom Font
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentRed) // ✅ Accent Red
                .cornerRadius(15)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.string(from: date)
    }
    
    private func getProjectColor(from colorName: String) -> Color {
        switch colorName {
        case "blue": return Color.blue
        case "purple": return Color.purple
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "green": return Color.green
        case "red": return Color.red
        default: return Color.blue
        }
    }
}
