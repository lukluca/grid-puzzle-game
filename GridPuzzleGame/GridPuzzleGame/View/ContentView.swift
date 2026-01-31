//
//  ContentView.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel: ViewModel
    
    @State private var isShuffleAlertPresented = false
    @State private var isNewGameAlertPresented = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(.xPuzzle("\(viewModel.size)", "\(viewModel.size)"))
                    .font(.headline)
                    .padding(.top)
                
                GeometryReader { geo in
                    stackView(from: geometry.size) {
                        let dimension = viewModel.gridDimension(from: geo.size)
                        
                        switch viewModel.state {
                        case .initial, .failure, .loading:
                            Color(white: 0.95)
                                .frame(width: dimension, height: dimension)
                        case .playing(let source):
                            Color(white: 0.95)
                                .frame(width: dimension, height: dimension)
                                .overlay(
                                    Grid(
                                        viewModel: .init(
                                        puzzle: viewModel.puzzle,
                                        image: source.image,
                                        dimension: dimension
                                    )
                                )
                            )
                        case .win(let source):
                            Image(uiImage: source.image)
                                .resizable()
                                .frame(width: dimension, height: dimension)
                        }
                        
                        if (geometry.size.width < geometry.size.height) {
                            Text(viewModel.state.hint)
                                .padding(.top)
                        }
                        
                        buttonsStackView(from: geometry.size) {
                            
                            if (geometry.size.width > geometry.size.height) {
                                Text(viewModel.state.hint)
                                    .padding(.bottom)
                            }
                            
                            // TODO: add buttons and handle disable/enabled state
                            
                            Spacer()
                            
                            Text(viewModel.state.description)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }.task {
            await viewModel.loadImage()
        }.onAppear {
            viewModel.observePuzzleCompletion()
        }
        
    }
    
    @ViewBuilder
    func stackView<Content : View>(
        from size: CGSize,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if size.width > size.height {
            HStack(content: content)
        } else {
            VStack(content: content)
        }
    }
    
    @ViewBuilder
    func buttonsStackView<Content : View>(
        from size: CGSize,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if size.width > size.height {
            VStack(content: content)
                .padding()
        } else {
            HStack(content: content)
                .padding()
        }
    }
}

#Preview("Default") {
    ContentView(viewModel: .default)
}

#Preview("Network error") {
    ContentView(viewModel: ContentView.ViewModel(fetcher: ImageFetcher(network: .init(session: .shared, url: nil), local: .default), puzzle: .default))
}

#Preview("Network error and file error") {
    ContentView(viewModel: ContentView.ViewModel(fetcher: ImageFetcher(network: .init(session: .shared, url: nil), local: .init(named: "")), puzzle: .default))
}
