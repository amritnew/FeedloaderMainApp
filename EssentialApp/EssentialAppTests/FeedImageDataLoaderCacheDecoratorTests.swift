//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 12/10/22.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init (decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let loader = LoaderSpy()
        let _ = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        
        XCTAssertTrue(loader.loadedUrls.isEmpty)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyUrl()
        let loader = LoaderSpy()
        let _ = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        
        _ = loader.loadImageData(from: url) { _ in  }
        
        XCTAssertFalse(loader.loadedUrls.isEmpty)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        
        var loadedUrls: [URL] = []
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            loadedUrls.append(url)
            return Task()
        }
    }
}
