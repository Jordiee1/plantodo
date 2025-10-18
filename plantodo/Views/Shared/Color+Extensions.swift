//
//  Color+Extensions.swift
//  plantodo
//
//  กำหนดสีรองสำหรับ Background และ Category
//

import SwiftUI

extension Color {
    // NOTE: Primary Accent ถูกกำหนดใน Assets > AccentColor
    
    static let primaryBackground = Color(hex: "#F7F8F9") // ขาวนวล/เทาอ่อน
    static let secondaryBackground = Color(hex: "#FFFFFF")// พื้นหลัง Card/Input
    
    // โทนสีรองสำหรับ Category/Highlight
    static let accentYellow = Color(hex: "#FFC700")      // เหลือง
    static let accentMint = Color(hex: "#B2EBF2")        // ฟ้า/เขียวมิ้นต์
    static let accentRed = Color(hex: "#EF5350")         // แดง (Warning/Delete)
    
    // Initializer เพื่อให้ใช้ Hex Code ได้
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
