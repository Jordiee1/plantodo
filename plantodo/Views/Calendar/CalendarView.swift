//
//  CalendarView.swift
//  plantodo
//
// โค้ดปฏิทินรายเดือนฉบับเดิม (แก้ไข Error และใช้ ViewModel ที่ถูกต้อง)
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var currentMonth: Date = Date()
    @State private var showAddTodo = false
    @State private var selectedTodo: TodoItem?
    @Environment(\.dismiss) var dismiss // เพิ่ม dismiss เพื่อปิด sheet
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header (ย้าย logic การเปลี่ยนเดือนมาไว้ใน extension)
                    CalendarHeader(
                        monthYearString: monthYearString,
                        daysOfWeek: daysOfWeek,
                        previousMonth: previousMonth,
                        nextMonth: nextMonth
                    )
                    
                    // Content (ใช้ Calendar Grid เดิม)
                    CalendarContent(
                        calendar: calendar,
                        daysInMonth: daysInMonth,
                        viewModel: viewModel,
                        selectedTodo: $selectedTodo,
                        showAddTodo: $showAddTodo
                    )
                }
            }
            .navigationTitle("ปฏิทิน")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ปิด") { dismiss() } // ปุ่มปิด
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTodo = nil
                        showAddTodo = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                    }
                }
            }
            .sheet(isPresented: $showAddTodo) {
                AddTodoSheet(viewModel: viewModel, editingTodo: selectedTodo)
                    .onDisappear {
                        selectedTodo = nil
                    }
            }
        }
    }
}

// MARK: - Header View (ใช้โค้ดเดิม)
struct CalendarHeader: View {
    @Environment(\.customBodyFont) var bodyFont
    let monthYearString: String
    let daysOfWeek: [String]
    let previousMonth: () -> Void
    let nextMonth: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) { /* ... */ }
                Spacer()
                Text(monthYearString).font(.system(size: 20, weight: .bold)).foregroundColor(.black).font(bodyFont)
                Spacer()
                Button(action: nextMonth) { /* ... */ }
            }
            // ... (โค้ด styling)
            .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(bodyFont)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Calendar Content (Uncommented and fixed)
struct CalendarContent: View {
    @Environment(\.customBodyFont) var bodyFont
    let calendar: Calendar
    let daysInMonth: [Date?]
    @ObservedObject var viewModel: TodoViewModel
    @Binding var selectedTodo: TodoItem?
    @Binding var showAddTodo: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Calendar Grid - แก้ไขโดย Uncomment โค้ดเดิม
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                        if let date = date {
                            CalendarDayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                                isToday: calendar.isDateInToday(date),
                                hasTask: viewModel.hasTasksOnDate(date),
                                taskCount: viewModel.taskCount(for: date) // ต้องมีฟังก์ชันนี้ใน ViewModel
                            ) {
                                withAnimation {
                                    viewModel.selectedDate = date
                                }
                            }
                        } else {
                            Color.clear
                                .frame(height: 60)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Todo List for Selected Date (ใช้ TodoCard แทน TodoRowView)
                if !viewModel.todosForSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("งานในวันที่เลือก")
                            .font(bodyFont)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        ForEach(viewModel.todosForSelectedDate) { todo in
                            // NOTE: ใช้ TodoRowView ที่คุณมีอยู่แทน TodoCard
                            TodoRowView(
                                todo: todo,
                                onToggle: { viewModel.toggleTodo(todo) },
                                onDelete: { viewModel.deleteTodo(todo) },
                                onEdit: {
                                    selectedTodo = todo
                                    showAddTodo = true
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Calendar Day Cell (ใช้โค้ดเดิม)
struct CalendarDayCell: View {
    @Environment(\.customBodyFont) var bodyFont
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTask: Bool
    let taskCount: Int
    let action: () -> Void
    // ... (โค้ด dayNumber, body, และ day ใช้งานได้ตามเดิม)
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium)).font(bodyFont)
                    .foregroundColor(isSelected ? .white : (isToday ? Color(red: 1.0, green: 0.42, blue: 0.62) : .black))
                
                if hasTask {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(isSelected ? Color.white : Color(red: 1.0, green: 0.42, blue: 0.62))
                            .frame(width: 4, height: 4)
                        
                        if taskCount > 1 {
                            Text("\(taskCount)")
                                .font(.system(size: 10, weight: .bold)).font(bodyFont)
                                .foregroundColor(isSelected ? .white : Color(red: 1.0, green: 0.42, blue: 0.62))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 1.0, green: 0.42, blue: 0.62) : (isToday ? Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.1) : Color.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday && !isSelected ? Color(red: 1.0, green: 0.42, blue: 0.62) : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Helpers (ใช้โค้ดเดิม)
extension CalendarView {
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        return generateDays(from: firstWeek.start)
    }
    
    private func generateDays(from startDate: Date) -> [Date?] {
        var days: [Date?] = []
        var currentDate = startDate
        
        for _ in 0..<42 {
            let isInMonth = calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month)
            days.append(isInMonth ? currentDate : nil)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}
