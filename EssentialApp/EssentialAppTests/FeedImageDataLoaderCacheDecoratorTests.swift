//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 12/10/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedUrls.isEmpty)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyUrl()
        let (_, loader) = makeSUT()
        
        _ = loader.loadImageData(from: url) { _ in  }
        
        XCTAssertFalse(loader.loadedUrls.isEmpty)
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyUrl()
        let (sut, loader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from loader")
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        
        expect(sut, expectedResult: .success(anyData())) {
            loader.complete(with: anyData())
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()

        expect(sut, expectedResult: .failure(anyError())) {
            loader.complete(with: anyError())
        }
    }
    
    func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
        let cache = CachesSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyUrl()) { _ in }
        loader.complete(with: anyData())
        
        XCTAssertEqual(cache.messages, [.save(data: anyData(), for: anyUrl())], "Expected to cache loaded image data on success")
    }
    
    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let cache = CachesSpy()
        let url = anyUrl()
        let (sut, loader) = makeSUT(cache: cache)

        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: anyError())

        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache image data on load error")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(cache: CachesSpy = .init()) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackMemoryLeak(instance: loader)
        trackMemoryLeak(instance: sut)
        return (sut, loader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        _ = sut.loadImageData(from: anyUrl()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expected), .success(received)):
                XCTAssertEqual(expected, received, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class CachesSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
            
        enum Message: Equatable {
            case save(data: Data, for: URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data: data, for: url))
            completion(.success(()))
        }
    }
}
