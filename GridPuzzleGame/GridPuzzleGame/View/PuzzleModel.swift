//
//  PuzzleModel.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import Foundation

/// Immutable / value-semantics puzzle model.
@Observable
final class PuzzleModel {
    let size: Int // grid size (3 means 3x3)
    private(set) var tiles: [Tile]
    
    init(size: Int) {
        self.size = size
        self.tiles = Array(0..<(size*size)).map { Tile(originalIndex: $0)}
    }

    func shuffle() {
        var shuffled = tiles
        shuffled.shuffle()
        // ensure not accidentally solved
        if shuffled == tiles {
            shuffled.shuffle()
        }
        tiles = shuffled
        // compute locked
        tiles = tiles.enumerated().map { (index, tile) in
            update(tile: tile, at: index)
        }
    }
    
    private func update(tile: Tile, at index: Int) -> Tile {
        var updated = tile
        updated.isCorrectPosition = index == tile.originalIndex
        return updated
    }

    var isComplete: Bool {
        tiles.allSatisfy { $0.isCorrectPosition }
    }

    /// Swap two positions, respecting locked flags (no-op if either is locked).
    func swapPositions(_ a: Int, _ b: Int) {
        guard a != b else { return }
        if tiles[a].isCorrectPosition || tiles[b].isCorrectPosition { return }
        tiles.swapAt(a, b)
        
        func updateTile(at index: Int) {
            tiles[index] = update(tile: tiles[index], at: index)
        }
        
        updateTile(at: a)
        updateTile(at: b)
    }

    // Helper to get row/col <-> index
    func index(row: Int, column: Int) -> Int { row * size + column }
}

extension PuzzleModel {
    static var `default`: PuzzleModel {
        PuzzleModel(size: 3)
    }
}

extension PuzzleModel: Equatable {
    static func == (lhs: PuzzleModel, rhs: PuzzleModel) -> Bool {
        lhs.size == rhs.size && lhs.tiles == rhs.tiles
    }
}

extension PuzzleModel {
    struct Tile {
        let id = UUID()
        let originalIndex: Int // This is the correct position of the tile
        var isCorrectPosition = true
    }
}

extension PuzzleModel.Tile: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
