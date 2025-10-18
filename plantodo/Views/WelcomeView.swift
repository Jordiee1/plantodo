//
//  WelcomeView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: TodoViewModel
    
    // ✅ กำหนดชื่อฟอนต์ที่ใช้
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    @State private var tempUserName: String = "" // ใช้ State ชั่วคราวในการกรอกชื่อ
    @State private var isAnimating = false
    @AppStorage("hasCompletedWelcome") var hasCompletedWelcome: Bool = false
    
    var body: some View {
        ZStack {
            Color.primaryBackground // ✅ สีพื้นหลังใหม่
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("👋")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .offset(y: isAnimating ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
                
                Text("ยินดีต้อนรับ!")
                    .font(.custom(boldFontName, size: 32)) // ✅ Custom Font
                    .foregroundColor(.accentColor)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.2), value: isAnimating)
                
                Text("กรุณาบอกชื่อของคุณ")
                    .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                    .foregroundColor(.gray)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.3), value: isAnimating)
                
                TextField("ชื่อของคุณ...", text: $tempUserName)
                    .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                    .padding()
                    .background(Color.secondaryBackground) // ✅ สี Card/Input
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                
                Button(action: {
                    let trimmedName = tempUserName.trimmingCharacters(in: .whitespaces)
                    if !trimmedName.isEmpty && trimmedName.lowercased() != "ผู้ใช้" {
                        viewModel.saveUserName(trimmedName) // บันทึกชื่อผ่าน ViewModel
                        hasCompletedWelcome = true // เปลี่ยนสถานะ AppStorage เพื่อเปลี่ยนหน้า
                    }
                }) {
                    Text("เริ่มต้นใช้งาน")
                        .font(.custom(boldFontName, size: 18)) // ✅ Custom Font
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            tempUserName.trimmingCharacters(in: .whitespaces).isEmpty ?
                            Color.gray : Color.accentColor // ✅ Accent Color
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(tempUserName.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
            }
            .padding()
            .background(Color.secondaryBackground) // ✅ สี Card
            .cornerRadius(30)
            .shadow(color: Color.accentColor.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 30)
        }
        .onAppear {
            isAnimating = true
            // โหลดชื่อผู้ใช้ที่บันทึกไว้ใน ViewModel มาแสดง (ถ้ามี)
            tempUserName = viewModel.userName
        }
    }
}
