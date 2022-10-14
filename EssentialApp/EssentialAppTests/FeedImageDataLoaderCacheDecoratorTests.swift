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
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: FeedImageDataLoader, loader: LoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
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
}
