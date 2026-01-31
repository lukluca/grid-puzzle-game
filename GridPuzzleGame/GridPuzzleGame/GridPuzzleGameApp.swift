//
//  GridPuzzleGameApp.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import SwiftUI

@main
struct GridPuzzleGameApp: App {
    
    private var isProduction: Bool {
        NSClassFromString("XCTestCase") == nil
    }
    
    var body: some Scene {
        WindowGroup {
            if isProduction {
                ContentView(viewModel: .default)
            }
        }
    }
}
