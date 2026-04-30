//
//  PianoPiece.swift
//  Music App
//
//  Created by Nathan Davis on 4/30/26.
//

import Foundation
import SwiftData

enum PianoPieceStatus: String, Codable, CaseIterable {
    case active
    case completed
    case inactive
}

@Model
class PianoPiece: Identifiable {
    var id: UUID = UUID()
    var name: String
    var dateCreated: Date
    var status: PianoPieceStatus = PianoPieceStatus.active
    @Relationship(deleteRule: .cascade, inverse: \TallyMethodEntry.piece)
    var entries: [TallyMethodEntry] = []

    init(name: String, status: PianoPieceStatus = .active) {
        self.name = name
        self.dateCreated = Date()
        self.status = status
    }
}
