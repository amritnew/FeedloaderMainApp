//
//  ValidateFeedCacheUseTestCaseFiles.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 09/06/22.
//

import XCTest
@testable import EssentialFeed

class ValidateFeedCacheUseTestCaseFiles: XCTestCase {

    func test_init_doesnotHaveAnyMessageUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validate_deleteCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validate()
        store.completeRetrievalWithError(error: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validate_doesnotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.validate()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validate_doesnotDeleteOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let nonExpiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validate()
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: nonExpiredCache)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validate_deleteCacheOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let expirationCache = currentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT { currentDate }
        
        sut.validate()
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: expirationCache)
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validate_deleteCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let expiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validate()
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: expiredCache)
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validate_doesnotDeleteInvalidcacheAfterSUThasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validate()
        sut = nil
        store.completeRetrievalWithError(error: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }

    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return(store, sut)
    }
}


