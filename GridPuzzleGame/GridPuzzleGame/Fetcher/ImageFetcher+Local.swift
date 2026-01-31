//
//  ImageFetcher+Local.swift
//  GridPuzzleGame
//
//  Created by lukluca on 25/01/26.
//

import UIKit.UIImage

extension ImageFetcher {
    struct Local {
        let named: String
        
        func loadImage() throws -> UIImage {
            guard let image = UIImage(named: named) else {
                throw Error.providedNameIsNotAnImage
            }
            return image
        }
    }
}

extension ImageFetcher.Local {
    enum Error: Swift.Error {
        case providedNameIsNotAnImage
    }
}

extension ImageFetcher.Local {
    static var `default`: ImageFetcher.Local {
        ImageFetcher.Local(named: "Fallback")
    }
}
