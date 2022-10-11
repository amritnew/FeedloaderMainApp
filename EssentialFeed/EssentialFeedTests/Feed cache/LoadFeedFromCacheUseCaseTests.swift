//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 08/06/22.
//

import Foundation
import XCTest
@testable import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesnotHaveAnyMessageUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
     
    func test_load_cacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyError()
        
        expect(sut, toCompleteWithResult: .failure(retrievalError)) {
            store.completeRetrievalWithError(error: retrievalError)
        }

    }
    
    func test_load_deliverNoImageOnEmptyCache() {
        let (store, sut) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliverImageCacheOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let onNonExpiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success(feed.models)) {
            store.completeRetrievalWith(imageCache: feed.localModels, timestamp: onNonExpiredTimestamp )
        }
    }
    
    func test_load_deliverEmptyImageCacheOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let expirationTimestamp = currentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWith(imageCache: feed.localModels, timestamp: expirationTimestamp )
        }
    }
    
    func test_load_deliverEmptyImageCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWith(imageCache: feed.localModels, timestamp: expiredTimestamp )
        }
    }
    
    func test_load_hasNoSideEffectOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithError(error: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load {_ in }
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let expirationCache = currentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT { currentDate }
        
        sut.load {_ in }
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: expirationCache)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let expiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load {_ in }
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: expiredCache)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesnotDeliverResultAfterSUTInstanceBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResult.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return(store, sut)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Wair for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedImages), .success(expectedImages)):
                XCTAssertEqual(recievedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got instead \(recievedResult)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
    }
}

