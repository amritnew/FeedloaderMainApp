//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by AmritPandey on 07/09/22.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displayNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)], "Expected messages has no error messsage")
    }
    
    func test_didFinishLoadingFeed_displayFeedsAndStopLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)])
    }
    
    func test_didFinishLoadinFeedWithError_displayLoacalizedErrorMessageAndStopLoading() {
        let (sut, view) = makeSUT()
        let error = anyError()
        
        sut.didFinishLoadingFeed(with: error)
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }
    
    // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: Int = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackMemoryLeak(instance: view)
        trackMemoryLeak(instance: sut)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let localizedKey = key
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string key: \(localizedKey) in table \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feeds))
        }
    }
}
