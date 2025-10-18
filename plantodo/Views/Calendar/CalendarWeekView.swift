//
//  CalendarWeekView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct CalendarWeekView: View {
    @Environment(\.customBodyFont) var bodyFont
    @Binding var selectedDate: Date
    @State private var weekDates: [Date] = []
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ForEach(getMonthNames(), id: \.self) { month in
                    Text(month)
                        .font(.system(size: 14)).font(bodyFont)
                        .foregroundColor(.gray)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDates, id: \.self) { date in
                        DateCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            generateWeekDates()
        }
    }
    
    private func generateWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today) else { return }
        
        var dates: [Date] = []
        var currentDate = weekInterval.start
        
        while currentDate < weekInterval.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        weekDates = dates
    }
    
    private func getMonthNames() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        
        var months: Set<String> = []
        for date in weekDates {
            formatter.dateFormat = "MMMM"
            months.insert(formatter.string(from: date))
        }
        
        return Array(months)
    }
}

struct DateCell: View {
    @Environment(\.customBodyFont) var bodyFont
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text(dayName)
                .font(.system(size: 12)).font(bodyFont)
                .foregroundColor(isSelected ? .white : .gray)
            
            Text("\(day)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
        }
        .frame(width: 50, height: 70)
        .background(isSelected ? Color(red: 0.4, green: 0.4, blue: 1.0) : Color.white)
        .cornerRadius(15)
        .shadow(color: isSelected ? Color(red: 0.4, green: 0.4, blue: 1.0).opacity(0.4) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var day: Int {
        Calendar.current.component(.day, from: date)
    }
}
