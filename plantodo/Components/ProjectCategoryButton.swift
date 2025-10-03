//
//  ProjectCategoryButton.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//


//
//  ProjectCategoryButton.swift
//  plantodo
//
//  Created for Team Project Feature
//

import SwiftUI

struct ProjectCategoryButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? color : .gray)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? color : .gray)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview
struct ProjectCategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            ProjectCategoryButton(
                icon: "briefcase.fill",
                label: "Work",
                color: .blue,
                isSelected: true,
                action: {}
            )
            
            ProjectCategoryButton(
                icon: "house.fill",
                label: "Personal",
                color: .green,
                isSelected: false,
                action: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}