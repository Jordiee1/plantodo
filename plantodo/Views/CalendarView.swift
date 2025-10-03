//
//  CalendarView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var currentMonth: Date = Date()
    @State private var showAddTodo = false
    @State private var selectedTodo: TodoItem?
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ✅ Header
                    CalendarHeader(
                        monthYearString: monthYearString,
                        daysOfWeek: daysOfWeek,
                        previousMonth: previousMonth,
                        nextMonth: nextMonth
                    )
                    
                    // ✅ Content
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTodo = nil
                        showAddTodo = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.appPrimary)
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

// MARK: - Header View
struct CalendarHeader: View {
    let monthYearString: String
    let daysOfWeek: [String]
    let previousMonth: () -> Void
    let nextMonth: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appPrimary)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.appPrimary)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
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

// MARK: - Calendar Content
struct CalendarContent: View {
    let calendar: Calendar
    let daysInMonth: [Date?]
    @ObservedObject var viewModel: TodoViewModel
    @Binding var selectedTodo: TodoItem?
    @Binding var showAddTodo: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    // ✅ ถูกต้องสำหรับ SwiftUI
//                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
//                        if let date = date {
//                            CalendarDayCell(
//                                date: date,
//                                isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
//                                isToday: calendar.isDateInToday(date),
//                                hasTask: viewModel.hasTasksOnDate(date),
//                                taskCount: viewModel.taskCount(for: date)
//                            ) {
//                                withAnimation {
//                                    viewModel.selectedDate = date
//                                }
//                            }
//                        } else {
//                            Color.clear
//                                .frame(height: 60)
//                        }
//                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Todo List
                if !viewModel.todosForSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("งานในวันที่เลือก")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        ForEach(viewModel.todosForSelectedDate) { todo in
                            TodoCard(
                                todo: todo,
                                onToggle: {
                                    viewModel.toggleTodo(todo)
                                },
                                onDelete: {
                                    viewModel.deleteTodo(todo)
                                }
                            )
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                selectedTodo = todo
                                showAddTodo = true
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTask: Bool
    let taskCount: Int
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : (isToday ? Color.appPrimary : .black))
                
                if hasTask {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(isSelected ? Color.white : Color.appPrimary)
                            .frame(width: 4, height: 4)
                        
                        if taskCount > 1 {
                            Text("\(taskCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(isSelected ? .white : Color.appPrimary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appPrimary : (isToday ? Color.appPrimary.opacity(0.1) : Color.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday && !isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Helpers
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
