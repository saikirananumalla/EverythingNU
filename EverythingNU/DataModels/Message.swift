//
//  Message.swift
//  final
//
//  Created by Sai Kiran Anumalla on 07/12/24.
//

import Foundation
import FirebaseFirestore

struct Message: Codable {
    var id: String?
    var content: String
    var senderId: String
    var senderName: String
    var timestamp: Timestamp

    var formattedTimestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: timestamp.dateValue())
    }
}

