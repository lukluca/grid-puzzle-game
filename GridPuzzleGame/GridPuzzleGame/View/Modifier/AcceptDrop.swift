//
//  AcceptDrop.swift
//  GridPuzzleGame
//
//  Created by lukluca on 26/01/26.
//

import SwiftUI
import UniformTypeIdentifiers.UTType

struct Droppable: ViewModifier {
    let condition: Bool
    let types: [UTType]
    let delegate: any DropDelegate

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrop(of: types, delegate: delegate)
        } else {
            content
        }
    }
}

extension View {
    public func acceptDrop(if condition: Bool, of supportedContentTypes: [UTType], delegate: any DropDelegate) -> some View {
        self.modifier(Droppable(condition: condition, types: supportedContentTypes, delegate: delegate))
    }
}
