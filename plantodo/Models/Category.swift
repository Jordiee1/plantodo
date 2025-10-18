//
//  Category.swift
//  plantodo
//

import SwiftUI

extension Color {
    // Helper สำหรับ Category Colors
    static let colorGeneral = Color(hex: "#635BFF")
    static let colorWork = Color(hex: "#FFC700")
    static let colorPersonal = Color(hex: "#B2EBF2")
    static let colorHealth = Color(hex: "#EF5350")
}

enum Category: String, Codable, CaseIterable, Identifiable {
    case general = "ทั่วไป"
    case work = "งาน"
    case personal = "ส่วนตัว"
    case health = "สุขภาพ"
    case shopping = "ช้อปปิ้ง"
    case study = "การเรียน"
    case other = "อื่น ๆ"

    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        // ✅ FIX: ใช้สีพื้นฐานที่คำนวณแล้ว (เพื่อลด Chained Modifiers)
        case .general: return Color.colorGeneral
        case .work: return Color.colorWork
        case .personal: return Color.colorPersonal
        case .health: return Color.colorHealth
        case .shopping: return Color.purple
        case .study: return Color.blue
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "📋"
        case .work: return "💼"
        case .personal: return "⭐"
        case .health: return "💊"
        case .shopping: return "🛒"
        case .study: return "📚"
        case .other: return "🔖"
        }
    }
}
