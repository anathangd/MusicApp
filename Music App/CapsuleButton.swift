//
//  CapsuleButton.swift
//  Music App
//
//  Created by Nathan Davis on 8/21/25.
//

import Foundation
import SwiftUI

struct CapsuleButton: View {
    let title: String
    var color: Color = .black
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .padding(20)
        .background(color)
        .foregroundColor(.white)
        .clipShape(Capsule())
        .padding(10)
    }
}

extension View {
    func capsuleButtonStyle(color: Color = .black) -> some View {
        self
            .padding(20)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(10)
    }
}
