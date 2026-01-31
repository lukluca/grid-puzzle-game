//
//  ImageFetcher.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import Foundation
import UIKit.UIImage

struct ImageFetcher {
    let network: Network
    let local: Local
    
    func loadImage() async throws -> Result {
        do {
            return try await .network(network.loadImage())
        } catch {
            return try .local(local.loadImage())
        }
    }
}

extension ImageFetcher {
    static var `default`: ImageFetcher {
        ImageFetcher(network: .default, local: .default)
    }
}

extension ImageFetcher {
    enum Result {
        case network(UIImage)
        case local(UIImage)
    }
}
