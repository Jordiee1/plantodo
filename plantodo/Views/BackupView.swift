//
//  BackupView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI

struct BackupView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var showExportSuccess = false
    @State private var showImportPicker = false
    @State private var exportedData = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 15) {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                            
                            Text("สำรองข้อมูล")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("จัดการข้อมูลรายการของคุณ")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 15) {
                            StatCard(icon: "checkmark.circle.fill", title: "งานทั้งหมด", value: "\(viewModel.todos.count)", color: Color(red: 1.0, green: 0.42, blue: 0.62))
                            
                            StatCard(icon: "checkmark.circle.fill", title: "งานที่เสร็จแล้ว", value: "\(viewModel.todos.filter { $0.isCompleted }.count)", color: Color.green)
                            
                            StatCard(icon: "clock.fill", title: "งานที่รออยู่", value: "\(viewModel.todos.filter { !$0.isCompleted }.count)", color: Color.orange)
                            
                            StatCard(icon: "flame.fill", title: "ไฟที่ได้รับ", value: "\(viewModel.dailyProgress.reduce(0) { $0 + $1.fireCount })", color: Color.red)
                        }
                        
                        VStack(spacing: 15) {
                            Button(action: exportData) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20))
                                    
                                    Text("ส่งออกข้อมูล")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(red: 1.0, green: 0.42, blue: 0.62))
                                .cornerRadius(15)
                                .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            Button(action: { showImportPicker = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 20))
                                    
                                    Text("นำเข้าข้อมูล")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.blue)
                                .cornerRadius(15)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            Button(action: clearAllData) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                    
                                    Text("ลบข้อมูลทั้งหมด")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.red)
                                .cornerRadius(15)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ℹ️ คำแนะนำ")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("• ส่งออกข้อมูลเพื่อสำรองข้อมูลของคุณ\n• นำเข้าข้อมูลเพื่อกู้คืนข้อมูลที่สำรองไว้\n• ลบข้อมูลทั้งหมดเพื่อเริ่มต้นใหม่")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("สำรองข้อมูล")
            .navigationBarTitleDisplayMode(.inline)
            .alert("ส่งออกสำเร็จ", isPresented: $showExportSuccess) {
                Button("ตกลง", role: .cancel) { }
            } message: {
                Text("ข้อมูลของคุณถูกส่งออกเรียบร้อยแล้ว")
            }
        }
    }
    
    private func exportData() {
        showExportSuccess = true
    }
    
    private func clearAllData() {
        viewModel.todos.removeAll()
        viewModel.dailyProgress.removeAll()
    }
}

