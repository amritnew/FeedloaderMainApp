//
//  FeedLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 11/10/22.
//

import XCTest
import EssentialFeed

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load(completion: completion)
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
    
    //MARK: Helpers
    private func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: Int = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        return sut
    }

}
