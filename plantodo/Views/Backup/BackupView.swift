//
//  BackupView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import SwiftUI
import UniformTypeIdentifiers

// MARK: - FilePicker (Coordinator) - ✅ เพิ่มโครงสร้างที่ขาดหายไป
struct FilePicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // อนุญาตให้เลือกไฟล์ประเภทใดก็ได้ (เช่น JSON หรือ Text)
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker
        
        init(_ parent: FilePicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedFileURL = urls.first
            parent.isPresented = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
        }
    }
}


struct BackupView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var showExportSuccess = false
    @State private var showImportPicker = false // ใช้ตัวนี้
    @State private var exportedData = ""
    @State private var selectedFileURL: URL? // URL ของไฟล์ที่เลือก
    @State private var showFileImportAlert = false
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"

    // ✅ Computed Properties สำหรับการคำนวณสถิติ (ลดภาระคอมไพเลอร์ใน Body)
    var totalTodos: Int { viewModel.todos.count }
    var completedTodos: Int { viewModel.todos.filter { $0.isCompleted }.count }
    var outstandingTodos: Int { viewModel.todos.filter { !$0.isCompleted }.count }
    var totalFireCount: Int { viewModel.dailyProgress.reduce(0) { $0 + $1.fireCount } }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground // ✅ สีพื้นหลังใหม่
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 15) {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor) // ✅ Accent Color
                            
                            Text("สำรองข้อมูล")
                                .font(.custom(boldFontName, size: 28)) // ✅ Custom Font
                                .foregroundColor(.black)
                            
                            Text("จัดการข้อมูลรายการของคุณ")
                                .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        
                        // ✅ ส่วน Stat Cards (ใช้ Computed Properties)
                        VStack(spacing: 15) {
                            StatCard(
                                icon: "list.bullet.clipboard.fill",
                                title: "งานทั้งหมด",
                                value: "\(totalTodos)",
                                color: .accentColor, // ✅ Accent Color
                                fontName: regularFontName,
                                boldFontName: boldFontName
                            )
                            
                            StatCard(
                                icon: "checkmark.circle.fill",
                                title: "งานที่เสร็จแล้ว",
                                value: "\(completedTodos)",
                                color: .accentMint, // ✅ Accent Mint Color
                                fontName: regularFontName,
                                boldFontName: boldFontName
                            )
                            
                            StatCard(
                                icon: "clock.fill",
                                title: "งานที่รออยู่",
                                value: "\(outstandingTodos)",
                                color: .accentYellow, // ✅ Accent Yellow Color
                                fontName: regularFontName,
                                boldFontName: boldFontName
                            )
                            
//                            StatCard(
//                                icon: "flame.fill",
//                                title: "ไฟที่ได้รับ",
//                                value: "\(totalFireCount)",
//                                color: .accentRed, // ✅ Accent Red Color
//                                fontName: regularFontName,
//                                boldFontName: boldFontName
//                            )
                        }
                        
                        // Action Buttons Section
                        VStack(spacing: 15) {
                            // ปุ่มส่งออก (Export)
                            Button(action: exportData) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20))
                                    
                                    Text("ส่งออกข้อมูล")
                                        .font(.custom(boldFontName, size: 18)) // ✅ Custom Font
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.accentColor) // ✅ Accent Color
                                .cornerRadius(15)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // ปุ่มนำเข้า (Import)
                            Button(action: { showImportPicker = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 20))
                                    
                                    Text("นำเข้าข้อมูล")
                                        .font(.custom(boldFontName, size: 18)) // ✅ Custom Font
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.accentColor) // ✅ ใช้ Accent Color แทน Color.blue
                                .cornerRadius(15)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4) // ✅ ใช้ Accent Color
                            }
                            
                            // ปุ่มลบข้อมูลทั้งหมด
                            Button(action: clearAllData) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                    
                                    Text("ลบข้อมูลทั้งหมด")
                                        .font(.custom(boldFontName, size: 18)) // ✅ Custom Font
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.accentRed) // ✅ Accent Red
                                .cornerRadius(15)
                                .shadow(color: Color.accentRed.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                        // Information Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ℹ️ คำแนะนำ")
                                .font(.custom(boldFontName, size: 16)) // ✅ Custom Font
                                .foregroundColor(.black)
                            
                            Text("• ส่งออกข้อมูลเพื่อสำรองข้อมูลของคุณ\n• นำเข้าข้อมูลเพื่อกู้คืนข้อมูลที่สำรองไว้\n• ลบข้อมูลทั้งหมดเพื่อเริ่มต้นใหม่")
                                .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(Color.secondaryBackground) // ✅ สี Card
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
            .sheet(isPresented: $showImportPicker) {
                FilePicker(selectedFileURL: $selectedFileURL, isPresented: $showImportPicker)
            }
            .onChange(of: selectedFileURL) { newValue in
                if let url = newValue {
                    print("Selected file URL: \(url)")
                    showFileImportAlert = true
                }
            }
            .alert("นำเข้าสำเร็จ", isPresented: $showFileImportAlert) {
                Button("ตกลง", role: .cancel) {}
            } message: {
                Text("จำลองการนำเข้า: เลือกไฟล์สำเร็จแล้ว")
            }
            .font(.custom(regularFontName, size: 16)) // ✅ กำหนด Font พื้นฐาน
        }
    }
    
    private func exportData() {
        showExportSuccess = true
    }
    
    private func clearAllData() {
        viewModel.todos.removeAll()
        viewModel.projects.removeAll()
        viewModel.dailyProgress.removeAll()
        UserDefaults.standard.set(nil, forKey: "todos")
        UserDefaults.standard.set(nil, forKey: "projects")
        UserDefaults.standard.set(nil, forKey: "dailyProgress")
    }
}
