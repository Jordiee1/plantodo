import SwiftUI

extension Font {
    
    // enum ช่วยให้เรียกใช้ง่ายและลดความผิดพลาดในการพิมพ์ชื่อฟอนต์
    enum CustomWeight {
        case light
        case regular
        case medium
        
        var fontName: String {
            switch self {
            case .light:
                // ต้องตรงกับชื่อ PostScript ของฟอนต์ (จาก Info.plist)
                return "IBMPlexSansThai-Light"
            case .regular:
                return "IBMPlexSansThai-Regular"
            case .medium:
                return "IBMPlexSansThai-Medium"
            }
        }
    }
    
    // ฟังก์ชันที่ใช้ในการสร้าง Font Object
    static func pdsanThai(style: Font.TextStyle, weight: CustomWeight) -> Font {
        
        // 1. หาขนาดมาตรฐานของ Text Style นั้นๆ (เพื่อให้รองรับ Dynamic Type)
        // เราใช้ UIFontMetrics ในการหาขนาดมาตรฐานของ Text Style นั้นๆ
        let defaultSize: CGFloat
        switch style {
        case .largeTitle: defaultSize = 34
        case .title: defaultSize = 28
        case .title2: defaultSize = 22
        case .title3: defaultSize = 20
        case .headline: defaultSize = 17
        case .body: defaultSize = 17 // นี่คือค่า Body Font ที่ใช้บ่อยสุด
        case .callout: defaultSize = 16
        case .subheadline: defaultSize = 15
        case .footnote: defaultSize = 13
        case .caption: defaultSize = 12
        case .caption2: defaultSize = 11
        @unknown default: defaultSize = 17
        }
        
        // 2. สร้าง Font.custom โดยใช้ขนาดมาตรฐาน และกำหนด relativeTo: เพื่อให้ปรับขนาดตาม Dynamic Type
        return .custom(weight.fontName, size: defaultSize, relativeTo: style)
    }
}

// -------------------------------------------------------------
// ส่วน Custom Environment Key (ยังใช้ได้เหมือนเดิม)
// -------------------------------------------------------------

private struct BodyFontKey: EnvironmentKey {
    // กำหนดค่าเริ่มต้นของฟอนต์ body ด้วย Weight: .regular
    static let defaultValue: Font = .pdsanThai(style: .body, weight: .regular)
}

extension EnvironmentValues {
    var customBodyFont: Font {
        get { self[BodyFontKey.self] }
        set { self[BodyFontKey.self] = newValue }
    }
}

extension View {
    func customBodyFont(_ font: Font) -> some View {
        self.environment(\.customBodyFont, font)
    }
}
