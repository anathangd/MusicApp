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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.purple : color)
        .foregroundColor(.white)
        .clipShape(Capsule())
        .padding(10)
    }
}

struct CapsuleButtonStyleModifier: ViewModifier {
    var color: Color
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(colorScheme == .dark ? Color.purple : color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(10)
    }
}

extension View {
    func capsuleButtonStyle(color: Color = .black) -> some View {
        self.modifier(CapsuleButtonStyleModifier(color: color))
    }
}
