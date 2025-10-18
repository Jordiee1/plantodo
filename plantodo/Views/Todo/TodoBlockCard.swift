//
//  TodoBlockCard.swift
//  plantodo
//
//  Component สำหรับแสดงรายการงานแบบ Block Card
//

import SwiftUI

struct TodoBlockCard: View {
    let todo: TodoItem // รับ TodoItem
    let onToggle: () -> Void
    let onOpenDetail: () -> Void
    
    // Computed Property สำหรับกำหนดสีของการ์ด
    var cardColor: Color {
        // ✅ Fix: ใช้ opacity ที่เดียวเพื่อความเสถียร
        return todo.category.color
            .opacity(0.9)
    }
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .top) {
                // 1. อีโมจิซ้ายบน (ตามหมวดหมู่)
                Text(todo.category.icon)
                    .font(.system(size: 28))
                    .frame(width: 45, height: 45)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(10)
                    .padding(4)
                
                Spacer()
                
                // 2. ปุ่ม Toggle สถานะ (แทนไอคอนสถานะเดิม)
                // ✅ Fix: ใช้ PlainButtonStyle เพื่อป้องกันการเปลี่ยนสีพื้นหลังเมื่อกด
                Button(action: onToggle) {
                    ZStack {
                        // Background (เพื่อให้มีพื้นที่กดชัดเจน)
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 32, height: 32)
                        
                        // Icon (Checkmark or Empty)
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            // ✅ FIX: ใช้สีขาวเมื่อเสร็จแล้ว
                            .foregroundColor(todo.isCompleted ? Color.white : Color.white.opacity(0.9))
                        
                        // Icon ที่ซ้อนทับ (ใช้สำหรับ Checkmark ที่ชัดเจน)
                        if todo.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(cardColor) // ใช้สีของการ์ดเป็นสี Checkmark ภายในวงกลมขาว
                                .background(Circle().fill(Color.white))
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle()) // ✅ FIX: ป้องกันการเปลี่ยนสีพื้นหลังเมื่อกด
            }
            
            Spacer()
            
            // Title & Description
            VStack(alignment: .leading) {
                // ✅ FIX: เปลี่ยน project.title เป็น todo.text
                Text(todo.text)
                    .font(.custom(boldFontName, size: 18))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .strikethrough(todo.isCompleted)
                
                // รายละเอียดอื่นๆ (เวลา)
                if let startTime = todo.startTime {
                    Text("Time: \(timeString(from: startTime))")
                        .font(.custom(regularFontName, size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(15)
        .frame(height: 150)
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: cardColor.opacity(0.5), radius: 8, x: 0, y: 4)
        .onTapGesture(perform: onOpenDetail)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
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
        default: return Color.gray
        }
    }
}
