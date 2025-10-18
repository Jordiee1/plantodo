//
//  AddTodoSheet.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//

import SwiftUI

struct AddTodoSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    // ✅ กำหนดชื่อฟอนต์ที่ใช้ (ต้องตรงกับชื่อ PostScript Name ใน Info.plist)
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    @State private var todoText: String = ""
    @State private var selectedCategory: Category = .general
    @State private var selectedDate: Date = Date()
    @State private var hasTime: Bool = false
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var hasReminder: Bool = false
    
    @State private var selectedProjectId: UUID? = nil
    
    var editingTodo: TodoItem?
    var initialProjectId: UUID?
    
    init(viewModel: TodoViewModel, editingTodo: TodoItem? = nil, initialProjectId: UUID? = nil) {
        self.viewModel = viewModel
        self.editingTodo = editingTodo
        self.initialProjectId = initialProjectId
        
        if let todo = editingTodo {
            _todoText = State(initialValue: todo.text)
            _selectedCategory = State(initialValue: todo.category)
            _selectedDate = State(initialValue: todo.date)
            _hasTime = State(initialValue: todo.startTime != nil)
            _startTime = State(initialValue: todo.startTime ?? Date())
            _endTime = State(initialValue: todo.endTime ?? Date())
            _hasReminder = State(initialValue: todo.reminder)
        }
        
        _selectedProjectId = State(initialValue: editingTodo?.projectId ?? initialProjectId)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // รายละเอียด
                        VStack(alignment: .leading, spacing: 8) {
                            Text("รายละเอียด")
                                .font(.custom(boldFontName, size: 14))
                                .foregroundColor(.gray)
                            
                            TextField("สิ่งที่ต้องทำ...", text: $todoText)
                                .font(.custom(regularFontName, size: 16))
                                .padding()
                                .background(Color.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        projectSelectionSection
                        
                        // หมวดหมู่
                        VStack(alignment: .leading, spacing: 8) {
                            Text("หมวดหมู่")
                                .font(.custom(boldFontName, size: 14))
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Category.allCases, id: \.self) { category in
                                        // ✅ เรียก CategoryButton จาก Shared Components
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            action: { selectedCategory = category },
                                            boldFontName: boldFontName
                                        )
                                    }
                                }
                            }
                        }
                        
                        // วันที่
                        dateSection
                        
                        // Time Section
                        timeSection
                        
                        // แจ้งเตือนและปุ่มบันทึก
                        VStack {
                            Toggle(isOn: $hasReminder) {
                                HStack {
                                    Image(systemName: "bell").foregroundColor(.accentColor)
                                    Text("แจ้งเตือน")
                                        .font(.custom(regularFontName, size: 16))
                                }
                            }
                            .padding()
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                        }
                        
                        Button(action: saveTodo) {
                            Text(editingTodo == nil ? "เพิ่มรายการ" : "บันทึกการแก้ไข")
                                .font(.custom(boldFontName, size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding()
                                .background(todoText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.accentColor)
                                .cornerRadius(15).shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        }.disabled(todoText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(editingTodo == nil ? "เพิ่มรายการใหม่" : "แก้ไขรายการ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") { dismiss() }
                }
            }
            .font(.custom(regularFontName, size: 16))
        }
    }

    // MARK: - Date Picker Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("วันที่")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            
            Group {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            .font(.custom(regularFontName, size: 16))
            .padding()
            .background(Color.secondaryBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Time Section (แยกออกมาเพื่อลดความซับซ้อน)
    private var timeSection: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $hasTime) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.accentColor)
                    Text("กำหนดเวลา")
                        .font(.custom(regularFontName, size: 16))
                }
            }.padding().background(Color.secondaryBackground).cornerRadius(12)
            
            if hasTime {
                VStack(spacing: 12) {
                    Group {
                        HStack {
                            Text("เริ่ม")
                                .frame(width: 60, alignment: .leading)
                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden()
                        }
                        .padding().background(Color.secondaryBackground).cornerRadius(12)
                    }
                    .font(.custom(regularFontName, size: 16))
                    
                    Group {
                        HStack {
                            Text("สิ้นสุด")
                                .frame(width: 60, alignment: .leading)
                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden()
                        }
                        .padding().background(Color.secondaryBackground).cornerRadius(12)
                    }
                    .font(.custom(regularFontName, size: 16))
                }
            }
        }
    }
    
    // MARK: - Project Selection Section
    private var projectSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("เชื่อมโยงโปรเจกต์ (ไม่บังคับ)")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "folder")
                    .foregroundColor(.accentColor)

                Picker("เลือกโปรเจกต์", selection: $selectedProjectId) {
                    Text("ไม่มีโปรเจกต์")
                        .tag(nil as UUID?)
                        .font(.custom(regularFontName, size: 16))

                    ForEach(viewModel.projects, id: \.id) { project in
                        HStack {
                            Circle()
                                .fill(getColor(from: project.color))
                                .frame(width: 10, height: 10)
                            Text(project.title)
                                .font(.custom(regularFontName, size: 16))
                        }
                        .tag(project.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(Color.secondaryBackground)
                .cornerRadius(12)
            }
            .padding(.horizontal, 10)
            .background(Color.secondaryBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }

    // MARK: - saveTodo Function
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
            reminder: hasReminder,
            location: editingTodo?.location,
            relatedPeople: editingTodo?.relatedPeople ?? [],
            notes: editingTodo?.notes,
            projectId: selectedProjectId
        )
        
        if editingTodo != nil {
            viewModel.updateTodo(todo)
        } else {
            viewModel.addTodo(todo)
        }
        
        dismiss()
    }
    
    // NOTE: getColor function ถูกใช้ใน Project Selection Section
    private func getColor(from colorName: String) -> Color {
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
