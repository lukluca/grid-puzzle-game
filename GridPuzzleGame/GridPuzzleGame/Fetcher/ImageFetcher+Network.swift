//
//  ImageFetcher+Network.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import Foundation
import UIKit.UIImage

extension ImageFetcher {
    struct Network {
        let session: URLSession
        let url: URL?
        
        func loadImage() async throws -> UIImage {
            guard let url else { throw URLError(.badURL) }
            
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw Error.dataIsNotAnImage
            }
            return image
        }
    }
}

extension ImageFetcher.Network {
    enum Error: Swift.Error {
        case dataIsNotAnImage
    }
}

extension ImageFetcher.Network {
    static var `default`: ImageFetcher.Network {
        ImageFetcher.Network(session: .shared, url: URL(string: "https://picsum.photos/1024"))
    }
}
