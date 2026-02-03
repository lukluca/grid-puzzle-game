//
//  Grid.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import SwiftUI
import UniformTypeIdentifiers

private typealias Tile = PuzzleModel.Tile

extension ContentView {
    struct Grid: View {
        
        let viewModel: ViewModel
        
        @State private var draggedTile: Tile? // The tile that we are dragging
        
        var body: some View {
            SwiftUI.Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<viewModel.size, id: \.self) { row in
                    GridRow {
                        ForEach(0..<viewModel.size, id: \.self) { column in
                            let tile = viewModel.tile(from: row, and: column)
                            TileContainer(
                                viewModel: viewModel,
                                tile: tile,
                                draggedTile: draggedTile
                            )
                            .onDrag({
                                draggedTile = tile
                                // Return a provider with the tile ID
                                return NSItemProvider(object: String(tile.id.uuidString) as NSString)
                            }, preview: {
                                TileView(
                                    image: viewModel.image,
                                    tileIndex: tile.originalIndex,
                                    gridSize: viewModel.size,
                                    dimension: viewModel.tileDimension
                                )
                            })
                            .onDrop(of: [.text], delegate: PuzzleDropDelegate(
                                tile: tile,
                                puzzle: viewModel.puzzle,
                                draggedTile: $draggedTile
                                
                            ))
                        }
                    }
                }
            }
            .frame(width: viewModel.dimension, height: viewModel.dimension)
            .clipped()
        }
    }
}

extension ContentView.Grid {
    fileprivate struct TileContainer: View {
        
        let viewModel: ViewModel
        let tile: Tile
        let draggedTile: Tile?
        
        var body: some View {
            if draggedTile == tile {
                Color(white: 0.95)
                    .frame(width: viewModel.tileDimension, height: viewModel.tileDimension)
            } else {
                TileView(
                    image: viewModel.image,
                    tileIndex: tile.originalIndex,
                    gridSize: viewModel.size,
                    dimension: viewModel.tileDimension
                )
            }
        }
    }
}

extension ContentView.Grid {
    struct TileView: View {
        let image: UIImage
        let tileIndex: Int
        let gridSize: Int
        let dimension: CGFloat
       
        var body: some View {
            ZStack {
                // compute cropping offsets
                GeometryReader { geo in
                    
                    // compute row/col of the tileIndex (which chunk of the original image to show)
                    let row = tileIndex / gridSize
                    let column = tileIndex % gridSize
                    
                    // We'll use SwiftUI's Image with resizable and then apply a cropping transform by
                    // scaling up so each tile shows the correct portion and offsetting it.
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * CGFloat(gridSize), height: geo.size.height * CGFloat(gridSize))
                        .offset(x: -CGFloat(column) * geo.size.width, y: -CGFloat(row) * geo.size.height)
                        .clipped()
                }
                Rectangle()
                    .stroke(Color.black.opacity(0.6), lineWidth: 1)
                
            }
            .frame(width: dimension, height: dimension)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - View Model

extension ContentView.Grid {
    /// Grid view
    /// - Parameters:
    ///     - image: The ``UIImage`` to be splitted.
    ///     - gridSize: The size of the grid.
    ///     - tileDimension: The dimension of a single tile.
    ///     - values: Helper function. Returns from row and column the shullfed index and if the tile is locked.
    struct ViewModel {
        let puzzle: PuzzleModel
        let image: UIImage
        let dimension: CGFloat
        
        var size: Int {
            puzzle.size
        }
        
        var tileDimension: CGFloat {
            dimension / CGFloat(size)
        }
        
        fileprivate func tile(from row: Int, and column: Int) -> Tile {
            let pos = puzzle.index(row: row, column: column)
            return puzzle.tiles[pos]
        }
    }
}

// MARK: - Drag & Drop Logic

fileprivate struct PuzzleDropDelegate: DropDelegate {
    
    let tile: Tile
    let puzzle: PuzzleModel
    @Binding var draggedTile: Tile?
    
    func performDrop(info: DropInfo) -> Bool {
        if draggedTile == tile {
            draggedTile = nil
            return false
        }
        
        guard let draggedTile,
              let fromIndex = puzzle.tiles.firstIndex(of: draggedTile),
              let toIndex = puzzle.tiles.firstIndex(of: tile)
        else {
            return false
        }
        
        puzzle.swapPositions(fromIndex, toIndex)
        
        self.draggedTile = nil
        
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}


// MARK: - Preview

#Preview {
    var puzzle = PuzzleModel.default
    puzzle.shuffle()
    return ContentView.Grid(viewModel: .init(puzzle: puzzle, image: UIImage(named: "Fallback")!, dimension: 402))
}




