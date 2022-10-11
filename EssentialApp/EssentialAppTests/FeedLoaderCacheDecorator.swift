//
//  FeedLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 11/10/22.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load { [weak self] result in
            if let items = try? result.get() {
                self?.cache.save(items, completion: { _ in })
            }
            completion(result)
        }
        
    }
}


class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut: sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyError()))
        
        expect(sut: sut, toCompleteWith: .failure(anyError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    //MARK: Helpers
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: Int = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackMemoryLeak(instance: loader)
        trackMemoryLeak(instance: sut)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
            
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(items))
            completion(.success(()))
        }
    }

}
