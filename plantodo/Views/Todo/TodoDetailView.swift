//
//  TodoDetailView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct TodoDetailView: View {
    @Environment(\.customBodyFont) var bodyFont
    let todo: TodoItem
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
                        HStack {
                            Text(todo.category.icon)
                                .font(.system(size: 50)).font(bodyFont)
                                .padding()
                                .background(todo.category.color.opacity(0.3))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(todo.text)
                                    .font(.system(size: 24, weight: .bold)).font(bodyFont)
                                    .foregroundColor(.black)
                                
                                Text(todo.category.rawValue)
                                    .font(.system(size: 14)).font(bodyFont)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        VStack(spacing: 15) {
                            DetailRow(icon: "calendar", title: "วันที่", content: dateString(from: todo.date))
                            
                            if let startTime = todo.startTime, let endTime = todo.endTime {
                                DetailRow(icon: "clock", title: "เวลา", content: "\(timeString(from: startTime)) - \(timeString(from: endTime))")
                            }
                            
                            if let location = todo.location, !location.isEmpty {
                                DetailRow(icon: "location.fill", title: "สถานที่", content: location)
                            }
                            
                            if !todo.relatedPeople.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                            .frame(width: 30)
                                        
                                        Text("บุคคลที่เกี่ยวข้อง")
                                            .font(.system(size: 14, weight: .semibold)).font(bodyFont)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(todo.relatedPeople, id: \.self) { person in
                                            HStack {
                                                Text("👤")
                                                    .font(.system(size: 16)).font(bodyFont)
                                                
                                                Text(person)
                                                    .font(.system(size: 16)).font(bodyFont)
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
                            
                            if let notes = todo.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "note.text")
                                            .font(.system(size: 16)).font(bodyFont)
                                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                            .frame(width: 30)
                                        
                                        Text("หมายเหตุ")
                                            .font(.system(size: 14, weight: .semibold)).font(bodyFont)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(notes)
                                        .font(.system(size: 16)).font(bodyFont)
                                        .foregroundColor(.black)
                                        .padding(.top, 4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }
                            
                            if todo.reminder {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                    
                                    Text("เปิดการแจ้งเตือน")
                                        .font(.system(size: 16)).font(bodyFont)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.toggleTodo(todo)
                            }) {
                                HStack {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                    
                                    Text(todo.isCompleted ? "เสร็จแล้ว" : "ทำเครื่องหมายเสร็จ")
                                        .font(.system(size: 16, weight: .semibold)).font(bodyFont)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(todo.isCompleted ? Color.green : Color(red: 1.0, green: 0.42, blue: 0.62))
                                .cornerRadius(15)
                            }
                            
                            Button(action: {
                                dismiss()
                                onEdit()
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 20))
                                    
                                    Text("แก้ไข")
                                        .font(.system(size: 16, weight: .semibold)).font(bodyFont)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                            }
                        }
                        
                        Button(action: {
                            viewModel.deleteTodo(todo)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                
                                Text("ลบรายการ")
                                    .font(.system(size: 16, weight: .semibold)).font(bodyFont)
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
            .navigationTitle("รายละเอียด")
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
}

struct DetailRow: View {
    @Environment(\.customBodyFont) var bodyFont
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                    .font(bodyFont)
                
                Text(content)
                    .font(.system(size: 16)).font(bodyFont)
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
