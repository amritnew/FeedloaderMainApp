//
//  LoadImageCommentFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by AmritPandey on 30/12/22.
//

import XCTest
import EssentialFeed

final class LoadImageCommentFromRemoteUseCase: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load{_ in}
        sut.load{_ in}

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(RemoteImageCommentLoader.Error.connectivity) ) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(RemoteImageCommentLoader.Error.invalidData)) {
                let json = makeItemJson(items: [])
                client.complete(with: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .failure(RemoteImageCommentLoader.Error.invalidData)) {
            let invalidJson = Data( "invalidJson".utf8)
            client.complete(with: 200, data: invalidJson)
        }
    }
    
    func test_load_deliversNoItemson200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemJson(items: [])
            client.complete(with: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(), message: "a comment", createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"), author: CommentAuthorObject(username: "an author"))

        let item2 = makeItem(id: UUID(), message: "another comment", createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"), author: CommentAuthorObject(username: "another author"))

        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let data = makeItemJson(items: [item1.json, item2.json])
            client.complete (with: 200, data: data)
        }
    }
    
    func test_doesnotDeliverAfterSUTIsDeallocated() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(url: url, client: client)

        var capturedErrors = [RemoteImageCommentLoader.Result]()
        sut?.load { capturedErrors.append($0) }

        sut = nil
        client.complete(with: 200, data: makeItemJson(items: []))

        XCTAssertTrue(capturedErrors.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
        trackMemoryLeak(instance: sut)
        trackMemoryLeak(instance: client)
        return (sut, client)
    }
    
    
    
    private func expect(_ sut: RemoteImageCommentLoader, toCompleteWithResult expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedItems), .success(expectedItems)):
                XCTAssertEqual(recievedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got instead \(recievedResult)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), author: CommentAuthorObject) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, author: author)

        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_At": createdAt.iso8601String,
            "author": [
                "username": author.username
            ]
        ]

        return (item, json)
    }
    
    private func makeItemJson(items: [[String: Any]]) -> Data {
        let itemJSON = [
            "items" : items
            ]
        return try! JSONSerialization.data(withJSONObject: itemJSON)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() { }
        }
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map{$0.url}
        }
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
            messages.append((url: url, completion: completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            messages[index].completion(.success((data, response!)))
        }

    }
}
