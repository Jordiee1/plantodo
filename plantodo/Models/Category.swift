//
//  Category.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case general = "ทั่วไป"
    case work = "งาน"
    case personal = "ส่วนตัว"
    case health = "สุขภาพ"
    case shopping = "ช้อปปิ้ง"
    case study = "การเรียน"
    case other = "อื่น ๆ"   // ✅ เพิ่ม case นี้

    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .general: return Color(red: 0.8, green: 0.8, blue: 1.0)
        case .work: return Color(red: 1.0, green: 0.8, blue: 0.8)
        case .personal: return Color(red: 1.0, green: 0.95, blue: 0.8)
        case .health: return Color(red: 0.8, green: 1.0, blue: 0.9)
        case .shopping: return Color(red: 1.0, green: 0.9, blue: 1.0)
        case .study: return Color(red: 0.9, green: 0.95, blue: 1.0)
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
