//
//  AcceptDrag.swift
//  GridPuzzleGame
//
//  Created by lukluca on 26/01/26.
//

import SwiftUI
import UniformTypeIdentifiers.UTType

struct DraggableWithPreview<V>: ViewModifier where V : View {
    let condition: Bool
    let data: () -> NSItemProvider
    let preview: (() -> V)?

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            if let preview {
                content.onDrag(data, preview: preview)
            } else {
                content.onDrag(data)
            }
        } else {
            content
        }
    }
}

struct Draggable: ViewModifier {
    let condition: Bool
    let data: () -> NSItemProvider

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrag(data)
        } else {
            content
        }
    }
}

extension View {
    func acceptDrag(if condition: Bool, _ data: @escaping () -> NSItemProvider) -> some View {
        modifier(Draggable(condition: condition, data: data))
    }
    
    func acceptDrag<V>(if condition: Bool, _ data: @escaping () -> NSItemProvider, @ViewBuilder preview: @escaping () -> V) -> some View where V : View {
        modifier(DraggableWithPreview(condition: condition, data: data, preview: preview))
    }
}
