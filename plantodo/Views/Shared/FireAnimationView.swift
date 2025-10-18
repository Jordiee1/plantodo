//
//  FireAnimationView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct FireAnimationView: View {
    @Environment(\.customBodyFont) var bodyFont
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🔥")
                    .font(.system(size: 100)).font(bodyFont)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))
                
                Text("ยอดเยี่ยม!")
                    .font(.system(size: 28, weight: .bold)).font(bodyFont)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("คุณทำงานสำเร็จครบ 3 งาน!")
                    .font(.system(size: 16)).font(bodyFont)
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.2
                opacity = 1
            }
            
            withAnimation(.linear(duration: 0.3).repeatForever(autoreverses: true)) {
                rotation = 10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                    scale = 1.5
                }
            }
        }
    }
}
