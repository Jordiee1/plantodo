//
//  CategoryButton.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 17/10/2568 BE.
//


//
//  SharedComponents.swift
//  plantodo
//
//  Component ที่ใช้ร่วมกัน: CategoryButton, MockPickers
//

import SwiftUI

// MARK: - CategoryButton (ใช้ใน AddTodoSheet และ AddProjectSheet)
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    let boldFontName: String
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(category.icon).font(.system(size: 28)) 
                Text(category.rawValue)
                    .font(.custom(boldFontName, size: 12))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.accentColor : category.color)
            .cornerRadius(15)
            .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
    }
}

// MARK: - MockContactPicker (ใช้ใน AddProjectSheet)
struct MockContactPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var teamMembers: [String]
    let boldFontName: String 
    
    let mockContacts = ["สมชาย เข็มกลัด", "มานะ ทรัพย์สิน", "ปรีชา ใจดี", "วิมล ว่องไว"]
    @State private var tempSelection: Set<String>
    
    init(teamMembers: Binding<[String]>, boldFontName: String) {
        self._teamMembers = teamMembers
        self.boldFontName = boldFontName
        self._tempSelection = State(initialValue: Set(teamMembers.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(mockContacts, id: \.self) { contact in
                    HStack {
                        Text(contact)
                            .font(.custom(boldFontName, size: 16)) 
                        Spacer()
                        if tempSelection.contains(contact) {
                            Image(systemName: "checkmark").foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if tempSelection.contains(contact) {
                            tempSelection.remove(contact)
                        } else {
                            tempSelection.insert(contact)
                        }
                    }
                }
            }
            .navigationTitle("เลือกผู้ติดต่อ")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("เสร็จสิ้น") { 
                        teamMembers = Array(tempSelection) 
                        dismiss() 
                    }
                    .font(.custom(boldFontName, size: 16)) 
                }
            }
        }
    }
}

// MARK: - MockImagePicker (ใช้ใน AddProjectSheet)
struct MockImagePicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImageURL: String?
    let boldFontName: String 
    
    let mockImages = [
        "https://placehold.co/600x400/9C27B0/FFFFFF/png?text=Design+Draft",
        "https://placehold.co/600x400/00BCD4/FFFFFF/png?text=Meeting+Photo",
        "https://placehold.co/600x400/FF5722/FFFFFF/png?text=Goal+Chart"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(mockImages, id: \.self) { url in
                    Text("รูปภาพจำลอง: \(url.suffix(15))...")
                        .font(.custom(boldFontName, size: 16)) 
                        .onTapGesture {
                            selectedImageURL = url
                            dismiss()
                        }
                }
            }
            .navigationTitle("เลือกรูปภาพ")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") { dismiss() }
                }
            }
        }
    }
}
