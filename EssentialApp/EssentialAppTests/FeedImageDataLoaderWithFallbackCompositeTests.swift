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
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryLoader = primary
        self.fallbackLoader = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primaryLoader.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case .failure:
                task.wrapped = self?.fallbackLoader.loadImageData(from: url, completion: { _ in })
            }
        })
        return task
    }

}


class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_doesNotLoadImage() {
        let (_, primaryLoader, fallbackLoader) = makeSUT(file: #file, line: #line)
                
        XCTAssertTrue(primaryLoader.loaderURLs.isEmpty, "Expected no loaded url on primary loader")
        XCTAssertTrue(fallbackLoader.loaderURLs.isEmpty, "Expected no loaded url on secondary loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyUrl()
        let (sut, primaryLoader, fallbackLoader) = makeSUT(file: #file, line: #line)
        
        _ = sut.loadImageData(from: url) { result in }
        
        XCTAssertEqual(primaryLoader.loaderURLs, [url], "Expected primary loader has loaded url")
        XCTAssertTrue(fallbackLoader.loaderURLs.isEmpty, "Expected no loaded url on secondary loader")
    }
    
    func test_loadImageData_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let url = anyUrl()
        let (sut, primaryLoader, fallbackLoader) = makeSUT(file: #file, line: #line)
        
        _ = sut.loadImageData(from: url) { result in }
        
        primaryLoader.complete(with: anyError())
        
        XCTAssertEqual(primaryLoader.loaderURLs, [url], "Expected primary loader has loaded url")
        XCTAssertEqual(fallbackLoader.loaderURLs, [url], "Expected fallback loader has loaded url")
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let url = anyUrl()
        let (sut, primaryLoader, fallbackLoader) = makeSUT(file: #file, line: #line)
        
        let task = sut.loadImageData(from: url) { result in }
        
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledUrls, [url], "Expected primary loader has cancelled url")
        XCTAssertTrue(fallbackLoader.cancelledUrls.isEmpty, "Expected fallback loader has no cancelled url")
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyUrl()
        let (sut, primaryLoader, fallbackLoader) = makeSUT(file: #file, line: #line)
        
        let task = sut.loadImageData(from: url) { result in }
        primaryLoader.complete(with: anyError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledUrls.isEmpty, "Expected primary loader has no cancelled url")
        XCTAssertEqual(fallbackLoader.cancelledUrls, [url], "Expected fallback loader has cancelled url")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let primaryData = anyData()
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success(primaryData)) {
            primaryLoader.complete(with: primaryData)
        }
    }
    
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackMemoryLeak(instance: primaryLoader, file: file, line: line)
        trackMemoryLeak(instance: fallbackLoader, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func trackMemoryLeak(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of sut have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func anyUrl() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any-data".utf8)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    private func expect(sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        _ = sut.loadImageData(from: anyUrl(), completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult) result, got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        })
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledUrls = [URL]()
        
        var loaderURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledUrls.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }

}
