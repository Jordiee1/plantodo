//
//  StatCard.swift
//  plantodo
//

import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let fontName: String // ✅ เพิ่ม Font Name
    let boldFontName: String // ✅ เพิ่ม Bold Font Name
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(fontName, size: 14)) // ✅ Custom Font
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.custom(boldFontName, size: 28)) // ✅ Custom Font Bold
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.secondaryBackground) // ✅ สี Card
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
