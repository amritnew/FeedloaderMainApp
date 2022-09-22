//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 22/09/22.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryLoader = primary
        self.fallbackLoader = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = primaryLoader.loadImageData(from: url, completion: completion)
        return Task()
    }

}


class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_doesNotLoadImage() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
                
        XCTAssertTrue(primaryLoader.loaderURLs.isEmpty, "Expected no loaded url on primary loader")
        XCTAssertTrue(fallbackLoader.loaderURLs.isEmpty, "Expected no loaded url on secondary loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyUrl()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { result in }
        
        XCTAssertEqual(primaryLoader.loaderURLs, [url], "Expected primary loader has loaded url")
        XCTAssertTrue(fallbackLoader.loaderURLs.isEmpty, "Expected no loaded url on secondary loader")
    }
    
    //MARK: Helpers
    
    private func makeSUT() -> (sut: FeedImageDataLoaderWithFallbackComposite, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func anyUrl() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        var loaderURLs = [URL]()
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() { }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            loaderURLs.append(url)
            return Task()
        }
    }

}
