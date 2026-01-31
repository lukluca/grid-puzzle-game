//
//  GridPuzzleGameTests.swift
//  GridPuzzleGameTests
//
//  Created by lukluca on 25/01/26.
//

import Testing
import Foundation
import UIKit

@testable import GridPuzzleGame

struct GridViewModelTests {

    @MainActor
    @Test func hasGotSameSizeThanPuzzle() async throws {
        let size: Int = 4
        let sut = makeSut(fetcher: makeFailingImageFetcher(), puzzleOfSize: size)
        
        #expect(sut.size == size)
    }
    
    @MainActor
    @Test func atInitTimeTheStateIsInitial() async throws {
        let sut = makeSutWithFailingFetcher()
        
        #expect(sut.state == .initial)
    }
    
    @MainActor
    @Test func setLoadingStateWhenLoadImageIsCalled() async throws {
        let sut = makeSutWithSuccessFetcher() // success otherwise we miss the state value
        
        observeState(of: sut) { state in
            switch state {
            case .loading:
                #expect(Bool(true))
            default:
                #expect(Bool(false))
            }
        }
        
        await sut.loadImage()
    }
    
    @MainActor
    @Test func setPlayingStateWhenImageIsLoadedAndThereIsANetworkError() async throws {
        let sut = makeSutWithFailingFetcher()
        
        observeState(of: sut) { state in
            switch state {
            case .playing(let source):
                switch source {
                case .fallback:
                    #expect(Bool(true))
                default:
                    #expect(Bool(false))
                }
            default:
                #expect(Bool(false))
            }
        }
        
        await sut.loadImage()
    }
    
    @MainActor
    @Test func setPlayingStateWhenImageIsLoadedAndThereIsNotANetworkError() async throws {
        let data = imageData
        let sut = makeSutWithSuccessFetcher(data: data)
        
        observeStateAfterLoading(of: sut) { state in
            switch state {
            case .playing(let source):
                switch source {
                case .network(let image):
                    #expect(image.pngData() == UIImage(data: data)?.pngData())
                default:
                    #expect(Bool(false))
                }
            default:
                #expect(Bool(false))
            }
        }
      
        await sut.loadImage()
    }
    
    @MainActor
    @Test func setWinStateWhenImageIsLoadedFromNetworkAndThePuzzleIsCompleted() async throws {
        let data = imageData
        let sut = makeSut(fetcher: makeSuccessImageFetcher(data: data), puzzleOfSize: 1) // 1 simulates a puzzle completed
       
        observeStateAfterLoading(of: sut) { state in
            switch state {
            case .win(let source):
                switch source {
                case .network(let image):
                    #expect(image.pngData() == UIImage(data: data)?.pngData())
                default:
                    #expect(Bool(false))
                }
            default:
                #expect(Bool(false))
            }
        }
      
        await sut.loadImage()
    }
    
    @MainActor
    @Test func setWinStateWhenThereIsANetworkErrorAndThePuzzleIsCompleted() async throws {
        let sut = makeSut(fetcher: makeFailingImageFetcher(), puzzleOfSize: 1) // 1 simulates a puzzle completed
        
        observeStateAfterLoading(of: sut) { state in
            switch state {
            case .win(let source):
                switch source {
                case .fallback:
                    #expect(Bool(true))
                default:
                    #expect(Bool(false))
                }
            default:
                #expect(Bool(false))
            }
        }
      
        await sut.loadImage()
    }
    
    @MainActor
    @Test func shufflesPuzzleAfterImageIsRetrieved() async throws {
        let puzzle = PuzzleModel.default
        let sut = makeSut(fetcher: makeSuccessImageFetcher(data: imageData), puzzle: puzzle)
        
        await sut.loadImage()
        
        #expect(puzzle.isComplete == false)
    }
    
    @MainActor
    @Test func setsFailureStateInCaseThereIsAFatalError() async throws {
        let sut = makeSut(fetcher: makeFailingImageFetcher(local: .init(named: "")))
        
        observeStateAfterLoading(of: sut) { state in
            switch state {
            case .failure:
                #expect(Bool(true))
            default:
                #expect(Bool(false))
            }
        }
        
        await sut.loadImage()
    }
    
    @MainActor
    @Test func shufflesPuzzle() {
        let puzzle = PuzzleModel.default
        let sut = makeSut(fetcher: makeFailingImageFetcher(), puzzle: puzzle)
        
        let tiles = puzzle.tiles
        
        sut.shuffle()
        
        #expect(sut.puzzle.tiles != tiles)
    }
    
    @MainActor
    @Test func calculatesGridDimension() {
        let sut = makeSutWithFailingFetcher()
        
        let vertical = CGSize(width: 100, height: 200)
        let dimension1 = sut.gridDimension(from: vertical)
        
        let horizontal = CGSize(width: 200, height: 100)
        let dimension2 = sut.gridDimension(from: horizontal)
        
        #expect(dimension1 == 60)
        #expect(dimension2 == 70)
    }
    
    
    // MARK: - Helper
    
    private let imageData = UIImage.strokedCheckmark.pngData()!
    
    // MARK: Factories
    
    private func makeSutWithFailingFetcher() -> ContentView.ViewModel {
        makeSut(fetcher: makeFailingImageFetcher())
    }
    
    private func makeSutWithSuccessFetcher() -> ContentView.ViewModel {
        makeSutWithSuccessFetcher(data: imageData)
    }
    
    private func makeSutWithSuccessFetcher(data: Data) -> ContentView.ViewModel {
        makeSut(fetcher: makeSuccessImageFetcher(data: data))
    }
    
    private func makeSut(fetcher: ImageFetcher) -> ContentView.ViewModel {
        makeSut(fetcher: fetcher, puzzle: .default)
    }
    
    private func makeSut(fetcher: ImageFetcher, puzzleOfSize size: Int) -> ContentView.ViewModel {
        makeSut(fetcher: fetcher, puzzle: makePuzzleModel(of: size))
    }
    
    private func makeSut(fetcher: ImageFetcher, puzzle: PuzzleModel) -> ContentView.ViewModel {
        ContentView.ViewModel(fetcher: fetcher, puzzle: puzzle)
    }
    
    private func makeFailingImageFetcher(local: ImageFetcher.Local = .default) -> ImageFetcher {
        ImageFetcher(network: makeFailingNetwork(), local: local)
    }
    
    private func makeSuccessImageFetcher(data: Data) -> ImageFetcher {
        ImageFetcher(network: makeSuccessNetwork(data: data), local: .default)
    }
    
    private func makeFailingNetwork() -> ImageFetcher.Network {
        ImageFetcher.Network(session: .shared, url: nil)
    }
    
    private func makeSuccessNetwork(data: Data) -> ImageFetcher.Network {
        makeNetwork(data: data)
    }
    
    private func makeNetwork(data: Data = Data()) -> ImageFetcher.Network {
        let url = URL(string: "https://foo.com")!
        let configuration = URLSessionConfiguration.ephemeral
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return ImageFetcher.Network(session: session, url: url)
    }
    
    private func makePuzzleModel(of size: Int) -> PuzzleModel {
        PuzzleModel(size: size)
    }
    
    // MARK: Observation
    
    private func observeState(of sut: ContentView.ViewModel, onChange: @MainActor @escaping (ContentView.ViewModel.State) -> Void) {
        withObservationTracking {
            _ = sut.state
        } onChange: {
            Task { @MainActor in
                onChange(sut.state)
            }
        }
    }
    
    private func observeStateAfterLoading(of sut: ContentView.ViewModel, onChange: @MainActor @escaping (ContentView.ViewModel.State) -> Void) {
        observeState(of: sut) { state in
            switch state {
            case .loading:
                observeState(of: sut, onChange: onChange)
            default:
                break
            }
        }
    }
}

extension ContentView.ViewModel.State: @retroactive Equatable {
    public static func == (lhs: ContentView.ViewModel.State, rhs: ContentView.ViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            true
        case (.loading, .loading):
            true
        case (.playing(let lhsSource), .playing(let rhsSource)):
            lhsSource == rhsSource
        case (.win(let lhsSource), .win(let rhsSource)):
            lhsSource == rhsSource
        case (.failure, .failure):
            true
        default:
            false
        }
    }
}

extension ContentView.ViewModel.State.Source: @retroactive Equatable {
    public static func == (lhs: ContentView.ViewModel.State.Source, rhs: ContentView.ViewModel.State.Source) -> Bool {
        switch (lhs, rhs) {
        case (.network(let lhsImage), .network(let rhsImage)):
            lhsImage == rhsImage
        case (.fallback(let lhsImage), .fallback(let rhsImage)):
            lhsImage == rhsImage
        default:
            false
        }
    }
}

final class MockURLProtocol: URLProtocol {
    static var error: Error?
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
    
        guard let handler = MockURLProtocol.requestHandler else {
            assertionFailure("Received unexpected request with no handler set")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
