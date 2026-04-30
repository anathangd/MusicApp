//
//  TallyMethodEntry.swift
//  Music App
//
//  Created by Nathan Davis on 4/30/26.
//

import Foundation
import SwiftData

@Model
class TallyMethodEntry: Identifiable {
    var id: UUID = UUID()
    var day: Int
    var session: Int
    var dateCreated: Date
    var sections: [String] = []
    var reps: [Int] = []
    var memorized: [Bool] = []
    var notes: String = ""
    var piece: PianoPiece?

    init(day: Int, session: Int = 1, dateCreated: Date = Date(), piece: PianoPiece? = nil) {
        self.day = day
        self.session = session
        self.dateCreated = dateCreated
        self.piece = piece
    }
}
