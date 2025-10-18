//
//  MockData.swift
//  plantodo
//
//  Created by Gemini
//
import SwiftUI
import Foundation

class MockData {
    
    static func generateMockTodos() -> [TodoItem] {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrowMorning = Calendar.current.date(byAdding: .hour, value: 9, to: tomorrow)!
        let todayAfternoon = Calendar.current.date(byAdding: .hour, value: 14, to: today)!
        
        // สร้าง UUID จำลองสำหรับ Project (ใช้ในการทดสอบการเชื่อมโยง)
        let workProjectId = UUID()
        let personalProjectId = UUID()

        return [
            // 1. งานที่เสร็จแล้ว (เมื่อวาน)
            TodoItem(
                text: "ซื้อเมล็ดพันธุ์สำหรับปลูก",
                isCompleted: true,
                date: yesterday,
                category: .shopping
            ),
            
            // 2. งานที่ต้องทำวันนี้ (มีเวลา)
            TodoItem(
                text: "ประชุมทีมวางแผนการตลาด",
                isCompleted: false,
                date: today,
                startTime: todayAfternoon,
                category: .work,
                reminder: true,
                projectId: workProjectId // เชื่อมโยงกับ Project จำลอง
            ),
            
            // 3. งานที่ต้องทำวันนี้ (ไม่มีเวลา)
            TodoItem(
                text: "ออกกำลังกาย 30 นาที",
                isCompleted: false,
                date: today,
                category: .health
            ),
            
            // 4. งานที่ต้องทำพรุ่งนี้ (Project Task)
            TodoItem(
                text: "เขียนบทสรุปรายงานประจำเดือน",
                isCompleted: false,
                date: tomorrow,
                startTime: tomorrowMorning,
                category: .study,
                projectId: workProjectId
            ),

            // 5. งานส่วนตัว (Project Task)
            TodoItem(
                text: "ทำความสะอาดบ้าน",
                isCompleted: false,
                date: today,
                category: .personal,
                projectId: personalProjectId
            )
        ]
    }
    
    static func generateMockProjects() -> [ProjectItem] {
        let today = Date()
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: today)!
        
        let workProjectId = UUID(uuidString: generateMockTodos()[1].projectId!.uuidString)! // ดึง ID จาก TodoItem
        let personalProjectId = UUID(uuidString: generateMockTodos()[4].projectId!.uuidString)! // ดึง ID จาก TodoItem

        return [
            ProjectItem(
                id: workProjectId,
                title: "โครงการเปิดตัวผลิตภัณฑ์ใหม่",
                description: "วางแผนและดำเนินการเปิดตัวสินค้าใหม่ในไตรมาสที่ 4",
                deadline: endOfMonth,
                teamMembers: ["สมชาย", "มานะ"],
                tasks: [
                    ProjectTask(title: "ออกแบบโลโก้", isCompleted: true),
                    ProjectTask(title: "ร่างแผนการโปรโมต", isCompleted: false)
                ],
                category: .work,
                color: "purple"
            ),
            ProjectItem(
                id: personalProjectId,
                title: "ปรับปรุงห้องครัว",
                description: "เปลี่ยนตู้และติดตั้งอุปกรณ์ทำครัวใหม่ทั้งหมด",
                deadline: today,
                teamMembers: ["จิดาภา"],
                tasks: [
                    ProjectTask(title: "วัดขนาดพื้นที่", isCompleted: true),
                    ProjectTask(title: "เลือกซื้อตู้ใหม่", isCompleted: false),
                    ProjectTask(title: "ติดตั้งไฟส่องสว่าง", isCompleted: false)
                ],
                category: .personal,
                color: "green"
            )
        ]
    }
}
