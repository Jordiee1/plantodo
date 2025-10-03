//
//  DailyProgress.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 3/10/2568 BE.
//


import Foundation

struct DailyProgress: Identifiable, Codable {
    let id: UUID
    let date: Date
    var completedCount: Int
    var fireCount: Int
    
    init(id: UUID = UUID(), date: Date, completedCount: Int = 0, fireCount: Int = 0) {
        self.id = id
        self.date = date
        self.completedCount = completedCount
        self.fireCount = fireCount
    }
}