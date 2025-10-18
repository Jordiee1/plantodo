//
//  MonthCalendarView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct MonthCalendarView: View {
    @Environment(\.customBodyFont) var bodyFont
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var selectedMonth = Date()
    @State private var selectedDateForDetail: Date?
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text(monthYearString)
                                .font(.system(size: 22, weight: .bold)).font(bodyFont)
                                .foregroundColor(.black)
                            
                            Text("\(getTodoCountForMonth()) รายการในเดือนนี้")
                                .font(.system(size: 12)).font(bodyFont)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14, weight: .semibold)).font(bodyFont)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            ForEach(getDaysInMonth(), id: \.self) { date in
                                if let date = date {
                                    DayCell(
                                        date: date,
                                        isCurrentMonth: calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month),
                                        isToday: calendar.isDateInToday(date),
                                        hasTasks: viewModel.hasTasksOnDate(date),
                                        completedCount: viewModel.completedTasksCount(for: date)
                                    )
                                    .onTapGesture {
                                        selectedDateForDetail = date
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 60)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("ปฏิทินภาพรวม")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: Binding(
                get: { selectedDateForDetail.map { DateWrapper(date: $0) } },
                set: { selectedDateForDetail = $0?.date }
            )) { dateWrapper in
                DayDetailSheet(date: dateWrapper.date, viewModel: viewModel)
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation {
                selectedMonth = newMonth
            }
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while days.count < 42 {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    private func getTodoCountForMonth() -> Int {
        return viewModel.todos.filter { todo in
            calendar.isDate(todo.date, equalTo: selectedMonth, toGranularity: .month)
        }.count
    }
}

struct DayCell: View {
    @Environment(\.customBodyFont) var bodyFont
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let hasTasks: Bool
    let completedCount: Int
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular)).font(bodyFont)
                .foregroundColor(isCurrentMonth ? (isToday ? .white : .black) : .gray)
            
            if hasTasks {
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.62))
                        .frame(width: 6, height: 6)
                    
                    if completedCount > 0 {
                        Text("\(completedCount)")
                            .font(.system(size: 8, weight: .bold)).font(bodyFont)
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                    }
                }
            }
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(isToday ? Color(red: 1.0, green: 0.42, blue: 0.62) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(isToday ? 0.15 : 0.05), radius: isToday ? 6 : 3, x: 0, y: 2)
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }
}

struct DateWrapper: Identifiable {
    let id = UUID()
    let date: Date
}

struct DayDetailSheet: View {
    @Environment(\.customBodyFont) var bodyFont
    let date: Date
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss
    
    private var todosForDate: [TodoItem] {
        viewModel.todos.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { item1, item2 in
                if let time1 = item1.startTime, let time2 = item2.startTime {
                    return time1 < time2
                }
                return false
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                if todosForDate.isEmpty {
                    VStack(spacing: 15) {
                        Text("📅")
                            .font(.system(size: 60)).font(bodyFont)
                        Text("ไม่มีรายการในวันนี้")
                            .font(.system(size: 18, weight: .semibold)).font(bodyFont)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(todosForDate) { todo in
                                TodoRowView(
                                    todo: todo,
                                    onToggle: {
                                        viewModel.toggleTodo(todo)
                                    },
                                    onDelete: {
                                        viewModel.deleteTodo(todo)
                                    },
                                    onEdit: {
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle(dateString)
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
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
