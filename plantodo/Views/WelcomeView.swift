//
//  WelcomeView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//

import SwiftUI

struct WelcomeView: View {
    @State private var userName: String = ""
    @State private var isAnimating = false
    @Binding var hasCompletedWelcome: Bool
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.96, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("👋")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .offset(y: isAnimating ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
                
                Text("ยินดีต้อนรับ!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.2), value: isAnimating)
                
                Text("กรุณาบอกชื่อของคุณ")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.3), value: isAnimating)
                
                TextField("ชื่อของคุณ...", text: $userName)
                    .padding()
                    .background(Color(red: 1.0, green: 0.96, blue: 0.97))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 1.0, green: 0.84, blue: 0.91), lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                
                Button(action: {
                    if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                        UserDefaults.standard.set(userName, forKey: "userName")
                        UserDefaults.standard.set(true, forKey: "hasCompletedWelcome")
                        withAnimation {
                            hasCompletedWelcome = true
                        }
                    }
                }) {
                    Text("เริ่มต้นใช้งาน")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            userName.trimmingCharacters(in: .whitespaces).isEmpty ?
                            Color.gray : Color(red: 1.0, green: 0.42, blue: 0.62)
                        )
                        .cornerRadius(15)
                        .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 30)
        }
        .onAppear {
            isAnimating = true
            if let savedName = UserDefaults.standard.string(forKey: "userName") {
                userName = savedName
            }
            if UserDefaults.standard.bool(forKey: "hasCompletedWelcome") {
                hasCompletedWelcome = true
            }
        }
    }
}
