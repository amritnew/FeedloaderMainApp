//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by AmritPandey on 12/01/23.
//

import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    
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
        expect(sut, toCompleteWithResult: .failure(RemoteLoader<String>.Error.connectivity) ) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnMappedError() {
        let (sut, client) = makeSUT() { _, _ in
            throw anyError()
        }
        expect(sut, toCompleteWithResult: .failure(RemoteLoader<String>.Error.invalidData)) {
            client.complete(with: 200, data: anyData())
        }
    }
    
    func test_load_deliversItemOnMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT() {data, _ in
            String(data: data, encoding: .utf8)!
        }

        expect(sut, toCompleteWithResult: .success(resource)) {
            client.complete (with: 200, data: resource.data(using: .utf8)! )
        }
    }
    
    func test_doesnotDeliverAfterSUTIsDeallocated() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader(url: url, client: client) {_, _ in "any"}

        var capturedErrors = [RemoteLoader<String>.Result]()
        sut?.load { capturedErrors.append($0) }

        sut = nil
        client.complete(with: 200, data: makeItemJson(items: []))

        XCTAssertTrue(capturedErrors.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = {_, _ in "any"},
        file: StaticString = #file,
        line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        trackMemoryLeak(instance: sut)
        trackMemoryLeak(instance: client)
        return (sut, client)
    }

    private func expect(_ sut: RemoteLoader<String>, toCompleteWithResult expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
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
}
