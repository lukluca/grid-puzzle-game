//
//  ContentView+ViewModel.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import SwiftUI

extension ContentView {
    @Observable
    final class ViewModel {
        
        private(set) var state: State = .initial
        
        private let fetcher: ImageFetcher
        let puzzle: PuzzleModel
        
        @ObservationIgnored
        var size: Int {
            puzzle.size
        }
        
        private var isObservingPuzzle = false
        
        init(fetcher: ImageFetcher, puzzle: PuzzleModel) {
            self.fetcher = fetcher
            self.puzzle = puzzle
        }
        
        
        /// Loads the image updating the state
        func loadImage() async {
            
            state = .loading
            
            do {
                let result = try await fetcher.loadImage()
                
                let source: State.Source
                switch result {
                case .network(let image):
                    source = .network(image)
                case .local(let image):
                    source = .fallback(image)
                }
                
                shuffle()
                
                if puzzle.isComplete {
                    state = .win(source)
                } else {
                    state = .playing(source)
                }
                
            } catch {
                state = .failure
            }
        }
        
        /// Shuffles the puzzle
        func shuffle() {
            puzzle.shuffle()
        }
        
        /// Calculates the dimenasion of the grid
        /// - Parameters:
        ///     - size: The father ``CGSize``
        func gridDimension(from size: CGSize) -> CGFloat {
            let extra = if size.width > size.height {
                CGFloat(30)
            } else {
                CGFloat(140)
            }
            
            return min(size.width, size.height - extra)
        }
        
        func observePuzzleCompletion() {
            guard !isObservingPuzzle else {
                return
            }
            
            isObservingPuzzle = true
            
            trackPuzzleCompletion { [weak self] in
                self?.isObservingPuzzle = false
            }
        }
        
        private func trackPuzzleCompletion(onWin: @escaping () -> Void) {
            withObservationTracking { [weak self] in
                guard let self else { return }
                _ = puzzle.isComplete
            } onChange: {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    
                    if puzzle.isComplete {
                        if case .playing(let source) = state {
                            state = .win(source)
                            onWin()
                        }
                    } else {
                        trackPuzzleCompletion(onWin: onWin)
                    }
                }
            }
        }
    }
}

extension ContentView.ViewModel {
    enum State {
        case initial
        case loading
        case playing(Source)
        case win(Source)
        case failure
        
        var hint: String {
            switch self {
            case .initial, .loading, .failure:
                return ""
            case .playing:
                return String(localized: "Recompose the image!")
            case .win:
                let value = String(localized: "You completed the game!!!")
                return "🏆 " + value + " 🏆"
            }
        }
        
        var description: String {
            switch self {
            case .initial:
                ""
            case .loading:
                String(localized: "Loading...")
            case .playing(let source):
                source.description
            case .win(let source):
                source.description
            case .failure:
                String(localized: "There was an error. Try again")
            }
        }
    }
}

extension ContentView.ViewModel.State {
    enum Source {
        case network(UIImage)
        case fallback(UIImage)
        
        var description: String {
            switch self {
            case .network:
                String(localized: "Image: network")
            case .fallback:
                String(localized: "Using fallback image")
            }
        }
        
        var image: UIImage {
            switch self {
            case .network(let image), .fallback(let image):
                image
            }
        }
    }
}

extension ContentView.ViewModel {
    static var `default`: ContentView.ViewModel {
        ContentView.ViewModel(fetcher: .default, puzzle: .default)
    }
}
