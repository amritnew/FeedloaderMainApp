//
//  RemoteWithLocalFeedLoaderFallbackTests.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 22/09/22.
//

import XCTest
import EssentialFeed

final class FeedLoaderWithFallbackComposite: FeedLoader {
    let primaryLoader: FeedLoader
    let fallbackLoader: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        primaryLoader = primary
        fallbackLoader = fallback
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        primaryLoader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallbackLoader.load(completion: completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut: sut, toCompleteWith: .success(primaryFeed), file: #file, line: #line)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut: sut, toCompleteWith: .success(fallbackFeed))
    }
    
    //MARK: Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackMemoryLeak(instance: primaryLoader, file: file, line: line)
        trackMemoryLeak(instance: fallbackLoader, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    private func expect(sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult) result, got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func trackMemoryLeak(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of sut have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            completion(result)
        }
    }
    
}
