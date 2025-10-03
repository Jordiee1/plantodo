//
//  AddTodoSheet.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct AddTodoSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    @State private var todoText: String = ""
    @State private var selectedCategory: Category = .general
    @State private var selectedDate: Date = Date()
    @State private var hasTime: Bool = false
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var hasReminder: Bool = false
    
    var editingTodo: TodoItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("รายละเอียด")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("สิ่งที่ต้องทำ...", text: $todoText)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("หมวดหมู่")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Category.allCases, id: \.self) { category in
                                        CategoryButton(category: category, isSelected: selectedCategory == category) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("วันที่")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        VStack(spacing: 12) {
                            Toggle(isOn: $hasTime) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                    Text("กำหนดเวลา")
                                        .font(.system(size: 16))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            if hasTime {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("เริ่ม")
                                            .frame(width: 60, alignment: .leading)
                                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
                                    HStack {
                                        Text("สิ้นสุด")
                                            .frame(width: 60, alignment: .leading)
                                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Toggle(isOn: $hasReminder) {
                            HStack {
                                Image(systemName: "bell")
                                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                Text("แจ้งเตือน")
                                    .font(.system(size: 16))
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        Button(action: saveTodo) {
                            Text(editingTodo == nil ? "เพิ่มรายการ" : "บันทึกการแก้ไข")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    todoText.trimmingCharacters(in: .whitespaces).isEmpty ?
                                    Color.gray : Color(red: 1.0, green: 0.42, blue: 0.62)
                                )
                                .cornerRadius(15)
                                .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(todoText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(editingTodo == nil ? "เพิ่มรายการใหม่" : "แก้ไขรายการ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let todo = editingTodo {
                todoText = todo.text
                selectedCategory = todo.category
                selectedDate = todo.date
                hasTime = todo.startTime != nil
                startTime = todo.startTime ?? Date()
                endTime = todo.endTime ?? Date()
                hasReminder = todo.reminder
            }
        }
    }
    
    private func saveTodo() {
        let trimmedText = todoText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        
        let todo = TodoItem(
            id: editingTodo?.id ?? UUID(),
            text: trimmedText,
            isCompleted: editingTodo?.isCompleted ?? false,
            date: selectedDate,
            startTime: hasTime ? startTime : nil,
            endTime: hasTime ? endTime : nil,
            category: selectedCategory,
            reminder: hasReminder
        )
        
        if editingTodo != nil {
            viewModel.updateTodo(todo)
        } else {
            viewModel.addTodo(todo)
        }
        
        dismiss()
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(category.icon)
                    .font(.system(size: 28))
                
                Text(category.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color(red: 1.0, green: 0.42, blue: 0.62) : category.color)
            .cornerRadius(15)
            .shadow(color: isSelected ? Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
    }
}
