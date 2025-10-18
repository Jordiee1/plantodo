//
//  ImagePicker.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 17/10/2568 BE.
//


import SwiftUI
import UIKit // ต้อง import UIKit

// UIImagePickerController Coordinator
struct ImagePicker: UIViewControllerRepresentable {
    
    // ✅ Binding สำหรับส่งรูปภาพที่เลือกกลับไป
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary // ตั้งค่าให้เลือกจากแกลเลอรี
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator Class
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // เมื่อผู้ใช้เลือกรูปภาพเสร็จสิ้น
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.dismiss()
        }
        
        // เมื่อผู้ใช้กดยกเลิก
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
