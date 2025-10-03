//
//  ProjectDetailView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//


import SwiftUI

struct ProjectDetailView: View {
    let project: ProjectItem
    @ObservedObject var viewModel: TodoViewModel
    let onEdit: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(project.category.icon)
                                    .font(.system(size: 50))
                                    .padding()
                                    .background(getProjectColor(from: project.color).opacity(0.3))
                                    .cornerRadius(20)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(project.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text(project.category.rawValue)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("ความคืบหน้า")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(project.completionPercentage))%")
                                        .font(.system(size: 24, weight: .bold))
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
                                            .frame(width: geometry.size.width * CGFloat(project.completionPercentage / 100), height: 12)
                                            .cornerRadius(6)
                                    }
                                }
                                .frame(height: 12)
                                
                                HStack {
                                    Text("\(project.completedTasksCount) จาก \(project.totalTasksCount) งาน")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        if let description = project.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(getProjectColor(from: project.color))
                                        .frame(width: 30)
                                    
                                    Text("รายละเอียด")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                Text(description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 16))
                                    .foregroundColor(getProjectColor(from: project.color))
                                    .frame(width: 30)
                                
                                Text("วันที่")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            
                            Text(dateString(from: project.date))
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        if let startTime = project.startTime, let endTime = project.endTime {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 16))
                                        .foregroundColor(getProjectColor(from: project.color))
                                        .frame(width: 30)
                                    
                                    Text("เวลา")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        if let location = project.location, !location.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(getProjectColor(from: project.color))
                                        .frame(width: 30)
                                    
                                    Text("สถานที่")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                Text(location)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        if !project.teamMembers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(getProjectColor(from: project.color))
                                        .frame(width: 30)
                                    
                                    Text("ทีมงาน (\(project.teamMembers.count) คน)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(project.teamMembers, id: \.self) { member in
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(getProjectColor(from: project.color))
                                            
                                            Text(member)
                                                .font(.system(size: 16))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color(red: 1.0, green: 0.96, blue: 0.97))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        if !project.tasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "list.bullet.clipboard.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(getProjectColor(from: project.color))
                                        .frame(width: 30)
                                    
                                    Text("รายการงาน (\(project.completedTasksCount)/\(project.totalTasksCount))")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(project.tasks) { task in
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                viewModel.toggleProjectTask(projectId: project.id, taskId: task.id)
                                            }) {
                                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(task.title)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.black)
                                                    .strikethrough(task.isCompleted)
                                                
                                                if let assignedTo = task.assignedTo, !assignedTo.isEmpty {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "person.fill")
                                                            .font(.system(size: 10))
                                                        Text(assignedTo)
                                                            .font(.system(size: 12))
                                                    }
                                                    .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(red: 1.0, green: 0.96, blue: 0.97))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                dismiss()
                                onEdit()
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 20))
                                    
                                    Text("แก้ไข")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                            }
                        }
                        
                        Button(action: {
                            viewModel.deleteProject(project)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                
                                Text("ลบโปรเจกต์")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(15)
                        }
                    }
                    .padding(20)
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
        }
    }
    
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
