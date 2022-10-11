//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by AmritPandey on 12/09/22.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesnotSendAnyMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImage_displayLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueItem()
        
        sut.didStartLoadingImage(model: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.shoulretry, false)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displayRetryOnfailedImagetransformation() {
        let (sut, view) = makeSUT()
        let image = uniqueItem()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.shoulretry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        
    }
    
    func test_didFinishLoadingImageData_displayImageOnSucessFulTransformation() {
        let transformedImage = AnyImage()
        let (sut, view) = makeSUT { _ in
            transformedImage
        }
        let image = uniqueItem()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.shoulretry, false)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNotNil(message?.image)
        
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let (sut, view) = makeSUT()
        let error = anyError()
        let image = uniqueItem()
        
        sut.didFinishLoadingImageData(with: error, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.shoulretry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping  ((Data) -> AnyImage?) = {_ in nil}, file: StaticString = #file, line: Int = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(feedImage: view, imageTranformer: imageTransformer)
        trackMemoryLeak(instance: view)
        trackMemoryLeak(instance: sut)
        return (sut, view)
    }
    
    private struct AnyImage: Equatable { }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }

}
