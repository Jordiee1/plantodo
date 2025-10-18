//
//  WishlistItem.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 17/10/2568 BE.
//


import Foundation

struct WishlistItem: Identifiable, Codable {
    let id: UUID
    var emoji: String
    var goal: String // สิ่งที่จะทำ (ดูหนัง, กินไอติม)
    var threshold: Int // งานที่ต้องทำครบ (2 งาน)
    var currentProgress: Int = 0 // งานที่ทำสำเร็จนับตั้งแต่ตั้ง Goal นี้
    var isAchieved: Bool = false
    
    init(id: UUID = UUID(), emoji: String = "🎁", goal: String, threshold: Int, currentProgress: Int = 0) {
        self.id = id
        self.emoji = emoji
        self.goal = goal
        self.threshold = threshold
        self.currentProgress = currentProgress
    }
}
