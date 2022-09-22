//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 22/09/22.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryLoader = primary
        self.fallbackLoader = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        _ = primaryLoader.loadImageData(from: url, completion: completion)
    }
}


class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_doesNotLoadImage() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
                
        XCTAssertTrue(primaryLoader.loaderURLs.isEmpty, "Expected no loaded url on primary loader")
        XCTAssertTrue(fallbackLoader.loaderURLs.isEmpty, "Expected no loaded url on secondary loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyUrl()
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        sut.loadImageData(from: url) { result in }
        
        XCTAssertEqual(primaryLoader.loaderURLs, [url], "Expected primary loader has loaded url")
        XCTAssertTrue(fallbackLoader.loaderURLs.isEmpty, "Expected no loaded url on secondary loader")
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
